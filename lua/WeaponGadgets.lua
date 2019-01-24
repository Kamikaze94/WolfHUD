local print_info = print_info or function(...) WolfHUD:print_log(string.format(...), "info") end

if RequiredScript == "lib/units/weapons/weapongadgetbase" then

	WeaponGadgetBase.SPAWNED_UNITS = {
		laser = {},
		flashlight = {},
	}

	function WeaponGadgetBase.update_theme_setting(gadget, theme, feature, setting, value)
		WeaponGadgetBase.THEME_SETTINGS[gadget][theme][feature][setting] = value

		for key, unit in pairs(WeaponGadgetBase.SPAWNED_UNITS[gadget]) do
			unit:base():refresh_themes()
		end
	end

	--TODO: These needs to be filled by default if no option menu is used
	WeaponGadgetBase.THEME_SETTINGS = {
		laser = WolfHUD:getSetting({"GADGETS", "laser"}, nil),
		flashlight = WolfHUD:getSetting({"GADGETS", "flashlight"}, nil)
	}

	local init_original = WeaponGadgetBase.init
	local destroy_original = WeaponGadgetBase.destroy

	function WeaponGadgetBase:init(...)
		init_original(self, ...)

		self.GADGET_TYPE = self.GADGET_TYPE or "unknown"
		if WeaponGadgetBase.SPAWNED_UNITS[self.GADGET_TYPE] then
			WeaponGadgetBase.SPAWNED_UNITS[self.GADGET_TYPE][self._unit:key()] = self._unit
		end
	end

	function WeaponGadgetBase:destroy(...)
		if WeaponGadgetBase.SPAWNED_UNITS[self.GADGET_TYPE] then
			WeaponGadgetBase.SPAWNED_UNITS[self.GADGET_TYPE][self._unit:key()] = nil
		end
		destroy_original(self, ...)
	end

	function WeaponGadgetBase:set_owner_unit(owner, is_akimbo)
		if alive(owner) then
			print_info("Setting %s unit %s owner (slot %d)", tostring(self.GADGET_TYPE), tostring(self._unit:key()), owner:slot())
			if managers.criminals:character_data_by_unit(owner) then
				self:_set_theme("team")
			elseif owner == managers.player:player_unit() then
				self:_set_theme("player")
			--elseif owner:in_slot(12) then
				--Sniper, theme set at unit creation
			--elseif owner:in_slot(25) or owner:in_slot(26) then
				--Sentry/Turret, theme switched during operation for turrets
				--local user_type = table.contains(managers.groupai:state():turrets() or {}, owner) and "turret" or "sentry"
			end
		end
	end

	function WeaponGadgetBase:refresh_themes()

	end

	function WeaponGadgetBase:get_theme(theme)
		if self._themes then
			if theme then
				return self._themes[theme]
			else
				return self._theme_type and self._themes[self._theme_type] or self._themes.default
			end
		end
	end

	function WeaponGadgetBase:_set_theme(theme)

	end

	function WeaponGadgetBase:_modify_color(color, intensity)

	end

	function WeaponGadgetBase:_update_effects(data, t, dt)
		if data then
			local color, intensity

			if data.rainbow then
				local r = t * 360 * data.rainbow.frequency
				color = Vector3((1 + math.sin(r + 0)) / 2, (1 + math.sin(r + 120)) / 2, (1 + math.sin(r + 240)) / 2)
			end

			if data.pulse then
				local r = 0.5 + 0.5 * math.sin(t * 180 * data.pulse.frequency)
				intensity = math.lerp(data.pulse.min, data.pulse.max, r)
			end

			if color or intensity then
				self:_modify_color(color, intensity)
			end
		end
	end

elseif RequiredScript == "lib/units/weapons/weaponlaser" then
	local init_original = WeaponLaser.init
	local update_original = WeaponLaser.update

	function WeaponLaser:init(...)
		init_original(self, ...)
		--self._brush = Draw:brush(self._brush_color or Color(0, 1, 0))
		self._theme_type = "player"
		self:refresh_themes()
	end

	function WeaponLaser:set_color(color)	--OVERWRITE
		self._custom_color = Vector3(color:unpack())

		self:refresh_themes()
	end

	function WeaponLaser:color()	--OVERWRITE
		local theme = self._themes[self._theme_type] or self._themes.default
		
		if theme and theme.brush then
			return Color(theme.brush:unpack())
		end

		return tweak_data.custom_colors.defaults.laser
	end

	function WeaponLaser:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)
		self:_update_effects(self._themes[self._theme_type], t, dt)
	end

	function WeaponLaser:set_color_by_theme(type)
		if not self._themes[type] then print_info("ERROR (WeaponLaser:set_color_by_theme): Attempting to set missing theme %s", tostring(type)) end

		self._theme_type = type
		self:_set_colors()
	end

	function WeaponLaser:refresh_themes()
		for theme, data in pairs(WeaponGadgetBase.THEME_SETTINGS.laser or {}) do
			local beam = data.beam.enabled and Vector3(data.beam.r, data.beam.g, data.beam.b) or self._custom_color or Vector3(tweak_data.custom_colors.defaults.laser:unpack())

			self._themes[theme] = {
				light = data.dot.match_beam and beam or Vector3(data.dot.r, data.dot.g, data.dot.b),
				glow = data.glow.match_beam and beam or Vector3(data.glow.r, data.glow.g, data.glow.b),
				brush = beam,
				alpha = { dot = data.dot.a, glow = data.glow.a, beam = data.beam.a },
				rainbow = data.beam.enabled and data.rainbow.enabled and {
					frequency = data.rainbow.frequency,
				},
				pulse = data.pulse.enabled and {
					min = data.pulse.min,
					max = data.pulse.max,
					frequency = data.pulse.frequency,
				},
			}
		end

		self._current_intensity = 1
		self:_set_theme(self._theme_type)
	end

	function WeaponLaser:_set_theme(theme_id)
		self:set_color_by_theme(theme_id)
	end

	function WeaponLaser:_modify_color(color, intensity)
		self._current_intensity = intensity or self._current_intensity
		self:_set_colors(color, color, color)
	end

	function WeaponLaser:_set_colors(light, glow, brush)
		local theme = self._themes[self._theme_type] or self._themes.default
		local alpha = theme and theme.alpha or { dot = 1, glow = 0.02, beam = 0.15 }

		mvector3.set(self._light_color, (light or theme.light) * 10 * alpha.dot * (self._current_intensity or 1))
		mvector3.set(self._light_glow_color, (glow or theme.glow) * 10 * alpha.glow * (self._current_intensity or 1))
		self._brush_color = Color((brush or theme.brush):unpack()):with_alpha(alpha.beam * (self._current_intensity or 1))

		self._light:set_color(self._light_color)
		self._light_glow:set_color(self._light_glow_color)
		self._brush:set_color(self._brush_color)
	end

elseif RequiredScript == "lib/units/weapons/weaponflashlight" then
	local init_original = WeaponFlashLight.init
	local update_original = WeaponFlashLight.update
	local set_color_original = WeaponFlashLight.set_color

	WeaponFlashLight._themes = {}

	function WeaponFlashLight:init(...)
		init_original(self, ...)
		self._theme_type = "player"
		self._intensity_modifier = 1
		self:refresh_themes()
	end

	function WeaponFlashLight:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)

		if not self:is_haunted() then
			self:_update_effects(self._themes[self._theme_type], t, dt)
		end
	end

	function WeaponFlashLight:set_color(color, ...)	--OVERWRITE
		if not self:is_haunted() then
			self._custom_color = Vector3(color:unpack())

			self:refresh_themes()
		end
	end

	function WeaponFlashLight:color()	--OVERWRITE
		local theme = self._themes[self._theme_type]
		
		if theme and theme.light then
			return Color(theme.light:unpack())
		end
	end

	function WeaponFlashLight:set_owner_unit(owner, is_akimbo)
		if is_akimbo then
			self._intensity_modifier = 0.5
		else
			self._intensity_modifier = 1
		end

		self.super.set_owner_unit(self, owner, is_akimbo)
	end

	function WeaponFlashLight:refresh_themes()
		for theme, data in pairs(WeaponGadgetBase.THEME_SETTINGS.flashlight or {}) do
			self._themes[theme] = {
				brightness = data.light.brightness,
				light = data.light.enabled and Vector3(data.light.r, data.light.g, data.light.b) or self._custom_color or Vector3(tweak_data.custom_colors.defaults.flashlight:unpack()),
				angle = data.light.angle,
				range = data.light.range * 100,
				rainbow = data.light.enabled and data.rainbow.enabled and {
					frequency = data.rainbow.frequency,
				},
				pulse = data.pulse.enabled and {
					min = data.pulse.min,
					max = data.pulse.max,
					frequency = data.pulse.frequency,
				}
			}
		end

		self._current_intensity = 1
		self:_set_theme(self._theme_type)
	end

	function WeaponFlashLight:_set_theme(theme)
		self._theme_type = theme

		if not self:is_haunted() then
			local theme = self._themes[self._theme_type]

			if theme then
				self:_set_colors(theme.light)
				self._light:set_spot_angle_end(theme.angle)
				self._light:set_far_range(theme.range)
			end
		end
	end

	function WeaponFlashLight:_modify_color(color, intensity)
		self._current_intensity = intensity or self._current_intensity
		self:_set_colors(color)
	end

	function WeaponFlashLight:_set_colors(light)
		local theme = self._themes[self._theme_type]
		local light = light or theme and theme.light
		
		if light then
			--self._light:set_color(light * (theme.brightness or 1) * (self._current_intensity or 1) * (self._intensity_modifier or 1))
			local light_color = Color(light.x, light.y, light.z) * (theme.brightness or 1) * (self._current_intensity or 1) * (self._intensity_modifier or 1)
			set_color_original(self, light_color)
		end
	end

elseif RequiredScript == "lib/units/weapons/raycastweaponbase" then

	local setup_original = RaycastWeaponBase.setup

	function RaycastWeaponBase:setup(...)
		setup_original(self, ...)
		self:_update_gadget_owner(self._gadgets or self._has_gadget)
	end

	function RaycastWeaponBase:_update_gadget_owner(gadgets)
		if gadgets then
			for _, id in ipairs(gadgets) do
				local base = self._parts[id] and alive(self._parts[id].unit) and self._parts[id].unit:base()
				if base and base.set_owner_unit then
					base:set_owner_unit(self._setup.user_unit, self.AKIMBO)
				end
			end
		end

		--if alive(self._second_gun) then
		--	local base = self._second_gun:base()
		--	base:_update_gadget_owner(managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", base._factory_id, base._blueprint))
		--end
	end

elseif RequiredScript == "lib/units/weapons/newnpcraycastweaponbase" then

	local setup_original = NewNPCRaycastWeaponBase.setup

	function NewNPCRaycastWeaponBase:setup(...)
		setup_original(self, ...)
		self:_update_gadget_owner(managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint))
	end

elseif RequiredScript == "lib/units/weapons/npcraycastweaponbase" then

	local set_laser_enabled_original = NPCRaycastWeaponBase.set_laser_enabled

	function NPCRaycastWeaponBase:set_laser_enabled(...)
		set_laser_enabled_original(self, ...)

		if alive(self._laser_unit) then
			self._laser_unit:base():set_owner_unit(self._setup.user_unit, self.AKIMBO)
		end
	end

elseif RequiredScript == "lib/units/weapons/sentrygunweapon" then

	local _set_laser_state_original = SentryGunWeapon._set_laser_state

	function SentryGunWeapon:_set_laser_state(...)
		_set_laser_state_original(self, ...)

		if alive(self._laser_unit) then
			self._laser_unit:base():set_owner_unit(self._unit, false)
		end
	end

end

-- Laser Auto On
if string.lower(RequiredScript) == "lib/units/weapons/newraycastweaponbase" then
	function NewRaycastWeaponBase:_setup_laser()
		if self._gadgets then
			for i, part_id in ipairs(self._gadgets) do
                local unit = self._parts[part_id] and self._parts[part_id].unit
				local base = unit and unit:base()
				if base and base.GADGET_TYPE and base.GADGET_TYPE == (WeaponLaser.GADGET_TYPE or "") then
					self:set_gadget_on(i or 0, false, self._gadgets)
					self._last_gadget_idx = self._gadget_on
					
					local owner = managers.player:player_unit()
					if owner then
						owner:inventory()._was_gadget_on = self._gadget_on	-- Prevent inventory from restoring wrong gadget state
						if owner and owner:network() then					-- Sync gadget state and laser color to other players
							owner:network():send("set_weapon_gadget_state", self._gadget_on)
							if base.color then
								local col = base:color() or Color(1, 0, 1, 0)
								owner:network():send("set_weapon_gadget_color", col.r * 255, col.g * 255, col.b * 255)
							end
						end
					end
					break
				end
			end
		end
	end

	local on_enabled_original = NewRaycastWeaponBase.on_enabled
	function NewRaycastWeaponBase:on_enabled(...)
		on_enabled_original(self, ...)

		if not self._init_laser_state and not self:is_npc() and self._assembly_complete and managers.player:current_state() == "standard" and WolfHUD:getSetting({"GADGETS", "LASER_AUTO_ON"}, true) then
			self:_setup_laser()
			self._init_laser_state = true
		end
	end
end

-- Rotated Secondary Sight
if string.lower(RequiredScript) == "lib/units/cameras/fpcameraplayerbase" then
	local clbk_stance_entered_original = FPCameraPlayerBase.clbk_stance_entered
	FPCameraPlayerBase.angled_sight_rotation = {
		wpn_fps_upg_o_45iron = Rotation(0, 0, -45),
		wpn_fps_upg_o_45rds = Rotation(0, 0, -45),
		wpn_fps_upg_o_45rds_v2 = Rotation(0, 0, -45),
	}
	FPCameraPlayerBase.angled_sight_translation = {
		-- Vector3(x, y, z) -- x = right, y = forward, z = upward
		m4 			= Vector3(-5, 9, -14),
		amcar 		= Vector3(-5, 9, -14),
		m16 		= Vector3(-5, 9, -14),
		ak74 		= Vector3(-5, 9, -14),
		akm 		= Vector3(-5, 9, -14),
		akm_gold 	= Vector3(-5, 9, -14),
		ak5 		= Vector3(-5, 9, -14),
		aug 		= Vector3(-5, 9, -14),
		g36 		= Vector3(-5, 9, -14),
		m14 		= Vector3(-5, 9, -14),
		s552 		= Vector3(-5, 9, -14),
		scar 		= Vector3(-5, 9, -14),
		fal 		= Vector3(-5, 9, -14),
		g3 			= Vector3(-5, 9, -14),
		galil 		= Vector3(-5, 9, -14),
		famas 		= Vector3(-5, 9, -14),
		l85a2 		= Vector3(-5, 9, -14),
		asval 		= Vector3(-5, 9, -14),
		vhs 		= Vector3(-5, 9, -14),
		sub2000 	= Vector3(-5, 9, -14),
		tecci 		= Vector3(-5, 9, -14),
		-- Sniper
		msr 		= Vector3(-14.8, 9, -8),
		m95 		= Vector3(-10.5, -8, -12),
		r93 		= Vector3(-12.5, 7, -11),
		model70 	= Vector3(-12.8, 10, -8),
		wa2000		= Vector3(-12, 8.8, -11.3),		--TODO: Reload Stock clipping...
		mosin		= Vector3(-10, 8, -9.5),
		desertfox 	= Vector3(-12, 8.8, -11.3),		-- TODO: Stock clipping on stop running...
		siltstone 	= Vector3(-12.8, 10, -8),		-- TODO: untested
	}

	function FPCameraPlayerBase:clbk_stance_entered(new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, ...)
		if self._want_rotated then
			self._saved_stance = self._saved_stance or {
				translation 	= stance_mod.translation,
				rotation 		= stance_mod.rotation
			}
			stance_mod = {
				rotation 	= FPCameraPlayerBase.angled_sight_rotation[self._sight_id] 			or Rotation(0, 0, -45),
				translation = FPCameraPlayerBase.angled_sight_translation[self._weapon_name] 	or Vector3(-13, 7, -12)
			}
		elseif self._saved_stance and self._want_restored then
			stance_mod = clone(self._saved_stance)
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

	function FPCameraPlayerBase:set_weapon_name(w_name, sight_id)
		self._weapon_name = w_name
		self._sight_id = sight_id
	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
	local _stance_entered_original = PlayerStandard._stance_entered
	local _check_action_weapon_gadget_original = PlayerStandard._check_action_weapon_gadget
	PlayerStandard.ANGELED_SIGHTS = {
		wpn_fps_upg_o_45iron = true,
		wpn_fps_upg_o_45rds = true,
        wpn_fps_upg_o_45rds_v2 = true,
	}

	function PlayerStandard:_stance_entered(...)
		local weapon_base = self._equipped_unit:base()
		local sight_id = weapon_base and weapon_base._second_sight_data and weapon_base._second_sight_data.part_id
		local rotate_weapon = WolfHUD:getSetting({"GADGETS", "SHOW_ANGELED_SIGHT"}, true) and sight_id and PlayerStandard.ANGELED_SIGHTS[sight_id]
		self._camera_unit:base():set_want_rotated(not self._state_data.in_steelsight and self._equipped_unit:base():is_second_sight_on() and not self:_is_reloading() and rotate_weapon)
		self._camera_unit:base():set_want_restored(not self._state_data.in_steelsight and (not self._equipped_unit:base():is_second_sight_on() or self:_is_reloading()) and rotate_weapon)
		self._camera_unit:base():set_weapon_name(weapon_base and weapon_base._name_id, sight_id)
		return _stance_entered_original(self, ...)
	end

	function PlayerStandard:_check_action_weapon_gadget(t, input, ...)
		local value = _check_action_weapon_gadget_original(self, t, input, ...)

		local weapon_base = self._equipped_unit:base()
		local sight_id = weapon_base and weapon_base._second_sight_data and weapon_base._second_sight_data.part_id
		if input.btn_weapon_gadget_press and sight_id and PlayerStandard.ANGELED_SIGHTS[sight_id] then
			self:_stance_entered()
		end

		return value
	end
end