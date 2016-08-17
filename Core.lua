--		TODO: Add Ingame Options for DMG Popup
--		TODO: Add Ingame Options for Buffs

if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath
	WolfHUD.settings_path = WolfHUD.save_path .. "WolfHUD.txt"
	WolfHUD.inv_names_file = "WolfHUD_InventoryNames.txt"
	WolfHUD.DEBUG_MODE = false
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
		"wolfhud_infopanels_buff_buffs_options_menu",
		"wolfhud_infopanels_buff_debuffs_options_menu",
		"wolfhud_infopanels_buff_teambuffs_options_menu",
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
		WolfHUD.color_table = { -- namestring is always 'wolfhud_color_<name>'
			{ color = Color('FFFFFF'), name = "white" },
			{ color = Color('F2F250'), name = "light_yellow" },
			{ color = Color('F2C24E'), name = "light_orange" },
			{ color = Color('E55858'), name = "light_red" },
			{ color = Color('CC55CC'), name = "light_purple" },
			{ color = Color('00FF00'), name = "light_green" },
			{ color = Color('00FFFF'), name = "light_blue" },
			{ color = Color('BABABA'), name = "light_gray" },
			{ color = Color('FFFF00'), name = "yellow" },
			{ color = Color('FFA500'), name = "orange" },
			{ color = Color('FF0000'), name = "red" },
			{ color = Color('800080'), name = "purple" },
			{ color = Color('008000'), name = "green" },
			{ color = Color('0000FF'), name = "blue" },
			{ color = Color('808080'), name = "gray" },
			{ color = Color('000000'), name = "black" },
			{ color = Color('000000'), name = "rainbow" },
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
		["lib/managers/blackmarketmanager"] = { "EquipmentTweaks.lua" },
		["lib/managers/chatmanager"] = { "MenuTweaks.lua" },
		["lib/managers/localizationmanager"] = { "AdvAssault.lua" },
		["lib/managers/experiencemanager"] = { "Scripts.lua" },
		["lib/managers/moneymanager"] = { "Scripts.lua" },
		["lib/managers/hudmanager"] = { "EnemyHealthbar.lua", "TabStats.lua" },
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
		["lib/managers/enemymanager"] = { "GameInfoManager.lua", "KillCounter.lua" },
		["lib/managers/group_ai_states/groupaistatebase"] = { "GameInfoManager.lua", "PacifiedCivs.lua" },
		["lib/managers/missionassetsmanager"] = { "MenuTweaks.lua" },
		["lib/managers/menu/blackmarketgui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/stageendscreengui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/lootdropscreengui"] = { "MenuTweaks.lua" },
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
		["lib/units/weapons/trip_mine/tripminebase"] = { "EquipmentTweaks.lua" },
		["lib/units/props/securitycamera"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/playerdamage"] = { "GameInfoManager.lua", "DamageIndicator.lua" },
		["lib/units/beings/player/playermovement"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/huskplayermovement"] = { "DownCounter.lua" },
		["lib/units/beings/player/states/playercivilian"] = { "Interaction.lua" },
		["lib/units/beings/player/states/playerstandard"] = { "GameInfoManager.lua", "EnemyHealthbar.lua", "Interaction.lua", "BurstFire.lua", "WeaponGadgets.lua" },
		["lib/units/beings/player/states/playerbleedout"] = { "DownCounter.lua" },
		["lib/units/vehicles/vehicledamage"] = { "DamageIndicator.lua" },
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
		["lib/tweak_data/timespeedeffecttweakdata"] = { "Scripts.lua" },
		["core/lib/managers/menu/items/coremenuitemslider"] = { "MenuTweaks.lua" },
		["core/lib/managers/subtitle/coresubtitlepresenter"] = { "EnhancedObjective.lua" },
	}
	
	
	function WolfHUD:Reset()
		WolfHUD.settings = 
		{
		  --CustomHUD
			use_customhud 					= true,
			PLAYER_SCALE 					= 1,		--Size of local Player HUD Panel
			PLAYER_OPACITY					= 0.85,
			PLAYER_NAME						= false,
			PLAYER_RANK						= false,
			PLAYER_CHARACTER				= false,
			PLAYER_STATUS					= true,
			PLAYER_EQUIPMENT				= true,
			PLAYER_SPECIALEQUIPMENT			= true,
			PLAYER_SPECIALEQUIPMENTROWS		= 1,
			PLAYER_CALLSIGN					= false,
			PLAYER_CARRY					= true,
			PLAYER_WEAPON_ICON				= 4,
			PLAYER_WEAPON_NAME				= 1,
			PLAYER_WEAPON_AMMO				= 4,
			PLAYER_WEAPON_FIREMODE			= 2,
			TEAM_SCALE 						= 0.8,		--Size of Teammates/AI's HUD Panels
			TEAM_OPACITY					= 0.85,
			TEAM_NAME						= true,
			TEAM_RANK						= true,
			TEAM_CHARACTER					= false,
			TEAM_LATENCY					= true,
			TEAM_STATUS						= true,
			TEAM_EQUIPMENT					= true,
			TEAM_SPECIALEQUIPMENT			= true,
			TEAM_SPECIALEQUIPMENTROWS		= 3,
			TEAM_CALLSIGN					= false,
			TEAM_CARRY						= true,
			TEAM_BUILD_HIDE					= true,
			TEAM_BUILD_DURATION				= 15,
			TEAM_WEAPON_ICON				= 4,
			TEAM_WEAPON_NAME				= 1,
			TEAM_WEAPON_AMMO				= 4,
			TEAM_WEAPON_FIREMODE			= 1,
			TEAM_INTERACTION_HIDE			= true,		-- Show Interaction
			TEAM_INTERACTION_MINDURATION	= 1,		--Hide Interaction if shorter than X sec.
			show_pacified_civilians			= true,
			show_downcounter 				= true,	
			use_realammo					= true,
		  --HUDChat
			CHAT_WAIT_TIME					= 10,		--Time before chat fades out, 0 = never
			LINE_HEIGHT						= 15,		--Chat font Size
			MAX_OUTPUT_LINES				= 8,		--Chat Output lines
			spam_filter						= true,		--Filter PocoHud and NGBTO Chat Spam messages.
		  --KillCounter
			use_killcounter 				= true,
			killcounter_color				= "yellow",
			SHOW_SPECIAL_KILLS 				= true,		--KillCounter shows special kills
			SHOW_HEADSHOT_KILLS 			= true,		--KillCounter shows headshot kills
			SHOW_AI_KILLS 					= true,		--Show KillCounter for Bots
			SHOW_ACCURACY					= true,
			max_corpses 					= 100,		--Maximum number of laying around corpses
		  --Enemy Healthbar
			show_enemy_healthbar 			= true,		--Show healthbars
			show_civilian_healthbar 		= false,	--Show Healthbars for Civilians and TeamAI
			show_car_healthbar				= true,		--Show Healthbar for vehicles
			show_healthbar_pointer 			= false,	--Show pointer near the Healthbar, pointing at Healthbar owner
		  --Dynamic Damage Indicator
			show_dmg_indicator				= true,
			dmg_ind_size					= 150,
			dmg_ind_time					= 2,
			dmg_indicator_max_count			= 10,
			dmg_shield_color				= "gray",
			dmg_health_color				= "red",
			dmg_crit_color					= "purple",
			dmg_vehicle_color				= "yellow",
			dmg_friendlyfire_color			= "orange",
		  --Damage Popup
			show_dmg_popup					= true,
			dmg_popup_time	 				= 3,
			dmg_popup_color					= "yellow",
			dmg_popup_headshot_color		= "red",
		  --Suspicion
			suspicion_scale					= 0.8,
			numberic_suspicion				= true,
			show_susp_eye					= true,
		  --Driving HUD
			use_drivinghud					= true,		--Show DrivingHUD Panel
			show_vehicle 					= true,		--Show Vehicle and Teammate Mask Images
			speed_in_mph 					= false,	--Display Speed in mph
		  --TabStats
			use_tabstats					= true,
			clock_mode						= 3,		-- 1 = disabled, 2 = 12h, 3 = 24h
			tabstats_color 					= "rainbow",
			tabstats_font_size 				= 18,
			use_actual_mask					= true,
			numberic_loot					= true,
		  --Scripts
			skip_blackscreen 				= true,		--Skip the blackscreen on mission start
			stat_screen_delay 				= 5,		--Skip the experience screen after X seconds
			autopick_card 					= true,		--Automatically pick a card on lootscreen
			loot_screen_delay 				= 3,		--Skip the loot screen after X seconds
			no_slowmotion 					= true,		--Disable mask-up and downed slow motion
		  --HUDList
			use_hudlist 					= true,
			right_list_scale				= 1,
			left_list_scale					= 1,
			buff_list_scale					= 1,
			list_color	 					= "white",		--Left and Right List font color
			list_color_bg	 				= "black",		--Left and Right List BG color
			civilian_color 					= "white", 		--EnemyCounter Civillian and Hostage icon color
			thug_color 						= "white",		--EnemyCounter Thug and Mobster icon color
			enemy_color 					= "white",		--EnemyCounter Cop and Specials icon color
			special_color 					= "white",
			
			show_timers 					= true,     --Drills, time locks, hacking etc.
			show_ammo_bags					= true,  	--Deployables (ammo)
			show_doc_bags					= true,  	--Deployables (doc bags)
			show_body_bags					= true,  	--Deployables (body bags)
			show_grenade_crates				= true,  	--Deployables (grenades)
			show_sentries 					= true,   	--Deployable sentries
			show_ecms 						= true,		--Active ECMs
			show_ecm_retrigger 				= true,  	--Countdown for players own ECM feedback retrigger delay
			show_minions 					= true,  	--Converted enemies, type and health
			show_pagers 					= true,  	--Show currently active pagers
			show_tape_loop 					= true,  	--Show active tape loop duration
			remove_answered_pager_contour 	= true,  	--Removes the interaction contour on answered pagers

			show_enemies 					= true,		--Currently spawned enemies
				aggregate_enemies 			= false,  	--Don't split enemies on type; use a single entry for all
			show_turrets 					= true,    	--Show active SWAT turrets
			show_civilians 					= true,  	--Currently spawned, untied civs
			show_hostages 					= true,   	--Currently tied civilian and dominated cops
				aggregate_hostages			= false,
			show_minion_count 				= true,     --Current number of jokered enemies
			show_pager_count 				= true,		--Show number of triggered pagers (only counts pagers triggered while you were present)
			show_cam_count					= true,
			show_bodybags_count				= true,
			show_loot 						= true,     --Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
				aggregate_loot 				= false, 	--Don't split loot on type; use a single entry for all
				separate_bagged_loot 		= true,     --Show bagged loot as a separate value
			show_special_pickups 			= true,    	--Show number of special equipment/items

			show_buffs 						= true,     --Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
			aggressive_reload_aced_buff		= true,
			ammo_efficiency_buff			= true,
			armor_break_invulnerable_buff	= true,
			berserker_buff					= true,
			biker_buff						= true,
			bloodthirst_basic_buff			= false,
			bloodthirst_aced_buff			= true,
			bullet_storm_buff				= true,
			close_contact_buff				= true,
			combat_medic_buff				= true,
			combat_medic_passive_buff		= false,
			desperado_buff					= true,
			die_hard_buff					= false,
			dire_need_buff					= true,
			grinder_buff					= true,
			hostage_situation_buff			= false,
			hostage_taker_buff				= false,
			inspire_buff					= true,
			lock_n_load_buff				= true,
			melee_stack_damage_buff			= false,
			maniac_buff						= false,
			messiah_buff					= true,
			overdog_buff					= false,
			overkill_buff					= false,
			painkiller_buff					= false,
			partner_in_crime_buff			= false,
			running_from_death_buff			= true,
			quick_fix_buff					= false,
			second_wind_buff				= true,
			sixth_sense_buff				= true,
			swan_song_buff					= false,
			tooth_and_claw_buff				= true,
			trigger_happy_buff				= false,
			underdog_buff					= false,
			unseen_strike_buff				= true,
			up_you_go_buff					= false,
			uppers_buff						= true,
			yakuza_buff						= false,
			anarchist_armor_recovery_debuff	= true,
			ammo_give_out_debuff			= true,
			armor_break_invulnerable_debuff	= false,
			bullseye_debuff					= true,
			grinder_debuff					= false,
			inspire_debuff					= true,
			inspire_revive_debuff			= true,
			life_drain_debuff				= true,
			medical_supplies_debuff			= true,
			sociopath_debuff				= true,
			unseen_strike_debuff			= false,
			uppers_debuff					= false,
			armorer_teambuff				= true,
			bulletproof_teambuff			= true,
			crew_chief_teambuff				= true,
			forced_friendship_teambuff		= true,
			damage_increase_compbuff		= true,
			damage_reduction_compbuff		= true,
			melee_damage_increase_compbuff	= true,
		  --Interaction
			LOCK_MODE 						= 3,			--Disabled (1, Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time (2), or current interaction time(3)
			MIN_TIMER_DURATION 				= 5, 			--Min interaction duration (in seconds) for the toggle behavior to activate
			EQUIPMENT_PRESS_INTERRUPT 		= true, 		--Use the equipment key ('G') to toggle off active interactions
			SHOW_LOCK_INDICATOR				= true,
			SHOW_CIRCLE						= true,
			CIRCLE_SCALE					= 0.8,
			TEXT_SCALE						= 0.8,
			SHOW_INTERRUPT_HINT				= true,
			SHOW_TIME_REMAINING 			= true,			--Show remaining Time in the Interaction-Circle
			GRADIENT_COLOR 					= "light_green",--Color, which the timer reaches on completition
			SHOW_RELOAD						= true,
			SHOW_MELEE						= false,
			SUPRESS_NADES_STEALTH			= true,
			HOLD2PICK						= true,
		  --Laser-Colors
			laser_autoon					= true,
			use_weaponlasers 				= true,
		    laser_light 					= 10,			--Multiplier for laser dot
			laser_glow 						= 5,			--Divider for laser beam
			laser_player 					= "light_blue",	--Player laser color id
			laser_player_alpha 				= 0.3,			--Player laser alpha
			laser_player_sentry				= "light_blue",	--Player sentry laser color id
			laser_player_sentry_alpha 		= 0.1,			--Player sentry laser alpha
			laser_teammates 				= "light_blue",	--Teammates laser color id
			laser_teammates_alpha 			= 0.15,			--Teammates laser alpha
			laser_teammates_sentry 			= "light_blue",	--Teammates sentry laser color id
			laser_teammates_sentry_alpha 	= 0.1,			--Teammates sentry laser alpha
			laser_sniper 					= "red",		--Sniper laser color id
			laser_sniper_alpha 				= 0.5,			--Sniper laser alpha
			laser_turret_active 			= "red",		--Active turret laser color id
			laser_turret_reloading 			= "yellow",		--Reloading turret laser color id
			laser_turret_jammed 			= "green",		--Jammed turret laser color id
			laser_turret_alpha 				= 0.15,			--Turret laser alpha
			flashlight_angle 				= 100,			--Flashlight angle
			flashlight_range 				= 20,			--Flashlight range (in m)
			flashlight_mult					= 2,
			flashlight_color				= "white",
			show_angeled_sight				= true,
		  --Equipment Tweaks
			senty_auto_ap 					= true,
			tripmine_auto_sensor_stealth	= true,
			ecm_feedback_disabled_stealth	= true,
			
			show_advanced_assault			= true,
			enable_burstmode				= true,
			
			replace_weapon_names 			= true,
			inventory_tab_names				= true,
			inventory_names					= true,
			show_mini_icons					= true
		}
	end
	
	function WolfHUD:print_log(text)
		if self.DEBUG_MODE then
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
					self:print_log("Error loading setting: " .. tostring(k) .. " (Wrong type)")
				end
			end
			file:close()
		else
			self:print_log("Error while loading, settings file could not be opened (" .. self.settings_path .. ")")
		end
		if corrupt then 
			self:Save()
			self:print_log("Invalid settings stored in savefile, resaving...")
		end
	end

	function WolfHUD:Save()
		local file = io.open(self.settings_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		else
			self:print_log("Error while saving, settings file could not be opened (" .. self.settings_path .. ")")
		end
	end
	
	function WolfHUD:createOverrides()
		local updates = {}
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "WolfHUD" then
				self.version = info["version"]
				updates = info["updates"]
			end
		end
		for k, v in pairs(updates) do
			if type(v["revision"]) == "string" and not io.file_is_readable( v["revision"] ) then
				if v["identifier"] ~= "fed_inv" or WolfHUD.settings.use_federal_inventory then
					self:print_log("Creating Dummy for: " .. v["display_name"])
					if not file.DirectoryExists("./" .. v["install_dir"] .. v["install_folder"]) then
						if SystemInfo:platform() == Idstring("WIN32") then  --Windows
							os.execute('cmd /c mkdir "./' .. v["install_dir"] .. v["install_folder"] .. '"')
						else --Linux
							log("[WolfHUD] mod_override folder '" .. v["install_folder"] .. "' is missing!")
						end
					end
					local file = io.open(v["revision"], "w+")
					if file then
						file:write("0")
						file:close()
					end
				end
			end
		end
	end
	
	function WolfHUD:getSetting(id, val_type)
		local value = self.settings[id]
		if value ~= nil and (not val_type or type(value) == val_type or val_type == "color" and type(value) == "string") then
			local value = self.settings[id]
			if val_type == "color" then
				local id = self:getColorID(value) or 1
				return self.color_table[id].color
			else
				return value
			end
		else
			self:print_log("Requested setting doesn't exists!  (id='" .. id .. "', type='" .. tostring(val_type) .. "') ")
			if val_type == "number" then -- Try to prevent crash by giving default value
				return 1
			elseif val_type == "boolean" then 
				return false
			elseif val_type == "string" then 
				return ""
			elseif val_type == "color" then
				return Color.white
			end
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
	
	WolfHUD:Reset()
	WolfHUD:Load()
	
	WolfHUD:createOverrides()
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
								local item_id = menu_item:parameters().name
								local value = WolfHUD:getSetting(tostring(item_id))
								if value ~= nil and menu_item.set_value then
									value = WolfHUD:getColorID(value) or value
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
	
	MenuCallbackHandler.clbk_change_color_setting = function(self, item)
		local value = item:value()
		local name = item:parameters().name
		if name and type(value) == "number" then
			WolfHUD.settings[name] = WolfHUD.color_table[value].name
		end
	end
	
	MenuCallbackHandler.clbk_change_hudlist_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and HUDListManager then managers.hud:change_list_setting(tostring(name), WolfHUD:getSetting(name)) end
	end
	
	MenuCallbackHandler.clbk_change_hudlist_color_setting = function(self, item)
		self:clbk_change_color_setting(item)
		local name = item:parameters().name
		if managers.hud and HUDListManager then managers.hud:change_list_setting(tostring(name), WolfHUD:getSetting(name, "color")) end
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
			managers.hud:change_hud_setting(type, setting, WolfHUD:getSetting(name)) 
		end
	end
	
	MenuCallbackHandler.clbk_change_tabstats_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if managers.hud and managers.hud.change_tabstats_setting then managers.hud:change_tabstats_setting(tostring(name), WolfHUD:getSetting(name)) end
	end
	
	MenuCallbackHandler.clbk_change_tabstats_color_setting = function(self, item)
		self:clbk_change_color_setting(item)
		local name = item:parameters().name
		if managers.hud and managers.hud.change_tabstats_setting then managers.hud:change_tabstats_setting(tostring(name), WolfHUD:getSetting(name)) end
	end
		
	WolfHUD:Load()
	local settings = clone(WolfHUD.settings)
	for k, v in pairs(settings) do
		if type(v) == "string" then
			settings[k] = WolfHUD:getColorID(v) or v
		end
	end
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/options.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets_lasers.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/equipment.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/interaction.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_tabstats.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_buff.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_buff_buffs.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_buff_debuffs.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_buff_teambuffs.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_right.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_left.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_panels.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_teampanels.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_playerpanel.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_chat.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_suspicion.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_killcounter.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damage_indicator.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damage_popup.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_enemy_healthbar.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_drivinghud.json", WolfHUD, settings)
end)