if string.lower(RequiredScript) == "lib/managers/enemymanager" then
	EnemyManager._MAX_NR_CORPSES = WolfHUD:getSetting("max_corpses", "number")
end

if not WolfHUD:getSetting("use_killcounter", "boolean") then return end

if RequiredScript == "lib/units/enemies/cop/copdamage" then

--This needs fixing for DoT kills (then again, so does the games own kill counter) as client somehow and a lot of testing

--[[
local chk_killshot_original = CopDamage.chk_killshot

function CopDamage:chk_killshot(attacker_unit, variant)
	--printf("chk_killshot: %s\n", tostring(attacker_unit and attacker_unit:slot()))
	
	if alive(attacker_unit) then
		local source = "direct/unknown"
		local killer = attacker_unit
		
		if attacker_unit:in_slot(14) then
			if attacker_unit:base().thrower_unit then
				source = "throwable"
				killer = attacker_unit:base():thrower_unit()
			end
		elseif attacker_unit:in_slot(25) then
			if attacker_unit:base().sentry_gun then
				local owner = attacker_unit:base()._owner_id
				if owner then
					source = "sentry"
					killer = managers.criminals:character_unit_by_peer_id(owner)
				end
			end
		end
		
		if killer then
			if killer:in_slot(3) then
				--printf("Teammate kill (%s)\n", source)
				local crim_data = managers.criminals:character_data_by_unit(killer)
				if crim_data and crim_data.panel_id then
					managers.hud:increment_teammate_kill_count(crim_data.panel_id, managers.groupai:state():is_enemy_special(self._unit))
				end
			elseif killer:in_slot(2) then
				--printf("Player kill (%s)\n", source)
				managers.hud:increment_teammate_kill_count(HUDManager.PLAYER_PANEL, managers.groupai:state():is_enemy_special(self._unit))
			elseif killer:in_slot(16) then
				printf("Bot/joker kill (%s)\n", source)
				local crim_data = managers.criminals:character_data_by_unit(killer)
				if crim_data and crim_data.panel_id then
					managers.hud:increment_teammate_kill_count(crim_data.panel_id, managers.groupai:state():is_enemy_special(self._unit))
				end
			elseif killer:in_slot(12) then
				--printf("Enemy kill (%s)\n", source)
			else
				printf("UNKNOWN KILL (%d / %s)\n", killer:slot(), source)
			end
		else
			printf("UNKNOWN KILL (no killer, attacker unit: %d)\n", attacker_unit:slot())
		end
	end
	

	
	return chk_killshot_original(self, attacker_unit, variant)
end
]]

	local _on_damage_received_original = CopDamage._on_damage_received

	function CopDamage:_process_kill(data)
		local killer
		local weapon_type
		local weapon_slot
		
		local attacker = alive(data.attacker_unit) and data.attacker_unit

		if attacker then
			if attacker:in_slot(3) or attacker:in_slot(5) then	
				--Human team mate
				killer = attacker
			elseif attacker:in_slot(2) then
				--Player
				killer = attacker
			elseif attacker:in_slot(16) then
				--Bot/joker
				killer = attacker
			elseif attacker:in_slot(12) then
				--Enemy
			elseif attacker:in_slot(25)	then
				--Turret
				local owner = attacker:base()._owner_id
				if owner then 
					killer =  managers.criminals:character_unit_by_peer_id(owner)
				end
			elseif attacker:base().thrower_unit then
				killer = attacker:base():thrower_unit()
			end
			
			if alive(killer) then
				local is_special = managers.groupai:state():is_enemy_special(self._unit)
				local i_body = data.col_ray and data.col_ray.body and self._unit:get_body_index(data.col_ray.body:name())
				local body_name = i_body and self._unit:body(i_body) and self._unit:body(i_body):name()
				local headshot = self._head_body_name and body_name and body_name == self._ids_head_body_name or false
				if killer:in_slot(2) then
					managers.hud:increment_teammate_kill_count(HUDManager.PLAYER_PANEL, is_special, headshot)
				else
					local crim_data = managers.criminals:character_data_by_unit(killer)
					if crim_data and crim_data.panel_id then
						managers.hud:increment_teammate_kill_count(crim_data.panel_id, is_special, headshot)
					end
				end
			end
		end
		
--[[
		if alive(data.attacker_unit) then
			if data.attacker_unit:base().sentry_gun then
				killer = managers.criminals:character_unit_by_peer_id(data.attacker_unit:base()._owner_id)
				weapon_type = "sentry"
			elseif data.attacker_unit:base().thrower_unit then
				killer = data.attacker_unit:base():thrower_unit()
				
				if alive(data.attacker_unit:base():weapon_unit()) then
					weapon_type = "weapon"
					weapon_slot = tweak_data.weapon[data.attacker_unit:base():weapon_unit():base():get_name_id()].use_data.selection_index
				else
					weapon_type = "throwable"
				end
			elseif data.name_id and tweak_data.blackmarket.melee_weapons[data.name_id] then
				killer = data.attacker_unit
				weapon_type = "melee"
			elseif alive(data.weapon_unit) then
				killer = data.attacker_unit
				local name_id = data.weapon_unit:base():get_name_id()
				
				if tweak_data.blackmarket.projectiles[name_id] then
					weapon_type = "throwable"
				elseif tweak_data.weapon[name_id] then
					weapon_type = "weapon"
					weapon_slot = tweak_data.weapon[name_id].use_data.selection_index
				elseif name_id == "trip_mine" then
					weapon_type = "trip_mine"
				end
			end
		end
		
		if killer and weapon_type then
			if killer == managers.player:player_unit() then
				managers.hud:increment_teammate_kill_count(HUDManager.PLAYER_PANEL, managers.groupai:state():is_enemy_special(self._unit))
				managers.hud:increment_teammate_kill_count_detailed(HUDManager.PLAYER_PANEL, self._unit, weapon_type, weapon_slot)
			elseif not managers.criminals:character_peer_id_by_unit(killer) then
				--io.write("DEBUG: Kill by bot " .. tostring(managers.criminals:character_name_by_unit(killer)) .. ": " .. tostring(weapon_type) .. " (" .. tostring(weapon_slot) .. ")\n")
			end
		end
]]
	end
	
	function CopDamage:_on_damage_received(data, ...)
		if self._dead then
			self:_process_kill(data)
		end
		
		return _on_damage_received_original(self, data, ...)
	end

	--TODO: Add sync damage checks for non-local bots and players

	
elseif RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
	
	local sync_setup_original = SentryGunBase.sync_setup
	
	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		sync_setup_original(self, upgrade_lvl, peer_id, ...)
		self._owner_id = self._owner_id or peer_id
	end
	
elseif RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDManager.KILL_COUNTER_PLUGIN = true
	HUDManager.SHOW_BOT_KILLS = true

	HUDManager.increment_teammate_kill_count = HUDManager.increment_teammate_kill_count or function (self, i, is_special, headshot)
		self._teammate_panels[i]:increment_kill_count(is_special, headshot)
	end
	
	HUDManager.reset_teammate_kill_count = HUDManager.reset_teammate_kill_count or function(self, i)
		self._teammate_panels[i]:reset_kill_count()
	end
	
	HUDManager.increment_teammate_kill_count_detailed = HUDManager.increment_teammate_kill_count_detailed or function(self, i, unit, weapon_type, weapon_slot)
		--TODO: Add call for default HUD  |  No need for that, really...
	end

elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then

	HUDTeammate.SHOW_AI_KILLS = WolfHUD:getSetting("SHOW_AI_KILLS", "boolean")
	
	if not HUDTeammate.increment_kill_count and not HUDManager.CUSTOM_TEAMMATE_PANELS then	--Custom HUD compatibility
		local init_original = HUDTeammate.init
		local set_name_original = HUDTeammate.set_name
		local set_state_original = HUDTeammate.set_state

		function HUDTeammate:init(...)
			init_original(self, ...)
			if not HUDManager.CUSTOM_TEAMMATE_PANELS then
				self:_init_killcount()
			end
		end
		
		function HUDTeammate:_init_killcount()
			self._kills_panel = self._panel:panel({
				name = "kills_panel",
				visible = true,
				w = 100,
				h = 20,
				x = 0,
				halign = "right"
			})
			
			local player_panel = self._panel:child("player")
			local name_label = self._panel:child("name")
			self._kills_panel:set_rightbottom(player_panel:right(), (self._id == HUDManager.PLAYER_PANEL) and name_label:bottom() or name_label:top())
			
			self._kill_icon = self._kills_panel:bitmap({
				texture = "guis/textures/pd2/cn_miniskull",
				w = self._kills_panel:h() * 0.75,
				h = self._kills_panel:h(),
				texture_rect = { 0, 0, 12, 16 },
				alpha = 1,
				blend_mode = "normal",
				layer = 0,
				color = Color.yellow
			})
			
			self._kills_text = self._kills_panel:text({
				name = "kills_text",
				text = "-",
				layer = 1,
				color = Color.yellow,
				w = self._kills_panel:w() - self._kill_icon:w(),
				h = self._kills_panel:h(),
				vertical = "center",
				align = "right",
				font_size = self._kills_panel:h(),
				font = tweak_data.hud_players.name_font
			})
			self._kills_text:set_right(self._kills_panel:w())
			
			self:reset_kill_count()
		end

		function HUDTeammate:increment_kill_count(is_special, headshot)
			self._kill_count = self._kill_count + 1
			self._kill_count_special = self._kill_count_special + (is_special and 1 or 0)
			self._headshot_kills = self._headshot_kills + (headshot and 1 or 0)
			self:_update_kill_count_text()
		end

		function HUDTeammate:_update_kill_count_text()
			local kill_string = tostring(self._kill_count)
			if WolfHUD:getSetting("SHOW_SPECIAL_KILLS", "boolean") then
				kill_string = kill_string .. "/" .. tostring(self._kill_count_special)
			end
			if WolfHUD:getSetting("SHOW_HEADSHOT_KILLS", "boolean") then
				kill_string = kill_string .. " (" .. tostring(self._headshot_kills) .. ")"
			end
			self._kills_text:set_text(kill_string)
			local _, _, w, _ = self._kills_text:text_rect()
			self._kill_icon:set_right(self._kills_panel:w() - w - self._kill_icon:w() * 0.15)
			
			if WolfHUD:getSetting("killcounter_color", "string") == "rainbow" then
				color = WolfHUD.color_table[(self._kill_count % (#WolfHUD.color_table - 1)) + 1].color
			else
				color = WolfHUD:getSetting("killcounter_color", "color")
			end
			self._kill_icon:set_color(color)
			self._kills_text:set_color(color)
		end

		function HUDTeammate:reset_kill_count()
			self._kill_count = 0
			self._kill_count_special = 0
			self._headshot_kills = 0
			self:_update_kill_count_text()
		end

		function HUDTeammate:set_name(teammate_name, ...)
			if teammate_name ~= self._name then
				self._name = teammate_name
				self:reset_kill_count()
			end
			
			return set_name_original(self, teammate_name, ...)
		end
	
		function HUDTeammate:set_state(...)
			set_state_original(self, ...)
		
			if not HUDTeammate.SHOW_AI_KILLS then
				self._kills_panel:set_visible(not self._ai and true or false)
			end
			
			if self._ai then
				self._kills_panel:set_bottom(self._panel:child("player"):bottom())
			else
				local name_label = self._panel:child("name")
				self._kills_panel:set_bottom((self._id == HUDManager.PLAYER_PANEL) and name_label:bottom() or name_label:top())
			end
		end
	end
end