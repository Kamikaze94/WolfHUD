if RequiredScript == "lib/units/enemies/cop/copdamage" then
	local _on_damage_received_original = CopDamage._on_damage_received
	
	function CopDamage:_on_damage_received(data, ...)
		self:_process_popup_damage(data)
		return _on_damage_received_original(self, data, ...)
	end
	
	function CopDamage:_process_popup_damage(attack_data)
		if WolfHUD:getSetting("show_dmg_popup", "boolean") then
			local player = managers.player:player_unit()
			local damage = tonumber(attack_data.damage) or 0
			if damage >= 0.1 and alive(attack_data.attacker_unit) and alive(player) then
				if attack_data.attacker_unit:key() == player:key() or alive(attack_data.attacker_unit:base()._thrower_unit) and attack_data.attacker_unit:base()._thrower_unit:key() == player:key() then
					local headshot = self._head_body_name and attack_data.col_ray and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
					self:show_popup(damage, self._dead, headshot)
				end
			end
		end
	end
	
	function CopDamage:show_popup(damage, dead, headshot)
		if managers.waypoints then
			local id = "damage_wp_" .. tostring(self._unit:key())
			local waypoint = managers.waypoints:get_waypoint(id)
			local waypoint_color = WolfHUD:getSetting(headshot and "dmg_popup_headshot_color" or "dmg_popup_color", "color")
			local waypoint_duration = WolfHUD:getSetting("dmg_popup_time", "number")
			if waypoint and not waypoint:is_deleted() then
				self._dmg_value = self._dmg_value + (damage * 10)
				managers.waypoints:set_waypoint_duration(id, "duration", waypoint_duration)
				managers.waypoints:set_waypoint_label(id, "label", math.floor(self._dmg_value))
				managers.waypoints:set_waypoint_setting(id, "color", waypoint_color)
				managers.waypoints:set_waypoint_component_setting(id, "icon", "show", dead)
			else
				self._dmg_value = (damage * 10)
							
				local params = {
					unit = self._unit,
					offset = Vector3(10, 10, 20),
					scale = 2,
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
						scale = 1.2, 
						texture = "guis/textures/pd2/risklevel_blackscreen", 
						texture_rect = {0, 0, 64, 64},
						blend_mode = "normal",
						on_minimap = false
					},
					label = {
						type = "label",
						show = true, 
						text = math.floor(self._dmg_value) 
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
					component_order = { { "icon", "label" }, { "duration" } }
				}
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
			end
		end
	end
elseif RequiredScript == "lib/units/civilians/civiliandamage" then
	local _on_damage_received_original = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(data, ...)
		CivilianDamage.super._process_popup_damage(self, data)
		return _on_damage_received_original(self, data, ...)
	end
end