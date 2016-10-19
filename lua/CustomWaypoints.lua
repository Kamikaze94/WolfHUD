if RequiredScript == "lib/managers/hudmanager" then
	local init_original = HUDManager.init

	HUDManager.CUSTOM_WAYPOINTS = {
		UPGRADE_COLORS = {
			[0] = Color.white:with_alpha(0),
			[1] = Color.white,
			[2] = Color.yellow,
			[3] = Color.red,
			[4] = Color.black,
		},
		TIMER = {
			ICON_MAP = {
				drill = "pd2_drill",
				hack = "pd2_computer",
				saw = "wp_saw",
				timer = "pd2_computer",
				securitylock = "pd2_computer",
				digital = "pd2_computer",
			},
			IGNORE = {
				[145557] = true,
				[145676] = true,
			},
		},
		EQUIPMENT = {
			ammo_bag 		= { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 1*64, 0, 64, 64 }, 						 offset = Vector3(0, 0, 15)  },
			doc_bag 		= { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 2*64, 7*64, 64, 64 }, 					 offset = Vector3(0, 0, 25)  },
			first_aid_kit 	= { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 2*64, 11*64, 64, 48 }, 					 offset = Vector3(0, 0, 20)  },
			body_bag 		= { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = { 5*64, 11*64, 64, 64 }, 					 offset = Vector3(0, 0, 25)  },
			grenade_crate 	= { texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = { 1*48, 0, 48, 48 }, offset = Vector3(0, 0, 20)  },
			UPGRADES = {
				ammo_bag = {
					bullet_storm 		= { texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = {4 * 80, 5 * 80, 80, 80} },
				},
				doc_bag = {
					damage_reduction 	= { texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = {0 * 80, 10 * 80, 80, 80} },
				},
				first_aid_kit = {
					damage_reduction 	= { texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = {1 * 80, 11 * 80, 80, 80} },
					auto_recovery 		= { texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = {2 * 80, 11 * 80, 80, 80} },
				},
			},
		},
		SPECIAL_EQUIPMENT = {
			ICON_MAP = {
				gen_pku_crowbar =					{ std_icon = "wp_crowbar"},
				pickup_keycard =					{ std_icon = "equipment_bank_manager_key", },
				pickup_hotel_room_keycard =			{ std_icon = "equipment_bank_manager_key", },
				--gage_assignment =					"equipment_money_bag",
				pickup_boards =						{ std_icon = "wp_planks"},
				stash_planks_pickup =				{ std_icon = "wp_planks"},
				muriatic_acid =						{ texture = "guis/textures/pd2/hud_pickups", texture_rect = {1 * 32, 1 * 32, 32, 32}, offset = Vector3(0, 0, 45) }, 
				hydrogen_chloride =					{ texture = "guis/textures/pd2/hud_pickups", texture_rect = {2 * 32, 1 * 32, 32, 32}, offset = Vector3(0, 0, 85) }, 
				caustic_soda =						{ texture = "guis/textures/pd2/hud_pickups", texture_rect = {3 * 32, 1 * 32, 32, 32}, offset = Vector3(0, 0, 50) }, 
				gen_pku_blow_torch =				{ std_icon = "equipment_blow_torch"},
				drk_pku_blow_torch = 				{ std_icon = "equipment_blow_torch"},
				hold_born_receive_item_blow_torch = { std_icon = "equipment_blow_torch"},
				thermite = 							{ std_icon = "equipment_thermite"},
				gasoline_engine = 					{ std_icon = "equipment_thermite"},
				gen_pku_thermite = 					{ std_icon = "equipment_thermite"},
				gen_pku_thermite_paste = 			{ std_icon = "equipment_thermite"},
				hold_take_gas_can = 				{ std_icon = "equipment_thermite"},
				gen_pku_thermite_paste_z_axis = 	{ std_icon = "equipment_thermite"},
				c4_consume = 						{ std_icon = "equipment_c4", 		x_ray = true, offset = Vector3(0, 0, 0) }
				--gasoline = 							{ std_icon = "equipment_thermite", 	x_ray = true, offset = Vector3(0, 0, 0) }
			},
		},
		MINIONS = {
			CHARACTER_NAMES = {
				[ "civilian" ] 					= "wolfhud_enemy_civilian",
				[ "civilian_female" ] 			= "wolfhud_enemy_civilian",
				[ "gangster" ] 					= "wolfhud_enemy_gangster",
				[ "biker" ] 					= "wolfhud_enemy_biker",
				[ "biker_escape" ] 				= "wolfhud_enemy_biker",
				[ "mobster" ] 					= "wolfhud_enemy_mobster",
				[ "security" ] 					= "wolfhud_enemy_security",
				[ "security_undominatable" ] 	= "wolfhud_enemy_security",
				[ "gensec" ] 					= "wolfhud_enemy_gensec",
				[ "cop" ] 						= "wolfhud_enemy_cop",
				[ "cop_female" ]				= "wolfhud_enemy_cop",
				[ "cop_scared" ]				= "wolfhud_enemy_cop",
				[ "fbi" ] 						= "wolfhud_enemy_fbi",
				[ "swat" ] 						= "wolfhud_enemy_swat",
				[ "heavy_swat" ] 				= "wolfhud_enemy_heavy_swat",
				[ "fbi_swat" ] 					= "wolfhud_enemy_swat",
				[ "fbi_heavy_swat" ] 			= "wolfhud_enemy_heavy_swat",
				[ "city_swat" ] 				= "wolfhud_enemy_city_swat",
				[ "shield" ] 					= "wolfhud_enemy_shield",
				[ "spooc" ] 					= "wolfhud_enemy_spook",
				[ "taser" ] 					= "wolfhud_enemy_taser",
				[ "sniper" ] 					= "wolfhud_enemy_sniper",
				[ "medic" ]						= "wolfhud_enemy_medic",
				[ "tank" ] 						= "wolfhud_enemy_tank",
				[ "tank_hw" ]					= "wolfhud_enemy_tank_hw",
				[ "phalanx_minion" ] 			= "wolfhud_enemy_phalanx_minion",
				[ "phalanx_vip" ] 				= "wolfhud_enemy_phalanx_vip",
				[ "swat_van_turret_module" ] 	= "wolfhud_enemy_swat_van",
				[ "ceiling_turret_module" ] 	= "wolfhud_enemy_ceiling_turret",
				[ "sentry_gun" ]				= "wolfhud_enemy_sentry_gun",
				[ "mobster_boss" ] 				= "wolfhud_enemy_mobster_boss",
				[ "chavez_boss" ]				= "wolfhud_enemy_chavez_boss",
				[ "biker_boss" ] 				= "wolfhud_enemy_biker_boss",
				[ "bank_manager" ] 				= "wolfhud_enemy_bank_manager",
				[ "inside_man" ] 				= "wolfhud_enemy_inside_man",
				[ "escort_undercover" ] 		= "wolfhud_enemy_escort_undercover",
				[ "drunk_pilot" ] 				= "wolfhud_enemy_drunk_pilot",
				[ "escort" ] 					= "wolfhud_enemy_escort",
				[ "boris" ]						= "wolfhud_enemy_boris",
				[ "old_hoxton_mission" ] 		= "wolfhud_enemy_old_hoxton_mission",
				[ "hector_boss" ] 				= "wolfhud_enemy_hector_boss",
				[ "hector_boss_no_armor" ] 		= "wolfhud_enemy_hector_boss_no_armor",
				[ "robbers_safehouse" ]			= "wolfhud_enemy_crew",
				[ "russian" ] 					= "menu_russian",
				[ "german" ] 					= "menu_german",
				[ "spanish" ] 					= "menu_spanish",
				[ "american" ] 					= "menu_american",
				[ "jowi" ] 						= "menu_jowi",
				[ "old_hoxton" ] 				= "menu_old_hoxton",
				[ "female_1" ] 					= "menu_female_1",
				[ "dragan" ] 					= "menu_dragan",
				[ "jacket" ] 					= "menu_jacket",
				[ "bonnie" ] 					= "menu_bonnie",
				[ "sokol" ] 					= "menu_sokol",
				[ "dragon" ] 					= "menu_dragon",
				[ "bodhi" ] 					= "menu_bodhi",
				[ "jimmy" ] 					= "menu_jimmy",
				[ "sydney" ] 					= "menu_sydney",
				[ "wild" ]						= "menu_wild",
			},
		},
	}
	
	function HUDManager:init(...)
		init_original(self, ...)
		
		self:setup_custom_waypoints()
	end

	function HUDManager:setup_custom_waypoints()
		if managers.gameinfo and managers.waypoints then
			local bag_equip_settings = {
				["ammo_bag"] 		= WolfHUD:getSetting("waypoints_show_ammo_bag", "boolean"),
				["doc_bag"] 		= WolfHUD:getSetting("waypoints_show_doc_bag", "boolean"),
				["body_bag"] 		= WolfHUD:getSetting("waypoints_show_body_bag", "boolean"),
				["grenade_crate"] 	= WolfHUD:getSetting("waypoints_show_grenade_crate", "boolean"),
				["first_aid_kit"] 	= WolfHUD:getSetting("waypoints_show_first_aid_kit", "boolean"),
			}
			for equip, enabled in pairs(bag_equip_settings) do
				if enabled then
					managers.gameinfo:register_listener(equip .. "_waypoint_listener", equip, "set_active", callback(self, self, "custom_waypoint_bag_clbk", equip))
					managers.gameinfo:register_listener(equip .. "_waypoint_listener", equip, "set_amount", callback(self, self, "custom_waypoint_bag_clbk", equip))
					managers.gameinfo:register_listener(equip .. "_waypoint_listener", equip, "set_amount_offset", callback(self, self, "custom_waypoint_bag_clbk", equip))
					managers.gameinfo:register_listener(equip .. "_waypoint_listener", equip, "set_owner", callback(self, self, "custom_waypoint_bag_clbk", equip))
					managers.gameinfo:register_listener(equip .. "_waypoint_listener", equip, "set_upgrades", callback(self, self, "custom_waypoint_bag_clbk", equip))
				end
			end
			
			if WolfHUD:getSetting("waypoints_show_sentries", "boolean") then
				managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_active", callback(self, self, "custom_waypoint_sentry_clbk"))
				managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_ammo_ratio", callback(self, self, "custom_waypoint_sentry_clbk"))
				managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_health_ratio", callback(self, self, "custom_waypoint_sentry_clbk"))
				managers.gameinfo:register_listener("sentry_waypoint_listener", "sentry", "set_owner", callback(self, self, "custom_waypoint_sentry_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_ecms", "boolean") then
				managers.gameinfo:register_listener("ecm_waypoint_listener", "ecm", "set_jammer_active", callback(self, self, "custom_waypoint_ecm_clbk"))
				managers.gameinfo:register_listener("ecm_waypoint_listener", "ecm", "set_feedback_active", callback(self, self, "custom_waypoint_ecm_clbk"))
				managers.gameinfo:register_listener("ecm_waypoint_listener", "ecm", "set_feedback_duration", callback(self, self, "custom_waypoint_ecm_clbk"))
				managers.gameinfo:register_listener("ecm_waypoint_listener", "ecm", "set_jammer_battery", callback(self, self, "custom_waypoint_ecm_clbk"))
				managers.gameinfo:register_listener("ecm_waypoint_listener", "ecm", "set_upgrade_level", callback(self, self, "custom_waypoint_ecm_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_timers", "boolean") then
				managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_active", callback(self, self, "custom_waypoint_timer_clbk"))
				managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "update", callback(self, self, "custom_waypoint_timer_clbk"))
				managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_jammed", callback(self, self, "custom_waypoint_timer_clbk"))
				managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_powered", callback(self, self, "custom_waypoint_timer_clbk"))
				managers.gameinfo:register_listener("timer_waypoint_listener", "timer", "set_upgrades", callback(self, self, "custom_waypoint_timer_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_minions", "boolean") then
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "add", callback(self, self, "custom_waypoint_minion_clbk"))
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "remove", callback(self, self, "custom_waypoint_minion_clbk"))
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "set_health_ratio", callback(self, self, "custom_waypoint_minion_clbk"))
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "set_owner", callback(self, self, "custom_waypoint_minion_clbk"))
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "set_kills", callback(self, self, "custom_waypoint_minion_clbk"))
				managers.gameinfo:register_listener("minion_waypoint_listener", "minion", "set_damage_resistance", callback(self, self, "custom_waypoint_minion_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_loot", "boolean") then
				managers.gameinfo:register_listener("loot_waypoint_listener", "loot", "add", callback(self, self, "custom_waypoint_loot_clbk"))
				managers.gameinfo:register_listener("loot_waypoint_listener", "loot", "remove", callback(self, self, "custom_waypoint_loot_clbk"))
				managers.gameinfo:register_listener("loot_waypoint_listener", "loot", "interact", callback(self, self, "custom_waypoint_loot_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_pager", "boolean") then
				managers.gameinfo:register_listener("pager_waypoint_listener", "pager", "add", callback(self, self, "custom_waypoint_pager_clbk"))
				managers.gameinfo:register_listener("pager_waypoint_listener", "pager", "remove", callback(self, self, "custom_waypoint_pager_clbk"))
				managers.gameinfo:register_listener("pager_waypoint_listener", "pager", "set_answered", callback(self, self, "custom_waypoint_pager_clbk"))
			end
			
			if WolfHUD:getSetting("waypoints_show_special_equipment", "boolean") then
				managers.gameinfo:register_listener("equipment_waypoint_listener", "special_equipment", "add", callback(self, self, "custom_waypoint_special_equipment_clbk"))
				managers.gameinfo:register_listener("equipment_waypoint_listener", "special_equipment", "remove", callback(self, self, "custom_waypoint_special_equipment_clbk"))
			end
		end
	end
	
	function HUDManager:add_custom_equip_waypoint(id, unit, position, texture, texture_rect, text, color, visible_angle, visible_distance, fade_angle, offset_position)
		local params = {
			unit = unit,
			position = position,
			offset = offset_position,
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
				text = text 
			},
			component_order = { { "icon", "label" } },
		}
		managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
	end

	function HUDManager:custom_waypoint_bag_clbk(type, event, key, data)
		if data.aggregate_members then return end
		
		local id = "bag_wp_" .. key
		
		if event == "set_active" then
			if data.active then
				local equipment_table = HUDManager.CUSTOM_WAYPOINTS.EQUIPMENT
				local icon_map = equipment_table and equipment_table[type]
				
				if icon_map then
					local amount = (data.amount or 0) + (data.amount_offset or 0)
					if type == "ammo_bag" then
						amount = string.format("%.0f%%", amount * 100)
					else
						amount = amount > 0 and tostring(amount) or ""
					end
					self:add_custom_equip_waypoint(id, data.unit, data.position, icon_map.texture, icon_map.texture_rect, amount, Color.white, { max = 32.5 }, { max = 1000 }, {start_angle = 32.5, end_angle = 25, final_scale = 10}, icon_map.offset)
					
					if data.owner then
						self:custom_waypoint_bag_clbk(type, "set_owner", key, data)
					end
					if data.upgrades then
						self:custom_waypoint_bag_clbk(type, "set_upgrades", key, data)
					end
				end
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "set_amount" or event == "set_amount_offset" then
				if data.amount or data.amount_offset then
					local amount = (data.amount or 0) + (data.amount_offset or 0)
					if type == "ammo_bag" then
						amount = string.format("%.0f%%", amount * 100)
					else
						amount = math.round(amount)
					end
					managers.waypoints:set_waypoint_label(id, "label", tostring(amount))
				end
			elseif event == "set_owner" then
				if data.owner then
					local peer_color = data.owner > 0 and tweak_data.chat_colors[data.owner]:with_alpha(1) or Color.white
					managers.waypoints:set_waypoint_component_setting(id, "icon", "color", peer_color)
				end
			elseif event == "set_upgrades" then
				if data.upgrades then
					for name, level in pairs(data.upgrades) do
						if not managers.waypoints:get_waypoint_component(id, name) then
							local upgrade_table = HUDManager.CUSTOM_WAYPOINTS.EQUIPMENT.UPGRADES
							local upgrade_data = upgrade_table and upgrade_table[type] and upgrade_table[type][name]
							if upgrade_data then
								local component = {
									type = "icon",
									show = (level > 0),
									texture = upgrade_data.texture,
									texture_rect = upgrade_data.texture_rect,
									color = HUDManager.CUSTOM_WAYPOINTS.UPGRADE_COLORS[level] or Color.white,
									visible_distance = { max = 200 }
								}
								managers.waypoints:add_waypoint_component(id, name, component, { 2, 1 })
							end
						else
							managers.waypoints:set_waypoint_component_setting(id, name, "show", level > 0)
							managers.waypoints:set_waypoint_component_setting(id, name, "color", HUDManager.CUSTOM_WAYPOINTS.UPGRADE_COLORS[level] or Color.white)
						end
					end
				end
			end
		end
	end

	function HUDManager:custom_waypoint_sentry_clbk(event, key, data)
		local id = "sentry_wp_" .. key
		
		if event == "set_active" or event == "set_owner" then
			if data.active then
				local peer = managers.network and managers.network:session() and managers.network:session():local_peer()
				if peer and data.owner and data.owner == peer:id() then
					local text = string.format("%.0f%%", (data.ammo_ratio or 0) * 100)
					self:add_custom_equip_waypoint(id, data.unit, data.position, "guis/textures/pd2/skilltree/icons_atlas", {7*64, 5*64, 64, 64}, text, Color.green, { max = 20 }, { max = 2000 }, {start_angle = 20, end_angle = 12.5, final_scale = 10})
				end
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif event == "set_ammo_ratio" then
			managers.waypoints:set_waypoint_label(id, "label", string.format("%.0f%%", (data.ammo_ratio or 0) * 100))
		elseif event == "set_health_ratio" then
			local color = math.lerp(Color.red, Color.green, data.health_ratio)
			managers.waypoints:set_waypoint_setting(id, "color", color)
		end
	end
	
	function HUDManager:custom_waypoint_ecm_clbk(event, key, data)
		local id = "ecm_wp_" .. key
		
		if event == "set_jammer_active" or event == "set_feedback_active" then
			if data.jammer_active or data.feedback_active then
				local params = {
					unit = data.unit,
					icon = { 
						type = "icon", 
						show = true, 
						scale = 1.1,
						texture = "guis/textures/pd2/skilltree/icons_atlas", 
						texture_rect = { 1 * 64, 4 * 64, 64, 64 }
					},
					jammer_time = { 
						type = "timer",
						show = true, 
						initial_value = 0,
						font = "fonts/font_medium_shadow_mf",
						color = Color.green,
					},
					feedback_time = { 
						type = "timer",
						show = false, 
						initial_value = 0,
						text = "Active",
						color = Color(0.0, 0.8, 1.0),
						font = "fonts/font_medium_shadow_mf",
					},
					distance = {
						type = "distance",
						show = true,
						scale = 0.6,
					},
					component_order = { { "icon" }, { "jammer_time", "feedback_time" }, { "distance" } },
				
				}
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params, false)
				managers.waypoints:set_waypoint_component_setting(id, "jammer_time", "show", data.jammer_active)
				managers.waypoints:set_waypoint_component_setting(id, "feedback_time", "show", data.feedback_active)
				if data.jammer_active then
					managers.waypoints:set_waypoint_component_setting(id, "jammer_time", "color", Color.green)
				end
				
				if data.feedback_duration or data.feedback_expire_t then
					self:custom_waypoint_ecm_clbk("set_feedback_duration", key, data)
				end
				if data.upgrade_level then
					self:custom_waypoint_ecm_clbk("set_upgrade_level", key, data)
				end
			else
				managers.waypoints:remove_waypoint(id, "jammer_time", "show", false)
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "set_jammer_battery" then
				if data.jammer_battery then
					managers.waypoints:set_waypoint_timer(id, "jammer_time", math.max(data.jammer_battery, 0))
					local max_duration = tweak_data.upgrades.ecm_jammer_base_battery_life * (data.upgrade_level and ECMJammerBase.battery_life_multiplier[data.upgrade_level] or 1)
					local color = math.lerp(Color.red, Color.green, data.jammer_battery / max_duration)
					managers.waypoints:set_waypoint_component_setting(id, "jammer_time", "color", color)
				end
			elseif event == "set_feedback_duration" then
				if data.feedback_duration or data.feedback_expire_t then
					local duration = data.feedback_expire_t and (data.feedback_expire_t - Application:time()) or data.feedback_duration
					managers.waypoints:set_waypoint_timer(id, "feedback_time", duration, -1)
				end
			elseif event == "set_upgrade_level" then
				if data.upgrade_level then
					if data.upgrade_level >= 3 then
						managers.waypoints:set_waypoint_component_setting(id, "icon", "color", Color.yellow)
					else
						managers.waypoints:set_waypoint_component_setting(id, "icon", "color", Color.white)
					end
				end
			end
		end
	end
	
	function HUDManager:custom_waypoint_timer_clbk(event, key, data)
		local id = "timer_wp_" .. key
		if event == "set_active" then
			if data.active and not HUDManager.CUSTOM_WAYPOINTS.TIMER.IGNORE[data.id] then
				local icon_table = HUDManager.CUSTOM_WAYPOINTS.TIMER.ICON_MAP
				
				local params = {
					unit = data.unit,
					offset = Vector3(0, 0, 30),
					show_offscreen = false,
					radius_offscreen = 300,
					icon = { 
						type = "icon", 
						show = true, 
						show_offscreen = true,
						std_wp = icon_table[data.device_type or "timer"],
						on_minimap = true,
					},
					timer = { 
						type = "timer",
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
					debug_txt = {
						type = "label",
						show = false,
						text = string.format("Editor ID: %s", (data.unit:editor_id() or "")),
					},
					component_order = { { "icon" }, { "timer" }, { "speed_upgrade", "noise_upgrade", "restart_upgrade" }, { "debug_txt" } },
				}
				
				if data.id == 132864 then --Meltdown timer
					MeltdownTemperatureWaypoint = MeltdownTemperatureWaypoint or class(CustomWaypoint)
					
					MeltdownTemperatureWaypoint.update_timer = function(self, name, value, t, dt)
						if self._settings[name] then
							self._settings[name].value = value
							if self._components[name] and self._settings[name].show then
								self:set_label(name, string.format("%d/50", math.floor(value)))
							end
						end
					end
				
					managers.waypoints:add_waypoint(id, "MeltdownTemperatureWaypoint", params)
				else
					managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
				end
				
				if data.upgrades then
					self:custom_waypoint_timer_clbk("set_upgrades", key, data)
				end
				if data.jammed then
					self:custom_waypoint_timer_clbk("set_jammed", key, data)
				end
				if data.powered then
					self:custom_waypoint_timer_clbk("set_powered", key, data)
				end
			else
				managers.waypoints:remove_waypoint(id)
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "update" then
				managers.waypoints:set_waypoint_timer(id, "timer", data.timer_value)
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
				managers.waypoints:set_waypoint_component_setting(id, "speed_upgrade", "color", HUDManager.CUSTOM_WAYPOINTS.UPGRADE_COLORS[speed_upgrade] or Color.white)
				managers.waypoints:set_waypoint_component_setting(id, "noise_upgrade", "color", HUDManager.CUSTOM_WAYPOINTS.UPGRADE_COLORS[noise_upgrade] or Color.white)
				managers.waypoints:set_waypoint_component_setting(id, "restart_upgrade", "color", HUDManager.CUSTOM_WAYPOINTS.UPGRADE_COLORS[restart_upgrade] or Color.white)
			end
		end
	end
	
	function HUDManager:custom_waypoint_minion_clbk(event, key, data)
		local id = "minion_wp_" .. key
		
		if event == "add" then
			local unit_tweak = data.unit:base() and data.unit:base()._tweak_table
			local name_id = unit_tweak and HUDManager.CUSTOM_WAYPOINTS.MINIONS.CHARACTER_NAMES[unit_tweak]
			local params = {
				unit = data.unit,
				offset = Vector3(0, 0, 30),
				fade_angle = { start_angle = 10, end_angle = 1, final_scale = 0.4 },
				scale = 1.25,
				health_bar = {
					type = "icon", 
					show = true,
					scale = 1.65,
					texture = "guis/textures/pd2/hud_health",
					texture_rect = {0, 0, 64, 64},
					radial_image = true,
					color = Color(data.health_ratio or 1, 1, 1),
				},
				health_shield = {
					type = "icon", 
					show = true,
					scale = 1.65,
					texture = "guis/textures/pd2/hud_shield",
					texture_rect = {0, 0, 64, 64},
					color = Color.white,
					alpha = 0.2,
				},
				health_bg = {
					type = "icon", 
					show = true,
					scale = 1.65,
					texture = "guis/textures/pd2/hud_radialbg",
					texture_rect = {0, 0, 64, 64},
				},
				health_dmg = {
					type = "icon", 
					show = true,
					scale = 1.65,
					texture = "guis/textures/pd2/hud_radial_rim",
					texture_rect = {0, 0, 64, 64},
					color = Color.red,
					alpha = 0,
				},
				name = { 
					type = "label", 
					show = true, 
					text = managers.localization:to_upper_text(name_id),
				},
				kills = { 
					type = "label", 
					show = true, 
					text = string.format("%s %d", utf8.char(57364), data.kills or 0),
					color = Color.white,
					alpha = 0.8,
					scale = 0.7,
				},
				component_order = { { "health_bar", "name" }, { "kills" } },
			}
			
			managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
			
			if data.kills then
				self:custom_waypoint_minion_clbk("set_kills", key, data)
			end
			if data.owner then
				self:custom_waypoint_minion_clbk("set_owner", key, data)
			end
			if data.damage_resistance then
				self:custom_waypoint_minion_clbk("set_damage_resistance", key, data)
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "remove" then
				managers.waypoints:remove_waypoint(id)
			elseif event == "set_health_ratio" then
				if data.health_ratio then
					managers.waypoints:set_waypoint_component_setting(id, "health_bar", "color", Color(data.health_ratio, 1, 1))
					local health_dmg = managers.waypoints:get_waypoint_component(id, "health_dmg")
					if alive(health_dmg) and data.health_ratio < 1 then
						health_dmg:stop()
						health_dmg:animate(callback(self, self, "_animate_custom_waypoint_minion_damage"))
					end
				end
			elseif event == "set_kills" then
				if data.kills then
					managers.waypoints:set_waypoint_label(id, "kills", string.format("%s %d", utf8.char(57364), data.kills))
				end
			elseif event == "set_owner" then
				if data.owner then
					local peer_color = data.owner > 0 and tweak_data.chat_colors[data.owner or 5]
					managers.waypoints:set_waypoint_setting(id, "color", peer_color)
				end
			elseif event == "set_damage_resistance" then
				local max_mult = tweak_data.upgrades.values.player.convert_enemies_health_multiplier[1] * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[2]
				local alpha = math.clamp(1 - (data.damage_resistance - max_mult) / (1 - max_mult), 0, 1) * 0.8 + 0.2
				managers.waypoints:set_waypoint_component_setting(id, "health_shield", "alpha", alpha)
			end
		end
	end
	
	function HUDManager:_animate_custom_waypoint_minion_damage(panel)
		local t = 1
		panel:set_alpha(1)
		while t > 0 do
			t = t - coroutine.yield()
			panel:set_alpha( math.clamp(t, 0, 1) )
		end
		panel:set_alpha(0)
	end
	
	function HUDManager:custom_waypoint_loot_clbk(event, key, data)
		local id = "loot_wp_" .. key
		local tweak_entry = data.carry_id and tweak_data.carry[data.carry_id]
		
		if event == "add" then
			if tweak_entry and not tweak_entry.is_vehicle and not tweak_entry.skip_exit_secure and (data.carry_id ~= "person" or managers.job:current_level_id() == "mad" and (data.bagged or data.unit:editor_id() ~= -1)) then
				local name_id = data.carry_id and tweak_data.carry[data.carry_id] and tweak_data.carry[data.carry_id].name_id
				local bag_name = name_id and managers.localization:to_upper_text(name_id)
				local count = data.count or 1
				if bag_name then
					local params = {
						unit = data.unit,
						offset = data.bagged and Vector3(0, 0, 30) or Vector3(0, 0, 15),
						visible_through_walls = data.bagged,
						alpha = 0.1,
						visible_angle = { max = 25 },
						visible_distance = { max = 2000 },
						fade_angle = { start_angle = 25, end_angle = 20, final_scale = 8 },
						scale = 1.25,
						icon = { 
							type = "icon", 
							show = data.bagged, 
							std_wp = "wp_bag",
							alpha = 0.5,
							on_minimap = true,
						},
						amount = { 
							type = "label", 
							show = (count > 1), 
							text = string.format("%dx", count),
						},
						label = { 
							type = "label", 
							show = true, 
							text = bag_name,
						},
						component_order = { { "icon", "amount", "label" } },
					}
					
					managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
				end
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "interact" then
				local count = data.count or 1
				managers.waypoints:set_waypoint_label(id, "amount", string.format("%dx", count))
				managers.waypoints:set_waypoint_component_setting(id, "amount", "show", (count > 1))
			elseif event == "remove" then
				managers.waypoints:remove_waypoint(id)
			end
		end
	end
	
	function HUDManager:custom_waypoint_pager_clbk(event, key, data)
		local id = "pager_wp_" .. key
		
		if event == "add" then
			if data.active then
				local params = {
					unit = data.unit,
					hide_on_uninteractable = true,
					show_offscreen = true,
					scale = 1.25,
					color = Color(1, 0.2, 0),
					icon = { 
						type = "icon", 
						show = true,
						show_offscreen = true,
						texture = "guis/textures/pd2/specialization/icons_atlas",
						texture_rect = { 1 * 64, 4 * 64, 64, 64 },
						scale = 1.4,
						on_minimap = true,
					},
					duration = { 
						type = "duration", 
						show = true, 
						show_offscreen = false,
						initial_value = 12,
						font = "fonts/font_medium_shadow_mf",
						fade_duration = {
							start = 0,
							stop = 1,
							color = {start = Color('008000'), stop = Color(1, 0.2, 0)},
						},
					},
					component_order = { { "icon", "duration" } },
				}
					
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
				
				if data.answered then
					self:custom_waypoint_pager_clbk("set_answered", key, data)
				end
			end
		elseif managers.waypoints:get_waypoint(id) then
			if event == "remove" then
				if not data.active then
					managers.waypoints:remove_waypoint(id)
				end
			elseif event == "set_answered" then
				if data.active and data.answered then
					managers.waypoints:set_waypoint_setting(id, "show_offscreen", false)
					managers.waypoints:remove_waypoint_component(id, "duration")
					managers.waypoints:set_waypoint_setting(id, "color", Color('008000'))
				end
			end
		end
	end
	
	function HUDManager:custom_waypoint_special_equipment_clbk(event, key, data)
		local id = "equipment_wp_" .. key
		
		if event == "add" then
			local icon_table = HUDManager.CUSTOM_WAYPOINTS.SPECIAL_EQUIPMENT.ICON_MAP
			local icon_data = icon_table[data.interact_id]
			if icon_data then
				local params = {
					unit = data.unit,
					offset = icon_data.offset or Vector3(0, 0, 15),
					hide_on_uninteractable = true,
					visible_through_walls = icon_data.x_ray or false,
					scale = 1,
					alpha = 0.1,
					fade_angle = { start_angle = 35, end_angle = 25, final_scale = 8 },
					visible_angle = { max = 35 },
					visible_distance = { max = 3000 },
					icon = { 
						type = "icon", 
						show = true,
						std_wp = icon_data.std_icon,
						texture = icon_data.texture,
						texture_rect = icon_data.texture_rect,
						on_minimap = true,
					},
					component_order = { { "icon" } },
				}
				
				managers.waypoints:add_waypoint(id, "CustomWaypoint", params)
			end
		elseif event == "remove" then
			managers.waypoints:remove_waypoint(id)
		end
	end
end

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