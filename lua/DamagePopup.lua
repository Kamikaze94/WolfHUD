if RequiredScript == "lib/units/enemies/cop/copdamage" then
	CopDamage._popup_fade_t = WolfHUD:getSetting("dmg_popup_time", "number")
	CopDamage._popup_offset = Vector3(10, 10, 20)
	CopDamage._popup_fade_distance = Vector3(0, 0, 30)
	CopDamage._popup_headshot_color = WolfHUD:getSetting("dmg_popup_headshot_color", "color")
	CopDamage._popup_color = WolfHUD:getSetting("dmg_popup_color", "color")
	
	local _on_damage_received_original = CopDamage._on_damage_received
	function CopDamage:_on_damage_received(data, ...)
		if WolfHUD:getSetting("show_dmg_popup", "boolean") then
			local player = managers.player:player_unit()
			if data.damage > 0.09 and alive(data.attacker_unit) and alive(player) and (data.attacker_unit == player or data.attacker_unit:base()._thrower_unit == player) then
				local headshot = self._head_body_name and data.col_ray and data.col_ray.body and data.col_ray.body:name() == self._ids_head_body_name
				self:show_popup(data.damage, self._dead, headshot)
			end
		end
		return _on_damage_received_original(self, data, ...)
	end
	
	function CopDamage:show_popup(damage, dead, headshot)
		if managers.waypoints then
			local id = "damage_wp_" .. tostring(self._unit:key())
			local waypoint = managers.waypoints:get_waypoint(id)
			if waypoint and not waypoint:is_deleted() then
				self._dmg_value = self._dmg_value + (damage * 10)
				managers.waypoints:set_waypoint_duration(id, "duration", CopDamage._popup_fade_t)
				managers.waypoints:set_waypoint_label(id, "label", math.floor(self._dmg_value))
				managers.waypoints:set_waypoint_setting(id, "color", headshot and CopDamage._popup_headshot_color or CopDamage._popup_color)
				managers.waypoints:set_waypoint_component_setting(id, "icon", "show", dead)
			else
				self._dmg_value = (damage * 10)
							
				local params = {
					unit = self._unit,
					offset = CopDamage._popup_offset,
					scale = 2,
					color = (headshot and CopDamage._popup_headshot_color or CopDamage._popup_color),
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
						initial_value = CopDamage._popup_fade_t,
						fade_duration = {
							start = 0,
							stop = 1,
							position = CopDamage._popup_fade_distance,
						},
					},
					component_order = { { "icon", "label" } , { "duration" } }
				}
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
			end
		end
	end
elseif RequiredScript == "lib/units/civilians/civiliandamage" then
	local _on_damage_received_original = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(data, ...)
		if WolfHUD:getSetting("show_dmg_popup", "boolean") then
			local player = managers.player:player_unit()
			if data.damage > 0.09 and alive(data.attacker_unit) and alive(player) and (data.attacker_unit == player or data.attacker_unit:base()._thrower_unit == player) then
				local headshot = data.col_ray and data.col_ray.body and data.col_ray.body:name() == Idstring("head")
				self:show_popup(data.damage, self._dead, headshot)
			end
		end
		return _on_damage_received_original(self, data, ...)
	end
end