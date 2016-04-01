if string.lower(RequiredScript) == "lib/managers/hud/hudhitdirection" then
	HUDHitDirection.seconds 	 = WolfHUD.settings.dmg_ind_time or 2
	HUDHitDirection.opacity 	 = 80
	HUDHitDirection.sizeStart 	 = WolfHUD.settings.dmg_ind_size or 150
	HUDHitDirection.sizeEnd 	 = HUDHitDirection.sizeStart + 100
	
	HUDHitDirection.shieldColor  = WolfHUD.color_table[(WolfHUD.settings.dmg_shield_color)] or Color.white
	HUDHitDirection.healthColor  = WolfHUD.color_table[(WolfHUD.settings.dmg_health_color)] or Color.red
	HUDHitDirection.critColor 	 = WolfHUD.color_table[(WolfHUD.settings.dmg_crit_color)] or Color.purple
	HUDHitDirection.vehicleColor = WolfHUD.color_table[(WolfHUD.settings.dmg_vehicle_color)] or Color.yellow
	HUDHitDirection.friendlyColor = Color('FFA500')

---------   END of Settings!   ------   Don't Edit Below, unless you know what you are doing!!!!   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	HUDHitDirection.UNIT_TYPE_HIT_ARMOR = 0
	HUDHitDirection.UNIT_TYPE_HIT_PLAYER = 1
	HUDHitDirection.UNIT_TYPE_HIT_CRIT = 2
	HUDHitDirection.UNIT_TYPE_HIT_VEHICLE = 3
	HUDHitDirection.UNIT_TYPE_HIT_FRIENDLY_FIRE = 4


	local hudhitdirection_init = HUDHitDirection.init
	function HUDHitDirection:init(hud)
		hudhitdirection_init(self, hud)
		local is_visible = not WolfHUD.settings.show_dmg_indicator
		self._hit_direction_panel:child("right"):set_visible(is_visible)
		self._hit_direction_panel:child("left"):set_visible(is_visible)
		self._hit_direction_panel:child("up"):set_visible(is_visible)
		self._hit_direction_panel:child("down"):set_visible(is_visible)
	end

	function HUDHitDirection:new_hitmarker(pos, type_hit)
		if not self._hit_direction_panel or not WolfHUD.settings.show_dmg_indicator then return end
		local color = (type_hit == self.UNIT_TYPE_HIT_ARMOR and HUDHitDirection.shieldColor or type_hit == self.UNIT_TYPE_HIT_PLAYER and HUDHitDirection.healthColor or type_hit == HUDHitDirection.UNIT_TYPE_HIT_CRIT and HUDHitDirection.critColor or type_hit == self.UNIT_TYPE_HIT_VEHICLE and HUDHitDirection.vehicleColor or type_hit == HUDHitDirection.UNIT_TYPE_HIT_FRIENDLY_FIRE and HUDHitDirection.friendlyColor) or Color.white
		local hitmarker = self._hit_direction_panel:panel({
			x = "center",
			y = "center",
			w = HUDHitDirection.sizeEnd,
			h = HUDHitDirection.sizeEnd
		})
		local hitmarker_icon = hitmarker:bitmap({
			name = "marker",
			rotation = 270,
			visible = true,
			texture = "guis/textures/pd2/hitdirection",
			color = color,
			blend_mode = "add",
			alpha = 0,
			halign = "right"
		})
		hitmarker:stop()
		hitmarker:animate( callback(self, self, "_animate_hitmarker"), hitmarker_icon, pos )
	end
	
	function HUDHitDirection:_animate_hitmarker(hitmarker, hitmarker_icon, pos)
		if self._hit_direction_panel and hitmarker and hitmarker_icon then
			local t = 0
			while alive(hitmarker) and t < HUDHitDirection.seconds do
				t = t + coroutine.yield()
				local o = t / HUDHitDirection.seconds
				local angle = self:getRotation(pos) or 180
				local r = HUDHitDirection.sizeStart + (1-math.pow(o,0.5)) * (HUDHitDirection.sizeEnd - HUDHitDirection.sizeStart)
				hitmarker_icon:set_alpha((-3 * math.pow(o - 0.5 , 2) + 0.7) * HUDHitDirection.opacity / 100 )
				hitmarker_icon:set_rotation(-(angle+90))
				hitmarker:set_center(self._hit_direction_panel:w()/2-math.sin(angle)*r + 70, self._hit_direction_panel:h()/2-math.cos(angle)*r - 30)
			end
			hitmarker:set_visible(false)
			self._hit_direction_panel:remove(hitmarker)
		end
	end
	
	function HUDHitDirection:getRotation( pos )
		
		local target_vec = pos - managers.player:player_unit():camera():position()
		local fwd = managers.player:player_unit():camera():rotation():y()
		local angle = target_vec:to_polar_with_reference( fwd, math.UP ).spin
		
		return angle
	end
	
	local HUDManager_set_mugshot_custody = HUDManager.set_mugshot_custody
	function HUDManager:set_mugshot_custody(id)
		HUDManager_set_mugshot_custody(self, id)
		if self._hud_hit_direction then -- ReInit HUDHitDirection, when you go into custody. No clean soulution, but it seems to work...
			hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			self._hud_hit_direction = HUDHitDirection:new(hud)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	function HUDManager:new_hitmarker(data, damage_type)
		local col_ray = data.col_ray
		if col_ray and col_ray.position and col_ray.distance then
			mobPos = col_ray.position - (col_ray.ray*(col_ray.distance or 0))
		end
		if not mobPos then
			local mobUnit = data.weapon_unit or data.attacker_unit
			if mobUnit and alive(mobUnit) then
				mobPos = mobUnit:position()
			else
				mobPos = data.hit_pos or data.position
			end
		end
		if not mobPos then
			mobPos = managers.player:player_unit():position()
		end
		self._hud_hit_direction:new_hitmarker(mobPos, damage_type)
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
	local PlayerDamage_damage_bullet = PlayerDamage.damage_bullet
	local PlayerDamage_damage_killzone = PlayerDamage.damage_killzone
	local PlayerDamage_damge_fall = PlayerDamage.damage_fall
	local PlayerDamage_damage_explosion = PlayerDamage.damage_explosion
	local PlayerDamage_damage_fire = PlayerDamage.damage_fire
	
	function PlayerDamage:damage_bullet(attack_data)
		PlayerDamage_damage_bullet(self, attack_data)
		self:showHitmarker(attack_data)
	end

	function PlayerDamage:damage_killzone(attack_data)
		PlayerDamage_damage_killzone(self, attack_data)
		self:showHitmarker(attack_data)
	end

	function PlayerDamage:damage_fall(data)
		local val = PlayerDamage_damge_fall(self, data)
		 if val then 
			self:showHitmarker(data)
		end
		return val
	end
	
	function PlayerDamage:damage_explosion(attack_data)
		PlayerDamage_damage_explosion(self, attack_data)
		local distance = mvector3.distance(attack_data.position, self._unit:position())
		if distance <= attack_data.range then
			self:showHitmarker(attack_data, HUDHitDirection.UNIT_TYPE_HIT_FRIENDLY_FIRE)
		end
	end
	
	function PlayerDamage:damage_fire(attack_data)
		PlayerDamage_damage_fire(self, attack_data)
		self:showHitmarker(attack_data, HUDHitDirection.UNIT_TYPE_HIT_FRIENDLY_FIRE)
	end
	
	function PlayerDamage:showHitmarker(attack_data, damage_type)
		local dmg_type = damage_type or HUDHitDirection.UNIT_TYPE_HIT_PLAYER
		if not damage_type and self:get_real_armor() > 0 then
			dmg_type = HUDHitDirection.UNIT_TYPE_HIT_ARMOR
		elseif (self:get_real_health() / self:_max_health()) <= 0.20 then
			dmg_type = HUDHitDirection.UNIT_TYPE_HIT_CRIT
		end
		managers.hud:new_hitmarker(attack_data, dmg_type)
	end
elseif string.lower(RequiredScript) == "lib/units/vehicles/vehicledamage" then
	local VehicleDamage_damage_bullet = VehicleDamage.damage_bullet
	function VehicleDamage:damage_bullet(attack_data)
		local val = VehicleDamage_damage_bullet(self, attack_data)
		local local_player_vehicle = managers.player:get_vehicle()
		if val and local_player_vehicle and self._unit == local_player_vehicle.vehicle_unit then
			managers.hud:new_hitmarker(attack_data, val ~= "friendly_fire" and HUDHitDirection.UNIT_TYPE_HIT_VEHICLE or HUDHitDirection.UNIT_TYPE_HIT_FRIENDLY_FIRE)
		end
		return val
	end
end