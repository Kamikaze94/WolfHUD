if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath
	WolfHUD.settings_path = WolfHUD.save_path .. "WolfHUD_v2.json"
	WolfHUD.tweak_file = "WolfHUDTweakData.lua"
	WolfHUD.LOG_MODE = { error = true, warning = true, info = false }		-- error, info, warning or all
	WolfHUD.version = nil

	WolfHUD.settings = {}
	WolfHUD.tweak_data = {}

	WolfHUD.hook_files = WolfHUD.hook_files or {
		["lib/setups/setup"] 										= { "GameInfoManager.lua", "WaypointsManager.lua", "EnhancedCrewLoadout.lua" },
		["lib/managers/menumanager"] 								= { "PrePlanManager.lua", "MenuTweaks.lua" },
		["lib/managers/menumanagerdialogs"] 						= { "MenuTweaks.lua" },
		["lib/managers/chatmanager"] 								= { "MenuTweaks.lua" },
		["lib/managers/localizationmanager"] 						= { "AdvAssault.lua" },
		["lib/managers/experiencemanager"] 							= { "Scripts.lua" },
		["lib/managers/moneymanager"] 								= { "Scripts.lua" },
		["lib/managers/crimespreemanager"]							= { "TabStats.lua" },
		["lib/managers/hudmanager"] 								= { "EnemyHealthbar.lua", "TabStats.lua", "CustomWaypoints.lua" },
		["lib/managers/hudmanagerpd2"] 								= { "CustomHUD.lua", "HUDChat.lua", "HUDList.lua", "KillCounter.lua", "DownCounter.lua", "DrivingHUD.lua", "DamageIndicator.lua", "WaypointsManager.lua", "Interaction.lua", "Scripts.lua", "BurstFire.lua", "AdvAssault.lua" },
		["lib/managers/statisticsmanager"] 							= { "KillCounter.lua", "TabStats.lua" },
		["lib/managers/playermanager"] 								= { "GameInfoManager.lua" },
		["lib/managers/preplanningmanager"] 						= { "PrePlanManager.lua" },
		["lib/managers/hud/huddriving"] 							= { "DrivingHUD.lua" },
		["lib/managers/hud/hudteammate"] 							= { "CustomHUD.lua", "KillCounter.lua", "DownCounter.lua", "BurstFire.lua" },
		["lib/managers/hud/hudtemp"] 								= { "CustomHUD.lua" },
		["lib/managers/hud/hudassaultcorner"] 						= { "HUDList.lua", "AdvAssault.lua" },
		["lib/managers/hud/hudobjectives"] 							= { "EnhancedObjective.lua" },
		["lib/managers/hud/hudheisttimer"] 							= { "EnhancedObjective.lua" },
		["lib/managers/hud/hudchat"] 								= { "HUDChat.lua" },
		["lib/managers/hud/hudstatsscreen"] 						= { "TabStats.lua", "EnhancedCrewLoadout.lua" },
		["lib/managers/hud/hudinteraction"] 						= { "Interaction.lua" },
		["lib/managers/hud/hudsuspicion"] 							= { "NumbericSuspicion.lua" },
		["lib/managers/hud/hudhitdirection"] 						= { "DamageIndicator.lua" },
		["lib/managers/enemymanager"] 								= { "GameInfoManager.lua" },
		["lib/managers/group_ai_states/groupaistatebase"] 			= { "GameInfoManager.lua", "PacifiedCivs.lua" },
		["lib/managers/missionassetsmanager"] 						= { "BuyAllAsset.lua" },
		["lib/managers/menu/blackmarketgui"] 						= { "MenuTweaks.lua" },
		["lib/managers/menu/contractboxgui"]						= { "MenuTweaks.lua", "EnhancedCrewLoadout.lua" },
		["lib/managers/menu/crimespreecontractboxgui"] 				= { "EnhancedCrewLoadout.lua" },
		["lib/managers/menu/crimespreedetailsmenucomponent"]		= { "EnhancedCrewLoadout.lua" },
		["lib/managers/menu/missionbriefinggui"]					= { "BuyAllAsset.lua", "EnhancedCrewLoadout.lua" },
		["lib/managers/menu/stageendscreengui"] 					= { "MenuTweaks.lua", "TabStats.lua" },
		["lib/managers/menu/lootdropscreengui"] 					= { "MenuTweaks.lua" },
		["lib/managers/menu/skilltreeguinew"] 						= { "MenuTweaks.lua" },
		["lib/managers/menu/renderers/menunodeskillswitchgui"] 		= { "MenuTweaks.lua" },
		["lib/managers/objectinteractionmanager"] 					= { "GameInfoManager.lua", "HUDList.lua", "Interaction.lua" },
		["lib/managers/player/smokescreeneffect"] 					= { "GameInfoManager.lua" },
		["lib/modifiers/boosts/gagemodifiermeleeinvincibility"] 	= { "GameInfoManager.lua" },
		["lib/modifiers/boosts/gagemodifierlifesteal"] 				= { "GameInfoManager.lua" },
		["lib/network/handlers/unitnetworkhandler"] 				= { "GameInfoManager.lua", "NetworkHandler.lua", "DownCounter.lua" },
		["lib/units/props/timergui"] 								= { "GameInfoManager.lua" },
		["lib/units/props/digitalgui"] 								= { "GameInfoManager.lua" },
		["lib/units/props/drill"] 									= { "GameInfoManager.lua" },
		["lib/units/props/securitylockgui"] 						= { "GameInfoManager.lua" },
		["lib/units/civilians/civiliandamage"] 						= { "DamagePopup.lua", "TabStats.lua" },
		["lib/units/enemies/cop/copdamage"] 						= { "GameInfoManager.lua", "KillCounter.lua", "DamagePopup.lua", "TabStats.lua" },
		["lib/units/cameras/fpcameraplayerbase"] 					= { "WeaponGadgets.lua" },
		["lib/units/equipment/ammo_bag/ammobagbase"] 				= { "GameInfoManager.lua" },
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] 		= { "GameInfoManager.lua" },
		["lib/units/equipment/doctor_bag/doctorbagbase"] 			= { "DownCounter.lua", "GameInfoManager.lua" },
		["lib/units/equipment/first_aid_kit/firstaidkitbase"] 		= { "GameInfoManager.lua" },
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] 			= { "GameInfoManager.lua", "EquipmentTweaks.lua" },
		["lib/units/equipment/grenade_crate/grenadecratebase"] 		= { "GameInfoManager.lua" },
		["lib/units/equipment/sentry_gun/sentrygunbase"] 			= { "GameInfoManager.lua", "KillCounter.lua" },
		["lib/units/equipment/sentry_gun/sentrygundamage"] 			= { "GameInfoManager.lua" },
		["lib/units/interactions/interactionext"] 					= { "GameInfoManager.lua", "Interaction.lua", "EquipmentTweaks.lua" },
		["lib/units/weapons/akimboweaponbase"] 						= { "BurstFire.lua" },
		["lib/units/weapons/sentrygunweapon"] 						= { "GameInfoManager.lua", "EquipmentTweaks.lua", "WeaponGadgets.lua" },
		["lib/units/weapons/weapongadgetbase"]						= { "WeaponGadgets.lua" },
		["lib/units/weapons/weaponlaser"] 							= { "WeaponGadgets.lua" },
		["lib/units/weapons/weaponflashlight"] 						= { "WeaponGadgets.lua" },
		["lib/units/weapons/raycastweaponbase"] 					= { "Scripts.lua", "WeaponGadgets.lua" },
		["lib/units/weapons/newraycastweaponbase"] 					= { "WeaponGadgets.lua", "BurstFire.lua" },
		["lib/units/weapons/npcraycastweaponbase"]					= { "WeaponGadgets.lua" },
		["lib/units/weapons/newnpcraycastweaponbase"]				= { "WeaponGadgets.lua" },
		["lib/units/props/securitycamera"] 							= { "GameInfoManager.lua" },
		["lib/units/beings/player/playerdamage"] 					= { "GameInfoManager.lua", "DamageIndicator.lua" },
		["lib/units/beings/player/playermovement"] 					= { "GameInfoManager.lua" },
		["lib/units/beings/player/huskplayermovement"] 				= { "DownCounter.lua" },
		["lib/units/beings/player/states/playercivilian"] 			= { "Interaction.lua" },
		["lib/units/beings/player/states/playerdriving"]			= { "Interaction.lua" },
		["lib/units/beings/player/states/playerstandard"] 			= { "GameInfoManager.lua", "EnemyHealthbar.lua", "Interaction.lua", "BurstFire.lua", "WeaponGadgets.lua" },
		["lib/units/beings/player/states/playermaskoff"] 			= { "GameInfoManager.lua" },
		["lib/units/beings/player/states/playerbleedout"] 			= { "DownCounter.lua" },
		["lib/units/vehicles/vehicledamage"] 						= { "DamageIndicator.lua" },
		["lib/units/vehicles/vehicledrivingext"] 					= { "CustomWaypoints.lua" },
		["lib/utils/temporarypropertymanager"] 						= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionbloodthirstbase"] 	= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionexperthandling"] 	= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionshockandawe"] 		= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractiondireneed"] 			= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionunseenstrike"] 		= { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractiontriggerhappy"] 		= { "GameInfoManager.lua" },
		["lib/states/ingamedriving"] 								= { "DrivingHUD.lua" },
		["lib/states/ingamearrested"]								= { "EnemyHealthbar.lua" },
		["lib/states/ingamewaitingforplayers"] 						= { "MenuTweaks.lua" },
		["lib/tweak_data/tweakdata"] 								= { "MenuTweaks.lua" },
		["lib/tweak_data/guitweakdata"] 							= { "MenuTweaks.lua" },
		["lib/tweak_data/timespeedeffecttweakdata"] 				= { "Scripts.lua" },
		["core/lib/managers/menu/items/coremenuitemslider"] 		= { "MenuTweaks.lua" },
		["core/lib/managers/subtitle/coresubtitlepresenter"] 		= { "EnhancedObjective.lua" },

		--Utils and custom classes...
		["lib/entry"]												= { "Utils/QuickInputMenu.lua" },
		["lib/managers/systemmenumanager"] 							= { "Utils/InputDialog.lua" },
		["lib/managers/dialogs/specializationdialog"] 				= { "Utils/InputDialog.lua" },
		["lib/managers/menu/specializationboxgui"] 					= { "Utils/InputDialog.lua" },
	}

	function WolfHUD:Reset()
		WolfHUD.settings = {
			CustomHUD = {
				ENABLED 							= true,
				PLAYER = {
					POSITION						= 2,		-- left (1), center (2) or right (3)
					SCALE 							= 1,		--Size of local Player HUD Panel
					OPACITY							= 0.85,
					NAME							= false,
					RANK							= false,
					TRUNCATE_TAGS					= false,
					CHARACTER						= false,
					STATUS							= true,
					EQUIPMENT						= true,
					SPECIAL_EQUIPMENT				= true,
					SPECIAL_EQUIPMENT_ROWS			= 3,
					CALLSIGN						= false,
					STAMINA							= true,
					DOWNCOUNTER						= true,
					CARRY							= true,
					CONDITION_ICON_COLOR			= "white",
					WEAPON = {
						ICON						= 4,
						NAME						= 1,
						AMMO						= 4,
						FIREMODE					= 2,
					},
					KILLCOUNTER = {
						HIDE						= false,
						SHOW_SPECIAL_KILLS 			= true,
						SHOW_HEADSHOT_KILLS			= true,
						COLOR						= "yellow",
					},
					SHOW_ACCURACY					= true,
				},
				TEAMMATE = {
					POSITION						= 1,		-- left (1), center (2) or right (3)
					SCALE 							= 0.8,		--Size of Teammates/AI's HUD Panels
					OPACITY							= 0.85,
					NAME							= true,
					RANK							= true,
					TRUNCATE_TAGS					= false,
					CHARACTER						= false,
					LATENCY							= true,
					STATUS							= true,
					EQUIPMENT						= true,
					SPECIAL_EQUIPMENT				= true,
					SPECIAL_EQUIPMENT_ROWS			= 3,
					CALLSIGN						= false,
					DOWNCOUNTER						= true,
					CARRY							= true,
					CONDITION_ICON_COLOR			= "white",
					BUILD = {
						HIDE						= false,
						DURATION					= 15,
					},
					AI_COLOR = {
						USE							= false,
						COLOR						= "white",
					},
					WEAPON = {
						ICON						= 4,
						NAME						= 1,
						AMMO						= 4,
						FIREMODE					= 1,
					},
					INTERACTION = {
						HIDE					= false,		-- Show Interaction
						NUMBER					= true,
						TEXT					= true,
						MIN_DURATION			= 1,
					},
					KILLCOUNTER = {
						HIDE						= false,
						SHOW_SPECIAL_KILLS 			= true,
						SHOW_HEADSHOT_KILLS			= true,
						COLOR						= "yellow",
						SHOW_BOT_KILLS 				= true,
					},
				},
				USE_REAL_AMMO 						= true,
			},
			HUDChat = {
				CHAT_WAIT_TIME							= 10,		--Time before chat fades out, 0 = never
				LINE_HEIGHT								= 15,		--Chat font Size
				MAX_OUTPUT_LINES						= 8,		--Chat Output lines
				SPAM_FILTER								= true,		--Filter PocoHud and NGBTO Chat Spam messages.
			},
			EnemyHealthbar = {
				ENABLED 								= true,		--Show healthbars
				SHOW_CIVILIAN 							= false,	--Show Healthbars for Civilians and TeamAI
				SHOW_VEHICLE							= true,		--Show Healthbar for vehicles
				SHOW_POINTER		 					= false,	--Show pointer near the Healthbar, pointing at Healthbar owner
			},
			DamageIndicator = {
				ENABLED									= true,
				SIZE									= 150,
				DURATION								= 2,
				MAX_AMOUNT								= 10,
				SHIELD_COLOR							= "gray",
				HEALTH_COLOR							= "red",
				CRIT_COLOR								= "purple",
				VEHICLE_COLOR							= "yellow",
				FRIENDLY_FIRE_COLOR						= "orange",
			},
			DamagePopup = {
				DISPLAY_MODE							= 2,
				DURATION	 							= 3,
				SCALE									= 1,
				SKULL_SCALE								= 1.2,
				SKULL_ALIGN								= 1,			-- left (1) or right (2)
				COLOR									= "yellow",
				HEADSHOT_COLOR							= "red",
			},
			AssaultBanner = {
				POSITION								= 2,			-- left (1), center (2) or right (3)
				USE_ADV_ASSAULT							= true,
			},
			HUDSuspicion = {
				SCALE									= 0.8,
				SHOW_PERCENTAGE							= true,
				SHOW_PERCENTAGE_OUTLINE					= true,
				SHOW_BARS								= true,
				SHOW_PACIFIED_CIVILIANS					= true,
				REMOVE_ANSWERED_PAGER_CONTOUR 			= true,
			},
			DrivingHUD = {
				ENABLED									= true,		--Show DrivingHUD Panel
				SCALE									= 1,
				SHOW_VEHICLE 							= true,		--Show Vehicle and Teammate Mask Images
				SHOW_HEALTH								= true,
				SHOW_LOOT								= true,
				SHOW_PASSENGERS							= true,
				SHOW_GEAR								= true,
				SHOW_SPEED								= true,
				SHOW_RPM								= true,
				SPEED_IN_MPH 							= false,	--Display Speed in mph
			},
			TabStats = {
				ENABLED									= true,
				CLOCK_MODE								= 3,		-- 1 = disabled, 2 = 12h, 3 = 24h
				COLOR		 							= "rainbow",
				FONT_SIZE		 						= 18,
				SHOW_MASK								= true,
				SHOW_LOOT_NUMBERS						= true,
			},
			CrewLoadout = {
				REPLACE_IN_BRIEFING 					= true,
				SHOW_IN_LOBBY							= true,
				SHOW_IN_CS_LOBBY 						= true,
				SHOW_ON_STATS_PANEL						= true,
			},
			HUDList = {
				ENABLED	 								= true,
				right_list_scale						= 1,
				left_list_scale							= 1,
				buff_list_scale							= 1,
				list_color	 							= "white",		--Left and Right List font color
				list_color_bg	 						= "black",		--Left and Right List BG color
				civilian_color 							= "white", 		--EnemyCounter Civillian and Hostage icon color
				thug_color 								= "white",		--EnemyCounter Thug and Mobster icon color
				enemy_color 							= "white",		--EnemyCounter Cop and Specials icon color
				special_color 							= "white",
				LEFT_LIST = {
					show_timers 							= true,     --Drills, time locks, hacking etc.
					show_ammo_bags							= true,  	--Deployables (ammo)
					show_doc_bags							= true,  	--Deployables (doc bags)
					show_first_aid_kits						= false,	--Deployables (first_aid_kits)
					show_body_bags							= true,  	--Deployables (body bags)
					show_grenade_crates						= true,  	--Deployables (grenades)
					show_sentries 							= true,   	--Deployable sentries
					show_ecms 								= true,		--Active ECMs
					show_ecm_retrigger 						= true,  	--Countdown for players own ECM feedback retrigger delay
					show_minions 							= true,  	--Converted enemies, type and health
						show_own_minions_only				= false,	--Only show player-owned minions
					show_pagers 							= true,  	--Show currently active pagers
					show_tape_loop 							= true,  	--Show active tape loop duration
				},
				RIGHT_LIST = {
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
					SHOW_PICKUP_CATEGORIES = {
						mission_pickups 					= true,
						collectables 						= true,
						valuables 							= true,
					}

				},
				BUFF_LIST = {
					show_buffs 								= true,     --Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
					damage_increase							= true,
					damage_reduction						= true,
					melee_damage_increase					= true,
					MASTERMIND_BUFFS = {
						forced_friendship					= true,
						aggressive_reload_aced				= true,
						ammo_efficiency						= true,
						combat_medic						= true,
						combat_medic_passive				= false,
						hostage_taker						= false,
						inspire								= true,
						painkiller							= false,
						partner_in_crime					= false,
						quick_fix							= false,
						uppers								= true,
						inspire_debuff						= true,
						inspire_revive_debuff				= true,
					},
					ENFORCER_BUFFS = {
						bulletproof							= true,
						bullet_storm						= true,
						die_hard							= false,
						overkill							= false,
						underdog							= false,
						bullseye_debuff						= true,
					},
					TECHNICIAN_BUFFS = {
						lock_n_load							= true,
					},
					GHOST_BUFFS = {
						dire_need							= true,
						second_wind							= true,
						sixth_sense							= true,
						unseen_strike						= true,
					},
					FUGITIVE_BUFFS = {
						berserker							= true,
						bloodthirst_basic					= false,
						bloodthirst_aced					= true,
						desperado							= true,
						frenzy			 					= false,
						messiah								= true,
						running_from_death					= true,
						swan_song							= false,
						trigger_happy						= false,
						up_you_go							= false,
					},
					PERK_BUFFS = {
						armor_break_invulnerable			= true,
						anarchist_armor_recovery_debuff		= true,
						armorer								= true,
						biker								= true,
						crew_chief							= true,
						hostage_situation					= false,
						ammo_give_out_debuff				= true,
						medical_supplies_debuff				= true,
						grinder								= true,
						chico_injector						= false,
						tooth_and_claw						= true,
						close_contact						= true,
						life_drain_debuff					= true,
						melee_stack_damage					= false,
						overdog								= false,
						maniac								= false,
						muscle_regen						= false,
						sicario_dodge 						= true,
						smoke_screen_grenade 				= true,
						sociopath_debuff					= true,
						yakuza								= false,
					},
					GAGE_BOOSTS = {
						invulnerable_buff					= true,
						life_steal_debuff					= true,
					},
				},
			},
			CustomWaypoints = {
				WAYPOINTS_COLOR							= "white",
				SHOW_AMMO_BAG 							= true,
				SHOW_DOC_BAG		 					= true,
				SHOW_FIRST_AID_KIT						= false,
				SHOW_BODY_BAG			 				= true,
				SHOW_GRENADE_CRATE			 			= true,
				SHOW_SENTRIES			 				= false,
				SHOW_ECMS								= false,
				SHOW_TIMERS			 					= false,
				SHOW_MINIONS							= true,
				SHOW_PAGER								= false,
				SHOW_SPECIAL_EQUIPMENT					= false,
				LOOT = {
					SHOW								= true,
					ICON								= true,
					OFFSET								= 15,
					BAGGED_OFFSET						= 30,
					ANGLE								= 25,
				},
			},
			INTERACTION = {
				LOCK_MODE 								= 3,			--Disabled (1, Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time (2), or current interaction time(3)
				MIN_TIMER_DURATION 						= 5, 			--Min interaction duration (in seconds) for the toggle behavior to activate
				EQUIPMENT_PRESS_INTERRUPT 				= true, 		--Use the equipment key ('G') to toggle off active interactions
				SHOW_LOCK_INDICATOR						= true,
				SHOW_CIRCLE								= true,
				CIRCLE_SCALE							= 0.8,
				TEXT_SCALE								= 0.8,
				SHOW_INTERRUPT_HINT						= true,
				SHOW_TIME_REMAINING 					= true,			--Show remaining Time in the Interaction-Circle
				SHOW_TIME_REMAINING_OUTLINE				= false,		--Show black outline around remaining Time text
				GRADIENT_COLOR_START					= "white",		--Color, which the timer starts with
				GRADIENT_COLOR							= "light_green",--Color, which the timer reaches on completition
				TIMER_SCALE								= 1,			--Timer scale (also takes CIRCLE_SCALE into account)
				SHOW_RELOAD								= false,
				SHOW_MELEE								= false,
				SUPRESS_NADES_STEALTH					= true,
				HOLD2PICK								= true,
			},
			GADGETS = {
				LASER_AUTO_ON 							= true,
				laser = {
					player = {
						beam 							= { r = 0, g = 1, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					team = {
						beam 							= { r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					player_sentry = {
						beam 							= { r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = true, frequency = 0.25 },
					},
					team_sentry = {
						beam 							= { r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					cop_sniper = {
						beam 							= { r = 1, g = 0, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 1, g = 0, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 0, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_active = {
						beam 							= { r = 1, g = 0, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 1, g = 0, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 0, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_rearming = {
						beam 							= { r = 1, g = 1, b = 0, a = 0.11 },
						glow 							= { match_beam = true, r = 1, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_mad = {
						beam 							= { r = 0, g = 1, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
				},
				flashlight = {
					player = {
						light 							= { r = 1, g = 1, b = 1, brightness = 1, range = 10, angle = 60 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					team = {
						light 							= { r = 1, g = 1, b = 1, brightness = 1, range = 10, angle = 60 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
				},
				SHOW_ANGELED_SIGHT						= true,
			},
			EQUIPMENT = {
				SENTRY_AUTO_AP 							= true,
				ECM_FEEDBACK_STEALTH_DISABLED			= true,
				SHAPED_CHARGE_STEALTH_DISABLED			= true,
				ENABLE_BURSTMODE						= true,
			},
			INVENTORY = {
				SHOW_WEAPON_NAMES 						= true,
				SHOW_WEAPON_MINI_ICONS 					= true,
				USE_REAL_WEAPON_NAMES 					= true,
				SHOW_SKILL_NAMES 						= true,
				CUSTOM_TAB_NAMES = {
					primaries 							= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
					secondaries 						= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
					masks 								= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
					melee_weapons 						= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
				},
			},
			SkipIt = {
				SKIP_BLACKSCREEN 						= true,		--Skip the blackscreen on mission start
				INSTANT_RESTART							= false,
				STAT_SCREEN_SPEEDUP						= false,
				STAT_SCREEN_DELAY 						= 5,		--Skip the experience screen after X seconds
				AUTOPICK_CARD 							= true,		--Automatically pick a card on lootscreen
				LOOT_SCREEN_DELAY 						= 3,		--Skip the loot screen after X seconds
				NO_SLOWMOTION 							= true,		--Disable mask-up and downed slow motion
			},
			MOD_OVERRIDES = {
				fed_inv									= true,
			},
		}
	end

	function WolfHUD:print_log(...)
		local params = {...}
		local msg_type, text = table.remove(params, #params), table.remove(params, 1)
		if msg_type and self.LOG_MODE[tostring(msg_type)] then
			if type(text) == "table" or type(text) == "userdata" then
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
				log(string.format("[WolfHUD] %s:", string.upper(type(text))))
				log_table(text)
				return
			elseif type(text) == "function" then
				msg_type = "error"
				text = "Cannot log function... "
			elseif type(text) == "string" then
				text = string.format(text, unpack(params))
			end
			log(string.format("[WolfHUD] %s: %s", string.upper(msg_type), text))
		end
	end

	function WolfHUD:Load()
		local file = io.open(self.settings_path, "r")
		if file then
			local function parse_settings(table_dst, table_src, setting_path)
				for k, v in pairs(table_src) do
					if type(table_dst[k]) == type(v) then
						if type(v) == "table" then
							table.insert(setting_path, k)
							parse_settings(table_dst[k], v, setting_path)
							table.remove(setting_path, #setting_path)
						else
							table_dst[k] = v
						end
					else
						self:print_log("Error while loading, Setting types don't match (%s->%s)", table.concat(setting_path, "->") or "", k or "N/A", "error")
					end
				end
			end

			local settings = json.decode(file:read("*all"))
			parse_settings(self.settings, settings, {})
			file:close()
		else
			self:print_log("Error while loading, settings file could not be opened (" .. self.settings_path .. ")", "error")
		end
	end

	function WolfHUD:Save()
		if table.size(self.settings or {}) > 0 then
			local file = io.open(self.settings_path, "w+")
			if file then
				file:write(json.encode(self.settings))
				file:close()
			else
				self:print_log("Error while saving, settings file could not be opened (" .. self.settings_path .. ")", "error")
			end
		else
			self:print_log("Error while saving, settings table appears to be empty...", "error")
		end
	end

	function WolfHUD:AskOverride(data, setting, notif_id)
		local menu_options = {
			[1] = {
				text = managers.localization:text("dialog_yes"),
				callback = function(self, item)
					WolfHUD.settings["MOD_OVERRIDES"][setting] = true
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
					WolfHUD.settings["MOD_OVERRIDES"][setting] = false
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
	
	function WolfHUD:getVersion()
		if not self.version then
			for k, v in pairs(LuaModManager.Mods) do
				local info = v.definition
				if info["name"] == "WolfHUD" then
					self.version = info["version"] or self.version
					break
				end
			end
		end

		return self.version
	end

	function WolfHUD:checkOverrides()
		local updates = {}
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "WolfHUD" then
				updates = info["updates"] or {}
				break
			end
		end

		if SystemInfo:platform() ~= Idstring("WIN32") then -- Abort here while Linux doesn't support 'mod_overrides', TODO: Linux seems to return WIN32 as well...
			return
		end

		for k, v in pairs(updates) do
			if type(v["revision"]) == "string" and not io.file_is_readable( v["revision"] ) then
				local setting = v["identifier"]
				if WolfHUD.settings["MOD_OVERRIDES"][setting] then
					WolfHUD:AskOverride(v, setting)
				elseif WolfHUD.settings["MOD_OVERRIDES"][setting] == nil then
					WolfHUD:createOverrides(v)
				else
					WolfHUD:createOverrideNotification(v, setting)
				end
			end
		end
	end

	function WolfHUD:createOverrides(data)
		self:print_log("Creating Dummy for: " .. data["display_name"], "info")
		if not file.DirectoryExists("./" .. data["install_dir"]) then
			WolfHUD:print_log("[WolfHUD] 'mod_overrides' folder is missing!", "warning")
			WolfHUD:createDirectory("./" .. data["install_dir"])
		end
		if not file.DirectoryExists("./" .. data["install_dir"] .. data["install_folder"]) then
			WolfHUD:print_log("[WolfHUD] mod_override folder '" .. data["install_folder"] .. "' is missing!", "warning")
			WolfHUD:createDirectory("./" .. data["install_dir"] .. data["install_folder"])
		end
		local file = io.open(data["revision"], "w+")
		if file then
			file:write("0")
			file:close()
		end
	end

	function WolfHUD:createDirectory(path)
		if SystemFS and SystemFS.make_dir then
			SystemFS:make_dir(path)
		elseif file and file.CreateDirectory then
			file.CreateDirectory(path)
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

	function WolfHUD:getSetting(id_table, default)
		if type(id_table) == "table" then
			local entry = self.settings
			for i = 1, #id_table do
				entry = entry[id_table[i]]
				if entry == nil then
					self:print_log("Requested setting doesn't exists!  (id='" .. table.concat(id_table, "->") .. "', type='" .. tostring(default) .. "') ", "error")
					return default
				end
			end
			return entry
		end
		return default
	end

	function WolfHUD:setSetting(id_table, value)
		local entry = self.settings
		for i = 1, (#id_table-1) do
			entry = entry[id_table[i]]
			if entry == nil then
				return false
			end
		end

		if type(entry[id_table[#id_table]]) == type(value) then
			entry[id_table[#id_table]] = value
			return true
		end
	end

	function WolfHUD:getColorSetting(id_table, default)
		local color_name = self:getSetting(id_table, default)
		return self:getColor(color_name) or default and self:getColor(default)
	end

	function WolfHUD:getColorID(name)
		if tweak_data and type(name) == "string" then
			for i, data in ipairs(self:getTweakEntry("color_table", "table")) do
				if name == data.name then
					return i
				end
			end
		end
	end

	function WolfHUD:getColor(name)
		if tweak_data and type(name) == "string" then
			for i, data in ipairs(self:getTweakEntry("color_table", "table")) do
				if name == data.name then
					return data.color and Color(data.color) or nil
				end
			end
		end
	end

	function WolfHUD:getTweakEntry(id, val_type, default)
		local value = self.tweak_data[id]
		if value ~= nil and (not val_type or type(value) == val_type) then
			return value
		else
			self:print_log("Requested tweak_entry doesn't exists!  (id='" .. id .. "', type='" .. tostring(val_type) .. "') ", "error")
			if default == nil then
				if val_type == "number" then -- Try to prevent crash by giving default value
					default = 1
				elseif val_type == "boolean" then
					default = false
				elseif val_type == "string" then
					default = ""
				elseif val_type == "table" then
					default = {}
				end
			end
			return default
		end
	end

	function WolfHUD:makeOutlineText(panel, bg, txt)
		bg.name = nil
		local bgs = {}
		for i = 1, 4 do
			table.insert(bgs, panel:text(bg))
		end
		WolfHUD:refreshOutlinePos(bgs, txt)
		return bgs
	end

	function WolfHUD:refreshOutlinePos(bgs, txt)
		bgs[1]:set_x(txt:x() - 1)
		bgs[1]:set_y(txt:y() - 1)
		bgs[2]:set_x(txt:x() + 1)
		bgs[2]:set_y(txt:y() - 1)
		bgs[3]:set_x(txt:x() - 1)
		bgs[3]:set_y(txt:y() + 1)
		bgs[4]:set_x(txt:x() + 1)
		bgs[4]:set_y(txt:y() + 1)
	end

	function WolfHUD:setOutlineText(bgs, text, show)
		for _, bg in pairs(bgs) do
			bg:set_text(text)
			if show then
				bg:show()
			else
				bg:set_visible(false)
			end
		end
	end

	function WolfHUD:setOutlineFontSize(bgs, size)
		for _, bg in pairs(bgs) do
			bg:set_font_size(size)
		end
	end

	function WolfHUD:truncateNameTag(name)
		local truncated_name = name:gsub('^%b[]',''):gsub('^%b==',''):gsub('^%s*(.-)%s*$','%1')
		if truncated_name:len() > 0 and name ~= truncated_name then
			name = utf8.char(1031) .. truncated_name
		end
		return name
	end

	if not WolfHUD.tweak_path then		-- Populate tweak data
		local tweak_path = string.format("%s%s", WolfHUD.save_path, WolfHUD.tweak_file)
		if not io.file_is_readable(tweak_path) then
			tweak_path = string.format("%s%s", WolfHUD.mod_path, WolfHUD.tweak_file)
		end
		if io.file_is_readable(tweak_path) then
			dofile(tweak_path)
			WolfHUD.tweak_data = WolfHUDTweakData:new()
		else
			WolfHUD:print_log(string.format("Tweak Data file couldn't be found! (%s)", tweak_path), "error")
		end
	end

	-- Table with all menu IDs
	WolfHUD.menu_ids = WolfHUD.menu_ids or {}

	--callback functions to apply changed settings on the fly
	if not WolfHUD.apply_settings_clbk then
		WolfHUD.apply_settings_clbk = {
			["CustomHUD"] = function(setting, value)
				if managers.hud and managers.hud.change_hud_setting then
					local type = table.remove(setting, 1)
					managers.hud:change_hud_setting(type, setting, WolfHUD:getColor(value) or value)
				end
			end,
			["HUDList"] = function(setting, value)
				if managers.hud and HUDListManager then
					if setting[1] == "BUFF_LIST" and setting[2] ~= "show_buffs" then
						managers.hud:change_bufflist_setting(tostring(setting[#setting]), WolfHUD:getColor(value) or value)
					elseif setting[1] == "RIGHT_LIST" and setting[2] == "SHOW_PICKUP_CATEGORIES" then
						managers.hud:change_pickuplist_setting(tostring(setting[#setting]), WolfHUD:getColor(value) or value)
					else
						managers.hud:change_list_setting(tostring(setting[#setting]), WolfHUD:getColor(value) or value)
					end
				end
			end,
			["TabStats"] = function(setting, value)
				if managers.hud and managers.hud.change_tabstats_setting then
					managers.hud:change_tabstats_setting(tostring(setting[#setting]), value)
				end
			end,
			["DrivingHUD"] = function(setting, value)
				if managers.hud and managers.hud.change_drivinghud_setting then
					managers.hud:change_drivinghud_setting(tostring(setting[#setting]), WolfHUD:getColor(value) or value)
				end
			end,
			["GADGETS"] = function(setting, value)
				if managers.hud and managers.hud.change_hud_setting and #setting >= 4 then
					WeaponGadgetBase.update_theme_setting(setting[1], setting[2], setting[3], setting[4], WolfHUD:getColor(value) or value)
				end
			end,
		}
	end

	WolfHUD:Reset()	-- Populate settings table
	WolfHUD:Load()	-- Load user settings

	-- Create Ingame Menus
	dofile(WolfHUD.mod_path .. "OptionMenus.lua")	-- Menu structure table in seperate file, in order to not bloat the Core file too much.
	local menu_options = WolfHUD.options_menu_data

	-- Setup and register option menus
	Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_WolfHUD", function( menu_manager, nodes )
		local function create_menu(menu_table, parent_id)
			for i, data in ipairs(menu_table) do
				if data.type == "menu" then
					MenuHelper:NewMenu( data.menu_id )
					create_menu(data.options, data.menu_id)
				end
			end
		end

		create_menu({menu_options}, "lua_mod_options_menu")
	end)

	--Populate options menus
	Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_WolfHUD", function(menu_manager, nodes)
		-- Called on setting change
		local function change_setting(setting, value)
			if WolfHUD:getSetting(setting, nil) ~= value and WolfHUD:setSetting(setting, value) then
				WolfHUD:print_log(string.format("Change setting: %s = %s", table.concat(setting, "->"), tostring(value)), "info")	-- Change type back!
				WolfHUD.settings_changed = true

				local script = table.remove(setting, 1)
				if WolfHUD.apply_settings_clbk[script] then
					WolfHUD.apply_settings_clbk[script](setting, value)
				end
			end
		end

		local function add_visible_reqs(menu_id, id, data)
			local visual_clbk_id = id .. "_visible_clbk"
			local enabled_clbk_id = id .. "_enabled_clbk"

			--Add visual callback
			MenuCallbackHandler[visual_clbk_id] = function(self, item)
				for _, req in ipairs(data.visible_reqs) do
					if type(req) == "table" then
						local a = WolfHUD:getSetting(req.setting, nil)
						if req.equal then
							if a ~= b then
								return false
							end
						elseif type(a) == "boolean" then
							local b = req.invert and true or false
							if a == b then
								return false
							end
						elseif type(a) == "number" then
							local min_value = req.min or a
							local max_value = req.max or a
							if a < min_value or a > max_value then
								return false
							end
						end
					end
				end
				return true
			end

			--Add enable callback
			MenuCallbackHandler[enabled_clbk_id] = function(self, item)
				return MenuCallbackHandler[visual_clbk_id](self, item)
			end

			--Associate visual callback with item
			local menu = MenuHelper:GetMenu(menu_id)
			for i, item in pairs(menu._items_list) do
				if item:parameters().name == id then
					if data.visible_reqs.hide_on_disabled then
						item._visible_callback_name_list = { visual_clbk_id }
					else
						item._enabled_callback_name_list = { enabled_clbk_id }
					end
					item._create_data = data
				end
			end
		end

		-- Reapply enabled state on all items in the same menu
		local update_visible_clbks = "wolfhud_update_visibility"
		MenuCallbackHandler[update_visible_clbks] = function(self, item)
			local gui_node = item:parameters().gui_node
			if gui_node then
				if item._type ~= "slider" then
					gui_node:refresh_gui(gui_node.node)
					gui_node:highlight_item(item, true)
				end

				for _, row_item in pairs(gui_node.row_items) do
					local option_item = row_item.item
					if option_item._type ~= "divider" and option_item:parameters().name ~= item:parameters().name then
						local enabled = true

						for _, clbk in ipairs(option_item._enabled_callback_name_list or {}) do
							enabled = enabled and self[clbk](self, option_item)
						end

						option_item:set_enabled(enabled)

						gui_node:reload_item(option_item)
					end
				end
			end
		end

		-- item create functions by type
		local create_item_handlers = {
			menu = function(parent_id, offset, data)
				if not table.contains(WolfHUD.menu_ids, data.menu_id) then
					table.insert(WolfHUD.menu_ids, data.menu_id)
				end
			end,
			slider = function(menu_id, offset, data, value)
				local id = string.format("%s_%s_slider", menu_id, data.name_id)
				local clbk_id = id .. "_clbk"

				MenuHelper:AddSlider({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					callback = string.format("%s %s", clbk_id, update_visible_clbks),
					value = value or 0,
					min = data.min_value,
					max = data.max_value,
					step = data.step_size,
					show_value = true,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				})

				--Value changed callback
				MenuCallbackHandler[clbk_id] = function(self, item)
					change_setting(clone(data.value), item:value())
				end

				if data.visible_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			toggle = function(menu_id, offset, data, value)
				local id = string.format("%s_%s_toggle", menu_id, data.name_id)
				local clbk_id = id .. "_clbk"

				if data.invert_value then
					value = not value
				end

				MenuHelper:AddToggle({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					callback = string.format("%s %s", clbk_id, update_visible_clbks),
					value = value or false,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				})

				--Add visual callback
				MenuCallbackHandler[clbk_id] = function(self, item)
					local value = (item:value() == "on") and true or false

					if data.invert_value then
						value = not value
					end

					change_setting(clone(data.value), value)
				end

				if data.visible_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			multi_choice = function(menu_id, offset, data, value)
				local id = string.format("%s_%s_multi", menu_id, data.name_id)
				local clbk_id = id .. "_clbk"

				MenuHelper:AddMultipleChoice({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					callback = string.format("%s %s", clbk_id, update_visible_clbks),
					items = data.options,
					value = value,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				})

				MenuCallbackHandler[clbk_id] = function(self, item)
					change_setting(clone(data.value), item:value())
				end

				if data.add_color_options then
					local menu = MenuHelper:GetMenu(menu_id)
					for i, item in pairs(menu._items_list) do
						if item:parameters().name == id then
							item:clear_options()
							for k, v in ipairs(WolfHUD:getTweakEntry("color_table", "table") or {}) do
								if data.add_rainbow or v.name ~= "rainbow" then
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

									item:add_option(CoreMenuItemOption.ItemOption:new(params))
								end
							end
							item:_show_options(nil)
							item:set_value(value)
							for __, clbk in pairs( item:parameters().callback ) do
								clbk(item)
							end
						end
					end
				end

				if data.visible_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			button = function(menu_id, offset, data)
				local id = string.format("%s_%s_button", menu_id, data.name_id)
				local clbk_id = data.clbk or (id .. "_clbk")

				MenuHelper:AddButton({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					callback = clbk_id,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				})

				MenuCallbackHandler[clbk_id] = MenuCallbackHandler[clbk_id] or function(self, item)

				end

				if data.visible_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			divider = function(menu_id, offset, data)
				local id = string.format("%s_divider_%d", menu_id, offset)

				MenuHelper:AddDivider({
					id = id,
					size = data.size,
					menu_id = menu_id,
					priority = offset,
				})
			end,
		}

		-- Populate Menus with their menu items
		local function populate_menu(menu_table, parent_id)
			local item_amount = #menu_table
			for i, data in ipairs(menu_table) do
				local value = data.value and WolfHUD:getSetting(data.value, nil)
				create_item_handlers[data.type](data.parent_id or parent_id, item_amount - i, data, value)

				if data.type == "menu" then
					populate_menu(data.options, data.menu_id)
				end
			end
		end

		populate_menu({menu_options}, "lua_mod_options_menu")
	end)

	-- Create callbacks and finalize menus
	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_WolfHUD", function(menu_manager, nodes)
		local back_clbk = "wolfhud_back_clbk"
		local focus_clbk = "wolfhud_focus_clbk"
		local reset_clbk = "wolfhud_reset_clbk"

		-- Add menu back callback
		MenuCallbackHandler[back_clbk] = function(self, item)
			if WolfHUD.settings_changed then
				WolfHUD.settings_changed = nil
				WolfHUD:Save()
				WolfHUD:print_log("Settings saved!", "info")
			end
		end

		-- Add focus callback
		MenuCallbackHandler[focus_clbk] = function(node, focus)
			if focus then
				for _, option_item in pairs(node._items) do
					if option_item._type ~= "divider" then
						local enabled = true

						for _, clbk in ipairs(option_item._enabled_callback_name_list or {}) do
							enabled = enabled and MenuCallbackHandler[clbk](self, option_item)
						end

						option_item:set_enabled(enabled)
					end
				end
			end
		end

		-- Add reset menu items callback
		MenuCallbackHandler[reset_clbk] = function(self, item)
			local menu_title = managers.localization:text("wolfhud_reset_options_title")
			local menu_message = managers.localization:text("wolfhud_reset_options_confirm")
			local menu_buttons = {
				[1] = {
					text = managers.localization:text("dialog_yes"),
					callback = function(self, item)
						WolfHUD:Reset()

						for i, menu_id in ipairs(WolfHUD.menu_ids) do
							local menu = MenuHelper:GetMenu(menu_id)
							if menu then
								for __, menu_item in ipairs(menu._items_list) do
									local setting = menu_item._create_data and clone(menu_item._create_data.value)
									if menu_item.set_value and setting then
										local value = WolfHUD:getSetting(setting, nil)
										if value ~= nil then
											local script = table.remove(setting, 1)
											if WolfHUD.apply_settings_clbk[script] then
												WolfHUD.apply_settings_clbk[script](setting, value)
											end

											if menu_item._type == "toggle" then
												if menu_item._create_data.invert_value then
													value = not value
												end
												value = (value and "on" or "off")
											end

											menu_item:set_value(value)
										end
									end
								end
							end
						end
						managers.viewport:resolution_changed()

						WolfHUD.settings_changed = true
						WolfHUD:print_log("Settings resetted!", "info")
					end,
				},
				[2] = {
					text = managers.localization:text("dialog_no"),
					is_cancel_button = true,
				},
			}
			QuickMenu:new( menu_title, menu_message, menu_buttons, true )
		end

		-- Build Menus and add a button to parent menu
		local function finalize_menu(menu_table, parent_id)
			for i, data in ipairs(menu_table) do
				if data.type == "menu" then
					nodes[data.menu_id] = MenuHelper:BuildMenu(data.menu_id, { back_callback = back_clbk, focus_changed_callback = focus_clbk })
					MenuHelper:AddMenuItem(
						nodes[data.parent_id or parent_id],
						data.menu_id,
						data.name_id,
						data.desc_id,
						data.position or i
					)

					finalize_menu(data.options, data.menu_id)
				end
			end
		end

		finalize_menu({menu_options}, "lua_mod_options_menu")
	end)

	--Add localiszation strings
	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_WolfHUD", function(loc)
		local loc_path = WolfHUD.mod_path .. "loc/"
		if file.DirectoryExists( loc_path ) then
			local chinese = false
			for k, v in pairs(LuaModManager.Mods) do
				local info = v.definition
				if info["name"] == "ChnMod" then
					chinese = true
					break
				end
			end
			if chinese then
				loc:load_localization_file(loc_path .. "chinese.json")
			elseif _G.PD2KR then
				loc:load_localization_file(loc_path .. "korean.json")
			else
				for _, filename in pairs(file.GetFiles(loc_path)) do
					local str = filename:match('^(.*).json$')
					if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
						loc:load_localization_file(loc_path .. filename)
						break
					end
				end
			end
			loc:load_localization_file(loc_path .. "english.json", false)

			if WolfHUD:getSetting({"INVENTORY", "USE_REAL_WEAPON_NAMES"}, false) then
				loc:load_localization_file(loc_path .. "RealWeaponNames.json")
			end
		else
			WolfHUD:print_log("Localization folder seems to be missing!", "error")
		end

		local localized_strings = {}
		localized_strings["cash_sign"] = WolfHUD:getTweakEntry("CASH_SIGN", "string", "$")

		-- Hide Skip Message, when auto skip blackscreen is active
		if WolfHUD:getSetting({"SkipIt", "SKIP_BLACKSCREEN"}, false) then
			localized_strings["hud_skip_blackscreen"] = ""
		end

		-- Add macro $VALUE to all interaction strings
		for interact_id, data in pairs(tweak_data.interaction) do
			if type(data) == "table" and data.text_id and not data.verify_owner then
				localized_strings[data.text_id] = loc:text(data.text_id, {BTN_INTERACT = "$BTN_INTERACT"}) .. "$VALUE"
			end
		end
		loc:add_localized_strings(localized_strings)
	end)
end

if MenuNodeMainGui then
	Hooks:PostHook( MenuNodeMainGui , "_setup_item_rows" , "MenuNodeMainGuiPostAddVersionString_WolfHUD" , function( self, node )
		WolfHUD:checkOverrides()
	end)

	Hooks:PostHook( MenuNodeMainGui , "_add_version_string" , "MenuNodeMainGuiPostAddVersionString_WolfHUD" , function( self )
		if alive(self._version_string) then
			self._version_string:set_text("Payday 2 v" .. Application:version() .. " | WolfHUD v" .. WolfHUD:getVersion())
		end
	end)
end

if MenuItemMultiChoice then
	Hooks:PostHook( MenuItemMultiChoice , "setup_gui" , "MenuItemMultiChoicePostSetupGui_WolfHUD" , function( self, node, row_item )
		if self:selected_option() and self:selected_option():parameters().color and row_item.choice_text then
			row_item.choice_text:set_blend_mode("normal")
		end
	end)
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()

	if WolfHUD.hook_files[requiredScript] then
		for __, file in ipairs(WolfHUD.hook_files[requiredScript]) do
			dofile( WolfHUD.mod_path .. "lua/" .. file )
		end
	end
end