if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

	Hooks:PostHook( HUDManager, "update", "WolfHUD_DownCounter_HUDManagere_update", function(self, ...)	
		for i, panel in ipairs(self._teammate_panels) do
			panel:update_downs()
		end
	end )

elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
	
	Hooks:PostHook( HUDTeammate, "init", "WolfHUD_DownCounter_HUDTeammate_init", function(self, ...)
		if not HUDManager.CUSTOM_TEAMMATE_PANEL then	-- For CustomHUD Compatability...
			self._health_panel = self._player_panel:child("radial_health_panel")
		end
		self._downs = 0
		
		local risk_indicator_bg = self._health_panel:bitmap({
			name = "risk_indicator_bg",  
			texture = "guis/textures/pd2/crimenet_marker_glow",  
			texture_rect = { 0, 0, 64, 64 }, 
			blend_mode = "normal",  
			color = Color.black,
			alpha = 0.6,
			w = self._health_panel:w(),  
			h = self._health_panel:h(),  
			layer = 1
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
	end)
	
	local HUDTeammate_set_ai = HUDTeammate.set_ai
	function HUDTeammate:set_ai(ai)
		HUDTeammate_set_ai(self, ai)
		self:reset_downs()
	end

	function HUDTeammate:update_downs()
		if not self._health_panel then return end
		local color = Color(1, 0, 0.8, 1)
		local alpha = WolfHUD.settings.show_downcounter and 1 or 0
		if not self._downs then self._downs = 0 end
		if managers.groupai:state():whisper_mode() and self._downs == 0 then
			local risk = 99
			if self._id == HUDManager.PLAYER_PANEL then
				self._health_panel:child("risk_indicator"):set_font_size(15 * (HUDTeammate._PLAYER_PANEL_SCALE or 1))
				risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_local(75)))
			elseif self:peer_id() ~= nil then
				self._health_panel:child("risk_indicator"):set_font_size(15 * (HUDTeammate._TEAMMATE_PANEL_SCALE or 0.75))
				risk = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_peer(managers.network:session():peer(self:peer_id()), 75)))
			end
			self._health_panel:child("risk_indicator"):set_text(utf8.char(57363))
			if risk < 99 then
				local r = (risk-3)/72
				local g = 0.8-0.6*((risk-3)/72)
				local b = 1-(risk-3)/72
				color = Color(1, r, g, b)
				self._health_panel:child("risk_indicator"):set_text(utf8.char(57363) .. tostring(risk))
			end
		else
			local downs_text = self._downs
			if self._id == HUDManager.PLAYER_PANEL then
				self._health_panel:child("risk_indicator"):set_font_size(19 * (HUDTeammate._PLAYER_PANEL_SCALE or 1))
				downs_text = (3 + managers.player:upgrade_value("player", "additional_lives", 0)) - self._downs
				has_messiah = managers.player:has_category_upgrade("player", "pistol_revive_from_bleed_out")
				if has_messiah and managers.player:player_unit() and managers.player:player_unit():character_damage() then
					messiah_charges = managers.player:player_unit():character_damage()._messiah_charges
					downs_text = downs_text .. "/" .. (messiah_charges or "?")
				end
			elseif self:peer_id() ~= nil then
				self._health_panel:child("risk_indicator"):set_font_size(15 * (HUDTeammate._TEAMMATE_PANEL_SCALE or 0.75))
			end
			alpha = (WolfHUD.settings.show_downcounter and (self:peer_id() ~= nil or self._id == HUDManager.PLAYER_PANEL) and 1 or 0)
			color = self._downs > 2 and Color('E24E4E') or self._downs > 1 and Color('CEA168') or Color('C2FC97')
			self._health_panel:child("risk_indicator"):set_text(tostring(downs_text))
		end
		self._health_panel:child("risk_indicator"):set_color(color:with_alpha(alpha))
	end
	
	function HUDTeammate:downed()
		if not self._ai then
			self._downs = self._downs + 1
		else
			self._downs = 0
		end
		self:update_downs()
	end
	
	function HUDTeammate:reset_downs()
		self._downs = 0
		self:update_downs()
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playerbleedout" then
	local player_bleed_out_original = PlayerBleedOut._enter
	function PlayerBleedOut:_enter(enter_data)
		player_bleed_out_original(self, enter_data)
		managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:downed()
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/huskplayermovement" then
	local HuskPlayerMovement_start_bleedout = HuskPlayerMovement._start_bleedout
	function HuskPlayerMovement:_start_bleedout(event_desc)
		local char_data = managers.criminals:character_data_by_unit(self._unit)
		managers.hud._teammate_panels[char_data.panel_id or HUDManager.PLAYER_PANEL]:downed()
		return HuskPlayerMovement_start_bleedout(self, event_desc)
	end
elseif string.lower(RequiredScript) == "lib/units/equipment/doctor_bag/doctorbagbase" then
	local doctor_bag_take_original = DoctorBagBase.take
	function DoctorBagBase:take(unit)
		managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:reset_downs()
		doctor_bag_take_original(self, unit)
	end
elseif string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then
	local UnitNetworkHandler_sync_doctor_bag_taken = UnitNetworkHandler.sync_doctor_bag_taken
	function UnitNetworkHandler:sync_doctor_bag_taken(unit, amount, sender)
		UnitNetworkHandler_sync_doctor_bag_taken(self, unit, amount, sender)
		local peer = self._verify_sender(sender)
		local char_data = managers.criminals:character_data_by_peer_id(peer:id())
		managers.hud._teammate_panels[char_data.panel_id or HUDManager.PLAYER_PANEL]:reset_downs()
	end
elseif string.lower(RequiredScript) == "lib/managers/trademanager" then
	local announce_spawn_orig = TradeManager._announce_spawn
	function TradeManager:_announce_spawn(criminal_name)
		announce_spawn_orig(self, criminal_name)
		local char_data = managers.criminals:character_data_by_name(criminal_name)
		managers.hud._teammate_panels[char_data.panel_id or HUDManager.PLAYER_PANEL]:reset_downs()
	end
end