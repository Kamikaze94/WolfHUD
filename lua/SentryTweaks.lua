if RequiredScript == "lib/units/interactions/interactionext" then
	SentryGunInteractionExt.can_select = function(self, player)	--Hard Overwrite, cause of the messy implementation by Overkill
		local result = SentryGunInteractionExt.super.super.can_select(self, player)
		if not managers.player:has_equipment(self._unit:base():get_type()) then
			result = false
		end
		return result
	end
elseif RequiredScript == "lib/units/equipment/sentry_gun/sentrygundamage" then
	local _die_original = SentryGunDamage.die

	function SentryGunDamage:die()
		_die_original(self)
		if self._unit:base() and self._unit:base():is_owner() then
			self._unit:contour():_clear()
			self._unit:contour():add("deployable_disabled") 
		end
	end
elseif RequiredScript == "lib/units/weapons/sentrygunweapon" then
	local old_setup = SentryGunWeapon.setup
	local _switch_fire_original = SentryGunWeapon._switch_fire_mode
	local _setup_contour_original = SentryGunWeapon._setup_contour
	
	function SentryGunWeapon:setup(...)
		old_setup(self, ...)
		if self._owner == managers.player:player_unit() and managers.player:has_category_upgrade("sentry_gun", "ap_bullets") then
			managers.enemy:add_delayed_clbk("Auto_AP_" .. tostring(self._unit:key()), callback(self, self, "_switch_fire_mode"), Application:time() + 0.01)
		end
	end

	function SentryGunWeapon:_switch_fire_mode()
		_switch_fire_original(self)
		if self._unit:base() and self._unit:base():is_owner() then
			if self._use_armor_piercing then
				self._unit:contour():_clear()
				self._unit:contour():add("deployable_interactable")
			else
				self._unit:contour():_clear()
				self._unit:contour():add("deployable_active")
			end
		end
	end

	function SentryGunWeapon:_setup_contour()
		_setup_contour_original(self)
		if self._unit:base() and self._unit:base():is_owner() then
			if self:out_of_ammo() then
				self._unit:contour():_clear()
				self._unit:contour():add("deployable_disabled") 
			end
		end
	end
end