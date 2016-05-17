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
		"wolfhud_infopanels_adv_options_menu", 
		"wolfhud_tabstats_options_menu",
		"wolfhud_dmgindicator_options_menu", 
		"wolfhud_enemyhealthbar_options_menu", 
		"wolfhud_press2hold_options_menu", 
		"wolfhud_lasers_options_menu" 
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
			{ color = Color('000000'), name = "rainbow" },		--(only available in laser + killcounter colors)
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
		["lib/setups/gamesetup"] = { "GameInfoManager.lua" },
		["lib/managers/menumanager"] = { "MenuTweaks.lua" },
		["lib/managers/menumanagerdialogs"] = { "MenuTweaks.lua" },
		["lib/managers/chatmanager"] = { "MenuTweaks.lua" },
		["lib/managers/localizationmanager"] = { "AdvAssault.lua" },
		["lib/managers/experiencemanager"] = { "Scripts.lua" },
		["lib/managers/moneymanager"] = { "Scripts.lua" },
		["lib/managers/hudmanager"] = { "EnemyHealthbar.lua", "TabStats.lua" },
		["lib/managers/hudmanagerpd2"] = { "CustomHUD.lua", "HUDChat.lua", "HUDList.lua", "KillCounter.lua", "DownCounter.lua", "DrivingHUD.lua", "DamageIndicator.lua", "Interaction.lua", "Scripts.lua", "BurstFire.lua", "AdvAssault.lua" },
		["lib/managers/statisticsmanager"] = { "KillCounter.lua" },
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
		["lib/managers/objectinteractionmanager"] = { "GameInfoManager.lua", "Interaction.lua" },
		["lib/network/handlers/unitnetworkhandler"] = { "DownCounter.lua", "GameInfoManager.lua" },
		["lib/units/props/timergui"] = { "GameInfoManager.lua" },
		["lib/units/props/digitalgui"] = { "GameInfoManager.lua" },
		["lib/units/props/securitylockgui"] = { "GameInfoManager.lua" },
		["lib/units/enemies/cop/copdamage"] = { "GameInfoManager.lua", "KillCounter.lua", "TabStats.lua" },
		["lib/units/equipment/ammo_bag/ammobagbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/doctor_bag/doctorbagbase"] = { "DownCounter.lua", "GameInfoManager.lua" },
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/grenade_crate/grenadecratebase"] = { "GameInfoManager.lua" },
		["lib/units/equipment/sentry_gun/sentrygunbase"] = { "GameInfoManager.lua", "KillCounter.lua" },
		["lib/units/equipment/sentry_gun/sentrygundamage"] = { "GameInfoManager.lua" },
		["lib/units/interactions/interactionext"] = { "Interaction.lua" },
		["lib/units/weapons/akimboweaponbase"] = { "BurstFire.lua" },
		["lib/units/weapons/sentrygunweapon"] = { "GameInfoManager.lua" },
		["lib/units/weapons/weaponlaser"] = { "WeaponLasers.lua" },
		["lib/units/weapons/weaponflashlight"] = { "WeaponLasers.lua" },
		["lib/units/weapons/raycastweaponbase"] = { "Scripts.lua", "WeaponLasers.lua" },
		["lib/units/weapons/newraycastweaponbase"] = { "WeaponLasers.lua", "BurstFire.lua" },
		["lib/units/props/securitycamera"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/playerdamage"] = { "GameInfoManager.lua", "DamageIndicator.lua" },
		["lib/units/beings/player/playermovement"] = { "GameInfoManager.lua" },
		["lib/units/beings/player/huskplayermovement"] = { "DownCounter.lua" },
		["lib/units/beings/player/states/playercivilian"] = { "Interaction.lua" },
		["lib/units/beings/player/states/playerstandard"] = { "GameInfoManager.lua", "EnemyHealthbar.lua", "Interaction.lua", "BurstFire.lua" },
		["lib/units/beings/player/states/playerbleedout"] = { "DownCounter.lua" },
		["lib/units/vehicles/vehicledamage"] = { "DamageIndicator.lua" },
		["lib/player_actions/skills/playeractionbloodthirstbase"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionexperthandling"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractionshockandawe"] = { "GameInfoManager.lua" },
		["lib/player_actions/skills/playeractiondireneed"] = { "GameInfoManager.lua" },
		["lib/states/ingamedriving"] = { "DrivingHUD.lua" },
		["lib/states/ingamewaitingforplayers"] = { "MenuTweaks.lua" },
		["lib/tweak_data/guitweakdata"] = { "MenuTweaks.lua" },	
		["lib/tweak_data/timespeedeffecttweakdata"] = { "Scripts.lua" },
		["core/lib/managers/menu/items/coremenuitemslider"] = { "MenuTweaks.lua" },
	}
	
	
	function WolfHUD:Reset()
		WolfHUD.settings = 
		{
		  --CustomHUD
			use_customhud 					= true,
			PLAYER_PANEL_SCALE 				= 1,		--Size of local Player HUD Panel
			PLAYER_PANEL_OPPACITY			= 0.85,
			PLAYER_PANEL_NAME				= false,
			PLAYER_PANEL_RANK				= false,
			PLAYER_PANEL_CHARACTER			= false,
--			PLAYER_PANEL_LATENCY			= false,
			PLAYER_PANEL_STATUS				= true,
			PLAYER_PANEL_EQUIPMENT			= true,
			PLAYER_PANEL_SPECIAL_EQUIPMENT	= true,
			PLAYER_PANEL_CALLSIGN			= false,
			PLAYER_PANEL_CARRY				= true,
--			PLAYER_PANEL_BUILD				= 0,
			PLAYER_PANEL_WEAPON_ICON		= 4,
			PLAYER_PANEL_WEAPON_NAME		= 1,
			PLAYER_PANEL_WEAPON_AMMO		= 4,
			PLAYER_PANEL_WEAPON_FIREMODE	= 2,
--			PLAYER_PANEL_INTERACTION		= 0,
			TEAMMATE_PANEL_SCALE 			= 0.8,		--Size of Teammates/AI's HUD Panels
			TEAM_PANEL_OPPACITY				= 0.85,
			TEAM_PANEL_NAME					= true,
			TEAM_PANEL_RANK					= true,
			TEAM_PANEL_CHARACTER			= false,
			TEAM_PANEL_LATENCY				= true,
			TEAM_PANEL_STATUS				= true,
			TEAM_PANEL_EQUIPMENT			= true,
			TEAM_PANEL_SPECIAL_EQUIPMENT	= true,
			TEAM_PANEL_CALLSIGN				= false,
			TEAM_PANEL_CARRY				= true,
			TEAM_PANEL_BUILD				= 15,
			TEAM_PANEL_WEAPON_ICON			= 4,
			TEAM_PANEL_WEAPON_NAME			= 1,
			TEAM_PANEL_WEAPON_AMMO			= 4,
			TEAM_PANEL_WEAPON_FIREMODE		= 1,
			TEAM_PANEL_SHOW_INTERACTION		= true,
			TEAM_PANEL_INTERACTION			= 1,
			colorize_healthbars				= 2,		--Colorize mode: 1 = none, 2 = by peer id, 3 = by health amount
			show_downcounter 				= true,	
			use_realammo					= true,
		  --HUDChat
			CHAT_WAIT_TIME					= 10,		--Time before chat fades out
			LINE_HEIGHT						= 15,		--Chat font Size
			MAX_OUTPUT_LINES				= 8,		--Chat Output lines
		  --KillCounter
			use_killcounter 				= true,
			killcounter_color				= "yellow",
			SHOW_SPECIAL_KILLS 				= true,		--KillCounter shows special kills
			SHOW_HEADSHOT_KILLS 			= true,		--KillCounter shows headshot kills
			SHOW_AI_KILLS 					= true,		--Show KillCounter for Bots
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
		  --Suspicion
			numberic_suspicion				= true,
			show_susp_eye					= true,
		  --Driving HUD
			use_drivinghud					= true,		--Show DrivingHUD Panel
			show_vehicle 					= true,		--Show Vehicle and Teammate Mask Images
			speed_in_mph 					= false,	--Display Speed in mph
		  --TabStats
			use_tabstats					= true,
			clock_mode						= 3,		-- 1 = disabled, 2 = 12h, 3 = 24h
			use_actual_mask					= true,
			numberic_loot					= true,
		  --Scripts
			skip_blackscreen 				= true,		--Skip the blackscreen on mission start
			stat_screen_delay 				= 5,		--Skip the experience screen after X seconds
			loot_screen_delay 				= 3,		--Skip the loot screen after X seconds
			spam_filter						= true,		--Filter PocoHud and NGBTO Chat Spam messages.
		  --HUDList
			show_timers 					= true,     --Drills, time locks, hacking etc.
			show_equipment 					= true,  	--Deployables (ammo, doc bags, body bags)
			show_sentries 					= true,   	--Deployable sentries
				hide_empty_sentries 		= true, 	--Hide sentries with no ammo if player lacks the skill to refill them
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
			show_minion_count 				= true,     --Current number of jokered enemies
			show_pager_count 				= true,		--Show number of triggered pagers (only counts pagers triggered while you were present)
			show_loot 						= true,     --Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
				aggregate_loot 				= false, 	--Don't split loot on type; use a single entry for all
				separate_bagged_loot 		= true,     --Show bagged loot as a separate value
			show_special_pickups 			= true,    	--Show number of special equipment/items

			show_buffs 						= 1,     	--Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
			
			use_hudlist 					= true,
			hudlist_right_scale				= 1,
			hudlist_left_scale				= 1,
			hudlist_buff_scale				= 1,
			hud_box_color 					= "white",		--Left and Right List font color
			hud_box_bg_color 				= "black",		--Left and Right List BG color
			civilian_color 					= "white", 		--EnemyCounter Civillian and Hostage icon color
			thug_color 						= "white",		--EnemyCounter Thug and Mobster icon color
			enemy_color 					= "white",		--EnemyCounter Cop and Specials icon color
		  --Press2Hold
			LOCK_MODE 						= 3,			--Disabled (1, Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time (2), or current interaction time(3)
			MIN_TIMER_DURATION 				= 5, 			--Min interaction duration (in seconds) for the toggle behavior to activate
			EQUIPMENT_PRESS_INTERRUPT 		= true, 		--Use the equipment key ('G') to toggle off active interactions
			SHOW_LOCK_INDICATOR				= true,
			SHOW_CIRCLE						= true,
			SHOW_INTERRUPT_HINT				= true,
			SHOW_TIME_REMAINING 			= true,			--Show remaining Time in the Interaction-Circle
			GRADIENT_COLOR 					= "light_green",--Color, which the timer reaches on completition
			SHOW_RELOAD						= true,
			SHOW_MELEE						= false,
			SUPRESS_NADES_STEALTH			= true,
			HOLD2PICK						= true,
		  --Laser-Colors
			laser_remember_state			= true,
			laser_autoon					= true,
			use_weaponlasers 				= true,
		    laser_light 					= 10,			--Multiplier for laser dot
			laser_glow 						= 5,			--Divider for laser beam
			laser_player 					= "light_blue",	--Player laser color id
			laser_player_alpha 				= 0.3,			--Player laser alpha
			laser_teammates 				= "light_blue",	--Teammates laser color id
			laser_teammates_alpha 			= 0.15,			--Teammates laser alpha
			laser_sniper 					= "red",		--Sniper laser color id
			laser_sniper_alpha 				= 0.5,			--Sniper laser alpha
			laser_turret_active 			= "red",		--Active turret laser color id
			laser_turret_reloading 			= "yellow",		--Reloading turret laser color id
			laser_turret_jammed 			= "green",		--Jammed turret laser color id
			laser_turret_alpha 				= 0.15,			--Turret laser alpha
			flashlight_angle 				= 100,			--Flashlight angle
			flashlight_range 				= 20,			--Flashlight range (in m)
			
			show_advanced_assault			= true,
			replace_weapon_names 			= true,
			enable_burstmode				= true
		}
	end
	
	function WolfHUD:print_log(text)
		if self.DEBUG_MODE then
			log("[WolfHUD] " .. text)
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
		end
		if corrupt then 
			self:Save()
		end
	end

	function WolfHUD:Save()
		local file = io.open(self.settings_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
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
							log("mod_override folder '" .. v["install_folder"] .. "' is missing!")
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
	if _G.PD2KR then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/korean.txt")
	else
		for _, filename in pairs(file.GetFiles(WolfHUD.mod_path .. "loc/")) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(WolfHUD.mod_path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(WolfHUD.mod_path .. "loc/english.txt", false)
	
	if WolfHUD:getSetting("replace_weapon_names", "boolean") then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/RealWeaponNames.txt")
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
		["hud_int_hold_take_artifact"] = "", 
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
		if HUDManager then HUDManager:change_list_setting(tostring(name), WolfHUD:getSetting(name)) end
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
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/interaction.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_enemy_healthbar.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damage_indicator.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_tabstats.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_adv.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_panels.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_teampanels.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_playerpanel.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_chat.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_killcounter.json", WolfHUD, settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_drivinghud.json", WolfHUD, settings)
end)

--[[
Hooks:Add("MenuManagerPostInitialize", "MenuManagerPostInitialize_WolfHUD", function(menu_manager)
	for __, menu_id in ipairs(WolfHUD.menu_ids) do
		local menu = MenuHelper:GetMenu(menu_id)
		for __, menu_item in ipairs(menu._items) do
			if menu_item._type == "multiple_choice" and #menu_item._options <= 0 then
				menu_item:clear_options()
				for id, data in ipairs(WolfHUD.color_table) do
					menu_item:add_option(CoreMenuItemOption.ItemOption:new({
						_meta = "option",
						text_id = "wolfhud_color_" .. (data.name or "unknown"),
						value = data.name,
						localize = true
					}))
				end
				local item_id = menu_item:parameters().name
				local value = WolfHUD:getSetting(tostring(item_id), "string")
				menu_item:set_value(value)
			end
		end
	end
end)
]]