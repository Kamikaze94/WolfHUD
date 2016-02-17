if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.loaded_options = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath .. "WolfHUD.txt"
	WolfHUD.menu_name = "WolfHUD_options"
	
	WolfHUD.colors = WolfHUD.colors or {
		Color('FAEBD7'),
		Color('00FFFF'),
		Color('7FFFD4'),
		Color('F0FFFF'),
		Color('8A2BE2'),
		Color('D2691E'),
		Color('FF7F50'),
		Color('00FFFF'),
		Color('00008B'),
		Color('9400D3'),
		Color('FF1493'),
		Color('00BFFF'),
		Color('B22222'),
		Color('228B22'),
		Color('FFD700'),
		Color('ADFF2F'),
		Color('4B0082'),
		Color('E6E6FA'),
		Color('ADD8E6'),
		Color('F08080'),
		Color('E0FFFF'),
		Color('90EE90'),
		Color('FFB6C1'),
		Color('FFA07A'),
		Color('20B2AA'),
		Color('87CEFA'),
		Color('FFFFE0'),
		Color('00FF00'),
		Color('FF00FF'),
		Color('0000CD'),
		Color('9370DB'),
		Color('3CB371'),
		Color('7B68EE'),
		Color('00FA9A'),
		Color('48D1CC'),
		Color('C71585'),
		Color('191970'),
		Color('000080'),
		Color('FFA500'),
		Color('87CEEB'),
		Color('00FF7F'),
		Color('008080'),
		Color('EE82EE'),
		Color('000000'),
	}
	
	WolfHUD.custom_hud = WolfHUD.custom_hud or {													--CustomHUD
		["lib/managers/hudmanagerpd2"] = "CustomHUD.lua",
		["lib/managers/hud/hudteammate"] = "CustomHUD.lua",
		["lib/managers/hud/hudtemp"] = "CustomHUD.lua",
		["lib/managers/hud/hudassaultcorner"] = "CustomHUD.lua",
		["lib/managers/hud/hudobjectives"] = "CustomHUD.lua",
		["lib/managers/hud/hudheisttimer"] = "CustomHUD.lua",
		["lib/managers/hud/hudchat"] = "CustomHUD.lua",
		["lib/managers/trademanager"] = "CustomHUD.lua",
		["lib/units/equipment/doctor_bag/doctorbagbase"] = "CustomHUD.lua",
		["lib/units/beings/player/states/playerbleedout"] = "CustomHUD.lua",
		["lib/units/beings/player/huskplayermovement"] = "CustomHUD.lua",
		["lib/network/handlers/unitnetworkhandler"] = "CustomHUD.lua"
	}
	
	WolfHUD.hud_list = WolfHUD.hud_list or {													--HUD-List
		["lib/managers/hudmanagerpd2"] = "HUDList.lua",
		["lib/units/unitbase"] = "HUDList.lua",
		["lib/units/props/timergui"] = "HUDList.lua",
		["lib/units/props/digitalgui"] = "HUDList.lua",
		["lib/units/props/securitylockgui"] = "HUDList.lua",
		["lib/managers/group_ai_states/groupaistatebase"] = "HUDList.lua",
		["lib/network/handlers/unitnetworkhandler"] = "HUDList.lua",
		["lib/units/enemies/cop/copdamage"] = "HUDList.lua",
		["lib/managers/enemymanager"] = "HUDList.lua",
		["lib/units/equipment/ammo_bag/ammobagbase"] = "HUDList.lua",
--		["lib/units/equipment/first_aid_kit/firstaidkitbase"] = "HUDList.lua",
		["lib/units/equipment/doctor_bag/doctorbagbase"] = "HUDList.lua",
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] = "HUDList.lua",
		["lib/units/equipment/grenade_crate/grenadecratebase"] = "HUDList.lua",
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] = "HUDList.lua",
		["lib/units/props/securitycamera"] = "HUDList.lua",
		["lib/units/equipment/sentry_gun/sentrygunbase"] = "HUDList.lua",
		["lib/units/weapons/sentrygunweapon"] = "HUDList.lua",
		["lib/units/equipment/sentry_gun/sentrygundamage"] = "HUDList.lua",
		["lib/units/beings/player/playerdamage"] = "HUDList.lua",
		["lib/units/beings/player/playermovement"] = "HUDList.lua",
		["lib/managers/playermanager"] = "HUDList.lua",
		["lib/units/beings/player/states/playerstandard"] = "HUDList.lua",
		["lib/managers/objectinteractionmanager"] = "HUDList.lua",
		["lib/units/props/missiondoor"] = "HUDList.lua",
		["lib/managers/hud/hudassaultcorner"] = "HUDList.lua",
	}
	
	WolfHUD.kill_counter = WolfHUD.kill_counter or {												-- KillCounter
		["lib/managers/hudmanagerpd2"] = "KillCounter.lua",
		["lib/managers/hud/hudteammate"] = "KillCounter.lua",
		["lib/units/enemies/cop/copdamage"] = "KillCounter.lua",
		["lib/units/equipment/sentry_gun/sentrygunbase"] = "KillCounter.lua"
	}
	
	WolfHUD.scripts = WolfHUD.scripts or {
		["lib/managers/hud/hudstatsscreen"] = "Scripts.lua",				--Stats on TAB-Menu
		["lib/managers/hud/hudsuspicion"] = "Scripts.lua",					--Numeric Suspicion
		["lib/managers/hud/hudteammate"] = "Scripts.lua",					--Mags left
		["lib/states/ingamewaitingforplayers"] = "Scripts.lua",				--Skip Blackscreen
		["lib/managers/menu/stageendscreengui"] = "Scripts.lua",			--Skip EXP Screen
		["lib/managers/menu/lootdropscreengui"] = "Scripts.lua",			--Skip Lootscreen
		["lib/managers/group_ai_states/groupaistatebase"] = "Scripts.lua",	--Pacified Civilian
		["lib/units/weapons/raycastweaponbase"] = "Scripts.lua",			--No Bullet-Bot-Collisions
		["lib/tweak_data/timespeedeffecttweakdata"] = "Scripts.lua",		--No SlowMotion (if Host)
		["lib/managers/enemymanager"] = "Scripts.lua",						-- Corpse limit
		["lib/managers/hudmanager"] = "EnemyHealthbar.lua",					--Healthbar for enemies
		["lib/units/beings/player/states/playerstandard"] = "EnemyHealthbar.lua"
	}
	
	WolfHUD.interaction = WolfHUD.interaction or {							--Press2Hold + Numeric Interaction Timer
		["lib/managers/hudmanagerpd2"] = "Press2Hold.lua",
		["lib/managers/hud/hudinteraction"] = "Press2Hold.lua",
		["lib/units/beings/player/states/playercivilian"] = "Press2Hold.lua",
		["lib/units/beings/player/states/playerstandard"] = "Press2Hold.lua",
	}
	
	WolfHUD.weapon_gadgets = WolfHUD.weapon_gadgets or {
		["lib/units/weapons/weaponlaser"] = "WeaponLasers.lua" ,			--Custom Laser Color
		["lib/units/weapons/raycastweaponbase"] = "WeaponLasers.lua",		--Custom Laser Color
		["lib/units/weapons/newraycastweaponbase"] = "WeaponLasers.lua",	--Remember Gadget State
		["lib/units/beings/player/states/playerstandard"] = "WeaponLasers.lua",
		["lib/units/weapons/akimboweaponbase"] = "WeaponLasers.lua",
		["lib/units/weapons/weaponflashlight"] = "WeaponLasers.lua",
		["lib/managers/hudmanagerpd2"] = "WeaponLasers.lua",
		["lib/managers/hud/hudteammate"] = "WeaponLasers.lua"
	}
	
	
	function WolfHUD:Reset()
		WolfHUD.settings = 
		{
		  --General
			use_customhud = true,
			use_killcounter = true,
			use_hudlist = true,
			use_press2hold = true,
			use_weaponlasers = true,
		  --CustomHUD
			PLAYER_PANEL_SCALE = 0.85,
			TEAMMATE_PANEL_SCALE = 0.75,
		  --HUDList
			show_timers = true,     				--Drills, time locks, hacking etc.
			show_equipment = true,  				--Deployables (ammo, doc bags, body bags)
			show_sentries = true,   				--Deployable sentries
				hide_empty_sentries = true, 		--Hide sentries with no ammo if player lacks the skill to refill them
			show_ecms = true,       				--Active ECMs
			show_ecm_retrigger = true,      		--Countdown for players own ECM feedback retrigger delay
			show_minions = true,    				--Converted enemies, type and health
			show_pagers = true,     				--Show currently active pagers
			show_tape_loop = true,  				--Show active tape loop duration
			remove_answered_pager_contour = true,   --Removes the interaction contour on answered pagers

			show_enemies = true,		    		--Currently spawned enemies
				aggregate_enemies = false,  		--Don't split enemies on type; use a single entry for all
			show_turrets = true,    				--Show active SWAT turrets
			show_civilians = true,  				--Currently spawned, untied civs
			show_hostages = true,   				--Currently tied civilian and dominated cops
			show_minion_count = true,       		--Current number of jokered enemies
			show_pager_count = true,				--Show number of triggered pagers (only counts pagers triggered while you were present)
			show_loot = true,       				--Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
				aggregate_loot = false, 			--Don't split loot on type; use a single entry for all
				separate_bagged_loot = true,     	--Show bagged loot as a separate value
			show_special_pickups = true,    		--Show number of special equipment/items

			show_buffs = true,      				--Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
		  --KillCounter
			SHOW_SPECIAL_KILLS = true,				--KillCounter shows special kills
			SHOW_HEADSHOT_KILLS = true,				--KillCounter shows headshot kills
			SHOW_AI_KILLS = true,					--Show KillCounter for Bots
		  --Press2Hold
			LOCK_MODE = 2,					 		--Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time, or current interaction time
			MIN_TIMER_DURATION = 5, 		 		--Min interaction duration (in seconds) for the toggle behavior to activate
			EQUIPMENT_PRESS_INTERRUPT = true, 		--Use the equipment key ('G') to toggle off active interactions
			SHOW_TIME_REMAINING = true,		 		--Show remaining Time in the Interaction-Circle
			GRADIENT_COLOR = 28,	 				--Color, which the timer reaches on completition
		  --Scripts
			skip_blackscreen = true,				--Skip the blackscreen on mission start
			stat_screen_delay = 5,					--Skip the experience screen after X seconds
			loot_screen_delay = 3,					--Skip the loot screen after X seconds
			max_corpses = 100,						--Maximum number of laying around corpses
		  --Enemy Healthbar
			show_enemy_healthbar = true,
			show_civilians_healthbar = false,
			show_healthbar_pointer = false,
		  --Laser-Colors
			laser_player = 9,
			laser_player_alpha = 0.3,
			laser_teammates = 9,
			laser_teammates_alpha = 0.15,
			laser_sniper = 14,
			laser_sniper_alpha = 0.5,
			laser_turret_active = 14,
			laser_turret_alpha = 0.15,
			laser_turret_reloading = 17,
			laser_turret_jammed = 29,
			flashlight_angle = 100,
			flashlight_range = 20
		}
	end
	
	function WolfHUD:Load()
		local file = io.open(self.save_path, "r")
		if file then
			for k, v in pairs(json.decode(file:read("*all"))) do
				self.settings[k] = v
			end
			file:close()
		end
	end

	function WolfHUD:Save()
		local file = io.open(self.save_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end
	
	WolfHUD:Reset()
	WolfHUD:Load()
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if WolfHUD.custom_hud[requiredScript] and WolfHUD.settings.use_customhud then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.custom_hud[requiredScript] )
	end
	if WolfHUD.hud_list[requiredScript] and WolfHUD.settings.use_hudlist then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.hud_list[requiredScript] )
	end
	if WolfHUD.kill_counter[requiredScript] and WolfHUD.settings.use_killcounter then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.kill_counter[requiredScript] )
	end
	if WolfHUD.scripts[requiredScript] then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.scripts[requiredScript] )
	end
	if WolfHUD.interaction[requiredScript] and WolfHUD.settings.use_press2hold then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.interaction[requiredScript] )
	end
	if WolfHUD.weapon_gadgets[requiredScript] then
		dofile( WolfHUD.mod_path .. "lua/" .. WolfHUD.weapon_gadgets[requiredScript] )
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_WolfHUD", function(loc)
	for _, filename in pairs(file.GetFiles(WolfHUD.mod_path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(WolfHUD.mod_path .. "loc/" .. filename)
			break
		end
	end
	
	loc:load_localization_file(WolfHUD.mod_path .. "loc/english.txt", false)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_WolfHUD", function(menu_manager)
	
	-- Define Callback methods here
	MenuCallbackHandler.WolfHUD_Save = function(this, item)
		WolfHUD:Save()
	end
	
	MenuCallbackHandler.callback_use_customhud = function(self, item)
		WolfHUD.settings.use_customhud = (item:value() =="on")
	end
	
	MenuCallbackHandler.callback_playerpanel_scale = function(self, item)
		WolfHUD.settings.PLAYER_PANEL_SCALE = item:value()
	end
	
	MenuCallbackHandler.callback_teammatepanel_scale = function(self, item)
		WolfHUD.settings.TEAMMATE_PANEL_SCALE = item:value()
	end
	
	MenuCallbackHandler.callback_use_killcounter = function(self, item)
		WolfHUD.settings.use_killcounter = (item:value() == "on")
		
	end
	
	MenuCallbackHandler.callback_show_special = function(self, item)
		WolfHUD.settings.SHOW_SPECIAL_KILLS = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_head = function(self, item)
		WolfHUD.settings.SHOW_HEADSHOT_KILLS = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_ai = function(self, item)
		WolfHUD.settings.SHOW_AI_KILLS = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_corpse_limit = function(self, item)
		WolfHUD.settings.max_corpses = item:value()
	end
	
	MenuCallbackHandler.callback_skip_blackscreen = function(self, item)
		WolfHUD.settings.skip_blackscreen = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_statscreen_delay = function(self, item)
		WolfHUD.settings.stat_screen_delay = item:value()
	end
	
	MenuCallbackHandler.callback_lootscreen_delay = function(self, item)
		WolfHUD.settings.loot_screen_delay = item:value()
	end
	
	MenuCallbackHandler.callback_use_hudlist = function(self, item)
		WolfHUD.settings.use_hudlist = (item:value() =="on")
	end
	
	MenuCallbackHandler.callback_use_press2hold = function(self, item)
		WolfHUD.settings.use_press2hold = (item:value() =="on")
	end
	
	MenuCallbackHandler.callback_use_weaponlasers = function(self, item)
		WolfHUD.settings.use_weaponlasers = (item:value() =="on")
	end
	
	MenuCallbackHandler.callback_show_timers = function(self, item)
		WolfHUD.settings.show_timers = (item:value() =="on")
	end

	MenuCallbackHandler.callback_show_equipment = function(self, item)
		WolfHUD.settings.show_equipment = (item:value() =="on")
	end

	MenuCallbackHandler.callback_show_minions = function(self, item)
		WolfHUD.settings.show_minions = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_pagers = function(self, item)
		WolfHUD.settings.show_pagers = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_remove_answered_pager_contour = function(self, item)
		WolfHUD.settings.remove_answered_pager_contour = (item:value() =="on")
	end

	MenuCallbackHandler.callback_show_ecms = function(self, item)
		WolfHUD.settings.show_ecms = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_enemies = function(self, item)
		WolfHUD.settings.show_enemies = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_aggregate_enemies = function(self, item)
		WolfHUD.settings.aggregate_enemies = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_civilians = function(self, item)
		WolfHUD.settings.show_civilians = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_hostages = function(self, item)
		WolfHUD.settings.show_hostages = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_pager_count = function(self, item)
		WolfHUD.settings.show_pager_count = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_loot = function(self, item)
		WolfHUD.settings.show_loot = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_aggregate_loot = function(self, item)
		WolfHUD.settings.aggregate_loot = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_separate_bagged_loot = function(self, item)
		WolfHUD.settings.separate_bagged_loot = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_special_pickups = function(self, item)
		WolfHUD.settings.show_special_pickups = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_buffs = function(self, item)
		WolfHUD.settings.show_buffs = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_special_kills = function(self, item)
		WolfHUD.settings.SHOW_SPECIAL_KILLS = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_headshot_kills = function(self, item)
		WolfHUD.settings.SHOW_HEADSHOT_KILLS = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_ai_kills = function(self, item)
		WolfHUD.settings.SHOW_AI_KILLS = (item:value() =="on")
	end	

	MenuCallbackHandler.callback_show_sentries = function(self, item)
		WolfHUD.settings.show_sentries = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_hide_empty_sentries = function(self, item)
		WolfHUD.settings.hide_empty_sentries = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_turrets = function(self, item)
		WolfHUD.settings.show_turrets = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_minion_count = function(self, item)
		WolfHUD.settings.show_minion_count = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_ecm_retrigger = function(self, item)
		WolfHUD.settings.show_ecm_retrigger = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_tape_loop = function(self, item)
		WolfHUD.settings.show_tape_loop = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_lock_mode = function(self, item)
		WolfHUD.settings.LOCK_MODE = item:value()
	end
	
	MenuCallbackHandler.callback_min_timer_duration = function(self, item)
		WolfHUD.settings.MIN_TIMER_DURATION = item:value()
	end
	
	MenuCallbackHandler.callback_equipment_cancel = function(self, item)
		WolfHUD.settings.EQUIPMENT_PRESS_INTERRUPT = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_timer = function(self, item)
		WolfHUD.settings.SHOW_TIME_REMAINING = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_timer_color = function(self, item)
		WolfHUD.settings.GRADIENT_COLOR = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_player = function(self, item)
		WolfHUD.settings.laser_player = item:value()
	end
	
	MenuCallbackHandler.callback_laseralpha_player = function(self, item)
		WolfHUD.settings.laser_player_alpha = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_teammates = function(self, item)
		WolfHUD.settings.laser_teammates = item:value()
	end
	
	MenuCallbackHandler.callback_laseralpha_teammates = function(self, item)
		WolfHUD.settings.laser_teammates_alpha = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_sniper = function(self, item)
		WolfHUD.settings.laser_sniper = item:value()
	end
	
	MenuCallbackHandler.callback_laseralpha_sniper = function(self, item)
		WolfHUD.settings.laser_sniper_alpha = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_active = function(self, item)
		WolfHUD.settings.laser_turret_active = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_reloading = function(self, item)
		WolfHUD.settings.laser_turret_reloading = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_jammed = function(self, item)
		WolfHUD.settings.laser_turret_jammed = item:value()
	end
	
	MenuCallbackHandler.callback_laseralpha_turret = function(self, item)
		WolfHUD.settings.laser_turret_alpha = item:value()
	end
	
	MenuCallbackHandler.callback_flashlight_angle = function(self, item)
		WolfHUD.settings.flashlight_angle = item:value()
	end
	
	MenuCallbackHandler.callback_flashlight_range = function(self, item)
		WolfHUD.settings.flashlight_range = item:value()
	end
	
	MenuCallbackHandler.callback_recommended_bltmods = function(self, item)
		-- TODO: Short info Box about BLT Mods
	end
	
	MenuCallbackHandler.callback_recommended_bagcontour = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("BC")
	end
	
	MenuCallbackHandler.callback_recommended_builddb = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("BDB")
	end
	
	MenuCallbackHandler.callback_recommended_enhanced_hitmarkers = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("ENH_HMRK")
	end
	
	MenuCallbackHandler.callback_recommended_inventorychatandplayerstates = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("ICAPS")
	end
	
	MenuCallbackHandler.callback_recommended_loadingscreeninfo = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("loadingscreeninfo")
	end
	
	MenuCallbackHandler.callback_recommended_lobbyplayerinfo = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("LPI")
	end
	
	MenuCallbackHandler.callback_recommended_pd2stats = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("pd2statsp")
	end
	
	MenuCallbackHandler.callback_recommended_pocohud3 = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("pocohud3")
	end
	
	MenuCallbackHandler.callback_recommended_sidejobsinlobby = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("SDJBL")
	end
	
	MenuCallbackHandler.callback_recommended_splsets = function(self, item)
		LuaModUpdates:OpenUpdateManagerNode()
		LuaModUpdates.ForceDownloadAndInstallMod("SPLS")
	end
	
	MenuCallbackHandler.callback_recommended_overridemods = function(self, item)
		-- TODO: Short info Box about 'mod_override'-Mods
	end
		
		-- TODO: Add Bodhi, Crime.net/Stealthmeter, Fednet Inventory, PDTH Blood Decals, SentryLaser Upgrade, Smoking_Barrels to recommended mod_overrides.
		
	WolfHUD:Load()
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/options.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hudlist.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/press2hold.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/lasers.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/recommended.txt", WolfHUD, WolfHUD.settings)
end)

