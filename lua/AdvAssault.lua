if string.lower(RequiredScript) == "lib/managers/hud/hudassaultcorner" then
	local init_original = HUDAssaultCorner.init
	local _start_assault_original = HUDAssaultCorner._start_assault
	local _set_hostage_offseted_original = HUDAssaultCorner._set_hostage_offseted
	local set_buff_enabled_original = HUDAssaultCorner.set_buff_enabled
	local show_point_of_no_return_timer_original = HUDAssaultCorner.show_point_of_no_return_timer
	local hide_point_of_no_return_timer_original = HUDAssaultCorner.hide_point_of_no_return_timer
	local show_casing_original = HUDAssaultCorner.show_casing
	local hide_casing_original = HUDAssaultCorner.hide_casing
	local set_assault_wave_number_original = HUDAssaultCorner.set_assault_wave_number
	local _animate_wave_started_original = HUDAssaultCorner._animate_wave_started
	local _animate_wave_completed_original = HUDAssaultCorner._animate_wave_completed

	function HUDAssaultCorner:init(...)
		init_original(self, ...)

		-- Waves completed are visible in Objective and overlapping with HUDList.
		if self:should_display_waves() then
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
		local banner_pos = math.clamp(WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 2), 1, 3)
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
				assault_panel:set_right(hud_w / 2 + self._bg_box:w() / 2 + assault_panel:child("icon_assaultbox"):w() + 3)
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
		local banner_pos = math.clamp(WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 2), 1, 3)
		if managers.hud and banner_pos ~= 2 then
			local offset = banner_visible and ((self._bg_box and self._bg_box:bottom() or 0) + (self:should_display_waves() and self._wave_text:h() or 0)+ 12) or 0
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

	function HUDAssaultCorner:show_point_of_no_return_timer(...)
		show_point_of_no_return_timer_original(self, ...)
		self:update_hudlist_offset(true)
	end

	function HUDAssaultCorner:hide_point_of_no_return_timer(...)
		hide_point_of_no_return_timer_original(self, ...)
		self:update_hudlist_offset(false)
	end

	function HUDAssaultCorner:show_casing(...)
		--show_casing_original(self, ...)
		--self:update_hudlist_offset(true)
	end
	function HUDAssaultCorner:hide_casing(...)
		--hide_casing_original(self, ...)
		--self:update_hudlist_offset(false)
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

	function HUDAssaultCorner:set_assault_wave_number(...)
		if alive(self._wave_text) then
			self._wave_text:set_text(self:get_completed_waves_string())
			self._wave_text:animate(callback(self, self, "_animate_wave_text"))
		end

		return set_assault_wave_number_original(self, ...)
	end

	function HUDAssaultCorner:_animate_wave_text(object)
		local TOTAL_T = 2
		local t = TOTAL_T
		object:set_alpha(0.8)
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			object:set_alpha(0.5 + 0.5 * (0.5 * math.sin(t * 360 * 2) + 0.5))
		end
		object:set_alpha(0.8)
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
	local sync_start_assault_original = HUDManager.sync_start_assault
	local sync_end_assault_original = HUDManager.sync_end_assault
	local _create_downed_hud_original = HUDManager._create_downed_hud
	local _create_custody_hud_original = HUDManager._create_custody_hud

	function HUDManager:_locked_assault(status)
		if Network:is_server() then
			status = managers.groupai:state():get_hunt_mode() or false
		end
		if self._assault_locked ~= status then
			if self._hud_assault_corner then
				self._hud_assault_corner:locked_assault(status)
			end
			self._assault_locked = status
			if Network:is_server() and WolfHUD.Sync then
				WolfHUD.Sync:endless_assault_status(self._assault_locked)
			end
		end
	end

	function HUDManager:is_assault_locked()
		return self._assault_locked or false
	end

	function HUDManager:change_assaultbanner_setting(setting, value)
		if self._hud_assault_corner then
			if setting == "POSITION" then
				self._hud_assault_corner:update_banner_pos()
			end
		end
	end

	function HUDManager:sync_start_assault(...)
		sync_start_assault_original(self, ...)

		if Network:is_server() then
			self:_locked_assault()
		end
	end

	function HUDManager:sync_end_assault(...)
		sync_end_assault_original(self, ...)

		if Network:is_server() then
			self:_locked_assault()
		end
	end

	function HUDManager:_create_downed_hud(...)
		_create_downed_hud_original(self, ...)
		local banner_pos = math.clamp(WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 2), 1, 3)
		if banner_pos == 2 and self._hud_player_downed then
			local downed_panel = self._hud_player_downed._hud_panel
			local downed_hud = self._hud_player_downed._hud
			local timer_msg = downed_panel and downed_panel:child("downed_panel"):child("timer_msg")
			local timer = downed_hud and downed_hud.timer
			if timer_msg and timer then
				timer_msg:set_y(65)
				timer:set_y(math.round(timer_msg:bottom() - 6))
			end
		end
	end

	function HUDManager:_create_custody_hud(...)
		_create_custody_hud_original(self, ...)
		local banner_pos = math.clamp(WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 2), 1, 3)
		if banner_pos == 2 and self._hud_player_custody then
			local custody_panel = self._hud_player_custody._hud_panel
			local timer_msg = custody_panel and custody_panel:child("custody_panel") and custody_panel:child("custody_panel"):child("timer_msg")
			local timer = self._hud_player_custody._timer
			if timer_msg and timer then
				timer_msg:set_y(65)
				timer:set_y(math.round(timer_msg:bottom() - 6))
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
		if WolfHUD:getSetting({"AssaultBanner", "USE_ADV_ASSAULT"}, true) then
			if managers.hud and managers.hud:is_assault_locked() then
				return self:text("wolfhud_locked_assault")
			else
				local tweak = tweak_data.group_ai.besiege.assault
				local gai_state = managers.groupai:state()
				local assault_data = Network:is_server() and gai_state and gai_state._task_data.assault
				if tweak and gai_state and assault_data and assault_data.active then
					local get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
					local get_mult = gai_state._get_balancing_multiplier or function() return 0 end
					local phase = self:text("wolfhud_advassault_phase_title") .. "  " .. self:text("wolfhud_advassault_phase_" .. assault_data.phase)

					local spawns = get_value(gai_state, tweak.force_pool) * get_mult(gai_state, tweak.force_pool_balance_mul)
					local spawns_left = self:text("wolfhud_advassault_spawns_title") .. "  " .. math.round(math.max(spawns - assault_data.force_spawned, 0))

					local time_left = assault_data.phase_end_t - gai_state._t + 350
					if assault_data.phase == "build" then
						local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
						time_left = time_left + sustain_duration + tweak.fade_duration
					elseif assault_data.phase == "sustain" then
						time_left = time_left + tweak.fade_duration
					end
					--if gai_state:_count_police_force("assault") > 7 then -- 350 = additional duration, if more than 7 assault groups are active (hardcoded values in gai_state).
					--	time_left = time_left + 350
					--end
					if time_left < 0 then
						time_left = self:text("wolfhud_advassault_time_overdue")
					else
						time_left = self:text("wolfhud_advassault_time_title") .. "  " .. string.format("%.2f", time_left)
					end

					local spacer = string.rep(" ", 10)
					local sep = string.format("%s%s%s", spacer, self:text("hud_assault_end_line"), spacer)
					return string.format("%s%s%s%s%s", phase, sep, spawns_left, sep, time_left)
				end
			end
		end
		return self:text("hud_assault_assault")
	end
end
