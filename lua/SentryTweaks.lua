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
		self._unit:contour():_clear()
		self._unit:contour():add("deployable_disabled") 
	end
elseif RequiredScript == "lib/units/weapons/sentrygunweapon" then
	local old_init = SentryGunWeapon.init
	local _switch_fire_original = SentryGunWeapon._switch_fire_mode
	local _setup_contour_original = SentryGunWeapon._setup_contour
	
	function SentryGunWeapon:init(unit)
		old_init(self, unit)
		if managers.player:has_category_upgrade("sentry_gun", "ap_bullets") then
			managers.enemy:add_delayed_clbk("Auto_AP_" .. tostring(unit:key()), callback(self, self, "_switch_fire_mode"), Application:time() + 0.01)
		end
	end

	function SentryGunWeapon:_switch_fire_mode()
		_switch_fire_original(self)
		if self._use_armor_piercing then
			self._unit:contour():_clear()
			self._unit:contour():add("deployable_interactable")
		else
			self._unit:contour():_clear()
			self._unit:contour():add("deployable_active")
		end
	end

	function SentryGunWeapon:_setup_contour()
		_setup_contour_original(self)
		if self:out_of_ammo() then
			self._unit:contour():_clear()
			self._unit:contour():add("deployable_disabled") 
		end
	end
end