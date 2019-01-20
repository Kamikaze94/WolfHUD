--TODO: Add bots? Add player support for standalone version?

if string.lower(RequiredScript) == "lib/units/beings/player/huskplayermovement" then

	local _perform_movement_action_enter_bleedout_original = HuskPlayerMovement._perform_movement_action_enter_bleedout

	function HuskPlayerMovement:_perform_movement_action_enter_bleedout(...)
		if not self._bleedout then
            local crim_data = managers.criminals:character_data_by_unit(self._unit)
            if crim_data and crim_data.panel_id then
                managers.hud:increment_teammate_downs(crim_data.panel_id)
            end
        end

		return _perform_movement_action_enter_bleedout_original(self, ...)
	end
elseif string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then

	local sync_doctor_bag_taken_original = UnitNetworkHandler.sync_doctor_bag_taken

	function UnitNetworkHandler:sync_doctor_bag_taken(unit, amount, sender, ...)
		local peer = self._verify_sender(sender)
		if peer then
			local crim_data = managers.criminals:character_data_by_peer_id(peer:id())
			if crim_data and crim_data.panel_id then
				managers.hud:reset_teammate_downs(crim_data.panel_id)
			end
		end

		return sync_doctor_bag_taken_original(self, unit, amount, sender, ...)
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

	HUDManager.DOWNS_COUNTER_PLUGIN = true

	local set_player_health_original = HUDManager.set_player_health
	local set_mugshot_custody_original = HUDManager.set_mugshot_custody

	function HUDManager:set_player_health(data, ...)
		if data.revives then
			self:set_player_revives(HUDManager.PLAYER_PANEL, data.revives - 1)
		end
		return set_player_health_original(self, data, ...)
	end

	function HUDManager:set_mugshot_custody(id, ...)
		local data = self:_get_mugshot_data(id)
		if data then
			local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id
			managers.hud:reset_teammate_downs(i)
		end

		return set_mugshot_custody_original(self, id, ...)
	end

	HUDManager.set_player_revives = HUDManager.set_player_revives or function(self, i, value)
		self._teammate_panels[i]:set_revives(value)
	end

	HUDManager.increment_teammate_downs = HUDManager.increment_teammate_downs or function(self, i)
		self._teammate_panels[i]:increment_downs()
	end

	HUDManager.reset_teammate_downs = HUDManager.reset_teammate_downs or function(self, i)
		self._teammate_panels[i]:reset_downs()
	end

elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" and not HUDManager.CUSTOM_TEAMMATE_PANELS then

	Hooks:PostHook( HUDTeammate, "init", "WolfHUD_DownCounter_HUDTeammate_init", function(self, ...)
		self._health_panel = self._health_panel or self._player_panel:child("radial_health_panel")
		self._condition_icon = self._condition_icon or self._panel:child("condition_icon")

		self._max_downs = (Global.game_settings.one_down and 2 or tweak_data.player.damage.LIVES_INIT) - 1
		if managers.modifiers and managers.modifiers.modify_value then
			self._max_downs = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._max_downs)
		end
		self._max_downs = self._max_downs + (self._main_player and managers.player:upgrade_value("player", "additional_lives", 0) or 0)
		self._downs = self._main_player and self._max_downs or 0

		self._setting_prefix = self._main_player and "PLAYER" or "TEAMMATE"

		self._health_panel:bitmap({
			name = "risk_indicator_bg",
			texture = "guis/textures/pd2/crimenet_marker_glow",
			texture_rect = { 0, 0, 64, 64 },
			blend_mode = "normal",
			color = Color.black,
			alpha = 0.6,
			w = self._health_panel:w(),
			h = self._health_panel:h(),
			layer = 1,
		})

		self._downs_counter = self._health_panel:text({
			name = "downs",
			text = tostring(self._downs),
			color = Color.white,
			align = "center",
			vertical = "center",
			w = self._health_panel:w(),
			h = self._health_panel:h(),
			font_size = self._main_player and 15 or 12,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			visible = HUDManager.DOWNS_COUNTER_PLUGIN and WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true) and not self._ai or false,
		})

		self._detection_counter = self._health_panel:text({
			name = "detection",
			text = utf8.char(57363),
			color = Color.red,
			align = "center",
			vertical = "center",
			w = self._health_panel:w(),
			h = self._health_panel:h(),
			font_size = self._main_player and 15 or 12,
			font = tweak_data.menu.pd2_medium_font,
			layer = 2,
			visible = HUDManager.DOWNS_COUNTER_PLUGIN and WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true) and not self._ai or false,
		})

		self:set_detection()

		if managers.gameinfo then
			managers.gameinfo:register_listener("HealthRadial_whisper_mode_listener" .. tostring(self._id), "whisper_mode", "change", callback(self, self, "_whisper_mode_change"), nil, true)
		end
	end)

	Hooks:PostHook( HUDTeammate, "remove_panel", "WolfHUD_DownCounter_HUDTeammate_remove_panel", function(self, ...)
		managers.gameinfo:unregister_listener("HealthRadial_whisper_mode_listener" .. tostring(self._id), "whisper_mode", "change")
	end)

	Hooks:PostHook( HUDTeammate, "set_peer_id", "WolfHUD_DownCounter_HUDTeammate_set_peer_id", function(self, ...)
		self:set_detection()
	end)

	Hooks:PostHook( HUDTeammate, "set_callsign", "WolfHUD_DownCounter_HUDTeammate_set_callsign", function(self, ...)
		if self._main_player then
			self:set_detection()
		end
	end)

	Hooks:PreHook( HUDTeammate, "set_name", "WolfHUD_DownCounter_HUDTeammate_set_name", function(self, teammate_name, ...)
		if teammate_name ~= self._name then
			self._name = teammate_name
			self:reset_downs()
		end
	end)

	function HUDTeammate:_whisper_mode_change(status)
		local disabled = self._condition_icon and self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true)) or self._ai
		self._downs_counter:set_visible(not disabled and (not status or self:down_amount() > 0))
		self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
	end

	HUDTeammate.set_downs = HUDTeammate.set_downs or function(self, amount)
		if amount and self._downs ~= amount then
			self._downs = amount
			self._downs_counter:set_text(tostring(self._downs))
			local progress = math.clamp(self:down_amount() / self._max_downs, 0, 1)
			self._downs_counter:set_color(math.lerp(Color.white, Color(1, 1, 0.2, 0), progress))
			local disabled = self._condition_icon and self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true)) or self._ai
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
	end

	HUDTeammate.set_revives = HUDTeammate.set_revives or function(self, value)
		self:set_downs(value)
	end

	HUDTeammate.increment_downs = HUDTeammate.increment_downs or function(self)
		self:set_downs(self._downs + 1)
	end

	HUDTeammate.reset_downs = HUDTeammate.reset_downs or function(self)
		self:set_downs((self._main_player and self._max_downs) or 0)
	end

	HUDTeammate.down_amount = HUDTeammate.down_amount or function(self)
		return self._main_player and self._max_downs - self._downs or self._downs
	end

	HUDTeammate.set_detection = HUDTeammate.set_detection or function(self, risk)
        if not risk then
            if self._main_player then
				risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100))
			elseif self:peer_id() then
				risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_peer(managers.network:session():peer(self:peer_id()), tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100))
			end
        end
		if not self._risk or risk and risk ~= self._risk then
            self._risk = risk
			if self._risk then
				local color = self._risk < 50 and Color(1, 0, 0.8, 1) or Color(1, 1, 0.2, 0)
				self._detection_counter:set_text(utf8.char(57363) .. tostring(self._risk))
				self._detection_counter:set_color(color)
			end
			local disabled = self._condition_icon and self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "DOWNCOUNTER"}, true)) or self._ai
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
	end
end
