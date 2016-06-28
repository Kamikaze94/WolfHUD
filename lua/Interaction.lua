if string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
	PlayerStandard.NADE_TIMEOUT = 0.25																	--Timeout for 2 NadeKey pushes, to prevent accidents in stealth

	local enter_original = PlayerStandard.enter
	local _update_interaction_timers_original = PlayerStandard._update_interaction_timers
	local _check_action_interact_original = PlayerStandard._check_action_interact
	local _start_action_reload_original = PlayerStandard._start_action_reload
	local _update_reload_timers_original = PlayerStandard._update_reload_timers
	local _interupt_action_reload_original = PlayerStandard._interupt_action_reload
	local _start_action_melee_original = PlayerStandard._start_action_melee
	local _update_melee_timers_original = PlayerStandard._update_melee_timers
	local _do_melee_damage_original = PlayerStandard._do_melee_damage
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
		PlayerStandard.LOCK_MODE = WolfHUD:getSetting("LOCK_MODE", "number")						--Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time, or current interaction time
		PlayerStandard.MIN_TIMER_DURATION = WolfHUD:getSetting("MIN_TIMER_DURATION", "number")		--Min interaction duration (in seconds) for the toggle behavior to activate	
		local is_locked = false
		if PlayerStandard.LOCK_MODE >= 3 then
			is_locked = self._interact_params and (self._interact_params.timer >= PlayerStandard.MIN_TIMER_DURATION) -- lock interaction, when total timer time is longer then given time
		elseif PlayerStandard.LOCK_MODE >= 2 then
			is_locked = self._interact_expire_t and (t - (self._interact_expire_t - self._interact_params.timer) >= PlayerStandard.MIN_TIMER_DURATION) --lock interaction, when interacting longer then given time
		end
		
		if self._interaction_locked ~= is_locked then
			managers.hud:set_interaction_bar_locked(is_locked)
			self._interaction_locked = is_locked
		end
	end
	
	function PlayerStandard:_check_interact_toggle(t, input)
		PlayerStandard.EQUIPMENT_PRESS_INTERRUPT = WolfHUD:getSetting("EQUIPMENT_PRESS_INTERRUPT", "boolean") 	--Use the equipment key ('G') to toggle off active interactions
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
	
	local hide_int_state = {
		["bleed_out"] = true,
		["fatal"] = true,
		["incapacitated"] = true,
		["arrested"] = true,
		["jerry1"] = true
	}
	function PlayerStandard:enter(...)
		enter_original(self, ...)
		if hide_int_state[managers.player:current_state()] and (self._state_data.show_reload or self._state_data.show_melee) then
			managers.hud:hide_interaction_bar(false)
			self._state_data.show_reload = false
			self._state_data.show_melee = false
		end
	end
	
	function PlayerStandard:_start_action_reload(t, ...)
		_start_action_reload_original(self, t, ...)
		PlayerStandard.SHOW_RELOAD = WolfHUD:getSetting("SHOW_RELOAD", "boolean")
		if PlayerStandard.SHOW_RELOAD and not hide_int_state[managers.player:current_state()] then
			if self._equipped_unit and not self._equipped_unit:base():clip_full() then
				self._state_data.show_reload = true
				managers.hud:show_interaction_bar(0, self._state_data.reload_expire_t or 0)
				self._state_data.reload_offset = t
			end
		end
	end

	function PlayerStandard:_update_reload_timers(t, ...)
		_update_reload_timers_original(self, t, ...)
		if PlayerStandard.SHOW_RELOAD then
			if self._state_data.show_reload and hide_int_state[managers.player:current_state()] then
				managers.hud:hide_interaction_bar(false)
				self._state_data.show_reload = false
			elseif not self._state_data.reload_expire_t and self._state_data.show_reload then
				managers.hud:hide_interaction_bar(true)
				self._state_data.show_reload = false
			elseif self._state_data.show_reload then
				managers.hud:set_interaction_bar_width(	t and t - self._state_data.reload_offset or 0, self._state_data.reload_expire_t and self._state_data.reload_expire_t - self._state_data.reload_offset or 0 )
			end
		end
	end

	function PlayerStandard:_interupt_action_reload(...)
		local val = _interupt_action_reload_original(self, ...)
		if self._state_data.show_reload and PlayerStandard.SHOW_RELOAD then
			managers.hud:hide_interaction_bar(false)
			self._state_data.show_reload = false
		end
		return val
	end
	
	function PlayerStandard:_start_action_melee(...)
		local val = _start_action_melee_original(self, ...)
		PlayerStandard.SHOW_MELEE = WolfHUD:getSetting("SHOW_MELEE", "boolean")
		if PlayerStandard.SHOW_MELEE and self._state_data.meleeing and not hide_int_state[managers.player:current_state()] then
			self._state_data.show_melee = true
			managers.hud:show_interaction_bar(0, 1)
		end
		return val
	end
	
	function PlayerStandard:_update_melee_timers(t, ...)
		local val = _update_melee_timers_original(self, t, ...)
		if PlayerStandard.SHOW_MELEE and self._state_data.meleeing and self._state_data.show_melee then
			local melee_lerp = self:_get_melee_charge_lerp_value(t)
			if hide_int_state[managers.player:current_state()] then
				managers.hud:hide_interaction_bar(false)
				self._state_data.show_melee = false
			elseif melee_lerp < 1 then
				managers.hud:set_interaction_bar_width(melee_lerp, 1)
			elseif self._state_data.show_melee then
				managers.hud:hide_interaction_bar(true)
				self._state_data.show_melee = false
			end
		end
		return val
	end
	
	function PlayerStandard:_do_melee_damage(...)
		managers.hud:hide_interaction_bar(false)
		self._state_data.show_melee = false
		return _do_melee_damage_original(self, ...)
	end
	
	function PlayerStandard:_check_action_throw_grenade(t, input, ...)
		if input.btn_throw_grenade_press and WolfHUD:getSetting("SUPRESS_NADES_STEALTH", "boolean") then
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
	local init_original 				= HUDInteraction.init
	local show_interaction_bar_original = HUDInteraction.show_interaction_bar
	local hide_interaction_bar_original = HUDInteraction.hide_interaction_bar
	local show_interact_original		= HUDInteraction.show_interact
	local destroy_original				= HUDInteraction.destroy
	
	local set_interaction_bar_width_original = HUDInteraction.set_interaction_bar_width
	
	function HUDInteraction:init(...)
		init_original(self, ...)
		
		local interact_text = self._hud_panel:child(self._child_name_text)
		local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
		self._original_circle_radius = self._circle_radius
		self._original_interact_text_font_size = interact_text:font_size()
		self._original_invalid_text_font_size = invalid_text:font_size()
		
		self:_rescale()
	end
	
	function HUDInteraction:set_interaction_bar_width(current, total)
		set_interaction_bar_width_original(self, current, total)
		local color_end = Color.white
		if not HUDInteraction.GRADIENT_COLOR then
			local t = Application:time()
			local r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
			color_end = Color(r, g, b)
		else
			color_end = HUDInteraction.GRADIENT_COLOR
		end
		
		if HUDInteraction.SHOW_TIME_REMAINING then
			self._interact_time:set_text(string.format("%.1fs", math.max(total - current, 0)))
			local perc = current/total
			local color = math.lerp(Color.white, color_end, perc)--perc * color + (1-perc) * Color.white
			self._interact_time:set_color(color)
			self._interact_time:set_alpha(1)
			self._interact_time:set_visible(perc < 1)
		end
	end
	
	
	function HUDInteraction:show_interaction_bar(current, total)
		self:_rescale()
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end
		
		local val = show_interaction_bar_original(self, current, total)
		
		HUDInteraction.SHOW_LOCK_INDICATOR = WolfHUD:getSetting("SHOW_LOCK_INDICATOR", "boolean")
		HUDInteraction.SHOW_TIME_REMAINING = WolfHUD:getSetting("SHOW_TIME_REMAINING", "boolean")
		HUDInteraction.SHOW_CIRCLE 	= WolfHUD:getSetting("SHOW_CIRCLE", "boolean")
		HUDInteraction.LOCK_MODE = PlayerStandard.LOCK_MODE or 1
		HUDInteraction.GRADIENT_COLOR = not (WolfHUD:getSetting("GRADIENT_COLOR", "string") == "rainbow") and WolfHUD:getSetting("GRADIENT_COLOR", "color") or false
		if HUDInteraction.SHOW_CIRCLE then
			if HUDInteraction.LOCK_MODE > 1 and HUDInteraction.SHOW_LOCK_INDICATOR then
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
		else
			HUDInteraction.SHOW_LOCK_INDICATOR = false
			self._interact_circle:set_visible(false)
		end
		
		if HUDInteraction.SHOW_TIME_REMAINING then
			if not self._interact_time then
				self._interact_time = self._hud_panel:text({
				name = "interaction_timer",
				visible = false,
				text = "",
				valign = "center",
				align = "center",
				layer = 1,
				color = Color.white,
				font = tweak_data.menu.default_font,
				font_size = 32 * (self._circle_scale or 1),
				h = 64
				})
			else
				self._interact_time:set_font_size(32 * (self._circle_scale or 1))
			end
			self._interact_time:set_y(self._hud_panel:center_y() + self._circle_radius - (2 * self._interact_time:font_size()))
		end
		
		if self._interact_time then
			self._interact_time:show()
			self._interact_time:set_text(string.format("%.1fs", total))
		end
		
		return val
	end
	

	function HUDInteraction:hide_interaction_bar(complete, ...)		
		if self._interact_circle_locked then
			self._interact_circle_locked:remove()
			self._interact_circle_locked = nil
		end
		
		if self._interact_time then
			self._interact_time:set_text("")
			self._interact_time:set_visible(false)
		end
		
		if not complete and self._old_text then
			self._hud_panel:child(self._child_name_text):set_text(self._old_text or "")
		elseif complete and HUDInteraction.SHOW_CIRCLE then
			local bitmap = self._hud_panel:bitmap({texture = "guis/textures/pd2/hud_progress_active", blend_mode = "add", align = "center", valign = "center", layer = 2, w = 2 * self._circle_radius, h = 2 * self._circle_radius})
			bitmap:set_position(bitmap:parent():w() / 2 - bitmap:w() / 2, bitmap:parent():h() / 2 - bitmap:h() / 2)
			local circle = CircleBitmapGuiObject:new(self._hud_panel, {radius = self._circle_radius, sides = 64, current = 64, total = 64, color = Color.white:with_alpha(1), blend_mode = "normal", layer = 3})
			circle:set_position(self._hud_panel:w() / 2 - self._circle_radius, self._hud_panel:h() / 2 - self._circle_radius)
			bitmap:animate(callback(self, self, "_animate_interaction_complete"), circle)
		end
		self._old_text = nil
		return hide_interaction_bar_original(self, false, ...)
	end

	function HUDInteraction:set_locked(status)
		if self._interact_circle_locked then
			self._interact_circle_locked._circle:set_color(status and Color.green or Color.red)
			self._interact_circle_locked._circle:set_alpha(0.25)
		end
		
		if status then
			self._old_text = self._hud_panel:child(self._child_name_text):text()
			local locked_text = ""
			if WolfHUD:getSetting("SHOW_INTERRUPT_HINT", "boolean") then
				local btn_cancel = PlayerStandard.EQUIPMENT_PRESS_INTERRUPT and (managers.localization:btn_macro("use_item", true) or managers.localization:get_default_macro("BTN_USE_ITEM")) or (managers.localization:btn_macro("interact", true) or managers.localization:get_default_macro("BTN_INTERACT"))
				locked_text = managers.localization:to_upper_text("wolfhud_int_locked", {BTN_CANCEL = btn_cancel})
			end
			self._hud_panel:child(self._child_name_text):set_text(locked_text)
		end
	end
	
	function HUDInteraction:show_interact(data)
		self:_rescale()
		if not self._old_text then
			return show_interact_original(self, data)
		end
	end
	
	function HUDInteraction:destroy()
		if self._interact_time and self._hud_panel then
			self._hud_panel:remove(self._interact_time)
			self._interact_time = nil
		end
		destroy_original(self)
	end
	
	function HUDInteraction:_rescale(circle_scale, text_scale)
		local circle_scale = circle_scale or WolfHUD:getSetting("CIRCLE_SCALE", "number")
		local text_scale = text_scale or WolfHUD:getSetting("TEXT_SCALE", "number")
		local interact_text = self._hud_panel:child(self._child_name_text)
		local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
		local changed = false
		if self._circle_scale ~= circle_scale then
			self._circle_radius = self._original_circle_radius * circle_scale
			self._circle_scale = circle_scale
			changed = true
		end
		if self._text_scale ~= text_scale then
			local interact_text = self._hud_panel:child(self._child_name_text)
			local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
			interact_text:set_font_size(self._original_interact_text_font_size * text_scale)
			invalid_text:set_font_size(self._original_invalid_text_font_size * text_scale)
			self._text_scale = text_scale
			changed = true
		end
		if changed then
			interact_text:set_y(self._hud_panel:h() / 2 + self._circle_radius + interact_text:font_size() / 2)
			invalid_text:set_center_y(interact_text:center_y())
		end
	end
elseif string.lower(RequiredScript) == "lib/units/interactions/interactionext" then
	local _add_string_macros_original = BaseInteractionExt._add_string_macros
	
	function BaseInteractionExt:would_be_bonus_bag(carry_id)
		if managers.loot:get_mandatory_bags_data().carry_id ~= "none" and carry_id and carry_id ~= managers.loot:get_mandatory_bags_data().carry_id then
			return true
		end
		local mandatory_bags_amount = managers.loot:get_mandatory_bags_data().amount or 0
		for _, data in ipairs(managers.loot._global.secured) do
			if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle then
				if mandatory_bags_amount > 1 and (managers.loot:get_mandatory_bags_data().carry_id == "none" or managers.loot._global.mandatory_bags.carry_id == data.carry_id) then
					mandatory_bags_amount = mandatory_bags_amount - 1
				elseif mandatory_bags_amount <= 1 then
					return true
				end
			end
		end
		return false
	end
	
	function BaseInteractionExt:get_unsecured_bag_value(carry_id)
		local carry_value = managers.money:get_bag_value(carry_id, 1)
		local bag_value = 0
		local bag_risk = 0
		local bag_skill_bonus = managers.player:upgrade_value("player", "secured_bags_money_multiplier", 1)
		if self:would_be_bonus_bag(carry_id) then
			local job_id = managers.job:current_job_id()
			local stars = managers.job:has_active_job() and managers.job:current_difficulty_stars() or 0
			local money_multiplier = managers.money:get_contract_difficulty_multiplier(stars)
			local total_stages = job_id and #tweak_data.narrative:job_chain(job_id) or 1
			bag_value = carry_value
			bag_risk = math.round(bag_value * money_multiplier)
		else
			bag_value = carry_value
		end
		return math.round((bag_value + bag_risk) * bag_skill_bonus / managers.money:get_tweak_value("money_manager", "offshore_rate"))
	end
	
	function BaseInteractionExt:_add_string_macros(macros)
		_add_string_macros_original(self, macros)
		if self._unit:carry_data() then
			macros.BTN_INTERACT = macros.BTN_INTERACT or managers.localization:get_default_macro("BTN_INTERACT") --Ascii ID for RB
			macros.BAG = managers.localization:text(tweak_data.carry[self._unit:carry_data():carry_id()].name_id)
			macros.VALUE = not tweak_data.carry[self._unit:carry_data():carry_id()].skip_exit_secure and " (" .. managers.experience:cash_string(self:get_unsecured_bag_value(self._unit:carry_data():carry_id(), 1)) .. ")" or ""
		end
	end

elseif string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then
	ObjectInteractionManager.AUTO_PICKUP_DELAY = 0.3 --Delay in seconds between auto-pickup procs (0 -> as fast as possible)
	local _update_targeted_original = ObjectInteractionManager._update_targeted
	function ObjectInteractionManager:_update_targeted(...)
		_update_targeted_original(self, ...)

		if alive(self._active_unit) and WolfHUD:getSetting("HOLD2PICK", "boolean") then
			local t = Application:time()
			if self._active_unit:base() and self._active_unit:base().small_loot and managers.menu:get_controller():get_input_bool("interact") and (t >= (self._next_auto_pickup_t or 0)) then
				self._next_auto_pickup_t = t + ObjectInteractionManager.AUTO_PICKUP_DELAY
				self:interact(managers.player:player_unit())
			end
		end
	end
end