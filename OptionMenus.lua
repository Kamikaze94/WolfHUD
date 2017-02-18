if WolfHUD then
	--Helper function to create Gadgetoption tables
	local function get_gadget_options(gadget_type, theme)
		local rainbow_pulse_options = {
			{ 
				type = "divider", 
				size = 24 
			},
			{
				type = "toggle",
				name_id = "wolfhud_gadgets_rainbow_enabled_title",
				desc_id = "wolfhud_gadgets_rainbow_enabled_desc",
				value = {"GADGETS", gadget_type, theme, "rainbow", "enabled"},
				visible_reqs = {},
			},
			{
				type = "slider",
				name_id = "wolfhud_gadgets_rainbow_frequency_title",
				desc_id = "wolfhud_gadgets_rainbow_frequency_desc",
				value = {"GADGETS", gadget_type, theme, "rainbow", "frequency"},
				visible_reqs = {
					hide_on_disabled = true,
					{ setting = { "GADGETS", gadget_type, theme, "rainbow", "enabled" }, invert = false },
				},
				min_value = 0,
				max_value = 5,
				step_size = 0.1,
			},
			{ 
				type = "divider", 
				size = 24 
			},
			{
				type = "toggle",
				name_id = "wolfhud_gadgets_pulse_enabled_title",
				desc_id = "wolfhud_gadgets_pulse_enabled_desc",
				value = {"GADGETS", gadget_type, theme, "pulse", "enabled"},
				visible_reqs = {},
			},
			{
				type = "slider",
				name_id = "wolfhud_gadgets_pulse_min_title",
				desc_id = "wolfhud_gadgets_pulse_min_desc",
				value = {"GADGETS", gadget_type, theme, "pulse", "min"},
				visible_reqs = {
					hide_on_disabled = true,
					{ setting = { "GADGETS", gadget_type, theme, "pulse", "enabled" }, invert = false },
				},
				min_value = 0,
				max_value = 5,
				step_size = 0.1,
			},
			{
				type = "slider",
				name_id = "wolfhud_gadgets_pulse_max_title",
				desc_id = "wolfhud_gadgets_pulse_max_desc",
				value = {"GADGETS", gadget_type, theme, "pulse", "max"},
				visible_reqs = {
					hide_on_disabled = true,
					{ setting = { "GADGETS", gadget_type, theme, "pulse", "enabled" }, invert = false },
				},
				min_value = 0,
				max_value = 5,
				step_size = 0.1,
			},
			{
				type = "slider",
				name_id = "wolfhud_gadgets_pulse_frequency_title",
				desc_id = "wolfhud_gadgets_pulse_frequency_desc",
				value = {"GADGETS", gadget_type, theme, "pulse", "frequency"},
				visible_reqs = {
					hide_on_disabled = true,
					{ setting = { "GADGETS", gadget_type, theme, "pulse", "enabled" }, invert = false },
				},
				min_value = 0,
				max_value = 5,
				step_size = 0.1,
			},
		}
		
		local option_table = {
			laser = {
				{
					type = "slider",
					name_id = "wolfhud_gadgets_beam_r_title",
					desc_id = "wolfhud_gadgets_beam_r_desc",
					value = {"GADGETS", "laser", theme, "beam", "r"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_beam_g_title",
					desc_id = "wolfhud_gadgets_beam_g_desc",
					value = {"GADGETS", "laser", theme, "beam", "g"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_beam_b_title",
					desc_id = "wolfhud_gadgets_beam_b_desc",
					value = {"GADGETS", "laser", theme, "beam", "b"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_beam_a_title",
					desc_id = "wolfhud_gadgets_beam_a_desc",
					value = {"GADGETS", "laser", theme, "beam", "a"},
					visible_reqs = {},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{ 
					type = "divider", 
					size = 12 
				},
				{
					type = "toggle",
					name_id = "wolfhud_gadgets_dot_match_title",
					desc_id = "wolfhud_gadgets_dot_match_desc",
					value = {"GADGETS", "laser", theme, "dot", "match_beam"},
					visible_reqs = {},
					},
					{
					type = "slider",
					name_id = "wolfhud_gadgets_dot_r_title",
					desc_id = "wolfhud_gadgets_dot_r_desc",
					value = {"GADGETS", "laser", theme, "dot", "r"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "dot", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_dot_g_title",
					desc_id = "wolfhud_gadgets_dot_g_desc",
					value = {"GADGETS", "laser", theme, "dot", "g"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "dot", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_dot_b_title",
					desc_id = "wolfhud_gadgets_dot_b_desc",
					value = {"GADGETS", "laser", theme, "dot", "b"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "dot", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_dot_a_title",
					desc_id = "wolfhud_gadgets_dot_a_desc",
					value = {"GADGETS", "laser", theme, "dot", "a"},
					visible_reqs = {},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{ 
					type = "divider", 
					size = 12 
				},
				{
					type = "toggle",
					name_id = "wolfhud_gadgets_glow_match_title",
					desc_id = "wolfhud_gadgets_glow_match_desc",
					value = {"GADGETS", "laser", theme, "glow", "match_beam"},
					visible_reqs = {},
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_glow_r_title",
					desc_id = "wolfhud_gadgets_glow_r_desc",
					value = {"GADGETS", "laser", theme, "glow", "r"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "glow", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_glow_g_title",
					desc_id = "wolfhud_gadgets_glow_g_desc",
					value = {"GADGETS", "laser", theme, "glow", "g"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "glow", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_glow_b_title",
					desc_id = "wolfhud_gadgets_glow_b_desc",
					value = {"GADGETS", "laser", theme, "glow", "b"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "laser", theme, "rainbow", "enabled" }, invert = true },
						{ setting = { "GADGETS", "laser", theme, "glow", "match_beam" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_glow_a_title",
					desc_id = "wolfhud_gadgets_glow_a_desc",
					value = {"GADGETS", "laser", theme, "glow", "a"},
					visible_reqs = {},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				unpack(rainbow_pulse_options)
			},
			flashlight = {
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_r_title",
					desc_id = "wolfhud_gadgets_light_r_desc",
					value = {"GADGETS", "flashlight", theme, "light", "r"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "flashlight", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_g_title",
					desc_id = "wolfhud_gadgets_light_g_desc",
					value = {"GADGETS", "flashlight", theme, "light", "g"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "flashlight", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_b_title",
					desc_id = "wolfhud_gadgets_light_b_desc",
					value = {"GADGETS", "flashlight", theme, "light", "b"},
					visible_reqs = {
						hide_on_disabled = true,
						{ setting = { "GADGETS", "flashlight", theme, "rainbow", "enabled" }, invert = true },
					},
					min_value = 0,
					max_value = 1,
					step_size = 0.01,
				},
				{ 
					type = "divider", 
					size = 12 
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_brightness_title",
					desc_id = "wolfhud_gadgets_light_brightness_desc",
					value = {"GADGETS", "flashlight", theme, "light", "brightness"},
					visible_reqs = {},
					min_value = 0,
					max_value = 5,
					step_size = 0.1,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_angle_title",
					desc_id = "wolfhud_gadgets_light_angle_desc",
					value = {"GADGETS", "flashlight", theme, "light", "angle"},
					visible_reqs = {},
					min_value = 0,
					max_value = 160,
					step_size = 5,
				},
				{
					type = "slider",
					name_id = "wolfhud_gadgets_light_range_title",
					desc_id = "wolfhud_gadgets_light_range_desc",
					value = {"GADGETS", "flashlight", theme, "light", "range"},
					visible_reqs = {},
					min_value = 0,
					max_value = 100,
					step_size = 5,
				},
				unpack(rainbow_pulse_options)
			}
		}
		
		return option_table[gadget_type]
	end
	
	
	-- Actual Menu Data table
	WolfHUD.options_menu_data = {
		type = "menu",
		menu_id = "wolfhud_main_options_menu",
		parent_id = "lua_mod_options_menu",
		name_id = "wolfhud_options_name",
		desc_id = "wolfhud_options_help",
		position = 3,
		options = {
			{
				type = "menu",
				menu_id = "wolfhud_customhud_options_menu",
				name_id = "wolfhud_panels_options_name",
				desc_id = "wolfhud_panels_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_use_customhud_title",
						desc_id = "wolfhud_use_customhud_desc",
						value = {"CustomHUD", "ENABLED"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "menu",
						menu_id = "wolfhud_customhud_player_options_menu",
						name_id = "wolfhud_playerpanel_options_name",
						desc_id = "wolfhud_playerpanel_options_help",
						options = {
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_position_title",
								desc_id = "wolfhud_panels_position_desc",
								options = {
									"wolfhud_multiselect_left",
									"wolfhud_multiselect_center",
									"wolfhud_multiselect_right"
								},
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "POSITION"},
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_scale_title",
								desc_id = "wolfhud_panels_scale_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "SCALE"},
								min_value = 0.01,
								max_value = 2,
								step_size = 0.01,
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_oppacity_title",
								desc_id = "wolfhud_panels_oppacity_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "OPACITY"},
								min_value = 0,
								max_value = 1,
								step_size = 0.01,
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_name_title",
								desc_id = "wolfhud_panels_show_name_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "NAME"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_rank_title",
								desc_id = "wolfhud_panels_rank_name_desc",
								visible_reqs = {},
								value = {"CustomHUD", "PLAYER", "RANK"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_char_title",
								desc_id = "wolfhud_panels_show_char_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "CHARACTER"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_status_title",
								desc_id = "wolfhud_panels_show_status_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "STATUS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_downcounter_title",
								desc_id = "wolfhud_panels_show_downcounter_desc",
								visible_reqs = {},
								value = {"CustomHUD", "PLAYER", "DOWNCOUNTER"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_stamina_title",
								desc_id = "wolfhud_panels_show_stamina_desc",
								visible_reqs = {},
								value = {"CustomHUD", "PLAYER", "STAMINA"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_equip_title",
								desc_id = "wolfhud_panels_show_equip_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "EQUIPMENT"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_special_equip_title",
								desc_id = "wolfhud_panels_show_special_equip_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "SPECIAL_EQUIPMENT"},
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_special_equip_rows_title",
								desc_id = "wolfhud_panels_special_equip_rows_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false },
									{ setting = {"CustomHUD", "PLAYER", "SPECIAL_EQUIPMENT"}, invert = false },
								},
								value = {"CustomHUD", "PLAYER", "SPECIAL_EQUIPMENT_ROWS"},
								min_value = 1,
								max_value = 8,
								step_size = 1,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_callsign_title",
								desc_id = "wolfhud_panels_show_callsign_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "CALLSIGN"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_carry_title",
								desc_id = "wolfhud_panels_show_carry_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "PLAYER", "CARRY"},
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_icon_title",
								desc_id = "wolfhud_panels_weapon_icon_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "PLAYER", "WEAPON", "ICON"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_name_title",
								desc_id = "wolfhud_panels_weapon_name_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "PLAYER", "WEAPON", "NAME"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_ammo_title",
								desc_id = "wolfhud_panels_weapon_ammo_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both",
									"wolfhud_panels_ammo_total"
								},
								value = {"CustomHUD", "PLAYER", "WEAPON", "AMMO"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_firemode_title",
								desc_id = "wolfhud_panels_weapon_firemode_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "PLAYER", "WEAPON", "FIREMODE"},
							}
						},
					},
					{
						type = "menu",
						menu_id = "wolfhud_customhud_team_options_menu",
						name_id = "wolfhud_teampanels_options_name",
						desc_id = "wolfhud_teampanels_options_help",
						options = {
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_position_title",
								desc_id = "wolfhud_panels_position_desc",
								options = {
									"wolfhud_multiselect_left",
									"wolfhud_multiselect_center",
									"wolfhud_multiselect_right"
								},
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "POSITION"},
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_scale_title",
								desc_id = "wolfhud_panels_scale_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "SCALE"},
								min_value = 0.01,
								max_value = 2,
								step_size = 0.01,
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_oppacity_title",
								desc_id = "wolfhud_panels_oppacity_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "OPACITY"},
								min_value = 0,
								max_value = 1,
								step_size = 0.01,
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_name_title",
								desc_id = "wolfhud_panels_show_name_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "NAME"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_rank_title",
								desc_id = "wolfhud_panels_rank_name_desc",
								visible_reqs = {},
								value = {"CustomHUD", "TEAMMATE", "RANK"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_char_title",
								desc_id = "wolfhud_panels_show_char_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "CHARACTER"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_ping_title",
								desc_id = "wolfhud_panels_show_ping_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "LATENCY"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_status_title",
								desc_id = "wolfhud_panels_show_status_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "STATUS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_downcounter_title",
								desc_id = "wolfhud_panels_show_downcounter_desc",
								visible_reqs = {},
								value = {"CustomHUD", "TEAMMATE", "DOWNCOUNTER"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_equip_title",
								desc_id = "wolfhud_panels_show_equip_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "EQUIPMENT"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_special_equip_title",
								desc_id = "wolfhud_panels_show_special_equip_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "SPECIAL_EQUIPMENT"},
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_special_equip_rows_title",
								desc_id = "wolfhud_panels_special_equip_rows_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false },
									{ setting = {"CustomHUD", "TEAMMATE", "SPECIAL_EQUIPMENT"}, invert = false },
								},
								value = {"CustomHUD", "TEAMMATE", "SPECIAL_EQUIPMENT_ROWS"},
								min_value = 1,
								max_value = 8,
								step_size = 1,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_callsign_title",
								desc_id = "wolfhud_panels_show_callsign_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "CALLSIGN"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_carry_title",
								desc_id = "wolfhud_panels_show_carry_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "CARRY"},
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_build_show_title",
								desc_id = "wolfhud_panels_build_show_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "BUILD", "HIDE"},
								invert_value = true,
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_build_time_title",
								desc_id = "wolfhud_panels_build_time_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "BUILD", "DURATION"},
								min_value = 0,
								max_value = 30,
								step_size = 1,
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_icon_title",
								desc_id = "wolfhud_panels_weapon_icon_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "TEAMMATE", "WEAPON", "ICON"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_name_title",
								desc_id = "wolfhud_panels_weapon_name_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "TEAMMATE", "WEAPON", "NAME"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_ammo_title",
								desc_id = "wolfhud_panels_weapon_ammo_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both",
									"wolfhud_panels_ammo_total"
								},
								value = {"CustomHUD", "TEAMMATE", "WEAPON", "AMMO"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_panels_weapon_firemode_title",
								desc_id = "wolfhud_panels_weapon_firemode_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								options = {
									"wolfhud_panels_hide",
									"wolfhud_panels_selected",
									"wolfhud_panels_unselected",
									"wolfhud_panels_both"
								},
								value = {"CustomHUD", "TEAMMATE", "WEAPON", "FIREMODE"},
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_panels_show_interaction_title",
								desc_id = "wolfhud_panels_show_interaction_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "INTERACTION", "HIDE"},
								invert_value = true,
							},
							{
								type = "slider",
								name_id = "wolfhud_panels_interaction_time_title",
								desc_id = "wolfhud_panels_interaction_time_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "ENABLED"}, invert = false }
								},
								value = {"CustomHUD", "TEAMMATE", "INTERACTION", "MIN_DURATION"},
								min_value = 0,
								max_value = 30,
								step_size = 1,
							},
						},
					},
					{
						type = "divider",
						size = 8
					},
					{
						type = "menu",
						menu_id = "wolfhud_killcounter_options_menu",
						name_id = "wolfhud_killcounter_options_name",
						desc_id = "wolfhud_killcounter_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_player_show_killcount_title",
								desc_id = "wolfhud_killcounter_player_show_killcount_desc",
								visible_reqs = {},
								value = {"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"},
								invert_value = true,
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_player_show_special_title",
								desc_id = "wolfhud_killcounter_player_show_special_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								value = {"CustomHUD", "PLAYER", "KILLCOUNTER", "SHOW_SPECIAL_KILLS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_player_show_head_title",
								desc_id = "wolfhud_killcounter_player_show_head_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								value = {"CustomHUD", "PLAYER", "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_killcounter_player_color_title",
								desc_id = "wolfhud_killcounter_player_color_desc",
								value = {"CustomHUD", "PLAYER", "KILLCOUNTER", "COLOR"},
								visible_reqs = {
									{ setting = {"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_player_show_accuracy_title",
								desc_id = "wolfhud_killcounter_player_show_accuracy_desc",
								visible_reqs = {},
								value = {"CustomHUD", "PLAYER", "SHOW_ACCURACY"},
							},
							{
								type = "divider",
								size = 32,
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_team_show_killcount_title",
								desc_id = "wolfhud_killcounter_team_show_killcount_desc",
								visible_reqs = {},
								value = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"},
								invert_value = true,
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_team_show_special_title",
								desc_id = "wolfhud_killcounter_team_show_special_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								value = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_SPECIAL_KILLS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_team_show_head_title",
								desc_id = "wolfhud_killcounter_team_show_head_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								value = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_killcounter_team_show_ai_title",
								desc_id = "wolfhud_killcounter_team_show_ai_desc",
								visible_reqs = {
									{ setting = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								value = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_BOT_KILLS"},
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_killcounter_team_color_title",
								desc_id = "wolfhud_killcounter_team_color_desc",
								value = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "COLOR"},
								visible_reqs = {
									{ setting = {"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"}, invert = true }
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
						},
					},
					{
						type = "toggle",
						name_id = "wolfhud_use_realammo_title",
						desc_id = "wolfhud_use_realammo_desc",
						visible_reqs = {},
						value = {"CustomHUD", "USE_REAL_AMMO"},
					},
					{
						type = "divider",
						size = 16,
					},
					{
						type = "menu",
						menu_id = "wolfhud_hudchat_options_menu",
						name_id = "wolfhud_chat_options_name",
						desc_id = "wolfhud_chat_options_help",
						options = {
							{
								type = "slider",
								name_id = "wolfhud_chat_fontsize_title",
								desc_id = "wolfhud_chat_fontsize_desc",
								visible_reqs = {},
								value = {"HUDChat", "LINE_HEIGHT"},
								min_value = 10,
								max_value = 20,
								step_size = 1,
							},
							{
								type = "slider",
								name_id = "wolfhud_chat_outputlines_title",
								desc_id = "wolfhud_chat_outputlines_desc",
								visible_reqs = {},
								value = {"HUDChat", "MAX_OUTPUT_LINES"},
								min_value = 2,
								max_value = 15,
								step_size = 1,
							},
							{
								type = "slider",
								name_id = "wolfhud_chat_waittime_title",
								desc_id = "wolfhud_chat_waittime_desc",
								visible_reqs = {},
								value = {"HUDChat", "CHAT_WAIT_TIME"},
								min_value = 0,
								max_value = 90,
								step_size = 1,
							},
							{
								type = "divider",
								size = 8,
							},
							{
								type = "toggle",
								name_id = "wolfhud_spam_filter_title",
								desc_id = "wolfhud_spam_filter_desc",
								visible_reqs = {},
								value = {"HUDChat", "SPAM_FILTER"},
							},
						},
					},
					{ -- Suspicion
						type = "menu",
						menu_id = "wolfhud_hudsuspicion_options_menu",
						name_id = "wolfhud_suspicion_options_name",
						desc_id = "wolfhud_suspicion_options_help",
						options = {
							{
								type = "slider",
								name_id = "wolfhud_suspicion_scale_title",
								desc_id = "wolfhud_suspicion_scale_desc",
								visible_reqs = {},
								value = {"HUDSuspicion", "SCALE"},
								min_value = 0.3,
								max_value = 1.2,
								step_size = 0.01,
							},
							{
								type = "toggle",
								name_id = "wolfhud_susp_eye_title",
								desc_id = "wolfhud_susp_eye_desc",
								visible_reqs = {},
								value = {"HUDSuspicion", "SHOW_BARS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_susp_numberic_title",
								desc_id = "wolfhud_susp_numberic_desc",
								visible_reqs = {},
								value = {"HUDSuspicion", "SHOW_PERCENTAGE"},
							},
							{
								type = "divider",
								size = 24,
							},
							{
								type = "toggle",
								name_id = "wolfhud_pacified_civs_title",
								desc_id = "wolfhud_pacified_civs_desc",
								visible_reqs = {},
								value = {"HUDSuspicion", "SHOW_PACIFIED_CIVILIANS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_remove_answered_pagers_title",
								desc_id = "wolfhud_hudlist_remove_answered_pagers_desc",
								visible_reqs = {},
								value = {"HUDSuspicion", "REMOVE_ANSWERED_PAGER_CONTOUR"},
							},
						},
					},
					{ -- AssaultBanner
						type = "menu",
						menu_id = "wolfhud_assaultbanner_options_menu",
						name_id = "wolfhud_assaultbanner_options_name",
						desc_id = "wolfhud_assaultbanner_options_help",
						options = {
							{
								type = "multi_choice",
								name_id = "wolfhud_assault_position_title",
								desc_id = "wolfhud_assault_position_desc",
								value = {"AssaultBanner", "POSITION"},
								visible_reqs = {},
								options = {
									"wolfhud_multiselect_left",
									"wolfhud_multiselect_center",
									"wolfhud_multiselect_right",
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_adv_assault_title",
								desc_id = "wolfhud_adv_assault_desc",
								visible_reqs = {},
								value = {"AssaultBanner", "USE_ADV_ASSAULT"},
							},
						},
					},
					{ -- Damage Indicator
						type = "menu",
						menu_id = "wolfhud_dmgindicator_options_menu",
						name_id = "wolfhud_dmgindicator_options_name",
						desc_id = "wolfhud_dmgindicator_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_show_dmg_indicator_title",
								desc_id = "wolfhud_show_dmg_indicator_desc",
								visible_reqs = {},
								value = {"DamageIndicator", "ENABLED"},
							},
							{
								type = "slider",
								name_id = "wolfhud_dmg_ind_time_title",
								desc_id = "wolfhud_dmg_ind_time_desc",
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								value = {"DamageIndicator", "DURATION"},
								min_value = 0.1,
								max_value = 20,
								step_size = 0.1,
							},
							{
								type = "slider",
								name_id = "wolfhud_dmg_ind_size_title",
								desc_id = "wolfhud_dmg_ind_size_desc",
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								value = {"DamageIndicator", "SIZE"},
								min_value = 100,
								max_value = 250,
								step_size = 10,
							},
							{
								type = "slider",
								name_id = "wolfhud_dmg_indicator_max_count_title",
								desc_id = "wolfhud_dmg_indicator_max_count_desc",
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								value = {"DamageIndicator", "MAX_AMOUNT"},
								min_value = 5,
								max_value = 20,
								step_size = 1,
							},
							{
								type = "divider",
								size = 16,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_shield_color_title",
								desc_id = "wolfhud_dmg_shield_color_desc",
								value = {"DamageIndicator", "SHIELD_COLOR"},
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_health_color_title",
								desc_id = "wolfhud_dmg_health_color_desc",
								value = {"DamageIndicator", "HEALTH_COLOR"},
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_crit_color_title",
								desc_id = "wolfhud_dmg_crit_color_desc",
								value = {"DamageIndicator", "CRIT_COLOR"},
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_vehicle_color_title",
								desc_id = "wolfhud_dmg_vehicle_color_desc",
								value = {"DamageIndicator", "VEHICLE_COLOR"},
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_friendlyfire_color_title",
								desc_id = "wolfhud_dmg_friendlyfire_color_desc",
								value = {"DamageIndicator", "FRIENDLY_FIRE_COLOR"},
								visible_reqs = {
									{ setting = { "DamageIndicator", "ENABLED" }, invert = false },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
						},
					},
					{
						type = "divider",
						size = 16,
					},					
					{ -- EnemyHealthbar
						type = "menu",
						menu_id = "wolfhud_enemyhealthbar_options_menu",
						name_id = "wolfhud_enemyhealthbar_options_name",
						desc_id = "wolfhud_enemyhealthbar_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_show_enemyhealthbar_title",
								desc_id = "wolfhud_show_enemyhealthbar_desc",
								visible_reqs = {},
								value = {"EnemyHealthbar", "ENABLED"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_show_civhealthbar_title",
								desc_id = "wolfhud_show_civhealthbar_desc",
								visible_reqs = {
									{ setting = { "EnemyHealthbar", "ENABLED" }, invert = false }
								},
								value = {"EnemyHealthbar", "SHOW_CIVILIAN"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_show_carhealthbar_title",
								desc_id = "wolfhud_show_carhealthbar_desc",
								visible_reqs = {
									{ setting = { "EnemyHealthbar", "ENABLED" }, invert = false }
								},
								value = {"EnemyHealthbar", "SHOW_VEHICLE"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_show_healthbar_pointer_title",
								desc_id = "wolfhud_show_healthbar_pointer_desc",
								visible_reqs = {
									{ setting = { "EnemyHealthbar", "ENABLED" }, invert = false }
								},
								value = {"EnemyHealthbar", "SHOW_POINTER"},
							},
						},
					},
					{ -- Damagepopup
						type = "menu",
						menu_id = "wolfhud_dmgpopup_options_menu",
						name_id = "wolfhud_dmgpopup_options_name",
						desc_id = "wolfhud_dmgpopup_options_help",
						options = {
							{
								type = "multi_choice",
								name_id = "wolfhud_show_dmg_popup_title",
								desc_id = "wolfhud_show_dmg_popup_desc",
								value = {"DamagePopup", "DISPLAY_MODE"},
								visible_reqs = {},
								options = {
									"wolfhud_multiselect_disabled",
									"wolfhud_dmg_popup_player",
									"wolfhud_dmg_popup_all"
								},
							},
							{
								type = "slider",
								name_id = "wolfhud_dmg_popup_scale_title",
								desc_id = "wolfhud_dmg_popup_scale_desc",
								visible_reqs = {
									{ setting = { "DamagePopup", "DISPLAY_MODE" }, min = 2 },
								},
								value = {"DamagePopup", "SCALE"},
								min_value = 0.1,
								max_value = 3,
								step_size = 0.1,
							},
							{
								type = "slider",
								name_id = "wolfhud_dmg_popup_time_title",
								desc_id = "wolfhud_dmg_popup_time_desc",
								visible_reqs = {
									{ setting = { "DamagePopup", "DISPLAY_MODE" }, min = 2 },
								},
								value = {"DamagePopup", "DURATION"},
								min_value = 0.1,
								max_value = 20,
								step_size = 0.1,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_popup_color_title",
								desc_id = "wolfhud_dmg_popup_color_desc",
								value = {"DamagePopup", "COLOR"},
								visible_reqs = {
									{ setting = { "DamagePopup", "DISPLAY_MODE" }, min = 2, max = 2 },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
							{
								type = "multi_choice",
								name_id = "wolfhud_dmg_popup_headshot_color_title",
								desc_id = "wolfhud_dmg_popup_headshot_color_desc",
								value = {"DamagePopup", "HEADSHOT_COLOR"},
								visible_reqs = {
									{ setting = { "DamagePopup", "DISPLAY_MODE" }, min = 2, max = 2 },
								},
								options = {},
								add_color_options = true,
								add_rainbow = false,
							},
						},
					}, 
					{
						type = "divider",
						size = 16,
					},	
					{ -- drivingHUD
						type = "menu",
						menu_id = "wolfhud_drivinghud_options_menu",
						name_id = "wolfhud_drivinghud_options_name",
						desc_id = "wolfhud_drivinghud_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_show_drivinghud_title",
								desc_id = "wolfhud_show_drivinghud_desc",
								visible_reqs = {},
								value = {"DrivingHUD", "ENABLED"},
							},
							{
								type = "slider",
								name_id = "wolfhud_drivinghud_scale_title",
								desc_id = "wolfhud_drivinghud_scale_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SCALE"},
								min_value = 0.05,
								max_value = 2,
								step_size = 0.01,
							},
							{
								type = "divider",
								size = 16,
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_vehicle_title",
								desc_id = "wolfhud_drivinghud_show_vehicle_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_VEHICLE"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_health_title",
								desc_id = "wolfhud_drivinghud_show_health_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_HEALTH"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_loot_title",
								desc_id = "wolfhud_drivinghud_show_loot_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_LOOT"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_passengers_title",
								desc_id = "wolfhud_drivinghud_show_passengers_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_PASSENGERS"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_gear_title",
								desc_id = "wolfhud_drivinghud_show_gear_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_GEAR"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_speed_title",
								desc_id = "wolfhud_drivinghud_show_speed_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_SPEED"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_speed_in_mph_title",
								desc_id = "wolfhud_drivinghud_speed_in_mph_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
									{ setting = { "DrivingHUD", "SHOW_SPEED" }, invert = false },
								},
								value = {"DrivingHUD", "SPEED_IN_MPH"},
							},
							{
								type = "toggle",
								name_id = "wolfhud_drivinghud_show_rpm_title",
								desc_id = "wolfhud_drivinghud_show_rpm_desc",
								visible_reqs = {
									{ setting = { "DrivingHUD", "ENABLED" }, invert = false },
								},
								value = {"DrivingHUD", "SHOW_RPM"},
							},
						},
					},
				},
			},
			{
				type = "menu",
				menu_id = "wolfhud_hudlist_options_menu",
				name_id = "wolfhud_infopanels_options_name",
				desc_id = "wolfhud_infopanels_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_use_hudlist_title",
						desc_id = "wolfhud_use_hudlist_desc",
						value = {"HUDList", "ENABLED"},
						visible_reqs = {},
					},
					{
						type ="divider",
						size = 16,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_box_color_title",
						desc_id = "wolfhud_hudlist_box_color_desc",
						value = {"HUDList", "list_color"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_box_bg_color_title",
						desc_id = "wolfhud_hudlist_box_bg_color_desc",
						value = {"HUDList", "list_color_bg"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_civcolor_title",
						desc_id = "wolfhud_hudlist_civcolor_desc",
						value = {"HUDList", "civilian_color"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_thugcolor_title",
						desc_id = "wolfhud_hudlist_thugcolor_desc",
						value = {"HUDList", "thug_color"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_copcolor_title",
						desc_id = "wolfhud_hudlist_copcolor_desc",
						value = {"HUDList", "enemy_color"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_hudlist_specialcolor_title",
						desc_id = "wolfhud_hudlist_specialcolor_desc",
						value = {"HUDList", "special_color"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = false,
					},
					{
						type ="divider",
						size = 16,
					},
					{
						type = "slider",
						name_id = "wolfhud_hudlist_scale_right_title",
						desc_id = "wolfhud_hudlist_scale_right_desc",
						value = {"HUDList", "right_list_scale"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						min_value = 0.5,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type = "slider",
						name_id = "wolfhud_hudlist_scale_left_title",
						desc_id = "wolfhud_hudlist_scale_left_desc",
						value = {"HUDList", "left_list_scale"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						min_value = 0.5,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type = "slider",
						name_id = "wolfhud_hudlist_scale_buff_title",
						desc_id = "wolfhud_hudlist_scale_buff_desc",
						value = {"HUDList", "buff_list_scale"},
						visible_reqs = {
							{ setting = { "HUDList", "ENABLED" }, invert = false },
						},
						min_value = 0.5,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type ="divider",
						size = 8,
					},
					{
						type = "menu",
						menu_id = "wolfhud_hudlist_left_options_menu",
						name_id = "wolfhud_infopanels_left_options_name",
						desc_id = "wolfhud_infopanels_left_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_timers_title",
								desc_id = "wolfhud_hudlist_show_timers_desc",
								value = {"HUDList", "LEFT_LIST", "show_timers"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_ammo_bags_title",
								desc_id = "wolfhud_hudlist_show_equipment_desc",
								value = {"HUDList", "LEFT_LIST", "show_ammo_bags"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_doc_bags_title",
								desc_id = "wolfhud_hudlist_show_equipment_desc",
								value = {"HUDList", "LEFT_LIST", "show_doc_bags"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_first_aid_kits_title",
								desc_id = "wolfhud_hudlist_show_equipment_desc",
								value = {"HUDList", "LEFT_LIST", "show_first_aid_kits"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_body_bags_title",
								desc_id = "wolfhud_hudlist_show_equipment_desc",
								value = {"HUDList", "LEFT_LIST", "show_body_bags"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_grenade_crates_title",
								desc_id = "wolfhud_hudlist_show_equipment_desc",
								value = {"HUDList", "LEFT_LIST", "show_grenade_crates"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_sentries_title",
								desc_id = "wolfhud_hudlist_sentries_desc",
								value = {"HUDList", "LEFT_LIST", "show_sentries"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_ecms_title",
								desc_id = "wolfhud_hudlist_show_ecms_desc",
								value = {"HUDList", "LEFT_LIST", "show_ecms"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_ecm_retrigger_title",
								desc_id = "wolfhud_hudlist_show_ecm_retrigger_desc",
								value = {"HUDList", "LEFT_LIST", "show_ecm_retrigger"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_minions_title",
								desc_id = "wolfhud_hudlist_show_minions_desc",
								value = {"HUDList", "LEFT_LIST", "show_minions"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_pagers_title",
								desc_id = "wolfhud_hudlist_show_pagers_desc",
								value = {"HUDList", "LEFT_LIST", "show_pagers"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_tape_loop_title",
								desc_id = "wolfhud_hudlist_show_tape_loop_desc",
								value = {"HUDList", "LEFT_LIST", "show_tape_loop"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
						},
					},
					{
						type = "menu",
						menu_id = "wolfhud_hudlist_right_options_menu",
						name_id = "wolfhud_infopanels_right_options_name",
						desc_id = "wolfhud_infopanels_right_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_enemies_title",
								desc_id = "wolfhud_hudlist_show_enemies_desc",
								value = {"HUDList", "RIGHT_LIST", "show_enemies"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_aggregate_enemies_title",
								desc_id = "wolfhud_hudlist_aggregate_enemies_desc",
								value = {"HUDList", "RIGHT_LIST", "aggregate_enemies"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = { "HUDList", "RIGHT_LIST", "show_enemies" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_turrets_title",
								desc_id = "wolfhud_hudlist_show_turrets_desc",
								value = {"HUDList", "RIGHT_LIST", "show_turrets"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_civilians_title",
								desc_id = "wolfhud_hudlist_show_civilians_desc",
								value = {"HUDList", "RIGHT_LIST", "show_civilians"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_hostages_title",
								desc_id = "wolfhud_hudlist_show_hostages_desc",
								value = {"HUDList", "RIGHT_LIST", "show_hostages"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_aggregate_hostages_title",
								desc_id = "wolfhud_hudlist_aggregate_hostages_desc",
								value = {"HUDList", "RIGHT_LIST", "aggregate_hostages"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = {"HUDList", "RIGHT_LIST",  "show_hostages"}, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_minion_count_title",
								desc_id = "wolfhud_hudlist_show_minion_count_desc",
								value = {"HUDList", "RIGHT_LIST", "show_minion_count"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_pager_count_title",
								desc_id = "wolfhud_hudlist_show_pager_count_desc",
								value = {"HUDList", "RIGHT_LIST", "show_pager_count"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_cam_count_title",
								desc_id = "wolfhud_hudlist_show_cam_count_desc",
								value = {"HUDList", "RIGHT_LIST", "show_cam_count"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_bodybags_count_title",
								desc_id = "wolfhud_hudlist_show_bodybags_count_desc",
								value = {"HUDList", "RIGHT_LIST", "show_bodybags_count"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_corpse_count_title",
								desc_id = "wolfhud_hudlist_show_corpse_count_desc",
								value = {"HUDList", "RIGHT_LIST", "show_corpse_count"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_loot_title",
								desc_id = "wolfhud_hudlist_show_loot_desc",
								value = {"HUDList", "RIGHT_LIST", "show_loot"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_aggregate_loot_title",
								desc_id = "wolfhud_hudlist_aggregate_loot_desc",
								value = {"HUDList", "RIGHT_LIST", "aggregate_loot"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = { "HUDList", "RIGHT_LIST",  "show_loot" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_separate_bagged_loot_title",
								desc_id = "wolfhud_hudlist_separate_bagged_loot_desc",
								value = {"HUDList", "RIGHT_LIST", "separate_bagged_loot"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = { "HUDList", "RIGHT_LIST",  "show_loot" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_potential_loot_title",
								desc_id = "wolfhud_hudlist_show_potential_loot_desc",
								value = {"HUDList", "RIGHT_LIST", "show_potential_loot"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_special_pickups_title",
								desc_id = "wolfhud_hudlist_show_special_pickups_desc",
								value = {"HUDList", "RIGHT_LIST", "show_special_pickups"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
						},
					},
					{
						type = "menu",
						menu_id = "wolfhud_hudlist_buffs_options_menu",
						name_id = "wolfhud_infopanels_buff_options_name",
						desc_id = "wolfhud_infopanels_buff_options_help",
						options = {
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_show_buffs_title",
								desc_id = "wolfhud_hudlist_show_buffs_desc",
								value = {"HUDList", "BUFF_LIST", "show_buffs"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
								},
							},
							{
								type = "divider",
								size = 16,
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_damage_increase_compbuff_title",
								desc_id = "wolfhud_hudlist_damage_increase_compbuff_desc",
								value = {"HUDList", "BUFF_LIST", "damage_reduction_compbuff"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_damage_reduction_compbuff_title",
								desc_id = "wolfhud_hudlist_damage_reduction_compbuff_desc",
								value = {"HUDList", "BUFF_LIST", "melee_damage_increase_compbuff"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
								},
							},
							{
								type = "toggle",
								name_id = "wolfhud_hudlist_melee_damage_increase_compbuff_title",
								desc_id = "wolfhud_hudlist_melee_damage_increase_compbuff_desc",
								value = {"HUDList", "BUFF_LIST", "show_buffs"},
								visible_reqs = {
									{ setting = { "HUDList", "ENABLED" }, invert = false },
									{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
								},
							},
							{
								type = "divider",
								size = 16,
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_mastermind_options_menu",
								name_id = "wolfhud_infopanels_buff_mastermind_options_name",
								desc_id = "wolfhud_infopanels_buff_mastermind_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_forced_friendship_teambuff_title",
										desc_id = "wolfhud_hudlist_forced_friendship_teambuff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "forced_friendship_teambuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "divider",
										size = 8
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_aggressive_reload_aced_buff_title",
										desc_id = "wolfhud_hudlist_aggressive_reload_aced_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "aggressive_reload_aced_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_ammo_efficiency_buff_title",
										desc_id = "wolfhud_hudlist_ammo_efficiency_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "ammo_efficiency_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_combat_medic_buff_title",
										desc_id = "wolfhud_hudlist_combat_medic_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "combat_medic_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_combat_medic_passive_buff_title",
										desc_id = "wolfhud_hudlist_combat_medic_passive_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "combat_medic_passive_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_hostage_taker_buff_title",
										desc_id = "wolfhud_hudlist_hostage_taker_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "hostage_taker_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_inspire_buff_title",
										desc_id = "wolfhud_hudlist_inspire_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_painkiller_buff_title",
										desc_id = "wolfhud_hudlist_painkiller_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "painkiller_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_partner_in_crime_buff_title",
										desc_id = "wolfhud_hudlist_partner_in_crime_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "partner_in_crime_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_quick_fix_buff_title",
										desc_id = "wolfhud_hudlist_quick_fix_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "quick_fix_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_uppers_buff_title",
										desc_id = "wolfhud_hudlist_uppers_buff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "uppers_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "divider", 
										size = 8,
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_inspire_debuff_title",
										desc_id = "wolfhud_hudlist_inspire_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_inspire_revive_debuff_title",
										desc_id = "wolfhud_hudlist_inspire_revive_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire_revive_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_enforcer_options_menu",
								name_id = "wolfhud_infopanels_buff_enforcer_options_name",
								desc_id = "wolfhud_infopanels_buff_enforcer_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_bulletproof_teambuff_title",
										desc_id = "wolfhud_hudlist_bulletproof_teambuff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bulletproof_teambuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "divider", 
										size = 8,
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_bullet_storm_buff_title",
										desc_id = "wolfhud_hudlist_bullet_storm_buff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bullet_storm_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_die_hard_buff_title",
										desc_id = "wolfhud_hudlist_die_hard_buff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "die_hard_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_overkill_buff_title",
										desc_id = "wolfhud_hudlist_overkill_buff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "overkill_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_underdog_buff_title",
										desc_id = "wolfhud_hudlist_underdog_buff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "underdog_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "divider", 
										size = 8,
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_bullseye_debuff_title",
										desc_id = "wolfhud_hudlist_bullseye_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bullseye_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_technician_options_menu",
								name_id = "wolfhud_infopanels_buff_technician_options_name",
								desc_id = "wolfhud_infopanels_buff_technician_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_lock_n_load_buff_title",
										desc_id = "wolfhud_hudlist_lock_n_load_buff_desc",
										value = {"HUDList", "BUFF_LIST", "TECHNICIAN_BUFFS", "lock_n_load_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_ghost_options_menu",
								name_id = "wolfhud_infopanels_buff_ghost_options_name",
								desc_id = "wolfhud_infopanels_buff_ghost_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_dire_need_buff_title",
										desc_id = "wolfhud_hudlist_dire_need_buff_desc",
										value = {"HUDList", "BUFF_LIST", "GHOST_BUFFS", "dire_need_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_second_wind_buff_title",
										desc_id = "wolfhud_hudlist_second_wind_buff_desc",
										value = {"HUDList", "BUFF_LIST", "GHOST_BUFFS", "second_wind_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_sixth_sense_buff_title",
										desc_id = "wolfhud_hudlist_sixth_sense_buff_desc",
										value = {"HUDList", "BUFF_LIST", "GHOST_BUFFS", "sixth_sense_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_unseen_strike_buff_title",
										desc_id = "wolfhud_hudlist_unseen_strike_buff_desc",
										value = {"HUDList", "BUFF_LIST", "GHOST_BUFFS", "unseen_strike_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_fugitive_options_menu",
								name_id = "wolfhud_infopanels_buff_fugitive_options_name",
								desc_id = "wolfhud_infopanels_buff_fugitive_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_berserker_buff_title",
										desc_id = "wolfhud_hudlist_berserker_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "berserker_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_bloodthirst_basic_buff_title",
										desc_id = "wolfhud_hudlist_bloodthirst_basic_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "bloodthirst_basic_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_bloodthirst_aced_buff_title",
										desc_id = "wolfhud_hudlist_bloodthirst_aced_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "bloodthirst_aced_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_desperado_buff_title",
										desc_id = "wolfhud_hudlist_desperado_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "desperado_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_frenzy_buff_title",
										desc_id = "wolfhud_hudlist_frenzy_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "frenzy_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_messiah_buff_title",
										desc_id = "wolfhud_hudlist_messiah_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "messiah_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_running_from_death_buff_title",
										desc_id = "wolfhud_hudlist_running_from_death_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "running_from_death_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_swan_song_buff_title",
										desc_id = "wolfhud_hudlist_swan_song_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "swan_song_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_trigger_happy_buff_title",
										desc_id = "wolfhud_hudlist_trigger_happy_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "trigger_happy_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_up_you_go_buff_title",
										desc_id = "wolfhud_hudlist_up_you_go_buff_desc",
										value = {"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "up_you_go_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
							{
								type = "menu",
								menu_id = "wolfhud_hudlist_buffs_perkdecks_options_menu",
								name_id = "wolfhud_infopanels_buff_perkdecks_options_name",
								desc_id = "wolfhud_infopanels_buff_perkdecks_options_help",
								options = {
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_armor_break_invulnerable_buff_title",
										desc_id = "wolfhud_hudlist_armor_break_invulnerable_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "armor_break_invulnerable_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_anarchist_armor_recovery_debuff_title",
										desc_id = "wolfhud_hudlist_anarchist_armor_recovery_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "anarchist_armor_recovery_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_armorer_teambuff_title",
										desc_id = "wolfhud_hudlist_armorer_teambuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "armorer_teambuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_biker_buff_title",
										desc_id = "wolfhud_hudlist_biker_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "biker_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_crew_chief_teambuff_title",
										desc_id = "wolfhud_hudlist_crew_chief_teambuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "crew_chief_teambuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_hostage_situation_buff_title",
										desc_id = "wolfhud_hudlist_hostage_situation_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "hostage_situation_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_ammo_give_out_debuff_title",
										desc_id = "wolfhud_hudlist_ammo_give_out_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "ammo_give_out_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_medical_supplies_debuff_title",
										desc_id = "wolfhud_hudlist_medical_supplies_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "medical_supplies_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_grinder_buff_title",
										desc_id = "wolfhud_hudlist_grinder_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "grinder_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_chico_injector_buff_title",
										desc_id = "wolfhud_hudlist_chico_injector_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "chico_injector_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_tooth_and_claw_buff_title",
										desc_id = "wolfhud_hudlist_tooth_and_claw_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "tooth_and_claw_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_close_contact_buff_title",
										desc_id = "wolfhud_hudlist_close_contact_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "close_contact_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_life_drain_debuff_title",
										desc_id = "wolfhud_hudlist_life_drain_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "life_drain_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_melee_stack_damage_buff_title",
										desc_id = "wolfhud_hudlist_melee_stack_damage_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "melee_stack_damage_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_overdog_buff_title",
										desc_id = "wolfhud_hudlist_overdog_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "overdog_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_maniac_buff_title",
										desc_id = "wolfhud_hudlist_maniac_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "maniac_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_muscle_regen_buff_title",
										desc_id = "wolfhud_hudlist_muscle_regen_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "muscle_regen_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_sociopath_debuff_title",
										desc_id = "wolfhud_hudlist_sociopath_debuff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "sociopath_debuff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
									{
										type = "toggle",
										name_id = "wolfhud_hudlist_yakuza_buff_title",
										desc_id = "wolfhud_hudlist_yakuza_buff_desc",
										value = {"HUDList", "BUFF_LIST", "PERK_BUFFS", "yakuza_buff"},
										visible_reqs = {
											{ setting = { "HUDList", "ENABLED" }, invert = false },
											{ setting = {"HUDList", "BUFF_LIST", "show_buffs"}, invert = false },
										},
									},
								},
							},
						},
					},
				},
			},
			{ --CustomWaypoints
				type = "menu",
				menu_id = "wolfhud_waypoint_options_menu",
				name_id = "wolfhud_waypoints_options_name",
				desc_id = "wolfhud_waypoints_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_ammo_bag_title",
						desc_id = "wolfhud_waypoints_show_ammo_bag_desc",
						value = {"CustomWaypoints", "SHOW_AMMO_BAG"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_doc_bag_title",
						desc_id = "wolfhud_waypoints_show_doc_bag_desc",
						value = {"CustomWaypoints", "SHOW_DOC_BAG"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_first_aid_kit_title",
						desc_id = "wolfhud_waypoints_show_first_aid_kit_desc",
						value = {"CustomWaypoints", "SHOW_FIRST_AID_KIT"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_body_bag_title",
						desc_id = "wolfhud_waypoints_show_body_bag_desc",
						value = {"CustomWaypoints", "SHOW_BODY_BAG"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_grenade_crate_title",
						desc_id = "wolfhud_waypoints_show_grenade_crate_desc",
						value = {"CustomWaypoints", "SHOW_GRENADE_CRATE"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_sentries_title",
						desc_id = "wolfhud_waypoints_show_sentries_desc",
						value = {"CustomWaypoints", "SHOW_SENTRIES"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_ecms_title",
						desc_id = "wolfhud_waypoints_show_ecms_desc",
						value = {"CustomWaypoints", "SHOW_ECMS"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_timers_title",
						desc_id = "wolfhud_waypoints_show_timers_desc",
						value = {"CustomWaypoints", "SHOW_TIMERS"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_loot_title",
						desc_id = "wolfhud_waypoints_show_loot_desc",
						value = {"CustomWaypoints", "SHOW_LOOT"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_special_equipment_title",
						desc_id = "wolfhud_waypoints_show_special_equipment_desc",
						value = {"CustomWaypoints", "SHOW_SPECIAL_EQUIPMENT"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_minions_title",
						desc_id = "wolfhud_waypoints_show_minions_desc",
						value = {"CustomWaypoints", "SHOW_MINIONS"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_waypoints_show_pager_title",
						desc_id = "wolfhud_waypoints_show_pager_desc",
						value = {"CustomWaypoints", "SHOW_PAGER"},
						visible_reqs = {},
					},
				},
			},
			{ --TabStats
				type = "menu",
				menu_id = "wolfhud_tabstats_options_menu",
				name_id = "wolfhud_tabstats_options_name",
				desc_id = "wolfhud_tabstats_options_help",
				options = {
					{
						type = "multi_choice",
						name_id = "wolfhud_tabstats_clock_mode_title",
						desc_id = "wolfhud_tabstats_clock_mode_desc",
						options = {
							"wolfhud_multiselect_disabled",
							"wolfhud_tabstats_clock_mode_a",
							"wolfhud_tabstats_clock_mode_b",
							"wolfhud_tabstats_clock_mode_c"
						},
						visible_reqs = {},
						value = {"TabStats", "CLOCK_MODE"},
					},
					{
						type = "divider",
						size = 16,
					},
					{
						type = "toggle",
						name_id = "wolfhud_use_tabstats_title",
						desc_id = "wolfhud_use_tabstats_desc",
						value = {"TabStats", "ENABLED"},
						visible_reqs = {},
					},
					{
						type = "slider",
						name_id = "wolfhud_tabstats_font_size_title",
						desc_id = "wolfhud_tabstats_font_size_desc",
						value = {"TabStats", "FONT_SIZE"},
						visible_reqs = {
							{ setting = { "TabStats", "ENABLED" }, invert = false },
						},
						min_value = 10,
						max_value = 24,
						step_size = 1,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_tabstats_color_title",
						desc_id = "wolfhud_tabstats_color_desc",
						value = {"TabStats", "COLOR"},
						visible_reqs = {
							{ setting = { "TabStats", "ENABLED" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = true,
					},
					{
						type = "toggle",
						name_id = "wolfhud_tabstats_actual_mask_title",
						desc_id = "wolfhud_tabstats_actual_mask_desc",
						value = {"TabStats", "SHOW_MASK"},
						visible_reqs = {
							{ setting = { "TabStats", "ENABLED" }, inverted = false }
						},
					},
					{
						type = "divider",
						size = 16,
					},
					{
						type = "toggle",
						name_id = "wolfhud_tabstats_numberic_loot_title",
						desc_id = "wolfhud_tabstats_numberic_loot_desc",
						value = {"TabStats", "SHOW_LOOT_NUMBERS"},
						visible_reqs = {},
					},
				},
			},
			{ --INTERACTION
				type = "menu",
				menu_id = "wolfhud_interaction_options_menu",
				name_id = "wolfhud_interaction_options_name",
				desc_id = "wolfhud_interaction_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_circle_title",
						desc_id = "wolfhud_press2hold_show_circle_desc",
						value = {"INTERACTION", "SHOW_CIRCLE"},
						visible_reqs = {},
					},
					{
						type = "slider",
						name_id = "wolfhud_press2hold_circle_scale_title",
						desc_id = "wolfhud_press2hold_circle_scale_desc",
						value = {"INTERACTION", "CIRCLE_SCALE"},
						visible_reqs = {},
						min_value = 0.3,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type = "slider",
						name_id = "wolfhud_press2hold_text_scale_title",
						desc_id = "wolfhud_press2hold_text_scale_desc",
						value = {"INTERACTION", "TEXT_SCALE"},
						visible_reqs = {},
						min_value = 0.3,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_reload_circle_title",
						desc_id = "wolfhud_press2hold_show_reload_circle_desc",
						value = {"INTERACTION", "SHOW_RELOAD"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_melee_circle_title",
						desc_id = "wolfhud_press2hold_show_melee_circle_desc",
						value = {"INTERACTION", "SHOW_MELEE"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_timer_title",
						desc_id = "wolfhud_press2hold_show_timer_desc",
						value = {"INTERACTION", "SHOW_TIME_REMAINING"},
						visible_reqs = {},
					},
					{
						type = "slider",
						name_id = "wolfhud_press2hold_timer_scale_title",
						desc_id = "wolfhud_press2hold_timer_scale_desc",
						value = {"INTERACTION", "TIMER_SCALE"},
						visible_reqs = {
							{ setting = { "INTERACTION", "SHOW_TIME_REMAINING" }, invert = false },
						},
						min_value = 0.3,
						max_value = 2,
						step_size = 0.01,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_press2hold_timer_color_start_title",
						desc_id = "wolfhud_press2hold_timer_color_start_desc",
						value = {"INTERACTION", "GRADIENT_COLOR_START"},
						visible_reqs = {
							{ setting = { "INTERACTION", "SHOW_TIME_REMAINING" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = true,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_press2hold_timer_color_title",
						desc_id = "wolfhud_press2hold_timer_color_desc",
						value = {"INTERACTION", "GRADIENT_COLOR"},
						visible_reqs = {
							{ setting = { "INTERACTION", "SHOW_TIME_REMAINING" }, invert = false },
						},
						options = {},
						add_color_options = true,
						add_rainbow = true,
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_timer_outline_title",
						desc_id = "wolfhud_press2hold_show_timer_outline_desc",
						value = {"INTERACTION", "SHOW_TIME_REMAINING_OUTLINE"},
						visible_reqs = {
							{ setting = { "INTERACTION", "SHOW_TIME_REMAINING" }, invert = false },
						},
					},
					{
						type = "divider",
						size = 24,
					},
					{
						type = "multi_choice",
						name_id = "wolfhud_press2hold_lock_mode_title",
						desc_id = "wolfhud_press2hold_lock_mode_desc",
						options = {
							"wolfhud_multiselect_disabled",
							"wolfhud_press2hold_lock_mode_a",
							"wolfhud_press2hold_lock_mode_b"
						},
						visible_reqs = {},
						value = {"INTERACTION", "LOCK_MODE"},
					},
					{
						type = "slider",
						name_id = "wolfhud_press2hold_min_timer_duration_title",
						desc_id = "wolfhud_press2hold_min_timer_duration_desc",
						value = {"INTERACTION", "MIN_TIMER_DURATION"},
						visible_reqs = {
							{ setting = { "INTERACTION", "LOCK_MODE" }, min = 2 },
						},
						min_value = 0,
						max_value = 45,
						step_size = 0.1,
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_show_lockindicator_title",
						desc_id = "wolfhud_press2hold_show_lockindicator_desc",
						value = {"INTERACTION", "SHOW_LOCK_INDICATOR"},
						visible_reqs = {
							{ setting = { "INTERACTION", "LOCK_MODE" }, min = 2 },
						},
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_equipment_cancel_title",
						desc_id = "wolfhud_press2hold_equipment_cancel_desc",
						value = {"INTERACTION", "EQUIPMENT_PRESS_INTERRUPT"},
						visible_reqs = {
							{ setting = { "INTERACTION", "LOCK_MODE" }, min = 2 },
						},
					},
					{
						type = "toggle",
						name_id = "wolfhud_press2hold_interrupt_hint_title",
						desc_id = "wolfhud_press2hold_interrupt_hint_desc",
						value = {"INTERACTION", "SHOW_INTERRUPT_HINT"},
						visible_reqs = {
							{ setting = { "INTERACTION", "LOCK_MODE" }, min = 2 },
						},
					},
					{
						type = "divider",
						size = 16,
					},
					{
						type = "toggle",
						name_id = "wolfhud_hold_to_pick_title",
						desc_id = "wolfhud_hold_to_pick_desc",
						value = {"INTERACTION", "HOLD2PICK"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_doubletap_nades_stealth_title",
						desc_id = "wolfhud_doubletap_nades_stealth_desc",
						value = {"INTERACTION", "SUPRESS_NADES_STEALTH"},
						visible_reqs = {},
					},
				},
			},
			{ --GADGETS
				type = "menu",
				menu_id = "wolfhud_gadget_options_menu",
				name_id = "wolfhud_gadget_options_name",
				desc_id = "wolfhud_gadget_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_laser_autoon_title",
						desc_id = "wolfhud_laser_autoon_desc",
						value = {"GADGETS", "LASER_AUTO_ON"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 16,
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_player_laser_options_menu",
						name_id = "wolfhud_gadget_player_laser_options_name",
						desc_id = "wolfhud_gadget_player_laser_options_help",
						options = get_gadget_options("laser", "player")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_player_sentry_laser_options_menu",
						name_id = "wolfhud_gadget_player_sentry_laser_options_name",
						desc_id = "wolfhud_gadget_player_sentry_laser_options_help",
						options = get_gadget_options("laser", "player_sentry")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_team_laser_options_menu",
						name_id = "wolfhud_gadget_team_laser_options_name",
						desc_id = "wolfhud_gadget_team_laser_options_help",
						options = get_gadget_options("laser", "team")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_team_sentry_laser_options_menu",
						name_id = "wolfhud_gadget_team_sentry_laser_options_name",
						desc_id = "wolfhud_gadget_team_sentry_laser_options_help",
						options = get_gadget_options("laser", "team_sentry")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_sniper_laser_options_menu",
						name_id = "wolfhud_gadget_sniper_laser_options_name",
						desc_id = "wolfhud_gadget_sniper_laser_options_help",
						options = get_gadget_options("laser", "cop_sniper")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_turret_laser_active_options_menu",
						name_id = "wolfhud_gadget_turret_laser_active_options_name",
						desc_id = "wolfhud_gadget_turret_laser_active_options_help",
						options = get_gadget_options("laser", "turret_module_active")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_turret_laser_rearming_options_menu",
						name_id = "wolfhud_gadget_turret_laser_rearming_options_name",
						desc_id = "wolfhud_gadget_turret_laser_rearming_options_help",
						options = get_gadget_options("laser", "turret_module_rearming")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_turret_laser_mad_options_menu",
						name_id = "wolfhud_gadget_turret_laser_mad_options_name",
						desc_id = "wolfhud_gadget_turret_laser_mad_options_help",
						options = get_gadget_options("laser", "turret_module_mad")
					},
					{
						type = "divider",
						size = 24,
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_player_flashlight_options_menu",
						name_id = "wolfhud_gadget_player_flashlight_options_name",
						desc_id = "wolfhud_gadget_player_flashlight_options_help",
						options = get_gadget_options("flashlight", "player")
					},
					{
						type = "menu",
						menu_id = "wolfhud_gadget_team_flashlight_options_menu",
						name_id = "wolfhud_gadget_team_flashlight_options_name",
						desc_id = "wolfhud_gadget_team_flashlight_options_help",
						options = get_gadget_options("flashlight", "team")
					},
					{
						type = "divider",
						size = 24,
					},
					{
						type = "toggle",
						name_id = "wolfhud_show_angeled_sight_title",
						desc_id = "wolfhud_show_angeled_sight_desc",
						value = {"GADGETS", "SHOW_ANGELED_SIGHT"},
						visible_reqs = {},
					},
				},
			},
			--INVENTORY & EQUIPMENT
			{
				type = "menu",
				menu_id = "wolfhud_inventory_options_menu",
				name_id = "wolfhud_inventory_options_name",
				desc_id = "wolfhud_inventory_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_replace_weapon_names_title",
						desc_id = "wolfhud_replace_weapon_names_desc",
						value = {"INVENTORY", "USE_REAL_WEAPON_NAMES"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_inventory_names_title",
						desc_id = "wolfhud_inventory_names_desc",
						value = {"INVENTORY", "SHOW_WEAPON_NAMES"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_show_mini_icons_title",
						desc_id = "wolfhud_show_mini_icons_desc",
						value = {"INVENTORY", "SHOW_WEAPON_MINI_ICONS"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_skill_names_title",
						desc_id = "wolfhud_skill_names_desc",
						value = {"INVENTORY", "SHOW_SKILL_NAMES"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 24,
					},
					{
						type = "toggle",
						name_id = "wolfhud_enable_burstmode_title",
						desc_id = "wolfhud_enable_burstmode_desc",
						value = {"EQUIPMENT", "ENABLE_BURSTMODE"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_equipment_senty_auto_ap_title",
						desc_id = "wolfhud_equipment_senty_auto_ap_desc",
						value = {"EQUIPMENT", "SENTRY_AUTO_AP"},
						visible_reqs = {},
					},
					{
						type = "toggle",
						name_id = "wolfhud_equipment_ecm_feedback_disabled_stealth_title",
						desc_id = "wolfhud_equipment_ecm_feedback_disabled_stealth_desc",
						value = {"EQUIPMENT", "ECM_FEEDBACK_STEALTH_DISABLED"},
						visible_reqs = {},
					},
				},
			},
			--SkipIt
			{
				type = "menu",
				menu_id = "wolfhud_skipit_options_menu",
				name_id = "wolfhud_skipit_options_name",
				desc_id = "wolfhud_skipit_options_help",
				options = {
					{
						type = "toggle",
						name_id = "wolfhud_skip_blackscreen_title",
						desc_id = "wolfhud_skip_blackscreen_desc",
						value = {"SkipIt", "SKIP_BLACKSCREEN"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_instant_restart_title",
						desc_id = "wolfhud_instant_restart_desc",
						value = {"SkipIt", "INSTANT_RESTART"},
						visible_reqs = {},
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_stat_screen_speedup_title",
						desc_id = "wolfhud_stat_screen_speedup_desc",
						value = {"SkipIt", "STAT_SCREEN_SPEEDUP"},
						visible_reqs = {},
					},
					{
						type = "slider",
						name_id = "wolfhud_stat_screen_delay_title",
						desc_id = "wolfhud_stat_screen_delay_desc",
						value = {"SkipIt", "STAT_SCREEN_DELAY"},
						visible_reqs = {},
						min_value = 0,
						max_value = 20,
						step_size = 0.1,
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_loot_screen_pick_card_title",
						desc_id = "wolfhud_loot_screen_pick_card_desc",
						value = {"SkipIt", "AUTOPICK_CARD"},
						visible_reqs = {},
					},
					{
						type = "slider",
						name_id = "wolfhud_loot_screen_delay_title",
						desc_id = "wolfhud_loot_screen_delay_desc",
						value = {"SkipIt", "LOOT_SCREEN_DELAY"},
						visible_reqs = {},
						min_value = 0,
						max_value = 20,
						step_size = 0.1,
					},
					{
						type = "divider",
						size = 8,
					},
					{
						type = "toggle",
						name_id = "wolfhud_no_slowmotion_title",
						desc_id = "wolfhud_no_slowmotion_desc",
						value = {"SkipIt", "NO_SLOWMOTION"},
						visible_reqs = {},
					},
				},
			},
			{
				type = "divider",
				size = 24,
			},
			{
				type = "button",
				name_id = "wolfhud_reset_options_title",
				desc_id = "wolfhud_reset_options_desc",
				clbk = "wolfhud_reset_clbk",
			},
		},
	}
end