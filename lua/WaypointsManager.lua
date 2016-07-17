if RequiredScript == "lib/setups/setup" then
	
	local init_managers_original = Setup.init_managers

	function Setup:init_managers(managers, ...)
		managers.waypoints = managers.waypoints or WaypointManager:new()
		init_managers_original(self, managers, ...)
	end


	WaypointManager = WaypointManager or class()
	
	function WaypointManager:init()
		self._waypoints = {}
		self._pending_waypoints = {}
	end
	
	function WaypointManager:check_pending_waypoints()
		for id, data in pairs(self._pending_waypoints) do
			self:add_waypoint(id, data.data, data.overwrite)
		end
		
		self._pending_waypoints = {}
	end
	
	function WaypointManager:update(t, dt)
		local cam = managers.viewport:get_current_camera()
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel
		local workspace = managers.hud:get_fullscreen_workspace()
		
		if cam and hud then
			local to_delete = {}
			local cam_forward = Vector3()

			mrotation.y(managers.viewport:get_current_camera_rotation(), cam_forward)
			
			for id, wp in pairs(self._waypoints) do
				wp:update(t, dt, cam, cam_forward, hud, workspace)
				
				if wp:is_deleted() then
					table.insert(to_delete, id)
				end
			end
			
			for i, id in ipairs(to_delete) do
				self:remove_waypoint(id)
			end
		end
	end
	
	function WaypointManager:add_waypoint(id, class, data, overwrite)
		if overwrite then
			self:remove_waypoint(id)
		end
		
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel
		
		if not hud then
			self._pending_waypoints[id] = { class = class, data = data, overwrite = overwrite }
		elseif not self._waypoints[id] then
			local item_class = type(class) == "string" and _G[class] or class
			self._waypoints[id] = item_class and item_class:new(id, hud, data)
		end
		
		return self._waypoints[id]
	end
	
	function WaypointManager:remove_waypoint(id)
		if self._pending_waypoints[id] then
			self._pending_waypoints[id] = nil
		elseif self._waypoints[id] then
			if HUDManager.HAS_MINIMAP then
				managers.hud._hud_minimap:delete_entity(id)
			end
			self._waypoints[id]:clear()
			self._waypoints[id] = nil
		end
	end
	
	function WaypointManager:set_waypoint_duration(id, value, t, dt)
		if self._waypoints[id] then
			self._waypoints[id]:update_duration(value, t, dt)
		end
	end
	
	function WaypointManager:set_waypoint_timer(id, value, t, dt)
		if self._waypoints[id] then
			self._waypoints[id]:update_timer(value, t, dt)
		end
	end
	
	function WaypointManager:set_waypoint_label(id, text)
		if self._waypoints[id] then
			self._waypoints[id]:set_label(text)
		end
	end
	
	function WaypointManager:set_waypoint_icon(id, texture, texture_rect)
		if self._waypoints[id] then
			self._waypoints[id]:set_icon(texture, texture_rect)
		end
	end
	
	function WaypointManager:set_waypoint_component_setting(id, component, setting, value)
		if self._waypoints[id] then
			self._waypoints[id]:set_component_setting(component, setting, value)
		end
	end
	
	function WaypointManager:get_waypoint(id)
		if self._waypoints[id] then
			return self._waypoints[id]
		end
	end
	
	function WaypointManager:get_waypoint_component(id, component)
		if self._waypoints[id] then
			return self._waypoints[id]:get_component(component)
		end
	end
	
	CustomWaypoint = CustomWaypoint or class()
	
	function CustomWaypoint:init(id, parent, data)
		self._panel = parent:panel({
			name = "wp_panel_" .. id,
			visible = false,
			w = 100,
			alpha = data.alpha or 1,
		})
		
		self._id = id
		self._unit = data.unit
		self._position = data.position
		self._deleted = false
		self._is_enabled = true	--For Minimap
		self._hide_on_uninteractable = data.hide_on_uninteractable
		
		self._components = {}
		self._component_order = data.component_order or { "label", "icon", "distance", "timer", "duration" }		--Top to bottom order
		self._settings = {
			show = true,
			visible_angle = data.visible_angle or {},
			visible_distance = data.visible_distance or {},
			fade_angle = data.fade_angle or {},
			--rescale_distance = data.rescale_distance or {},	--Don't use this for main panel or things get ugly
			base_values = { alpha = data.alpha or 1 },
		}
		
		local base_size = self._base_size or 16
		local base_scale = self._base_scale or data.scale or 1
		
		self:_setup_icon(data, base_size, base_scale)
		self:_setup_label(data, base_size, base_scale)
		self:_setup_distance(data, base_size, base_scale)
		self:_setup_timer(data, base_size, base_scale)
		self:_setup_duration(data, base_size, base_scale)
		
		self:_arrange()
	end
	
	function CustomWaypoint:clear()
		if alive(self._panel) then
			self._panel:parent():remove(self._panel)
		end
	end
	
	function CustomWaypoint:delete()
		self._deleted = true
	end
	
	function CustomWaypoint:is_deleted()
		return self._deleted
	end
	
	function CustomWaypoint:get_component(name)
		return self._components[name]
	end
	
	function CustomWaypoint:set_label(text)
		self._components.label:set_text(text)
	end
	
	function CustomWaypoint:set_icon(texture, texture_rect)
		self._components.icon:set_image(texture, texture_rect)
	end
	
	function CustomWaypoint:set_component_setting(component, setting, value)
		if self._settings[component] then
			self._settings[component][setting] = value
		end
	end
	
	function CustomWaypoint:update(t, dt, cam, cam_fwd, hud, workspace)
		local world_pos = Vector3()
		local screen_pos = Vector3()
		local dir = Vector3()
		local dir_normalized = Vector3()
		
		if self._unit and not alive(self._unit) then
			return self:delete()
		end
		
		if self._settings.duration.value then
			self:update_duration(self._settings.duration.value - dt)
			
			if self._settings.duration.value <= 0 then
				return self:delete()
			end
		end
		
		if self._settings.timer.auto_update and self._settings.timer.value then
			self:update_timer(self._settings.timer.value + self._settings.timer.auto_update * dt, t, dt)
		end
		
		local on_screen = true
		local is_enabled = true
		local dot = 0
		
		if self._hide_on_uninteractable and self._unit:interaction() then
			local player = managers.player:player_unit()
			is_enabled = alive(player) and self._unit:interaction():can_interact(player)
		end
		
		if HUDManager.HAS_MINIMAP and is_enabled ~= self._is_enabled then
			self._is_enabled = is_enabled
			managers.hud._hud_minimap:set_entity_enabled(self._id, is_enabled)
		end
		
		if is_enabled then
			self._position = self._unit and (self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position()) or self._position
			
			mvector3.set(world_pos, self._position)
			mvector3.set(screen_pos, workspace:world_to_screen(cam, world_pos))
			mvector3.set(dir, world_pos)
			mvector3.subtract(dir, managers.viewport:get_current_camera_position())
			mvector3.set(dir_normalized, dir)
			mvector3.normalize(dir_normalized)
			dot = mvector3.dot(cam_fwd, dir_normalized)
		
			self:_update_distance(dir:length(), t, dt)
		
			on_screen = dot >= 0 and not hud:outside(mvector3.x(screen_pos), mvector3.y(screen_pos))
		end
		
		if is_enabled and on_screen then
			self:_update_visuals(mvector3.x(screen_pos), mvector3.y(screen_pos), math.acos(dot))
		elseif self._panel:visible() then
			self._panel:hide()
		end

	end
	
	function CustomWaypoint:update_timer(value, t, dt)
		self._settings.timer.value = value
		if self._settings.timer.show then
			local frmt = value >= 9.95 and "%.0fs" or "%.1fs"
			self._components.timer:set_text(string.format(frmt, value))
		end
	end
	
	function CustomWaypoint:update_duration(value, t, dt)
		self._settings.duration.value = value
		if self._settings.duration.show then
			local frmt = value >= 9.95 and "%.0fs" or "%.1fs"
			self._components.duration:set_text(string.format(frmt, value))
		end
	end
	
	function CustomWaypoint:_update_distance(value, t, dt)
		self._distance = value
		if self._settings.distance.show then
			local frmt = value >= 995 and "%.0fm" or "%.1fm"
			self._components.distance:set_text(string.format(frmt, value / 100))
		end
	end
	
	function CustomWaypoint:_update_visuals(x, y, angle)
		local function update_component(component, data, angle)
			local rearrange = false
		
			if component and data.show then
				local is_visible = true
				local in_view = true
				local in_range = true
				
				if data.visible_distance then
					in_range =
						(not data.visible_distance.min or data.visible_distance.min <= self._distance) and 
						(not data.visible_distance.max or data.visible_distance.max >= self._distance)
				end
				
				if data.visible_angle then
					in_view =
						(not data.visible_angle.min or data.visible_angle.min <= angle) and 
						(not data.visible_angle.max or data.visible_angle.max >= angle)
				end
				
				is_visible = is_visible and in_range and in_view
				
				if is_visible ~= component:visible() then
					component:set_visible(is_visible)
					component:set_alpha(data.base_values.alpha)
					rearrange = true
				end
				
				if is_visible then
					if data.rescale_distance and data.rescale_distance.start_distance and data.rescale_distance.end_distance then
						local start = data.rescale_distance.start_distance
						local stop = data.rescale_distance.end_distance
						
						if start < self._distance then
							local final_scale = data.rescale_distance.final_scale or 0
							local scale = (self._distance >= stop) and final_scale or math.lerp(1, final_scale, (self._distance - start) / (stop - start))
							local new_size = math.round(data.base_values.size * scale)
							
							if component:h() ~= new_size then
								rearrange = true
								component:set_h(new_size)
								
								if data.base_values.font_size then
									component:set_font_size(data.base_values.font_size * scale)
								else
									component:set_w(new_size)
								end
							end
						end
					end
					
					if data.fade_angle and data.fade_angle.start_angle and data.fade_angle.end_angle then
						local start = data.fade_angle.start_angle
						local stop = data.fade_angle.end_angle
						
						if start > angle then
							local final_scale = data.fade_angle.final_scale or 0
							local scale = (stop >= angle) and final_scale or math.lerp(final_scale, 1, (angle - stop) / (start - stop))
							component:set_alpha(data.base_values.alpha * scale)
						end
					end
				end
				
				return is_visible, rearrange
			end
		end
		
		
		if update_component(self._panel, self._settings, angle) then	--Main panel
			local rearrange = false
			
			for name, component in pairs(self._components) do
				local visible, need_rearrange = update_component(component, self._settings[name], angle)
				rearrange = rearrange or need_rearrange
			end
			
			if rearrange then
				self:_arrange()
			end
			
			self._panel:set_center(x, y)
		end
		
	end
	
	function CustomWaypoint:_setup_icon(data, base_size, base_scale)
		data.icon = data.icon or {}
		local scale = base_scale * (data.icon.scale or 1)
		local color = data.icon.color or data.color or Color.white
		local size = base_size * scale
		local alpha = data.icon.alpha or 1
		local texture, texture_rect
		local show = data.icon.show and true or false
		
		if data.icon.std_wp then
			texture, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon.std_wp)
		else
			texture = data.icon.texture
			texture_rect = data.icon.texture_rect
		end
		
		self._settings.icon = {
			show = show,
			base_values = { size = size, alpha = alpha },
			visible_angle = data.icon.visible_angle or {},
			visible_distance = data.icon.visible_distance or {},
			fade_angle = data.icon.fade_angle or {},
			rescale_distance = data.icon.rescale_distance or {},
		}
		
		self._components.icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			color = color,
			w = size,
			h = size,
			alpha = alpha,
			visible = show,
		})
		
		if HUDManager.HAS_MINIMAP and data.on_minimap then
			managers.hud._hud_minimap:add_entity(HUDMiniMapWaypointEntity, self._id, { 
				unit = data.unit, 
				position = data.position, 
				texture = texture, 
				texture_rect = texture_rect, 
				color = color,
				same_elevation_only = not data.all_elevations,
			})
		end
	end
	
	function CustomWaypoint:_setup_text_component(name, data, base_size, base_scale)
		local component_data = data[name] or {}
		local scale = base_scale * (component_data.scale or data.text_scale or 1)
		local color = component_data.color or data.text_color or data.color or Color.white
		local size = base_size * scale
		local alpha = component_data.alpha or 1
		local show = component_data.show and true or false
		
		self._settings[name] = {
			show = show,
			base_values = { size = size, alpha = alpha, font_size = size * 0.95 },
			visible_angle = component_data.visible_angle or {},
			visible_distance = component_data.visible_distance or {},
			fade_angle = component_data.fade_angle or {},
			rescale_distance = component_data.rescale_distance or {},
		}
		
		self._components[name] = self._panel:text({
			name = name,
			text = component_data.text or "",
			color = color,
			font = component_data.font or data.text_font or tweak_data.hud.medium_font_noshadow,
			font_size = size * 0.95,
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = size,
			alpha = alpha,
			visible = show,
		})
	end
	
	function CustomWaypoint:_setup_label(data, base_size, base_scale)
		self:_setup_text_component("label", data, base_size, base_scale)
		self._components.label:set_text(tostring(data.label and data.label.text or ""))
	end
	
	function CustomWaypoint:_setup_distance(data, base_size, base_scale)
		self:_setup_text_component("distance", data, base_size, base_scale)
	end
	
	function CustomWaypoint:_setup_timer(data, base_size, base_scale)
		self:_setup_text_component("timer", data, base_size, base_scale)
		self._settings.timer.value = data.timer and (data.timer.initial_value or 0)
		self._settings.timer.auto_update = data.timer and data.timer.auto_update
	end
	
	function CustomWaypoint:_setup_duration(data, base_size, base_scale)
		self:_setup_text_component("duration", data, base_size, base_scale)
		self._settings.duration.value = data.duration and data.duration.initial_value
	end
	
	function CustomWaypoint:_arrange()
		local h = 0
		
		for i, name in ipairs(self._component_order) do
			if self._settings[name].show then
				local component = self._components[name]
				
				if component:visible() then
					component:set_y(h)
					component:set_center_x(self._panel:w() / 2)
					h = h + component:h()
				end
			end
		end
		
		self._panel:set_h(h)
	end
	
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	local init_original = HUDManager.init
	local update_original = HUDManager.update

	function HUDManager:init(...)
		init_original(self, ...)
		managers.waypoints:check_pending_waypoints()
	end
	
	function HUDManager:update(t, dt, ...)
		managers.waypoints:update(t, dt)
		return update_original(self, t, dt, ...)
	end
	
	function HUDManager:get_fullscreen_workspace()
		return self._fullscreen_workspace
	end
	
end