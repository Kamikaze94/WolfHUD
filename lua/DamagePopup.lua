if RequiredScript == "lib/units/enemies/cop/copdamage" then
	local _on_damage_received_original = CopDamage._on_damage_received

	function CopDamage:_on_damage_received(data, ...)
		self:_process_popup_damage(data)
		return _on_damage_received_original(self, data, ...)
	end

	function CopDamage:_process_popup_damage(attack_data)
		CopDamage.DMG_POPUP_SETTING = WolfHUD:getSetting({"DamagePopup", "DISPLAY_MODE"}, 2)

		local attacker = alive(attack_data.attacker_unit) and attack_data.attacker_unit
		local damage = tonumber(attack_data.damage) or 0

		if attacker and damage >= 0.1 and CopDamage.DMG_POPUP_SETTING > 1 then
			local killer

			if attacker:in_slot(3) or attacker:in_slot(5) then
				--Human team mate
				killer = attacker
			elseif attacker:in_slot(2) then
				--Player
				killer = attacker
			elseif attacker:in_slot(16) then
				--Bot/joker
				local key = tostring(attacker:key())
				local minion_data = managers.gameinfo and managers.gameinfo:get_minions(key)
				if minion_data then
					-- Joker
					killer = minion_data.owner and managers.criminals:character_unit_by_peer_id(minion_data.owner)
				else
					-- Bot
					killer = attacker
				end
			elseif attacker:in_slot(12) then
				--Enemy
			elseif attacker:in_slot(25)	then
				--Turret
				local owner = attacker:base():get_owner_id()
				if owner then
					killer =  managers.criminals:character_unit_by_peer_id(owner)
				end
			elseif attacker:base().thrower_unit then
				killer = attacker:base():thrower_unit()
			end

			if alive(killer) then
				local headshot = self._head_body_name and attack_data.col_ray and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
				if CopDamage.DMG_POPUP_SETTING == 2 then
					if killer:in_slot(2) then
						self:show_popup(damage, self._dead, headshot)
					end
				else
					local color_id = managers.criminals:character_color_id_by_unit(killer)
					if color_id then
						self:show_popup(damage, self._dead, headshot, color_id)
					end
				end
			end
		end
	end

	function CopDamage:show_popup(damage, dead, headshot, color_id)
		if managers.waypoints then
			local id = "damage_wp_" .. tostring(self._unit:key())
			local waypoint = managers.waypoints:get_waypoint(id)
			local waypoint_color = color_id and ((color_id == 5 and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "USE"}, false)) and WolfHUD:getColorSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "COLOR"}, Color.white) or tweak_data.chat_colors[color_id]) or WolfHUD:getColorSetting({"DamagePopup", headshot and "HEADSHOT_COLOR" or "COLOR"}, "yellow")
			local waypoint_duration = WolfHUD:getSetting({"DamagePopup", "DURATION"}, 3)
			if waypoint and not waypoint:is_deleted() then
				managers.waypoints:set_waypoint_duration(id, "duration", waypoint_duration)
				managers.waypoints:set_waypoint_label(id, "label", self:build_popup_text(damage, headshot))
				managers.waypoints:set_waypoint_setting(id, "color", waypoint_color)
				managers.waypoints:set_waypoint_component_setting(id, "icon", "show", dead)
			else
				local params = {
					unit = self._unit,
					offset = Vector3(10, 10, 20),
					scale = 2 * WolfHUD:getSetting({"DamagePopup", "SCALE"}, 1),
					color = waypoint_color,
					visible_distance = {
						min = 30,
						max = 10000
					},
					rescale_distance = {
						start_distance = 500,
						end_distance = 3000,
						final_scale = 0.5
					},
					fade_duration = {
						start = 0.5,
						stop = 1,
						alpha = true,
					},
					icon = {
						type = "icon",
						show = dead,
						scale = WolfHUD:getSetting({"DamagePopup", "SKULL_SCALE"}, 1.2),
						texture = "guis/textures/pd2/risklevel_blackscreen",
						texture_rect = {0, 0, 64, 64},
						blend_mode = "normal",
						on_minimap = false
					},
					label = {
						type = "label",
						show = true,
						text = self:build_popup_text(damage, headshot, true)
					},
					duration = {
						type = "duration",
						show = false,
						initial_value = waypoint_duration,
						fade_duration = {
							start = 0,
							stop = 1,
							position = Vector3(0, 0, 30),
						},
					},
					component_order = { WolfHUD:getSetting({"DamagePopup", "SKULL_ALIGN"}, 1) == 1 and { "icon", "label" } or { "label", "icon" } , { "duration" } }
				}
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
			end
		end
	end

	function CopDamage:build_popup_text(damage, headshot, is_new)
		self._dmg_value = (not is_new and self._dmg_value or 0) + (damage * 10)
		return math.floor(self._dmg_value) .. ((CopDamage.DMG_POPUP_SETTING == 3 and headshot) and "!" or "")
	end

elseif RequiredScript == "lib/units/civilians/civiliandamage" then
	local _on_damage_received_original = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(data, ...)
		CivilianDamage.super._process_popup_damage(self, data)
		return _on_damage_received_original(self, data, ...)
	end
end