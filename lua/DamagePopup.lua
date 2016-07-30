if CustomWaypoint and not EnemyDamageWaypoint then
	EnemyDamageWaypoint = class(CustomWaypoint)
	
	function EnemyDamageWaypoint:_arrange()
		local w = 0
		local h = 0
		
		for i, name in ipairs(self._component_order) do
			if self._settings[name].show then
				local component = self._components[name]
				
				if component:visible() then
					component:set_x(w)
					component:set_center_y(self._panel:h() / 2)
					w = w + component:w()
					h = math.max(h, component:h())
				end
			end
		end
		
		self._panel:set_w(w)
	end

	function EnemyDamageWaypoint:set_label(...)
		EnemyDamageWaypoint.super.set_label(self, ...)
		local _, _, w, _ = self._components.label:text_rect()
		self._components.label:set_w(w)
		self:_arrange()
	end
	
	function EnemyDamageWaypoint:_setup_label(...)
		EnemyDamageWaypoint.super._setup_label(self, ...)
		local _, _, w, _ = self._components["label"]:text_rect()
		self._components["label"]:set_w(w)
	end
	
	function EnemyDamageWaypoint:update(...)
		local tmp_unit = self._unit
		if self._unit and not alive(self._unit) then
			return self:delete()
		end
		local progress =  math.clamp(1 - (self._settings.duration.value / CopDamage._popup_fade_t), 0, 1)
		if self._unit then
			self._position = self._unit:movement():m_head_pos() + CopDamage._popup_offset + Vector3(0, 0, CopDamage._popup_fade_distance * progress)
			self._panel:set_alpha(1 - progress)
			self._unit = nil
		end
		EnemyDamageWaypoint.super.update(self, ...)
		self._unit = tmp_unit
	end
end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	CopDamage._popup_fade_t = WolfHUD:getSetting("dmg_popup_time", "number")
	CopDamage._popup_offset = Vector3(20, 20, 20)
	CopDamage._popup_fade_distance = 30
	CopDamage._popup_headshot_color = WolfHUD:getSetting("dmg_popup_headshot_color", "color")
	CopDamage._popup_color = WolfHUD:getSetting("dmg_popup_color", "color")
	
	local _on_damage_received_original = CopDamage._on_damage_received
	function CopDamage:_on_damage_received(data, ...)
		if WolfHUD:getSetting("show_dmg_popup", "boolean") then
			if data.damage > 0.09 and data.attacker_unit and alive(managers.player:player_unit()) and (data.attacker_unit == managers.player:player_unit() or data.attacker_unit:base()._thrower_unit == managers.player:player_unit()) then
				local headshot = self._head_body_name and data.col_ray and data.col_ray.body and data.col_ray.body:name() == self._ids_head_body_name
				self:show_popup(data.damage, self._dead, headshot)
			end
		end
		return _on_damage_received_original(self, data, ...)
	end
	
	function CopDamage:show_popup(damage, dead, headshot)
		if not EnemyDamageWaypoint then return end
		local id = tostring(self._unit:key())
		local waypoint = managers.waypoints:get_waypoint(id)
		if waypoint and not waypoint:is_deleted() then
			self._dmg_value = self._dmg_value + (damage * 10)
			managers.waypoints:set_waypoint_duration(id, CopDamage._popup_fade_t)
			managers.waypoints:set_waypoint_label(id, math.ceil(self._dmg_value))
			managers.waypoints:get_waypoint_component(id, "icon"):set_color(headshot and CopDamage._popup_headshot_color or CopDamage._popup_color)
			managers.waypoints:get_waypoint_component(id, "label"):set_color(headshot and CopDamage._popup_headshot_color or CopDamage._popup_color)
			managers.waypoints:set_waypoint_component_setting(id, "icon", "show", dead)
		else
			self._dmg_value = (damage * 10)
						
			local params = {
				unit = self._unit,
				on_minimap = false,
				scale = 2,
				color = (headshot and CopDamage._popup_headshot_color or CopDamage._popup_color),
				icon = { 
					show = dead, 
					scale = 2.1, 
					rescale_distance = { 
						start_distance = 500, 
						end_distance = 3000, 
						final_scale = 0.5 
					}, 
					texture = "guis/textures/pd2/risklevel_blackscreen", 
					texture_rect = {0, 0, 64, 64}
				},
				label = { 
					show = true, 
					text = math.ceil(self._dmg_value) 
				},
				visible_distance = { 
					min = 30, 
					max = 10000 
				},
				rescale_distance = { 
					start_distance = 500, 
					end_distance = 3000, 
					final_scale = 0.5 
				},
				duration = { initial_value = CopDamage._popup_fade_t	},
				component_order = { "icon", "label", "distance", "timer", "duration" }
			}
			
			managers.waypoints:add_waypoint(id, EnemyDamageWaypoint, params)
		end
	end
elseif RequiredScript == "lib/units/civilians/civiliandamage" then
	local _on_damage_received_original = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(data, ...)
		if WolfHUD:getSetting("show_dmg_popup", "boolean") then
			if data.damage > 0.09 and data.attacker_unit and alive(managers.player:player_unit()) and (data.attacker_unit == managers.player:player_unit() or data.attacker_unit:base()._thrower_unit == managers.player:player_unit()) then
				local headshot = data.col_ray and data.col_ray.body and data.col_ray.body:name() == Idstring("head")
				self:show_popup(data.damage, self._dead, headshot)
			end
		end
		return _on_damage_received_original(self, data, ...)
	end
end