if RequiredScript == "lib/units/weapons/sentrygunweapon" then
	local old_setup = SentryGunWeapon.init
	local _switch_fire_original = SentryGunWeapon._switch_fire_mode
	local _setup_contour_original = SentryGunWeapon._setup_contour
	
	function SentryGunWeapon:init(...)
		old_setup(self, ...)
		if tweak_data.blackmarket.deployables[self._unit:base():get_type()] then
			managers.enemy:add_delayed_clbk("Sentry_post_init_" .. tostring(self._unit:key()), callback(self, self, "post_init"), Application:time() + 0)
		end
	end
	
	function SentryGunWeapon:post_init()
		local enable_ap = false
		local laser_theme = ""
		if self._unit:base():is_owner() then
			laser_theme = "player_sentry"
			enable_ap = managers.player:has_category_upgrade("sentry_gun", "ap_bullets")
		else
			laser_theme = "default_sentry"
		end
		self._laser_align = self._unit:get_object(Idstring("fire"))
		self:set_laser_enabled(laser_theme)
		
		if enable_ap then
			self:_switch_fire_mode()
			managers.network:session():send_to_peers_synched("sentrygun_sync_state", self._unit)
			self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
		end
	end
end