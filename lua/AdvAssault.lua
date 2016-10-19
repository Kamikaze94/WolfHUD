if string.lower(RequiredScript) == "lib/managers/hud/hudassaultcorner" then
	local init_original = HUDAssaultCorner.init
	local _start_assault_original = HUDAssaultCorner._start_assault
	local sync_set_assault_mode_original = HUDAssaultCorner.sync_set_assault_mode
	local _set_hostage_offseted_original = HUDAssaultCorner._set_hostage_offseted
	local set_buff_enabled_original = HUDAssaultCorner.set_buff_enabled
	local show_casing_original = HUDAssaultCorner.show_casing
	local hide_casing_original = HUDAssaultCorner.hide_casing
	local _animate_wave_started_original = HUDAssaultCorner._animate_wave_started
	local _animate_wave_completed_original = HUDAssaultCorner._animate_wave_completed
	 
	function HUDAssaultCorner:init(...)
		init_original(self, ...)
		
		-- Waves completed are visible in Objective and overlapping with HUDList.
		if self:is_safehouse_raid() then
			local wave_panel = self._hud_panel:child("wave_panel")
			if alive(wave_panel) then
				wave_panel:set_alpha(0)
			end
			local assault_panel = self._hud_panel:child("assault_panel")
			if alive(assault_panel) then
				self._wave_text = assault_panel:text({
					name = "num_waves",
					text = self:get_completed_waves_string(),
					valign = "center",
					vertical = "center",
					align = "center",
					halign = "right",
					w = self._bg_box and self._bg_box:w() or 100,
					h = tweak_data.hud.active_objective_title_font_size,
					layer = 1,
					x = 0,
					y = 0,
					color = Color.white,
					alpha = 0.8,
					font = "fonts/font_medium_shadow_mf",
					font_size = tweak_data.hud.active_objective_title_font_size * 0.9,
				})
				self._wave_text:set_top(self._bg_box and self._bg_box:bottom() or 40)
				self._wave_text:set_right(self._bg_box and self._bg_box:right() or 575)
			end
		end
		
		self:update_banner_pos()
	end
	
	function HUDAssaultCorner:update_banner_pos()
		if not alive(self._hud_panel) then return end
		local hud_w = self._hud_panel:w()
		local banner_pos = math.clamp(WolfHUD:getSetting("assault_banner_position", "number"), 1, 3)
		local assault_panel = self._hud_panel:child("assault_panel")
		local buffs_panel = self._hud_panel:child("buffs_panel")
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		local casing_panel = self._hud_panel:child("casing_panel")
		if alive(assault_panel) and alive(buffs_panel) and alive(point_of_no_return_panel) and alive(casing_panel) then
			if banner_pos < 2 then	--Quite messy, but all the panels in this class are far wider than they would need to be, giving "false information" on their w() function...
				buffs_panel:set_right(self._vip_bg_box:w())
				assault_panel:set_right((buffs_panel:visible() and buffs_panel:right() or 80) + self._bg_box:w() + 6 + assault_panel:child("icon_assaultbox"):w())
				point_of_no_return_panel:set_right(80 + self._bg_box:w() + 3 + point_of_no_return_panel:child("icon_noreturnbox"):w())
				casing_panel:set_right(80 + self._bg_box:w() + 3 + casing_panel:child("icon_casingbox"):w())
			elseif banner_pos == 2 then
				assault_panel:set_right(hud_w / 2 + (self._bg_box:w() + assault_panel:child("icon_assaultbox"):w()) / 2 + (buffs_panel:visible() and (self._vip_bg_box:w() + 3) / 2 or 0))
				buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - 3 - buffs_panel:w())
				point_of_no_return_panel:set_right(hud_w / 2 + (self._bg_box:w() + point_of_no_return_panel:child("icon_noreturnbox"):w()) / 2)
				casing_panel:set_right(hud_w / 2 + (self._bg_box:w() + casing_panel:child("icon_casingbox"):w()) / 2)
			else
				assault_panel:set_right(hud_w)
				buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - 3 - buffs_panel:w())
				point_of_no_return_panel:set_right(hud_w)
				casing_panel:set_right(hud_w)
			end
		end
		
		self:update_hudlist_offset()
	end
	
	function HUDAssaultCorner:set_buff_enabled(...)
		self:update_banner_pos()
		return set_buff_enabled_original(self, ...)
	end
	
	function HUDAssaultCorner:update_hudlist_offset(banner_visible)
		banner_visible = banner_visible or banner_visible == nil and (self._assault or self._point_of_no_return or self._casing)
		local banner_pos = math.clamp(WolfHUD:getSetting("assault_banner_position", "number"), 1, 3)
		if managers.hud and banner_pos ~= 2 then
			local offset = banner_visible and ((self._bg_box and self._bg_box:bottom() or 0) + (self:is_safehouse_raid() and self._wave_text:h() or 0)+ 12) or 0
			if banner_pos > 2 and HUDListManager then
				managers.hud:change_list_setting("right_list_height_offset", offset)
			elseif banner_pos < 2 then
				if managers.hud._hud_objectives and managers.hud._hud_objectives.apply_offset then
					managers.hud._hud_objectives:apply_offset(offset)
				end
			end
		end
	end
	
	function HUDAssaultCorner:_set_hostage_offseted(is_offseted, ...)
		_set_hostage_offseted_original(self, is_offseted, ...)
		self:update_hudlist_offset(is_offseted)
	end

	function HUDAssaultCorner:show_point_of_no_return_timer()
		local delay_time = self._assault and 1.2 or 0
		self:_end_assault()
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		point_of_no_return_panel:stop()
		point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
		self._point_of_no_return = true
		self:update_hudlist_offset(true)
	end

	function HUDAssaultCorner:hide_point_of_no_return_timer()
		self._noreturn_bg_box:stop()
		self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
		self._point_of_no_return = false
		self:update_hudlist_offset(false)
	end

	function HUDAssaultCorner:set_control_info(...) end
	function HUDAssaultCorner:show_casing(...) 
--		show_casing_original(self, ...)
--		self:update_hudlist_offset(true)
	end
	function HUDAssaultCorner:hide_casing(...) 
--		hide_casing_original(self, ...)
--		self:update_hudlist_offset(false)
	end
	
	function HUDAssaultCorner:_start_assault(text_list, ...)
		for i, string_id in ipairs(text_list) do
			if string_id == "hud_assault_assault" then
				text_list[i] = "hud_adv_assault"
			end
		end
		return _start_assault_original(self, text_list, ...)
	end
	
	function HUDAssaultCorner:_animate_wave_started(...)
		self._wave_text:set_text(self:get_completed_waves_string())
		
		return _animate_wave_started_original(self, ...)
	end
	function HUDAssaultCorner:_animate_wave_completed(...)
		self._wave_text:set_text(self:get_completed_waves_string())
		
		return _animate_wave_completed_original(self, ...)
	end
	
	function HUDAssaultCorner:locked_assault(status)
		local assault_panel = self._hud_panel:child("assault_panel")
		local icon_assaultbox = assault_panel and assault_panel:child("icon_assaultbox")
		local image
		if status then
			image = "guis/textures/pd2/hud_icon_padlockbox"
		else
			image = "guis/textures/pd2/hud_icon_assaultbox"
		end
		if icon_assaultbox and image then
			icon_assaultbox:set_image(image)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local _change_vanillahud_setting_original = HUDManager._change_vanillahud_setting or function(...) end
	function HUDManager:_locked_assault(status)
		status = Network:is_server() and (managers.groupai:state():get_hunt_mode() or false) or status
		self._assault_locked = self._assault_locked or false
		if self._assault_locked ~= status then
			if self._hud_assault_corner then
				self._hud_assault_corner:locked_assault(status)
			end
			if Network:is_server() and WolfHUD.Sync then
				local data = { event = "assault_lock_state", data = status}
				WolfHUD.Sync.send("WolfHUD_Sync", data)
			end
			self._assault_locked = status
		end
		return self._assault_locked
	end
	function HUDManager:_change_vanillahud_setting(setting)
		if self._hud_assault_corner then
			if setting == "assault_banner_position" then
				self._hud_assault_corner:update_banner_pos()
			else
				_change_vanillahud_setting_original(self, setting)
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/localizationmanager" then
	local text_original = LocalizationManager.text

	function LocalizationManager:text(string_id, ...)
		if string_id == "hud_adv_assault" then
			return self:hud_adv_assault()
		end
		return text_original(self, string_id, ...)
	end

	function LocalizationManager:hud_adv_assault()
		if WolfHUD:getSetting("show_advanced_assault", "boolean") then
			if managers.hud and managers.hud:_locked_assault() then
				return self:text("wolfhud_locked_assault")
			else
				local assault_task_data = Network:is_server() and managers.groupai:state()._task_data.assault or WolfHUD.Sync and WolfHUD.Sync:getCache("assault_task_data")
				if assault_task_data then
					if WolfHUD.Sync and Network:is_server() then
						WolfHUD.Sync:send("WolfHUD_Sync_Cache", { event = "assault_task_data", data = { phase = assault_task_data.phase, force_spawned = assault_task_data.force_spawned, phase_end_t = assault_task_data.phase_end_t } })
					end
					
					local phase = self:text("wolfhud_advassault_phase_title") .. "  " .. self:text("wolfhud_advassault_phase_" .. assault_task_data.phase)
					local spawns = managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
					local spawns_left = self:text("wolfhud_advassault_spawns_title") .. "  " .. math.round(math.max(spawns - assault_task_data.force_spawned, 0))
					local time_left = assault_task_data.phase_end_t + math.lerp(managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul) + tweak_data.group_ai.besiege.assault.fade_duration * 2
					if time_left < 0 then
						time_left = self:text("wolfhud_advassault_time_overdue")
					else
						time_left = self:text("wolfhud_advassault_time_title") .. "  " .. string.format("%.2f", time_left + 350 - managers.groupai:state()._t)
					end
					local sep = "          " .. self:text("hud_assault_end_line") .. "          "
					local text = phase .. sep .. spawns_left .. sep .. time_left
					return text
				end
			end
		end
		return self:text("hud_assault_assault")
	end
end
