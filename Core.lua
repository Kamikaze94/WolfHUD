if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath
	WolfHUD.settings_path = WolfHUD.save_path .. "WolfHUD.txt"
	WolfHUD.colors_file = "WolfHUD_Colors.txt"
	WolfHUD.inv_names_file = "WolfHUD_InventoryNames.txt"
	WolfHUD.LOG_MODE = { error = true, warning = false, info = false }		-- error, info, warning or all
	WolfHUD.version = "1.0"
	WolfHUD.menu_ids = { 
		"wolfhud_options_menu", 
		"wolfhud_panels_options_menu",
		"wolfhud_playerpanel_options_menu",
		"wolfhud_teampanels_options_menu", 
		"wolfhud_chat_options_menu", 
		"wolfhud_killcounter_options_menu", 
		"wolfhud_drivinghud_options_menu", 
		"wolfhud_infopanels_options_menu", 
		"wolfhud_infopanels_left_options_menu",
		"wolfhud_infopanels_right_options_menu",
		"wolfhud_infopanels_buff_options_menu",
		"wolfhud_infopanels_buff_mastermind_options_menu",
		"wolfhud_infopanels_buff_enforcer_options_menu",
		"wolfhud_infopanels_buff_technician_options_menu",
		"wolfhud_infopanels_buff_ghost_options_menu",
		"wolfhud_infopanels_buff_fugitive_options_menu",
		"wolfhud_infopanels_buff_perkdecks_options_menu",
		"wolfhud_waypoints_options_menu",
		"wolfhud_tabstats_options_menu",
		"wolfhud_dmgindicator_options_menu", 
		"wolfhud_dmgpopup_options_menu",
		"wolfhud_enemyhealthbar_options_menu", 
		"wolfhud_press2hold_options_menu", 
		"wolfhud_equipment_options_menu",
		"wolfhud_gadget_options_menu",
		"wolfhud_gadget_laser_options_menu"
	}
	WolfHUD.settings = {}
	
	if not WolfHUD.color_table then
		WolfHUD.color_table = { -- namestring is always 'wolfhud_colors_<name>'
			{ color = 'FFFFFF', name = "white" },
			{ color = 'F2F250', name = "light_yellow" },
			{ color = 'F2C24E', name = "light_orange" },
			{ color = 'E55858', name = "light_red" },
			{ color = 'CC55CC', name = "light_purple" },
			{ color = '00FF00', name = "light_green" },
			{ color = '00FFFF', name = "light_blue" },
			{ color = 'BABABA', name = "light_gray" },
			{ color = 'FFFF00', name = "yellow" },
			{ color = 'FFA500', name = "orange" },
			{ color = 'FF0000', name = "red" },
			{ color = '800080', name = "purple" },
			{ color = '008000', name = "green" },
			{ color = '0000FF', name = "blue" },
			{ color = '808080', name = "gray" },
			{ color = '000000', name = "black" },
			{ color = '000000', name = "rainbow" },
		}
	end
	if not WolfHUD.inventory_names then		
		
		if io.file_is_readable(WolfHUD.mod_path .. WolfHUD.inv_names_file) then
			if not io.file_is_readable(WolfHUD.save_path ..WolfHUD.inv_names_file) then
				local source = io.open(WolfHUD.mod_path .. WolfHUD.inv_names_file, "r")
				local dest = io.open(WolfHUD.save_path ..WolfHUD.inv_names_file, "w+")
				if source and dest then
					dest:write(source:read("*all"))
					source:close()
					dest:close()
				end
			end
			os.remove(WolfHUD.mod_path .. WolfHUD.inv_names_file)
		end
		
		local file = io.open(WolfHUD.save_path .. WolfHUD.inv_names_file, "r")
		if file then
			WolfHUD.inventory_names = json.decode(file:read("*all"))
			file:close()
		end
	end
	
	WolfHUD.hook_files = WolfHUD.hook_files or {
		["lib/setups/setup"] = { "GameInfoManager.lua", "WaypointsManager.lua" },
		["lib/managers/menumanager"] = { "MenuTweaks.lua" },
		["lib/managers/menumanagerdialogs"] = { "MenuTweaks.lua" },
		["lib/managers/chatmanager"] = { "MenuTweaks.lua" },
		["lib/managers/localizationmanager"] = { "AdvAssault.lua" },
		["lib/managers/experiencemanager"] = { "Scripts.lua" },
		["lib/managers/moneymanager"] = { "Scripts.lua" },
		["lib/managers/hudmanager"] = { "EnemyHealthbar.lua", "TabStats.lua", "CustomWaypoints.lua" },
		["lib/managers/hudmanagerpd2"] = { "CustomHUD.lua", "HUDChat.lua", "HUDList.lua", "KillCounter.lua", "DownCounter.lua", "DrivingHUD.lua", "DamageIndicator.lua", "WaypointsManager.lua", "Interaction.lua", "Scripts.lua", "BurstFire.lua", "AdvAssault.lua" },
		["lib/managers/statisticsmanager"] = { "KillCounter.lua", "TabStats.lua" },
		["lib/managers/playermanager"] = { "GameInfoManager.lua" },
		["lib/managers/hud/huddriving"] = { "DrivingHUD.lua" },
		["lib/managers/hud/hudteammate"] = { "CustomHUD.lua", "KillCounter.lua", "DownCounter.lua", "BurstFire.lua" },
		["lib/managers/hud/hudtemp"] = { "CustomHUD.lua" },
		["lib/managers/hud/hudassaultcorner"] = { "HUDList.lua", "AdvAssault.lua" },
		["lib/managers/hud/hudobjectives"] = { "EnhancedObjective.lua" },
		["lib/managers/hud/hudheisttimer"] = { "EnhancedObjective.lua" },
		["lib/managers/hud/hudchat"] = { "HUDChat.lua" },
		["lib/managers/hud/hudstatsscreen"] = { "TabStats.lua" },
		["lib/managers/hud/hudinteraction"] = { "Interaction.lua" },
		["lib/managers/hud/hudsuspicion"] = { "NumbericSuspicion.lua" },
		["lib/managers/hud/hudhitdirection"] = { "DamageIndicator.lua" },
		["lib/managers/enemymanager"] = { "GameInfoManager.lua" },
		["lib/managers/group_ai_states/groupaistatebase"] = { "GameInfoManager.lua", "PacifiedCivs.lua", "CustomWaypoints.lua" },
		["lib/managers/missionassetsmanager"] = { "BuyAllAsset.lua" },
		["lib/managers/menu/blackmarketgui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/stageendscreengui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/lootdropscreengui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/skilltreeguinew"] = { "MenuTweaks.lua" },
		["lib/managers/menu/renderers/menunodeskillswitchgui"] = { "MenuTweaks.lua" },
		["lib/managers/objectinteractionmanager"] = { "GameInfoManager.lua", "HUDList.lua", "Interaction.lua" },
		["lib/network/handlers/unitnetworkhandler"] = { "DownCounter.lua", "GameInfoManager.lua" },
		["lib/units/props/timergui"] = { "GameInfoManager.lua" },
		["lib/units/props/digitalgui"] = { "GameInfoManager.lua" },
		["lib/units/props/securitylockgui"] = { "GameInfoManager.lua" },
		["lib/units/civilians/civiliandamage"] = { "DamagePopup.lua" },
		["lib/units/enemies/cop/copdamage"] = { "GameInfoManager.lua", "KillCounter.lua", "DamagePopup.lua", "TabStats.lua" },
		["lib/units/cameras/fpcameraplayerbase"] = { "WeaponGadgets.lua" },
		["lib/units/equipment/ammo_bag/ammobagbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/doctor_bag/doctorbagbase"] = { "DownCounter.lua", "GameInfoManager.lua" },
		["lib/units/equipment/first_aid_kit/firstaidkitbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] = { "GameInfoManager.lua", "EquipmentTweaks.lua" },
		["lib/units/equipment/grenade_crate/grenadecratebase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/sentry_gun/sentrygunbase"] = { "GameInfoManager.lua", "KillCounter.lua" },
		["lib/units/equipment/sentry_gun/sentrygundamage"] = { "GameInfoManager.lua" },
		["lib/units/interactions/interactionext"] = { "GameInfoManager.lua", "Interaction.lua", "EquipmentTweaks.lua" },
		["lib/units/weapons/akimboweaponbase"] = { "BurstFire.lua" },
		["lib/units/weapons/sentrygunweapon"] = { "GameInfoManager.lua", "EquipmentTweaks.lua" },
		["lib/units/weapons/weaponlaser"] = { "WeaponGadgets.lua" },
		["lib/units/weapons/weaponflashlight"] = { "WeaponGadgets.lua" },
		["lib/units/weapons/raycastweaponbase"] = { "GameInfoManager.lua", "Scripts.lua" },
		["lib/units/weapons/newraycastweaponbase"] = { "WeaponGadgets.lua", "BurstFire.lua" },
		["lib/units/props/securitycamera"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/playerdamage"] = { "GameInfoManager.lua", "DamageIndicator.lua" },
		["lib/units/beings/player/playermovement"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/huskplayermovement"] = { "DownCounter.lua" },
		["lib/units/beings/player/states/playercivilian"] = { "Interaction.lua" },
		["lib/units/beings/player/states/playerstandard"] = { "GameInfoManager.lua", "EnemyHealthbar.lua", "Interaction.lua", "BurstFire.lua", "WeaponGadgets.lua" },
		["lib/units/beings/player/states/playerbleedout"] = { "DownCounter.lua" },
		["lib/units/vehicles/vehicledamage"] = { "DamageIndicator.lua" },
		["lib/units/vehicles/vehicledrivingext"] = { "CustomWaypoints.lua" },
		["lib/utils/temporarypropertymanager"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionbloodthirstbase"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionexperthandling"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionshockandawe"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractiondireneed"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionunseenstrike"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractiontriggerhappy"] = { "GameInfoManager.lua" },
		["lib/states/ingamedriving"] = { "DrivingHUD.lua" },
		["lib/states/ingamewaitingforplayers"] = { "MenuTweaks.lua" },
		["lib/tweak_data/tweakdata"] = { "MenuTweaks.lua" },	
		["lib/tweak_data/guitweakdata"] = { "MenuTweaks.lua" },	
		["lib/tweak_data/assetstweakdata"] = { "BuyAllAsset.lua" },
		["lib/tweak_data/timespeedeffecttweakdata"] = { "Scripts.lua" },
		["core/lib/managers/menu/items/coremenuitemslider"] = { "MenuTweaks.lua" },
		["core/lib/managers/subtitle/coresubtitlepresenter"] = { "EnhancedObjective.lua" },
	}
	
	
	function WolfHUD:Reset()
		WolfHUD.settings = 
		{
		  --CustomHUD
			use_customhud 							= true,
			PLAYER_POSITION							= 2,		-- left (1), center (2) or right (3)
			PLAYER_SCALE 							= 1,		--Size of local Player HUD Panel
			PLAYER_OPACITY							= 0.85,
			PLAYER_NAME								= false,
			PLAYER_RANK								= false,
			PLAYER_CHARACTER						= false,
			PLAYER_STATUS							= true,
			PLAYER_EQUIPMENT						= true,
			PLAYER_SPECIALEQUIPMENT					= true,
			PLAYER_SPECIALEQUIPMENTROWS				= 3,
			PLAYER_CALLSIGN							= false,
			PLAYER_STAMINA							= true,
			PLAYER_DOWNCOUNTER						= true,
			PLAYER_CARRY							= true,
			PLAYER_WEAPON_ICON						= 4,
			PLAYER_WEAPON_NAME						= 1,
			PLAYER_WEAPON_AMMO						= 4,
			PLAYER_WEAPON_FIREMODE					= 2,
			PLAYER_KILLCOUNTER_HIDE					= true,
			PLAYER_KILLCOUNTER_SHOWSPECIALKILLS 	= true,
			PLAYER_KILLCOUNTER_SHOWHEADSHOTKILLS	= true,
			PLAYER_KILLCOUNTER_COLOR				= "yellow",
			PLAYER_SHOWACCURACY						= true,
			TEAM_POSITION							= 1,		-- left (1), center (2) or right (3)
			TEAM_SCALE 								= 0.8,		--Size of Teammates/AI's HUD Panels
			TEAM_OPACITY							= 0.85,
			TEAM_NAME								= true,
			TEAM_RANK								= true,
			TEAM_CHARACTER							= false,
			TEAM_LATENCY							= true,
			TEAM_STATUS								= true,
			TEAM_EQUIPMENT							= true,
			TEAM_SPECIALEQUIPMENT					= true,
			TEAM_SPECIALEQUIPMENTROWS				= 3,
			TEAM_CALLSIGN							= false,
			TEAM_DOWNCOUNTER						= true,
			TEAM_CARRY								= true,
			TEAM_BUILD_HIDE							= true,
			TEAM_BUILD_DURATION						= 15,
			TEAM_WEAPON_ICON						= 4,
			TEAM_WEAPON_NAME						= 1,
			TEAM_WEAPON_AMMO						= 4,
			TEAM_WEAPON_FIREMODE					= 1,
			TEAM_INTERACTION_HIDE					= true,		-- Show Interaction
			TEAM_INTERACTION_MINDURATION			= 1,		--Hide Interaction if shorter than X sec.
			TEAM_KILLCOUNTER_HIDE					= true,
			TEAM_KILLCOUNTER_SHOWBOTKILLS			= true,
			TEAM_KILLCOUNTER_SHOWSPECIALKILLS		= true,
			TEAM_KILLCOUNTER_SHOWHEADSHOTKILLS		= true,
			TEAM_KILLCOUNTER_COLOR					= "yellow",
			show_pacified_civilians					= true,
			show_downcounter 						= true,	
			use_realammo							= true,
		  --HUDChat
			CHAT_WAIT_TIME							= 10,		--Time before chat fades out, 0 = never
			LINE_HEIGHT								= 15,		--Chat font Size
			MAX_OUTPUT_LINES						= 8,		--Chat Output lines
			spam_filter								= true,		--Filter PocoHud and NGBTO Chat Spam messages.
		  --KillCounter
			use_killcounter 						= true,
			killcounter_color						= "yellow",
			SHOW_SPECIAL_KILLS 						= true,		--KillCounter shows special kills
			SHOW_HEADSHOT_KILLS 					= true,		--KillCounter shows headshot kills
			SHOW_AI_KILLS 							= true,		--Show KillCounter for Bots
			SHOW_ACCURACY							= true,
		  --Enemy Healthbar
			show_enemy_healthbar 					= true,		--Show healthbars
			show_civilian_healthbar 				= false,	--Show Healthbars for Civilians and TeamAI
			show_car_healthbar						= true,		--Show Healthbar for vehicles
			show_healthbar_pointer 					= false,	--Show pointer near the Healthbar, pointing at Healthbar owner
		  --Dynamic Damage Indicator
			show_dmg_indicator						= true,
			dmg_ind_size							= 150,
			dmg_ind_time							= 2,
			dmg_indicator_max_count					= 10,
			dmg_shield_color						= "gray",
			dmg_health_color						= "red",
			dmg_crit_color							= "purple",
			dmg_vehicle_color						= "yellow",
			dmg_friendlyfire_color					= "orange",
		  --Damage Popup
			show_dmg_popup							= true,
			dmg_popup_time	 						= 3,
			dmg_popup_color							= "yellow",
			dmg_popup_headshot_color				= "red",
		  --Suspicion
			suspicion_scale							= 0.8,
			numberic_suspicion						= true,
			show_susp_eye							= true,
		  --Driving HUD
			use_drivinghud							= true,		--Show DrivingHUD Panel
			drivinghud_scale						= 1,
			drivinghud_show_vehicle 				= true,		--Show Vehicle and Teammate Mask Images
			drivinghud_show_health					= true,
			drivinghud_show_loot					= true,
			drivinghud_show_passengers				= true,
			drivinghud_show_gear					= true,
			drivinghud_show_speed					= true,
			drivinghud_show_rpm						= true,
			drivinghud_speed_in_mph 				= false,	--Display Speed in mph
		  --TabStats
			use_tabstats							= true,
			clock_mode								= 3,		-- 1 = disabled, 2 = 12h, 3 = 24h
			tabstats_color 							= "rainbow",
			tabstats_font_size 						= 18,
			use_actual_mask							= true,
			numberic_loot							= true,
		  --Scripts
			skip_blackscreen 						= true,		--Skip the blackscreen on mission start
			stat_screen_delay 						= 5,		--Skip the experience screen after X seconds
			autopick_card 							= true,		--Automatically pick a card on lootscreen
			loot_screen_delay 						= 3,		--Skip the loot screen after X seconds
			no_slowmotion 							= true,		--Disable mask-up and downed slow motion
		  --HUDList
			use_hudlist 							= true,
			right_list_scale						= 1,
			left_list_scale							= 1,
			buff_list_scale							= 1,
			list_color	 							= "white",		--Left and Right List font color
			list_color_bg	 						= "black",		--Left and Right List BG color
			civilian_color 							= "white", 		--EnemyCounter Civillian and Hostage icon color
			thug_color 								= "white",		--EnemyCounter Thug and Mobster icon color
			enemy_color 							= "white",		--EnemyCounter Cop and Specials icon color
			special_color 							= "white",
			
			show_timers 							= true,     --Drills, time locks, hacking etc.
			show_ammo_bags							= true,  	--Deployables (ammo)
			show_doc_bags							= true,  	--Deployables (doc bags)
			show_body_bags							= true,  	--Deployables (body bags)
			show_grenade_crates						= true,  	--Deployables (grenades)
			show_sentries 							= true,   	--Deployable sentries
			show_ecms 								= true,		--Active ECMs
			show_ecm_retrigger 						= true,  	--Countdown for players own ECM feedback retrigger delay
			show_minions 							= true,  	--Converted enemies, type and health
			show_pagers 							= true,  	--Show currently active pagers
			show_tape_loop 							= true,  	--Show active tape loop duration
			remove_answered_pager_contour 			= true,  	--Removes the interaction contour on answered pagers

			show_enemies 							= true,		--Currently spawned enemies
				aggregate_enemies 					= false,  	--Don't split enemies on type; use a single entry for all
			show_turrets 							= true,    	--Show active SWAT turrets
			show_civilians 							= true,  	--Currently spawned, untied civs
			show_hostages 							= true,   	--Currently tied civilian and dominated cops
				aggregate_hostages					= false,
			show_minion_count 						= true,     --Current number of jokered enemies
			show_pager_count 						= true,		--Show number of triggered pagers (only counts pagers triggered while you were present)
			show_cam_count							= true,
			show_bodybags_count						= true,
			show_corpse_count						= false,
			show_loot 								= true,     --Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
				aggregate_loot		 				= false, 	--Don't split loot on type; use a single entry for all
				separate_bagged_loot		 		= true,     --Show bagged loot as a separate value
				show_potential_loot					= false,
			show_special_pickups 					= true,    	--Show number of special equipment/items

			show_buffs 								= true,     --Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
			aggressive_reload_aced_buff				= true,
			ammo_efficiency_buff					= true,
			armor_break_invulnerable_buff			= true,
			berserker_buff							= true,
			biker_buff								= true,
			bloodthirst_basic_buff					= false,
			bloodthirst_aced_buff					= true,
			bullet_storm_buff						= true,
			close_contact_buff						= true,
			combat_medic_buff						= true,
			combat_medic_passive_buff				= false,
			desperado_buff							= true,
			die_hard_buff							= false,
			dire_need_buff							= true,
			grinder_buff							= true,
			hostage_situation_buff					= false,
			hostage_taker_buff						= false,
			inspire_buff							= true,
			lock_n_load_buff						= true,
			melee_stack_damage_buff					= false,
			maniac_buff								= false,
			messiah_buff							= true,
			muscle_regen_buff						= false,
			overdog_buff							= false,
			overkill_buff							= false,
			painkiller_buff							= false,
			partner_in_crime_buff					= false,
			running_from_death_buff					= true,
			quick_fix_buff							= false,
			second_wind_buff						= true,
			sixth_sense_buff						= true,
			swan_song_buff							= false,
			tooth_and_claw_buff						= true,
			trigger_happy_buff						= false,
			underdog_buff							= false,
			unseen_strike_buff						= true,
			up_you_go_buff							= false,
			uppers_buff								= true,
			yakuza_buff								= false,
			anarchist_armor_recovery_debuff			= true,
			ammo_give_out_debuff					= true,
			armor_break_invulnerable_debuff			= false,
			bullseye_debuff							= true,
			grinder_debuff							= false,
			inspire_debuff							= true,
			inspire_revive_debuff					= true,
			life_drain_debuff						= true,
			medical_supplies_debuff					= true,
			sociopath_debuff						= true,
			unseen_strike_debuff					= false,
			uppers_debuff							= false,
			armorer_teambuff						= true,
			bulletproof_teambuff					= true,
			crew_chief_teambuff						= true,
			forced_friendship_teambuff				= true,
			damage_increase_compbuff				= true,
			damage_reduction_compbuff				= true,
			melee_damage_increase_compbuff			= true,
		  --CustomWaypoints	
			waypoints_show_ammo_bag 				= true,
			waypoints_show_doc_bag 					= true,
			waypoints_show_first_aid_kit			= false,
			waypoints_show_body_bag 				= true,
			waypoints_show_grenade_crate 			= true,
			waypoints_show_sentries 				= false,
			waypoints_show_ecms						= false,
			waypoints_show_timers 					= false,
			waypoints_show_minions					= true,
			waypoints_show_loot						= true,
			waypoints_show_pager					= false,
			waypoints_show_special_equipment		= false,
		  --Interaction
			LOCK_MODE 								= 3,			--Disabled (1, Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time (2), or current interaction time(3)
			MIN_TIMER_DURATION 						= 5, 			--Min interaction duration (in seconds) for the toggle behavior to activate
			EQUIPMENT_PRESS_INTERRUPT 				= true, 		--Use the equipment key ('G') to toggle off active interactions
			SHOW_LOCK_INDICATOR						= true,
			SHOW_CIRCLE								= true,
			CIRCLE_SCALE							= 0.8,
			TEXT_SCALE								= 0.8,
			SHOW_INTERRUPT_HINT						= true,
			SHOW_TIME_REMAINING 					= true,			--Show remaining Time in the Interaction-Circle
			GRADIENT_COLOR 							= "light_green",--Color, which the timer reaches on completition
			SHOW_RELOAD								= false,
			SHOW_MELEE								= false,
			SUPRESS_NADES_STEALTH					= true,
			HOLD2PICK								= true,
		  --Laser-Colors		
			laser_autoon							= true,
			use_weaponlasers 						= true,
		    laser_light 							= 10,			--Multiplier for laser dot
			laser_glow 								= 5,			--Divider for laser beam
			laser_player 							= "light_blue",	--Player laser color id
			laser_player_alpha 						= 0.3,			--Player laser alpha
			laser_player_sentry						= "light_blue",	--Player sentry laser color id
			laser_player_sentry_alpha 				= 0.1,			--Player sentry laser alpha
			laser_teammates 						= "light_blue",	--Teammates laser color id
			laser_teammates_alpha 					= 0.15,			--Teammates laser alpha
			laser_teammates_sentry 					= "light_blue",	--Teammates sentry laser color id
			laser_teammates_sentry_alpha 			= 0.1,			--Teammates sentry laser alpha
			laser_sniper 							= "red",		--Sniper laser color id
			laser_sniper_alpha 						= 0.5,			--Sniper laser alpha
			laser_turret_active 					= "red",		--Active turret laser color id
			laser_turret_reloading 					= "yellow",		--Reloading turret laser color id
			laser_turret_jammed 					= "green",		--Jammed turret laser color id
			laser_turret_alpha 						= 0.15,			--Turret laser alpha
			flashlight_angle 						= 100,			--Flashlight angle
			flashlight_range 						= 20,			--Flashlight range (in m)
			flashlight_mult							= 2,
			flashlight_color						= "white",
			show_angeled_sight						= true,
		  --Equipment Tweaks
			senty_auto_ap 							= true,
			ecm_feedback_disabled_stealth			= true,
			
			show_advanced_assault					= true,
			assault_banner_position					= 2,			-- left (1), center (2) or right (3)
			enable_burstmode						= true,
			
			replace_weapon_names 					= true,
			inventory_tab_names						= true,
			inventory_names							= true,
			show_mini_icons							= true,
			skill_names								= true,	
			
			use_fed_inv								= true
		}
	end
	
	function WolfHUD:print_log(text, msg_type)
		if msg_type and self.LOG_MODE[msg_type] then
			local function log_table(userdata)
				local text = ""
				for id, data in pairs(userdata) do
					if type(data) == "table" then
						log( id .. " = {")
						log_table(data)
						log("}")
					elseif type(data) ~= "function" then
						log( id .. " = " .. tostring(data) .. "")
					else
						log( "function " .. id .. "(...)")
					end
				end
			end
			if type(text) == "table" or type(text) == "userdata" then
				log_table(text)
				return
			elseif type(text) == "function" then
				text = "Error, cannot log function... " 
			end
			log("[WolfHUD] " .. tostring(text))
		end
	end
	
	function WolfHUD:Load()
		local corrupt = false
		local file = io.open(self.settings_path, "r")
		if file then
			for k, v in pairs(json.decode(file:read("*all"))) do
				if type(v) == type(self.settings[k]) then
					self.settings[k] = v
				else
					corrupt = true
					self:print_log("Error loading setting: " .. tostring(k) .. " (Wrong type)", "error")
				end
			end
			file:close()
		else
			self:print_log("Error while loading, settings file could not be opened (" .. self.settings_path .. ")", "error")
		end
		if corrupt then 
			self:Save()
			self:print_log("Invalid settings stored in savefile, resaving...", "warning")
		end
	end

	function WolfHUD:Save()
		local file = io.open(self.settings_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		else
			self:print_log("Error while saving, settings file could not be opened (" .. self.settings_path .. ")", "error")
		end
	end
	
	function WolfHUD:AskOverride(data, setting, notif_id)
		local menu_options = {
		[1] = {
			text = managers.localization:text("dialog_yes"),
			callback = function(self, item)
				WolfHUD.settings[setting] = true
				WolfHUD:Save()
				WolfHUD:createOverrides(data)
				if notif_id and NotificationsManager:NotificationExists( notif_id ) then
					NotificationsManager:UpdateNotification( notif_id, 
						managers.localization:text("woldhud_notification_restart_override_title", { NAME = data.display_name }), 
						managers.localization:text("woldhud_notification_restart_override_desc"), 20, function() end	
					)
				end
			end,
		},
		[2] = {
			text = managers.localization:text("dialog_no"),
			callback = function(self, item)
				WolfHUD.settings[setting] = false
				WolfHUD:Save()
				WolfHUD:createOverrideNotification(data, setting)
			end,
		},
		[3] = {
			text = managers.localization:text("wolfhud_dialog_remind_later"),
			is_cancel_button = true,
		},
}
		return QuickMenu:new( managers.localization:text("wolfhud_dialog_install_title", { NAME = data["display_name"] }), 
								string.format("%s\n\n%s", managers.localization:text(string.format("wolfhud_dialog_install_%s_desc", data["identifier"])), managers.localization:text("wolfhud_dialog_install_desc", { NAME = data["display_name"]})) ,
								menu_options, true )
	end
	
	function WolfHUD:checkOverrides()
		local updates = {}
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "WolfHUD" then
				self.version = info["version"] or self.version
				updates = info["updates"] or updates
			end
		end
		if SystemInfo:platform() ~= Idstring("WIN32") then return end	--Abort here while Linux doesn't support 'mod_overrides'
		for k, v in pairs(updates) do
			if type(v["revision"]) == "string" and not io.file_is_readable( v["revision"] ) then
				local setting = "use_" .. v["identifier"]
				if WolfHUD:getSetting(setting, "boolean") then
					WolfHUD:AskOverride(v, setting)
				elseif WolfHUD.settings[setting] == nil then
					WolfHUD:createOverrides(v)
				else
					WolfHUD:createOverrideNotification(v, setting)
				end
			end
		end
	end
	
	function WolfHUD:createOverrides(data)
		self:print_log("Creating Dummy for: " .. data["display_name"], "info")
		if not file.DirectoryExists("./" .. data["install_dir"] .. data["install_folder"]) then
			if SystemInfo:platform() == Idstring("WIN32") then  --Windows
				os.execute('cmd /c mkdir "./' .. data["install_dir"] .. data["install_folder"] .. '"')
			else --Linux
				WolfHUD:print_log("[WolfHUD] mod_override folder '" .. data["install_folder"] .. "' is missing!", "warning")
			end
		end
		local file = io.open(data["revision"], "w+")
		if file then
			file:write("0")
			file:close()
		end
	end
	
	function WolfHUD:createOverrideNotification(data, setting)
		local id = string.format("wolfhud_disabled_override_%s", data.identifier)
		if not NotificationsManager:NotificationExists( id ) then
				NotificationsManager:AddNotification( id, 
				managers.localization:text("woldhud_notification_disabled_override_title", { NAME = data.display_name }), 
				managers.localization:text("woldhud_notification_disabled_override_desc"), 
				20, function() 
					WolfHUD:AskOverride(data, setting, id)
				end
			)
		end
	end
	
	function WolfHUD:getSetting(id, val_type, default)
		local value = self.settings[id]
		if value ~= nil and (not val_type or type(value) == val_type or val_type == "color" and type(value) == "string") then
			local value = self.settings[id]
			if val_type == "color" then
				local id = self:getColorID(value)
				if id then
					return Color(self.color_table[id].color)
				end
			else
				return value
			end
		else
			self:print_log("Requested setting doesn't exists!  (id='" .. id .. "', type='" .. tostring(val_type) .. "') ", "error")
			if default == nil then
				if val_type == "number" then -- Try to prevent crash by giving default value
					default = 1
				elseif val_type == "boolean" then 
					default = false
				elseif val_type == "string" then 
					default = ""
				elseif val_type == "color" then
					default = Color.white
				end
			end			
			return default
		end
	end
	
	
	function WolfHUD:populate_colors()
		if io.file_is_readable(self.save_path .. self.colors_file) then
			local file = io.open(self.save_path .. self.colors_file, "r")
			if file then
				local colors = json.decode(file:read("*all"))
				for k, v in ipairs(colors) do
					if not self:getColorID(v.name) then
						table.insert(self.color_table, v)
					end
				end
				file:close()
			end
		end
		local file = io.open(self.save_path .. self.colors_file, "w+")
		if file then
			file:write(json.encode(self.color_table))
			file:close()
		end
	end
	
	function WolfHUD:getColorID(name)
		if type(name) == "string" then
			for i, data in ipairs(WolfHUD.color_table) do
				if name == data.name then
					return i
				end
			end
		end
	end
	
	WolfHUD:populate_colors()
	WolfHUD:Reset()
	WolfHUD:Load()
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if WolfHUD.hook_files[requiredScript] then
		for __, file in ipairs(WolfHUD.hook_files[requiredScript]) do
			dofile( WolfHUD.mod_path .. "lua/" .. file )
		end
	end
end

if MenuNodeMainGui then
	Hooks:PostHook( MenuNodeMainGui , "_setup_item_rows" , "MenuNodeMainGuiPostSetupItemRows_WolfHUD" , function( self )
		WolfHUD:checkOverrides()
		if alive(self._version_string) then
			self._version_string:set_text("Payday 2 v" .. Application:version() .. " | WolfHUD v" .. WolfHUD.version)
		end
	end)
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_WolfHUD", function(loc)
	local chinese = false
	for k, v in pairs(LuaModManager.Mods) do
		local info = v.definition
		if info["name"] == "ChnMod" then
			chinese = true
			break
		end
	end
	if chinese then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/chinese.json")
	elseif _G.PD2KR then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/korean.json")
	else
		for _, filename in pairs(file.GetFiles(WolfHUD.mod_path .. "loc/")) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(WolfHUD.mod_path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(WolfHUD.mod_path .. "loc/english.json", false)
	
	if WolfHUD:getSetting("replace_weapon_names", "boolean") then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/RealWeaponNames.json")
	end
	
	if WolfHUD:getSetting("skip_blackscreen", "boolean") then
		loc:add_localized_strings({
			["hud_skip_blackscreen"] = ""
		})
	end
	
	local loot_int_table = {
		["debug_interact_money_wrap_take_money"] = "",
		["debug_interact_money_printed_take_money"] = "",
		["debug_interact_gold_pile_take_money"] = "",
		["hud_int_hold_grab_the_bag"] = "",
		["hud_int_hold_grab_the_painting"] = "",
		["hud_int_hold_take_painting"] = "", 
		["hud_int_hold_take_server"] = "", 
		["hud_int_hold_steal_meth"] = "", 
		["hud_int_hold_take_reaktor"] = "", 
		["hud_int_hold_take_cocaine"] = "", 
		["hud_int_take_weapons"] = "",
		["hud_int_hold_take_artifact"] = "", 
		["hud_int_take_artifact"] = "",
		["hud_int_hold_take_jewelry"] = "", 
		["hud_int_hold_take_meth"] = "", 
		["hud_int_hold_pack_shells"] = "", 
		["hud_int_hold_bag_sa_armor"] = "", 
		["hud_int_hold_take_pure_cocaine"] = "", 
		["hud_int_hold_take_sandwich"] = "", 
		["hud_int_hold_take_evidence"] = "", 
		["hud_int_hold_take_warhead"] = "", 
		["hud_int_hold_take_safe"] = "", 
		["hud_int_hold_take_pig"] = "", 
		["hud_int_hold_take_prototype"] = "", 
		["hud_int_hold_take_counterfeit_money"] = "", 
		["hud_int_hold_bag_present"] = "", 
		["hud_int_hold_grab_goat"] = "",
		["hud_action_disassemble_cro_loot"] = ""
	}
	for string_id, __ in pairs(loot_int_table) do
		loot_int_table[string_id] = loc:text(string_id, {BTN_INTERACT = "$BTN_INTERACT"}) .. "$VALUE"
	end
	loc:add_localized_strings(loot_int_table)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_WolfHUD", function(menu_manager)
	
	-- Define Callback methods here
	MenuCallbackHandler.WolfHUD_Save = function(self, item)
		WolfHUD:Save()
	end
	
	MenuCallbackHandler.WolfHUD_Reset = function(self, item)
		local menu_title = managers.localization:text("wolfhud_reset_options_title")
		local menu_message = managers.localization:text("wolfhud_reset_options_confirm")
		local menu_options = {
			[1] = {
				text = managers.localization:text("dialog_yes"),
				callback = function(self, item)
					WolfHUD:Reset()
					for __, menu_id in ipairs(WolfHUD.menu_ids) do
						local menu = MenuHelper:GetMenu(menu_id)
						if menu then
							for __, menu_item in ipairs(menu._items) do
								if menu_item.set_value then
									local item_id = menu_item:parameters().name
									local value = WolfHUD:getSetting(tostring(item_id))
									if value ~= nil then
										if menu_item._type == "toggle" then
											value = (value and "on" or "off")
										end
										menu_item:set_value(value)
										for __, clbk in pairs( menu_item:parameters().callback ) do
											clbk(menu_item)
										end
									end
								end
							end
						end
					end
					managers.viewport:resolution_changed()
				end,
			},
			[2] = {
				text = managers.localization:text("dialog_no"),
				is_cancel_button = true,
			},
		}
		QuickMenu:new( menu_title, menu_message, menu_options, true )
	end
	
	MenuCallbackHandler.WolfHUD_FocusChanged = function(node, focus)
		if managers.menu:active_menu().name ~= "menu_main" then
			return
		end
	end
	
	MenuCallbackHandler.WolfHUD_GeneralHUD_Focus = function(node, focus)
		if managers.menu:active_menu().name ~= "menu_main" then
			if managers.hud then
				managers.hud:force_unit_health_visible( focus )
				if managers.hud._hud_driving then
					if focus then
						managers.hud._hud_driving:start()	
					else
						managers.hud._hud_driving:stop()
					end
				end
			end
		end
	end
	
	MenuCallbackHandler.WolfHUD_TabStats_Focus = function(node, focus)
		if managers.menu:active_menu().name ~= "menu_main" then
			if managers.hud and managers.hud._hud_statsscreen then
				if focus then
					managers.hud:show_stats_screen()
				else
					managers.hud:hide_stats_screen()
				end
			end
		end
	end
	
	MenuCallbackHandler.clbk_change_setting = function(self, item)
		local value
		if item._type == "toggle" then
			value = (item:value() == "on")
		else
			value = item:value()
		end
		local name = item:parameters().name
		if name then
			WolfHUD.settings[name] = value
		end
	end
	
	MenuCallbackHandler.clbk_change_hudlist_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and HUDListManager then managers.hud:change_list_setting(tostring(name), WolfHUD:getSetting(name, "color", WolfHUD:getSetting(name))) end
	end
	
	MenuCallbackHandler.clbk_change_hudlist_buff_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and HUDListManager then managers.hud:change_bufflist_setting(tostring(name), WolfHUD:getSetting(name, "boolean")) end
	end
	
	MenuCallbackHandler.clbk_change_customhud_setting = function(self, item)
		self:clbk_change_setting(item)
		if managers.hud and HUDManager.CUSTOM_TEAMMATE_PANELS and managers.hud.change_hud_setting then 
			local name = item:parameters().name
			local setting = {}
			for word in string.gmatch(name, "[%a%d]+") do
				table.insert(setting, word)
			end
			local type = table.remove(setting, 1)
			managers.hud:change_hud_setting(type, setting, WolfHUD:getSetting(name, "color", WolfHUD:getSetting(name))) 
		end
	end
	
	MenuCallbackHandler.clbk_change_tabstats_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and managers.hud.change_tabstats_setting then managers.hud:change_tabstats_setting(tostring(name), WolfHUD:getSetting(name)) end
	end
	
	MenuCallbackHandler.clbk_change_drivinghud_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and managers.hud.change_drivinghud_setting then managers.hud:change_drivinghud_setting(tostring(name), WolfHUD:getSetting(name, "color", WolfHUD:getSetting(name))) end
	end
	
	MenuCallbackHandler.clbk_change_vanillahud_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and managers.hud._change_vanillahud_setting then managers.hud:_change_vanillahud_setting(tostring(name)) end
	end
		
	WolfHUD:Load()
	
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/options.json", 					WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets.json", 					WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets_lasers.json", 			WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/equipment.json", 					WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/interaction.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_tabstats.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudwaypoints.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo.json", 					WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_mastermind.json", 	WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_enforcer.json", 		WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_technician.json", 	WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_ghost.json", 		WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_fugitive.json", 		WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_buff_perkdecks.json", 	WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_right.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudinfo_left.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud.json", 						WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_teampanels.json", 			WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_playerpanel.json", 			WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_chat.json", 					WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_suspicion.json", 				WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_killcounter.json", 			WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damageindicator.json", 		WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damagepopup.json", 			WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_enemyhealthbar.json", 		WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_drivinghud.json", 			WolfHUD, WolfHUD.settings)
	
	Hooks:Add( "MenuManagerPostInitialize", "MenuManagerPostInitialize_WolfHUD", function( menu_manager )
		for __, menu_id in ipairs(WolfHUD.menu_ids) do
			local menu = MenuHelper:GetMenu(menu_id)
			if menu then
				for __, menu_item in ipairs(menu._items) do
					if menu_item and menu_item._type == "multi_choice" and #menu_item._options <= 1 then
						menu_item:clear_options()
						local add_rainbow = #menu_item._options > 0
						for k, v in ipairs(WolfHUD.color_table) do
							if add_rainbow or v.name ~= "rainbow" then
								local color_name = managers.localization:text("wolfhud_colors_" .. v.name)
								color_name = not color_name:lower():find("error") and color_name or string.upper(v.name)
								local params = {
									_meta = "option",
									text_id = color_name,
									value = v.name,
									localize = false,
									color = Color(v.color),
								}
								if v.name == "rainbow" then
									local rainbow_colors = { Color('FE0E31'), Color('FB9413'), Color('F7F90F'), Color('3BC529'), Color('00FFFF'), Color('475DE7'), Color('B444E4'), Color('F46FE6') }
									params.color = rainbow_colors[1]
									for i = 0, color_name:len() do
										params["color" .. i] = rainbow_colors[(i % #rainbow_colors) + 1]
										params["color_start" .. i] = i
										params["color_stop" .. i] = i + 1
									end
								end
								
								menu_item:add_option(CoreMenuItemOption.ItemOption:new(params))
							end
						end
						menu_item:_show_options(nil)
						local item_id = menu_item:parameters().name
						local value = WolfHUD:getSetting(tostring(item_id), "string")
						menu_item:set_value(value)
						for __, clbk in pairs( menu_item:parameters().callback ) do
							clbk(menu_item)
						end
					end
				end
			end
		end
	end)
end)

if MenuItemMultiChoice then
	Hooks:PostHook( MenuItemMultiChoice , "setup_gui" , "MenuItemMultiChoicePostSetupGui_WolfHUD" , function( self, node, row_item )
		if self:selected_option():parameters().color and row_item.choice_text then
			row_item.choice_text:set_blend_mode("normal")
		end
	end)
end