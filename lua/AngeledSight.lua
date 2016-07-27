if RequiredScript == "lib/units/cameras/fpcameraplayerbase" then
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

	function FPCameraPlayerBase:set_weapon_name(name)
		self._weapon_name = name
	end

elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
	local _stance_entered_original = PlayerStandard._stance_entered
	PlayerStandard.ANGELED_SIGHTS = {
		wpn_fps_upg_o_45iron = true
	}
	
	function PlayerStandard:_stance_entered(...)
		local weapon_base = self._equipped_unit:base()
		local sight_id = weapon_base and weapon_base._second_sight_data and weapon_base._second_sight_data.part_id
		local rotate_weapon = sight_id and PlayerStandard.ANGELED_SIGHTS[sight_id]
		self._camera_unit:base():set_want_rotated(not self._state_data.in_steelsight and self._equipped_unit:base():is_second_sight_on() and not self:_is_reloading() and rotate_weapon)
		self._camera_unit:base():set_want_restored(not self._state_data.in_steelsight and (not self._equipped_unit:base():is_second_sight_on() or self:_is_reloading()) and rotate_weapon)

		return _stance_entered_original(self, ...)
	end
end
