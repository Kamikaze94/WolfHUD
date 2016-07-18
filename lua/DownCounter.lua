--TODO: Add bots? Add player support for standalone version?

if string.lower(RequiredScript) == "lib/units/beings/player/huskplayermovement" then

	local _start_bleedout_original = HuskPlayerMovement._start_bleedout
	local _start_dead_original = HuskPlayerMovement._start_dead

	function HuskPlayerMovement:_start_bleedout(...)
		local crim_data = managers.criminals:character_data_by_unit(self._unit)
		if crim_data and crim_data.panel_id then
			managers.hud:increment_teammate_downs(crim_data.panel_id)
		end
	
		return _start_bleedout_original(self, ...)
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
		self._teammate_panels[i]:set_downs(value)
	end
	
	HUDManager.increment_teammate_downs = HUDManager.increment_teammate_downs or function(self, i)
		self._teammate_panels[i]:increment_downs()
	end
	
	HUDManager.reset_teammate_downs = HUDManager.reset_teammate_downs or function(self, i)
		self._teammate_panels[i]:reset_downs()
	end
	
elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" and not HUDManager.CUSTOM_TEAMMATE_PANELS then
	
	Hooks:PostHook( HUDTeammate, "init", "WolfHUD_DownCounter_HUDTeammate_init", function(self, i, teammates_panel, is_player, ...)
		if not HUDManager.CUSTOM_TEAMMATE_PANELS then	-- For CustomHUD Compatability...
			self._health_panel = self._player_panel:child("radial_health_panel")
			
			local risk_indicator_bg = self._health_panel:bitmap({
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
			
			local risk_indicator = self._health_panel:text({
				name = "risk_indicator",
				text = "?",
				color = Color(1, 1, 0, 0),
				blend_mode = "normal",
				layer = 2,
				w = self._health_panel:w(),
				h = self._health_panel:h(),
				vertical = "center",
				align = "center",
				font_size = 15,
				font = tweak_data.menu.pd2_medium_font
			})
			
			self._max_downs = tweak_data.player.damage.LIVES_INIT - 1 + (is_player and managers.player:upgrade_value("player", "additional_lives", 0) or 0)
			self._downs = 0
			
			if managers.gameinfo then
				managers.gameinfo:register_listener("HealthRadial_whisper_mode_listener" .. tostring(self._id), "whisper_mode", "change", callback(self, self, "_whisper_mode_change"))
			end
		end
	end)
	
	Hooks:PostHook( HUDTeammate, "remove_panel", "WolfHUD_DownCounter_HUDTeammate_remove_panel", function(self, ...)
		if not HUDManager.CUSTOM_TEAMMATE_PANELS then	-- For CustomHUD Compatability...
			managers.gameinfo:unregister_listener("HealthRadial_whisper_mode_listener" .. tostring(self._id), "whisper_mode", "change")
		end
	end)
	
	if not HUDManager.CUSTOM_TEAMMATE_PANELS then
		function HUDTeammate:_whisper_mode_change(event, key, status)
			self:set_downs()
		end
	end
	
	HUDTeammate.set_downs = HUDTeammate.set_downs or function(self, i)
		if not self._health_panel then return end
		if not i or self._downs ~= i then
			self._downs = i or self._downs
			self._health_panel:child("risk_indicator_bg"):set_visible(WolfHUD:getSetting("show_downcounter", "boolean"))
			local alpha = WolfHUD:getSetting("show_downcounter", "boolean") and 1 or 0
			if managers.groupai:state():whisper_mode() and self._downs == self._max_downs then
				if not self._risk then
					self._risk = 99
					if self._id == HUDManager.PLAYER_PANEL then
						self._health_panel:child("risk_indicator"):set_font_size(15)
						self._risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_local(75)))
					elseif self:peer_id() ~= nil then
						self._health_panel:child("risk_indicator"):set_font_size(12)
						self._risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_peer(managers.network:session():peer(self:peer_id()), 75)))
					end
					self._health_panel:child("risk_indicator"):set_text(utf8.char(57363))
					if self._risk < 99 then
						local r = (self._risk-3)/72
						local g = 0.8-0.6*((self._risk-3)/72)
						local b = 1-(self._risk-3)/72
						color = Color(1, r, g, b)
						self._health_panel:child("risk_indicator"):set_text(utf8.char(57363) .. tostring(self._risk))
					end
					self._health_panel:child("risk_indicator"):set_color(color:with_alpha(alpha))
				end
			else
				local downs_text = self._downs
				local color = Color.white
				if self._id == HUDManager.PLAYER_PANEL then
					self._health_panel:child("risk_indicator"):set_font_size(15)
					color = self._downs > 2 and Color('C2FC97') or self._downs > 1 and Color('CEA168') or Color('E24E4E')
				elseif self:peer_id() ~= nil then
					self._health_panel:child("risk_indicator"):set_font_size(12)
					color = self._downs > 2 and Color('E24E4E') or self._downs > 1 and Color('CEA168') or Color('C2FC97')
				end
				alpha = (WolfHUD:getSetting("show_downcounter", "boolean") and (self:peer_id() ~= nil or self._id == HUDManager.PLAYER_PANEL) and 1 or 0)
				self._health_panel:child("risk_indicator"):set_text(tostring(downs_text))
				self._health_panel:child("risk_indicator"):set_color(color:with_alpha(alpha))
			end
		end
	end
	
	HUDTeammate.increment_downs = HUDTeammate.increment_downs or function(self)
		self:set_downs(self._downs + 1)
	end
	
	HUDTeammate.reset_downs = HUDTeammate.reset_downs or function(self)
		self:set_downs(0)
	end
end