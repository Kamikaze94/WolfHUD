if not WolfHUD:getSetting("show_dmg_indicator", "boolean") then return end

if string.lower(RequiredScript) == "lib/managers/hud/hudhitdirection" then
	HUDHitDirection.indicator_count = 0
	HUDHitDirection.DAMAGE_TYPES = {}
	HUDHitDirection.DAMAGE_TYPES.HEALTH = 1
	HUDHitDirection.DAMAGE_TYPES.ARMOUR = 2
	HUDHitDirection.DAMAGE_TYPES.VEHICLE = 3
	HUDHitDirection.DAMAGE_TYPES.CRIT = 4
	HUDHitDirection.DAMAGE_TYPES.FRIENDLY_FIRE = 5
	
	local init_original = HUDHitDirection.init
	local _add_hit_indicator_original = HUDHitDirection._add_hit_indicator
	local _remove_original = HUDHitDirection._remove
	
	function HUDHitDirection:init(...)
		init_original(self, ...)
		if alive(self._hud_panel) and alive(self._hit_direction_panel) then
			self._hit_direction_panel:set_w(self._hud_panel:w())
			self._hit_direction_panel:set_h(self._hud_panel:h())
			self._hit_direction_panel:set_center(self._hit_direction_panel:parent():w() * 0.5, self._hit_direction_panel:parent():h() * 0.5)
		end
	end
	
	function HUDHitDirection:_add_hit_indicator(...)
		HUDHitDirection.PANEL_SIZE = WolfHUD:getSetting("dmg_ind_size", "number")
		if self.indicator_count < WolfHUD:getSetting("dmg_indicator_max_count", "number") then
			self.indicator_count = self.indicator_count + 1
			_add_hit_indicator_original(self, ...)
		end
	end
	
	function HUDHitDirection:_animate(indicator, data, remove_func)
		data.duration = WolfHUD:getSetting("dmg_ind_time", "number")
		data.t = 0
		while data.t < data.duration do
			local dt = coroutine.yield()
			data.t = data.t + dt
			if alive(indicator) then
				local o = data.t / data.duration
				indicator:set_color(self:_get_indicator_color(data.damage_type, o))
				indicator:set_alpha( math.clamp(math.sin(math.deg(o * math.pi)), 0, 1) )
				if managers.player:player_unit() then
					local ply_camera = managers.player:player_unit():camera()
					if ply_camera then
						local target_vec = ply_camera:position() - data.origin
						local angle = target_vec:to_polar_with_reference(ply_camera:forward(), math.UP).spin
						local r = HUDHitDirection.PANEL_SIZE + (1-math.pow(o,0.5)) * (100)
						if data.fixed_angle ~= nil then
							angle = data.fixed_angle
						end
						indicator:set_rotation(90 - angle)
						indicator:set_center(self._hit_direction_panel:w() * 0.5 - math.sin(angle + 180) * r, self._hit_direction_panel:h() * 0.5 - math.cos(angle + 180) * r)
					end
				end
			end
		end
		remove_func(indicator, data)
	end
	
	function HUDHitDirection:_remove(...)
		_remove_original(self, ...)
		self.indicator_count = self.indicator_count - 1
	end
	
	function HUDHitDirection:_get_indicator_color(damage_type, t)
		if damage_type == HUDHitDirection.DAMAGE_TYPES.HEALTH then
			return WolfHUD:getSetting("dmg_health_color", "color")
		elseif damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
			return WolfHUD:getSetting("dmg_shield_color", "color")
		elseif damage_type == HUDHitDirection.DAMAGE_TYPES.VEHICLE then
			return WolfHUD:getSetting("dmg_vehicle_color", "color")
		elseif damage_type == HUDHitDirection.DAMAGE_TYPES.CRIT then
			return WolfHUD:getSetting("dmg_crit_color", "color")
		elseif damage_type == HUDHitDirection.DAMAGE_TYPES.FRIENDLY_FIRE then
			return WolfHUD:getSetting("dmg_friendlyfire_color", "color")
		else
			return Color(1, t, t)
		end
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
	local PlayerDamage_damage_explosion = PlayerDamage.damage_explosion
	local PlayerDamage_damage_fire = PlayerDamage.damage_fire
	
	function PlayerDamage:damage_explosion(attack_data, ...)
		PlayerDamage_damage_explosion(self, attack_data, ...)
		local distance = mvector3.distance(attack_data.position, self._unit:position())
		if self:_chk_can_take_dmg() and distance <= attack_data.range and not (self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable or self:incapacitated() or self._bleed_out) then
			self:_hit_direction(attack_data.position, HUDHitDirection.DAMAGE_TYPES.FRIENDLY_FIRE)
		end
	end
	
	function PlayerDamage:damage_fire(attack_data, ...)
		PlayerDamage_damage_fire(self, attack_data, ...)
		local distance = mvector3.distance(attack_data.position, self._unit:position())
		if self:_chk_can_take_dmg() and distance <= attack_data.range and not (self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable or self:incapacitated() or self._bleed_out) then
			self:_hit_direction(attack_data.position, HUDHitDirection.DAMAGE_TYPES.FRIENDLY_FIRE)
		end
	end
	
	function PlayerDamage:_hit_direction(position_vector, damage_type)
		if position_vector then
			local armor_left, low_health = (self:get_real_armor() > 0), ((self:get_real_health() / self:_max_health()) <= 0.20)
			local dmg_type = low_health and HUDHitDirection.DAMAGE_TYPES.CRIT or damage_type or armor_left and HUDHitDirection.DAMAGE_TYPES.ARMOUR or HUDHitDirection.DAMAGE_TYPES.HEALTH
			managers.hud:on_hit_direction(position_vector, dmg_type)
		end
	end
elseif false and string.lower(RequiredScript) == "lib/units/vehicles/vehicledamage" then	
	function VehicleDamage:_hit_direction(position_vector, damage_type)
		if position_vector then
			local dmg_type = damage_type or HUDHitDirection.DAMAGE_TYPES.VEHICLE
			managers.hud:on_hit_direction(position_vector, dmg_type)
		end
	end
end