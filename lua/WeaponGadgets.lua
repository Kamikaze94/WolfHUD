if string.lower(RequiredScript) == "lib/units/weapons/weaponlaser" then
	local init_original = WeaponLaser.init
	local update_original = WeaponLaser.update
	WeaponLaser.DEFINITIONS = {
		player = {	  					--Player
			color = WolfHUD:getSetting("laser_player", "color"),
			alpha = WolfHUD:getSetting("laser_player_alpha", "number"),
		},
		player_sentry = {	  			--Player Sentry Gun
			color = WolfHUD:getSetting("laser_player_sentry", "color"),
			alpha = WolfHUD:getSetting("laser_player_sentry_alpha", "number"),
		},
		default = {	 					--Team mates
			color = WolfHUD:getSetting("laser_teammates", "color"),
			alpha = WolfHUD:getSetting("laser_teammates_alpha", "number"),
		},
		default_sentry = {	 			--Team mates Sentry Gun
			color = WolfHUD:getSetting("laser_teammates_sentry", "color"),
			alpha = WolfHUD:getSetting("laser_teammates_sentry_alpha", "number"),
		},
		cop_sniper = {  				--Enemy snipers
			color = WolfHUD:getSetting("laser_sniper", "color"),
			alpha = WolfHUD:getSetting("laser_sniper_alpha", "number"),
		},
		turret_module_active = {		--SWAT turret standard
			color = WolfHUD:getSetting("laser_turret_active", "color"),
			alpha = WolfHUD:getSetting("laser_turret_alpha", "number"),
		},
		turret_module_rearming = {	  	--SWAT turret reloading
			color = WolfHUD:getSetting("laser_turret_reloading", "color"),
			alpha = WolfHUD:getSetting("laser_turret_alpha", "number"),
		},
		turret_module_mad = {   		--SWAT turret jammed
			color = WolfHUD:getSetting("laser_turret_jammed", "color"),
			alpha = WolfHUD:getSetting("laser_turret_alpha", "number"),
		},
	}
		
	WeaponLaser._suffix_map = {
		player = "player",
		player_sentry = "player_sentry",
		default = "teammates",
		default_sentry = "teammates_sentry",
		cop_sniper = "sniper",
		turret_module_active = "turret_active",
		turret_module_rearming = "turret_reloading",
		turret_module_mad = "turret_jammed"
	}
	
	if WolfHUD:getSetting("use_weaponlasers", "boolean") then   
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
				light = color * WolfHUD:getSetting("laser_light", "number"),
				glow = color / WolfHUD:getSetting("laser_glow", "number"),
				brush = color:with_alpha(alpha)
			}
		end
		
		function WeaponLaser:update(unit, t, ...)
			update_original(self, unit, t, ...)
			local theme = self._theme_type
			local suffix = self._suffix_map[theme]
			local col = Color.white
			if suffix then 
				if WolfHUD:getSetting("laser_" .. suffix, "string") == "rainbow" then
					local r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
					col = Color(r, g, b)
				else
					col = WolfHUD:getSetting("laser_" .. suffix, "color")
				end
				local alpha = 1
				if suffix == "turret_active" or suffix == "turret_reloading" or suffix == "turret_jammed" then
					alpha = WolfHUD:getSetting("laser_turret_alpha", "number")
				else
					alpha = WolfHUD:getSetting("laser_" .. suffix .. "_alpha", "number")
				end
				if self._themes[theme].brush == col:with_alpha(alpha) then return end
				self:update_theme(theme, col, alpha)
				self:set_color_by_theme(theme)
			else
				log("[WolfHUD] Trying to update unknown laser theme: " .. theme)
			end
		end

	end

elseif string.lower(RequiredScript) == "lib/units/weapons/weaponflashlight" then
	local init_flash_cbk = WeaponFlashLight.init
	local update_flash_cbk = WeaponFlashLight.update
	function WeaponFlashLight:init(...)
		init_flash_cbk(self, ...)
		local angle = WolfHUD:getSetting("flashlight_angle", "number") --Angle/width of beam, 0-160 (default 60)
		local range = (WolfHUD:getSetting("flashlight_range", "number") * 100) --Range of beam, 0+ (default 1000 -> 10m)
		self._light:set_spot_angle_end(math.clamp(angle, 0, 160))
		self._light:set_far_range(range)
	end
	
	function WeaponFlashLight:update(unit, t, dt, ...)
		update_flash_cbk(self, unit, t, dt, ...)
		if not self._is_haunted then
			local col = Color.white
			if WolfHUD:getSetting("flashlight_color", "string") == "rainbow" then
				local r, g, b = math.sin(135 * t + 0) / 2 + 0.5, math.sin(140 * t + 60) / 2 + 0.5, math.sin(145 * t + 120) / 2 + 0.5
				col = Color(r, g, b)
			else
				col = WolfHUD:getSetting("flashlight_color", "color")
			end
			self._light:set_spot_angle_end(math.clamp(WolfHUD:getSetting("flashlight_angle", "number"), 0, 160))
			self._light:set_far_range((WolfHUD:getSetting("flashlight_range", "number") * 100))
			self._light:set_multiplier(WolfHUD:getSetting("flashlight_mult", "number"))
			self._light:set_color(col)
		end
	end
	
elseif string.lower(RequiredScript) == "lib/units/weapons/newraycastweaponbase" then 
	
	function NewRaycastWeaponBase:_setup_laser()
		for id, part in pairs(self._parts) do
			local base = part.unit and part.unit:base()
			if base and base.set_color_by_theme then
				if WolfHUD:getSetting("use_weaponlasers", "boolean") then
					base:set_color_by_theme("player")
				end
				self._has_laser = WolfHUD:getSetting("laser_autoon", "boolean")
			end
		end
	end
	
	if not _NewRaycastWeaponBase_on_equip then _NewRaycastWeaponBase_on_equip = NewRaycastWeaponBase.on_equip end
	if not _NewRaycastWeaponBase_toggle_gadget then _NewRaycastWeaponBase_toggle_gadget = NewRaycastWeaponBase.toggle_gadget end
	
	function NewRaycastWeaponBase:on_equip(...)
		_NewRaycastWeaponBase_on_equip(self, ...)
		if self._has_gadget then
			self:_setup_laser()
			if alive(self._second_gun) then
				self._second_gun:base():_setup_laser()
			end
		end
		self:set_gadget_on(self._stored_gadget_on or (self._has_laser and 1 or 0), false)
	end

	function NewRaycastWeaponBase:toggle_gadget(...)
		if _NewRaycastWeaponBase_toggle_gadget(self, ...) then
			self._stored_gadget_on = (WolfHUD:getSetting("laser_remember_state", "boolean")) and self._gadget_on
			return true
		end
	end
	
elseif RequiredScript == "lib/units/weapons/shotgun/newshotgunbase" then
	
    function NewShotgunBase:_setup_laser()
        for id, part in pairs(self._parts) do
            local base = part.unit and part.unit:base()
            if base and base.set_color_by_theme then
                if WolfHUD:getSetting("use_weaponlasers", "boolean") then
					base:set_color_by_theme("player")
				end
				self._has_laser = WolfHUD:getSetting("laser_autoon", "boolean")
            end
        end
    end

	if not _NewShotgunBase_on_equip then _NewShotgunBase_on_equip = NewShotgunBase.on_equip end
    if not _NewShotgunBase_toggle_gadget then _NewShotgunBase_toggle_gadget = NewShotgunBase.toggle_gadget end

    function NewShotgunBase:on_equip(...)
        _NewShotgunBase_on_equip(self, ...)
        if self._has_gadget then
            self:_setup_laser()
        end
        self:set_gadget_on(self._stored_gadget_on or (self._has_laser and 1 or 0), false)
    end

    function NewShotgunBase:toggle_gadget(...)
        if _NewShotgunBase_toggle_gadget(self, ...) then
            self._stored_gadget_on = (WolfHUD:getSetting("laser_remember_state", "boolean")) and self._gadget_on or 0
            return true
        end
    end
elseif RequiredScript == "lib/units/cameras/fpcameraplayerbase" then
	local clbk_stance_entered_original = FPCameraPlayerBase.clbk_stance_entered
	function FPCameraPlayerBase:clbk_stance_entered(new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, ...)
		if self._want_rotated then
			self._saved_stance = self._saved_stance or {
				translation = (stance_mod.translation or Vector3()) + Vector3(),
				rotation = (stance_mod.rotation or Rotation()) * Rotation()
			}
			stance_mod.rotation = Rotation(0, 0, -45)
			stance_mod.translation = Vector3(-13, 7, -12)
		elseif self._saved_stance and self._want_restored then
			stance_mod = {
				translation = self._saved_stance.translation,
				rotation = self._saved_stance.rotation
			}
			self._saved_stance = nil
		end

		return clbk_stance_entered_original(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, ...)
	end
	
	function FPCameraPlayerBase:set_want_rotated(status)
		self._want_rotated = status
	end

	function FPCameraPlayerBase:set_want_restored(status)
		self._want_restored = status
	end
elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
	local _stance_entered_original = PlayerStandard._stance_entered
	PlayerStandard.ANGELED_SIGHTS = {
		wpn_fps_upg_o_45iron = true
	}
	
	function PlayerStandard:_stance_entered(...)
		local weapon_base = self._equipped_unit:base()
		local sight_id = weapon_base and weapon_base._second_sight_data and weapon_base._second_sight_data.part_id
		local rotate_weapon = WolfHUD:getSetting("show_angeled_sight", "boolean") and sight_id and PlayerStandard.ANGELED_SIGHTS[sight_id]
		self._camera_unit:base():set_want_rotated(not self._state_data.in_steelsight and self._equipped_unit:base():is_second_sight_on() and not self:_is_reloading() and rotate_weapon)
		self._camera_unit:base():set_want_restored(not self._state_data.in_steelsight and (not self._equipped_unit:base():is_second_sight_on() or self:_is_reloading()) and rotate_weapon)

		return _stance_entered_original(self, ...)
	end
end