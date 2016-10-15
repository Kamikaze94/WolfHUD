if string.lower(RequiredScript) == "lib/units/weapons/sentrygunweapon" then
	local old_setup = SentryGunWeapon.init
	local old_destroy = SentryGunWeapon.destroy
	
	function SentryGunWeapon:init(...)
		old_setup(self, ...)
		if tweak_data.blackmarket.deployables[self._unit:base():get_type()] then
			managers.enemy:add_delayed_clbk("Sentry_post_init_" .. tostring(self._unit:key()), callback(self, self, "post_init"), Application:time() + 0.1)
		end
	end
	
	function SentryGunWeapon:post_init()
		local enable_ap = false
		local laser_theme = "default_sentry"
		if self._unit:base():is_owner() then
			laser_theme = "player_sentry"
			enable_ap = managers.player:has_category_upgrade("sentry_gun", "ap_bullets")
		end
		self._laser_align = self._unit:get_object(Idstring("fire"))
		self:set_laser_enabled(laser_theme)
		
		if WolfHUD:getSetting("senty_auto_ap", "boolean") and enable_ap then
			if alive(self._fire_mode_unit) and alive(self._unit) then
				local firemode_interaction = self._fire_mode_unit:interaction()
				if firemode_interaction and firemode_interaction:can_interact(managers.player:player_unit()) then
					self:_switch_fire_mode()
					managers.network:session():send_to_peers_synched("sentrygun_sync_state", self._unit)	--clone(self._unit)
					self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
				end
			end
		end
	end
	
	function SentryGunWeapon:destroy(...)
		managers.enemy:remove_delayed_clbk("Sentry_post_init_" .. tostring(self._unit:key()))
		old_destroy(self, ...)
	end
elseif string.lower(RequiredScript) == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	local setup_original = ECMJammerBase.setup
	local contour_interaction_original = ECMJammerBase.contour_interaction
	local destroy_original = ECMJammerBase.destroy
	function ECMJammerBase:setup(...)
		setup_original(self, ...)
		if WolfHUD:getSetting("ecm_feedback_disabled_stealth", "boolean") and managers.groupai:state():whisper_mode() then
			local owner_unit = self:owner()
			local player_unit = managers.player:player_unit()
			if alive(owner_unit) and alive(player_unit) and owner_unit:key() == player_unit:key() then
				managers.gameinfo:register_listener("ECMContour_whisper_mode_listener" .. tostring(self._unit:key()), "whisper_mode", "change", callback(self, self, "_whisper_mode_change"))
			end
		end
	end
	
	function ECMJammerBase:contour_interaction(...)
		if not (managers.groupai:state():whisper_mode() and WolfHUD:getSetting("ecm_feedback_disabled_stealth", "boolean")) then
			contour_interaction_original(self, ...)
		end
	end
	
	function ECMJammerBase:destroy(...)
		managers.gameinfo:unregister_listener("ECMContour_whisper_mode_listener" .. tostring(self._unit:key()), "whisper_mode", "change")
		destroy_original(self, ...)
	end
	
	function ECMJammerBase:_whisper_mode_change(event, key, status)
		if not status then
			contour_interaction_original(self)
		end
	end
elseif string.lower(RequiredScript) == "lib/units/interactions/interactionext" then
	local ECMJammerInteaction_can_interact_original = ECMJammerInteractionExt.can_interact
	local ECMJammerInteraction_can_select_original = ECMJammerInteractionExt.can_select
	function ECMJammerInteractionExt:can_interact(...)
		if WolfHUD:getSetting("ecm_feedback_disabled_stealth", "boolean") and managers.groupai:state():whisper_mode() then
			return false
		end
		return ECMJammerInteaction_can_interact_original(self, ...)
	end
	
	function ECMJammerInteractionExt:can_select(...)
		if WolfHUD:getSetting("ecm_feedback_disabled_stealth", "boolean") and managers.groupai:state():whisper_mode() then
			return false
		end
		return ECMJammerInteraction_can_select_original(self, ...)
	end
end