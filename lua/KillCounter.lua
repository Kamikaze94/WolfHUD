if string.lower(RequiredScript) == "lib/managers/enemymanager" then
	EnemyManager._MAX_NR_CORPSES = WolfHUD:getSetting("max_corpses", "number")
end

if WolfHUD:getSetting("use_killcounter", "boolean") then return end
if string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then

	HUDTeammate.SHOW_SPECIAL_KILLS = WolfHUD:getSetting("SHOW_SPECIAL_KILLS", "boolean")
	HUDTeammate.SHOW_HEADSHOT_KILLS = WolfHUD:getSetting("SHOW_HEADSHOT_KILLS", "boolean")
	HUDTeammate.SHOW_AI_KILLS = WolfHUD:getSetting("SHOW_AI_KILLS", "boolean")
	
	if not HUDTeammate.increment_kill_count and not HUDManager.CUSTOM_TEAMMATE_PANEL then	--Custom HUD compatibility
		local init_original = HUDTeammate.init
		local set_name_original = HUDTeammate.set_name
		local set_state_original = HUDTeammate.set_state

		function HUDTeammate:init(...)
			init_original(self, ...)
			if not HUDManager.CUSTOM_TEAMMATE_PANEL then
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
				blend_mode = "add",
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
			if self.SHOW_SPECIAL_KILLS then
				kill_string = kill_string .. "/" .. tostring(self._kill_count_special)
			end
			if HUDTeammate.SHOW_HEADSHOT_KILLS then
				kill_string = kill_string .. " (" .. tostring(self._headshot_kills) .. ")"
			end
			self._kills_text:set_text(kill_string)
			local _, _, w, _ = self._kills_text:text_rect()
			self._kill_icon:set_right(self._kills_panel:w() - w - self._kill_icon:w() * 0.15)
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
	

elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then

	HUDManager._USE_KILL_COUNTER = true	--Custom HUD compatibility

	function HUDManager:increment_kill_count(teammate_panel_id, is_special, headshot)
		self._teammate_panels[teammate_panel_id]:increment_kill_count(is_special, headshot)
	end

	function HUDManager:reset_kill_count(teammate_panel_id)
		self._teammate_panels[teammate_panel_id]:reset_kill_count()
	end
	
elseif string.lower(RequiredScript) == "lib/units/enemies/cop/copdamage" then

	local bullet_original = CopDamage.damage_bullet
	local explosion_original = CopDamage.damage_explosion
	local melee_original = CopDamage.damage_melee
	local fire_original = CopDamage.damage_fire
	local sync_bullet_original = CopDamage.sync_damage_bullet
	local sync_explosion_original = CopDamage.sync_damage_explosion
	local sync_melee_original = CopDamage.sync_damage_melee
	local sync_fire_original = CopDamage.sync_damage_fire

	function CopDamage:_process_kill(aggressor, i_body)
		if alive(aggressor) and aggressor:base() then
			if aggressor:base().sentry_gun then
				aggressor = aggressor:base():get_owner() or managers.criminals:character_unit_by_peer_id(aggressor:base()._owner_id)
			elseif aggressor:base()._projectile_entry then
				aggressor = aggressor:base()._thrower_unit
			end
		end
		
		if alive(aggressor) then
			local panel_id

			if aggressor == managers.player:player_unit() then
				panel_id = HUDManager.PLAYER_PANEL
			else
				local char_data = managers.criminals:character_data_by_unit(aggressor)
				panel_id = char_data and char_data.panel_id
			end
			
			if panel_id then
				local body_name = i_body and self._unit:body(i_body) and self._unit:body(i_body):name()
				local headshot = self._head_body_name and body_name and body_name == self._ids_head_body_name or false
				local is_special = managers.groupai:state()._special_unit_types[self._unit:base()._tweak_table] or false
				managers.hud:increment_kill_count(panel_id, is_special, headshot)
				return
			end
		end
	end

	function CopDamage:damage_bullet(attack_data, ...)
		local result = bullet_original(self, attack_data, ...)
		if result and result.type == "death" then self:_process_kill(attack_data.attacker_unit, self._unit:get_body_index(attack_data.col_ray.body:name())) end
		return result
	end

	function CopDamage:damage_explosion(attack_data, ...)
		local result = explosion_original(self, attack_data, ...)
		if result and result.type == "death" then self:_process_kill(attack_data.attacker_unit) end
		return result
	end

	function CopDamage:damage_melee(attack_data, ...)
		local result = melee_original(self, attack_data, ...)
		if result and result.type == "death" then self:_process_kill(attack_data.attacker_unit, self._unit:get_body_index(attack_data.col_ray.body:name())) end
		return result
	end
	
	function CopDamage:damage_fire(attack_data, ...)
		--TODO: Fix this when Overkill has learned how to code
		
		if not self:dead() then
			fire_original(self, attack_data, ...)
			if self:dead() and alive(attack_data.attacker_unit) then
				self:_process_kill(attack_data.attacker_unit, attack_data.col_ray and attack_data.col_ray.body and self._unit:get_body_index(attack_data.col_ray.body:name())) 
			end
		end
		
		--local result = fire_original(self, attack_data, ...)
		--if result and result.type == "death" then self:_process_kill(attack_data.attacker_unit, self._unit:get_body_index(attack_data.col_ray.body:name())) end
		--return result
	end

	function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, death, ...)
		if death then self:_process_kill(attacker_unit, i_body) end
		return sync_bullet_original(self, attacker_unit, damage_percent, i_body, hit_offset_height, death, ...)
	end

	function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, ...)
		if death then self:_process_kill(attacker_unit) end
		return sync_explosion_original(self, attacker_unit, damage_percent, i_attack_variant, death, ...)
	end

	function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death, ...)
		if death then
			self:_process_kill(attacker_unit, i_body)
		end
		return sync_melee_original(self, attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death, ...)
	end

	function CopDamage:sync_damage_fire(attacker_unit, damage_percent, death, ...)
		if death then
			self:_process_kill(attacker_unit)
		end
		return sync_fire_original(self, attacker_unit, damage_percent, death, ...)
	end
	
elseif string.lower(RequiredScript) == "lib/units/equipment/sentry_gun/sentrygunbase" then
	
	local sync_setup_original = SentryGunBase.sync_setup
	
	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		sync_setup_original(self, upgrade_lvl, peer_id, ...)
		self._owner_id = self._owner_id or peer_id
	end

end