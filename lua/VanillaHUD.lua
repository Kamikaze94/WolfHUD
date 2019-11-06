
if WolfHUD:getSetting({"CustomHUD", "ENABLED"}, true) then
	return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	local set_stamina_value_original = HUDManager.set_stamina_value
	local set_max_stamina_original = HUDManager.set_max_stamina
	local teammate_progress_original = HUDManager.teammate_progress

	function HUDManager:set_stamina_value(value, ...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_current_stamina(value)
		return set_stamina_value_original(self, value, ...)
	end

	function HUDManager:set_max_stamina(value, ...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_max_stamina(value)
		return set_max_stamina_original(self, value, ...)
	end

	function HUDManager:teammate_progress(peer_id, type_index, enabled, tweak_data_id, timer, success, ...)
		teammate_progress_original(self, peer_id, type_index, enabled, tweak_data_id, timer, success, ...)
		local character_data = managers.criminals:character_data_by_peer_id(peer_id)
		if character_data then
			local teammate_panel = self._teammate_panels[character_data.panel_id]
			local name_label = self:_name_label_by_peer_id(peer_id)
			if name_label then
				teammate_panel:set_interact_text(name_label.panel:child("action"):text())
			end
			teammate_panel:set_interact_visibility(enabled and timer and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "MIN_DURATION"}, 1) <= timer and not WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "HIDE"}, false) and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "TEXT"}, true))
		end
	end

elseif RequiredScript == "lib/managers/hud/hudteammate" then

	local init_original = HUDTeammate.init
	local set_name_original = HUDTeammate.set_name
	local set_condition_original = HUDTeammate.set_condition
	local teammate_progress_original = HUDTeammate.teammate_progress
	local update_original = HUDManager.update

	function HUDTeammate:init(...)
		init_original(self, ...)

		self._setting_prefix = self._main_player and "PLAYER" or "TEAMMATE"
		self._max_name_panel_width = self._panel:w()

		self._condition_icon = self._panel:child("condition_icon")
		self._condition_icon:set_color(WolfHUD:getColorSetting({"CustomHUD", self._setting_prefix, "CONDITION_ICON_COLOR"}, "white"))

		self._next_latency_update_t = 0

		if self._main_player and not HUDManager.CUSTOM_TEAMMATE_PANELS then
			self:_create_stamina_circle()
		else
			self:_init_interact_info()
		end

		if WolfHUD:getSetting({"CustomHUD","TEAMMATE","LATENCY"}, true) then
			self:_create_ping_info()
		end
	end

	function HUDTeammate:set_name(name, ...)
		if not self._ai then
			if WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "TRUNCATE_TAGS"}, true) then
				name = WolfHUD:truncateNameTag(name)
			end
			if WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "RANK"}, true) then
				local peer = self:peer_id() and managers.network:session():peer(self:peer_id())
				local infamy, level = peer and peer:rank() or managers.experience:current_rank(), peer and peer:level() or managers.experience:current_level()
				local level_str = string.format("%s%s ",
					(infamy or 0) > 0 and string.format("%s-", managers.experience:rank_string(infamy)) or "",
					tostring(level)
				)
				name = level_str .. name
				self._color_pos = level_str:len()
			end
		end
		set_name_original(self, name,...)
		self:_truncate_name()
	end

	function HUDTeammate:_truncate_name()
		local name_panel = self._panel:child("name")
		local name_bg_panel = self._panel:child("name_bg")
		local teammate_name = name_panel:text()
		name_panel:set_vertical("center")
		name_panel:set_font_size(tweak_data.hud_players.name_size)
		name_panel:set_w(self._panel:w() - name_panel:x())
		local _,_,w,h = name_panel:text_rect()
		while (name_panel:x() + w) > self._max_name_panel_width do
			if name_panel:font_size() > 15.1 then
				name_panel:set_font_size(name_panel:font_size() - 0.1)
			else
				name_panel:set_text(teammate_name:sub(1, teammate_name:len() - 1))
			end
			teammate_name = name_panel:text()
			_,_,w,h = name_panel:text_rect()
		end
		if not self._ai then
			name_panel:set_range_color((self._color_pos or 0) + 1, name_panel:text():len() + 1, self._panel:child("callsign"):color():with_alpha(1))
		else
			name_panel:set_color(WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "USE"}, false) and WolfHUD:getColorSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "COLOR"}, "white") or tweak_data.chat_colors[5])
		end
		name_bg_panel:set_w(w + 4)
		name_bg_panel:set_h(h + 2)
		name_bg_panel:set_y(name_panel:y() + name_panel:h() / 2 - h / 2 - 1)
	end

	function HUDTeammate:update(t,dt)
		self:update_latency(t,dt)
	end

	function HUDTeammate:update_latency(t,dt)
		local ping_panel = self._panel:child("latency")
		if ping_panel and self:peer_id() and t > self._next_latency_update_t then
			local net_session = managers.network:session()
			local peer = net_session and net_session:peer(self:peer_id())
			local latency = peer and Network:qos(peer:rpc()).ping or "n/a"

			if type(latency) == "number" then
				ping_panel:set_text(string.format("%.0fms", latency))
				ping_panel:set_color(latency < 75 and Color('C2FC97') or latency < 150 and Color('CEA168') or Color('E24E4E'))
			else
				ping_panel:set_text(latency)
				ping_panel:set_color(Color('E24E4E'))
			end

			self._next_latency_update_t = t + 1
		elseif not self:peer_id() and ping_panel then
			ping_panel:set_text("")
		end
	end

	function HUDManager:update(...)
		for i, panel in ipairs(self._teammate_panels) do
			panel:update(...)
		end

		return update_original(self, ...)
	end

	function HUDTeammate:_create_ping_info()
		local name_panel = self._panel:child("name")
		local ping_info = self._panel:text({
			name = "latency",
			vertical = "right",
			font_size = tweak_data.hud.small_font_size,
			align = "right",
			halign = "right",
			text = "",
			font = "fonts/font_small_mf",
			layer = 1,
			visible = true,
			color = Color.white,
			x = -12,
			y = name_panel:y() - tweak_data.hud.small_font_size,
			h = 50
		})
	end

	function HUDTeammate:_create_stamina_circle()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		self._stamina_bar = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/textures/pd2/hud_radial_rim",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			alpha = 1,
			w = radial_health_panel:w() * 0.37,--53,
			h = radial_health_panel:h() * 0.37,--53,
			layer = 2,
			visible = WolfHUD:getSetting({"CustomHUD", "PLAYER", "STAMINA"}, true)
		})
		self._stamina_bar:set_color(Color(1, 1, 0, 0))
		self._stamina_bar:set_center(radial_health_panel:child("radial_health"):center())

		self._stamina_line = radial_health_panel:rect({
			color = Color.red:with_alpha(0.4),
			w = radial_health_panel:w() * 0.05,
			h = 2,
			layer = 10,
			visible = WolfHUD:getSetting({"CustomHUD", "PLAYER", "STAMINA"}, true)
		})
		self._stamina_line:set_center(radial_health_panel:child("radial_health"):center())
	end

	function HUDTeammate:set_max_stamina(value)
		if not self._max_stamina or self._max_stamina ~= value then
			self._max_stamina = value
			local w = self._stamina_bar:w()
			local threshold = tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
			local angle = 360 * (threshold/self._max_stamina) - 90
			local x = 0.48 * w * math.cos(angle) + w * 0.5 + self._stamina_bar:x()
			local y = 0.48 * w * math.sin(angle) + w * 0.5 + self._stamina_bar:y()
			self._stamina_line:set_x(x)
			self._stamina_line:set_y(y)
			self._stamina_line:set_rotation(angle)
		end
	end

	function HUDTeammate:set_current_stamina(value)
		self._stamina_bar:set_color(Color(1, value/self._max_stamina, 0, 0))
		self:set_stamina_meter_visibility(WolfHUD:getSetting({"CustomHUD", "PLAYER", "STAMINA"}, true) and not self._condition_icon:visible())
	end

	function HUDTeammate:set_stamina_meter_visibility(value)
		if self._stamina_bar and self._stamina_bar:visible() ~= value then
			self._stamina_bar:set_visible(value)
			self._stamina_line:set_visible(value)
		end
	end

	function HUDTeammate:_init_interact_info()
		self._interact_info_panel = self._panel:panel({
			name = "interact_info_panel",
			x = 0,
			y = 0,
			visible = false
		})
		self._interact_info = self._interact_info_panel:text({
			name = "interact_info",
			text = "|",
			layer = 3,
			color = Color.white,
			x = 0,
			y = 1,
			align = "right",
			vertical = "top",
			font_size = tweak_data.hud_players.name_size,
			font = tweak_data.hud_players.name_font
		})
		local _, _, text_w, text_h = self._interact_info:text_rect()
		self._interact_info:set_right(self._interact_info_panel:w() - 4)
		self._interact_info_bg = self._interact_info_panel:bitmap({
			name = "interact_info_bg",
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {
				84,
				0,
				44,
				32
			},
			layer = 2,
			color = Color.white / 3,
			x = 0,
			y = 0,
			align = "left",
			vertical = "bottom",
			w = text_w + 4,
			h = text_h
		})
	end

	function HUDTeammate:set_interact_text(text)
		if alive(self._interact_info) then
			self._interact_info:set_text(text)
			local _, _, w, _ = self._interact_info:text_rect()
			self._interact_info_bg:set_w(w + 8)
			self._interact_info_bg:set_right(self._interact_info:right() + 4)
		end
	end

	function HUDTeammate:set_interact_visibility(visible)
		if self._interact_info_panel then
			self._interact_info_panel:set_visible(visible)
		end
	end

	function HUDTeammate:teammate_progress(enabled, tweak_data_id, timer, success, ...)
		local show = timer and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "MIN_DURATION"}, 1) <= timer and not WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "HIDE"}, false)
		teammate_progress_original(self, enabled and show, tweak_data_id, timer, success and show, ...)
		if enabled and show and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "NUMBER"}, true) then
			self:_start_interact_timer(timer)
		else
			self:_stop_interact_timer()
		end
	end

	function HUDTeammate:_start_interact_timer(interaction_time)
		local condition_timer = self._panel:child("condition_timer")
		condition_timer:stop()
		condition_timer:animate(callback(self, self, "_animate_interact_timer"), interaction_time)
	end

	function HUDTeammate:_animate_interact_timer(condition_timer, total_time)
		condition_timer:set_font_size(tweak_data.hud_players.timer_size)
		condition_timer:set_color(Color.white)
		condition_timer:set_visible(true)

		local t = total_time
		while t >= 0 do
			t = t - coroutine.yield()
			condition_timer:set_text(string.format("%.1fs", t))
			condition_timer:set_color(math.lerp(Color('00FF00'), Color.white, t / total_time))
		end
		condition_timer:set_text(string.format("%.1fs", 0))
		condition_timer:set_color(Color('00FF00'))
	end

	function HUDTeammate:_stop_interact_timer()
		if alive(self._panel) then
			local condition_timer = self._panel:child("condition_timer")
			condition_timer:stop()
			condition_timer:set_visible(false)
		end
	end

	function HUDTeammate:set_condition(icon_data, ...)
		local visible = icon_data ~= "mugshot_normal"
		self:set_stamina_meter_visibility(not visible and WolfHUD:getSetting({"CustomHUD", "PLAYER", "STAMINA"}, true))
		if HUDManager.DOWNS_COUNTER_PLUGIN and self._downs_counter and self._detection_counter then
			local disabled = visible or not WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true) or self._ai
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
		set_condition_original(self, icon_data, ...)
	end

end
