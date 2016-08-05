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
		
		if WolfHUD:getSetting("senty_auto_ap", "boolean") and enable_ap then
			self:_switch_fire_mode()
			managers.network:session():send_to_peers_synched("sentrygun_sync_state", self._unit)
			self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
		end
	end
elseif RequiredScript == "lib/units/weapons/trip_mine/tripminebase" then
	local set_active_original = TripMineBase.set_active
	function TripMineBase:set_active(active, owner, ...)
		if WolfHUD:getSetting("tripmine_auto_sensor_stealth", "boolean") then
			if owner and owner == managers.player:player_unit() and managers.groupai:state():whisper_mode() then
				self._startup_armed = false
			end
		end
		set_active_original(self, active, owner, ...)
	end
elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	local setup_original = ECMJammerBase.setup
	local contour_interaction_original = ECMJammerBase.contour_interaction
	local destroy_original = ECMJammerBase.destroy
	function ECMJammerBase:setup(...)
		setup_original(self, ...)
		if WolfHUD:getSetting("ecm_feedback_disabled_stealth", "boolean") and managers.groupai:state():whisper_mode() then
			if self._owner_id and self._owner_id == managers.network:session():local_peer():id() then
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
elseif RequiredScript == "lib/units/interactions/interactionext" then
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
elseif RequiredScript == "lib/managers/blackmarketmanager" then
	local equipped_armor_original = BlackMarketManager.equipped_armor
	function BlackMarketManager:equipped_armor(chk_armor_kit, chk_player_state, ...)
	-- Fix for secondary Armor Kit, currently non-functional...
--[[
		if chk_player_state and managers.player:current_state() == "civilian" then
			return self._defaults.armor
		end
		if chk_armor_kit then
			local armor_kit_slot = (self:equipped_deployable(1) == "armor_kit") and 1 or (self:equipped_deployable(2) == "armor_kit") and 2
			if armor_kit_slot then
				if (not managers.player:has_equipment("armor_kit") or managers.player:has_deployable_left("armor_kit", armor_kit_slot)) then
					return self._defaults.armor
				end
			end
		end
]]
		return equipped_armor_original(self, chk_armor_kit, chk_player_state, ...)
	end
end