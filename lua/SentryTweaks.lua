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
		local enable_ap = false
		local laser_theme
		if self._owner then
			self._laser_align = self._unit:get_object(Idstring("fire"))
			if self._owner == managers.player:player_unit() then
				laser_theme = "player"
				if Network:is_server() and managers.player:has_category_upgrade("sentry_gun", "ap_bullets") then
					enable_ap = true
				end
			else
				laser_theme = "default"
			end
			managers.enemy:add_delayed_clbk("Sentry_post_setup_" .. tostring(self._unit:key()), callback(self, self, "post_setup", {laser_theme, enable_ap}), Application:time() + 0.01)
		end
	end
	
	function SentryGunWeapon:post_setup(data)
		local laser_theme, enable_ap = unpack(data)
		if laser_theme then
			self:set_laser_enabled(laser_theme)
		end
		if enable_ap then
			self:_switch_fire_mode()
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