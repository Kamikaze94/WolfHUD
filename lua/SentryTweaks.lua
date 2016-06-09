if RequiredScript == "lib/units/weapons/sentrygunweapon" then
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
				laser_theme = "player_sentry"
				if Network:is_server() and managers.player:has_category_upgrade("sentry_gun", "ap_bullets") then
					enable_ap = true
				end
			else
				laser_theme = "default_sentry"
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
			local add_contour = self._use_armor_piercing and self._unit:base():ap_contour_id() or self._unit:base():standard_contour_id()
			self._unit:base():set_contour(add_contour)
		end
	end
end