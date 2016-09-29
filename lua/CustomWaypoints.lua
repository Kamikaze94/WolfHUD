if RequiredScript == "lib/units/vehicles/vehicledrivingext" then
	
	local add_loot_original = VehicleDrivingExt.add_loot
	function VehicleDrivingExt:add_loot(...)
		-- Create a label, if the vehicle has none yet...
		if managers.hud and self._unit:unit_data() and not self._unit:unit_data().name_label_id then
			self._unit:unit_data().name_label_id = managers.hud:add_vehicle_name_label({unit = self._unit, name = self._tweak_data.name})
		end
		
		add_loot_original(self, ...)
	end
end

do return end
-- TODO: Add Options, add more possible waypoints?
if RequiredScript == "lib/managers/hudmanager" then
	local init_original = HUDManager.init

	function HUDManager:init(...)
		init_original(self, ...)
		
		if managers.gameinfo and managers.waypoints then
			for _, t in pairs({ "ammo_bag", "doc_bag", "body_bad", "grenade_crate" }) do
				managers.gameinfo:register_listener(t .. "_waypoint_listener", t, "set_active", callback(nil, _G, "custom_waypoint_bag_clbk", t))
				managers.gameinfo:register_listener(t .. "_waypoint_listener", t, "set_amount", callback(nil, _G, "custom_waypoint_bag_clbk", t))
				managers.gameinfo:register_listener(t .. "_waypoint_listener", t, "set_amount_offset", callback(nil, _G, "custom_waypoint_bag_clbk", t))
			end
			managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_active", callback(nil, _G, "custom_waypoint_sentry_clbk"))
			managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_ammo_ratio", callback(nil, _G, "custom_waypoint_sentry_clbk"))
			
			managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_active", callback(nil, _G, "custom_waypoint_timer_clbk"))
			managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "update", callback(nil, _G, "custom_waypoint_timer_clbk"))
			managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_jammed", callback(nil, _G, "custom_waypoint_timer_clbk"))
			managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_powered", callback(nil, _G, "custom_waypoint_timer_clbk"))
			managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_upgrades", callback(nil, _G, "custom_waypoint_timer_clbk"))
		end
	end

	local function add_waypoint(id, unit, position, texture, texture_rect, text, color, visible_angle, visible_distance, fade_angle)
		local params = {
			unit = unit,
			position = position,
			color = color,
			alpha = 0.1,
			visible_angle = visible_angle,
			visible_distance = visible_distance or { max = 1000 },
			fade_angle = fade_angle,
			scale = 1.25,
			icon = { 
				type = "icon", 
				show = true, 
				texture = texture, 
				texture_rect = texture_rect 
			},
			label = { 
				type = "label", 
				show = true, 
				text = text },
			component_order = { { "icon", "label" } },
		}
		managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
	end

	function custom_waypoint_bag_clbk(type, event, key, data)
		if data.aggregate_members then return end
		
		local id = "bag_wp_" .. key
		
		if event == "set_active" then
			if data.active then
				local icon_map = {
					ammo_bag = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 1*64, 0, 64, 64 } },
					doc_bag = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 2*64, 7*64, 64, 64 } },
					body_bag = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 5*64, 11*64, 64, 64 } },
					grenade_crate = { texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = { 1*48, 0, 48, 48 } },
				}
				
				local amount = (data.amount or 0) + (data.amount_offset or 0)
				if type == "ammo_bag" then
					amount = amount * 100
				end
				add_waypoint(id, data.unit, data.position, icon_map[type].texture, icon_map[type].texture_rect, tostring(amount), Color.white, { max = 32.5 }, { max = 1000 }, {start_angle = 32.5, end_angle = 25, final_scale = 10})
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif event == "set_amount" or event == "set_amount_offset" then
			local amount = (data.amount or 0) + (data.amount_offset or 0)
			if type == "ammo_bag" then
				amount = amount * 100
			end
			managers.waypoints:set_waypoint_label(id, "label", math.round(amount))
		end
	end

	function custom_waypoint_sentry_clbk(event, key, data)
		local id = "sentry_wp_" .. key
		
		if event == "set_active" then
			if data.active then
				local text = string.format("%.0f%%", (data.ammo_ratio or 0) * 100)
				add_waypoint(id, data.unit, data.position, "guis/textures/pd2/skilltree/icons_atlas", {7*64, 5*64, 64, 64}, text, Color.red, { max = 20 }, { max = 2000 }, {start_angle = 20, end_angle = 12.5, final_scale = 10})
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif event == "set_ammo_ratio" then
			managers.waypoints:set_waypoint_label(id, string.format("%.0f%%", (data.ammo_ratio or 0) * 100))
		end
	end
	
	function custom_waypoint_timer_clbk(event, key, data)
		local id = "timer_wp_" .. key

		if event == "set_active" then
			if data.active then
				local icon_table = {
					drill = "pd2_drill",
					hack = "pd2_computer",
					saw = "wp_saw",
					timer = "pd2_computer",
					securitylock = "pd2_computer",
					digital = "pd2_computer",
				}
				local params = {
					unit = data.unit,
					offset = Vector3(0, 0, 30),
					on_minimap = true,
					icon = { 
						type = "icon", 
						show = true, 
						std_wp = icon_table[data.device_type or "timer"] 
					},
					timer = { 
						show = true, 
						show_offscreen = false,
						initial_value = 0,
						font = "fonts/font_medium_shadow_mf",
					},
					speed_upgrade = { 
						type = "icon", 
						show = false, 
						show_offscreen = false,
						texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
						color = Color.white,
						scale = 0.5,
						visible_distance = { max = 1500 },
					},
					noise_upgrade = { 
						type = "icon", 
						show = false, 
						show_offscreen = false,
						texture = "guis/textures/pd2/skilltree/drillgui_icon_silent",
						color = Color.white,
						scale = 0.5,
						visible_distance = { max = 1500 },
					},
					restart_upgrade = { 
						type = "icon", 
						show = false, 
						show_offscreen = false,
						texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter",
						color = Color.white,
						scale = 0.5,
						visible_distance = { max = 1500 },
					},
					component_order = { { "icon" }, { "timer" }, { "speed_upgrade", "noise_upgrade", "restart_upgrade" } },
				}
				
				if data.id == 132864 then --Meltdown timer
					MeltdownTemperatureWaypoint = MeltdownTemperatureWaypoint or class(CustomWaypoint)
					
					MeltdownTemperatureWaypoint.update_timer = function(self, value, t, dt)
						if self._settings.timer then
							self._settings.timer.value = value
							if self._components.timer and self._settings.timer.show then
								self._components.timer:set_text(string.format("%d/50", math.floor(value)))
								local _, _, w, _ = self._components.timer:text_rect()
								if w ~= self._components.timer:w() then
									self._components.timer:set_w(w)
									self:_arrange()
								end
							end
						end
					end
				
					managers.waypoints:add_waypoint(id, "MeltdownTemperatureWaypoint", params)
				else
					managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
				end
				
				if data.upgrades then
					custom_waypoint_timer_clbk("set_upgrades", key, data)
				end
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif event == "update" then
			managers.waypoints:set_waypoint_timer(id, data.timer_value)
		elseif event == "set_jammed" then
			if data.jammed then
				managers.waypoints:set_waypoint_setting(id, "color", Color('FF7575'))
				managers.waypoints:set_waypoint_setting(id, "show_offscreen", true)
			else
				managers.waypoints:set_waypoint_setting(id, "color", Color('FFFFFF'))
				managers.waypoints:set_waypoint_setting(id, "show_offscreen", false)
			end
		elseif event == "set_powered" then
			if data.powered then
				managers.waypoints:set_waypoint_setting(id, "color", Color('FFFFFF'))
				managers.waypoints:set_waypoint_setting(id, "show_offscreen", false)
			else
				managers.waypoints:set_waypoint_setting(id, "color", Color('FF7575'))
				managers.waypoints:set_waypoint_setting(id, "show_offscreen", true)
			end
		elseif event == "set_upgrades" then
			local speed_upgrade 	= math.clamp(data.upgrades.speed_upgrade_level or 0, 0, 2)
			local noise_upgrade 	= (data.upgrades.silent_drill and 1 or 0) + (data.upgrades.reduced_alert and 1 or 0)
			local restart_upgrade 	= ((data.upgrades.auto_repair_level_2 and data.upgrades.auto_repair_level_2 > 0) and 2 or (data.upgrades.auto_repair_level_1 and data.upgrades.auto_repair_level_1 > 0) and 1 or 0)
			managers.waypoints:set_waypoint_component_setting(id, "speed_upgrade", "show", (speed_upgrade > 0))
			managers.waypoints:set_waypoint_component_setting(id, "noise_upgrade", "show", (noise_upgrade > 0))
			managers.waypoints:set_waypoint_component_setting(id, "restart_upgrade", "show", (restart_upgrade > 0))
			managers.waypoints:set_waypoint_component_setting(id, "speed_upgrade", "color", (speed_upgrade > 1) and Color.yellow or Color.white)
			managers.waypoints:set_waypoint_component_setting(id, "noise_upgrade", "color", (noise_upgrade > 1) and Color.yellow or Color.white)
			managers.waypoints:set_waypoint_component_setting(id, "restart_upgrade", "color", (restart_upgrade > 1) and Color.yellow or Color.white)
		end
	end
	
	function HUDManager:add_waypoint(id, data, ...)
		local params = {
			unit = data.unit,
			position = data.position,
			scale = 2,
			alpha = 0.8,
			show_offscreen = true,
			radius_offscreen = data.radius,
			rescale_distance = { start_distance = 500, end_distance = 3000, final_scale = 0.5 },
			fade_angle = { start_angle = 10, end_angle = 3, final_scale = 0.7 },
			icon = {
				type = "icon",
				show = data.icon,
				show_offscreen = true,
				std_wp = data.icon or "wp_standard",
				texture_rect = {0, 0, 32, 32},
				alpha = 0.8,
			},
			distance = {
				show = data.distance,
				show_offscreen = false,
			},
			timer = {
				show = data.timer,
				show_offscreen = false,
				initial_value = data.timer or 0,
				auto_update = -1,
				pause = data.pause_timer,
			},
			arrow = {
				scale = 0.4,
				color = data.color,
			},
			component_order = { { "icon" }, { "timer", "distance" } }
		}
		managers.waypoints:add_waypoint(id, "CustomWaypoint", params, true)
	end
	
	function HUDManager:change_waypoint_icon(id, icon)
		local texture, rect = tweak_data.hud_icons:get_icon_data(icon, { 0, 0, 32, 32 })
		managers.waypoints:set_waypoint_icon(id, "icon", texture, rect)
	end
	
	function HUDManager:change_waypoint_icon_alpha(id, alpha)
		-- No need, "fade_angle" handles that job... ^^
	end
	
	function HUDManager:change_waypoint_arrow_color(id, color)
		managers.waypoints:set_waypoint_component_setting(id, "arrow", "color", color)
	end
	
	function HUDManager:remove_waypoint(id)
		managers.waypoints:remove_waypoint(id)
	end
	
	function HUDManager:set_waypoint_timer_pause(id, pause)
		managers.waypoints:set_waypoint_timer_pause(id, pause)
	end
	
	function HUDManager:get_waypoint_data(id)
		return managers.waypoints:get_waypoint(id)
	end
	
	function HUDManager:clear_waypoints()
		managers.waypoints:clear_waypoints()
	end
	
	function HUDManager:_update_waypoints(...) end
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	local _upd_criminal_suspicion_progress_original = GroupAIStateBase._upd_criminal_suspicion_progress
	function GroupAIStateBase:_upd_criminal_suspicion_progress(...)
		if self._ai_enabled then
			for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
				local unit = obs_susp_data.u_observer
				if managers.enemy:is_civilian(unit) then
					local waypoint_id = "susp1" .. tostring(obs_key)
					local texture, texture_rect, color, arrow_color
					if unit:anim_data().drop and WolfHUD:getSetting("show_pacified_civilians", "boolean") then
						if not obs_susp_data._subdued_civ then
							obs_susp_data._alerted_civ = nil
							obs_susp_data._subdued_civ = true
							color = Color(0, 0.71, 1)
							arrow_color = Color(0, 0.35, 0.5)
							texture = "guis/textures/menu_singletick"
						end
					elseif obs_susp_data.alerted then
						if not obs_susp_data._alerted_civ then
							obs_susp_data._subdued_civ = nil
							obs_susp_data._alerted_civ = true
							color = Color.white
							arrow_color = tweak_data.hud.detected_color
							texture = "guis/textures/hud_icons"
							texture_rect = { 479, 433, 32, 32 }
						end
					end
					if managers.waypoints and texture then
						managers.waypoints:set_waypoint_setting(waypoint_id, "color", color)
						managers.waypoints:set_waypoint_component_setting(waypoint_id, "arrow", "color", arrow_color)
						managers.waypoints:set_waypoint_icon(waypoint_id, "icon", texture, texture_rect)
					end
				end
			end
		end
		return _upd_criminal_suspicion_progress_original(self, ...)
	end
end