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
	--Workaround for Teammate Headshots, since col_ray doesn't get forwarded...  (self._sync_ibody_killcount)
	local sync_damage_bullet_original = CopDamage.sync_damage_bullet
	local sync_damage_melee_original = CopDamage.sync_damage_melee

	function CopDamage:_process_kill(data)
		local killer

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
				local owner = attacker:base():get_owner_id()
				if owner then
					killer =  managers.criminals:character_unit_by_peer_id(owner)
				end
			elseif attacker:base().thrower_unit then
				killer = attacker:base():thrower_unit()
			end

			if alive(killer) and alive(self._unit) then
				local tweak_id = self._unit:base()._tweak_table
				local special_unit_ids = managers.statistics and managers.statistics.special_unit_ids or {}
				local is_special = managers.groupai:state():is_enemy_special(self._unit) or table.contains(special_unit_ids, tweak_id)
				local body = data.col_ray and data.col_ray.body or self._sync_ibody_killcount and self._unit:body(self._sync_ibody_killcount)
				local headshot = body and self.is_head and self:is_head(body) or false

				if killer:in_slot(2) then
					managers.hud:increment_teammate_kill_count(HUDManager.PLAYER_PANEL, is_special, headshot)

					local current_player_state = managers.player and managers.player:get_current_state()
					local weapon_base = current_player_state and current_player_state._equipped_unit:base()
					local projectile_name = "bullet"
					if weapon_base._projectile_type_index then
						projectile_name = tweak_data and tweak_data:get_raw_value("blackmarket", "projectiles", "_projectiles_index", weapon_base._projectile_type_index)
					end
					if projectile_name == (data.variant or "") then
						local weapon_id = weapon_base:get_name_id()
						local weapon_tweak = weapon_base and weapon_base:weapon_tweak_data()
						local weapon_type = weapon_tweak.category
						local slot = weapon_tweak and weapon_tweak.use_data and weapon_tweak.use_data.selection_index
						managers.hud:increment_teammate_kill_count_detailed(HUDManager.PLAYER_PANEL, self._unit, weapon_id, weapon_type, slot)
					end
				else
					local crim_data = managers.criminals:character_data_by_unit(killer)
					if crim_data and crim_data.panel_id then
						managers.hud:increment_teammate_kill_count(crim_data.panel_id, is_special, headshot)
					end
				end
			end
		end
	end

	function CopDamage:_on_damage_received(data, ...)
		if self._dead then
			self:_process_kill(data)
		end
		self._sync_ibody_killcount = nil
		return _on_damage_received_original(self, data, ...)
	end

	function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, ...)
		if i_body then
			self._sync_ibody_killcount = i_body
		end

		return sync_damage_bullet_original(self, attacker_unit, damage_percent, i_body, ...)
	end

	function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, ...)
		if i_body then
			self._sync_ibody_killcount = i_body
		end

		return sync_damage_melee_original(self, attacker_unit, damage_percent, damage_effect_percent, i_body, ...)

	end

	--TODO: Add sync damage checks for non-local bots and players

elseif RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then

	local sync_setup_original = SentryGunBase.sync_setup

	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		sync_setup_original(self, upgrade_lvl, peer_id, ...)
		self._owner_id = self._owner_id or peer_id
	end

elseif RequiredScript == "lib/managers/statisticsmanager" then

	local shot_fired_original = StatisticsManager.shot_fired

	function StatisticsManager:shot_fired(data, ...)
		shot_fired_original(self, data, ...)

		--[[
			This does not work well for HE rounds. It would be almost correct if you halved number of shots,
			but would not take into account shots that goes into the void or compensate for direct hits
		]]

		local name_id = data.name_id or data.weapon_unit:base():get_name_id()
		local weapon_tweak = tweak_data.weapon[name_id]
		local slot = weapon_tweak and weapon_tweak.use_data and weapon_tweak.use_data.selection_index
		if slot then	--Exclude throwables like exploding cards mod...
			local weapon_data = name_id and self._global.session.shots_by_weapon[name_id]
			local weapon_accuracy = 0
			if weapon_data and weapon_data.total > 0 then
				weapon_accuracy = math.floor(100 * weapon_data.hits / weapon_data.total)
			end
			managers.hud:set_teammate_weapon_accuracy(HUDManager.PLAYER_PANEL, slot, weapon_accuracy)
		end

		managers.hud:set_teammate_accuracy(HUDManager.PLAYER_PANEL, self:session_hit_accuracy())
	end

elseif RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDManager.KILL_COUNTER_PLUGIN = true
	HUDManager.ACCURACY_PLUGIN = true

	HUDManager.increment_teammate_kill_count = HUDManager.increment_teammate_kill_count or function (self, i, is_special, headshot)
		self._teammate_panels[i]:increment_kill_count(is_special, headshot)
	end

	HUDManager.reset_teammate_kill_count = HUDManager.reset_teammate_kill_count or function(self, i)
		self._teammate_panels[i]:reset_kill_count()
	end

	HUDManager.increment_teammate_kill_count_detailed = HUDManager.increment_teammate_kill_count_detailed or function(self, i, unit, weapon_id, weapon_type, weapon_slot)
		--TODO: Add call for default HUD  |  No need for that, really...
	end

	HUDManager.set_teammate_accuracy = HUDManager.set_teammate_accuracy or function(self, i, value)
		self._teammate_panels[i]:set_accuracy(value)
	end

	HUDManager.set_teammate_weapon_accuracy = HUDManager.set_teammate_weapon_accuracy or function(self, i, slot, value)
		--TODO
	end

	function HUDManager:teampanels_height()
		return (WolfHUD:getSetting({"CustomHUD", "PLAYER", "SHOW_ACCURACY"}, true) and not WolfHUD:getSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, false)) and 140 or 120
	end

elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then

	if not HUDManager.CUSTOM_TEAMMATE_PANELS then	--Custom HUD compatibility
		local init_original = HUDTeammate.init
		local set_name_original = HUDTeammate.set_name
		local set_state_original = HUDTeammate.set_state

		function HUDTeammate:init(...)
			init_original(self, ...)
			self._setting_prefix = self._main_player and "PLAYER" or "TEAMMATE"
			self:_init_killcount()
			self:init_accuracy()
		end

		function HUDTeammate:_init_killcount()
			self._kills_panel = self._panel:panel({
				name = "kills_panel",
				visible = not WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "HIDE"}, false),
				w = 150,
				h = 20,
				x = 0,
				halign = "right"
			})

			local player_panel = self._panel:child("player")
			local name_label = self._panel:child("name")
			self._kills_panel:set_rightbottom(player_panel:right(), (self._main_player or WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "TEXT"}, true)) and name_label:bottom() or name_label:top())
			local killcount_color = WolfHUD:getColorSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "COLOR"}, "yellow")

			self._kill_icon = self._kills_panel:bitmap({
				texture = "guis/textures/pd2/cn_miniskull",
				w = self._kills_panel:h() * 0.75,
				h = self._kills_panel:h(),
				texture_rect = { 0, 0, 12, 16 },
				alpha = 1,
				blend_mode = "normal",
				layer = 0,
				color = killcount_color
			})

			self._kills_text = self._kills_panel:text({
				name = "kills_text",
				text = "-",
				layer = 1,
				color = killcount_color,
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

		function HUDTeammate:init_accuracy()
			if not self._main_player then return end
			self._accuracy_panel = self._panel:panel({
				name = "accuracy_panel",
				visible = WolfHUD:getSetting({"CustomHUD", "PLAYER", "SHOW_ACCURACY"}, true),
				w = 100,
				h = 20,
				x = 0,
				halign = "right"
			})

			local player_panel = self._panel:child("player")
			local name_label = self._panel:child("name")
			self._accuracy_panel:set_rightbottom(player_panel:right(), self._kills_panel and self._kills_panel:visible() and self._kills_panel:top() or name_label:bottom())

			self._accuracy_icon = self._accuracy_panel:bitmap({
				texture = "guis/textures/pd2/pd2_waypoints",
				w = self._accuracy_panel:h() * 0.75,
				h = self._accuracy_panel:h(),
				texture_rect = { 96, 0, 32, 32 },
				alpha = 1,
				blend_mode = "normal",
				layer = 0,
				color = Color.white
			})

			self._accuracy_text = self._accuracy_panel:text({
				name = "accuracy_text",
				text = "0%",
				layer = 1,
				color = Color.white,
				w = self._accuracy_panel:w(),
				h = self._accuracy_panel:h(),
				vertical = "center",
				align = "right",
				font_size = self._accuracy_panel:h(),
				font = tweak_data.hud_players.name_font
			})
			self:set_accuracy(0)
		end

		function HUDTeammate:increment_kill_count(is_special, headshot)
			self._kill_count = self._kill_count + 1
			self._kill_count_special = self._kill_count_special + (is_special and 1 or 0)
			self._headshot_kills = self._headshot_kills + (headshot and 1 or 0)
			self:_update_kill_count_text()
		end

		function HUDTeammate:_update_kill_count_text()
			local kill_string = tostring(self._kill_count)
			if WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "SHOW_SPECIAL_KILLS"}, true) then
				kill_string = kill_string .. "/" .. tostring(self._kill_count_special)
			end
			if WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"}, true) then
				kill_string = kill_string .. " (" .. tostring(self._headshot_kills) .. ")"
			end
			self._kills_text:set_text(kill_string)
			local _, _, w, _ = self._kills_text:text_rect()
			self._kill_icon:set_right(self._kills_panel:w() - w - self._kill_icon:w() * 0.15)

			if (self._main_player or WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "TEXT"}, true)) and not WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "HIDE"}, false) then
				self._max_name_panel_width = (self._kills_panel:x() + self._kill_icon:x() - 4)
				self:_truncate_name()
			end

			local color = WolfHUD:getColorSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "COLOR"}, "yellow")
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

			local visible = not WolfHUD:getSetting({"CustomHUD", self._setting_prefix, "KILLCOUNTER", "HIDE"}, false) and (not self._ai or WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_BOT_KILLS"}, true))
			self._kills_panel:set_visible(visible)

			if self._ai then
				self._kills_panel:set_bottom(self._panel:child("player"):bottom())
			else
				local name_label = self._panel:child("name")
				self._kills_panel:set_bottom((self._main_player or WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "TEXT"}, true)) and name_label:bottom() or name_label:top())
			end
		end

		function HUDTeammate:set_accuracy(value)
			self._accuracy_text:set_text(tostring(value) .. "%")
			local _, _, w, _ = self._accuracy_text:text_rect()
			self._accuracy_icon:set_right(self._accuracy_panel:w() - w - self._accuracy_icon:w() * 0.15)
			if WolfHUD:getSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, false) and WolfHUD:getSetting({"CustomHUD", "PLAYER", "SHOW_ACCURACY"}, true) then
				self._max_name_panel_width = (self._accuracy_panel:x() + self._accuracy_icon:x() - 4)
				self:_truncate_name()
			end
		end

		HUDTeammate._truncate_name = HUDTeammate._truncate_name or function() end
	end
end
