if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath .. "WolfHUD.txt"
	WolfHUD.menu_ids = { "wolfhud_options_menu", "wolfhud_lowerhud_options_menu", "wolfhud_upperhud_options_menu", "wolfhud_upperhud_adv_options_menu", "wolfhud_dmgindicator_options_menu", "wolfhud_enemyhealthbar_options_menu", "wolfhud_press2hold_options_menu", "wolfhud_lasers_options_menu" }
	
	if not WolfHUD.color_table then
		WolfHUD.color_table = {}
		WolfHUD.color_table[1]  = Color('FFFFFF')		--1:  White
		WolfHUD.color_table[2]  = Color('F2F250')		--2:  Light_Yellow
		WolfHUD.color_table[3]  = Color('F2C24E')		--3:  Light_Orange
		WolfHUD.color_table[4]  = Color('E55858')		--4:  Light_Red
		WolfHUD.color_table[5]  = Color('CC55CC')		--5:  Light_Purple
		WolfHUD.color_table[6]  = Color('00FF00')		--6:  Light_Green
		WolfHUD.color_table[7]  = Color('00FFFF') 		--7:  Light_Blue
		WolfHUD.color_table[8]  = Color('FFFF00')		--8:  Yellow
		WolfHUD.color_table[9]  = Color('FFA500')		--9:  Orange
		WolfHUD.color_table[10] = Color('FF0000')		--10: Red
		WolfHUD.color_table[11] = Color('800080')		--11: Purple
		WolfHUD.color_table[12] = Color('008000')		--12: Green
		WolfHUD.color_table[13] = Color('0000FF')		--13: Blue
		WolfHUD.color_table[14] = Color('808080')		--14: Gray
		WolfHUD.color_table[15] = Color('000000')		--15: Black
		WolfHUD.color_table[16] = Color('000000')		--16: Rainbow (only available in laser colors)
	end
	
	WolfHUD.hook_files = WolfHUD.hook_files or {
		["lib/managers/menumanager"] = { "MenuTweaks.lua" },
		["lib/managers/menumanagerdialogs"] = { "MenuTweaks.lua" },
		["lib/managers/chatmanager"] = { "MenuTweaks.lua" },
		["lib/managers/hudmanager"] = { "EnemyHealthbar.lua" },
		["lib/managers/hudmanagerpd2"] = { "CustomHUD.lua", "HUDList.lua", "KillCounter.lua", "DownCounter.lua", "DrivingHUD.lua", "DamageIndicator.lua", "Interaction.lua", "WeaponLasers.lua" },
		["lib/managers/playermanager"] = { "HUDList.lua" },
		["lib/managers/trademanager"] = { "DownCounter.lua" },
		["lib/managers/hud/huddriving"] = { "DrivingHUD.lua" },
		["lib/managers/hud/hudteammate"] = { "CustomHUD.lua", "KillCounter.lua", "DownCounter.lua", "Scripts.lua", "WeaponLasers.lua" },
		["lib/managers/hud/hudtemp"] = { "CustomHUD.lua" },
		["lib/managers/hud/hudassaultcorner"] = { "CustomHUD.lua", "HUDList.lua" },
		["lib/managers/hud/hudobjectives"] = { "CustomHUD.lua" },
		["lib/managers/hud/hudheisttimer"] = { "CustomHUD.lua" },
		["lib/managers/hud/hudchat"] = { "CustomHUD.lua" },
		["lib/managers/hud/hudstatsscreen"] = { "Scripts.lua" },
		["lib/managers/hud/hudinteraction"] = { "Interaction.lua" },
		["lib/managers/hud/hudsuspicion"] = { "Scripts.lua" },
		["lib/managers/hud/hudhitdirection"] = { "DamageIndicator.lua" },
		["lib/managers/enemymanager"] = { "HUDList.lua", "KillCounter.lua" },
		["lib/managers/group_ai_states/groupaistatebase"] = { "HUDList.lua", "Scripts.lua" },
		["lib/managers/missionassetsmanager"] = { "MenuTweaks.lua" },
		["lib/managers/menu/blackmarketgui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/stageendscreengui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/lootdropscreengui"] = { "MenuTweaks.lua" },
		["lib/managers/menu/renderers/menunodeskillswitchgui"] = { "MenuTweaks.lua" },
		["lib/managers/objectinteractionmanager"] = { "HUDList.lua", "Interaction.lua" },
		["lib/network/handlers/unitnetworkhandler"] = { "DownCounter.lua", "HUDList.lua" },
		["lib/units/unitbase"] = { "HUDList.lua" },
		["lib/units/props/timergui"] = { "HUDList.lua" },
		["lib/units/props/digitalgui"] = { "HUDList.lua" },
		["lib/units/props/securitylockgui"] = { "HUDList.lua" },
		["lib/units/enemies/cop/copdamage"] = { "HUDList.lua", "KillCounter.lua" },
		["lib/units/equipment/ammo_bag/ammobagbase"] = { "HUDList.lua" },
		["lib/units/equipment/bodybags_bag/bodybagsbagbase"] = { "HUDList.lua" },
		["lib/units/equipment/doctor_bag/doctorbagbase"] = { "DownCounter.lua", "HUDList.lua" },
		["lib/units/equipment/ecm_jammer/ecmjammerbase"] = { "HUDList.lua" },
		["lib/units/equipment/grenade_crate/grenadecratebase"] = { "HUDList.lua" },
		["lib/units/equipment/sentry_gun/sentrygunbase"] = { "HUDList.lua", "KillCounter.lua" },
		["lib/units/equipment/sentry_gun/sentrygundamage"] = { "HUDList.lua" },
		["lib/units/weapons/akimboweaponbase"] = { "WeaponLasers.lua" },
		["lib/units/weapons/sentrygunweapon"] = { "HUDList.lua" },
		["lib/units/weapons/weaponlaser"] = { "WeaponLasers.lua" },
		["lib/units/weapons/weaponflashlight"] = { "WeaponLasers.lua" },
		["lib/units/weapons/raycastweaponbase"] = { "Scripts.lua", "WeaponLasers.lua" },
		["lib/units/weapons/newraycastweaponbase"] = { "WeaponLasers.lua" },
		["lib/units/props/missiondoor"] = { "HUDList.lua" },
		["lib/units/props/securitycamera"] = { "HUDList.lua" },
		["lib/units/beings/player/playerdamage"] = { "HUDList.lua", "DamageIndicator.lua" },
		["lib/units/beings/player/playermovement"] = { "HUDList.lua" },
		["lib/units/beings/player/huskplayermovement"] = { "DownCounter.lua" },
		["lib/units/beings/player/states/playercivilian"] = { "Interaction.lua" },
		["lib/units/beings/player/states/playerstandard"] = { "HUDList.lua", "EnemyHealthbar.lua", "Interaction.lua", "WeaponLasers.lua" },
		["lib/units/beings/player/states/playerbleedout"] = { "DownCounter.lua" },
		["lib/units/vehicles/vehicledamage"] = { "DamageIndicator.lua" },
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
			PLAYER_PANEL_SCALE 				= 0.85,		--Size of local Player HUD Panel
			TEAMMATE_PANEL_SCALE 			= 0.75,		--Size of Teammates/AI's HUD Panels
			LINE_HEIGHT						= 15,		--Chat font Size
			MAX_OUTPUT_LINES				= 8,		--Chat Output lines
			colorize_healthbars				= 1,		--1 = none, 2 = peer color, 3 = health amount
			show_downcounter 				= true,
			use_realammo					= true,
		  --KillCounter
			use_killcounter 				= true,
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
			dmg_shield_color				= 1,
			dmg_health_color				= 10,
			dmg_crit_color					= 11,
			dmg_vehicle_color				= 8,
			dmg_friendlyfire_color			= 9,
		  --Driving HUD
			use_drivinghud					= true,		--Show DrivingHUD Panel
			show_vehicle 					= true,		--Show Vehicle and Teammate Mask Images
			speed_in_mph 					= false,	--Display Speed in mph
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

			show_buffs 						= 1,     --Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
			
			use_hudlist 					= true,
			hud_box_color 					= 1,		--Left and Right List font color
			hud_box_bg_color 				= 14,		--Left and Right List BG color
			civilian_color 					= 1, 		--EnemyCounter Civillian and Hostage icon color
			thug_color 						= 1,		--EnemyCounter Thug and Mobster icon color
			enemy_color 					= 1,		--EnemyCounter Cop and Specials icon color
		  --Press2Hold
			use_press2hold 					= true,
			LOCK_MODE 						= 2,		--Lock interaction, if MIN_TIMER_DURATION is longer then total interaction time, or current interaction time
			MIN_TIMER_DURATION 				= 5, 		--Min interaction duration (in seconds) for the toggle behavior to activate
			EQUIPMENT_PRESS_INTERRUPT 		= true, 	--Use the equipment key ('G') to toggle off active interactions
			SHOW_LOCK_INDICATOR				= true,
			SHOW_TIME_REMAINING 			= true,		--Show remaining Time in the Interaction-Circle
			GRADIENT_COLOR 					= 6,	 	--Color, which the timer reaches on completition
			SUPRESS_NADES_STEALTH			= true,
			HOLD2PICK						= true,
		  --Laser-Colors
			laser_remember_state			= true,
			laser_autoon					= true,
			use_weaponlasers 				= true,
		    laser_light 					= 10,		--Multiplier for laser dot
			laser_glow 						= 5,		--Divider for laser beam
			laser_player 					= 7,		--Player laser color id
			laser_player_alpha 				= 0.3,		--Player laser alpha
			laser_teammates 				= 7,		--Teammates laser color id
			laser_teammates_alpha 			= 0.15,		--Teammates laser alpha
			laser_sniper 					= 10,		--Sniper laser color id
			laser_sniper_alpha 				= 0.5,		--Sniper laser alpha
			laser_turret_active 			= 10,		--Active turret laser color id
			laser_turret_reloading 			= 8,		--Reloading turret laser color id
			laser_turret_jammed 			= 12,		--Jammed turret laser color id
			laser_turret_alpha 				= 0.15,		--Turret laser alpha
			flashlight_angle 				= 100,		--Flashlight angle
			flashlight_range 				= 20,		--Flashlight range (in m)
			
			replace_weapon_names 			= true,
			use_federal_inventory 			= true
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
	
	function WolfHUD:createOverridesDummies()
		local updates = {}
		for k, v in pairs(LuaModManager.Mods) do
			local info = v.definition
			if info["name"] == "WolfHUD" then
				updates = info["updates"]
			end
		end
		for k, v in pairs(updates) do
			if type(v["revision"]) == "string" and not io.file_is_readable( v["revision"] ) then
				if v["identifier"] ~= "fed_inv" or WolfHUD.settings.use_federal_inventory then
					if not file.DirectoryExists("./" .. v["install_dir"] .. v["install_folder"]) then
						os.execute('cmd /c mkdir "./' .. v["install_dir"] .. v["install_folder"] .. '"')
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
	
	WolfHUD:Reset()
	WolfHUD:Load()
	
	WolfHUD:createOverridesDummies()
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if WolfHUD.hook_files[requiredScript] then
		for __, file in ipairs(WolfHUD.hook_files[requiredScript]) do
			dofile( WolfHUD.mod_path .. "lua/" .. file )
		end
	end
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
	
	if WolfHUD.settings.replace_weapon_names then
		loc:load_localization_file(WolfHUD.mod_path .. "loc/RealWeaponNames.txt")
	end
	
	if WolfHUD.settings.skip_blackscreen then
		loc:add_localized_strings({
			["hud_skip_blackscreen"] = ""
		})
	end
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
							if WolfHUD.settings[item_id] ~= nil and menu_item.set_value then
								local value = WolfHUD.settings[item_id]
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
	
	MenuCallbackHandler.clbk_change_hudlist_setting = function(self, item)
		self:clbk_change_setting(item)
		local name = item:parameters().name
		if HUDManager then HUDManager:change_list_setting(tostring(name), WolfHUD.settings[name]) end
	end
	
	WolfHUD:Load()
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/options.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/interaction.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_enemy_healthbar.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_damage_indicator.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_info_adv.json", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_teampanels.json", WolfHUD, WolfHUD.settings)
end)