--TODO: Passive Health Regen: check percentages, substract berserker reduction, calculate frenzy reduction
if not (WolfHUD and WolfHUD:getSetting({"HUDList", "ENABLED"}, true)) then return end

if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local format_time_string = function(value)
		local time_str

		if math.floor(value) > 60 and not (HUDListManager and HUDListManager.ListOptions.timers_in_seconds) then
			time_str = string.format("%d:%02d", math.floor(value / 60), math.floor(value % 60))
		elseif math.floor(value) > 9.9 then
			time_str = string.format("%d", math.floor(value))
		elseif value > 0 then
			time_str = string.format("%.1f", value)
		else
			time_str = string.format("%.1f", 0)
		end

		return time_str
	end

	local function get_distance_to_player(unit)
		local distance, rotation = 0, 360

		local cam = managers.viewport:get_current_camera()
		if alive(cam) and alive(unit) then
			local vector = unit:position() - cam:position()
			local forward = cam:rotation():y()
			distance = (mvector3.normalize(vector) or 0) / 100
			rotation = math.floor( vector:to_polar_with_reference( forward , math.UP ).spin )
		end

		local distance_str
		if math.floor(distance) > 9.9 then
			distance_str = string.format("%dm", distance)
		else
			distance_str = string.format("%.1fm", distance)
		end
		return distance_str, rotation
	end

	local function get_icon_data(icon)
		local texture = icon.texture
		local texture_rect = icon.texture_rect

		if icon.skills then
			texture = "guis/textures/pd2/skilltree/icons_atlas"
			local x, y = unpack(icon.skills)
			texture_rect = { x * 64, y * 64, 64, 64 }
		elseif icon.skills_new then
			texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
			local x, y = unpack(icon.skills_new)
			texture_rect = { x * 80, y * 80, 80, 80 }
		elseif icon.perks then
			texture = string.format("guis/%stextures/pd2/specialization/icons_atlas", icon.texture_bundle_folder and string.format("dlcs/%s/", tostring(icon.texture_bundle_folder)) or "")
			local x, y = unpack(icon.perks)
			texture_rect = { x * 64, y * 64, 64, 64 }
		elseif icon.preplanning then
			texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types"
			local x, y = unpack(icon.preplanning)
			texture_rect = { x * 48, y * 48, 48, 48 }
		elseif icon.hud_tweak then
			texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon.hud_tweak, texture_rect)
		elseif icon.hud_icons then
			texture = "guis/textures/hud_icons"
			texture_rect = icon.hud_icons
		elseif icon.hudtabs then
			texture = "guis/textures/pd2/hud_tabs"
			texture_rect = icon.hudtabs
		elseif icon.hudpickups then
			texture = "guis/textures/pd2/hud_pickups"
			texture_rect = icon.hudpickups
		elseif icon.waypoints then
			texture = "guis/textures/pd2/pd2_waypoints"
			texture_rect = icon.waypoints
		end

		return texture, texture_rect
	end

	local function get_color_from_table(value, max_value, color_table, default_color)
		local color_table = color_table or {
			{ ratio = 0.0, color = Color(1, 0.9, 0.1, 0.1) }, --Red
			{ ratio = 0.5, color = Color(1, 0.9, 0.9, 0.1) }, --Yellow
			{ ratio = 1.0, color = Color(1, 0.1, 0.9, 0.1) } --Green
		}
		local color = default_color or color_table[#color_table].color or Color.white
		if value and max_value then
			local ratio = math.clamp(value / max_value, 0 , 1)

			for i, data in ipairs(color_table) do
				if ratio < data.ratio then
					local nxt = color_table[math.clamp(i-1, 1, #color_table)]
					local scale = (ratio - data.ratio) / (nxt.ratio - data.ratio)
					color = Color(
						(data.color.alpha or 1) * (1-scale) + (nxt.color.alpha or 1) * scale,
						(data.color.red or 0) * (1-scale) + (nxt.color.red or 0) * scale,
						(data.color.green or 0) * (1-scale) + (nxt.color.green or 0) * scale,
						(data.color.blue or 0) * (1-scale) + (nxt.color.blue or 0) * scale)
					break
				end
			end
		end

		return color
	end

	local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
	local update_original = HUDManager.update
	local show_stats_screen_original = HUDManager.show_stats_screen
	local hide_stats_screen_original = HUDManager.hide_stats_screen

	function HUDManager:_setup_player_info_hud_pd2(...)
		_setup_player_info_hud_pd2_original(self, ...)
		if managers.gameinfo then
			managers.hudlist = HUDListManager:new()
		else
			WolfHUD:print_log("(HUDList) GameInfoManager not present!", "error")
		end
	end

	function HUDManager:update(t, dt, ...)
		if managers.hudlist then
			managers.hudlist:update(Application:time(), dt)	--TEST. See if this improves oddity with durations
		end

		return update_original(self, t, dt, ...)
	end

	function HUDManager:change_list_setting(setting, value)
		if managers.hudlist then
			return managers.hudlist:change_setting(setting, value)
		else
			HUDListManager.ListOptions[setting] = value
			return true
		end
	end

	function HUDManager:change_bufflist_setting(name, show)
		if managers.hudlist then
			return managers.hudlist:change_buff_ignore(name, not show)
		else
			HUDList.BuffItemBase.MAP[name].ignore = not show
			return true
		end
	end

	function HUDManager:change_pickuplist_setting(name, show)
		if managers.hudlist then
			return managers.hudlist:change_pickup_ignore(name, not show)
		else
			for _, data in pairs(HUDList.SpecialPickupItem.MAP) do
				if data.category == name then
					data.ignore = not show
				end
			end
			return true
		end
	end

	function HUDManager:show_stats_screen(...)
		if managers.hudlist then
			managers.hudlist:fade_lists(0.4)
		end
		return show_stats_screen_original(self, ...)
	end

	function HUDManager:hide_stats_screen(...)
		if managers.hudlist then
			managers.hudlist:fade_lists(1)
		end
		return hide_stats_screen_original(self, ...)
	end

	HUDListManager = HUDListManager or class()
	HUDListManager.ListOptions = {
		--General settings (Offsets get updated by Objective/Assault or CustomHUD)
		right_list_height_offset = 0,   										--Margin from top for the right list
		left_list_height_offset = 40,   										--Margin from top for the left list
		buff_list_height_offset = 90,   										--Margin from bottom for the buff list
		right_list_scale 				= WolfHUD:getSetting({"HUDList", "right_list_scale"}, 1),   	--Size scale of right list
		left_list_scale 				= WolfHUD:getSetting({"HUDList", "left_list_scale"}, 1),    	--Size scale of left list
		buff_list_scale 				= WolfHUD:getSetting({"HUDList", "buff_list_scale"}, 1),    	--Size scale of buff list
		right_list_progress_alpha 		= WolfHUD:getSetting({"HUDList", "right_list_progress_alpha"}, 0.4),
		left_list_progress_alpha 		= WolfHUD:getSetting({"HUDList", "left_list_progress_alpha"}, 0.4),
		buff_list_progress_alpha 		= WolfHUD:getSetting({"HUDList", "buff_list_progress_alpha"}, 1.0),
		
		timers_in_seconds 				= WolfHUD:getSetting({"HUDList", "timers_in_seconds"}, false),

		--Left side list
		show_timers 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_timers"}, true),     				--Drills, time locks, hacking etc.
		show_ammo_bags 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_ammo_bags"}, true),
		show_doc_bags 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_doc_bags"}, true),
		show_first_aid_kits				= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_first_aid_kits"}, false),
		show_body_bags 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_body_bags"}, true),
		show_grenade_crates 			= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_grenade_crates"}, true),
		show_sentries 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_sentries"}, true),   				--Deployable sentries
		show_ecms 						= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_ecms"}, true),       				--Active ECMs
		show_ecm_retrigger 				= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_ecm_retrigger"}, true),      		--Countdown for player owned ECM feedback retrigger delay
		show_minions 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_minions"}, true),    				--Converted enemies, type and health
			show_own_minions_only 		= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_own_minions_only"}, true),			--Only show player-owned minions
		show_pagers 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_pagers"}, true),     				--Show currently active pagers
		show_tape_loop 					= WolfHUD:getSetting({"HUDList", "LEFT_LIST", "show_tape_loop"}, true),  				--Show active tape loop duration

		--Right side list
		show_enemies 					= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_enemies"}, true),            		--Currently spawned enemies
			aggregate_enemies 			= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "aggregate_enemies"}, false),      			--Aggregate all enemies into a single item
		show_turrets 					= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_turrets"}, true),    				--Show active SWAT turrets
		show_civilians 					= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_civilians"}, true),  				--Currently spawned, untied civs
		show_hostages 					= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_hostages"}, true),   				--Currently tied civilian and dominated cops
			aggregate_hostages 			= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "aggregate_hostages"}, false),															--Aggregate all hostages into a single item
		show_minion_count 				= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_minion_count"}, true),       		--Current number of jokered enemies
		show_pager_count 				= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_pager_count"}, true),        		--Show number of triggered pagers (only counts pagers triggered while you were present)
		show_cam_count					= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_cam_count"}, true),
		show_bodybags_count				= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_bodybags_count"}, true),
		show_corpse_count				= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_corpse_count"}, true),
		show_loot 						= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_loot"}, true),       				--Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
			aggregate_loot 				= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "aggregate_loot"}, false), 					--Aggregate all loot into a single item
			separate_bagged_loot 		= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "separate_bagged_loot"}, true),     		--Show bagged/unbagged loot as separate values
			show_potential_loot			= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_potential_loot"}, false),
		show_special_pickups 			= WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_special_pickups"}, true),    		--Show number of special equipment/items

		--Buff list
		show_buffs 						= WolfHUD:getSetting({"HUDList", "BUFF_LIST", "show_buffs"}, true),       				--Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default

		list_color 						= WolfHUD:getColorSetting({"HUDList", "list_color"}, "white"),
		list_color_bg 					= WolfHUD:getColorSetting({"HUDList", "list_color_bg"}, "black"),
		civilian_color 					= WolfHUD:getColorSetting({"HUDList", "civilian_color"}, "white"),
		hostage_color 					= WolfHUD:getColorSetting({"HUDList", "civilian_color"}, "white"),
		thug_color 						= WolfHUD:getColorSetting({"HUDList", "thug_color"}, "white"),
		enemy_color 					= WolfHUD:getColorSetting({"HUDList", "enemy_color"}, "white"),
		guard_color 					= WolfHUD:getColorSetting({"HUDList", "enemy_color"}, "white"),
		special_color 					= WolfHUD:getColorSetting({"HUDList", "special_color"}, "white"),
		turret_color 					= WolfHUD:getColorSetting({"HUDList", "special_color"}, "white"),
	}

	HUDListManager.TIMER_SETTINGS = {
		shoutout_raid = {
			[132864] = {	--Meltdown vault temperature
				class = "TemperatureGaugeItem",
				params = { start = 0, goal = 50 },
			},
		},
		nail = {
			[135076] = { ignore = true },	--Lab rats cloaker safe 2
			[135246] = { ignore = true },	--Lab rats cloaker safe 3
			[135247] = { ignore = true },	--Lab rats cloaker safe 4
		},
		help = {
			[400003] = { ignore = true },	--Prison Nightmare Big Loot timer
		},
		hvh = {
			[100007] = { ignore = true },	--Cursed kill room timer
			[100888] = { ignore = true },	--Cursed kill room timer
			[100889] = { ignore = true },	--Cursed kill room timer
			[100891] = { ignore = true },	--Cursed kill room timer
			[100892] = { ignore = true },	--Cursed kill room timer
			[100878] = { ignore = true },	--Cursed kill room timer
			[100176] = { ignore = true },	--Cursed kill room timer
			[100177] = { ignore = true },	--Cursed kill room timer
			[100029] = { ignore = true },	--Cursed kill room timer
			[141821] = { ignore = true },	--Cursed kill room safe 1 timer
			[141822] = { ignore = true },	--Cursed kill room safe 1 timer
			[140321] = { ignore = true },	--Cursed kill room safe 2 timer
			[140322] = { ignore = true },	--Cursed kill room safe 2 timer
			[139821] = { ignore = true },	--Cursed kill room safe 3 timer
			[139822] = { ignore = true },	--Cursed kill room safe 3 timer
			[141321] = { ignore = true },	--Cursed kill room safe 4 timer
			[141322] = { ignore = true },	--Cursed kill room safe 4 timer
			[140821] = { ignore = true },	--Cursed kill room safe 5 timer
			[140822] = { ignore = true },	--Cursed kill room safe 5 timer
		}
	}

	HUDListManager.UNIT_TYPES = {
		cop = 						{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_cop" 					},
		cop_female = 				{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_cop" 					},
		fbi = 						{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_fbi" 					},
		swat = 						{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_swat" 					},
		heavy_swat = 				{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_heavy_swat" 				},
        heavy_swat_sniper =         { type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_heavy_swat_sniper"   	},
		fbi_swat = 					{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_swat" 					},
		fbi_heavy_swat = 			{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_heavy_swat" 				},
		city_swat = 				{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_city_swat" 				},
		security = 					{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_security" 				},
		security_undominatable = 	{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_security" 				},
		security_mex = 				{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_security" 				},
		security_mex_no_pager = 	{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_security" 				},
		gensec = 					{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_gensec" 					},
		bolivian_indoors =			{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_bolivian_security" 		},
		bolivian_indoors_mex =		{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_bolivian_security_mex" 	},
		bolivian =					{ type_id = "thug",			category = "enemies",	long_name = "wolfhud_enemy_bolivian_thug" 			},
		gangster = 					{ type_id = "thug",			category = "enemies",	long_name = "wolfhud_enemy_gangster" 				},
		mobster = 					{ type_id = "thug",			category = "enemies",	long_name = "wolfhud_enemy_mobster" 				},
		biker = 					{ type_id = "thug",			category = "enemies",	long_name = "wolfhud_enemy_biker" 					},
		biker_escape = 				{ type_id = "thug",			category = "enemies",	long_name = "wolfhud_enemy_biker" 					},
		tank = 						{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank" 					},
		tank_hw = 					{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank_hw" 				},
		tank_medic = 				{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank_medic" 				},
		tank_mini = 				{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank_mini" 				},
		spooc = 					{ type_id = "spooc",		category = "enemies",	long_name = "wolfhud_enemy_spook" 					},
		shadow_spooc = 				{ type_id = "spooc",		category = "enemies",	long_name = "wolfhud_enemy_shadow_spook" 			},
		taser = 					{ type_id = "taser",		category = "enemies",	long_name = "wolfhud_enemy_taser" 					},
		shield = 					{ type_id = "shield",		category = "enemies",	long_name = "wolfhud_enemy_shield" 					},
		sniper = 					{ type_id = "sniper",		category = "enemies",	long_name = "wolfhud_enemy_sniper" 					},
		medic = 					{ type_id = "medic",		category = "enemies",	long_name = "wolfhud_enemy_medic" 					},
		biker_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_biker_boss" 				},
		chavez_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_chavez_boss" 			},
		drug_lord_boss =			{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_druglord_boss" 			},
		drug_lord_boss_stealth =	{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_druglord_boss_stealth" 	},
		hector_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_hector_boss" 			},
		hector_boss_no_armor = 		{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_hector_boss_no_armor" 	},
		mobster_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "wolfhud_enemy_mobster_boss" 			},
		phalanx_vip = 				{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_phalanx_vip" 			},
		phalanx_minion = 			{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_phalanx_minion" 			},
		civilian = 					{ type_id = "civ",			category = "civilians",	long_name = "wolfhud_enemy_civilian" 				},
		civilian_female = 			{ type_id = "civ",			category = "civilians",	long_name = "wolfhud_enemy_civilian" 				},
		civilian_mariachi = 		{ type_id = "civ",			category = "civilians",	long_name = "wolfhud_enemy_civilian" 				},
		bank_manager = 				{ type_id = "civ",			category = "civilians",	long_name = "wolfhud_enemy_bank_manager" 			},
		--drunk_pilot = 			{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_drunk_pilot" 			},	--White x-Mas
		--escort = 					{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_escort" 					},	--?
		--old_hoxton_mission = 		{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_old_hoxton_mission" 		},	--Hox Breakout / BtM (Locke)
		--inside_man = 				{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_inside_man" 				},	--FWB
		--boris = 					{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_boris" 					},	--Goat Sim Day 2
		--escort_undercover = 		{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_escort_undercover" 		},	--Taxman, Undercover + Matt, Heat Street
		--escort_chinese_prisoner = { type_id = "unique", 		category = "civilians", long_name = "wolfhud_enemy_escort_chinese_prisoner" },	--Kazo, Green Bridge
		--spa_vip = 				{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_spa_vip" 				},	--Charon, Wick Heist
		--spa_vip_hurt = 			{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_spa_vip_hurt" 			},	--Charon, Wick Heist
		--escort_criminal = 		{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_escort_criminal" 		},	--???, Breakfast

		--Custom unit definitions
		--mechanic = 				{ type_id = "unique",		category = "civilians",	long_name = "wolfhud_enemy_biker_mechanic" 			},	-- Mechanic, Biker Heist
		turret = 					{ type_id = "turret",		category = "turrets",	long_name = "wolfhud_enemy_swat_van" 				},
		cop_hostage =				{ type_id = "cop_hostage",	category = "hostages",	force_update = { "cop", "enemies" } 				},
		sec_hostage =				{ type_id = "cop_hostage",	category = "hostages",	force_update = { "security", "enemies" } 			},
		civ_hostage =				{ type_id = "civ_hostage",	category = "hostages",	force_update = { "civ", "civilians" } 				},
		cop_minion =				{ type_id = "minion",		category = "minions",	force_update = { "cop", "enemies" } 				},
		sec_minion =				{ type_id = "minion",		category = "minions",	force_update = { "security", "enemies" }			},
		
		--Restoration Overhaul Enemies
		boom = 						{ type_id = "grenadier",	category = "enemies",	long_name = "wolfhud_enemy_boom" 					},
		omnia_lpf = 				{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_omnia_lpf" 				},
		summers = 					{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_summers" 				},
		boom_summers = 				{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_boom_summers" 			},
		taser_summers = 			{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_taser_summers" 			},
		medic_summers = 			{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_medic_summers" 			},
		spring = 					{ type_id = "phalanx",		category = "enemies",	long_name = "wolfhud_enemy_spring" 					},
		fbi_vet = 					{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_fbi_vet" 				},

		--Crackdown Enemies
		deathvox_lightar = 			{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_deathvox_light" },
		deathvox_heavyar = 			{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_deathvox_heavy" },
		deathvox_lightshot = 		{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_deathvox_light" },
		deathvox_heavyshot = 		{ type_id = "cop",			category = "enemies",	long_name = "wolfhud_enemy_deathvox_heavy" },
		deathvox_greendozer = 		{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank" },
		deathvox_blackdozer = 		{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank" },
		deathvox_lmgdozer = 		{ type_id = "tank",			category = "enemies",	long_name = "wolfhud_enemy_tank" },
		deathvox_medicdozer =		{ type_id = "tank_med",		category = "enemies",	long_name = "wolfhud_enemy_tank_medic" },
		deathvox_cloaker =			{ type_id = "spooc",		category = "enemies",	long_name = "wolfhud_enemy_spooc" },
		deathvox_taser =			{ type_id = "taser",		category = "enemies",	long_name = "wolfhud_enemy_taser" },
		deathvox_shield =			{ type_id = "shield",		category = "enemies",	long_name = "wolfhud_enemy_shield" },
		deathvox_sniper =			{ type_id = "sniper",		category = "enemies",	long_name = "wolfhud_enemy_sniper" },
		deathvox_medic =			{ type_id = "medic",		category = "enemies",	long_name = "wolfhud_enemy_medic" },
		deathvox_grenadier =		{ type_id = "grenadier",	category = "enemies",	long_name = "wolfhud_enemy_boom" },
		deathvox_guard =			{ type_id = "security",		category = "enemies",	long_name = "wolfhud_enemy_security" },
	}

	HUDListManager.SPECIAL_PICKUP_TYPES = {
		gen_pku_crowbar =					"crowbar",
		pickup_keycard =					"keycard",
		pickup_hotel_room_keycard =			"keycard",
		gage_assignment =					"courier",
		pickup_case = 						"gage_case",
		pickup_keys = 						"gage_key",
		hold_take_mask = 					"paycheck_masks",
		pickup_boards =						"planks",
		stash_planks_pickup =				"planks",
		muriatic_acid =						"meth_ingredients",
		hydrogen_chloride =					"meth_ingredients",
		caustic_soda =						"meth_ingredients",
		gen_pku_blow_torch =				"blowtorch",
		drk_pku_blow_torch = 				"blowtorch",
		hold_born_receive_item_blow_torch = "blowtorch",
		thermite = 							"thermite",
		gasoline_engine = 					"thermite",
		gen_pku_thermite = 					"thermite",
		gen_pku_thermite_paste = 			"thermite",
		gen_int_thermite_rig = 				"thermite",
		hold_take_gas_can = 				"thermite",
		gen_pku_thermite_paste_z_axis = 	"thermite",
		c4_bag = 							"c4",
		money_wrap_single_bundle = 			"small_loot",
		money_wrap_single_bundle_active = 	"small_loot",
		money_wrap_single_bundle_dyn = 		"small_loot",
		cas_chips_pile = 					"small_loot",
		diamond_pickup = 					"small_loot",
		diamond_pickup_pal = 				"small_loot",
		diamond_pickup_axis = 				"small_loot",
		safe_loot_pickup = 					"small_loot",
		pickup_tablet = 					"small_loot",
		pickup_phone = 						"small_loot",
		press_pick_up =						"secret_item",
		hold_pick_up_turtle = 				"secret_item",
		diamond_single_pickup_axis = 		"secret_item",
		ring_band = 						"rings",
		glc_hold_take_handcuffs = 			"handcuffs",
		hold_take_missing_animal_poster = 	"poster",
		press_take_folder = 				"poster",
		--take_confidential_folder_icc = 		"poster",
		take_jfr_briefcase = 				"briefcase",
	}

	HUDListManager.LOOT_TYPES = {
		ammo =						"shell",
		artifact_statue =			"artifact",
		bike_part_light = 			"bike",
		bike_part_heavy = 			"bike",
		circuit =					"server",
		cloaker_cocaine = 			"coke",
		cloaker_gold = 				"gold",
		cloaker_money = 			"money",
		coke =						"coke",
		coke_pure =					"coke",
		counterfeit_money =			"money",
		cro_loot1 =					"bomb",
		cro_loot2 =					"bomb",
		diamonds =					"jewelry",
		diamond_necklace = 			"jewelry",
		din_pig =					"pig",
		drk_bomb_part =				"bomb",
		drone_control_helmet =		"drone_ctrl",
		evidence_bag =				"evidence",
		expensive_vine = 			"wine",
		faberge_egg = 				"egg",
		goat = 						"goat",
		gold =						"gold",
		hope_diamond =				"diamond",
		diamonds_dah = 				"diamonds",
		red_diamond = 				"diamond",
		lost_artifact = 			"artifact",
		mad_master_server_value_1 =	"server",
		mad_master_server_value_2 =	"server",
		mad_master_server_value_3 =	"server",
		mad_master_server_value_4 =	"server",
		master_server = 			"server",
		masterpiece_painting =		"painting",
		meth =						"meth",
		meth_half =					"meth",
		money =						"money",
		mus_artifact =				"artifact",
		mus_artifact_paint =		"painting",
		old_wine = 					"wine",
		ordinary_wine = 			"wine",
		painting =					"painting",
		person =					"body",
		present = 					"present",
		prototype = 				"prototype",
		robot_toy = 				"toy",
		safe_ovk =					"safe",
		safe_wpn =					"safe",
		samurai_suit =				"armor",
		roman_armor = 				"armor",
		sandwich =					"toast",
		special_person =			"body",
		toothbrush = 				"toothbrush",
		treasure = 					"treasure",
		turret =					"turret",
		unknown =					"dentist",
		box_unknown = 				"dentist",
		box_unknown_tag = 			"dentist",
		black_tablet = 				"dentist",
		vr_headset = 				"vr",
		warhead =					"warhead",
		weapon =					"weapon",
		weapon_glock =				"weapon",
		weapon_scar =				"weapon",
		women_shoes = 				"shoes",
		yayo = 						"coke",
	}

	HUDListManager.POTENTIAL_LOOT_TYPES = {
		crate = 					"crate",
		xmas_present = 				"xmas_present",
		shopping_bag = 				"shopping_bag",
		showcase = 					"showcase",
	}

	HUDListManager.LOOT_TYPES_CONDITIONS = {
		body = function(id, data)
			if managers.job:current_level_id() == "mad" then	-- Boiling Point
				return data.bagged or data.unit:editor_id() ~= -1
			end
		end,
		crate = function(id, data)
			local level_id = managers.job:current_level_id()
			local disabled_lvls = {
				"election_day_3", 		-- Election Day Day 2 Warehouse
				"election_day_3_skip1",
				"election_day_3_skip2",
				"mia_1",		 		-- Hotline Miami Day 1
				"pal" 					-- Counterfeit
			}
			return not (level_id and table.contains(disabled_lvls, level_id))
		end,
		showcase = function(id, data)
			local level_id = managers.job:current_level_id()
			local disabled_lvls = {
				"mus", 		-- The Diamond
				"sah",		-- Shacklethorne Auction
			}
			return not (level_id and table.contains(disabled_lvls, level_id))
		end,
	}

	HUDListManager.BUFFS = {
		--Buff list items affected by specific buffs/debuffs. Add entries if buff ID differs from the HUDList buff entry for some reason, or if a single buff ID affect multiple items
		berserker = { "berserker", "damage_increase", "melee_damage_increase" },
		berserker_aced = { "berserker", "damage_increase" },										--TODO: buff remains after expiration, base game does not reset upgrade value
		bloodthirst_basic = { "bloodthirst_basic", "melee_damage_increase" },
		chico_injector = { "chico_injector", "damage_reduction" },
		close_contact_1 = { "close_contact", "damage_reduction" },
		close_contact_2 = { "close_contact", "damage_reduction" },
		close_contact_3 = { "close_contact", "damage_reduction" },
		combat_medic = { "combat_medic", "damage_reduction" },
		combat_medic_passive = { "combat_medic_passive", "damage_reduction" },
		crew_health_regen = { "crew_health_regen", "passive_health_regen" },
		die_hard = { "die_hard", "damage_reduction" },
		frenzy = { "frenzy", "damage_reduction" },
		hostage_situation = { "hostage_situation", "damage_reduction" },
		hostage_taker = { "hostage_taker", "passive_health_regen" },
		maniac = { "maniac", "damage_reduction" },
		melee_stack_damage = { "melee_stack_damage", "melee_damage_increase" },
		movement_dodge = { "total_dodge_chance" },
		muscle_regen = { "muscle_regen", "passive_health_regen" },
		overdog = { "overdog", "damage_reduction" },
		overkill = { "overkill", "damage_increase" },
		overkill_aced = { "overkill", "damage_increase" },
		pain_killer = { "painkiller", "damage_reduction" },
		pain_killer_aced = { "painkiller", "damage_reduction" },
		partner_in_crime_aced = { "partner_in_crime" },
		pocket_ecm_kill_dodge =	{ "pocket_ecm_kill_dodge", "total_dodge_chance" },
		quick_fix = { "quick_fix", "damage_reduction" },
		running_from_death_basic = { "running_from_death" },
		running_from_death_aced = { "running_from_death" },
		sicario_dodge = { "sicario_dodge", "total_dodge_chance" },
		smoke_screen_grenade = { "smoke_screen_grenade", "total_dodge_chance" },
		swan_song_aced = { "swan_song" },
		trigger_happy = { "trigger_happy", "damage_increase" },
		underdog = { "underdog", "damage_increase" },
		underdog_aced = { "underdog", "damage_reduction" },
		up_you_go = { "up_you_go", "damage_reduction" },
		yakuza_recovery = { "yakuza" },
		yakuza_speed = { "yakuza" },

		armorer_9 = { "armorer" },
		crew_chief_1 = { "crew_chief", "damage_reduction" },	--Bonus for <50% health changed separately through set_value
		crew_chief_3 = { "crew_chief" },
		crew_chief_5 = { "crew_chief" },
		crew_chief_9 = { "crew_chief" },	--Damage reduction from hostages covered by hostage_situation

		--Debuffs that are merged into the buff itself
		composite_debuffs = {
			armor_break_invulnerable_debuff = "armor_break_invulnerable",
			grinder_debuff = "grinder",
			chico_injector_debuff = "chico_injector",
			delayed_damage_debuff = "delayed_damage",
			maniac_debuff = "maniac",
			pocket_ecm_jammer_debuff = "pocket_ecm_jammer",
			sicario_dodge_debuff = "sicario_dodge",
			smoke_screen_grenade_debuff = "smoke_screen_grenade",
			tag_team_debuff = "tag_team",
			unseen_strike_debuff = "unseen_strike",
			uppers_debuff = "uppers",
			interact_debuff = "interact",
		},
	}

	function HUDListManager:init()
		self._lists = {}
		self._unit_count_listeners = 0

		self:_setup_left_list()
		self:_setup_right_list()
		self:_setup_buff_list()

		managers.gameinfo:register_listener("HUDList_whisper_mode_listener", "whisper_mode", "change", callback(self, self, "_whisper_mode_change"))
	end

	function HUDListManager:update(t, dt)
		for _, list in pairs(self._lists) do
			if list:is_active() then
				list:update(t, dt)
			end
			if list:animation_active() then
				list:_animate_fade(t, dt)
				list:_animate_move(t, dt)
			end
		end
	end

	function HUDListManager:list(name)
		return self._lists[name]
	end

	function HUDListManager:lists()
		return self._lists
	end

	function HUDListManager:change_setting(setting, value)
		local clbk = "_set_" .. setting
		if HUDListManager[clbk] and HUDListManager.ListOptions[setting] ~= value then
			HUDListManager.ListOptions[setting] = value
			self[clbk](self, value)
			return true
		end
	end

	function HUDListManager:change_buff_ignore(buff_id, ignore)
		local buff_map = HUDList.BuffItemBase.MAP
		if buff_map[buff_id] and buff_map[buff_id].ignore ~= ignore then
			buff_map[buff_id].ignore = ignore

			local buff_list = self:list("buff_list")
			local item = buff_list and buff_list:item(buff_id)
			if item then
				buff_list:set_item_disabled(item, "setting", ignore)
			end
		end
	end

	function HUDListManager:change_pickup_ignore(category_id, ignore)
		local pickup_list = self:list("right_side_list"):item("special_pickup_list")
		for _, item in pairs(pickup_list:items()) do
			local pickup_type = item:name()
			local pickup_data = pickup_type and HUDList.SpecialPickupItem.MAP[pickup_type]
			if pickup_data and pickup_data.category == category_id then
				pickup_list:set_item_disabled(item, "setting", ignore)
				pickup_data.ignore = ignore
			end
		end
	end

	function HUDListManager:fade_lists(alpha)
		for _, list in pairs(self._lists) do
			if list:is_active() then
				list:_fade(alpha)
			end
		end
	end

	function HUDListManager:register_list(name, class, params, ...)
		if not self._lists[name] then
			class = type(class) == "string" and _G.HUDList[class] or class
			self._lists[name] = class and class:new(nil, name, params, ...)
		end

		return self._lists[name]
	end

	function HUDListManager:unregister_list(name, instant)
		if self._lists[name] then
			self._lists[name]:delete(instant)
		end
		self._lists[name] = nil
	end

	function HUDListManager:_setup_left_list()
		local list_width = 500
		local list_height = 450
		local x = 0
		local y = HUDListManager.ListOptions.left_list_height_offset or 40
		local scale = HUDListManager.ListOptions.left_list_scale or 1
		local list = self:register_list("left_side_list", HUDList.VerticalList, { align = "left", x = x, y = y, w = list_width, h = list_height, scale = scale, top_to_bottom = true, item_margin = 5 })

		--Timers
		local timer_list = list:register_item("timers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5, priority = 3, recheck_interval = 1 })
		timer_list:set_static_item(HUDList.LeftListIcon, 1, 4/5, {
			{ skills = {3, 6}, color = HUDListManager.ListOptions.list_color },
		})

		--Deployables
		local equipment_list = list:register_item("equipment", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5, priority = 1 })
		equipment_list:set_static_item(HUDList.LeftListIcon, 1, 1, {
			{ skills = HUDList.EquipmentItem.EQUIPMENT_TABLE.ammo_bag.skills, h = 0.55, w = 0.55, valign = "top", halign = "right", color = HUDListManager.ListOptions.list_color },
			{ skills = HUDList.EquipmentItem.EQUIPMENT_TABLE.doc_bag.skills, h = 0.55, w = 0.55, valign = "top", halign = "left", color = HUDListManager.ListOptions.list_color },
			{ skills = HUDList.EquipmentItem.EQUIPMENT_TABLE.sentry.skills, h = 0.55, w = 0.55, valign = "bottom", halign = "right", color = HUDListManager.ListOptions.list_color },
			{ skills = HUDList.EquipmentItem.EQUIPMENT_TABLE.body_bag.skills, h = 0.55, w = 0.55, valign = "bottom", halign = "left", color = HUDListManager.ListOptions.list_color },
		})

		--Minions
		local minion_list = list:register_item("minions", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, left_to_right = true, item_margin = 5, priority = 4 })
		minion_list:set_static_item(HUDList.LeftListIcon, 1, 4/5, {
			{ skills = {6, 8} },
		})

		--Pagers
		local pager_list = list:register_item("pagers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5, priority = 2, recheck_interval = 1 })
		pager_list:set_static_item(HUDList.LeftListIcon, 1, 1, {
			{ perks = {1, 4}, color = HUDListManager.ListOptions.list_color },
		})

		--ECMs
		local ecm_list = list:register_item("ecms", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5, priority = 5 })
		ecm_list:set_static_item(HUDList.LeftListIcon, 1, 1, {
			{ skills = {1, 4}, color = HUDListManager.ListOptions.list_color },
		})

		--ECM trigger
		local retrigger_list = list:register_item("ecm_retrigger", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5, priority = 6 })
		retrigger_list:set_static_item(HUDList.LeftListIcon, 1, 1, {
			{ skills = {6, 2}, color = HUDListManager.ListOptions.list_color },
		})

		--Tape loop
		local tape_loop_list = list:register_item("tape_loop", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5, priority = 7 })
		tape_loop_list:set_static_item(HUDList.LeftListIcon, 1, 1, {
			{ skills = {4, 2}, color = HUDListManager.ListOptions.list_color },
		})

		self:_set_show_timers()
		self:_set_show_ammo_bags()
		self:_set_show_doc_bags()
		self:_set_show_first_aid_kits()
		self:_set_show_body_bags()
		self:_set_show_grenade_crates()
		self:_set_show_sentries()
		self:_set_show_minions()
		self:_set_show_pagers()
		self:_set_show_ecms()
		self:_set_show_ecm_retrigger()
		self:_set_show_tape_loop()
	end

	function HUDListManager:_setup_right_list()
		local list_width = 600
		local list_height = 500
		local x = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:right() - list_width
		local y = HUDListManager.ListOptions.right_list_height_offset or 0
		local scale = HUDListManager.ListOptions.right_list_scale or 1
		local list = self:register_list("right_side_list", HUDList.VerticalList, { align = "right", x = x, y = y, w = list_width, h = list_height, scale = scale, top_to_bottom = true, item_margin = 5 })

		local unit_count_list = list:register_item("unit_count_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 1 })
		local stealth_list = list:register_item("stealth_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 4 })
		local loot_list = list:register_item("loot_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 2 })
		local special_equipment_list = list:register_item("special_pickup_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 3 })

		self:_set_show_enemies()
		self:_set_show_turrets()
		self:_set_show_civilians()
		self:_set_show_hostages()
		self:_set_show_minion_count()
		self:_set_show_pager_count()
		self:_set_show_cam_count()
		self:_set_show_bodybags_count()
		self:_set_show_corpse_count()
		self:_set_show_loot()
		self:_set_show_potential_loot()
		self:_set_show_special_pickups()
	end

	function HUDListManager:_setup_buff_list()
		local hud_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel
		local scale = HUDListManager.ListOptions.buff_list_scale or 1
		local list_height = 70 * scale
		local list_width = hud_panel:w()
		local x = 0
		local y

		if HUDManager.CUSTOM_TEAMMATE_PANELS then
			y = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:panel():top() - (list_height + 10)
		else
			y = hud_panel:bottom() - ((HUDListManager.ListOptions.buff_list_height_offset or 90) + list_height)
		end

		if managers.subtitle then
			local sub_presenter = managers.subtitle:presenter()
			if sub_presenter and sub_presenter.set_bottom then
				sub_presenter:set_bottom(y - 10)
			end
		end

		local buff_list = self:register_list("buff_list", HUDList.HorizontalList, {
			align = "center",
			x = x,
			y = y ,
			w = list_width,
			h = list_height,
			scale = scale,
			centered = true,
			item_margin = 0,
			item_move_speed = 300,
			fade_time = 0.15
		})

		self:_set_show_buffs()
	end

	function HUDListManager:_whisper_mode_change(event, key, status)
		--[[
		for _, item in pairs(self:list("right_side_list"):item("stealth_list"):items()) do
			item:set_active(item:get_count() > 0 and status)
		end

		for _, item in pairs(self:list("left_side_list"):item("pagers"):items()) do
			item:set_active(status)
		end

		for _, item in pairs(self:list("left_side_list"):item("equipment"):items()) do
			if item:get_type() == "body_bag" then
				item:set_active(item:current_amount() > 0 and status)
			end
		end
		]]
		--[[
		local body_loot_item = self:list("right_side_list"):item("loot_list"):item("body")
		if body_loot_item then
			body_loot_item:set_count(0, 0)
		end
		]]
	end

	function HUDListManager:_get_buff_items(id)
		local buff_list = self:list("buff_list")
		local items = {}

		local function register_item(item_id)
			local item_data = HUDList.BuffItemBase.MAP[item_id]

			if item_data then
				local item = buff_list:item(item_id)
				if not item then
					item = buff_list:register_item(item_id, item_data.class or "BuffItemBase", item_data)
					buff_list:set_item_disabled(item, "setting", item_data.ignore)
				end
				table.insert(items, item)
			end
		end

		if HUDListManager.BUFFS[id] then
			for _, item_id in ipairs(HUDListManager.BUFFS[id]) do
				register_item(item_id)
			end
		else
			register_item(id)
		end

		return items
	end

	function HUDListManager:_get_units_by_category(category)
		local all_types = {}
		local all_ids = {}

		for unit_id, data in pairs(HUDListManager.UNIT_TYPES) do
			if data.category == category then
				all_types[data.type_id] = all_types[data.type_id] or {}
				table.insert(all_types[data.type_id], unit_id)
				table.insert(all_ids, unit_id)
			end
		end

		return all_types, all_ids
	end

	function HUDListManager:_update_unit_count_list_items(list, id, members, show)
		if show then
			local data = HUDList.UnitCountItem.MAP[id] or {}
			local item = list:register_item(id, data.class or HUDList.UnitCountItem, id, members)
		else
			list:unregister_item(id, true)
		end
	end

	function HUDListManager:_update_deployable_list_items(type, enabled)
		local list = self:list("left_side_list"):item("equipment")
		local listener_id = string.format("HUDListManager_%s_listener", type)
		local events = { "set_active" }
		local clbk = callback(self, self, string.format("_%s_event", type))

		for _, event in pairs(events) do
			if enabled then
				managers.gameinfo:register_listener(listener_id, type, event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, type, event)
			end
		end
		for key, data in pairs(managers.gameinfo:get_deployables(type)) do
			if enabled then
				clbk("set_active", key, data)
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_bag_deployable_event(event, key, data, class, bag_type)
		if data.aggregate_key then return end

		local equipment_list = self:list("left_side_list"):item("equipment")

		if event == "set_active" then
			if data.active then
				equipment_list:register_item(key, class, data, bag_type)
			else
				equipment_list:unregister_item(key)
			end
		end
	end

	--Event handlers
	function HUDListManager:_timer_event(event, key, data)
		local level_id = managers.job:current_level_id() or ""
		local settings = HUDListManager.TIMER_SETTINGS[level_id] and HUDListManager.TIMER_SETTINGS[level_id][data.id] or HUDListManager.TIMER_SETTINGS[data.device_type] or HUDList.TimerItem.DEVICE_TYPES[data.device_type] or {}

		if not settings.ignore then
			local timer_list = self:list("left_side_list"):item("timers")
			if event == "set_active" then
				if data.active then
					timer_list:register_item(key, settings.class or HUDList.TimerItem, data, settings.params):activate()
				else
					timer_list:unregister_item(key)
				end
			end
		end
	end

	function HUDListManager:_unit_count_event(event, unit_type, value)
		if HUDListManager.UNIT_TYPES[unit_type] then
			local list = self:list("right_side_list"):item("unit_count_list")
			local type_id = HUDListManager.UNIT_TYPES[unit_type].type_id
			local category = HUDListManager.UNIT_TYPES[unit_type].category

			local item = list:item(type_id) or list:item(category)

			if item then
				if event == "change" then
					item:change_count(value)
				elseif event == "set" then
					item:set_count(value)
				end

				for _, id in pairs(HUDListManager.UNIT_TYPES[unit_type].force_update or {}) do
					local item = list:item(id)
					if item then
						item:change_count(0)
					end
				end
			end
		end
	end

	function HUDListManager:_minion_event(event, key, data)
		local minion_list = self:list("left_side_list"):item("minions")

		if event == "add" then
			local item = minion_list:register_item(key, HUDList.MinionItem, data)

			if not HUDListManager.ListOptions.show_own_minions_only then
				item:activate()
			end
		elseif event == "remove" then
			minion_list:unregister_item(key)
		end
	end

	function HUDListManager:_pager_event(event, key, data)
		local pager_list = self:list("left_side_list"):item("pagers")

		if event == "add" then
			pager_list:register_item(key, HUDList.PagerItem, data):activate()
		elseif event == "remove" then
			pager_list:unregister_item(key)
		end
	end

	--[[
	function HUDListManager:_pager_count_event(event, key, data)
		local item = self:list("right_side_list"):item("stealth_list"):item("PagerCount")
		if item then
			item:change_count(1)
		end
	end
	function HUDListManager:_cam_count_event(event, key, data)
		local item = self:list("right_side_list"):item("stealth_list"):item("CamCount")
		if event == "add" or event == "enable" then
			item:change_count(1)
		elseif event == "disable" or event == "destroy" then
			item:change_count(-1)
		end
	end
	]]
	function HUDListManager:_bodybag_count_event(event, key, data)
		local item = self:list("right_side_list"):item("stealth_list"):item("BodyBagInv")
		local whisper_mode = managers.groupai:state():whisper_mode()
		if event == "set" and whisper_mode then
			item:set_count(key)
		end
	end

	function HUDListManager:_ecm_event(event, key, data)
		local list = self:list("left_side_list"):item("ecms")

		if event == "set_jammer_active" then
			if data.jammer_active then
				list:register_item(key, HUDList.ECMItem, data):activate()
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_ecm_retrigger_event(event, key, data)
		local list = self:list("left_side_list"):item("ecm_retrigger")

		if event == "set_retrigger_active" then
			if data.retrigger_active then
				list:register_item(string.format("%s_retrigger", key), HUDList.ECMRetriggerItem, data):activate()
			else
				list:unregister_item(string.format("%s_retrigger", key))
			end
		elseif event == "set_feedback_active" then
			if data.feedback_active then
				list:register_item(string.format("%s_feedback", key), HUDList.ECMFeedbackItem, data):activate()
			else
				list:unregister_item(string.format("%s_feedback", key))
			end
		end
	end

	function HUDListManager:_tape_loop_event(event, key, data)
		local list = self:list("left_side_list"):item("tape_loop")

		if event == "set_tape_loop_active" then
			if data.tape_loop_active then
				list:register_item(key, HUDList.TapeLoopItem, data):activate()
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_sentry_equipment_event(event, key, data)
		local equipment_list = self:list("left_side_list"):item("equipment")

		if event == "set_active" then
			if data.active then
				equipment_list:register_item(key, HUDList.SentryEquipmentItem, data):activate()
			end
		elseif event == "destroy" then
			equipment_list:unregister_item(key)
		end
	end

	function HUDListManager:_buff_event(event, id, data)
		WolfHUD:print_log("(HUDList) _buff_event(%s, %s)", tostring(event), tostring(id), "info")
		local items = self:_get_buff_items(id)

		for _, item in ipairs(items) do
			if item[event] then
				item[event](item, id, data)
			else
				WolfHUD:print_log("HUDList) _buff_event: No matching function for event %s for buff %s", tostring(event), tostring(id), "warning")
			end
		end

		if HUDListManager.BUFFS.composite_debuffs[id] then
			if event == "activate" or event == "deactivate" or event == "set_duration" then
				local debuff_parent_id = HUDListManager.BUFFS.composite_debuffs[id]
				self:_buff_event(event .. "_debuff", debuff_parent_id, data)
			end
		end
	end

	function HUDListManager:_player_action_event(event, id, data)
		self:_buff_event(event, id, data)
	end

	function HUDListManager:_ammo_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, HUDList.AmmoBagItem, "ammo_bag")
	end

	function HUDListManager:_doc_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, HUDList.BagEquipmentItem, "doc_bag")
	end

	function HUDListManager:_first_aid_kit_event(event, key, data)
		self:_bag_deployable_event(event, key, data, HUDList.BagEquipmentItem, "first_aid_kit")
	end

	function HUDListManager:_body_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, HUDList.BodyBagItem, "body_bag")
	end

	function HUDListManager:_grenade_crate_event(event, key, data)
		self:_bag_deployable_event(event, key, data, HUDList.BagEquipmentItem, "grenade_crate")
	end

	--General config
	function HUDListManager:_set_right_list_scale(scale)
		local list = self:list("right_side_list")
		list:rescale(scale or HUDListManager.ListOptions.right_list_scale)
	end

	function HUDListManager:_set_left_list_scale()
		local list = self:list("left_side_list")
		list:rescale(scale or HUDListManager.ListOptions.left_list_scale)
	end

	function HUDListManager:_set_buff_list_scale()
		local list = self:list("buff_list")
		local bottom = list:bottom()
		list:rescale(scale or HUDListManager.ListOptions.buff_list_scale)

		list:set_bottom(bottom)
		if managers.subtitle then
			local sub_presenter = managers.subtitle:presenter()
			if sub_presenter and sub_presenter.set_bottom then
				sub_presenter:set_bottom(list:top() - 10)
			end
		end
	end

	function HUDListManager:_set_right_list_height_offset()
		local list = self:list("right_side_list")
		if list then
			list:move(list:panel():x(), HUDListManager.ListOptions.right_list_height_offset or 40, false)
		end
	end

	function HUDListManager:_set_left_list_height_offset()
		local list = self:list("left_side_list")
		if list then
			list:move(list:panel():x(), HUDListManager.ListOptions.left_list_height_offset or 40, false)
		end
	end

	function HUDListManager:_set_buff_list_height_offset()
		local list = self:list("buff_list")
		if list then
			list:move(list:panel():x(), HUDListManager.ListOptions.buff_list_height_offset or 90, false)
		end
	end

	function HUDListManager:_set_right_list_progress_alpha(alpha)
		local list = self:list("right_side_list")
		if list then
			for _, sub_list in pairs(list:items()) do
				for _, item in pairs(sub_list:items()) do
					item:set_progress_alpha(alpha or HUDListManager.ListOptions.right_list_progress_alpha)
				end
			end
		end
	end

	function HUDListManager:_set_left_list_progress_alpha(alpha)
		local list = self:list("left_side_list")
		if list then
			for _, sub_list in pairs(list:items()) do
				for _, item in pairs(sub_list:items()) do
					item:set_progress_alpha(alpha or HUDListManager.ListOptions.left_list_progress_alpha)
				end
			end
		end
	end

	function HUDListManager:_set_buff_list_progress_alpha(alpha)
		local list = self:list("buff_list")
		if list then
			for _, item in pairs(list:items()) do
				item:set_progress_alpha(alpha or HUDListManager.ListOptions.buff_list_progress_alpha)
			end
		end
	end

	function HUDListManager:_set_list_color(color)
		for _, list in pairs(self:lists()) do
			for _, item in pairs(list:items()) do
				item:set_color(color)
			end
		end
	end

	function HUDListManager:_set_list_color_bg(color)
		for _, list in pairs(self:lists()) do
			for _, item in pairs(list:items()) do
				item:set_bg_color(color)
			end
		end
	end

	function HUDListManager:_set_civilian_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "civilian_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.civilian_color)
				end
			end
		end
		self:_set_hostage_color( color or HUDListManager.ListOptions.civilian_color )
	end

	function HUDListManager:_set_hostage_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "hostage_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.hostage_color)
				end
			end
		end
	end

	function HUDListManager:_set_thug_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "thug_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.thug_color)
				end
			end
		end
	end

	function HUDListManager:_set_enemy_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "enemy_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.enemy_color)
				end
			end
		end
		self:_set_guard_color(color or HUDListManager.ListOptions.enemy_color)
	end

	function HUDListManager:_set_guard_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "guard_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.guard_color)
				end
			end
		end
	end

	function HUDListManager:_set_special_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "special_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.special_color)
				end
			end
		end
		self:_set_turret_color(HUDListManager.ListOptions.special_color)
	end

	function HUDListManager:_set_turret_color(color)
		local list = self:list("right_side_list"):item("unit_count_list")
		if list then
			local map = HUDList.UnitCountItem.MAP
			for _, item in pairs(list:items()) do
				local u_id = item:unit_id()
				if map[u_id] and map[u_id].color_id == "turret_color" then
					item:set_icon_color(color or HUDListManager.ListOptions.turret_color)
				end
			end
		end
	end

	--Left list config
	function HUDListManager:_set_show_timers()
		local list = self:list("left_side_list"):item("timers")
		local listener_id = "HUDListManager_timer_listener"
		local events = { "set_active" }
		local clbk = callback(self, self, "_timer_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_timers then
				managers.gameinfo:register_listener(listener_id, "timer", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "timer", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_timers()) do
			if HUDListManager.ListOptions.show_timers then
				clbk("set_active", key, data)
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_minions()
		local listener_id = "HUDListManager_minion_listener"
		local events = { "add", "remove" }
		local clbk = callback(self, self, "_minion_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_minions then
				managers.gameinfo:register_listener(listener_id, "minion", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "minion", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_minions()) do
			clbk(HUDListManager.ListOptions.show_minions and "add" or "remove", key, data)
		end
	end

	function HUDListManager:_set_show_own_minions_only()
		local minion_list = self:list("left_side_list"):item("minions")

		for name, item in pairs(minion_list:items()) do
			item:set_active(not HUDListManager.ListOptions.show_own_minions_only or data.owner == managers.network:session():local_peer():id())
		end
	end

	function HUDListManager:_set_show_pagers()
		local list = self:list("left_side_list"):item("pagers")
		local pagers = managers.gameinfo:get_pagers()
		local listener_id = "HUDListManager_pager_listener"
		local events = { "add", "remove" }
		local clbk = callback(self, self, "_pager_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_pagers then
				managers.gameinfo:register_listener(listener_id, "pager", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "pager", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_pagers()) do
			if HUDListManager.ListOptions.show_pagers then
				if data.active then
					clbk("add", key, data)
				end
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_ecms()
		local list = self:list("left_side_list"):item("ecms")
		local listener_id = "HUDListManager_ecm_listener"
		local events = { "set_jammer_active" }
		local clbk = callback(self, self, "_ecm_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_ecms then
				managers.gameinfo:register_listener(listener_id, "ecm", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "ecm", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_ecms()) do
			if HUDListManager.ListOptions.show_ecms then
				clbk("set_jammer_active", key, data)
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_ecm_retrigger()
		local list = self:list("left_side_list"):item("ecm_retrigger")
		local ecms = managers.gameinfo:get_ecms()
		local listener_id = "HUDListManager_ecm_listener"
		local events = { "set_retrigger_active", "set_feedback_active" }
		local clbk = callback(self, self, "_ecm_retrigger_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_ecm_retrigger then
				managers.gameinfo:register_listener(listener_id, "ecm", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "ecm", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_ecms()) do
			if HUDListManager.ListOptions.show_ecm_retrigger then
				clbk("set_retrigger_active", key, data)
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_ammo_bags()
		self:_update_deployable_list_items("ammo_bag", HUDListManager.ListOptions.show_ammo_bags)
	end

	function HUDListManager:_set_show_doc_bags()
		self:_update_deployable_list_items("doc_bag", HUDListManager.ListOptions.show_doc_bags)
	end

	function HUDListManager:_set_show_first_aid_kits()
		self:_update_deployable_list_items("first_aid_kit", HUDListManager.ListOptions.show_first_aid_kits)
	end

	function HUDListManager:_set_show_body_bags()
		self:_update_deployable_list_items("body_bag", HUDListManager.ListOptions.show_body_bags)
	end

	function HUDListManager:_set_show_grenade_crates()
		self:_update_deployable_list_items("grenade_crate", HUDListManager.ListOptions.show_grenade_crates)
	end

	function HUDListManager:_set_show_tape_loop()
		local list = self:list("left_side_list"):item("tape_loop")
		local listener_id = "HUDListManager_tape_loop_listener"
		local events = { "set_tape_loop_active" }
		local clbk = callback(self, self, "_tape_loop_event")

		for _, event in pairs(events) do
			if HUDListManager.ListOptions.show_tape_loop then
				managers.gameinfo:register_listener(listener_id, "camera", event, clbk)
			else
				managers.gameinfo:unregister_listener(listener_id, "camera", event)
			end
		end

		for key, data in pairs(managers.gameinfo:get_cameras()) do
			if data.tape_loop_expire_t and HUDListManager.ListOptions.show_tape_loop then
				clbk("start_tape_loop", key, data)
			else
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_sentries()
		local listener_id = "HUDListManager_sentry_listener"
		local events = { "set_active", "destroy" }
		local spawned_items = managers.gameinfo:get_sentries()

		if HUDListManager.ListOptions.show_sentries then
			local clbk = callback(self, self, "_sentry_equipment_event")

			for key, data in pairs(spawned_items) do
				self:_sentry_equipment_event("set_active", key, data)
			end

			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "sentry", event, clbk)
			end
		else
			local list = self:list("left_side_list"):item("equipment")

			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "sentry", event)
			end

			for key, data in pairs(spawned_items) do
				list:unregister_item(key)
			end
		end
	end

	--Right list config
	function HUDListManager:_set_show_enemies()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("enemies")

		if HUDListManager.ListOptions.aggregate_enemies then
			self:_update_unit_count_list_items(list, "enemies", all_ids, HUDListManager.ListOptions.show_enemies)
		else
			for unit_type, unit_ids in pairs(all_types) do
				self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_enemies)
			end
		end
	end

	function HUDListManager:_set_aggregate_enemies()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("enemies")
		all_types.enemies = {}

		for unit_type, unit_ids in pairs(all_types) do
			list:unregister_item(unit_type)
		end

		self:_set_show_enemies()
	end

	function HUDListManager:_set_show_civilians()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("civilians")

		for unit_type, unit_ids in pairs(all_types) do
			self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_civilians)
		end
	end

	function HUDListManager:_set_show_hostages()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("hostages")

		if HUDListManager.ListOptions.aggregate_hostages then
			self:_update_unit_count_list_items(list, "hostages", all_ids, HUDListManager.ListOptions.show_hostages)
		else
			for unit_type, unit_ids in pairs(all_types) do
				self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_hostages)
			end
		end
	end

	function HUDListManager:_set_aggregate_hostages()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("hostages")
		all_types.hostages = {}

		for unit_type, unit_ids in pairs(all_types) do
			local item = list:item(unit_type)
			if item then
				item:delete(true)
			else
				for unit_type, unit_ids in pairs(all_types) do
					self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_hostages)
				end
			end
		end

		self:_set_show_hostages()
	end

	function HUDListManager:_set_show_minion_count()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("minions")

		for unit_type, unit_ids in pairs(all_types) do
			self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_minion_count)
		end
	end

	function HUDListManager:_set_show_turrets()
		local list = self:list("right_side_list"):item("unit_count_list")
		local all_types, all_ids = self:_get_units_by_category("turrets")

		for unit_type, unit_ids in pairs(all_types) do
			self:_update_unit_count_list_items(list, unit_type, unit_ids, HUDListManager.ListOptions.show_turrets)
		end
	end

	function HUDListManager:_set_show_pager_count()
		local list = self:list("right_side_list"):item("stealth_list")

		if HUDListManager.ListOptions.show_pager_count then
			list:register_item("PagerCount", HUDList.UsedPagersItem, { perks = {1, 4} }, { priority = 1 })
		else
			list:unregister_item("PagerCount", true)
		end
	end

	function HUDListManager:_set_show_cam_count()
		local list = self:list("right_side_list"):item("stealth_list")

		if HUDListManager.ListOptions.show_cam_count then
			list:register_item("CamCount", HUDList.CamCountItem, { skills = {4, 2} }, { priority = 2 })
		else
			list:unregister_item("CamCount", true)
		end
	end

	function HUDListManager:_set_show_bodybags_count()
		local list = self:list("right_side_list"):item("stealth_list")

		if HUDListManager.ListOptions.show_bodybags_count then
			list:register_item("BodyBagInv", HUDList.BodyBagsInvItem, { skills = { 5, 11 } }, { priority = 3 })
		else
			list:unregister_item("BodyBagInv", true)
		end
	end

	function HUDListManager:_set_show_corpse_count()
		local list = self:list("right_side_list"):item("stealth_list")

		if HUDListManager.ListOptions.show_corpse_count then
			list:register_item("CorpseCount", HUDList.CorpseCountItem, { texture = "guis/textures/pd2/risklevel_blackscreen" }, { priority = 4 })
		else
			list:unregister_item("CorpseCount", true)
		end
	end

	function HUDListManager:_set_show_special_pickups()
		local list = self:list("right_side_list"):item("special_pickup_list")
		local all_ids = {}
		local all_types = {}

		for pickup_id, pickup_type in pairs(HUDListManager.SPECIAL_PICKUP_TYPES) do
			all_types[pickup_type] = all_types[pickup_type] or {}
			table.insert(all_types[pickup_type], pickup_id)
			table.insert(all_ids, pickup_id)
		end

		for pickup_type, members in pairs(all_types) do
			if HUDListManager.ListOptions.show_special_pickups then
				local pickup_map = HUDList.SpecialPickupItem.MAP[pickup_type]
				if pickup_map then
					local item = list:item(pickup_type) or list:register_item(pickup_type, HUDList.SpecialPickupItem, pickup_type, members)
					list:set_item_disabled(item, "setting", pickup_map.ignore)
				end
			else
				list:unregister_item(pickup_type, true)
			end
		end
	end

	function HUDListManager:_set_show_loot()
		local list = self:list("right_side_list"):item("loot_list")
		local all_ids = {}
		local all_types = {}

		for loot_id, loot_type in pairs(HUDListManager.LOOT_TYPES) do
			all_types[loot_type] = all_types[loot_type] or {}
			table.insert(all_types[loot_type], loot_id)
			table.insert(all_ids, loot_id)
		end

		if HUDListManager.ListOptions.aggregate_loot then
			if HUDListManager.ListOptions.show_loot then
				list:register_item("aggregate", HUDList.LootItem, "aggregate", all_ids)
			else
				list:unregister_item("aggregate", true)
			end
		else
			for loot_type, members in pairs(all_types) do
				if HUDListManager.ListOptions.show_loot then
					list:register_item(loot_type, HUDList.LootItem, loot_type, members)
				else
					list:unregister_item(loot_type, true)
				end
			end
		end
	end

	function HUDListManager:_set_aggregate_loot()
		local list = self:list("right_side_list"):item("loot_list")
		local all_ids = {}
		local all_types = {}
		all_types.aggregate = {}

		for loot_id, loot_type in pairs(HUDListManager.LOOT_TYPES) do
			all_types[loot_type] = all_types[loot_type] or {}
			table.insert(all_types[loot_type], loot_id)
			table.insert(all_ids, loot_id)
		end

		for loot_type, loot_id in pairs(all_types) do
			list:unregister_item(loot_type)
		end

		self:_set_show_loot()
	end

	function HUDListManager:_set_separate_bagged_loot()
		for _, item in pairs(self:list("right_side_list"):item("loot_list"):items()) do
			item:update_value()
		end
	end

	function HUDListManager:_set_show_potential_loot()
		local list = self:list("right_side_list"):item("loot_list")
		local all_ids = {}
		local all_types = {}

		for loot_id, loot_type in pairs(HUDListManager.POTENTIAL_LOOT_TYPES) do
			all_types[loot_type] = all_types[loot_type] or {}
			table.insert(all_types[loot_type], loot_id)
			table.insert(all_ids, loot_id)
		end

		for loot_type, members in pairs(all_types) do
			if HUDListManager.ListOptions.show_potential_loot then
				list:register_item(loot_type, HUDList.LootItem, loot_type, members)
			else
				list:unregister_item(loot_type, true)
			end
		end
	end

	--Buff list
	function HUDListManager:_set_show_buffs()
		local listener_id = "HUDListManager_buff_listener"
		local sources = {
			buff = {
				"activate",
				"deactivate",
				"set_duration",
				"set_progress",
				"set_stack_count",
				"add_timed_stack",
				"remove_timed_stack",
				"set_value",
				clbk = callback(self, self, "_buff_event"),
			},
			player_action = {
				"activate",
				"deactivate",
				"set_duration",
				"set_data",
				clbk = callback(self, self, "_player_action_event"),
			},
		}

		for src, data in pairs(sources) do
			for _, event in ipairs(data) do
				if HUDListManager.ListOptions.show_buffs then
					managers.gameinfo:register_listener(listener_id, src, event, data.clbk)
				else
					managers.gameinfo:unregister_listener(listener_id, src, event)
				end
			end
		end

		if HUDListManager.ListOptions.show_buffs then
			for id, data in pairs(managers.gameinfo:get_buffs()) do
				self:_buff_event("activate", id)

				if data.stacks then
					self:_buff_event("add_timed_stack", id, data)
				end

				if data.t and data.expire_t then
					self:_buff_event("set_duration", id, data)
				end

				if data.stack_count then
					self:_buff_event("set_stack_count", id, data)
				end

				if data.value then
					self:_buff_event("set_value", id, data)
				end
			end

			for id, data in pairs(managers.gameinfo:get_player_actions()) do
				self:_player_action_event("activate", id, data)

				if data.t and data.expire_t then
					self:_player_action_event("set_duration", id, data)
				end

				if data.data then
					self:_player_action_event("set_data", id, data)
				end
			end
		else
			for _, item in pairs(self:list("buff_list"):items()) do
				item:delete()
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--LIST CLASS DEFINITION BLOCK
	HUDList = HUDList or {}

	HUDList.ItemBase = HUDList.ItemBase or class()
	function HUDList.ItemBase:init(parent_list, name, params)
		self._parent_list = parent_list
		self._name = name
		self._align = params.align or "center"
		self._fade_time = params.fade_time or 0.25
		self._move_speed = params.move_speed or 150
		self._priority = params.priority
		self._scale = params.scale or self._parent_list and self._parent_list:scale() or 1
		self._listener_clbks = {}
		self._disable_reason = {}

		self._panel = (self._parent_list and self._parent_list:panel() or params.native_panel or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel):panel({
			name = name,
			visible = true,
			alpha = 0,
			w = params.w or 0,
			h = params.h or 0,
			x = params.x or 0,
			y = params.y or 0,
			layer = 10
		})
	end

	function HUDList.ItemBase:post_init()
		for i, data in ipairs(self._listener_clbks) do
			for _, event in pairs(data.event) do
				managers.gameinfo:register_listener(data.name, data.source, event, data.clbk, data.keys, data.data_only)
			end
		end
	end

	function HUDList.ItemBase:destroy()
		for i, data in ipairs(self._listener_clbks) do
			for _, event in pairs(data.event) do
				managers.gameinfo:unregister_listener(data.name, data.source, event)
			end
		end
	end

	function HUDList.ItemBase:_set_item_visible(status)
		self._panel:set_visible(status and self:enabled())
	end

	function HUDList.ItemBase:rescale(new_scale)
		local diff = self._scale - new_scale
		if math.abs(diff) > 0.01 then
			local size_mult = new_scale / self._scale
			self:set_size(self:w() * size_mult, self:h() * size_mult)
			self._scale = new_scale
			return true, size_mult
		end
	end

	function HUDList.ItemBase:enabled() return next(self._disable_reason) == nil end

	function HUDList.ItemBase:set_disabled(reason, status, instant)
		if self._parent_list then
			self._parent_list:set_item_disabled(self, reason, status)
		else
			self:_set_disabled(reason, status, instant)
		end
	end

	function HUDList.ItemBase:_set_disabled(reason, status, instant)
		self._disable_reason[reason] = status and true or nil

		local visible = self:enabled() and self:is_active()
		self:_fade(visible and 1 or 0, instant)
	end

	function HUDList.ItemBase:set_priority(priority)
		self._priority = priority
	end

	function HUDList.ItemBase:set_fade_time(time)
		self._fade_time = time
	end

	function HUDList.ItemBase:set_move_speed(speed)
		self._move_speed = speed
	end

	function HUDList.ItemBase:set_active(status)
		if status then
			self:activate()
		else
			self:deactivate()
		end
	end

	function HUDList.ItemBase:activate()
		self._active = true
		self._scheduled_for_deletion = nil
		self:_show()
	end

	function HUDList.ItemBase:deactivate()
		self._active = false
		self:_hide()
	end

	function HUDList.ItemBase:delete(instant)
		self._scheduled_for_deletion = true
		self._active = false
		self:_hide(instant)
	end

	function HUDList.ItemBase:_delete()
		self:destroy()
		if alive(self._panel) then
			--self._panel:stop()		--Should technically do this, but screws with unrelated animations for some reason...
			if self._parent_list then
				self._parent_list:_remove_item(self)
				self._parent_list:set_item_visible(self, false)
			end
			if alive(self._panel:parent()) then
				self._panel:parent():remove(self._panel)
			end
		end
	end

	function HUDList.ItemBase:_show(instant)
		if alive(self._panel) then
			--self._panel:set_visible(true)
			self:_set_item_visible(true)
			self:_fade(1, instant)
			if self._parent_list then
				self._parent_list:set_item_visible(self, true)
			end
		end
	end

	function HUDList.ItemBase:_hide(instant)
		if alive(self._panel) then
			self:_fade(0, instant)
			if self._parent_list then
				self._parent_list:set_item_visible(self, false)
			end
		end
	end

	function HUDList.ItemBase:_fade(target_alpha, instant, time_override)
		local init_alpha = self._panel:alpha()
		instant = instant or init_alpha == target_alpha
		local fade_time = time_override and math.abs(alpha - init_alpha) / time_override or self._fade_time
		self._active_fade = { 
			duration = instant and 0 or time_override or math.abs(target_alpha - init_alpha) * fade_time, 
			current = 0, 
			fade_time = fade_time,
			init_alpha = init_alpha,
			target_alpha = target_alpha, 
			change = target_alpha > init_alpha and 1 or -1
		}
	end

	function HUDList.ItemBase:move(x, y, instant, time_override)
		local init_x, init_y = self._panel:x(), self._panel:y()
		instant = instant or (init_x == x and init_y == y)
		local move_speed = time_override and math.abs(x - init_x) / time_override or self._move_speed
		self._active_move = { 
			duration = instant and 0 or time_override or math.max(math.abs(x - init_x) / move_speed, math.abs(y - init_y) / move_speed), 
			current = 0, 
			move_speed = move_speed, 
			init_x = init_x, 
			init_y = init_y,
			target_x = x, 
			target_y = y, 
			change_x = x > init_x and 1 or x < init_x and -1 or nil,
			change_y = y > init_y and 1 or y < init_y and -1 or nil
		}
	end

	function HUDList.ItemBase:cancel_move()
		if self._active_move then
			local new_x, new_y = self._active_move.target_x, self._active_move.target_y
			self._active_move = nil
			
			self._panel:set_x(new_x or self._panel:x())
			self._panel:set_y(new_y or self._panel:y())
		end 
	end
	
	function HUDList.ItemBase:update(t, dt)
		-- Dummy.
	end
	
	function HUDList.ItemBase:_animate_fade(t, dt)
		if alive(self._panel) and self._active_fade then
			if self._active_fade.current < self._active_fade.duration then
				self._panel:set_alpha(math.clamp(self._active_fade.init_alpha + self._active_fade.current * self._active_fade.change * 1 / self._active_fade.fade_time, 0, 1))
				self._active_fade.current = self._active_fade.current + dt
			else
				self._panel:set_alpha(self._active_fade.target_alpha)
				self:_set_item_visible(self._active_fade.target_alpha > 0)
				self._active_fade = nil
				
				if self._scheduled_for_deletion then
					self:_delete()
				end
			end
		end
	end
	
	function HUDList.ItemBase:_animate_move(t, dt)
		if alive(self._panel) and self._active_move then
			if self._active_move.current < self._active_move.duration then
				if self._active_move.change_x then
					self._panel:set_x(self._active_move.init_x  + self._active_move.current * self._active_move.change_x * self._active_move.move_speed)
				end
				if self._active_move.change_y then
					self._panel:set_y(self._active_move.init_y  + self._active_move.current * self._active_move.change_y * self._active_move.move_speed)
				end
				self._active_move.current = self._active_move.current + dt
			else
				self._panel:set_x(self._active_move.target_x)
				self._panel:set_y(self._active_move.target_y)
				self._active_move = nil
			end
		end
	end
	
	function HUDList.ItemBase:name() return self._name end
	function HUDList.ItemBase:panel() return self._panel end
	function HUDList.ItemBase:alpha() return self._panel:alpha() end
	function HUDList.ItemBase:w() return self._panel:w() end
	function HUDList.ItemBase:h() return self._panel:h() end
	function HUDList.ItemBase:x() return self._panel:x() end
	function HUDList.ItemBase:y() return self._panel:y() end
	function HUDList.ItemBase:left() return self._panel:left() end
	function HUDList.ItemBase:right() return self._panel:right() end
	function HUDList.ItemBase:top() return self._panel:top() end
	function HUDList.ItemBase:bottom() return self._panel:bottom() end
	function HUDList.ItemBase:center() return self._panel:center() end
	function HUDList.ItemBase:center_x() return self._panel:center_x() end
	function HUDList.ItemBase:center_y() return self._panel:center_y() end
	function HUDList.ItemBase:visible() return self._panel:visible() end
	function HUDList.ItemBase:layer() return self._panel:layer() end
	function HUDList.ItemBase:text_rect() return self:x(), self:y(), self:w(), self:h() end
	function HUDList.ItemBase:set_alpha(v) self._panel:set_alpha(v) end
	function HUDList.ItemBase:set_x(v) self._panel:set_x(v) end
	function HUDList.ItemBase:set_y(v) self._panel:set_y(v) end
	function HUDList.ItemBase:set_w(v) self._panel:set_w(v)	end
	function HUDList.ItemBase:set_h(v) self._panel:set_h(v)	end
	function HUDList.ItemBase:set_size(w, h) self._panel:set_size(w, h)	end
	function HUDList.ItemBase:set_left(v) self._panel:set_left(v) end
	function HUDList.ItemBase:set_right(v) self._panel:set_right(v) end
	function HUDList.ItemBase:set_top(v) self._panel:set_top(v) end
	function HUDList.ItemBase:set_bottom(v) self._panel:set_bottom(v) end
	function HUDList.ItemBase:set_center(x, y) self._panel:set_center(x, y) end
	function HUDList.ItemBase:set_center_x(v) self._panel:set_center_x(v) end
	function HUDList.ItemBase:set_center_y(v) self._panel:set_center_y(v) end
	function HUDList.ItemBase:set_layer(v) self._panel:set_layer(v) end
	function HUDList.ItemBase:parent_list() return self._parent_list end
	function HUDList.ItemBase:align() return self._align end
	function HUDList.ItemBase:is_active() return self._active end
	function HUDList.ItemBase:animation_active() return self._active_fade or self._active_move end
	function HUDList.ItemBase:priority() return self._priority end
	function HUDList.ItemBase:scale() return self._scale end
	function HUDList.ItemBase:fade_time() return self._fade_time end
	function HUDList.ItemBase:set_color(color) end
	function HUDList.ItemBase:set_bg_color(color) end
	function HUDList.ItemBase:set_progress_alpha(alpha) end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.ListBase = HUDList.ListBase or class(HUDList.ItemBase) --DO NOT INSTANTIATE THIS CLASS
	function HUDList.ListBase:init(parent, name, params)
		params.fade_time = params.fade_time or 0
		HUDList.ListBase.super.init(self, parent, name, params)

		self._stack = params.stack or false
		self._queue = not self._stack
		self._item_fade_time = params.item_fade_time
		self._item_move_speed = params.item_move_speed
		self._item_margin = params.item_margin or 0
		self._margin = params.item_margin or 0
		self._items = {}
		self._shown_items = {}

		--[[
		self._bg = self._panel:rect({
			name = "bg",
			color = Color(math.random(), math.random(), math.random()),
			alpha = 0.25,
			valign = "grow",
			halign = "grow",
			layer = -1,
		})
		]]
	end

	function HUDList.ListBase:item(name)
		return self._items[name]
	end

	function HUDList.ListBase:items()
		return self._items
	end

	function HUDList.ListBase:num_items()
		return table.size(self._items)
	end

	function HUDList.ListBase:active_items()
		local count  = 0
		for name, item in pairs(self._items) do
			if item:is_active() then
				count = count + 1
			end
		end
		return count
	end

	function HUDList.ListBase:shown_items()
		return #self._shown_items
	end

	function HUDList.ListBase:update(t, dt)
		HUDList.ListBase.super.update(self, t, dt)
		
		for name, item in pairs(self._items) do
			if item.update and item:is_active() then
				item:update(t, dt)
			end
			if item:animation_active() then
				item:_animate_fade(t, dt)
				item:_animate_move(t, dt)
			end
		end
	end

	function HUDList.ListBase:rescale(new_scale)
		local diff = self._scale - new_scale
		if math.abs(diff) > 0.01 then
			local size_mult = new_scale / self._scale
			self._scale = new_scale

			for _, item in pairs(self:items()) do
				item:rescale(new_scale)
			end

			self:_update_item_positions(nil, true)
			return true, size_mult
		end
	end

	function HUDList.ListBase:register_item(name, class, ...)
		if not self._items[name] then
			class = type(class) == "string" and _G.HUDList[class] or class
			local new_item = class and class:new(self, name, ...)

			if new_item then
				if self._item_fade_time then
					new_item:set_fade_time(self._item_fade_time)
				end
				if self._item_move_speed then
					new_item:set_move_speed(self._item_move_speed)
				end
				if self._scale then
					new_item:rescale(self._scale)
				end
				new_item:post_init(...)
				self:_set_default_item_position(new_item)
			end

			self._items[name] = new_item
		end

		return self._items[name]
	end

	function HUDList.ListBase:unregister_item(name, instant)
		if self._items[name] then
			self._items[name]:delete(instant)
		end
	end

	function HUDList.ListBase:set_static_item(class, ...)
		self:delete_static_item()

		if type(class) == "string" then
			class = _G.HUDList[class]
		end

		self._static_item = class and class:new(self, "static_list_item", ...)
		if self._static_item then
			self:setup_static_item()
			self._static_item:panel():show()
			self._static_item:panel():set_alpha(1)
		end

		return self._static_item
	end

	function HUDList.ListBase:setup_static_item()
	end

	function HUDList.ListBase:delete_static_item()
		if self._static_item then
			self._static_item:delete(true)
			self._static_item = nil
		end
	end

	function HUDList.ListBase:set_item_visible(item, visible)
		local index
		for i, shown_item in ipairs(self._shown_items) do
			if shown_item == item then
				index = i
				break
			end
		end

		--local threshold = self._static_item and 1 or 0	--TODO

		if visible and not index then
			if #self._shown_items <= 0 then
				self:activate()
			end

			local insert_index = #self._shown_items + 1
			if item:priority() then
				for i, list_item in ipairs(self._shown_items) do
					if not list_item:priority() or (list_item:priority() > item:priority()) then
						insert_index = i
						break
					end
				end
			end

			table.insert(self._shown_items, insert_index, item)
		elseif not visible and index then
			table.remove(self._shown_items, index)
			if #self._shown_items <= 0 then
				managers.enemy:add_delayed_clbk("visibility_cbk_" .. self._name, callback(self, self, "_cbk_update_visibility"), Application:time() + item:fade_time())
				--self:deactivate()
			end
		else
			return
		end

		self:_update_item_positions(item)
	end

	function HUDList.ListBase:set_item_disabled(item, reason, status, instant)
		item:_set_disabled(reason, status, instant)
		self:update_item_positions()
	end

	function HUDList.ListBase:update_item_positions()
		self:_update_item_positions(nil, true)
	end

	function HUDList.ListBase:_update_item_positions(insert_item, instant_move, move_timer)
	end

	function HUDList.ListBase:_cbk_update_visibility()
		if #self._shown_items <= 0 then
			self:deactivate()
		end
	end

	function HUDList.ListBase:_remove_item(item)
		self._items[item:name()] = nil
	end

	function HUDList.ListBase:set_color(color)
		for _, item in pairs(self:items()) do
			item:set_color(color)
		end
	end
	function HUDList.ListBase:set_bg_color(color)
		for _, item in pairs(self:items()) do
			item:set_bg_color(color)
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.HorizontalList = HUDList.HorizontalList or class(HUDList.ListBase)
	function HUDList.HorizontalList:init(parent, name, params)
		params.align = params.align == "top" and "top" or params.align == "bottom" and "bottom" or "center"
		HUDList.HorizontalList.super.init(self, parent, name, params)
		self._left_to_right = params.left_to_right
		self._right_to_left = params.right_to_left and not self._left_to_right
		self._centered = params.centered and not (self._right_to_left or self._left_to_right)

		self._max_shown_items = params.max_items

		self._recheck_interval = params.recheck_interval
		self._next_recheck = self._recheck_interval

		self:setup_expansion_item()
	end

	function HUDList.HorizontalList:rescale(new_scale)
		local diff = self._scale - new_scale
		if math.abs(diff) > 0.01 then
			local size_mult = new_scale / self._scale
			self:set_h(self:h() * size_mult)
			self._scale = new_scale

			if self._static_item then
				self._static_item:rescale(new_scale)
			end
			for _, item in pairs(self:items()) do
				item:rescale(new_scale)
			end
			if self._expansion_indicator then
				self._expansion_indicator:rescale(new_scale)
			end

			self:_update_item_positions(nil, true)
			return true, size_mult
		end
	end

	function HUDList.HorizontalList:set_color(color)
		if self._static_item then
			self._static_item:set_color(color)
		end
		for _, item in pairs(self:items()) do
			item:set_color(color)
		end
		if self._expansion_indicator then
			self._expansion_indicator:set_color(color)
		end
	end
	function HUDList.HorizontalList:set_bg_color(color)
		if self._static_item then
			self._static_item:set_bg_color(color)
		end
		for _, item in pairs(self:items()) do
			item:set_bg_color(color)
		end
		if self._expansion_indicator then
			self._expansion_indicator:set_bg_color(color)
		end
	end

	function HUDList.HorizontalList:_set_default_item_position(item)
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		item:panel():set_top(y)
	end

	function HUDList.HorizontalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		local x = self._left_to_right and 0 or self._panel:w() - item:panel():w()
		item:panel():set_left(x)
		item:panel():set_top(y)
		self:_update_item_positions()
	end

	function HUDList.HorizontalList:setup_expansion_item()
		self._expansion_indicator = HUDList.ExpansionIndicator:new(self, "expansion_indicator", 1/5, 1, {})
		self._expansion_indicator:set_mirrored(self._right_to_left)
		self._expansion_indicator:set_active(self._max_shown_items and self._max_shown_items >= self:shown_items())
	end

	function HUDList.HorizontalList:update(t, dt)
		HUDList.HorizontalList.super.update(self, t, dt)
		
		if self._recheck_interval ~= nil then
			self._next_recheck = self._next_recheck - dt

			if self:shown_items() > 0 and self._next_recheck <= 0 then
				self:reapply_item_priorities(true, self._recheck_interval / 2)
				self._next_recheck = self._recheck_interval
			end
		end
	end

	function HUDList.HorizontalList:_update_item_positions(insert_item, instant_move, move_timer)
		local total_shown_items = 0
		local show_expansion = false
		if self._centered then
			local total_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			local prev_disabled_i = {}
			for i, item in ipairs(self._shown_items) do
				local next_total_width = total_width + item:panel():w() + self._item_margin
				show_expansion = show_expansion or (next_total_width > self:w())
				if self._max_shown_items then
					show_expansion = show_expansion or (total_shown_items >= self._max_shown_items)
				end
				if not item:enabled() then
					table.insert(prev_disabled_i, i)
				end
				item:_set_disabled("max_items_reached", show_expansion)

				if item:enabled() then
					total_width = next_total_width
					total_shown_items = total_shown_items + 1
				end
			end
			total_width = total_width - self._item_margin

			local left = (self._panel:w() - math.min(total_width, self._panel:w())) / 2

			if self._static_item then
				self._static_item:move(left, item:panel():y(), instant_move, move_timer)
				left = left + self._static_item:panel():w() + self._item_margin
			end

			for i, item in ipairs(self._shown_items) do
				if item:enabled() then
					if insert_item and item == insert_item or table.contains(prev_disabled_i, i) then
						if item:panel():x() ~= left then
							item:panel():set_x(left - item:panel():w() / 2)
							item:move(left, item:panel():y(), instant_move, move_timer)
						end
					else
						item:move(left, item:panel():y(), instant_move, move_timer)
					end
					left = left + item:panel():w() + self._item_margin
				else
					item:panel():set_x(left)
				end
			end

			if self._expansion_indicator then
				self._expansion_indicator:cancel_move()
				self._expansion_indicator:set_active(show_expansion)
				self._expansion_indicator:panel():set_x(left)
			end
		else
			local prev_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				local next_width = prev_width + item:panel():w() + self._item_margin
				show_expansion = show_expansion or (next_width > self:w())
				if self._max_shown_items then
					show_expansion = show_expansion or (total_shown_items >= self._max_shown_items)
				end
				local was_disabled = not item:enabled()
				item:_set_disabled("max_items_reached", show_expansion)

				if item:enabled() then
					local width = item:panel():w()
					local new_x = (self._left_to_right and prev_width) or (self._panel:w() - (width+prev_width))
					if insert_item and item == insert_item or was_disabled then
						item:cancel_move()
						item:panel():set_x(new_x)
					else
						item:move(new_x, item:panel():y(), instant_move, move_timer)
					end

					prev_width = prev_width + width + self._item_margin
					total_shown_items = total_shown_items + 1
				end
			end

			if self._expansion_indicator then
				self._expansion_indicator:set_active(show_expansion)
				local width = self._expansion_indicator:panel():w()
				local new_x = (self._left_to_right and math.min(prev_width, self._panel:w() - width)) or math.max(self._panel:w() - (width+prev_width), 0)
				self._expansion_indicator:cancel_move()
				self._expansion_indicator:panel():set_x(new_x)
			end

			self:set_disabled("no_visible_items", total_shown_items <= 0)
		end
	end

	function HUDList.HorizontalList:reapply_item_priorities(update_positions, move_time_override)
		local order_changed = false
		if not self._reorder_in_progress then
			self._reorder_in_progress = true

			local swapped = false
			repeat
				swapped = false

				for i = 2, #self._shown_items, 1 do
					local prev = self._shown_items[i-1]
					local cur = self._shown_items[i]

					local prev_prio, cur_prio = prev and prev:priority(), cur and cur:priority()
					if cur_prio then
						if not prev_prio or prev_prio > cur_prio then
							table.insert(self._shown_items, i, table.remove(self._shown_items, i-1))
							swapped = true
						end
					end
				end
				order_changed = order_changed or swapped
			until not swapped

			self._reorder_in_progress = nil

			if update_positions and order_changed then
				self:_update_item_positions(nil, false, move_time_override)
			end
		end

		return order_changed
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.VerticalList = HUDList.VerticalList or class(HUDList.ListBase)
	function HUDList.VerticalList:init(parent, name, params)
		params.align = params.align == "left" and "left" or params.align == "right" and "right" or "center"
		HUDList.VerticalList.super.init(self, parent, name, params)
		self._top_to_bottom = params.top_to_bottom
		self._bottom_to_top = params.bottom_to_top and not self._top_to_bottom
		self._centered = params.centered and not (self._bottom_to_top or self._top_to_bottom)
	end

	function HUDList.VerticalList:_set_default_item_position(item)
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		item:panel():set_left(x)
	end

	function HUDList.VerticalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		local y = self._top_to_bottom and 0 or self._panel:h() - item:panel():h()
		item:panel():set_left(x)
		item:panel():set_y(y)
		self:_update_item_positions()
	end

	function HUDList.VerticalList:_update_item_positions(insert_item, instant_move, move_timer)
		if self._centered then
			local total_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if item:enabled() then
					total_height = total_width + item:panel():h() + self._item_margin
				end
			end
			total_height = total_height - self._item_margin

			local top = (self._panel:h() - math.min(total_height, self._panel:h())) / 2

			if self._static_item then
				self._static_item:move(item:panel():x(), top, instant_move, move_timer)
				top = top + self._static_item:panel():h() + self._item_margin
			end

			for i, item in ipairs(self._shown_items) do
				if item:enabled() then
					if insert_item and item == insert_item then
						if item:panel():y() ~= top then
							item:panel():set_y(top - item:panel():h() / 2)
							item:move(item:panel():x(), top, instant_move, move_timer)
						end
					else
						item:move(item:panel():x(), top, instant_move, move_timer)
					end
					top = top + item:panel():h() + self._item_margin
				end
			end
		else
			local prev_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if item:enabled() then
					local height = item:panel():h()
					local new_y = (self._top_to_bottom and prev_height) or (self._panel:h() - (height+prev_height))
					if insert_item and item == insert_item then
						item:cancel_move()
						item:panel():set_y(new_y)
					else
						item:move(item:panel():x(), new_y, instant_move, move_timer)
					end
					prev_height = prev_height + height + self._item_margin
				end
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.ExpansionIndicator = HUDList.ExpansionIndicator or class(HUDList.ItemBase)

	function HUDList.ExpansionIndicator:init(parent, name, ratio_w, ratio_h, params)
		HUDList.ExpansionIndicator.super.init(self, parent, name, { align = "center", w = parent:panel():h() * (ratio_w or 1), h = parent:panel():h() * (ratio_h or 1) })

		local icon = params.icon or {}
		self._icon = self._panel:bitmap({
			name = "icon_expansion",
			texture = icon.texture or "guis/textures/hud_icons",
			texture_rect = icon.texture_rect or { 434, 48, 30, 16 },
			h = self:panel():h() * (icon.h or 1),
			w = self:panel():w() * (icon.w or 0.8),
			blend_mode = "add",
			align = "center",
			vertical = "center",
			valign = "scale",
			halign = "scale",
			color = icon.color or Color.white,
		})

		self._icon:set_center(self._panel:center())
	end

	function HUDList.ExpansionIndicator:set_mirrored(status)
		self._icon:set_rotation(status and 180 or 0)
	end

	function HUDList.ExpansionIndicator:_show(instant)
		if alive(self._panel) then
			self:_set_item_visible(true)
			self:_fade(1, instant)
		end
	end

	function HUDList.ExpansionIndicator:_hide(instant)
		if alive(self._panel) then
			self:_fade(0, instant)
		end
	end

	function HUDList.ExpansionIndicator:set_color(color)
		self._icon:set_color(color)
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--LIST ITEM CLASS DEFINITION BLOCK

	--Right list

	HUDList.RightListItem = HUDList.RightListItem or class(HUDList.ItemBase)
	function HUDList.RightListItem:init(parent, name, icon, params)
		params = params or {}
		params.align = params.align or "right"
		params.w = params.w or parent:panel():h() / 2
		params.h = params.h or parent:panel():h()
		HUDList.RightListItem.super.init(self, parent, name, params)

		self._default_text_color = HUDListManager.ListOptions.list_color or Color.white
		self._default_icon_color = icon.color or icon.color_id and HUDListManager.ListOptions[icon.color_id]
		self._change_increase_color = Color.green
		self._change_decrease_color = Color.red


		local texture, texture_rect = get_icon_data(icon)

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			h = self._panel:w() * (icon.h_ratio or 1),
			w = self._panel:w() * (icon.w_ratio or 1),
			alpha = icon.alpha or 1,
			blend_mode = icon.blend_mode or "normal",
			color = self._default_icon_color or self._default_text_color,
		})
		self._icon:set_center(self._panel:w() * 0.5, self._panel:w() * 0.5)

		--self._box = HUDBGBox_create(self._panel, { w = self._panel:w(),	h = self._panel:w() }, { color = HUDListManager.ListOptions.list_color, bg_color = HUDListManager.ListOptions.list_color_bg })
		--self._box:set_bottom(self._panel:bottom())

		self._progress_bar = PanelFrame:new(self._panel, {
			w = self._panel:w(),
			h = self._panel:w(),
			invert_progress = true,
			bar_w = 2,
			bar_color = self._default_text_color,
			bg_color = (HUDListManager.ListOptions.list_color_bg or Color.black),
			bar_alpha = HUDListManager.ListOptions.right_list_progress_alpha or 0.4,
			add_bg = true,
		})
		self._progress_bar:set_ratio(1)

		local box = self._progress_bar:panel()
		box:set_bottom(self._panel:bottom())

		self._text = box:text({
			name = "text",
			text = "",
			align = "center",
			vertical = "center",
			w = box:w(),
			h = box:h(),
			color = self._default_text_color,
			font = tweak_data.hud_corner.assault_font,
			font_size = box:h() * 0.6
		})

		self._count = 0
	end

	function HUDList.RightListItem:rescale(new_scale)
		local enabled, size_mult = HUDList.RightListItem.super.rescale(self, new_scale)

		if enabled then
			self._icon:set_size(self._icon:w() * size_mult, self._icon:h() * size_mult)
			self._icon:set_center(self._panel:w() * 0.5, self._panel:w() * 0.5)

			self._progress_bar:set_size(self._panel:w(), self._panel:w())
			self._progress_bar:set_bottom(self._panel:bottom())

			self._text:set_size(self._progress_bar:w(), self._progress_bar:h())
			self._text:set_font_size(self._progress_bar:h() * 0.6)
		end

		return enabled, size_mult
	end

	function HUDList.RightListItem:set_color(color)
		self._default_text_color = color or HUDListManager.ListOptions.list_color or Color.white
		self._icon:set_color(self._default_icon_color or self._default_text_color)
		self._progress_bar:set_color(self._default_text_color)
		self._text:set_color(self._default_text_color)
	end

	function HUDList.RightListItem:set_bg_color(color)
		self._progress_bar:set_bg_color(color)
	end

	function HUDList.RightListItem:set_icon_color(color)
		self._default_icon_color = color
		self._icon:set_color(self._default_icon_color or self._default_text_color)
	end

	function HUDList.RightListItem:set_progress_alpha(alpha)
		self._progress_bar:set_alpha(alpha)
	end

	function HUDList.RightListItem:change_count(diff)
		self:set_count(self._count + diff)
	end

	function HUDList.RightListItem:set_count(num)
		if self._count ~= num then
			local increase = num > self._count
			self._count = num
			self._text:set_text(tostring(self._count))
			self:set_active(self._count > 0)
			
			if self:is_active() then
				self._active_count_change = {
					duration = 0.5,
					current = 0,
					color = increase and self._change_increase_color or self._change_decrease_color,
					invert_progress = not increase
				}
			end
		end
	end

	function HUDList.RightListItem:get_count()
		return self._count or 0
	end

	function HUDList.RightListItem:update(t, dt)
		HUDList.RightListItem.super.update(self, t, dt)
		
		self:_animate_count_change(t, dt)
	end

	function HUDList.RightListItem:_animate_count_change(t, dt)
		if self._active_count_change ~= nil then
			if self._active_count_change.current <= self._active_count_change.duration then
				local ratio = math.clamp(self._active_count_change.current / self._active_count_change.duration, 0, 1)
				local new_color = math.lerp(self._default_text_color, self._active_count_change.color, ratio)
				self._text:set_color(new_color)
				self._progress_bar:set_color(new_color)
				self._progress_bar:set_ratio((self._active_count_change.invert_progress and (1-ratio) or ratio))
				self._active_count_change.current = self._active_count_change.current + dt
			else
				self._text:set_color(self._default_text_color)
				self._progress_bar:set_color(self._default_text_color)
				self._progress_bar:set_ratio(1)
				self._active_count_change = nil
			end
		end
	end

	HUDList.UnitCountItem = HUDList.UnitCountItem or class(HUDList.RightListItem)
	do
		local buff_shield = "guis/textures/pd2/hud_buff_shield"
		HUDList.UnitCountItem.MAP = {
			enemies =		{ class = "UnitCountItem", 	 skills = 	{6, 1}, 	color_id = "enemy_color", 		priority = 1, subtract = { "cop_hostage", "sec_hostage", "minions" } },	--Aggregated enemies
			cop =			{ class = "UnitCountItem",	 skills = 	{0, 5}, 	color_id = "enemy_color", 		priority = 5, subtract = { "cop_hostage", "cop_minion" } },	--Non-special police
			security =		{ class = "UnitCountItem",	 perks = 	{1, 4}, 	color_id = "guard_color", 		priority = 4, subtract = { "sec_hostage", "sec_minion" } },
			thug =			{ class = "UnitCountItem",	 skills = 	{4, 12}, 	color_id = "thug_color", 		priority = 4 },
			tank =			{ class = "UnitCountItem",	 skills = 	{3, 1}, 	color_id = "special_color", 	priority = 6 },
			spooc =			{ class = "UnitCountItem",	 skills = 	{1, 3}, 	color_id = "special_color", 	priority = 6 },
			taser =			{ class = "UnitCountItem",	 skills = 	{3, 5}, 	color_id = "special_color", 	priority = 6 },
			shield =		{ class = "ShieldCountItem", texture = buff_shield, color_id = "special_color", 	priority = 6 },
			sniper =		{ class = "UnitCountItem",	 skills = 	{6, 5}, 	color_id = "special_color", 	priority = 6 },
			medic = 		{ class = "UnitCountItem",	 skills = 	{5, 8}, 	color_id = "special_color", 	priority = 6 },
			grenadier = 	{ class = "UnitCountItem",	 skills = 	{9, 9}, 	color_id = "special_color", 	priority = 6 },
			thug_boss =		{ class = "UnitCountItem",	 skills = 	{1, 1}, 	color_id = "thug_color", 		priority = 4 },
			phalanx =		{ class = "UnitCountItem",	 texture = buff_shield, color_id = "special_color", 	priority = 7 },

			turret =		{ class = "UnitCountItem",	 skills = 	{7, 5}, 	color_id = "turret_color", 		priority = 5 },
			unique =		{ class = "UnitCountItem",	 skills = 	{3, 8}, 	color_id = "civilian_color", 	priority = 3 },
			cop_hostage =	{ class = "UnitCountItem",	 skills = 	{2, 8}, 	color_id = "hostage_color", 	priority = 2 },
			civ_hostage =	{ class = "UnitCountItem",	 skills = 	{4, 7}, 	color_id = "hostage_color", 	priority = 1 },
			hostages =		{ class = "UnitCountItem",	 skills = 	{4, 7}, 	color_id = "hostage_color", 	priority = 1 },
			minion =		{ class = "UnitCountItem",	 skills = 	{6, 8}, 	color_id = "hostage_color", 	priority = 0 },
			civ =			{ class = "UnitCountItem",	 skills = 	{6, 7}, 	color_id = "civilian_color", 	priority = 3, subtract = { "civ_hostage" } },
		}
	end
	function HUDList.UnitCountItem:init(parent, name, id, unit_types)
		local unit_data = HUDList.UnitCountItem.MAP[id] or {}
		local params = { priority = unit_data.priority }

		HUDList.UnitCountItem.super.init(self, parent, name, unit_data, params)

		self._id = id
		self._unit_types = {}
		self._subtract_types = {}
		self._unit_count = {}

		local total_count = 0
		local keys = {}

		for _, unit_id in pairs(unit_types or {}) do
			local count = managers.gameinfo:get_unit_count(unit_id)
			total_count = total_count + count
			self._unit_count[unit_id] = count
			self._unit_types[unit_id] = true
			table.insert(keys, unit_id)
		end

		for _, unit_id in pairs(unit_data.subtract or {}) do
			local count = managers.gameinfo:get_unit_count(unit_id)
			total_count = total_count - count
			self._unit_count[unit_id] = count
			self._subtract_types[unit_id] = true
			table.insert(keys, unit_id)
		end

		self._listener_clbks = {
			{
				name = string.format("HUDList_%s_unit_count_listener", id),
				source = "unit_count",
				event = { "change" },
				clbk = callback(self, self, "_change_count_clbk"),
				keys = keys
			}
		}

		self:set_count(total_count)
	end

	function HUDList.UnitCountItem:unit_id()
		return self._id
	end

	function HUDList.UnitCountItem:_change_count_clbk(event, unit_type, value)
		self._unit_count[unit_type] = self._unit_count[unit_type] + value
		if self._subtract_types[unit_type] then
			self:change_count(-value)
		else
			self:change_count(value)
		end
	end

	HUDList.ShieldCountItem = HUDList.ShieldCountItem or class(HUDList.UnitCountItem)

	function HUDList.ShieldCountItem:init(parent, name, id, unit_types)
		HUDList.ShieldCountItem.super.init(self, parent, name, id, unit_types)

		self._shield_filler = self._panel:rect({
			name = "shield_filler",
			w = self._icon:w() * 0.4,
			h = self._icon:h() * 0.4,
			color = self._default_icon_color or self._default_text_color,
			blend_mode = "normal",
			layer = self._icon:layer() + 1,
		})
		self._shield_filler:set_center(self._icon:center())
	end

	function HUDList.ShieldCountItem:set_icon_color(color)
		HUDList.ShieldCountItem.super.set_icon_color(self, color)
		if self._shield_filler then
			self._shield_filler:set_color(self._default_icon_color or self._default_text_color)
		end
	end

	function HUDList.ShieldCountItem:rescale(new_scale)
		local enabled, size_mult = HUDList.ShieldCountItem.super.rescale(self, new_scale)

		if enabled and alive(self._shield_filler) then
			self._shield_filler:set_size(self._icon:w() * 0.4, self._icon:h() * 0.4)
			self._shield_filler:set_center(self._icon:center())
		end

		return enabled, size_mult
	end

	HUDList.UsedPagersItem = HUDList.UsedPagersItem or class(HUDList.RightListItem)
	function HUDList.UsedPagersItem:init(...)
		HUDList.UsedPagersItem.super.init(self, ...)

		self._change_increase_color = Color.red

		self._listener_clbks = {
			{
				name = "HUDList_pager_count_listener",
				source = "pager",
				event = { "add" },
				clbk = callback(self, self, "_add_pager"),
			},
			{
				name = "HUDList_pager_count_listener",
				source = "whisper_mode",
				event = { "change" },
				clbk = callback(self, self, "_whisper_mode_change"),
				data_only = true,
			}
		}

		self:set_count(table.size(managers.gameinfo:get_pagers()))
	end

	function HUDList.UsedPagersItem:_add_pager(...)
		self:change_count(1)
	end

	function HUDList.UsedPagersItem:_whisper_mode_change(status)
		self:set_active(self._count > 0 and status)
	end

	function HUDList.UsedPagersItem:set_count(num)
		if managers.groupai:state():whisper_mode() then
			local tweak = tweak_data.player.alarm_pager.bluff_success_chance
			self._default_text_color = math.lerp(Color(1, 0.2, 0), HUDListManager.ListOptions.list_color or Color.white, tweak and tonumber(tweak[(num or 0) + 1]) or 0)

			HUDList.UsedPagersItem.super.set_count(self, num)
		end
	end

	HUDList.CamCountItem = HUDList.CamCountItem or class(HUDList.RightListItem)
	function HUDList.CamCountItem:init(...)
		HUDList.CamCountItem.super.init(self, ...)

		self._listener_clbks = {
			{
				name = "HUDList_cam_count_listener",
				source = "camera_count",
				event = { "set_count" },
				clbk = callback(self, self, "_change_camera_count"),
				data_only = true,
			},
			{
				name = "HUDList_cam_count_listener",
				source = "whisper_mode",
				event = { "change" },
				clbk = callback(self, self, "_whisper_mode_change"),
				data_only = true,
			}
		}

		self:set_count(managers.gameinfo:_recount_active_cameras())
	end

	function HUDList.CamCountItem:_change_camera_count(count)
		local diff = count and (count - self._count) or 0
		if diff ~= 0 then
			self:change_count(diff)
		end
	end

	function HUDList.CamCountItem:_whisper_mode_change(status)
		self:set_active(self._count > 0 and status)
	end

	function HUDList.CamCountItem:set_count(num)
		if managers.groupai:state():whisper_mode() then
			HUDList.CamCountItem.super.set_count(self, num)
		end
	end

	HUDList.BodyBagsInvItem = HUDList.BodyBagsInvItem or class(HUDList.RightListItem)
	function HUDList.BodyBagsInvItem:init(...)
		HUDList.BodyBagsInvItem.super.init(self, ...)

		self._listener_clbks = {
			{
				name = "HUDList_bodybags_count_listener",
				source = "bodybags",
				event = { "change" },
				clbk = callback(self, self, "change_count"),
				data_only = true,
			},
			{
				name = "HUDList_bodybags_count_listener",
				source = "whisper_mode",
				event = { "change" },
				clbk = callback(self, self, "_whisper_mode_change"),
				data_only = true,
			}
		}

		self:set_count(managers.gameinfo:get_bodybag_amount())
	end

	function HUDList.BodyBagsInvItem:_whisper_mode_change(status)
		self:set_active(self._count > 0 and status)
	end

	function HUDList.BodyBagsInvItem:change_count(diff)
		if managers.groupai:state():whisper_mode() then
			HUDList.BodyBagsInvItem.super.change_count(self, diff)
		end
	end

	HUDList.CorpseCountItem = HUDList.CorpseCountItem or class(HUDList.RightListItem)
	function HUDList.CorpseCountItem:init(...)
		HUDList.CorpseCountItem.super.init(self, ...)

		self._keys = {"person", "special_person"}
		self._change_increase_color = Color.red
		self._change_decrease_color = Color.green
		self._total_count = 0
		self._bagged_count = 0
		self._unbagged_count = 0

		self._listener_clbks = {
			{
				name = "HUDList_corpse_count_listener",
				source = "loot_count",
				event = { "change" },
				clbk = callback(self, self, "_change_corpse_count"),
				keys = self._keys
			},
			{
				name = "HUDList_corpse_count_listener",
				source = "pager",
				event = { "add", "remove" },
				clbk = callback(self, self, "_pager_event"),
			},
			{
				name = "HUDList_corpse_count_listener",
				source = "whisper_mode",
				event = { "change" },
				clbk = callback(self, self, "_whisper_mode_change"),
				data_only = true,
			}
		}

		local pagers = managers.gameinfo:get_pagers() or {}
		for uid, data in pairs(pagers) do
			if data.active then
				self._unbagged_count = self._unbagged_count + 1
			end
		end
		for _, data in pairs(managers.gameinfo:get_loot()) do
			if table.contains(self._keys, data.carry_id) then
				if data.bagged then
					self._bagged_count = self._bagged_count + data.count
				else
					self._unbagged_count = self._unbagged_count + data.count
				end
			end
		end

		self:set_count(self._unbagged_count, self._bagged_count)
	end

	function HUDList.CorpseCountItem:_change_corpse_count(event, carry_id, bagged, value, data)
		local bagged_count = self._bagged_count
		local unbagged_count = self._unbagged_count

		if bagged then
			bagged_count = bagged_count + value
		else
			unbagged_count = unbagged_count + value
		end

		self:set_count(unbagged_count, bagged_count)

		
		if self:is_active() and value ~= 0 then
			local increase = value > 0
			self._active_count_change = {
				duration = 0.5,
				current = 0,
				color = increase and self._change_increase_color or self._change_decrease_color,
				invert_progress = not increase
			}
		end
	end

	function HUDList.CorpseCountItem:_pager_event(event, key, data)
		local bagged_count = self._bagged_count
		local unbagged_count = self._unbagged_count

		if event == "add" then
			unbagged_count = unbagged_count + 1
		elseif event == "remove" then
			unbagged_count = unbagged_count - 1
		end

		self:set_count(unbagged_count, bagged_count)

		if self:is_active() then
			local increase = (event == "add")
			self._active_count_change = {
				duration = 0.5,
				current = 0,
				color = increase and self._change_increase_color or self._change_decrease_color,
				invert_progress = not increase
			}
		end
	end

	function HUDList.CorpseCountItem:_whisper_mode_change(status)
		self:set_active(self._count > 0 and status)
	end

	function HUDList.CorpseCountItem:set_count(unbagged, bagged)
		if managers.groupai:state():whisper_mode() then
			self._unbagged_count = unbagged
			self._bagged_count = bagged
			self._total_count = self._unbagged_count + self._bagged_count

			self._text:set_text(self._unbagged_count .. "/" .. self._bagged_count)

			self:set_active(self._total_count > 0)
		end
	end

	HUDList.SpecialPickupItem = HUDList.SpecialPickupItem or class(HUDList.RightListItem)
	HUDList.SpecialPickupItem.MAP = {
		crowbar =					{ hudpickups = { 0, 64, 32, 32 }, 												priority = 1, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		keycard =					{ hudpickups = { 32, 0, 32, 32 }, 												priority = 1, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		planks =					{ hudpickups = { 0, 32, 32, 32 }, 												priority = 2, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		meth_ingredients =			{ waypoints  = { 192, 32, 32, 32 }, 											priority = 2, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		blowtorch = 				{ hudpickups = { 96, 192, 32, 32 }, 											priority = 1, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		thermite = 					{ hudpickups = { 64, 64, 32, 32 }, 												priority = 1, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		c4 = 						{ hudicons	 = { 36, 242, 32, 32 }, 											priority = 1, category = "mission_pickups", ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "mission_pickups"}, true) 	},
		small_loot = 				{ hudpickups = { 32, 224, 32, 32}, 												priority = 3, category = "valuables", 		ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "valuables"}, true) 		},
		briefcase = 				{ hudpickups = { 96, 224, 32, 32}, 												priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		courier = 					{ texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment", 	priority = 3, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		gage_case = 				{ skills 	 = { 1, 0 }, 														priority = 3, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		gage_key = 					{ hudpickups = { 32, 64, 32, 32 }, 												priority = 3, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		paycheck_masks = 			{ hudpickups = { 128, 32, 32, 32 }, 											priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		secret_item =				{ waypoints  = { 96, 64, 32, 32 }, 												priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		rings = 					{ texture = "guis/textures/pd2/level_ring_small", w_ratio = 0.5, h_ratio = 0.5, priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		poster = 					{ hudpickups = { 96, 96, 32, 32 }, 												priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
		handcuffs = 				{ hud_icons  = {294,469, 40, 40 }, 												priority = 4, category = "collectables", 	ignore = not WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "SHOW_PICKUP_CATEGORIES", "collectables"}, true) 		},
	}

	function HUDList.SpecialPickupItem:init(parent, name, id, members)
		local pickup_data = HUDList.SpecialPickupItem.MAP[id]
		local params = { priority = pickup_data.priority }

		HUDList.SpecialPickupItem.super.init(self, parent, name, pickup_data, params)

		self._pickup_types = {}

		local keys = {}
		for _, pickup_id in pairs(members) do
			self._pickup_types[pickup_id] = true
			table.insert(keys, pickup_id)
		end

		local total_count = 0
		for _, data in pairs(managers.gameinfo:get_special_equipment()) do
			if self._pickup_types[data.interact_id] then
				total_count = total_count + 1
			end
		end

		self._listener_clbks = {
			{
				name = string.format("HUDList_%s_special_pickup_count_listener", id),
				source = "special_equipment_count",
				event = { "change" },
				clbk = callback(self, self, "_change_special_equipment_count_clbk"),
				keys = keys
			}
		}

		self:set_count(total_count)
	end

	function HUDList.SpecialPickupItem:_change_special_equipment_count_clbk(event, interact_id, value, data)
		self:change_count(value)
	end

	HUDList.LootItem = HUDList.LootItem or class(HUDList.RightListItem)
	HUDList.LootItem.MAP = {
		aggregate =		{ text = "", no_localize = true },	--Aggregated loot

		armor =			{ text = "wolfhud_hudlist_loot_armor", 		priority = 1 }, -- Shaddow Raid
		artifact =		{ text = "hud_carry_artifact", 				priority = 1 },	-- Schaddow Raid, The Diamond
		bike = 			{ text = "hud_carry_bike_part", 			priority = 1 },	-- Biker Heist
		bomb =			{ text = "wolfhud_hudlist_loot_bomb", 		priority = 1 },	-- Bomb Forest & Dockyard, Murky Station EMP
		coke =			{ text = "hud_carry_coke", 					priority = 1 },
		dentist =		{ text = "???", no_localize = true, 		priority = 1 },	-- Golden Grin
		diamond = 		{ text = "wolfhud_hudlist_loot_diamond", 	priority = 1 },	-- The Diamond/Diamond Heist Red Diamond
		diamonds =		{ text = "hud_carry_diamonds_dah", 			priority = 1 },	-- The Diamond Heist
		drone_ctrl = 	{ text = "hud_carry_helmet", 				priority = 1 },	-- Biker Heist
		egg = 			{ text = "wolfhud_hudlist_loot_egg", 		priority = 1 },	-- San Martin Bank
		evidence =		{ text = "wolfhud_hudlist_loot_evidence", 	priority = 1 },	-- Hoxton revenge
		goat =			{ text = "hud_carry_goat", 					priority = 1 },	-- Goat Simulator
		gold =			{ text = "hud_carry_gold", 					priority = 1 },
		jewelry =		{ text = "hud_carry_diamonds", 				priority = 1 },
		meth =			{ text = "hud_carry_meth", 					priority = 1 },
		money =			{ text = "hud_carry_money", 				priority = 1 },
		painting =		{ text = "hud_carry_painting", 				priority = 1 },
		pig =			{ text = "hud_carry_pig", 					priority = 1 },	-- Slaugtherhouse
		present =		{ text = "hud_carry_present", 				priority = 1 },	-- Santa's Workshop
		prototype =		{ text = "hud_carry_prototype", 			priority = 1 },
		safe =			{ text = "hud_carry_safe", 					priority = 1 },	-- Aftershock
		server =		{ text = "hud_carry_circuit", 				priority = 1 },
		shell =			{ text = "hud_carry_ammo", 					priority = 1 },	-- Transport: Train
		shoes = 		{ text = "wolfhud_hudlist_loot_shoes", 		priority = 1 },	-- Stealing Xmas
		toast =			{ text = "wolfhud_hudlist_loot_toast", 		priority = 1 },	-- White Xmas
		toothbrush = 	{ text = "wolfhud_hudlist_loot_toothbrush", priority = 1 },	-- Panic Room
		toy = 			{ text = "wolfhud_hudlist_loot_toy", 		priority = 1 },	-- Stealing Xmas
		treasure = 		{ text = "wolfhud_hudlist_loot_treasure", 	priority = 1 },	-- San Martin Bank
		turret =		{ text = "hud_carry_turret", 				priority = 1 },	-- Transport: Train
		vr = 			{ text = "wolfhud_hudlist_loot_vr", 		priority = 1 },	-- Stealing Xmas
		warhead =		{ text = "hud_carry_warhead", 				priority = 1 },	-- Meltdown
		weapon =		{ text = "wolfhud_hudlist_loot_weapon", 	priority = 1 },
		wine = 			{ text = "hud_carry_wine", 					priority = 1 },	-- Stealing Xmas
		body = 			{ text = "hud_carry_person", 				priority = 1 },	-- Boiling point
		crate = 		{ text = "wolfhud_hudlist_loot_crate", 		priority = 2, no_separate = true },
		xmas_present = 	{ text = "hud_carry_present", 				priority = 2, no_separate = true },	-- White Xmas
		shopping_bag = 	{ text = "wolfhud_hudlist_loot_bag", 		priority = 2, no_separate = true },	-- White Xmas
		showcase = 		{ text = "wolfhud_hudlist_showcase", 		priority = 2, no_separate = true },	-- Diamond heist + Diamond Museum
	}
	function HUDList.LootItem:init(parent, name, id, members)
		local loot_data = HUDList.LootItem.MAP[id]
		HUDList.LootItem.super.init(self, parent, name, loot_data.icon_data or { hudtabs = { 32, 33, 32, 32 }, alpha = 0.75, w_ratio = 1.2 }, loot_data)

		self._id = id
		self._loot_types = {}
		self._total_count = 0
		self._bagged_count = 0
		self._unbagged_count = 0

		self._icon:set_center(self._panel:center())
		self._icon:set_top(self._panel:top())

		if loot_data.text then
			local txt = loot_data.no_localize and loot_data.text or managers.localization:text(loot_data.text)

			self._name_text = self._panel:text({
				name = "text",
				text = txt:sub(1, 10) or "",
				align = "center",
				vertical = "center",
				w = self._panel:w(),
				h = self._panel:w(),
				color = HUDListManager.ListOptions.list_color_bg or Color(0.0, 0.5, 0.0),
				blend_mode = "normal",
				font = tweak_data.hud_corner.assault_font,
				font_size = self._panel:w() * 0.45,
				layer = 10
			})
			local _, _, w, h = self._name_text:text_rect()
			local font_size = math.min(self._name_text:font_size() * (self._name_text:w() / w) * 0.9, self._name_text:font_size())
			self._name_text:set_font_size(font_size)
			self._name_text:set_center(self._icon:center())
			self._name_text:set_y(self._name_text:y() + self._icon:h() * 0.1)
		end

		local keys = {}

		for _, loot_id in pairs(members) do
			self._loot_types[loot_id] = true
			table.insert(keys, loot_id)
		end

		self._listener_clbks = {
			{
				name = string.format("HUDList_%s_loot_count_listener", id),
				source = "loot_count",
				event = { "change" },
				clbk = callback(self, self, "_change_loot_count_clbk"),
				keys = keys
			}
		}

		self:update_value()
	end

	function HUDList.LootItem:rescale(new_scale)
		local enabled, size_mult = HUDList.LootItem.super.rescale(self, new_scale)

		if enabled then
			self._name_text:set_size(self._panel:w(), self._panel:h())
			local _, _, w, h = self._name_text:text_rect()
			local font_size = math.min(self._name_text:font_size() * (self._name_text:w() / w) * 0.9, self._name_text:font_size())
			self._name_text:set_font_size(font_size)
			self._name_text:set_center(self._icon:center())
			self._name_text:set_y(self._name_text:y() + self._icon:h() * 0.1)
		end

		return enabled, size_mult
	end

	function HUDList.LootItem:update_value()
		local total_unbagged = 0
		local total_bagged = 0

		for _, data in pairs(managers.gameinfo:get_loot()) do
			if self._loot_types[data.carry_id] then
				local loot_type = HUDListManager.LOOT_TYPES[data.carry_id]
				local condition_clbk = HUDListManager.LOOT_TYPES_CONDITIONS[loot_type]

				if not condition_clbk or condition_clbk(loot_type, data) then
					if data.bagged then
						total_bagged = total_bagged + data.count
					else
						total_unbagged = total_unbagged + data.count
					end
				end
			end
		end

		self:set_count(total_unbagged, total_bagged)
	end

	function HUDList.LootItem:get_count()
		return self._unbagged_count or 0, self._bagged_count or 0
	end

	function HUDList.LootItem:set_count(unbagged, bagged)
		self._unbagged_count = unbagged
		self._bagged_count = bagged
		self._total_count = self._unbagged_count + self._bagged_count

		if HUDListManager.ListOptions.separate_bagged_loot and not HUDList.LootItem.MAP[self._id].no_separate then
			self._text:set_text(self._unbagged_count .. "/" .. self._bagged_count)
		else
			self._text:set_text(self._total_count)
		end

		self:set_active(self._total_count > 0)
	end

	function HUDList.LootItem:_change_loot_count_clbk(event, carry_id, bagged, value, data)
		local loot_type = HUDListManager.LOOT_TYPES[carry_id] or HUDListManager.POTENTIAL_LOOT_TYPES[carry_id]
		local condition_clbk = HUDListManager.LOOT_TYPES_CONDITIONS[loot_type]

		if not condition_clbk or condition_clbk(loot_type, data) then
			local bagged_count = self._bagged_count
			local unbagged_count = self._unbagged_count

			if bagged then
				bagged_count = bagged_count + value
			else
				unbagged_count = unbagged_count + value
			end

			self:set_count(unbagged_count, bagged_count)

			if self:is_active() and value ~= 0 then
				local increase = value > 0
				self._active_count_change = {
					duration = 0.5,
					current = 0,
					color = increase and self._change_increase_color or self._change_decrease_color,
					invert_progress = not increase
				}
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Left list items

	HUDList.LeftListIcon = HUDList.LeftListIcon or class(HUDList.ItemBase)
	function HUDList.LeftListIcon:init(parent, name, ratio_w, ratio_h, icons)
		HUDList.LeftListIcon.super.init(self, parent, name, { align = "center", w = parent:panel():h() * (ratio_w or 1), h = parent:panel():h() * (ratio_h or 1) })

		self._icons = {}
		for i, icon in ipairs(icons) do
			local texture, texture_rect = get_icon_data(icon)

			local bitmap = self._panel:bitmap({
				name = "icon_" .. tostring(i),
				texture = texture,
				texture_rect = texture_rect or nil,
				h = self:panel():w() * (icon.h or 1),
				w = self:panel():w() * (icon.w or 1),
				blend_mode = "add",
				color = icon.color or Color.white,
			})

			bitmap:set_center(self._panel:center())
			if icon.valign == "top" then
				bitmap:set_top(self._panel:top())
			elseif icon.valign == "bottom" then
				bitmap:set_bottom(self._panel:bottom())
			end
			if icon.halign == "left" then
				bitmap:set_left(self._panel:left())
			elseif icon.halign == "right" then
				bitmap:set_right(self._panel:right())
			end

			table.insert(self._icons, bitmap)
		end
	end

	function HUDList.LeftListIcon:rescale(new_scale)
		local enabled, size_mult = HUDList.LeftListIcon.super.rescale(self, new_scale)

		if enabled then
			for _, icon in ipairs(self._icons) do
				icon:set_size(icon:w() * size_mult, icon:h() * size_mult)
				icon:set_x(icon:x() * size_mult)
				icon:set_y(icon:y() * size_mult)
			end
		end

		return enabled, size_mult
	end

	function HUDList.LeftListIcon:set_color(color)
		HUDList.LeftListIcon.super.set_color(self, color)
		for _, icon in ipairs(self._icons) do
			icon:set_color(color)
		end
	end

	HUDList.LeftListItem = HUDList.LeftListItem or class(HUDList.ItemBase)
	function HUDList.LeftListItem:init(parent, name, params)
		params = params or {}
		params.align = params.align or "left"
		params.w = params.w or parent:panel():h()
		params.h = params.h or parent:panel():h()
		HUDList.LeftListItem.super.init(self, parent, name, params)

		self._progress_bar = PanelFrame:new(self._panel, {
			w = params.progress_w or self._panel:w(),
			h = params.progress_h or self._panel:h(),
			invert_progress = params.invert_progress ~= false,
			bar_w = 2,
			bar_color = params.progress_color or (HUDListManager.ListOptions.list_color or Color.white),
			bg_color = (HUDListManager.ListOptions.list_color_bg or Color.black),
			bar_alpha = params.progress_alpha or HUDListManager.ListOptions.left_list_progress_alpha or 0.4,
			add_bg = true,
		})
		self._progress_bar:set_ratio(1)
	end

	function HUDList.LeftListItem:rescale(new_scale)
		local enabled, size_mult = HUDList.LeftListItem.super.rescale(self, new_scale)

		if enabled then
			self._progress_bar:set_size(self._progress_bar:w() * size_mult, self._progress_bar:h() * size_mult)
		end

		return enabled, size_mult
	end

	function HUDList.LeftListItem:set_color(color)
		HUDList.LeftListItem.super.set_color(self, color)
		self._progress_bar:set_color(color)
	end

	function HUDList.LeftListItem:set_bg_color(color)
		HUDList.LeftListItem.super.set_bg_color(self, color)
		self._progress_bar:set_bg_color(color)
	end

	function HUDList.LeftListItem:set_progress_alpha(alpha)
		self._progress_bar:set_alpha(alpha)
	end

	HUDList.TimerItem = HUDList.TimerItem or class(HUDList.LeftListItem)
	HUDList.TimerItem.DEVICE_TYPES = {
		digital 		= { class = "TimerItem", 			name = "wolfhud_hudlist_device_timer" 	},
		drill 			= { class = "UpgradeableTimerItem", name = "wolfhud_hudlist_device_drill" 	},
		drill_noupgrade	= { class = "TimerItem", 			name = "wolfhud_hudlist_device_drill" 	},
		saw 			= { class = "UpgradeableTimerItem", name = "wolfhud_hudlist_device_saw" 	},
		saw_noupgrade 	= { class = "TimerItem", 			name = "wolfhud_hudlist_device_saw" 	},
		hack 			= { class = "TimerItem", 			name = "wolfhud_hudlist_device_hack" 	},
		timer 			= { class = "TimerItem", 			name = "wolfhud_hudlist_device_timer" 	},
		securitylock 	= { class = "SecurityTimerItem", 	name = "wolfhud_hudlist_device_security"},
	}
	function HUDList.TimerItem:init(parent, name, data)
		self.STANDARD_COLOR = HUDListManager.ListOptions.list_color or Color(1, 1, 1, 1)
		self.DISABLED_COLOR = Color(1, 1, 0, 0)
		self.FLASH_SPEED = 2

		self._show_distance = (data.show_distance ~= false)
		self._unit = data.unit
		self._device_type = data.device_type
		self._jammed = data.jammed
		self._powered = data.powered
--[[
		self._upgradable = data.upgradable
		self._auto_repair = data.auto_repair
		self._upgrades = data.upgrades or {}
		self._show_upgrade_icons = data.can_have_upgrades or false
]]
		HUDList.TimerItem.super.init(self, parent, name, { align = "left", w = data.w or (parent:panel():h() * 4/5), h = parent:panel():h() })

		local txt = HUDList.TimerItem.DEVICE_TYPES[self._device_type] and managers.localization:text(HUDList.TimerItem.DEVICE_TYPES[self._device_type].name or "N/A") or tostring(self._device_type)
		self._type_text = self._panel:text({
			name = "type_text",
			text = txt,
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:h() * 0.3,
			color = self.STANDARD_COLOR or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.3
		})

		self._progress_bar:set_h(self._panel:h() * 0.7)
		self._progress_bar:set_bottom(self._panel:bottom())

		self._distance_text = self._panel:text({
			name = "distance",
			align = "center",
			vertical = "top",
			y = self._progress_bar:y() + 2,
			w = self._progress_bar:w(),
			h = self._progress_bar:h() - 2,
			color = self.STANDARD_COLOR or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._progress_bar:h() * 0.4
		})

		self._time_text = self._panel:text({
			name = "time",
			align = "center",
			vertical = "bottom",
			y = self._progress_bar:y(),
			w = self._progress_bar:w(),
			h = self._progress_bar:h(),
			color = self.STANDARD_COLOR or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._progress_bar:h() * 0.6
		})

		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
		}
		self:_set_colors(self.STANDARD_COLOR)

		self:_set_jammed(data)
		self:_set_powered(data)
		self:_update_timer(data)

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_timer_listener_%s", key)
		local events = {
			update = callback(self, self, "_update_timer"),
			set_jammed = callback(self, self, "_set_jammed"),
			set_powered = callback(self, self, "_set_powered"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "timer", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.TimerItem:rescale(new_scale)
		local enabled, size_mult = HUDList.TimerItem.super.rescale(self, new_scale)

		if enabled then
			self._type_text:set_size(self._panel:w(), self._panel:h() * 0.3)

			self._distance_text:set_size(self._progress_bar:w(), self._progress_bar:h() - 2)
			self._distance_text:set_y(self._progress_bar:y() + 2)

			self._time_text:set_size(self._progress_bar:w(), self._progress_bar:h())
			self._time_text:set_y(self._progress_bar:y())
		end

		return enabled, size_mult
	end

	function HUDList.TimerItem:set_color(color)
		HUDList.TimerItem.super.set_color(self, color)
		self.STANDARD_COLOR = color
		self:_set_colors(self.STANDARD_COLOR)
	end

	function HUDList.TimerItem:priority()
		return self._remaining and Utl.round(self._remaining, 1) or self._priority
	end

	function HUDList.TimerItem:update(t, dt)
		HUDList.TimerItem.super.update(self, t, dt)
		
		if not alive(self._unit) then
			self:delete()
			return
		end

		self:_update_distance()

		if self._jammed or not self._powered then
			local new_color = get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			self:_set_colors(new_color)
		end
	end
	
	function HUDList.TimerItem:_update_distance()
		if self._show_distance and alive(self._unit) then
			self._distance_text:set_text(get_distance_to_player(self._unit))
		end
	end

	function HUDList.TimerItem:_update_timer(data)
		if data.timer_value then
			self._remaining = data.timer_value
			self._time_text:set_text(format_time_string(self._remaining))
			if data.timer_ratio then
				self._progress_bar:set_ratio(data.timer_ratio)
			end
		end
	end

	function HUDList.TimerItem:_set_jammed(data)
		self._jammed = data.jammed
		self:_check_is_running()
	end

	function HUDList.TimerItem:_set_powered(data)
		self._powered = data.powered
		self:_check_is_running()
	end

	function HUDList.TimerItem:_check_is_running()
		if not self._jammed and self._powered then
			self:_set_colors(self._flash_color_table[2].color)
		end
	end

	function HUDList.TimerItem:_set_colors(color)
		self._time_text:set_color(color)
		self._type_text:set_color(color)
		self._distance_text:set_color(color)
		self._progress_bar:set_color(color)
	end

	HUDList.UpgradeableTimerItem = HUDList.UpgradeableTimerItem or class(HUDList.TimerItem)
	function HUDList.UpgradeableTimerItem:init(parent, name, data)
		self.UPGRADE_COLOR = Color(1, 0.0, 0.8, 1.0)
		self.AUTOREPAIR_COLOR = Color(1, 1, 0.5, 1)
		self.UPGRADE_LVL_COLORS = { Color(0.3, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)}

		self._upgradable = data.upgradable
		self._auto_repair = data.auto_repair

		data.w = parent:panel():h()

		HUDList.UpgradeableTimerItem.super.init(self, parent, name, data)

		self._upgrade_types = { "faster", "silent", "restarter"}
		self._upgrade_icons = {}

		local icon_size = (self._panel:h() - self._type_text:h() - 5) / #self._upgrade_types
		local y = self._time_text:y() + 3
		for i, upgrade in ipairs(self._upgrade_types) do
			local icon = self._panel:bitmap{
				texture = "guis/textures/pd2/skilltree/drillgui_icon_" .. upgrade,
				y = y + icon_size * (i-1),
				w = icon_size,
				h = icon_size,
				align = "center",
				vertical = "center",
				valign = "scale",
				halign = "scale",
				color = self.UPGRADE_LVL_COLORS[1],
				visible = true,
			}
			icon:set_right(self._panel:w() - 3)
			self._upgrade_icons[upgrade] = icon
		end

		self._time_text:set_w(self._panel:w() - icon_size)
		self._distance_text:set_w(self._panel:w() - icon_size)

		self:_set_upgradable(data)
		self:_set_upgrades(data)
		self:_set_autorepair(data)

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_timer_listener_%s", key)
		local events = {
			set_upgradable = callback(self, self, "_set_upgradable"),
			set_upgrades = callback(self, self, "_set_upgrades"),
			set_autorepair = callback(self, self, "_set_autorepair"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "timer", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.UpgradeableTimerItem:rescale(new_scale)
		local enabled, size_mult = HUDList.UpgradeableTimerItem.super.rescale(self, new_scale)

		if enabled then
			local y = self._time_text:y() + 3
			local icon_size = (self._panel:h() - self._type_text:h() - 5) / #self._upgrade_types
			for i, icon in ipairs(self._upgrade_icons) do
				icon:set_size(icon_size, icon_size)
				icon:set_right(self._panel:w() - 3)
				icon:set_y(y + icon_size * (i-1))
			end
		end

		return enabled, size_mult
	end

	function HUDList.UpgradeableTimerItem:set_color(color)
		HUDList.UpgradeableTimerItem.super.set_color(self, color)
		local current_color = self._auto_repair and self.AUTOREPAIR_COLOR or self._upgradable and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table[2].color = current_color
		self:_set_colors(current_color)
	end

	function HUDList.UpgradeableTimerItem:_set_upgradable(data)
		self._upgradable = data.upgradable

		local current_color = self._auto_repair and self.AUTOREPAIR_COLOR or self._upgradable and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table[2].color = current_color
		self:_set_colors(current_color)
	end

	function HUDList.UpgradeableTimerItem:_set_upgrades(data)
		if data.upgrades then
			for _, upgrade in ipairs(self._upgrade_types) do
				if data.upgrades[upgrade] and self._upgrade_icons[upgrade] then
					local upgrade_color = self.UPGRADE_LVL_COLORS[math.clamp((data.upgrades[upgrade] or 0) + 1, 1, #self.UPGRADE_LVL_COLORS)] or Color.red
					self._upgrade_icons[upgrade]:set_color(upgrade_color)
				end
			end
		end
	end

	function HUDList.UpgradeableTimerItem:_set_autorepair(data)
		self._auto_repair = data.auto_repair

		local current_color = self._auto_repair and self.AUTOREPAIR_COLOR or self._upgradable and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table[2].color = current_color
		self:_set_colors(current_color)
	end

	HUDList.SecurityTimerItem = HUDList.SecurityTimerItem or class(HUDList.TimerItem)
	function HUDList.SecurityTimerItem:init(parent, name, data)
		data.show_distance = false	-- Disabled, we show current and total bars there.
		
		HUDList.SecurityTimerItem.super.init(self, parent, name, data)

		self._bars = { current = data.current_bar or 1, total = data.total_bars or 3}
		self:_update_bar_text()

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_timer_listener_%s", key)
		local events = {
			set_current_bar = callback(self, self, "_set_current_bar"),
			set_total_bars = callback(self, self, "_set_total_bars"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "timer", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.SecurityTimerItem:_update_bar_text()
		local text = managers.localization:text("wolfhud_hudlist_device_security_bar", { CURRENT = self._bars.current or 1, TOTAL = self._bars.total or 3})
		self._distance_text:set_text(text)
	end

	function HUDList.SecurityTimerItem:_set_current_bar(data)
		if data.current_bar then
			self._bars.current = data.current_bar
			self:_update_bar_text()
		end
	end

	function HUDList.SecurityTimerItem:_set_total_bars(data)
		if data.total_bars then
			self._bars.total = data.total_bars
			self:_update_bar_text()
		end
	end

	HUDList.TemperatureGaugeItem = HUDList.TemperatureGaugeItem or class(HUDList.TimerItem)
	function HUDList.TemperatureGaugeItem:init(parent, name, timer_data, params)
		self._start = params.start
		self._goal = params.goal
		self._last_value = self._start

		HUDList.TemperatureGaugeItem.super.init(self, parent, name, timer_data)

		self._type_text:set_text("Temp")
	end

	function HUDList.TemperatureGaugeItem:update(t, dt)
		HUDList.TemperatureGaugeItem.super.update(self, t, dt)
		
		local estimate = "N/A"
		if self._remaining and self._last_update_t then
			local time_left = self._remaining - math.max(t - self._last_update_t, 0)
			estimate = format_time_string(time_left)
		end
		self._time_text:set_text(estimate)
	end

	function HUDList.TemperatureGaugeItem:_update_timer(data)
		if data.timer_value then
			local dv = math.max(data.timer_value - self._last_value, 0)
			if dv > 0 then
				self._remaining = math.max(self._goal - data.timer_value, 0) / dv
				self._last_update_t = Application:time()
			end

			self._distance_text:set_text(string.format("%d / %d", data.timer_value, self._goal))
			self._progress_bar:set_ratio(data.timer_value / self._goal)
			self._last_value = data.timer_value
		end
	end

	HUDList.EquipmentItem = HUDList.EquipmentItem or class(HUDList.LeftListItem)
	HUDList.EquipmentItem.EQUIPMENT_TABLE = {
		sentry 			= {	skills 		= { 7,  5 }, priority = 0 },
		ammo_bag 		= {	skills 		= { 1,  0 }, priority = 3 },
		doc_bag 		= {	skills 		= { 2,  7 }, priority = 4 },
		first_aid_kit	= {	skills 		= { 3, 10 }, priority = 5 },
		body_bag 		= {	skills 		= { 5, 11 }, priority = 6 },
		grenade_crate 	= {	preplanning = { 1,  0 }, priority = 2 },
	}
	function HUDList.EquipmentItem:init(parent, name, data, equipment_type)
		local icon_data = HUDList.EquipmentItem.EQUIPMENT_TABLE[equipment_type]

		HUDList.EquipmentItem.super.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h(), priority = icon_data.priority })

		self._unit = data.unit
		self._key = name --normally unit:key(), exception for aggregated items that have no singular unit
		self._equipment_type = equipment_type

		local texture, texture_rect = get_icon_data(icon_data)

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			h = self:panel():w() * 0.8,
			w = self:panel():w() * 0.8,
			blend_mode = "add",
			layer = 0,
			color = HUDListManager.ListOptions.list_color or Color.white,
		})
		self._icon:set_center(self._panel:center())
		self._icon:set_top(0)
		self:_set_owner(data)

		local id = string.format("HUDList_equipment_listener_%s", self._key)
		local events = {
			set_owner = callback(self, self, "_set_owner"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = self._equipment_type, event = { event }, clbk = clbk, keys = { self._key }, data_only = true })
		end

		if not self._defer_activation then
			self:activate()
		end
	end

	function HUDList.EquipmentItem:rescale(new_scale)
		local enabled, size_mult = HUDList.EquipmentItem.super.rescale(self, new_scale)

		if enabled then
			self._icon:set_size(self:panel():w() * 0.8, self:panel():w() * 0.8)
			self._icon:set_center_x(self:panel():w() * 0.5)
		end

		return enabled, size_mult
	end

	function HUDList.EquipmentItem:set_color(color)
		HUDList.EquipmentItem.super.set_color(self, color)

		if not self._owner then
			self._icon:set_color(color)
		end
	end

	function HUDList.EquipmentItem:_set_owner(data)
		if data.owner then
			self._owner = data.owner
			self:_set_color()
		end
	end

	function HUDList.EquipmentItem:is_player_owner()
		return self._owner == managers.network:session():local_peer():id()
	end

	function HUDList.EquipmentItem:get_type()
		return self._equipment_type
	end

	function HUDList.EquipmentItem:_set_color()
		local color = self._owner and self._owner > 0 and tweak_data.chat_colors[self._owner]:with_alpha(1) or HUDListManager.ListOptions.list_color or Color.white
		self._icon:set_color(color)
	end

	HUDList.BagEquipmentItem = HUDList.BagEquipmentItem or class(HUDList.EquipmentItem)
	function HUDList.BagEquipmentItem:init(parent, name, data, equipment_type)
		HUDList.BagEquipmentItem.super.init(self, parent, name, data, equipment_type)

		self._info_text = self._panel:text({
			name = "info",
			align = "center",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:h() * 0.4,
			color = Color.white,
			layer = 1,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.4,
		})
		self._info_text:set_bottom(self._panel:h())

		self:_set_max_amount(data)
		self:_set_amount(data)
		self:_set_amount_offset(data)

		local id = string.format("HUDList_equipment_listener_%s", self._key)
		local events = {
			set_max_amount = callback(self, self, "_set_max_amount"),
			set_amount = callback(self, self, "_set_amount"),
			set_amount_offset = callback(self, self, "_set_amount_offset"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = self._equipment_type, event = { event }, clbk = clbk, keys = { self._key }, data_only = true })
		end
	end

	function HUDList.BagEquipmentItem:rescale(new_scale)
		local enabled, size_mult = HUDList.BagEquipmentItem.super.rescale(self, new_scale)

		if enabled then
			self._info_text:set_font_size(self._panel:h() * 0.4)
			self._info_text:set_size(self._panel:w(), self._panel:h() * 0.4)
			self._info_text:set_bottom(self._panel:h())
		end

		return enabled, size_mult
	end

	function HUDList.BagEquipmentItem:priority()
		return HUDList.BagEquipmentItem.super.priority(self) - Utl.round(self:amount() * 0.1, 3)
	end

	function HUDList.BagEquipmentItem:amount()
		return (self._amount or 0) + (self._amount_offset or 0)
	end

	function HUDList.BagEquipmentItem:max_amount()
		return (self._max_amount or 0) + (self._amount_offset or 0)
	end

	function HUDList.BagEquipmentItem:amount_ratio()
		return math.clamp(self:amount() / self:max_amount(), 0, 1)
	end

	function HUDList.BagEquipmentItem:_set_max_amount(data)
		if data.max_amount then
			self._max_amount = data.max_amount
			self:_update_info_text()
		end
	end

	function HUDList.BagEquipmentItem:_set_amount(data)
		if data.amount then
			self._amount = data.amount
			self._max_amount = self._max_amount or self._amount
			self:_update_info_text()
		end
	end

	function HUDList.BagEquipmentItem:_set_amount_offset(data)
		if data.amount_offset then
			self._amount_offset = data.amount_offset
			self:_update_info_text()
		end
	end

	function HUDList.BagEquipmentItem:_update_info_text()
		if self._amount or self._amount_offset then
			self._info_text:set_text(string.format("%.0f", self:amount()))
			self._progress_bar:set_ratio(self:amount_ratio())
			local new_color = get_color_from_table(self:amount(), self:max_amount())
			self._info_text:set_color(new_color)
			self._progress_bar:set_color(new_color)

			if self._parent_list then
				self._parent_list:reapply_item_priorities(true, 0.5)
			end
		end
	end

	HUDList.AmmoBagItem = HUDList.AmmoBagItem or class(HUDList.BagEquipmentItem)
	function HUDList.AmmoBagItem:_update_info_text()
		if self._amount then
			self._info_text:set_text(string.format("%.0f%%", self:amount() * 100))
			self._progress_bar:set_ratio(self:amount_ratio())
			local new_color = get_color_from_table(self:amount(), self:max_amount())
			self._info_text:set_color(new_color)
			self._progress_bar:set_color(new_color)

			if self._parent_list then
				self._parent_list:reapply_item_priorities(true, 0.5)
			end
		end
	end

	HUDList.BodyBagItem = HUDList.BodyBagItem or class(HUDList.BagEquipmentItem)
	function HUDList.BodyBagItem:init(...)
		self._defer_activation = true

		HUDList.BodyBagItem.super.init(self, ...)

		table.insert(self._listener_clbks, {
			name = string.format("HUDList_equipment_listener_%s", self._key),
			source = "whisper_mode",
			event = { "change" },
			clbk = callback(self, self, "_whisper_mode_change"),
			data_only = true,
		})

		self:set_active(managers.groupai:state():whisper_mode())
	end

	function HUDList.BodyBagItem:_whisper_mode_change(status)
		self:set_active(self:amount() > 0 and status)
	end

	HUDList.SentryEquipmentItem = HUDList.SentryEquipmentItem or class(HUDList.EquipmentItem)
	function HUDList.SentryEquipmentItem:init(parent, name, data)
		HUDList.SentryEquipmentItem.super.init(self, parent, name, data, "sentry")

		self._bar_bg = self._panel:rect({
			name = "bar_bg",
			x = self._panel:w() * 0.1,
			w = self._panel:w() * 0.8,
			h = self._panel:h() * 0.3,
			color = Color.black,
			alpha = 0.5,
			layer = 0,
		})
		self._bar_bg:set_bottom(self._panel:h() * 0.9)

		self._health_bar = self._panel:rect({
			name = "health_bar",
			x = self._bar_bg:x(),
			y = self._bar_bg:y(),
			h = self._bar_bg:h() * 0.5,
			color = Color(0.7, 0.0, 0.0),
			layer = 1,
		})

		self._ammo_bar = self._panel:rect({
			name = "ammo_bar",
			x = self._bar_bg:x(),
			y = self._bar_bg:y() + self._bar_bg:h() * 0.5,
			h = self._bar_bg:h() * 0.5,
			color = Color(0.0, 0.7, 0.0),
			layer = 1,
		})

		self._kills = self._panel:text({
			name = "kills",
			text = "0",
			align = "left",
			vertical = "top",
			x = 3,
			y = 2,
			w = self._panel:w(),
			h = self._panel:h(),
			color = Color.white,
			alpha = 0.75,
			layer = 10,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.3,
		})

		self:_set_ammo_ratio(data)
		self:_set_health_ratio(data)

		local id = string.format("HUDList_equipment_listener_%s", self._key)
		local events = {
			set_ammo_ratio = callback(self, self, "_set_ammo_ratio"),
			set_health_ratio = callback(self, self, "_set_health_ratio"),
			set_kills = callback(self, self, "_set_kills"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "sentry", event = { event }, clbk = clbk, keys = { self._key }, data_only = true })
		end
	end

	function HUDList.SentryEquipmentItem:rescale(new_scale)
		local enabled, size_mult = HUDList.SentryEquipmentItem.super.rescale(self, new_scale)

		if enabled then
			self._bar_bg:set_size(self._panel:w() * 0.8, self._panel:h() * 0.3)
			self._bar_bg:set_x(self._panel:w() * 0.1)
			self._bar_bg:set_bottom(self._panel:h() * 0.9)

			self._health_bar:set_size(self._health_bar:w() * size_mult, self._bar_bg:h() * 0.5)
			self._health_bar:set_x(self._bar_bg:x())
			self._health_bar:set_y(self._bar_bg:y())

			self._ammo_bar:set_size(self._ammo_bar:w() * size_mult, self._bar_bg:h() * 0.5)
			self._ammo_bar:set_x(self._bar_bg:x())
			self._ammo_bar:set_y(self._bar_bg:y() + self._bar_bg:h() * 0.5)

			self._kills:set_size(self._panel:w(), self._panel:h())
			self._kills:set_font_size(self._panel:h() * 0.3)
		end

		return enabled, size_mult
	end

	function HUDList.SentryEquipmentItem:_set_ammo_ratio(data)
		if data.ammo_ratio then
			self._ammo_ratio = data.ammo_ratio or 0
			self._ammo_bar:set_w(self._bar_bg:w() * self._ammo_ratio)
			self._progress_bar:set_ratio(self._ammo_ratio)

			if self._ammo_ratio <= 0 then
				self:_set_inactive(nil)
			end
		end
	end

	function HUDList.SentryEquipmentItem:_set_health_ratio(data)
		if data.health_ratio then
			self._health_ratio = data.health_ratio or 0
			self._health_bar:set_w(self._bar_bg:w() * self._health_ratio)
			self._progress_bar:set_color(math.lerp(get_color_from_table(self._health_ratio, 1), (HUDListManager.ListOptions.list_color or Color.white), 0.4))

			if self._health_ratio <= 0 then
				self:_set_inactive(nil)
			end
		end
	end

	function HUDList.SentryEquipmentItem:_set_kills(data)
		if data.kills == 10 then
			self._kills:set_font_size(self._panel:h() * 0.25)
		end
		self._kills:set_text(tostring(data.kills))
	end

	function HUDList.SentryEquipmentItem:_set_inactive(duration)
		if self:is_player_owner() then
			if not self._animating then
				self._icon:animate(callback(self, self, "_animate_inactive"), Color.red, duration, callback(self, self, "deactivate"))
			end
		else
			self:deactivate()
		end
	end

	function HUDList.SentryEquipmentItem:_animate_inactive(icon, flash_color, duration, expire_clbk)
		self._animating = true
		local base_color = icon:color()
		local t = 0

		while self._animating and (not duration or duration > t) do
			local s = math.sin(t*720) * 0.5 + 0.5
			local r = math.lerp(base_color.r, flash_color.r, s)
			local g = math.lerp(base_color.g, flash_color.g, s)
			local b = math.lerp(base_color.b, flash_color.b, s)
			icon:set_color(Color(r, g, b))
			t = t + coroutine.yield()
		end

		self:_set_color()
		self._animating = nil

		if expire_clbk then
			expire_clbk()
		end
	end

	HUDList.MinionItem = HUDList.MinionItem or class(HUDList.ItemBase)
	HUDList.MinionItem.name_max = 10
	function HUDList.MinionItem:init(parent, name, data)
		HUDList.MinionItem.super.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h() })

		self._unit = data.unit
		local type_table = self._unit:base()._tweak_table and HUDListManager.UNIT_TYPES[self._unit:base()._tweak_table] or false
		local type_string = type_table and managers.localization:to_upper_text(type_table.long_name) or "UNKNOWN"
		if type_string:len() > self.name_max then
			type_string = type_string:match("(%S+)(.+)")
			type_string = type_string:sub(0, self.name_max)
		end

		self._health_bar = self._panel:bitmap({
			name = "radial_health",
			texture = "guis/textures/pd2/hud_health",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 2,
			color = Color(1, 1, 0, 0),
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._health_bar:set_texture_rect(self._health_bar:texture_width(), 0, -self._health_bar:texture_width(), self._health_bar:texture_height())
		self._health_bar:set_bottom(self._panel:bottom())

		self._hit_indicator = self._panel:bitmap({
			name = "hit_indicator",
			texture = "guis/textures/pd2/hud_radial_rim",
			blend_mode = "add",
			layer = 1,
			color = Color.red,
			alpha = 0,
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._hit_indicator:set_center(self._health_bar:center())

		self._outline = self._panel:bitmap({
			name = "outline",
			texture = "guis/textures/pd2/hud_shield",
			blend_mode = "add",
			w = self._panel:w() * 0.95,
			h = self._panel:w() * 0.95,
			layer = 1,
			alpha = 0.3,
			color = Color(0.8, 0.8, 1.0),
		})
		self._outline:set_texture_rect(self._outline:texture_width(), 0, -self._outline:texture_width(), self._outline:texture_height())
		self._outline:set_center(self._health_bar:center())

		self._damage_upgrade_text = self._panel:text({
			name = "dmg_upgrade",
			text = utf8.char(57364),
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:w(),
			color = Color.white,
			layer = 3,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:w() * 0.4,
			alpha  = 0.3
		})
		self._damage_upgrade_text:set_bottom(self._panel:bottom())

		self._unit_type = self._panel:text({
			name = "type",
			text = type_string,
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:w() * 0.3,
			color = Color.white,
			layer = 3,
			font = tweak_data.hud_corner.assault_font,
			font_size = math.min(8 / string.len(type_string), 1) * 0.25 * self._panel:h(),
		})

		self._kills = self._panel:text({
			name = "kills",
			text = "0",
			align = "right",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:w(),
			color = Color.white,
			alpha = 0.75,
			layer = 10,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:w() * 0.3,
		})
		self._kills:set_center(self._health_bar:center())

		if data.health_ratio then
			self:_set_health_ratio(data, true)
		end
		if data.damage_resistance then
			self:_set_damage_resistance(data)
		end
		if data.damage_multiplier then
			self:_set_damage_multiplier(data)
		end

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_minion_listener_%s", key)
		local events = {
			set_health_ratio = callback(self, self, "_set_health_ratio"),
			set_owner = callback(self, self, "_set_owner"),
			set_kills = callback(self, self, "_set_kills"),
			set_damage_resistance = callback(self, self, "_set_damage_resistance"),
			set_damage_multiplier = callback(self, self, "_set_damage_multiplier"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "minion", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.MinionItem:rescale(new_scale)
		local enabled, size_mult = HUDList.MinionItem.super.rescale(self, new_scale)

		if enabled then
			self._health_bar:set_size(self._panel:w(), self._panel:w())
			self._health_bar:set_bottom(self._panel:h())
			self._hit_indicator:set_size(self._panel:w(), self._panel:w())
			self._hit_indicator:set_center(self._health_bar:center())
			self._outline:set_size(self._panel:w() * 0.95, self._panel:w() * 0.95)
			self._outline:set_center(self._health_bar:center())
			self._damage_upgrade_text:set_size(self._panel:w(), self._panel:w())
			self._damage_upgrade_text:set_font_size(self._panel:w() * 0.4)
			self._damage_upgrade_text:set_bottom(self._panel:h())
			self._unit_type:set_size(self._panel:w(), self._panel:w() * 0.3)
			self._kills:set_size(self._panel:w(), self._panel:w())
			self._kills:set_font_size(self._kills:font_size() * size_mult)
			self._kills:set_center(self._health_bar:center())
		end

		return enabled, size_mult
	end

	function HUDList.MinionItem:set_color(color)
		HUDList.MinionItem.super.set_color(self, color)
		if not self._owner then
			self._unit_type:set_color(color)
		end
	end

	function HUDList.MinionItem:owner()
		return self._owner
	end

	function HUDList.MinionItem:_set_health_ratio(data, skip_animate)
		self._health_bar:set_color(Color(1, data.health_ratio, 1, 1))
		if not skip_animate then
			self._hit_indicator:stop()
			self._hit_indicator:animate(callback(self, self, "_animate_damage"))
		end
	end

	function HUDList.MinionItem:_set_owner(data)
		if data.owner then
			self._owner = data.owner
			self._unit_type:set_color(tweak_data.chat_colors[data.owner]:with_alpha(1) or Color(1, 1, 1, 1))

			if HUDListManager.ListOptions.show_own_minions_only then
				self:set_active(data.owner == managers.network:session():local_peer():id())
			end
		end
	end

	function HUDList.MinionItem:_set_kills(data)
		if data.kills == 10 then
			self._kills:set_font_size(self._panel:w() * 0.2)
		end
		self._kills:set_text(data.kills)
	end

	function HUDList.MinionItem:_set_damage_resistance(data)
		local max_mult = tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[2]
		local alpha = math.clamp((1 - data.damage_resistance) / (1 - max_mult), 0, 1) * 0.7 + 0.3
		self._outline:set_alpha(alpha)
	end

	function HUDList.MinionItem:_set_damage_multiplier(data)
		local min_mult = tweak_data.upgrades.values.player.convert_enemies_damage_multiplier[1] 	-- 0.65, damage multiplier if player has joker skill
		local max_mult = tweak_data.upgrades.values.player.convert_enemies_damage_multiplier[2] 	-- 1.00, damage multiplier if player has 35% damage increase skill
		local alpha = math.clamp((data.damage_multiplier - min_mult) / (max_mult - min_mult), 0, 1) * 0.7 + 0.3
		self._damage_upgrade_text:set_alpha(alpha)
	end

	function HUDList.MinionItem:_animate_damage(icon)
		local duration = 1
		local t = duration
		icon:set_alpha(1)

		while t > 0 do
			local dt = coroutine.yield()
			t = math.clamp(t - dt, 0, duration)
			icon:set_alpha(t/duration)
		end

		icon:set_alpha(0)
	end

	HUDList.PagerItem = HUDList.PagerItem or class(HUDList.LeftListItem)
	function HUDList.PagerItem:init(parent, name, data)
		HUDList.PagerItem.super.init(self, parent, name, { align = "left", w = parent:panel():h(), h = parent:panel():h() })

		self._unit = data.unit
		self._start_t = data.start_t
		self._expire_t = data.expire_t
		self._remaining = data.expire_t - Application:time()
		self._duration = data.expire_t - data.start_t

		self._timer_text = self._panel:text({
			name = "time",
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h() * 0.6,
			color = Color.red,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.6,
		})

		self._distance_text = self._panel:text({
			name = "distance",
			align = "center",
			vertical = "center",
			y = self._timer_text:bottom(),
			w = self._panel:w() * 0.65,
			h = self._panel:h() * 0.4,
			color = HUDListManager.ListOptions.list_color or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.35,
			text = "DIST"
		})

		self._direction_icon = self._panel:bitmap({
			name = "direction",
			texture = "guis/textures/hud_icons",
			texture_rect = { 434, 46, 30, 19 },
			align = "center",
			vertical = "center",
			valign = "scale",
			halign = "scale",
			w = self._panel:h() * 0.3,
			h = self._panel:h() * 0.2,
			rotation = 270,
		})
		self._direction_icon:set_center(self._panel:w() * 0.8, self._panel:h() * 0.75)

		local key = tostring(self._unit:key())
		table.insert(self._listener_clbks, {
			name = string.format("HUDList_pager_listener_%s", key),
			source = "pager",
			event = { "set_answered" },
			clbk = callback(self, self, "_set_answered"),
			keys = { key },
			data_only = true
		})
	end

	function HUDList.PagerItem:rescale(new_scale)
		local enabled, size_mult = HUDList.PagerItem.super.rescale(self, new_scale)

		if enabled then
			self._timer_text:sei_size(self._panel:w(), self._panel:h() * 0.6)

			self._distance_text:sei_size(self._panel:w() * 0.65, self._panel:h() * 0.4)
			self._distance_text:set_y(self._timer_text:bottom())

			self._direction_icon:set_size(self._panel:h() * 0.3, self._panel:h() * 0.2)
			self._direction_icon:set_center(self._panel:w() * 0.8, self._panel:h() * 0.75)
		end

		return enabled, size_mult
	end

	function HUDList.PagerItem:set_color(color)
		HUDList.PagerItem.super.set_color(self, color)
		self._distance_text:set_color(color)
		self._direction_icon:set_color(color)
	end

	function HUDList.PagerItem:priority()
		return self._remaining and Utl.round(self._remaining, 1) + (self._answered and 0.5 or 0)
	end

	function HUDList.PagerItem:_set_answered()
		if not self._answered then
			self._answered = true
			self._timer_text:set_color(Color(1, 0.1, 0.9, 0.1))
			self._progress_bar:set_color(Color(1, 0.1, 0.9, 0.1))
		end
	end

	function HUDList.PagerItem:update(t, dt)
		HUDList.PagerItem.super.update(self, t, dt)
		
		if not self._answered then
			self._remaining = math.max(self._remaining - dt, 0)
			self._timer_text:set_text(format_time_string(self._remaining))
			self._timer_text:set_color(get_color_from_table(self._remaining, self._duration))
			self._progress_bar:set_ratio(self._remaining / self._duration)
		end

		local distance, rotation = get_distance_to_player(self._unit)
		self._distance_text:set_text(distance)
		self._direction_icon:set_rotation(270 - rotation)
	end

	HUDList.ECMItem = HUDList.ECMItem or class(HUDList.LeftListItem)
	function HUDList.ECMItem:init(parent, name, data)
		HUDList.ECMItem.super.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })

		self.STANDARD_COLOR = HUDListManager.ListOptions.list_color or Color(1, 1, 1, 1)
		self.DISABLED_COLOR = Color(1, 1, 0, 0)
		self.FLASH_SPEED = 2

		self._unit = data.unit
		self._max_duration = tweak_data.upgrades.ecm_jammer_base_battery_life
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
		}

		self._text = self._panel:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h() * 0.7,
			color = HUDListManager.ListOptions.list_color or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.6,
			layer = 10,
		})

		self._upgrade_lvl3 = self._panel:bitmap({
			name = "upgrade_level_3",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 3 * 64, 4 * 64, 64, 64 },
			blend_mode = "normal",
			w = self._panel:w() * 0.4,
			h = self._panel:w() * 0.4,
			layer = 11,
			color = Color(1, 0.2, 0),
			visible = false,
		})
		self._upgrade_lvl3:set_bottom(self._panel:h() - 2)

		self._level = self._panel:text({
			name = "text",
			align = "center",
			vertical = "bottom",
			text = "",
			w = self._panel:w(),
			h = self._panel:h(),
			color = HUDListManager.ListOptions.list_color or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.4,
			layer = 10,
		})

		self:_set_owner(data)
		self:_set_jammer_battery(data)
		self:_set_upgrade_level(data)
		self:_set_battery_low(data)

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_ecm_jammer_listener_%s", key)
		local events = {
			set_owner = callback(self, self, "_set_owner"),
			set_upgrade_level = callback(self, self, "_set_upgrade_level"),
			set_jammer_battery = callback(self, self, "_set_jammer_battery"),
			set_battery_low = callback(self, self, "_set_battery_low"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "ecm", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.ECMItem:rescale(new_scale)
		local enabled, size_mult = HUDList.ECMItem.super.rescale(self, new_scale)

		if enabled then
			self._text:set_size(self._panel:w(), self._panel:h() * 0.7)
			self._text:set_font_size(self._panel:h() * 0.6)
			self._upgrade_lvl3:set_size(self._panel:w() * 0.4, self._panel:w() * 0.4)
			self._upgrade_lvl3:set_bottom(self._panel:h() - 2)
			self._level:set_size(self._panel:w() * (self._blocks_pager and 0.6 or 1), self._panel:h())
			self._level:set_font_size(self._panel:h() * 0.4)
			self._level:set_x(self._blocks_pager and (self._upgrade_lvl3:w() - 2) or 0)
		end

		return enabled, size_mult
	end

	function HUDList.ECMItem:set_color(color)
		HUDList.ECMItem.super.set_color(self, color)
		if not self._owner then
			self._text:set_color(color)
			self.STANDARD_COLOR = color
			self._flash_color_table[2].color = color
		end
		self._level:set_color(color)
	end

	function HUDList.ECMItem:priority()
		return self._remaining and Utl.round(self._remaining, 1)
	end

	function HUDList.ECMItem:_animate_battery_low(text, progress_bar)
		local t = Application:time()
		while self._animating_low_battery do
			t = t + coroutine.yield()
			local new_color = get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			text:set_color(new_color)
			if progress_bar then
				progress_bar:set_color(new_color)
			end
		end
		text:set_color(self.STANDARD_COLOR or Color.white)
		if progress_bar then
			progress_bar:set_color(HUDListManager.ListOptions.list_color or Color.white)
		end
	end

	function HUDList.ECMItem:_set_owner(data)
		if data.owner then
			self._owner = data.owner
			local color = self._owner > 0 and tweak_data.chat_colors[self._owner]:with_alpha(1) or Color.white
			self._text:set_color(color)
			self.STANDARD_COLOR = color
			self._flash_color_table[2].color = color
		end
	end

	function HUDList.ECMItem:_set_upgrade_level(data)
		if data.upgrade_level then
			self._max_duration = tweak_data.upgrades.ecm_jammer_base_battery_life * ECMJammerBase.battery_life_multiplier[data.upgrade_level]

			self._blocks_pager = data.upgrade_level == 3
			self._upgrade_lvl3:set_visible(self._blocks_pager)

			self._level:set_text(string.format("Lv. %i", data.upgrade_level))
			self._level:set_x(self._blocks_pager and (self._upgrade_lvl3:w() - 2) or 0)
			self._level:set_w(self._panel:w() * (self._blocks_pager and 0.6 or 1))
		end
	end

	function HUDList.ECMItem:_set_jammer_battery(data)
		if data.jammer_battery then
			self._remaining = data.jammer_battery
			self._text:set_text(format_time_string(data.jammer_battery))
			self._progress_bar:set_ratio(data.jammer_battery / self._max_duration)
		end
	end

	function HUDList.ECMItem:_set_battery_low(data)
		if data.battery_low and not self._animating_low_battery then
			self._animating_low_battery = true
			self._text:animate(callback(self, self, "_animate_battery_low"), self._progress_bar)
		elseif not data.battery_low then
			self._animating_low_battery = nil
		end
	end

	HUDList.ECMRetriggerItem = HUDList.ECMRetriggerItem or class(HUDList.LeftListItem)
	function HUDList.ECMRetriggerItem:init(parent, name, data)
		HUDList.ECMRetriggerItem.super.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })

		self.STANDARD_COLOR = HUDListManager.ListOptions.list_color or Color.white
		self._unit = data.unit
		self._max_duration = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
		self._flash_color_table = {
			{ ratio = 0.00, color = self.STANDARD_COLOR },
			{ ratio = 0.75, color = self.STANDARD_COLOR },
			{ ratio = 1.00, color = Color('00FF00') }
		}

		self._text = self._panel:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h(),
			color = self.STANDARD_COLOR,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.6,
		})

		self:_set_retrigger_delay(data)

		local key = tostring(data.unit:key())
		table.insert(self._listener_clbks, {
			name = string.format("HUDList_ecm_retrigger_listener_%s", key),
			source = "ecm",
			event = { "set_retrigger_delay" },
			clbk = callback(self, self, "_set_retrigger_delay"),
			keys = { key },
			data_only = true
		})
	end

	function HUDList.ECMRetriggerItem:rescale(new_scale)
		local enabled, size_mult = HUDList.ECMRetriggerItem.super.rescale(self, new_scale)

		if enabled then
			self._text:set_size(self._panel:w(), self._panel:h())
			self._text:set_font_size(self._panel:h() * 0.6)
		end

		return enabled, size_mult
	end

	function HUDList.ECMRetriggerItem:set_color(color)
		HUDList.ECMRetriggerItem.super.set_color(self, color)
		self._text:set_color(color)
		self.STANDARD_COLOR = color
		self._flash_color_table[1].color = color
		self._flash_color_table[2].color = color
	end

	function HUDList.ECMRetriggerItem:priority()
		return self._remaining and Utl.round(self._remaining + 100, 1)
	end

	function HUDList.ECMRetriggerItem:_set_retrigger_delay(data)
		if data.retrigger_delay then
			self._remaining = data.retrigger_delay
			self._text:set_text(format_time_string(data.retrigger_delay))
			self._progress_bar:set_ratio(data.retrigger_delay / self._max_duration)

			local new_color = get_color_from_table(self._max_duration - data.retrigger_delay, self._max_duration, self._flash_color_table, self.STANDARD_COLOR)
			self._text:set_color(new_color)
			--self._progress_bar:set_color(new_color)
		end
	end

	HUDList.ECMFeedbackItem = HUDList.ECMFeedbackItem or class(HUDList.LeftListItem)
	function HUDList.ECMFeedbackItem:init(parent, name, data)
		HUDList.ECMFeedbackItem.super.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h(), priority = 0 })

		self.STANDARD_COLOR = Color(1, 0.0, 0.8, 1.0)
		self.DISABLED_COLOR = Color(1, 1, 0, 0)
		self.FLASH_SPEED = 2

		self._unit = data.unit
		self._max_duration = 60
		self._expire_t = 0
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
		}

		self._text = self._panel:text({
			name = "text",
			text = "Active",
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h() * 0.7,
			color = self.STANDARD_COLOR,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.5,
		})

		self._distance_text = self._panel:text({
			name = "distance",
			align = "center",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:h(),
			color = HUDListManager.ListOptions.list_color or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.4
		})

		self:_set_feedback_duration(data)
		self:_set_feedback_low(data)

		local key = tostring(data.unit:key())
		table.insert(self._listener_clbks, {
			name = string.format("HUDList_ecm_feedback_listener_%s", key),
			source = "ecm",
			event = { "set_feedback_duration" },
			clbk = callback(self, self, "_set_feedback_duration"),
			keys = { key },
			data_only = true
		})
		table.insert(self._listener_clbks, {
			name = string.format("HUDList_ecm_feedback_listener_%s", key),
			source = "ecm",
			event = { "set_feedback_low" },
			clbk = callback(self, self, "_set_feedback_low"),
			keys = { key },
			data_only = true
		})
	end

	function HUDList.ECMFeedbackItem:rescale(new_scale)
		local enabled, size_mult = HUDList.ECMFeedbackItem.super.rescale(self, new_scale)

		if enabled then
			self._text:set_size(self._panel:w(), self._panel:h() * 0.7)
			self._text:set_font_size(self._panel:h() * 0.5)
			self._distance_text:set_size(self._panel:w(), self._panel:h())
			self._distance_text:set_font_size(self._panel:h() * 0.4)
		end

		return enabled, size_mult
	end

	function HUDList.ECMFeedbackItem:set_color(color)
		HUDList.ECMFeedbackItem.super.set_color(self, color)
		self._distance_text:set_color(color)
	end

	function HUDList.ECMFeedbackItem:priority()
		return self._remaining and Utl.round(self._remaining, 1) or self._priority
	end

	function HUDList.ECMFeedbackItem:_animate_battery_low(text, progress_bar)
		local t = Application:time()
		while self._animating_low_battery do
			t = t + coroutine.yield()
			local new_color = get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			text:set_color(new_color)
			if progress_bar then
				progress_bar:set_color(new_color)
			end
		end
		text:set_color(self.STANDARD_COLOR or Color.white)
		if progress_bar then
			progress_bar:set_color(HUDListManager.ListOptions.list_color or Color.white)
		end
	end

	function HUDList.ECMFeedbackItem:_set_feedback_duration(data)
		if data.feedback_active and (data.feedback_duration or data.feedback_expire_t) then
			local t = Application:time()
			self._max_duration = data.feedback_duration or (data.feedback_expire_t - t) or 15
			self._expire_t = data.feedback_expire_t or (t + data.feedback_duration) or 0
			self._text:set_font_size(self._panel:h() * 0.6)
		end
	end

	function HUDList.ECMFeedbackItem:_set_feedback_low(data)
		if data.feedback_low and not self._animating_low_battery then
			self._animating_low_battery = true
			self._text:animate(callback(self, self, "_animate_battery_low"), self._progress_bar)
		elseif not data.feedback_low then
			self._animating_low_battery = nil
		end
	end

	function HUDList.ECMFeedbackItem:update(t, dt)
		HUDList.ECMFeedbackItem.super.update(self, t, dt)
	
		if self._expire_t >= t then
			self._remaining = math.max(0, self._expire_t - t)
			self._text:set_text(format_time_string(self._remaining))
			self._progress_bar:set_ratio(self._remaining / self._max_duration)
		end

		self._distance_text:set_text(get_distance_to_player(self._unit))
	end

	HUDList.TapeLoopItem = HUDList.TapeLoopItem or class(HUDList.LeftListItem)
	function HUDList.TapeLoopItem:init(parent, name, data)
		HUDList.TapeLoopItem.super.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })

		self.STANDARD_COLOR = HUDListManager.ListOptions.list_color or Color(1, 1, 1, 1)
		self.DISABLED_COLOR = Color(1, 1, 0, 0)
		self.FLASH_SPEED = 0.8

		self._unit = data.unit
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
		}

		self._text = self._panel:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h(),
			color = self.STANDARD_COLOR or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.6,
		})

		self:_set_expire_t(data)

		local key = tostring(self._unit:key())
		local id = string.format("HUDList_tape_loop_listener_%s", key)
		local events = {
			set_tape_loop_expire_t = callback(self, self, "_set_expire_t"),
			set_tape_loop_restart_active = callback(self, self, "_set_restart_active"),
		}

		for event, clbk in pairs(events) do
			table.insert(self._listener_clbks, { name = id, source = "camera", event = { event }, clbk = clbk, keys = { key }, data_only = true })
		end
	end

	function HUDList.TapeLoopItem:rescale(new_scale)
		local enabled, size_mult = HUDList.TapeLoopItem.super.rescale(self, new_scale)

		if enabled then
			self._text:set_size(self._panel:w(), self._panel:h())
		end

		return enabled, size_mult
	end

	function HUDList.TapeLoopItem:set_color(color)
		HUDList.TapeLoopItem.super.set_color(self, color)
		self._text:set_color(color)
		self.STANDARD_COLOR = color
		self._flash_color_table[2].color = color
	end

	function HUDList.TapeLoopItem:priority()
		return self._remaining and Utl.round(self._remaining, 1)
	end

	function HUDList.TapeLoopItem:_animate_restart_active(text, progress_bar)
		local t = Application:time()
		while self._animating_restart do
			t = t + coroutine.yield()
			local new_color = get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			text:set_color(new_color)
			if progress_bar then
				progress_bar:set_color(new_color)
			end
		end
		text:set_color(self.STANDARD_COLOR or Color.white)
		if progress_bar then
			progress_bar:set_color(self.STANDARD_COLOR or Color.white)
		end
	end

	function HUDList.TapeLoopItem:update(t, dt)
		HUDList.TapeLoopItem.super.update(self, t, dt)
		
		self._remaining = math.max(0, (self._expire_t or t) - t)
		self._text:set_text(format_time_string(self._remaining))
		self._progress_bar:set_ratio(self._remaining / self._max_duration)
	end

	function HUDList.TapeLoopItem:_set_expire_t(data)
		if data.tape_loop_active and data.tape_loop_expire_t then
			self._max_duration = data.tape_loop_expire_t - Application:time()
			self._expire_t = data.tape_loop_expire_t
		end
	end

	function HUDList.TapeLoopItem:_set_restart_active(data)
		if data.tape_loop_restart_active and not self._animating_restart then
			self._animating_restart = true
			self._text:animate(callback(self, self, "_animate_restart_active"), self._progress_bar)
		elseif not data.tape_loop_restart_active then
			self._animating_restart = nil
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Buff list

	HUDList.BuffItemBase = HUDList.BuffItemBase or class(HUDList.ItemBase)

	HUDList.BuffItemBase.ICON_COLOR = {
		STANDARD 	= Color('FFFFFF'),
		DEBUFF 		= Color('FF7575'),
		TEAM 		= Color('75FF75'),
	}

	HUDList.BuffItemBase.VALUE_FUNC = {
		IN_PERCENT = function(value)
			return string.format("%.0f%%", value * 100)
		end,
		IN_PERCENT_INVERTED = function(value)
			return string.format("%.0f%%", (1 - value) * 100)
		end,
		MULT_IN_PERCENT = function(value)
			return string.format("%.0f%%", (value - 1) * 100)
		end,
	}

	HUDList.BuffItemBase.MAP = {
		--Buffs
		aggressive_reload_aced = {
			skills_new = tweak_data.skilltree.skills.speedy_reload.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "aggressive_reload_aced"}, true),
		},
		ammo_efficiency = {
			skills_new = tweak_data.skilltree.skills.single_shot_ammo_return.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "ammo_efficiency"}, true)
		},
		armor_break_invulnerable = {
			perks = {6, 1},
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "armor_break_invulnerable"}, true),
		},
		berserker = {
			skills_new = tweak_data.skilltree.skills.wolverine.icon_xy,
			class = "BuffItemBase",
			priority = 3,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = HUDList.BuffItemBase.VALUE_FUNC.IN_PERCENT,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "berserker"}, true),
		},
		biker = {
			perks = {0, 0},
			texture_bundle_folder = "wild",
			class = "BikerBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "biker"}, true),
		},
		bloodthirst_aced = {
			skills_new = tweak_data.skilltree.skills.bloodthirst.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ace_icon = true,
			title = "wolfhud_hudlist_buff_aced",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "bloodthirst_aced"}, true),
		},
		bloodthirst_basic = {
			skills_new = tweak_data.skilltree.skills.bloodthirst.icon_xy,
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			title = "wolfhud_hudlist_buff_basic",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "bloodthirst_basic"}, false),
		},
		bullet_storm = {
			skills_new = tweak_data.skilltree.skills.ammo_reservoir.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bullet_storm"}, true),
		},
		chico_injector = {
			perks = {0, 0},
			texture_bundle_folder = "chico",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "chico_injector"}, false) and (WolfHUD:getSetting({"CustomHUD", "PLAYER", "STATUS"}, true) or WolfHUD:getSetting({"CustomHUD", "ENABLED"}, false)),
		},
		close_contact = {
			perks = {5, 4},
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "close_contact"}, true),
		},
		combat_medic = {
			skills_new = tweak_data.skilltree.skills.combat_medic.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "combat_medic"}, true),
		},
		combat_medic_passive = {
			skills_new = tweak_data.skilltree.skills.combat_medic.icon_xy,
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "combat_medic_passive"}, false),
		},
		delayed_damage = {
			perks = {3, 0},
			texture_bundle_folder = "myh",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = "-%.0f",
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "delayed_damage"}, true),
		},
		desperado = {
			skills_new = tweak_data.skilltree.skills.expert_handling.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "desperado"}, true),
		},
		die_hard = {
			skills_new = tweak_data.skilltree.skills.show_of_force.icon_xy,
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "die_hard"}, false),
		},
		dire_need = {
			skills_new = tweak_data.skilltree.skills.dire_need.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GHOST_BUFFS", "dire_need"}, true),
		},
		frenzy = {
			skills_new = tweak_data.skilltree.skills.frenzy.icon_xy,
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = HUDList.BuffItemBase.VALUE_FUNC.IN_PERCENT,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "frenzy"}, false),
		},
		grinder = {
			perks = {4, 6},
			class = "TimedStacksBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "grinder"}, true),
		},
		hostage_situation = {
			perks = {0, 1},
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "hostage_situation"}, false),
		},
		hostage_taker = {
			skills_new = tweak_data.skilltree.skills.black_marketeer.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			invert_timers = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "hostage_taker"}, false),
		},
		inspire = {
			skills_new = tweak_data.skilltree.skills.inspire.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire"}, true),
		},
		lock_n_load = {
			skills_new = tweak_data.skilltree.skills.shock_and_awe.icon_xy,
			class = "BuffItemBase",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = HUDList.BuffItemBase.MULT_IN_PERCENT,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "TECHNICIAN_BUFFS", "lock_n_load"}, true),
		},
		maniac = {
			perks = {0, 0},
			texture_bundle_folder = "coco",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = "-%.1f",
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "maniac"}, false) and (WolfHUD:getSetting({"CustomHUD", "PLAYER", "STATUS"}, true) or WolfHUD:getSetting({"CustomHUD", "ENABLED"}, false)),
		},
		messiah = {
			skills_new = tweak_data.skilltree.skills.messiah.icon_xy,
			class = "BuffItemBase",
			priority = 3,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "messiah"}, true)
		},
		melee_stack_damage = {
			perks = {5, 4},
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "melee_stack_damage"}, false),
		},
		muscle_regen = {
			perks = { 4, 1 },
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			invert_timers = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "muscle_regen"}, false),
		},
		overdog = {
			perks = {6, 4},
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "overdog"}, false)
		},
		overkill = {
			skills_new = tweak_data.skilltree.skills.overkill.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "overkill"}, false),
		},
		painkiller = {
			skills_new = tweak_data.skilltree.skills.fast_learner.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "painkiller"}, false),
		},
		partner_in_crime = {
			skills_new = tweak_data.skilltree.skills.control_freak.icon_xy,
			class = "BuffItemBase",
			priority = 3,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "partner_in_crime"}, false),
		},
		pocket_ecm_jammer = {
			perks = {0, 0},
			texture_bundle_folder = "joy",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "pocket_ecm_jammer"}, true),
		},
		pocket_ecm_kill_dodge = {
			perks = {3, 0},
			texture_bundle_folder = "joy",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "pocket_ecm_kill_dodge"}, false),
		},
		running_from_death = {
			skills_new = tweak_data.skilltree.skills.running_from_death.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "running_from_death"}, true),
		},
		quick_fix = {
			skills_new = tweak_data.skilltree.skills.tea_time.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "quick_fix"}, false),
		},
		second_wind = {
			skills_new = tweak_data.skilltree.skills.scavenger.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GHOST_BUFFS", "second_wind"}, true),
		},
		sicario_dodge = {
			perks = {1, 0},
			texture_bundle_folder = "max",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = HUDList.BuffItemBase.VALUE_FUNC.IN_PERCENT,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "sicario_dodge"}, true),
		},
		sixth_sense = {
			skills_new = tweak_data.skilltree.skills.chameleon.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GHOST_BUFFS", "sixth_sense"}, true),
		},
		smoke_screen_grenade = {
			perks = {0, 0},
			texture_bundle_folder = "max",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "smoke_screen_grenade"}, true),
		},
		swan_song = {
			skills_new = tweak_data.skilltree.skills.perseverance.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "swan_song"}, false) and (WolfHUD:getSetting({"CustomHUD", "PLAYER", "STATUS"}, true) or WolfHUD:getSetting({"CustomHUD", "ENABLED"}, false)),
		},
		tag_team = {
			perks = {0, 0},
			texture_bundle_folder = "ecp",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "tag_team"}, true) and (WolfHUD:getSetting({"CustomHUD", "PLAYER", "STATUS"}, true) or WolfHUD:getSetting({"CustomHUD", "ENABLED"}, false)),
		},
		tooth_and_claw = {
			perks = {0, 3},
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "tooth_and_claw"}, true),
		},
		trigger_happy = {
			skills_new = tweak_data.skilltree.skills.trigger_happy.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "trigger_happy"}, false),
		},
		underdog = {
			skills_new = tweak_data.skilltree.skills.underdog.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "underdog"}, false),
		},
		unseen_strike = {
			skills_new = tweak_data.skilltree.skills.unseen_strike.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GHOST_BUFFS", "unseen_strike"}, true),
		},
		up_you_go = {
			skills_new = tweak_data.skilltree.skills.up_you_go.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "FUGITIVE_BUFFS", "up_you_go"}, false),
		},
		uppers = {
			skills_new = tweak_data.skilltree.skills.tea_cookies.icon_xy,
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "uppers"}, true),
		},
		yakuza = {
			perks = {2, 7},
			class = "BuffItemBase",
			priority = 3,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			show_value = HUDList.BuffItemBase.VALUE_FUNC.IN_PERCENT,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "yakuza"}, false),
		},

		--Debuffs
		anarchist_armor_recovery_debuff = {
			perks = {0, 1},
			texture_bundle_folder = "opera",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "anarchist_armor_recovery_debuff"}, true),
		},
		ammo_give_out_debuff = {
			perks = {5, 5},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "ammo_give_out_debuff"}, true),
		},
		armor_break_invulnerable_debuff = {
			perks = {6, 1},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		bullseye_debuff = {
			skills_new = tweak_data.skilltree.skills.prison_wife.icon_xy,
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bullseye_debuff"}, true),
		},
		grinder_debuff = {
			perks = {4, 6},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		chico_injector_debuff = {
			perks = {0, 0},
			texture_bundle_folder = "chico",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		delayed_damage_debuff = {
			perks = {3, 0},
			texture_bundle_folder = "myh",
			class = "TimedBuffItem",
			priority = 8,
			show_value = "-%.1f",
			ignore = true, 	--Coposite debuff
		},
		inspire_debuff = {
			skills_new = tweak_data.skilltree.skills.inspire.icon_xy,
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			title = "wolfhud_hudlist_buff_boost",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire_debuff"}, true),
		},
		inspire_revive_debuff = {
			skills_new = tweak_data.skilltree.skills.inspire.icon_xy,
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ace_icon = true,
			title = "wolfhud_hudlist_buff_revive",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "inspire_revive_debuff"}, true),
		},
		life_drain_debuff = {
			perks = {7, 4},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "life_drain_debuff"}, true),
		},
		maniac_debuff = {
			perks = {0, 0},
			texture_bundle_folder = "coco",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		medical_supplies_debuff = {
			perks = {4, 5},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "medical_supplies_debuff"}, true),
		},
		pocket_ecm_jammer_debuff = {
			perks = {0, 0},
			texture_bundle_folder = "joy",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		sicario_dodge_debuff = {
			perks = {1, 0},
			texture_bundle_folder = "max",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		smoke_screen_grenade_debuff = {
			perks = {0, 0},
			texture_bundle_folder = "max",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		sociopath_debuff = {
			perks = {3, 5},
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "sociopath_debuff"}, true),
		},
		tag_team_debuff = {
			perks = {0, 0},
			texture_bundle_folder = "ecp",
			class = "TimedBuffItem",
			priority = 4,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = true,	--Composite debuff
		},
		damage_control_debuff = {
			perks = {2, 0},
			texture_bundle_folder = "myh",
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "damage_control_debuff"}, false),
		},
		unseen_strike_debuff = {
			skills_new = tweak_data.skilltree.skills.unseen_strike.icon_xy,
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},
		uppers_debuff = {
			skills_new = tweak_data.skilltree.skills.tea_cookies.icon_xy,
			class = "TimedBuffItem",
			priority = 8,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true,	--Composite debuff
		},

		--Team buffs
		armorer = {
			perks = {6, 0},
			class = "TeamBuffItem",
			priority = 1,
			color = HUDList.BuffItemBase.ICON_COLOR.TEAM,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "armorer"}, true),
		},
		bulletproof = {						--TODO: Needs new icon (Faster Team armor recovery)
			--skills_new = tweak_data.skilltree.skills.iron_man.icon_xy,
			perks = {6, 2},
			class = "TeamBuffItem",
			priority = 1,
			color = HUDList.BuffItemBase.ICON_COLOR.TEAM,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "ENFORCER_BUFFS", "bulletproof"}, true),
		},
		crew_chief = {
			perks = {2, 0},
			class = "TeamBuffItem",
			priority = 1,
			color = HUDList.BuffItemBase.ICON_COLOR.TEAM,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "PERK_BUFFS", "crew_chief"}, true),
		},
		endurance = {
			skills_new = tweak_data.skilltree.skills.triathlete.icon_xy,
			class = "TeamBuffItem",
			priority = 1,
			color = HUDList.BuffItemBase.ICON_COLOR.TEAM,
			ignore = true,
		},
		forced_friendship = {
			skills = tweak_data.skilltree.skills.triathlete.icon_xy,
			class = "TeamBuffItem",
			priority = 1,
			color = HUDList.BuffItemBase.ICON_COLOR.TEAM,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "MASTERMIND_BUFFS", "forced_friendship"}, true),
		},

		--Gage Boosts
		invulnerable_buff = {
			hud_tweak = "csb_melee",
			class = "TimedBuffItem",
			priority = 10,
			color = HUDList.BuffItemBase.ICON_COLOR.BUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GAGE_BOOSTS", "invulnerable_buff"}, true),
		},
		life_steal_debuff = {
			hud_tweak = "csb_lifesteal",
			class = "TimedBuffItem",
			priority = 10,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "GAGE_BOOSTS", "life_steal_debuff"}, true),
		},

		--Henchman boosts
		crew_inspire_debuff = {
			hud_tweak = "ability_1",
			class = "TimedBuffItem",
			priority = 10,
			title = "wolfhud_hudlist_buff_crew_inspire_debuff",
			localized = true,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "AI_SKILLS", "crew_inspire_debuff"}, true),
		},
		crew_throwable_regen = {
			hud_tweak = "skill_7",
			class = "BuffItemBase",
			priority = 10,
			color = HUDList.BuffItemBase.ICON_COLOR.BUFF,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "AI_SKILLS", "crew_throwable_regen"}, true),
		},
		crew_health_regen = {
			hud_tweak = "skill_5",
			class = "TimedBuffItem",
			priority = 10,
			color = HUDList.BuffItemBase.ICON_COLOR.BUFF,
			invert_timers = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "AI_SKILLS", "crew_health_regen"}, true),
		},

		--Composite buffs
		damage_increase = {
			skills_new = tweak_data.skilltree.skills.prison_wife.icon_xy,
			class = "DamageIncreaseBuff",
			priority = 2,
			color = Color(1, 1, 0),
			title = "wolfhud_hudlist_buff_dmg_inc",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "damage_increase"}, true),
		},
		damage_reduction = {
			skills_new = tweak_data.skilltree.skills.disguise.icon_xy,
			class = "DamageReductionBuff",
			priority = 2,
			color = Color(0, 1, 1),
			title = "wolfhud_hudlist_buff_dmg_dec",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "damage_reduction"}, true),
		},
		melee_damage_increase = {
			skills_new = tweak_data.skilltree.skills.hidden_blade.icon_xy,
			class = "MeleeDamageIncreaseBuff",
			priority = 2,
			color = Color(1, 0, 1),
			title = "wolfhud_hudlist_buff_mdmg_inc",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "melee_damage_increase"}, true),
		},
		passive_health_regen = {
			--perks = {4, 1},
			skills_new = {1, 11},
			class = "PassiveHealthRegenBuff",
			priority = 2,
			color = Color(0.1, 1, 0.1),
			title = "wolfhud_hudlist_buff_phealth_reg",
			localized = true,
			invert_timers = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "passive_health_regen"}, true),
		},
		total_dodge_chance = {	--missing some skills:
			--perks = {1, 0},
			skills_new = {1, 12},
			texture_bundle_folder = "max",
			class = "TotalDodgeChanceBuff",
			priority = 2,
			color = Color(1, 0.5, 0),
			title = "wolfhud_hudlist_buff_tot_dodge",
			localized = true,
			ignore = not WolfHUD:getSetting({"HUDList", "BUFF_LIST", "total_dodge_chance"}, true),
		},

		--Player actions
		anarchist_armor_regeneration = {
			perks = {0, 0},
			texture_bundle_folder = "opera",
			class = "TimedBuffItem",
			priority = 12,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			invert_timers = true,
			ignore = false,
		},
		standard_armor_regeneration = {
			perks = {6, 0},
			class = "TimedBuffItem",
			priority = 12,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			invert_timers = true,
			ignore = false,
		},
		weapon_charge = {
			texture = "guis/textures/wolfhud/hudlist/weapon_charge",
			class = "TimedBuffItem",
			priority = 15,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = false,
		},
		melee_charge = {
			--skills_new = tweak_data.skilltree.skills.hidden_blade.icon_xy,
			skills = tweak_data.skilltree.skills.hidden_blade.icon_xy,
			class = "TimedBuffItem",
			priority = 15,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = WolfHUD:getSetting({"INTERACTION", "SHOW_MELEE"}, true)
		},
		reload = {
			--skills_new = tweak_data.skilltree.skills.speedy_reload.icon_xy,
			skills = {0, 9},
			class = "TimedBuffItem",
			priority = 15,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = WolfHUD:getSetting({"INTERACTION", "SHOW_RELOAD"}, true)
		},
		interact = {
			--skills_new = tweak_data.skilltree.skills.second_chances.icon_xy,
			texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
			class = "TimedInteractionItem",
			priority = 15,
			color = HUDList.BuffItemBase.ICON_COLOR.STANDARD,
			ignore = (WolfHUD:getSetting({"INTERACTION", "SHOW_CIRCLE"}, true) or WolfHUD:getSetting({"INTERACTION", "SHOW_TIME_REMAINING"}, true))
		},
		interact_debuff = {
			--skills_new = tweak_data.skilltree.skills.second_chances.icon_xy,
			texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
			class = "TimedInteractionItem",
			priority = 15,
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			ignore = true	--Composite debuff
		}
	}

	function HUDList.BuffItemBase:init(parent, name, icon, w, h)
		HUDList.BuffItemBase.super.init(self, parent, name, { priority = icon.priority, align = "bottom", w = w or parent:panel():h() * 0.6, h = h or parent:panel():h() })

		local texture, texture_rect = get_icon_data(icon)

		self._default_icon_color = icon.color or HUDList.BuffItemBase.ICON_COLOR.STANDARD or Color.white
		self._show_value = icon.show_value
		local progress_bar_width = self._panel:w() * 0.05
		local icon_size = self._panel:w() - progress_bar_width * 4

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			valign = "center",
			align = "center",
			h = icon_size,
			w = icon_size,
			blend_mode = icon.blend_mode or "normal",
			color = self._default_icon_color,
			rotation = icon.icon_rotation or 0,
		})
		self._icon:set_center(self:panel():center())

		self._ace_icon = self._panel:bitmap({
			name = "ace_icon",
			texture = "guis/textures/pd2/skilltree_2/ace_symbol",
			valign = "center",
			align = "center",
			h = icon_size * 1.5,
			w = icon_size * 1.5,
			blend_mode = "normal",
			color = self._default_icon_color,
			layer = self._icon:layer() - 1,
			visible = icon.ace_icon and true or false,
		})
		self._ace_icon:set_center(self._icon:center())

		self._bg = self._panel:rect({
			name = "bg",
			h = self._icon:h(),
			w = self._icon:w(),
			blend_mode = "normal",
			layer = self._ace_icon:layer() - 1,
			color = Color.black,
			alpha = 0.2,
		})
		self._bg:set_center(self._icon:center())

		self._title = self._panel:text({
			name = "title",
			text = icon.localized and managers.localization:text(icon.title) or icon.title or "",
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = (self._panel:h() - icon_size) / 2,
			layer = 10,
			color = self._default_icon_color,
			font = tweak_data.hud_corner.assault_font,
			font_size = 0.7 * (self._panel:h() - icon_size) / 2,
			blend_mode = "normal",
		})

		self._value = self._panel:text({
			name = "value",
			align = "center",
			vertical = "bottom",
			w = self._panel:w(),
			h = (self._panel:h() - icon_size) / 2,
			layer = 10,
			color = self._default_icon_color,
			font = tweak_data.hud_corner.assault_font,
			font_size = 0.7 * (self._panel:h() - icon_size) / 2,
			blend_mode = "normal",
		})
		self._value:set_bottom(self._panel:h() + progress_bar_width)

		self._progress_bar_debuff = PanelFrame:new(self._panel, {
			invert_progress = icon.invert_debuff,
			bar_w = progress_bar_width,
			w = self._panel:w(),
			h = self._panel:w(),
			color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF,
			alpha = HUDListManager.ListOptions.buff_list_progress_alpha or 1,
		})
		self._progress_bar_debuff:set_center(self._icon:center())
		self._progress_bar_debuff:set_visible(false)
		self._progress_bar_debuff:set_ratio(1)

		self._progress_bar = PanelFrame:new(self._panel, {
			invert_progress = icon.invert_timers,
			bar_w = progress_bar_width,
			w = self._panel:w() - (progress_bar_width+1),
			h = self._panel:w() - (progress_bar_width+1),
			color = icon.progress_color or self._default_icon_color,
			alpha = HUDListManager.ListOptions.buff_list_progress_alpha or 1,
		})
		self._progress_bar:set_center(self._icon:center())
		self._progress_bar:set_visible(false)
		self._progress_bar:set_ratio(1)

		self._progress_bar_inner = PanelFrame:new(self._panel, {
			invert_progress = icon.invert_timers,
			bar_w = progress_bar_width,
			w = self._panel:w() - (progress_bar_width+1) * 2,
			h = self._panel:w() - (progress_bar_width+1) * 2,
			color = icon.progress_color or self._default_icon_color,
			alpha = HUDListManager.ListOptions.buff_list_progress_alpha or 1,
		})
		self._progress_bar_inner:set_center(self._icon:center())
		self._progress_bar_inner:set_visible(false)
		self._progress_bar_inner:set_ratio(1)

		self._stack_bg = self._panel:bitmap({
			w = self._icon:w() * 0.4,
			h = self._icon:h() * 0.4,
			blend_mode = "normal",
			texture = "guis/textures/pd2/equip_count",
			texture_rect = { 5, 5, 22, 22 },
			layer = 2,
			alpha = 0.8,
			visible = false
		})
		self._stack_bg:set_right(self._icon:right())
		self._stack_bg:set_bottom(self._icon:bottom())

		self._stack_text = self._panel:text({
			name = "stack_text",
			text = "",
			valign = "center",
			align = "center",
			vertical = "center",
			w = self._stack_bg:w(),
			h = self._stack_bg:h(),
			layer = 3,
			color = Color.black,
			blend_mode = "normal",
			font = tweak_data.hud.small_font,
			font_size = self._stack_bg:h() * 0.85,
			visible = false,
		})
		self._stack_text:set_center(self._stack_bg:center())
	end

	function HUDList.BuffItemBase:post_init()
		self:set_fade_time(0)
		self:set_move_speed(0)
	end

	function HUDList.BuffItemBase:rescale(new_scale)
		local enabled, size_mult = HUDList.BuffItemBase.super.rescale(self, new_scale)

		if enabled then
			local progress_bar_width = self._panel:w() * 0.05
			local icon_size = self._panel:w() - progress_bar_width * 4
			self._icon:set_size(icon_size, icon_size)
			self._icon:set_center(self:w() * 0.5, self:h() * 0.5)
			self._ace_icon:set_size(icon_size * 1.5, icon_size * 1.5)
			self._ace_icon:set_center(self:w() * 0.5, self:h() * 0.5)
			self._bg:set_size(self._icon:w(), self._icon:h())
			self._bg:set_center(self._icon:center())
			self._title:set_size(self._panel:w(), (self._panel:h() - icon_size) / 2)
			self._title:set_font_size(0.7 * (self._panel:h() - icon_size) / 2)
			self._value:set_size(self._panel:w(), (self._panel:h() - icon_size) / 2)
			self._value:set_font_size(0.7 * (self._panel:h() - icon_size) / 2)
			self._value:set_bottom(self._panel:h() + progress_bar_width)
			self._progress_bar_debuff:set_size(self._panel:w(), self._panel:w())
			self._progress_bar_debuff:set_center(self._icon:center())
			self._progress_bar_debuff:set_width(progress_bar_width)
			self._progress_bar:set_size(self._panel:w() - (progress_bar_width+1), self._panel:w() - (progress_bar_width+1))
			self._progress_bar:set_center(self._icon:center())
			self._progress_bar:set_width(progress_bar_width)
			self._progress_bar_inner:set_size(self._panel:w() - (progress_bar_width+1) * 2, self._panel:w() - (progress_bar_width+1) * 2)
			self._progress_bar_inner:set_center(self._icon:center())
			self._progress_bar_inner:set_width(progress_bar_width)
			self._stack_bg:set_size(self._icon:w() * 0.4, self._icon:h() * 0.4)
			self._stack_bg:set_right(self._icon:right())
			self._stack_bg:set_bottom(self._icon:bottom())
			self._stack_text:set_size(self._stack_bg:w(), self._stack_bg:h())
			self._stack_text:set_font_size(self._stack_bg:h() * 0.85)
			self._stack_text:set_center(self._stack_bg:center())
		end

		return enabled, size_mult
	end

	function HUDList.BuffItemBase:set_bg_color(color)
		HUDList.BuffItemBase.super.set_bg_color(self, color)
		self._bg:set_color(color)
	end

	function HUDList.BuffItemBase:set_progress_alpha(alpha)
		self._progress_bar_debuff:set_alpha(alpha)
		self._progress_bar:set_alpha(alpha)
		self._progress_bar_inner:set_alpha(alpha)
	end

	function HUDList.BuffItemBase:activate(id)
		self._buff_active = true
		self:_set_progress(0)
		self:_set_progress_inner(0)
		HUDList.BuffItemBase.super.activate(self)
	end

	function HUDList.BuffItemBase:deactivate(id)
		self._buff_active = false
		self._expire_t = nil
		self._start_t = nil
		self:_set_progress(0)
		self:_set_progress_inner(0)
		if not self._debuff_active then
			HUDList.BuffItemBase.super.deactivate(self)
		else
			self._icon:set_color(HUDList.BuffItemBase.ICON_COLOR.DEBUFF)
			self._ace_icon:set_color(HUDList.BuffItemBase.ICON_COLOR.DEBUFF)
			self._value:set_text("")
		end
	end

	function HUDList.BuffItemBase:activate_debuff(id)
		if not self._debuff_active then
			self._debuff_active = true
			self._icon:set_color(HUDList.BuffItemBase.ICON_COLOR.DEBUFF)
			self._ace_icon:set_color(HUDList.BuffItemBase.ICON_COLOR.DEBUFF)
			HUDList.BuffItemBase.super.activate(self)
		end
	end

	function HUDList.BuffItemBase:deactivate_debuff(id)
		if self._debuff_active then
			self._debuff_active = false

			if self._debuff_expire_t and not self._has_text then
				self._value:set_text("")
			end

			self._debuff_expire_t = nil
			self._debuff_start_t = nil
			self._progress_bar_debuff:set_visible(false)
			self._icon:set_color(self._default_icon_color)
			self._ace_icon:set_color(self._default_icon_color)
			if not self._buff_active then
				HUDList.BuffItemBase.super.deactivate(self)
			end
		end
	end

	function HUDList.BuffItemBase:set_duration(id, data)
		self._start_t = data.t
		self._expire_t = data.expire_t
		self._progress_bar:set_visible(true)

		if self._debuff_active and self._debuff_expire_t and self._expire_t < self._debuff_expire_t then
			self._icon:set_color(self._default_icon_color)
			self._ace_icon:set_color(self._default_icon_color)
		end
	end

	function HUDList.BuffItemBase:set_duration_debuff(id, data)
		self._debuff_start_t = data.t
		self._debuff_expire_t = data.expire_t

		self._progress_bar_debuff:set_visible(true)

		if self._buff_active and self._expire_t and self._expire_t < self._debuff_expire_t then
			self._icon:set_color(self._default_icon_color)
			self._ace_icon:set_color(self._default_icon_color)
		end
	end

	function HUDList.BuffItemBase:set_progress(id, data)
		if self._buff_active and not self._expire_t then
			self._progress_bar:set_visible(true)
			self:_set_progress(data.progress)
		end
	end

	function HUDList.BuffItemBase:set_progress_debuff(id, data)
		if self._debuff_active and not self._debuff_expire_t then
			self._progress_bar_debuff:set_visible(true)
			self:_set_progress_debuff(data.progress)
		end
	end

	function HUDList.BuffItemBase:set_stack_count(id, data)
		self:_set_stack_count(data.stack_count)
	end

	function HUDList.BuffItemBase:set_value(id, data)
		if self._show_value then
			local str = ""
			if type(self._show_value) == "function" then
				str = self._show_value(data.value)
			elseif type(self._show_value) == "string" then
				str = string.format(self._show_value, data.value)
			else
				str = tostring(data.value)
			end
			self:_set_text(str)
		end
	end

	function HUDList.BuffItemBase:set_data(id, data)
		-- Unused, only called for interact Item...
		self._data = data.data
	end

	function HUDList.BuffItemBase:_update_debuff(t, dt)
		self:_set_progress_debuff((t - self._debuff_start_t) / (self._debuff_expire_t - self._debuff_start_t))

		if t > self._debuff_expire_t then
			self._debuff_start_t = nil
			self._debuff_expire_t = nil
			self._progress_bar_debuff:set_visible(false)
		end
	end

	function HUDList.BuffItemBase:_set_progress(r)
		self._progress_bar:set_ratio(1-r)
	end

	function HUDList.BuffItemBase:_set_progress_inner(r)
		self._progress_bar_inner:set_ratio(1-r)
	end

	function HUDList.BuffItemBase:_set_progress_debuff(r)
		self._progress_bar_debuff:set_ratio(r)
	end

	function HUDList.BuffItemBase:_set_stack_count(count)
		self._stack_bg:set_visible(count and true or false)
		self._stack_text:set_visible(count and true or false)
		self._stack_text:set_text(count or 0)
	end

	function HUDList.BuffItemBase:_set_text(str)
		self._has_text = str and str:len() > 0 and true or false
		if alive(self._value) then
			self._value:set_text(tostring(str or ""))
		end
	end

	HUDList.TimedBuffItem = HUDList.TimedBuffItem or class(HUDList.BuffItemBase)
	function HUDList.TimedBuffItem:init(...)
		HUDList.TimedBuffItem.super.init(self, ...)
	end

	function HUDList.TimedBuffItem:update(t, dt)
		HUDList.TimedBuffItem.super.update(self, t, dt)
		
		local time_str = {}
		if self._debuff_active and self._debuff_expire_t then
			self:_update_debuff(t, dt)

			if self._debuff_expire_t and self._debuff_expire_t > t then
				table.insert(time_str, {
					str = string.format("%.1fs", self._debuff_expire_t - t),
					color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF
				})
			end
		end

		if self._buff_active and self._expire_t then
			self:_set_progress((t - self._start_t) / (self._expire_t - self._start_t))

			if t > self._expire_t then
				self._start_t = nil
				self._expire_t = nil
				self._progress_bar:set_visible(false)
			end

			if self._expire_t and self._expire_t > t then
				table.insert(time_str, {
					str = string.format("%.1fs", self._expire_t - t),
					color = self._default_icon_color
				})
			end
		end

		if not self._has_text then
			if #time_str > 0 then
				local color_ranges = {}
				local str = ""
				local offset = 0

				for i, data in ipairs(time_str) do
					str = str .. data.str
					table.insert(color_ranges, { offset, string.len(str), data.color or HUDList.BuffItemBase.ICON_COLOR.STANDARD })
					if i < #time_str then
						str = str .. " "
					end
					offset = offset + string.len(str)
				end

				self._value:set_text(str)

				for _, data in ipairs(color_ranges) do
					self._value:set_range_color(data[1], data[2], data[3])
				end
			else
				self._value:set_text("")
			end
		end
	end

	HUDList.TimedStacksBuffItem = HUDList.TimedStacksBuffItem or class(HUDList.BuffItemBase)
	function HUDList.TimedStacksBuffItem:init(...)
		HUDList.TimedStacksBuffItem.super.init(self, ...)
		self._stacks = {}
	end

	function HUDList.TimedStacksBuffItem:update(t, dt)
		HUDList.TimedStacksBuffItem.super.update(self, t, dt)
		
		local time_str = {}
		if self._debuff_active and self._debuff_expire_t then
			self:_update_debuff(t, dt)

			if self._debuff_expire_t and self._debuff_expire_t > t then
				table.insert(time_str, {
					str = string.format("%.1fs", self._debuff_expire_t - t),
					color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF
				})
			end
		end

		if #self._stacks > 0 then
			local stack = self._stacks[#self._stacks]
			self:_set_progress((stack.expire_t - t) / (stack.expire_t - stack.t))
		else
			self:_set_progress(0)
		end

		if #self._stacks > 1 then
			local stack = self._stacks[1]
			self:_set_progress_inner((stack.expire_t - t) / (stack.expire_t - stack.t))
		else
			self:_set_progress_inner(0)
		end

		if not self._has_text then
			if #time_str > 0 then
				local color_ranges = {}
				local str = ""
				local offset = 0

				for i, data in ipairs(time_str) do
					str = str .. data.str
					table.insert(color_ranges, { offset, string.len(str), data.color or self._default_icon_color or HUDList.BuffItemBase.ICON_COLOR.STANDARD })
					if i < #time_str then
						str = str .. " "
					end
					offset = offset + string.len(str)
				end

				self._value:set_text(str)

				for _, data in ipairs(color_ranges) do
					self._value:set_range_color(data[1], data[2], data[3])
				end
			else
				self._value:set_text("")
			end
		end
	end

	function HUDList.TimedStacksBuffItem:add_timed_stack(id, data)
		self:_update_stacks(data and data.stacks or {})
	end

	function HUDList.TimedStacksBuffItem:remove_timed_stack(id, data)
		self:_update_stacks(data and data.stacks or {})
	end

	function HUDList.TimedStacksBuffItem:_update_stacks(stacks)
		self._stacks = stacks or {}
		self:_set_stack_count(#self._stacks)
		self._progress_bar:set_visible(#self._stacks > 0)
		self._progress_bar_inner:set_visible(#self._stacks > 1)
	end

	HUDList.BikerBuffItem = HUDList.BikerBuffItem or class(HUDList.TimedStacksBuffItem)

	function HUDList.BikerBuffItem:_set_stack_count(count)
		local charges = tweak_data.upgrades.wild_max_triggers_per_time - count
		if charges <= 0 then
			self:activate_debuff()
		else
			self:deactivate_debuff()
		end

		HUDList.BikerBuffItem.super._set_stack_count(self, math.max(charges, 0))
	end

	HUDList.TeamBuffItem = HUDList.TeamBuffItem or class(HUDList.BuffItemBase)
	function HUDList.TeamBuffItem:init(...)
		HUDList.TeamBuffItem.super.init(self, ...)
		self._members = {}
	end

	function HUDList.TeamBuffItem:set_stack_count(id, data)
		--HUDList.TeamBuffItem.super.set_stack_count(self, data)
		self._members[id] = { level = data.level, count = data.stack_count or 0 }
		self:_recheck_level()
	end

	function HUDList.TeamBuffItem:_recheck_level()
		local max_level = 0

		for id, data in pairs(self._members) do
			if data.count > 0 then
				max_level = math.max(data.level, max_level)
			end
		end

		self:_set_text(max_level > 0 and ("Lv. " .. tostring(max_level)) or "")
	end

	HUDList.CompositeBuff = HUDList.CompositeBuff or class(HUDList.BuffItemBase)
	function HUDList.CompositeBuff:init(...)
		HUDList.CompositeBuff.super.init(self, ...)
		self._member_buffs = {}
		self._progress_bar:set_visible(true)
		self._progress_bar_inner:set_visible(true)
	end

	function HUDList.CompositeBuff:activate(id)
		HUDList.CompositeBuff.super.activate(self, id)

		if not self._member_buffs[id] then
			self._member_buffs[id] = {}
			--self:_check_buffs()
		end
	end

	function HUDList.CompositeBuff:deactivate(id)
		if self._member_buffs[id] then
			self._member_buffs[id] = nil
			self:_check_buffs()

			if next(self._member_buffs) == nil then
				HUDList.CompositeBuff.super.deactivate(self, id)
			end
		end
	end

	function HUDList.CompositeBuff:activate_debuff(id)
		-- TODO?
	end

	function HUDList.CompositeBuff:deactivate_debuff(id)
		-- TODO?
	end

	function HUDList.CompositeBuff:update(t, dt)
		HUDList.CompositeBuff.super.update(self, t, dt)

		if self._min_expire_buff then
			self:_set_progress_inner((t - self._member_buffs[self._min_expire_buff].start_t) / (self._member_buffs[self._min_expire_buff].expire_t - self._member_buffs[self._min_expire_buff].start_t))
		end

		if self._max_expire_buff then
			self:_set_progress((t - self._member_buffs[self._max_expire_buff].start_t) / (self._member_buffs[self._max_expire_buff].expire_t - self._member_buffs[self._max_expire_buff].start_t))
		end
	end

	function HUDList.CompositeBuff:set_duration(id, data)
		if self._member_buffs[id] then
			self._member_buffs[id].start_t = data.t
			self._member_buffs[id].expire_t = data.expire_t
			self:_check_buffs()
		end
	end

	function HUDList.CompositeBuff:set_stack_count(id, data)
		if self._member_buffs[id] and self._member_buffs[id].stack_count ~= data.stack_count then
			self._member_buffs[id].stack_count = data.stack_count
			--self:_check_buffs()
		end
	end

	function HUDList.CompositeBuff:set_value(id, data)
		if self._member_buffs[id] and self._member_buffs[id].value ~= data.value then
			WolfHUD:print_log("(HUDList) CompositeBuff:set_value(%s, %s)", tostring(id), tostring(data.value), "info")
			self._member_buffs[id].value = data.value
			self:_check_buffs()
		end
	end

	function HUDList.CompositeBuff:_check_buffs()
		local max_expire
		local min_expire

		for id, data in pairs(self._member_buffs) do
			if data.expire_t then
				if not max_expire or data.expire_t > self._member_buffs[max_expire].expire_t then
					max_expire = id
				end
				if not min_expire or data.expire_t < self._member_buffs[min_expire].expire_t then
					min_expire = id
				end
			end
		end

		self._max_expire_buff = max_expire
		self._min_expire_buff = min_expire

		if not self._max_expire_buff then
			self._progress_bar:set_visible(false)
		else
			self._progress_bar:set_visible(true)
		end

		if not self._min_expire_buff or self._member_buffs[self._min_expire_buff].expire_t == self._member_buffs[self._max_expire_buff].expire_t then
			self._min_expire_buff = nil
			self._progress_bar_inner:set_visible(false)
		else
			self._progress_bar_inner:set_visible(true)
		end

		self:_update_value()
	end

	HUDList.DamageIncreaseBuff = HUDList.DamageIncreaseBuff or class(HUDList.CompositeBuff)
	function HUDList.DamageIncreaseBuff:init(...)
		HUDList.DamageIncreaseBuff.super.init(self, ...)

		self._buff_weapon_requirements = {
			overkill = {
				shotgun = true,
				saw = true,
			},
			berserker = {
				saw = true,
			},
		}

		self._buff_weapon_exclusions = {
			overkill_aced = {
				shotgun = true,
				saw = true,
			},
			berserker_aced = {
				saw = true,
			},
		}

		self._buff_effects = {
			berserker = function(value)
				return 1 + (value or 0) * managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0)
			end,
			berserker_aced = function(value)
				return 1 + (value or 0) * managers.player:upgrade_value("player", "damage_health_ratio_multiplier", 0)
			end,
		}
	end

	function HUDList.DamageIncreaseBuff:update(t, dt)
		HUDList.DamageIncreaseBuff.super.update(self, t, dt)

		if not alive(self._player_unit) and alive(managers.player:player_unit()) then
			self._player_unit = managers.player:player_unit()
			self._player_unit:inventory():add_listener("DamageIncreaseBuff", { "equip" }, callback(self, self, "_on_weapon_equipped"))
			self:_on_weapon_equipped(self._player_unit)
		end
	end

	function HUDList.DamageIncreaseBuff:_on_weapon_equipped(unit)
		self._weapon_unit = unit:inventory():equipped_unit()
		self._weapon_id = self._weapon_unit:base():get_name_id()
		self._weapon_tweak = self._weapon_unit:base():weapon_tweak_data()

		self:_update_value()
	end

	function HUDList.DamageIncreaseBuff:_update_value()
		local text = ""

		if alive(self._weapon_unit) then
			if self._weapon_tweak.ignore_damage_upgrades then
				text = "(0%)"
			else
				local weapon_categories = self._weapon_tweak.categories
				local value = 1

				for id, data in pairs(self._member_buffs) do
					for _, category in ipairs(weapon_categories) do
						if not self._buff_weapon_requirements[id] or self._buff_weapon_requirements[id][category] then
							if not (self._buff_weapon_exclusions[id] and self._buff_weapon_exclusions[id][category]) then
								local clbk = self._buff_effects[id]
								value = value * (data.value and (clbk and clbk(data.value) or data.value) or 1)
								break
							end
						end
					end
				end

				text = string.format("+%.0f%%", (value-1)*100)
			end
		end

		self:_set_text(text)
	end

	HUDList.MeleeDamageIncreaseBuff = HUDList.MeleeDamageIncreaseBuff or class(HUDList.CompositeBuff)
	function HUDList.MeleeDamageIncreaseBuff:init(...)
		HUDList.MeleeDamageIncreaseBuff.super.init(self, ...)

		self._buff_effects = {
			berserker = function(value)
				return 1 + (value or 0) * managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0)
			end,
		}
	end

	function HUDList.MeleeDamageIncreaseBuff:_update_value()
		local value = 1

		for id, data in pairs(self._member_buffs) do
			local clbk = self._buff_effects[id]
			value = value * (data.value and (clbk and clbk(data.value) or data.value) or 1)
		end

		self:_set_text(string.format("x%.0f", (value-1)))
	end

	HUDList.DamageReductionBuff = HUDList.DamageReductionBuff or class(HUDList.CompositeBuff)
	function HUDList.DamageReductionBuff:init(...)
		HUDList.DamageReductionBuff.super.init(self, ...)
		self._buff_effects = {
			chico_injector = function(value)
				local player = managers.player:player_unit()
				local health_ratio = alive(player) and player:character_damage():health_ratio() or 1
                if managers.player:has_category_upgrade("player", "chico_injector_low_health_multiplier") then
                    local upg_values = managers.player:upgrade_value("player", "chico_injector_low_health_multiplier")
                    if health_ratio < upg_values[1] then
                        value = value + upg_values[2]
                    end
                end
				return 1 - value
			end,
			frenzy = function(value)
				return 1 - value
			end,
			maniac = function(value)
				local new_value = 1
				local player = managers.player:player_unit()
				local player_damage = alive(player) and player:character_damage()
				if player_damage then
					if player_damage:get_real_armor() > 0 then
						new_value = value / (player_damage:_max_armor() * 10)
					else
						new_value = value / (player_damage:_max_health() * 10)
					end
				end
				return 1 - new_value
			end
		}
	end

	function HUDList.DamageReductionBuff:_update_value()
		local value = 1

		for id, data in pairs(self._member_buffs) do
			local clbk = self._buff_effects[id]
			value = value * (data.value and (clbk and clbk(data.value) or data.value) or 1)
		end

		self:_set_text(string.format("-%.0f%%", math.min(1 - value, 1) * 100))
	end

	HUDList.PassiveHealthRegenBuff = HUDList.PassiveHealthRegenBuff or class(HUDList.CompositeBuff)
	function HUDList.PassiveHealthRegenBuff:init(...)
		HUDList.PassiveHealthRegenBuff.super.init(self, ...)
		self._buff_effects = {
			crew_health_regen = function(value)
				local new_value = 0
				local player = managers.player:player_unit()
				local player_damage = alive(player) and player:character_damage()
				if player_damage then
					new_value = value / (player_damage:_max_health() * 10)
				end
				return new_value
			end
		}
	end

	function HUDList.PassiveHealthRegenBuff:_update_value()
		local value = 0

		for id, data in pairs(self._member_buffs) do
			local clbk = self._buff_effects[id]
			value = value + (data.value and (clbk and clbk(data.value) or data.value) or 0)
		end

		self:_set_text(string.format("%.1f%%", value * 100))
	end

	HUDList.TotalDodgeChanceBuff = HUDList.TotalDodgeChanceBuff or class(HUDList.CompositeBuff)
	function HUDList.TotalDodgeChanceBuff:init(...)
		HUDList.TotalDodgeChanceBuff.super.init(self, ...)

        self._member_buffs["base_dodge"] = { value = (tweak_data.player.damage.DODGE_INIT or 0) + managers.player:body_armor_value("dodge") }
		self._member_buffs["crook_dodge"] = { value = managers.player:upgrade_value("player", "passive_dodge_chance", 0)
												+ managers.player:upgrade_value("player", tostring(managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0) -- Crook Perk
											}
		self._member_buffs["burglar_dodge"] = { value = managers.player:upgrade_value("player", "tier_dodge_chance", 0) }	 -- Burglar Perk
		self._member_buffs["jail_diet"] = { value = managers.player:get_value_from_risk_upgrade(managers.player:upgrade_value("player", "detection_risk_add_dodge_chance"))}
        self._member_buffs["henchman_dodge"] = { value = managers.player:upgrade_value("team", "crew_add_dodge", 0) }

		self._buff_effects = {
		}

		self:_check_buffs()
	end

	function HUDList.TotalDodgeChanceBuff:_update_value()
		local value = 0

		for id, data in pairs(self._member_buffs) do
			local clbk = self._buff_effects[id]
			value = value + (data.value and (clbk and  clbk(data.value) or data.value) or 0)
		end

		if self._member_buffs["smoke_screen_grenade"] then
			value = 1 - (1 - value) * (1 - tweak_data.projectiles.smoke_screen_grenade.dodge_chance)
		end

		self:_set_text(string.format("%.0f%%", math.max(value * 100, 0)))

		if value <= 0 then
			HUDList.TotalDodgeChanceBuff.super.super.deactivate(self, "nil")
		else
			HUDList.TotalDodgeChanceBuff.super.super.activate(self, "nil")
		end
	end

	function HUDList.TotalDodgeChanceBuff:activate(id)
		if not self._member_buffs[id] then
			self._member_buffs[id] = {}
		end
	end

	function HUDList.TotalDodgeChanceBuff:deactivate(id)
		if self._member_buffs[id] then
			self._member_buffs[id] = nil
			self:_check_buffs()
		end
	end

	HUDList.TimedInteractionItem = HUDList.TimedInteractionItem or class(HUDList.TimedBuffItem)
	HUDList.TimedInteractionItem.INTERACT_ID_TO_ICON = {
		default 					= { texture = "guis/textures/pd2/skilltree/drillgui_icon_faster" 	},
		mask_up 					= { texture = "guis/textures/wolfhud/hudlist/mask_up" 				},
		ammo_bag 					= { skills 		= {1, 0}				},
		doc_bag 					= { skills 		= {2, 7}				},
		first_aid_kit 				= { skills 		= {3, 10}, 				},
		body_bag 					= { skills 		= {5, 11}, 				},
		grenade_crate 				= { preplanning = {1, 0}			 	},
		ecm_jammer 					= { skills 		= {1, 4}, 				},
		corpse_alarm_pager			= { skills 		= {1, 4}, 				},
		pick_lock_easy_no_skill 	= { skills 		= {5, 4} 				},
		intimidate					= { hud_tweak = "equipment_cable_ties" 	},
		c4_consume 					= { hud_tweak = "equipment_c4" 			},
		drill 						= { hud_tweak = "pd2_drill" 			},
		hack 						= { hud_tweak = "pd2_computer" 			},
		saw 						= { hud_tweak = "wp_saw" 				},
		timer 						= { hud_tweak = "pd2_computer" 			},
		securitylock 				= { hud_tweak = "pd2_computer" 			},
		digital 					= { hud_tweak = "pd2_computer" 			},
	}
	function HUDList.TimedInteractionItem:init(...)
		HUDList.TimedInteractionItem.super.init(self, ...)
	end

	function HUDList.TimedInteractionItem:activate_debuff()
		if not self._debuff_active then
			HUDList.TimedInteractionItem.super.activate_debuff(self)
			self:_set_icon("default")
		end
	end

	function HUDList.TimedInteractionItem:set_data(id, data)
		HUDList.TimedInteractionItem.super.set_data(self, id, data)
		if data.data then
			self:_set_icon(data.data.interact_id)

			local color = self._default_icon_color
			if data.data.invalid then
				color = HUDList.BuffItemBase.ICON_COLOR.DEBUFF
			end
			self._icon:set_color(color)
			self._ace_icon:set_color(color)
		end
	end

	function HUDList.TimedInteractionItem:_set_icon(interact_id)
		local lookup = HUDList.TimedInteractionItem.INTERACT_ID_TO_ICON
		local icon_data = lookup[interact_id] or lookup["default"]
		if icon_data and alive(self._icon) then
			local texture, texture_rect = get_icon_data(icon_data)

			self._icon:set_image(texture)
			if texture_rect then
				self._icon:set_texture_rect(unpack(texture_rect))
			end
		end
	end

	PanelFrame = PanelFrame or class()

	function PanelFrame:init(parent, settings)
		settings = settings or {}

		local h = settings.h or parent:h()
		local w = settings.w or parent:w()

		self._panel = parent:panel({
			w = w,
			h = h,
			alpha = settings.alpha or 1,
		})

		if settings.add_bg then
			self._bg = self._panel:rect({
				name = "bg",
				valign = "grow",
				halign = "grow",
				blend_mode = "normal",
				layer = self._panel:layer() - 1,
				color = settings.bg_color or settings.color or Color.black,
				alpha = settings.bg_alpha or settings.alpha or 0.25,
			})
		end

		self._invert_progress = settings.invert_progress
		self._top = self._panel:rect({})
		self._bottom = self._panel:rect({})
		self._left = self._panel:rect({})
		self._right = self._panel:rect({})

		self:set_width(settings.bar_w or 2)
		self:set_color(settings.bar_color or settings.color or Color.white, settings.alpha or settings.bar_alpha or 1)
		self:reset()
	end

	function PanelFrame:panel()
		return self._panel
	end

	function PanelFrame:set_width(w)
		local pw, ph = self._panel:w(), self._panel:h()
		local total = 2*pw + 2*ph
		self._bar_w = w
		self._stages = { 0, (pw - 2*self._bar_w)/total, (pw+ph-self._bar_w)/total, (2*pw+ph-2*self._bar_w)/total, 1 }
		self._top:set_h(w)
		self._top:set_top(0)
		self._bottom:set_h(w)
		self._bottom:set_bottom(self._panel:h())
		self._left:set_w(w)
		self._left:set_left(0)
		self._right:set_w(w)
		self._right:set_right(self._panel:w())
	end

	function PanelFrame:set_color(c, alpha)
		self._top:set_color(c)
		self._bottom:set_color(c)
		self._left:set_color(c)
		self._right:set_color(c)
		if alpha then
			self._top:set_alpha(alpha)
			self._bottom:set_alpha(alpha)
			self._left:set_alpha(alpha)
			self._right:set_alpha(alpha)
		end
	end

	function PanelFrame:set_bg_color(c, alpha)
		if alive(self._bg) then
			self._bg:set_color(c)
			if alpha then
				self._bg:set_alpha(alpha)
			end
		end
	end

	function PanelFrame:set_alpha(alpha)
		self._top:set_alpha(alpha)
		self._bottom:set_alpha(alpha)
		self._left:set_alpha(alpha)
		self._right:set_alpha(alpha)
	end

	function PanelFrame:set_bg_alpha(alpha)
		if alive(self._bg) then
			self._bg:set_alpha(alpha)
		end
	end

	function PanelFrame:reset()
		self._current_stage = 1
		self._top:set_w(self._panel:w() - 2 * self._bar_w)
		self._top:set_left(self._bar_w)
		self._right:set_h(self._panel:h())
		self._right:set_bottom(self._panel:h())
		self._bottom:set_w(self._panel:w() - 2 * self._bar_w)
		self._bottom:set_right(self._panel:w() - self._bar_w)
		self._left:set_h(self._panel:h())
	end

	function PanelFrame:set_ratio(r)
		r = math.clamp(r, 0, 1)
		self._current_ratio = r
		if self._invert_progress then
			r = 1-r
		end

		if r < self._stages[self._current_stage] then
			self:reset()
		end

		while r > self._stages[self._current_stage + 1] do
			if self._current_stage == 1 then
				self._top:set_w(0)
			elseif self._current_stage == 2 then
				self._right:set_h(0)
			elseif self._current_stage == 3 then
				self._bottom:set_w(0)
			elseif self._current_stage == 4 then
				self._left:set_h(0)
			end
			self._current_stage = self._current_stage + 1
		end

		local low = self._stages[self._current_stage]
		local high = self._stages[self._current_stage + 1]
		local stage_progress = (r - low) / (high - low)

		if self._current_stage == 1 then
			self._top:set_w((self._panel:w() - 2 * self._bar_w) * (1-stage_progress))
			self._top:set_right(self._panel:w() - self._bar_w)
		elseif self._current_stage == 2 then
			self._right:set_h(self._panel:h() * (1-stage_progress))
			self._right:set_bottom(self._panel:h())
		elseif self._current_stage == 3 then
			self._bottom:set_w((self._panel:w() - 2 * self._bar_w) * (1-stage_progress))
		elseif self._current_stage == 4 then
			self._left:set_h(self._panel:h() * (1-stage_progress))
		end
	end

	function PanelFrame:ratio()
		local r = self._current_ratio or 0
		if self._invert_progress then
			r = 1-r
		end
		return r
	end

	function PanelFrame:alpha() return self._panel:alpha() end
	function PanelFrame:w() return self._panel:w() end
	function PanelFrame:h() return self._panel:h() end
	function PanelFrame:x() return self._panel:x() end
	function PanelFrame:y() return self._panel:y() end
	function PanelFrame:left() return self._panel:left() end
	function PanelFrame:right() return self._panel:right() end
	function PanelFrame:top() return self._panel:top() end
	function PanelFrame:bottom() return self._panel:bottom() end
	function PanelFrame:center() return self._panel:center() end
	function PanelFrame:center_x() return self._panel:center_x() end
	function PanelFrame:center_y() return self._panel:center_y() end
	function PanelFrame:visible() return self._panel:visible() end
	function PanelFrame:layer() return self._panel:layer() end
	function PanelFrame:text_rect() return self:x(), self:y(), self:w(), self:h() end
	function PanelFrame:set_x(v) self._panel:set_x(v) end
	function PanelFrame:set_y(v) self._panel:set_y(v) end
	function PanelFrame:set_w(v) self:set_size(v, nil)	end
	function PanelFrame:set_h(v) self:set_size(nil, v)	end
	function PanelFrame:set_size(w, h)
		w = w or self:w()
		h = h or self:h()

		self._panel:set_size(w, h)
		self:set_width(self._bar_w)
		self:reset()
		self:set_ratio(self._current_ratio or 1)
	end
	function PanelFrame:set_left(v) self._panel:set_left(v) end
	function PanelFrame:set_right(v) self._panel:set_right(v) end
	function PanelFrame:set_top(v) self._panel:set_top(v) end
	function PanelFrame:set_bottom(v) self._panel:set_bottom(v) end
	function PanelFrame:set_center(x, y) self._panel:set_center(x, y) end
	function PanelFrame:set_center_x(v) self._panel:set_center_x(v) end
	function PanelFrame:set_center_y(v) self._panel:set_center_y(v) end
	function PanelFrame:set_visible(v) self._panel:set_visible(v) end
	function PanelFrame:set_layer(v) self._panel:set_layer(v) end
end

if string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then
	local init_original = ObjectInteractionManager.init

	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		if managers.gameinfo and WolfHUD:getSetting({"HUDSuspicion", "REMOVE_ANSWERED_PAGER_CONTOUR"}, true) then
			managers.gameinfo:register_listener("pager_contour_remover", "pager", "set_answered", callback(nil, _G, "pager_answered_clbk"))
		end
	end

	function pager_answered_clbk(event, key, data)
		managers.enemy:add_delayed_clbk("contour_remove_" .. key, callback(nil, _G, "remove_answered_pager_contour_clbk", data.unit), Application:time() + 0.01)
	end

	function remove_answered_pager_contour_clbk(unit)
		if alive(unit) then
			unit:contour():remove(tweak_data.interaction.corpse_alarm_pager.contour_preset)
		end
	end
end

if string.lower(RequiredScript) == "lib/managers/hud/hudassaultcorner" then
	local HUDAssaultCorner_init = HUDAssaultCorner.init
	function HUDAssaultCorner:init(...)
		HUDAssaultCorner_init(self, ...)
		local hostages_panel = self._hud_panel:child("hostages_panel")
		if alive(hostages_panel) then
			hostages_panel:set_alpha(0)
		end
	end
end
