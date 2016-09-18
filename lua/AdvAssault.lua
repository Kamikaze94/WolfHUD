if string.lower(RequiredScript) == "lib/managers/hud/hudassaultcorner" then
	local init_original = HUDAssaultCorner.init
	local _start_assault_original = HUDAssaultCorner._start_assault
	local sync_set_assault_mode_original = HUDAssaultCorner.sync_set_assault_mode
	local _set_hostage_offseted_original = HUDAssaultCorner._set_hostage_offseted
	 
	function HUDAssaultCorner:init(...)
		init_original(self, ...)
		
		self:update_vertical_pos()
	end
	
	function HUDAssaultCorner:update_vertical_pos()
		if not alive(self._hud_panel) then return end
		local width = self._hud_panel:w()
		local max_offset = width / 2 - 150
		local banner_scale = math.clamp(WolfHUD:getSetting("assault_banner_position", "number"), -1, 1)
		
		local assault_panel = self._hud_panel:child("assault_panel")
		if alive(assault_panel) then
			max_offset = width / 2 - assault_panel:w() / 2
			assault_panel:set_center_x(width / 2 + max_offset * banner_scale)
			local buffs_panel = self._hud_panel:child("buffs_panel")
			if alive(buffs_panel) then
				buffs_panel:set_right(assault_panel:x() + 20)
			end
		end
		
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		if alive(point_of_no_return_panel) then
			max_offset = width / 2 - point_of_no_return_panel:w() / 2
			point_of_no_return_panel:set_center_x(width / 2 + max_offset * banner_scale)
		end
		
		local casing_panel = self._hud_panel:child("casing_panel")
		if alive(casing_panel) then
			max_offset = width / 2 - casing_panel:w() / 2
			casing_panel:set_center_x(width / 2 + max_offset * banner_scale)
		end
		
		self:update_hudlist_offset()
	end
	
	function HUDAssaultCorner:update_hudlist_offset(banner_visible)
		banner_visible = banner_visible or banner_visible == nil and (self._assault or self._point_of_no_return or self._casing)
		local banner_scale = math.clamp(WolfHUD:getSetting("assault_banner_position", "number"), -1, 1)
		if managers.hud and math.abs(banner_scale) > 0.4 then
			local offset = banner_visible and ((self._bg_box and self._bg_box:h() or 30) + 12) or 0
			if banner_scale > 0 and HUDListManager then
				managers.hud:change_list_setting("right_list_height_offset", offset)
			elseif banner_scale < 0 then
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
	function HUDAssaultCorner:show_casing(...) end
	function HUDAssaultCorner:hide_casing(...) end
	
	function HUDAssaultCorner:_start_assault(text_list, ...)
		for i, string_id in ipairs(text_list) do
			if string_id == "hud_assault_assault" then
				text_list[i] = "hud_adv_assault"
			end
		end
		return _start_assault_original(self, text_list, ...)
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
	function HUDManager:_locked_assault(status)
		status = status or Network:is_server() and managers.groupai:state():get_hunt_mode() or false
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
	function HUDManager:_update_assault_setting(setting)
		if self._hud_assault_corner then
			if setting == "assault_banner_position" then
				self._hud_assault_corner:update_vertical_pos()
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
		if managers.hud and managers.hud:_locked_assault() then
			return self:text("wolfhud_locked_assault")
		elseif Network:is_server() then
			if not WolfHUD:getSetting("show_advanced_assault", "boolean") then
				return self:text("hud_assault_assault")
			else
				local phase = self:text("wolfhud_advassault_phase_title") .. "  " .. self:text("wolfhud_advassault_phase_" .. managers.groupai:state()._task_data.assault.phase)
				local spawns = managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
				local spawns_left = self:text("wolfhud_advassault_spawns_title") .. "  " .. math.round(math.max(spawns - managers.groupai:state()._task_data.assault.force_spawned, 0))
				local time_left = managers.groupai:state()._task_data.assault.phase_end_t + math.lerp(managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul) + tweak_data.group_ai.besiege.assault.fade_duration * 2
				if time_left < 0 then
					time_left = self:text("wolfhud_advassault_time_overdue")
				else
					time_left = self:text("wolfhud_advassault_time_title") .. "  " .. string.format("%.2f", time_left + 350 - managers.groupai:state()._t)
				end
				local sep = "          " .. self:text("hud_assault_end_line") .. "          "
				local text = phase .. sep .. spawns_left .. sep .. time_left
				return text
			end
		else
			return self:text("hud_assault_assault")
		end
	end
end

