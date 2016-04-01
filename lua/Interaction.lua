if string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then

	PlayerStandard.LOCK_MODE = WolfHUD.settings.LOCK_MODE or 2														--Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time, or current interaction time
	PlayerStandard.MIN_TIMER_DURATION = WolfHUD.settings.MIN_TIMER_DURATION or 5 									--Min interaction duration (in seconds) for the toggle behavior to activate
	PlayerStandard.EQUIPMENT_PRESS_INTERRUPT = WolfHUD.settings.EQUIPMENT_PRESS_INTERRUPT or not WolfHUD and true 	--Use the equipment key ('G') to toggle off active interactions
	PlayerStandard.NADE_TIMEOUT = 0.25																				--Timeout for 2 NadeKey pushes, to prevent accidents in stealth

	local _update_interaction_timers_original = PlayerStandard._update_interaction_timers
	local _check_action_interact_original = PlayerStandard._check_action_interact
	local _check_action_throw_grenade_original = PlayerStandard._check_action_throw_grenade
	
	function PlayerStandard:_update_interaction_timers(t, ...)
		self:_check_interaction_locked(t)
		return _update_interaction_timers_original(self, t, ...)
	end
	
	function PlayerStandard:_check_action_interact(t, input, ...)
		if not self:_check_interact_toggle(t, input) then
			return _check_action_interact_original(self, t, input, ...)
		end
	end
	
	
	function PlayerStandard:_check_interaction_locked(t) 
		local is_locked = false
		if PlayerStandard.LOCK_MODE == 1 then
			is_locked = self._interact_expire_t and (t - (self._interact_expire_t - self._interact_params.timer) >= PlayerStandard.MIN_TIMER_DURATION) --lock interaction, when interacting longer then given time
		elseif PlayerStandard.LOCK_MODE == 2 then
			is_locked = self._interact_params and (self._interact_params.timer >= PlayerStandard.MIN_TIMER_DURATION) -- lock interaction, when total timer time is longer then given time
		end
		
		if self._interaction_locked ~= is_locked then
			managers.hud:set_interaction_bar_locked(is_locked)
			self._interaction_locked = is_locked
		end
	end
	
	function PlayerStandard:_check_interact_toggle(t, input)
		local interrupt_key_press = input.btn_interact_press
		if PlayerStandard.EQUIPMENT_PRESS_INTERRUPT then
			interrupt_key_press = input.btn_use_item_press
		end
		
		if interrupt_key_press and self:_interacting() then
			self:_interupt_action_interact()
			return true
		elseif input.btn_interact_release and self._interact_params then
			if self._interaction_locked then
				return true
			end
		end
	end
	
	function PlayerStandard:_check_action_throw_grenade(t, input, ...)
		if input.btn_throw_grenade_press and (WolfHUD.settings.SUPRESS_NADES_STEALTH or not WolfHUD) then
			if managers.groupai:state():whisper_mode() and (t - (self._last_grenade_t or 0) >= PlayerStandard.NADE_TIMEOUT) then
				self._last_grenade_t = t
				return
			end
		end
		
		return _check_action_throw_grenade_original(self, t, input, ...)
	end

elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playercivilian" then

	local _update_interaction_timers_original = PlayerCivilian._update_interaction_timers
	local _check_action_interact_original = PlayerCivilian._check_action_interact
	
	function PlayerCivilian:_update_interaction_timers(t, ...)
		self:_check_interaction_locked(t)
		return _update_interaction_timers_original(self, t, ...)
	end
	
	function PlayerCivilian:_check_action_interact(t, input, ...)
		if not self:_check_interact_toggle(t, input) then
			return _check_action_interact_original(self, t, input, ...)
		end
	end
	
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

	function HUDManager:set_interaction_bar_locked(status)
		self._hud_interaction:set_locked(status)
	end
	
elseif string.lower(RequiredScript) == "lib/managers/hud/hudinteraction" then
	
	HUDInteraction.SHOW_LOCK_INDICATOR = WolfHUD.settings.SHOW_LOCK_INDICATOR or not WolfHUD and true
	HUDInteraction.SHOW_TIME_REMAINING = WolfHUD.settings.SHOW_TIME_REMAINING or not WolfHUD and true
	HUDInteraction.GRADIENT_COLOR = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] or Color.green

	local show_interaction_bar_original = HUDInteraction.show_interaction_bar
	local hide_interaction_bar_original = HUDInteraction.hide_interaction_bar
	local destroy_original				= HUDInteraction.destroy
	
	local set_interaction_bar_width_original = HUDInteraction.set_interaction_bar_width
	
	function HUDInteraction:set_interaction_bar_width(current, total)
		set_interaction_bar_width_original(self, current, total)
		if HUDInteraction.SHOW_TIME_REMAINING then
			self._interact_time:set_text(string.format("%.1fs", math.max(total - current, 0)))
			local perc = current/total
			local color = perc * HUDInteraction.GRADIENT_COLOR + (1-perc) * Color.white
			self._interact_time:set_color(color)
			self._interact_time:set_alpha(1)
			self._interact_time:set_visible(perc < 1)
		end
		if self._old_text and self._new_text then
			self._hud_panel:child(self._child_name_text):set_text(self._new_text)
		end
	end
	
	
	function HUDInteraction:show_interaction_bar(current, total)
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end
		
		if PlayerStandard.LOCK_MODE < 3 and HUDInteraction.SHOW_LOCK_INDICATOR then
			self._interact_circle_locked = CircleBitmapGuiObject:new(self._hud_panel, {
				radius = self._circle_radius,
				color = Color.red,
				blend_mode = "normal",
				alpha = 0,
			})
			self._interact_circle_locked:set_position(self._hud_panel:w() / 2 - self._circle_radius, self._hud_panel:h() / 2 - self._circle_radius)
			self._interact_circle_locked:set_color(Color.red)
			self._interact_circle_locked._circle:set_render_template(Idstring("Text"))
		end
		
		if HUDInteraction.SHOW_TIME_REMAINING and not self._interact_time then
			self._interact_time = self._hud_panel:text({
			name = "interaction_timer",
			visible = false,
			text = "",
			valign = "center",
			align = "center",
			layer = 1,
			color = Color.white,
			font = tweak_data.menu.default_font,
			font_size = 32,
			h = 64
			})
			
			self._interact_time:set_y(self._hud_panel:h() / 2 + 10)
			if self._interact_time then
				self._interact_time:show()
				self._interact_time:set_text(string.format("%.1fs", total))
			end
		end
		
		return show_interaction_bar_original(self, current, total)
	end
	

	function HUDInteraction:hide_interaction_bar(...)		
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end
		
		if self._interact_time then
			self._interact_time:set_text("")
			self._interact_time:set_visible(false)
		end
		
		local val = hide_interaction_bar_original(self, ...)
		self._hud_panel:child(self._child_name_text):set_text(self._old_text or self._hud_panel:child(self._child_name_text):text())
		self._old_text = nil
		return val
	end

	function HUDInteraction:set_locked(status)
		if self._interact_circle_locked then
			self._interact_circle_locked._circle:set_color(status and Color.green or Color.red)
			self._interact_circle_locked._circle:set_alpha(0.25)
		end
		
		if status then
			self._old_text = self._hud_panel:child(self._child_name_text):text()
			local type = managers.controller:get_default_wrapper_type()
			local interact_key  = managers.controller:get_settings(type):get_connection("interact"):get_input_name_list()[1] or "f"
			local equipment_key = managers.controller:get_settings(type):get_connection("use_item"):get_input_name_list()[1] or "g"
			self._new_text = string.upper(managers.localization:text("wolfhud_int_locked", {BTN = (PlayerStandard.EQUIPMENT_PRESS_INTERRUPT and equipment_key or interact_key)}))
		end
	end
	
	function HUDInteraction:destroy()
		self._hud_panel:remove(self._interact_time)
		--self._interact_time = nil
		destroy_original(self)
	end
elseif string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then
	ObjectInteractionManager.AUTO_PICKUP_DELAY = 0.3 --Delay in seconds between auto-pickup procs (0 -> as fast as possible)
	local _update_targeted_original = ObjectInteractionManager._update_targeted
	function ObjectInteractionManager:_update_targeted(...)
		_update_targeted_original(self, ...)

		if alive(self._active_unit) and WolfHUD.settings.HOLD2PICK then
			local t = Application:time()
			if self._active_unit:base() and self._active_unit:base().small_loot and managers.menu:get_controller():get_input_bool("interact") and (t >= (self._next_auto_pickup_t or 0)) then
				self._next_auto_pickup_t = t + ObjectInteractionManager.AUTO_PICKUP_DELAY
				self:interact(managers.player:player_unit())
			end
		end
	end
end