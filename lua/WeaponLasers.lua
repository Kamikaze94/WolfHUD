if string.lower(RequiredScript) == "lib/units/weapons/weaponlaser" then
	local init_original = WeaponLaser.init
	local update_original = WeaponLaser.update
	WeaponLaser.DEFINITIONS = {
		player = {	  					--Player
			color = WolfHUD.color_table[(WolfHUD.settings.laser_player)] or Color(0,0.75,1),
			alpha = WolfHUD.settings.laser_player_alpha or 0.3,
		},
		cop_sniper = {  				--Enemy snipers
			color = WolfHUD.color_table[(WolfHUD.settings.laser_sniper)] or Color(0.7, 0, 0),
			alpha = WolfHUD.settings.laser_sniper_alpha or 0.5,
		},
		default = {	 					--Team mates
			color = WolfHUD.color_table[(WolfHUD.settings.laser_teammates)] or Color(0,0.75,1),
			alpha = WolfHUD.settings.laser_teammates_alpha or 0.15,
		},
		turret_module_active = {		--SWAT turret standard
			color = WolfHUD.color_table[(WolfHUD.settings.laser_turret_active)] or Color(1, 0, 0),
			alpha = WolfHUD.settings.laser_turret_alpha or 0.15,
		},
		turret_module_rearming = {	  	--SWAT turret reloading
			color = WolfHUD.color_table[(WolfHUD.settings.laser_turret_reloading)] or Color(1, 1, 0),
			alpha = WolfHUD.settings.laser_turret_alpha or 0.15,
		},
		turret_module_mad = {   		--SWAT turret jammed
			color = WolfHUD.color_table[(WolfHUD.settings.laser_turret_jammed)] or Color(0, 1, 0),
			alpha = WolfHUD.settings.laser_turret_alpha or 0.15,
		},
	}
		
	WeaponLaser._suffix_map = {
	player = "player",
	default = "teammates",
	cop_sniper = "sniper",
	turret_module_active = "turret_active",
	turret_module_rearming = "turret_reloading",
	turret_module_mad = "turret_jammed"
}
	
	if WolfHUD.settings.use_weaponlasers then   
		function WeaponLaser:init(...)
			init_original(self, ...)
			self:init_themes()
			self:set_color_by_theme(self._theme_type)
		end
		   
		function WeaponLaser:init_themes()
			for theme, data in pairs(WeaponLaser.DEFINITIONS) do
				self:update_theme(theme, data.color, data.alpha)
			end
		end
	 
		function WeaponLaser:update_theme(name, color, alpha)
			self._themes[name] = self._themes[name] or {}
			local color = color or self._themes[name].brush or Color.white
			local alpha = alpha or self._themes[name].brush and self._themes[name].brush.alpha or 0
	 
			self._themes[name] = {
				light = color * (WolfHUD.settings.laser_light or 10),
				glow = color / (WolfHUD.settings.laser_glow or 5),
				brush = color:with_alpha(alpha)
			}
		end
		
		function WeaponLaser:update(unit, t, dt, ...)
			update_original(self, unit, t, dt, ...)
			local theme = self._theme_type
			local suffix = self._suffix_map[theme]
			local col = Color.white
			if not theme or not suffix then return end
			if WolfHUD.settings["laser_" .. suffix] >= (#WolfHUD.color_table) then
				local r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
				col = Color(r, g, b)
			else
				col = WolfHUD.color_table[(WolfHUD.settings["laser_" .. suffix])] or Color.white
			end
			local alpha = 1
			if suffix == "turret_active" or suffix == "turret_reloading" or suffix == "turret_jammed" then
				alpha = WolfHUD.settings["laser_turret_alpha"]
			else
				alpha = WolfHUD.settings["laser_" .. suffix .. "_alpha"]
			end
			if self._themes[theme].brush == col:with_alpha(alpha) then return end
			self:update_theme(theme, col, alpha)
			self:set_color_by_theme(theme)
		end

	end
 
elseif string.lower(RequiredScript) == "lib/units/weapons/raycastweaponbase" then
 
	local on_equip_original = RaycastWeaponBase.on_equip
 
	function RaycastWeaponBase:on_equip(...)
		if self._has_gadget then
			self:_setup_laser()
			if alive(self._second_gun) then
				self._second_gun:base():_setup_laser()
			end
		end
			   
		return on_equip_original(self, ...)
	end
	   
	function RaycastWeaponBase:_setup_laser()
		for id, part in pairs(self._parts) do
			local base = part.unit and part.unit:base()
			if base and base.set_color_by_theme then
				base:set_color_by_theme("player")
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/units/weapons/weaponflashlight" then
	local init_flash_cbk = WeaponFlashLight.init
	local update_flash_cbk = WeaponFlashLight.update
	function WeaponFlashLight:init(unit)
		init_flash_cbk(self, unit)
		local angle = WolfHUD.settings.flashlight_angle or 100 --Angle/width of beam, 0-160 (default 60)
		local range = (WolfHUD.settings.flashlight_range * 100) or 2000 --Range of beam, 0+ (default 1000 -> 10m)
		self._light:set_spot_angle_end(math.clamp(angle, 0, 160))
		self._light:set_far_range(range)
	end
	
	function WeaponFlashLight:update(unit, t, dt)
		update_flash_cbk(self, unit, t, dt)
		if WolfHUD and not self._is_haunted then
			self._light:set_spot_angle_end(math.clamp(WolfHUD.settings.flashlight_angle, 0, 160))
			self._light:set_far_range((WolfHUD.settings.flashlight_range * 100))
		end
	end

elseif string.lower(RequiredScript) == "lib/units/weapons/newraycastweaponbase" then 
	if not _NewRaycastWeaponBase_on_equip then _NewRaycastWeaponBase_on_equip = NewRaycastWeaponBase.on_equip end
	
	function NewRaycastWeaponBase:on_equip()
		_NewRaycastWeaponBase_on_equip(self)
		if WolfHUD and not WolfHUD.settings.laser_autoon then 
			self._has_laser = false 
		end
		if self._has_gadget and self._has_laser == nil and (managers.weapon_factory and tweak_data and tweak_data.weapon and tweak_data.weapon.factory) then
			local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint)
			for _, id in pairs(gadgets) do
				local part_data = tweak_data.weapon.factory.parts[id]
				if part_data and (part_data.sub_type == "laser" or part_data.type == "grip") then
					self._has_laser = true
					break
				else
					self._has_laser = false
				end
			end
		end
		self:set_gadget_on(self._stored_gadget_on or (self._has_laser and 1 or 0), false)
	end

	if not _NewRaycastWeaponBase_toggle_gadget then _NewRaycastWeaponBase_toggle_gadget = NewRaycastWeaponBase.toggle_gadget end
	function NewRaycastWeaponBase:toggle_gadget()
		if _NewRaycastWeaponBase_toggle_gadget(self) then
			self._stored_gadget_on = (not WolfHUD or WolfHUD.settings.laser_remember_state) and self._gadget_on
			return true
		end
	end
end