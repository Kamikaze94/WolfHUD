--[[
Waypoint settings:
	unit: 					(unit) 		A game unit to tie the waypoint to. If the unit is deleted from the game, the waypoint will be removed. Preference as follows: unit head position, unit interaction positions, unit position
	position: 				(vector)	A fixed 3D vector position to place the waypoint at
	offset: 				(vector) 	Offset vector from the Unit/position
	visible_through_walls:	(boolean)	Option to show/hide Waypoints, if the unit is not visible from the players position.
	mask					(various)	Slot mask for the visible_through_walls raycast. Can be a default slot_mask name string or a slotmask directly.
	show_offscreen: 		(boolean) 	Show this waypoint if it's outside your FOV (default: false)
	radius_offscreen: 		(number) 	Radius of the circle the waypoint is orbiting on while moving (default: 200)
	transition_duration: 	(number) 	Duration of the animation when a waypoint changes its state between on- and off-screen. (default: 0.3)
	scale: 					(number) 	Size scale of the waypoint (default 1)
	color:					(color)		Default color for all waypoint components. (default: white)
	alpha: 					(number) 	Default alpha value of the waypoint (default 1)
	hide_on_uninteractable: (boolean) 	Flag to determine whether a waypoint should be hidden if the associated unit has an interaction and the interaction is currently blocked (e.g. hide a crowbar waypoint if you already have a crowbar)
	visible_angle: 			(table) 	"min"/"max" 	(number)	values for viewing angle for which the waypoint should be visible
	visible_distance: 		(table) 	"min"/"max" 	(number)	values for a distance range for which the waypoint should be visible
	fade_angle: 			(table) 	"min"/"max" 	(number)	angles and final alpha values for waypoint fading based on viewing angle
										"final_scale" 	(number)	alpha to reach on maximum angle
	rescale_distance: 		(table) 	"min"/"max"		(number)	distance and final scale values for waypoint rescaling based on distance
										"final_scale" 	(number)	multiplier to reach on maximum distance
	fade_duration: 			(table) 	"min"/"max" 	(number)	values to start fade (0-1),
										"alpha" 		(boolean)	for it to affect alpha of the whole waypoint,
										"color"			(table)		"start"/"stop"	(color)	Color for the whole waypoint on 0/100% progress. (Component color settings have higher priority)
										"position" 		(vector)	to change the position offset of the whole waypoint
	component_order: 		(table) 	row tables		(table)		Row definition of components (top-2-bottom).
																	column tables 		(table) 	Column definition of coponents by names (left-2-right).

Component settings:			(table)		Component definition as subtable of the Waypoint settings. the key will be that components name.
	type: 					(string)	Determines the component type (label/icon/distance/timer/duration)
	show: 					(boolean) 	Determines whether the component should be shown at all
	show_offscreen: 		(boolean) 	Show this waypoint if it's outside your FOV. (default: true, only active if waypoint is visible too)
	scale: 					(number) 	Size scale of the waypoint component, gets multiplied on default scale. (default 1)
	color:					(color)		The color for that components. If not set, it will use the waypoints default color.
	alpha: 					(number) 	The alpha value of that component. If not set, it will use the waypoints default alpha.
	font:					(string)	Font for that component. Icons excluded, for obvious reasons.
	visible_angle: 			(table) 	"min"/"max" 	(number)	values for viewing angle for which the waypoint should be visible
	visible_distance: 		(table) 	"min"/"max" 	(number)	values for a distance range for which the waypoint should be visible
	fade_angle: 			(table) 	"min"/"max" 	(number)	angles and final alpha values for waypoint fading based on viewing angle
										"final_scale" 	(number)	alpha to reach on maximum angle
	rescale_distance: 		(table) 	"min"/"max" 	(number)	distance and final scale values for waypoint rescaling based on distance
										"final_scale" 	(number)	multiplier to reach on maximum distance
	fade_duration: 			(table) 	"min"/"max" 	(number)	values to start fade (0-1),
										"alpha" 		(boolean)	for it to affect the components alpha,
										"color"			(table)		"start"/"stop"	(color)	Color for the Component on 0/100% progress.

Icon exclusive settings:
	texture: 				(string) 	Path to texture to use for icon
	texture_rect: 			(table) 	Bounding box to use for the icon texture. Containing {x, y, w, h}
	radial_image			(boolean)	Handle the Image as Radial Image (Red value of color determines how much of an angle of the image is visible)
	blend_mode				(string)	Determines the image blend mode, e.g. "normal", "add", "sub" (default: "add")
	std_wp: 				(string) 	As an alternative to texture/texture_rect, an ID to one of the predefined waypoint icons in the game tweak data (e.g. "wp_crowbar")
	on_minimap:				(boolean)	Show that icon on the Minimap (if that mod is installed)
	all_elevations:			(boolean)	Show icon on the Minimap, regardless of your elevation

Label exclusive settings:
	text: 					(string) 	Label text

Timer exclusive settings:
	initial_value: 			(number) 	Start value of the component (e.g. 30 for a waypoint duration of 30 seconds)
	auto_update: 			(-1/1) 		Determines whether timer should be updated internally by the script itself (and in the direction indicated by the sign), or manually updated
	pause: 					(number) 	Time the timer gets paused until it starts counting. Only working if auto_update is set.

Duration exclusive settings:
	initial_value: 			(number) 	Start value of the component (e.g. 30 for a waypoint duration of 30 seconds)

Special components:
	arrow		-- This component gets always created. It represents the small arrows shown for off-screen waypoints. It has all settings a general component has, no exclusive ones.
				-- Don't add it to the component_order table, nor give any of you components this name.

Last Note: Don't call any functions starting with "_" (or the update-functions) from the outside. Thanks!
]]
if RequiredScript == "lib/setups/setup" then

	local function format_time_string(value)
		local frmt_string

		if math.floor(value) > 60 then
			frmt_string = string.format("%d:%02d", math.floor(value / 60), math.floor(value % 60))
		elseif math.floor(value) > 9.9 then
			frmt_string = string.format("%d", math.floor(value))
		elseif value > 0 then
			frmt_string = string.format("%.1f", value)
		else
			frmt_string = string.format("%.1f", 0)
		end

		return frmt_string
	end

	local init_managers_original = Setup.init_managers

	function Setup:init_managers(managers, ...)
		init_managers_original(self, managers, ...)
		managers.waypoints = managers.waypoints or WaypointManager:new()
	end

	WaypointManager = WaypointManager or class()

	function WaypointManager:init()
		self._workspace = managers.gui_data and managers.gui_data:create_fullscreen_workspace()
		self._waypoints = {}
		self._pending_waypoints = {}
	end

	function WaypointManager:_check_pending_waypoints()
		for id, data in pairs(self._pending_waypoints) do
			self:add_waypoint(id, data.class, data.data, data.overwrite)
		end

		self._pending_waypoints = {}
	end

	function WaypointManager:update(t, dt)
		local cam = managers.viewport:get_current_camera()

		if alive(self._hud_panel) and alive(self._workspace) and cam then
			local cam_forward = Vector3()

			mrotation.y(managers.viewport:get_current_camera_rotation(), cam_forward)

			for id, wp in pairs(self._waypoints) do
				if wp:is_deleted() then
					wp:_clear()
					self._waypoints[id] = nil
				else
					wp:update(t, dt, cam, cam_forward, self._hud_panel, self._workspace)
				end

			end
		end
		self:_check_pending_waypoints()
	end

	function WaypointManager:add_waypoint(id, class, data, overwrite)
		self._hud_panel = self._hud_panel or managers.hud and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel

		if not self._hud_panel then
			self._pending_waypoints[id] = { class = class, data = data, overwrite = overwrite }
		elseif overwrite and self._waypoints[id] then
			self._waypoints[id]:delete()
			self._pending_waypoints[id] = { class = class, data = data, overwrite = overwrite }
		elseif not self._waypoints[id] then
			local item_class = type(class) == "string" and _G[class] or class
			self._waypoints[id] = item_class and item_class:new(id, self._hud_panel, data)
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
			self._waypoints[id]:delete()
		end
	end

	function WaypointManager:clear_waypoints()
		self._pending_waypoints = {}
		for id, wp in pairs(self._waypoints) do
			wp:delete()
		end
	end

	function WaypointManager:add_waypoint_component(id, name, data, order, overwrite)
		if self._pending_waypoints[id] then
			local pending_data = self._pending_waypoints[id].data
			if not pending_data[name] or overwrite then
				pending_data[name] = data
				if pending_data.component_order and order then
					local i, j = unpack(order)
					pending_data.component_order[i] = pending_data.component_order[i] or {}
					j = math.min(j, #pending_data.component_order[i] + 1)
					table.insert(pending_data.component_order[i], j, name)
				end
				self._pending_waypoints[id].data = pending_data
			end
		elseif self._waypoints[id] then
			self._waypoints[id]:add_component(name, data, order, overwrite)
		end
	end

	function WaypointManager:remove_waypoint_component(id, name)
		if self._pending_waypoints[id] then
			local pending_data = self._pending_waypoints[id].data
			if pending_data[name] then
				pending_data[name] = nil
				if pending_data.component_order then
					for i, vertical_order in ipairs(pending_data.component_order) do
						for j, component_name in ipairs(vertical_order) do
							if name == component_name then
								table.remove(vertical_order, j)
								break
							end
						end
					end
				end
				self._pending_waypoints[id].data = pending_data
			end
		elseif self._waypoints[id] then
			self._waypoints[id]:remove_component(name)
		end
	end

	function WaypointManager:set_waypoint_duration(id, name, value)
		if self._waypoints[id] then
			self._waypoints[id]:set_duration(name, value)
		end
	end

	function WaypointManager:set_waypoint_timer(id, name, value, auto_update)
		if self._waypoints[id] then
			self._waypoints[id]:set_timer(name, value, auto_update)
		end
	end

	function WaypointManager:set_waypoint_timer_pause(id, name, value)
		if self._waypoints[id] then
			self._waypoints[id]:set_timer_pause(name, value)
		end
	end

	function WaypointManager:set_waypoint_label(id, name, text)
		if self._waypoints[id] then
			self._waypoints[id]:set_label(name, text)
		end
	end

	function WaypointManager:set_waypoint_icon(id, name, texture, texture_rect)
		if self._waypoints[id] then
			self._waypoints[id]:set_icon(name, texture, texture_rect)
		end
	end

	function WaypointManager:set_waypoint_setting(id, setting, value)
		if self._waypoints[id] then
			self._waypoints[id]:set_setting(setting, value)
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
			w = 300,
			alpha = data.alpha or 1,
		})

		self._id = id
		self._unit = data.unit
		self._position = data.position
		self._visible_through_walls = (data.visible_through_walls ~= false)
		self._slot_mask = data.mask and (type(data.mask) == "string" and managers.slot:get_mask(data.mask) or data.mask) or (managers.slot:get_mask( 'bullet_impact_targets', 'pickups' ) - managers.slot:get_mask( 'criminals' ))
		self._hide_on_uninteractable = data.hide_on_uninteractable
		self._offset = data.offset or Vector3(0, 0, 0)
		self._base_size = 16
		self._base_scale = data.scale or 1
		self._deleted = false
		self._is_enabled = true	--For Minimap
		self._state = "on_screen"

		self._components = {}
		self._timer_components = {}
		self._duration_components = {}
		self._distance_components = {}
		self._component_order = data.component_order or {}		--Top to bottom, left to right (Don't add "arrow" to the component list...)
		self._settings = {
			show = true,
			show_offscreen = data.show_offscreen and true or false,
			radius_offscreen = data.radius_offscreen or 200,
			transition_duration = data.transition_duration or 0.3,
			color = data.color or Color.white,
			fade_duration = data.fade_duration or {},
			visible_angle = data.visible_angle or {},
			visible_distance = data.visible_distance or {},
			fade_angle = data.fade_angle or {},
			--rescale_distance = data.rescale_distance or {},	--Don't use this for main panel or things get ugly
			base_values = { alpha = data.alpha or 1 },
		}

		for component_name, component_data in pairs(data) do
			if type(component_data) == "table" and component_data.type then
				if not self:add_component(component_name, data, nil) then
					WolfHUD:print_log(string.format("Error while creating waypoint: %s", self._id), "error")
				end
			end
		end

		self:_setup_arrow(data, self._base_size, self._base_scale)

		self:_arrange()
	end

	function CustomWaypoint:_clear()
		for name, component in pairs(self._components) do
			if alive(component) then
				component:parent():remove(component)
			end
		end

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

	function CustomWaypoint:is_on_screen()
		return (self._state == "on_screen" or self._state == "transition_on_screen")
	end

	function CustomWaypoint:add_component(name, data, order, overwrite)
		if not data[name] then
			local component_data = clone(data)
			data = clone(self._settings)
			data[name] = component_data
		end

		if type(data[name]) == "table" and data[name].type then
			if self._components[name] or self._settings[name] then
				if overwrite then
					self:remove_component(name)
				else
					return false
				end
			end
			if data[name].type == "distance" then
				self:_setup_distance_component(name, data, self._base_size, self._base_scale)
			elseif data[name].type == "timer" then
				self:_setup_timer_component(name, data, self._base_size, self._base_scale)
			elseif data[name].type == "duration" then
				self:_setup_duration_component(name, data, self._base_size, self._base_scale)
			elseif data[name].type == "icon" then
				self:_setup_icon_component(name, data, self._base_size, self._base_scale)
			elseif data[name].type == "label" then
				self:_setup_label_component(name, data, self._base_size, self._base_scale)
			else
				return false
			end

			if order and type(order) == "table" and #order >= 2 then
				local i, j = unpack(order)
				self._component_order[i] = self._component_order[i] or {}
				j = math.min(j, #self._component_order[i] + 1)
				table.insert(self._component_order[i], j, name)
				self:_arrange()
			end

			return true
		end
	end

	function CustomWaypoint:remove_component(name)
		self._distance_components[name] = nil
		self._timer_components[name] = nil
		self._duration_components[name] = nil

		local component = self._components[name]
		if component then
			self._panel:remove(component)
		end

		self._settings[name] = nil

		for i, vertical_order in ipairs(self._component_order) do
			for j, component_name in ipairs(vertical_order) do
				if name == component_name then
					table.remove(vertical_order, j)
					self:_arrange()
					break
				end
			end
		end
	end

	function CustomWaypoint:get_component(name)
		return self._components[name]
	end

	function CustomWaypoint:set_label(name, text)
		if self._components[name] then
			self._components[name]:set_text(tostring(text))
			local _, _, w, _ = self._components[name]:text_rect()
			if w ~= self._components[name]:w() then
				self._components[name]:set_w(w)
				self:_arrange()
			end
		end
	end

	function CustomWaypoint:set_icon(name, texture, texture_rect, w_multiplier)
		if self._components[name] then
			if texture then
				self._components[name]:set_image(texture)
				local w_ratio
				if texture_rect then
					self._components[name]:set_texture_rect(unpack(texture_rect))
					w_ratio = w_multiplier or (texture_rect[3] / texture_rect[4])
				else
					w_ratio = w_multiplier or 1
				end
				self._settings[name].base_values.w_ratio = w_ratio
			end
		end
	end

	function CustomWaypoint:set_timer(name, value, auto_update)
		if self._settings[name] then
			if auto_update then
				self._settings[name].auto_update = auto_update
			end
			self:update_timer(name, value)
		end
	end

	function CustomWaypoint:set_timer_pause(name, value)
		if self._settings[name] then
			self._settings[name].pause = value
		end
	end

	function CustomWaypoint:set_duration(name, value)
		if self._settings[name] then
			self._settings[name].start_value = value
			self:update_duration(name, value)
		end
	end

	function CustomWaypoint:set_setting(setting, value)
		if self._settings then
			self._settings[setting] = value
		end
	end

	function CustomWaypoint:set_component_setting(component, setting, value)
		if self._settings[component] then
			self._settings[component][setting] = value
		end
	end

	function CustomWaypoint:update(t, dt, cam, cam_fwd, hud, workspace)
		local world_pos = Vector3()
		local screen_pos = Vector3()
		local offset = Vector3()
		local dir = Vector3()
		local dir_normalized = Vector3()
		mvector3.set(offset, self._offset)

		if self._unit and not alive(self._unit) then
			return self:delete()
		end

		self._position = self._unit and (self._unit:movement() and self._unit:movement():m_head_pos() or self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position()) or self._position

		for name, _ in pairs(self._duration_components) do
			if self._settings[name] and self._settings[name].value then
				self:update_duration(name, math.max(self._settings[name].value - dt, 0))

				if self._settings[name].fade_duration then
					local start, stop = self._settings[name].fade_duration.start or 0, self._settings[name].fade_duration.stop or 1
					local progress = math.clamp(1 - (self._settings[name].value / self._settings[name].start_value), 0, 1)
					progress = math.min(math.max(progress - start, 0) / (stop - start), 1)
					local fade_offset = self._settings[name].fade_duration.position or Vector3(0, 0, 0)
					mvector3.add(offset, fade_offset * progress)
					self._settings[name].progress = progress
				end

				if self._settings[name].value <= 0 then
					return self:delete()
				end
			end
		end

		for name, _ in pairs(self._timer_components) do
			if self._settings[name] and self._settings[name].auto_update ~= 0 and self._settings[name].value then
				if not self._settings[name].pause then
					self:update_timer(name, self._settings[name].value + self._settings[name].auto_update * dt)
				end
			end
		end

		local on_screen = true
		local is_enabled = true
		local dot = 0

		if not self._visible_through_walls then
			local raycast_position = self._position + self._offset / 2
			local r = World:raycast( "ray", cam:position(), raycast_position, "slot_mask", self._slot_mask or managers.slot:get_mask( 'explosion_targets'))
			is_enabled = (not r or not r.unit or type(r.unit) ~= "userdata" or self._unit and (self._unit:key() == r.unit:key()))
		end

		if is_enabled and self._hide_on_uninteractable and self._unit:interaction() then
			local player = managers.player:player_unit()
			is_enabled = alive(player) and self._unit:interaction()._active and self._unit:interaction():can_interact(player)
		end

		if HUDManager.HAS_MINIMAP and is_enabled ~= self._is_enabled then
			self._is_enabled = is_enabled
			managers.hud._hud_minimap:set_entity_enabled(self._id, is_enabled)
		end

		if is_enabled then
			mvector3.set(world_pos, self._position)
			mvector3.add(world_pos, offset)
			mvector3.set(screen_pos, workspace:world_to_screen(cam, world_pos))
			mvector3.set(dir, world_pos)
			mvector3.subtract(dir, cam:position())
			mvector3.set(dir_normalized, dir)
			mvector3.normalize(dir_normalized)
			dot = mvector3.dot(cam_fwd, dir_normalized)

			self:_update_distance(dir:length())

			on_screen = dot >= 0 and not hud:outside(mvector3.x(screen_pos), mvector3.y(screen_pos))

			if not on_screen then
				local radius = self._settings.radius_offscreen
				local panel_center_x, panel_center_y = hud:center()
				mvector3.set_static(dir, screen_pos.x - panel_center_x, screen_pos.y - panel_center_y, 0)
				mvector3.set(dir_normalized, dir)
				mvector3.normalize(dir_normalized)
				mvector3.set_static(screen_pos, panel_center_x + mvector3.x(dir_normalized) * radius, panel_center_y + mvector3.y(dir_normalized) * radius, 0)
			end
		end

		if is_enabled and self._state == (on_screen and "on_screen" or "off_screen") then
			self:_update_visuals(mvector3.x(screen_pos), mvector3.y(screen_pos), math.acos(dot), dir_normalized)
		elseif is_enabled and ( on_screen or self._settings.show_offscreen ) then
			if self._state == "on_screen" then
				self._state = "transition_off_screen"
				self._transition_time = self._settings.transition_duration
			elseif self._state == "off_screen" then
				self._state = "transition_on_screen"
				self._transition_time = self._settings.transition_duration
			end
			local x, y = self._panel:center()
			local x_diff, y_diff = mvector3.x(screen_pos) - x, mvector3.y(screen_pos) - y
			local x_move, y_move = x_diff / self._transition_time * dt + x, y_diff / self._transition_time * dt + y
			self._transition_time = self._transition_time - dt
			self:_update_visuals(x_move, y_move, math.acos(dot), dir_normalized)

			if self._transition_time <= 0 then
				self._transition_time = nil
				if self._state == "transition_on_screen" then
					self._state = "on_screen"
				elseif self._state == "transition_off_screen" then
					self._state = "off_screen"
				end
			end
		elseif self._panel:visible() then
			self._panel:hide()
			self._components.arrow:hide()
		end

	end

	function CustomWaypoint:update_timer(name, value)
		if self._settings[name] then
			self._settings[name].value = math.max(value, 0)
			if self._components[name] and self._settings[name].show then
				self:set_label(name, format_time_string(value))
			end
		end
	end

	function CustomWaypoint:update_duration(name, value)
		if self._settings[name] then
			self._settings[name].value = math.max(value, 0)
			if self._components[name] and self._settings[name].show then
				self:set_label(name, format_time_string(value))
			end
		end
	end

	function CustomWaypoint:_update_distance(value)
		self._distance = value
		for name, _ in pairs(self._distance_components) do
			if self._components[name] then
				if self._settings[name] and self._settings[name].show then
					local frmt = value >= 995 and "%.0fm" or "%.1fm"
					self:set_label(name, string.format(frmt, value / 100))
				end
			end
		end
	end

	function CustomWaypoint:_update_visuals(x, y, angle, arrow_direction)
		if self:_update_component_visuals(self._panel, self._settings, angle) then	--Main panel
			local rearrange = false
			if self._settings.arrow then
				self._settings.arrow.show = not self:is_on_screen()
			end

			for name, component in pairs(self._components) do
				if component and self._settings[name] then
					local visible, need_rearrange = self:_update_component_visuals(component, self._settings[name], angle)
					rearrange = rearrange or need_rearrange
				end
			end

			if rearrange then
				self:_arrange()
			end

			self._panel:set_center(x, y)

			if self._components.arrow and self._components.arrow:visible() then
				local angle = math.X:angle(arrow_direction) * math.sign(arrow_direction.y)
				self._components.arrow:set_rotation(angle)
				self._components.arrow:set_center(x + arrow_direction.x * (self._panel:w() + 3), y + arrow_direction.y * (self._panel:h() + 3))
			end
		elseif not self._settings.show_offscreen then
			self._state = "on_screen"
			self._components.arrow:hide()
		end

	end

	function CustomWaypoint:_update_component_visuals(component, data, angle)
		local rearrange = false

		if component and data.show and (self:is_on_screen() or data.show_offscreen) then
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

			if is_visible then
				if data.fade_duration then
					local progress = data.progress
					if not progress then
						progress = 0
						local component_count = 0
						for name, _ in pairs(self._duration_components) do
							if self._settings[name] and self._settings[name].progress then
								progress = progress + self._settings[name].progress
								component_count = component_count + 1
							end
						end
						progress = progress / component_count
					end
					if data.fade_duration.alpha then
						local alpha_mult = 1 - (progress or 0)
						data.alpha = alpha_mult * data.base_values.alpha
					end
					if data.fade_duration.color and data.fade_duration.color.start and data.fade_duration.color.stop then
						local color = math.lerp(data.fade_duration.color.start, data.fade_duration.color.stop, progress)
						data.color = color
					end
				end

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
								local _, _, w, _ = component:text_rect()
								if w ~= component:w() then
									component:set_w(w)
									rearrange = true
								end
							else
								component:set_w(new_size * data.base_values.w_ratio)
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
						data.alpha = data.base_values.alpha * scale
					end
				end

				local color = data.color or self._settings.color
				if color and component.color and color ~= component:color() then
					component:set_color(color)
				end

				local alpha = data.alpha or data.base_values.alpha
				if alpha and component.alpha and component:alpha() ~= alpha then
					component:set_alpha(alpha)
				end
			end

			if is_visible ~= component:visible() then
				component:set_visible(is_visible)
				rearrange = true
			end

			return is_visible, rearrange
		elseif component then
			local rearrange = component:visible()
			component:set_visible(false)
			return component:visible(), rearrange
		end
	end

	function CustomWaypoint:_setup_image_component(name, data, base_size, base_scale, base_panel)
		data[name] = data[name] or {}
		local scale = base_scale * (data[name].scale or 1)
		local color = data[name].color or data.color or Color.white
		local size = base_size * scale
		local alpha = data[name].alpha or 1
		local texture, texture_rect
		local show = data[name].show and true or false

		if data[name].std_wp then
			texture, texture_rect = tweak_data.hud_icons:get_icon_data(data[name].std_wp)
		else
			texture = data[name].texture
			texture_rect = data[name].texture_rect
		end
		local w_ratio = data.w_ratio or texture_rect and (texture_rect[3] / texture_rect[4]) or 1

		self._settings[name] = {
			show = show,
			show_offscreen = (data[name].show_offscreen ~= false) or false,
			base_values = { size = size, alpha = alpha, w_ratio = w_ratio },
			color = data[name].color,
			fade_duration = data[name].fade_duration or {},
			visible_angle = data[name].visible_angle or {},
			visible_distance = data[name].visible_distance or {},
			fade_angle = data[name].fade_angle or {},
			rescale_distance = data[name].rescale_distance or {},
		}

		self._components[name] = (base_panel or self._panel):bitmap({
			name = name,
			texture = texture,
			texture_rect = texture_rect,
			render_template = data[name].radial_image and "VertexColorTexturedRadial",
			color = color,
			w = size * w_ratio,
			h = size,
			alpha = alpha,
			visible = show,
			blend_mode = data[name].blend_mode or "add",
		})
	end

	function CustomWaypoint:_setup_arrow(data, base_size, base_scale)
		data.arrow = data.arrow or {}
		data.arrow.std_wp = "wp_arrow"
		data.arrow.alpha = 0.5
		data.arrow.show_offscreen = (data.arrow.show_offscreen ~= false)
		data.arrow.w_ratio = 2

		self:_setup_image_component("arrow", data, base_size, base_scale, self._panel:parent())

		self._components.arrow:set_rotation(270)
	end

	function CustomWaypoint:_setup_icon_component(name, data, base_size, base_scale)
		self:_setup_image_component(name, data, base_size, base_scale, self._panel)

		if HUDManager.HAS_MINIMAP and data[name].on_minimap then
			managers.hud._hud_minimap:add_entity(HUDMiniMapWaypointEntity, self._id, {
				unit = data.unit,
				position = data.position,
				texture = texture,
				texture_rect = texture_rect,
				color = color,
				same_elevation_only = not data[name].all_elevations,
			})
		end
	end

	function CustomWaypoint:_setup_text_component(name, data, base_size, base_scale, base_panel)
		local component_data = data[name] or {}
		local scale = base_scale * (component_data.scale or data.text_scale or 1)
		local color = component_data.color or data.text_color or data.color or Color.white
		local size = base_size * scale
		local alpha = component_data.alpha or 1
		local show = component_data.show and true or false

		self._settings[name] = {
			show = show,
			show_offscreen = component_data.show_offscreen and true or false,
			base_values = { size = size, alpha = alpha, font_size = size * 0.95 },
			color = component_data.color,
			fade_duration = component_data.fade_duration or {},
			visible_angle = component_data.visible_angle or {},
			visible_distance = component_data.visible_distance or {},
			fade_angle = component_data.fade_angle or {},
			rescale_distance = component_data.rescale_distance or {},
		}
		self._components[name] = base_panel:text({
			name = name,
			text = component_data.text and tostring(component_data.text) or "",
			color = color,
			font = component_data.font or data.text_font or tweak_data.hud.medium_font_noshadow,
			font_size = size * 0.95,
			align = "left",
			vertical = "center",
			w = size * 3,
			h = size,
			alpha = alpha,
			visible = show,
		})

		local _, _, w, _ = self._components[name]:text_rect()
		if w ~= self._components[name]:w() then
			self._components[name]:set_w(w)
			self:_arrange()
		end
	end

	function CustomWaypoint:_setup_label_component(name, data, base_size, base_scale)
		self:_setup_text_component(name, data, base_size, base_scale, self._panel)
	end

	function CustomWaypoint:_setup_distance_component(name, data, base_size, base_scale)
		self:_setup_text_component(name, data, base_size, base_scale, self._panel)
		self._distance_components[name] = true
	end

	function CustomWaypoint:_setup_timer_component(name, data, base_size, base_scale)
		self:_setup_text_component(name, data, base_size, base_scale, self._panel)
		self._settings[name].value = data[name] and (data[name].initial_value or 0)
		self._settings[name].auto_update = data[name] and data[name].auto_update or 0
		self._settings[name].pause = data[name] and data[name].pause or false
		self._timer_components[name] = true
	end

	function CustomWaypoint:_setup_duration_component(name, data, base_size, base_scale)
		self:_setup_text_component(name, data, base_size, base_scale, self._panel)
		self._settings[name].start_value = data[name] and data[name].initial_value
		self._settings[name].value = self._settings[name].start_value
		self._duration_components[name] = true
	end

	function CustomWaypoint:_arrange()
		local MARGIN = 3
		local w = 0
		local h = 0
		local w_rows = {}
		local h_rows = {}

		for i, vertical_order in ipairs(self._component_order) do

			local w_row = 0
			local h_row = 0

			for j = 1, #vertical_order do
				local name = vertical_order[j]
				local component = name and self._components[name]

				if component and component:visible() then
					component:set_y(h)
					component:set_x(w_row)
					w_row = w_row + MARGIN + component:w()
					h_row = math.max(h_row, component:h())
				end
			end

			table.insert(w_rows, w_row)
			table.insert(h_rows, h_row)

			h = h + h_row
			w = math.max(w, w_row)
		end

		for i, vertical_order in ipairs(self._component_order) do
			for j = 1, #vertical_order do
				local name = vertical_order[j]
				local component = self._components[name]
				if component and component:visible() then
					local row_w, row_h = w_rows[i] or component:w(), h_rows[i] or component:h()

					component:set_x(math.ceil(component:x() + (w - row_w) / 2))
					component:set_y(math.ceil(component:y() + (row_h - component:h()) / 2))
				end
			end
		end

		if self._panel:w() ~= w or self._panel:h() ~= h then
			self._panel:set_size(w, h)
		end
	end

end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	local init_original = HUDManager.init
	local update_original = HUDManager.update

	function HUDManager:init(...)
		init_original(self, ...)
		managers.waypoints:_check_pending_waypoints()
	end

	function HUDManager:update(t, dt, ...)
		managers.waypoints:update(t, dt)
		return update_original(self, t, dt, ...)
	end

end
