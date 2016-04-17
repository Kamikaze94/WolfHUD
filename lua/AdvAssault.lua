if string.lower(RequiredScript) == "lib/managers/hud/hudassaultcorner" then
	local init_original = HUDAssaultCorner.init
	local _start_assault_original = HUDAssaultCorner._start_assault
	 
	function HUDAssaultCorner:init(...)
		init_original(self, ...)
				   
		local assault_panel = self._hud_panel:child("assault_panel")
		assault_panel:set_center_x(self._hud_panel:center_x())
		local buffs_panel = self._hud_panel:child("buffs_panel")
		buffs_panel:set_x(assault_panel:x() - buffs_panel:w() - 3)
				   
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		point_of_no_return_panel:set_center_x(self._hud_panel:center_x())
				   
		local casing_panel = self._hud_panel:child("casing_panel")
		casing_panel:set_center_x(self._hud_panel:center_x())
	end

	function HUDAssaultCorner:show_point_of_no_return_timer()
		local delay_time = self._assault and 1.2 or 0
		self:_end_assault()
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		point_of_no_return_panel:stop()
		point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
		self._point_of_no_return = true
	end

	function HUDAssaultCorner:hide_point_of_no_return_timer()
		self._noreturn_bg_box:stop()
		self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
		self._point_of_no_return = false
	end

	function HUDAssaultCorner:set_control_info(...) end
	function HUDAssaultCorner:show_casing(...) end
	function HUDAssaultCorner:hide_casing(...) end
	
	function HUDAssaultCorner:_start_assault(text_list, ...)
		if Network:is_server() then
			for i, string_id in ipairs(text_list) do
				if string_id == "hud_assault_assault" then
					text_list[i] = "hud_adv_assault"
				end
			end
		end
		return _start_assault_original(self, text_list, ...)
	end
	
	function HUDAssaultCorner:locked_assault(status)
		if self._assault_locked == status then return end
		local assault_panel = self._hud_panel:child("assault_panel")
		local icon_assaultbox = assault_panel and assault_panel:child("icon_assaultbox")
		local image
		self._assault_locked = status
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
		if self._hud_assault_corner then
			self._hud_assault_corner:locked_assault(status)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/localizationmanager" then
	local text_original = LocalizationManager.text

	-- This hack allows us to reroute every call for texts.
	function LocalizationManager:text(string_id, ...)
		if string_id == "hud_adv_assault" then
			-- enhanced assault banner
			return self:hud_adv_assault()
		else
			-- fallback to default
			return text_original(self, string_id, ...)
		end
	end

	function LocalizationManager:hud_adv_assault()
		if managers.groupai:state():get_hunt_mode() then
			managers.hud:_locked_assault(true)
			return self:text("hud_assault_assault")
		elseif not WolfHUD:getSetting("show_advanced_assault", "boolean") then
			return self:text("hud_assault_assault")
		else
			local phase = "Assault Phase: " .. managers.groupai:state()._task_data.assault.phase
			local spawns = managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
			local spawns_left = "Spawns Left: " .. math.round(math.max(spawns - managers.groupai:state()._task_data.assault.force_spawned, 0))
			local time_left = managers.groupai:state()._task_data.assault.phase_end_t + math.lerp(managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul) + tweak_data.group_ai.besiege.assault.fade_duration * 2
			if time_left < 0 then
				time_left = "OVERDUE"
			else
				time_left = "Time Left: " .. string.format("%.2f", time_left + 350 - managers.groupai:state()._t)
			end
			local sep = "          " .. self:text("hud_assault_end_line") .. "          "
			local text = phase .. sep .. spawns_left .. sep .. time_left
			return text
		end
	end
	
--[[	
	local text_original = LocalizationManager.text
	
	function LocalizationManager:getAdvAssault()
		log("AdvAssault data requested!")
		local groupai_state = managers.groupai:state()
		local assault_data = groupai_state and groupai_state._task_data.assault
		if not assault_data then
			log("ERROR: No Assault Data!")
			return text_original(self, "hud_assault_assault")--"ERROR: No Assault Data!"
		end
		log("Assaultdata available!")
		local phase 		= managers.groupai:state()._task_data.assault.phase
		local spawns_left 	= (managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)) - managers.groupai:state()._task_data.assault.force_spawned
		local time_left 	= managers.groupai:state()._task_data.assault.phase_end_t + math.lerp(managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), managers.groupai:state():_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul) + tweak_data.group_ai.besiege.assault.fade_duration * 2
		local text = "Phase: " .. phase .. " /// Spawns left: " .. math.max(spawns_left, 0) .. " /// " .. time_left > 0 and ("Time left: " .. time_left) or "OVERDUE"
		log("Assaultstring build!")
		log("AssaultData: " .. text)
		return text
	end
	
	function LocalizationManager:text(string_id, ...)
		if string_id == "hud_adv_assault" and WolfHUD:getSetting("show_advanced_assault", "boolean") and not managers.groupai:state():get_hunt_mode() then
			return self:getAdvAssault()
		end		
		return text_original(self, string_id, ...)
	end]]
end

