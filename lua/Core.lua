if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.overrides = { {path = "assets/mod_overrides/WolfHUD_Textures/", file = "WolfHUD_Textures.zip", version = 2} }
	WolfHUD.save_path = SavePath .. "WolfHUD.txt"
	WolfHUD.menu_ids = { "wolfhud_options_menu", "wolfhud_lowerhud_options_menu", "wolfhud_upperhud_options_menu", "wolfhud_upperhud_adv_options_menu", "wolfhud_press2hold_options_menu", "wolfhud_lasers_options_menu" }
	
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
		WolfHUD.color_table[14] = Color('000000')		--14: Black
		WolfHUD.color_table[15] = Color('000000')		--15: Rainbow (only available in laser colors)
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
			
			replace_weapon_names 			= true
		}
	end
	
	function WolfHUD:Load()
		local file = io.open(self.save_path, "r")
		if file then
			for k, v in pairs(json.decode(file:read("*all"))) do
				if type(self.settings[k]) == type(v) then
					self.settings[k] = v
				end
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
	
	function WolfHUD:checkVersion()
		dohttpreq( "https://raw.githubusercontent.com/Kamikaze94/WolfHUD/master/mod.txt", function(data, id)
			local local_version = "1.0"
			local new_version = json.decode(data)
			
			for k, v in pairs(LuaModManager.Mods) do
				local info = v.definition
				if info["name"] == "WolfHUD" then
					local_version = info["version"]
				end
			end
			
			if tonumber(new_version.version) > tonumber(local_version) then
				log("[WolfHUD] Found new version! Server-Version: " .. new_version.version .. ", Client-Version: " .. local_version)
				local menu_title = managers.localization:text("wolfhud_update_title")
				local menu_message = managers.localization:text("wolfhud_update_confirm")
				local menu_options = {
					[1] = {
						text = managers.localization:text("dialog_yes"),
						callback = function(self, item)
							WolfHUD:update(new_version.contact, "mods/downloads/WolfHUD.zip")
						end,
					},
					[2] = {
						text = managers.localization:text("dialog_no"),
						callback = function(self, item)
							WolfHUD:checkOverrides()
						end,
					},
					[3] = {
						text = managers.localization:text("wolfhud_update_browser"),
						callback = function(self, item)
							os.execute("start " .. new_version.contact)
						end,
					},
				}
				QuickMenu:new( menu_title, menu_message, menu_options, true )
			else
				log("[WolfHUD] WolfHUD is already up-to-date! (Version: " .. local_version .. ")")
				WolfHUD:checkOverrides()
			end
		end)
	end
	
	function WolfHUD:update(url, file_path)
		if io.file_is_readable(file_path) then
			os.remove(file_path)
		end
		
		dohttpreq( url .. "/archive/master.zip", function(data, id)
			log("[WolfHUD] Beginning automated Update...")
			local success = true
			local file = io.open( file_path, "wb+" )
			if file then
				file:write( data )
				file:close()
			else
				success = false
			end
			if not io.file_is_readable(file_path) then
				log("[WolfHUD] New version could not be downloaded.")
				log("[WolfHUD] Aborting Update...")
				success = false
			end
			if success then
				unzip( file_path , "mods/" )
				local r, error_str = os.execute('rmdir /S /Q "' .. WolfHUD.mod_path .. '"')
				if not r then
					log("[WolfHUD] Error while removing old version: " .. error_str)
					log("[WolfHUD] Aborting Update...")
					success = false
				end
			end
			if success then
				local r, error_str = os.execute('rename "mods\\WolfHUD-master" "WolfHUD"')
				if not r then
					log("[WolfHUD] Error while renaming new version: " .. error_str)
					log("[WolfHUD] Aborting Update...")
					success = false
				end
			end
			if success then
				local r, error_str = os.remove(file_path)
				if not r then
					log("[WolfHUD] Error while removing update file: " .. error_str)
				end
			end
			if success then log("[WolfHUD] Update successful!") end
			QuickMenu:new( managers.localization:text("wolfhud_update_title"), managers.localization:text("wolfhud_update_" .. (success and "successful" or "failed")), {[1] = {text = managers.localization:text("dialog_ok"), is_cancel_button = true}}, true )
		end)
	end
	
	function WolfHUD:checkOverrides()
		for _, override in ipairs(WolfHUD.overrides) do
			if io.file_is_readable( WolfHUD.mod_path .. override.file ) then
				local update = false
				if (not file.DirectoryExists( override.path )) then
					update = true
				else
					local file = io.open(override.path .. "revision.txt", "r")
					if file then
						local version = tonumber(file:read("*all"))
						file:close()
						if version < override.version then
							io.remove_directory_and_files(override.path)
							update = true
						else
							os.remove(WolfHUD.mod_path .. override.file)
						end
					end
				end
				if update then 
					log("[WolfHUD] Updating mod_override, using file: " .. override.file)
					unzip( WolfHUD.mod_path .. override.file, override.path )
					os.remove(WolfHUD.mod_path .. override.file)
					log("[WolfHUD] Update of mod_override successful.")
					QuickMenu:new( managers.localization:text("wolfhud_overrides_updated_title"), managers.localization:text("wolfhud_overrides_updated_text"), { [1] = { text = managers.localization:text("dialog_ok"), is_cancel_button = true } }, true )
				end
			end
		end
	end
	
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

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_WolfHUD", function(menu_manager, menu, position)
	if menu == "menu_main" then
		log("[WolfHUD] Checking for Updates...")
		WolfHUD:checkVersion()
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
	
	MenuCallbackHandler.callback_use_customhud = function(self, item)
		WolfHUD.settings.use_customhud = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_playerpanel_scale = function(self, item)
		WolfHUD.settings.PLAYER_PANEL_SCALE = item:value()
	end
	
	MenuCallbackHandler.callback_teammatepanel_scale = function(self, item)
		WolfHUD.settings.TEAMMATE_PANEL_SCALE = item:value()
	end
	
	MenuCallbackHandler.callback_chat_fontsize_scale = function(self, item)
		WolfHUD.settings.LINE_HEIGHT = item:value()
	end
	
	MenuCallbackHandler.callback_chat_outputlines = function(self, item)
		WolfHUD.settings.MAX_OUTPUT_LINES = item:value()
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
	
	MenuCallbackHandler.callback_show_enemyhealthbar = function(self, item)
		WolfHUD.settings.show_enemy_healthbar = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_civhealthbar = function(self, item)
		WolfHUD.settings.show_civilian_healthbar = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_carhealthbar = function(self, item)
		WolfHUD.settings.show_car_healthbar = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_healthbar_pointer = function(self, item)
		WolfHUD.settings.show_healthbar_pointer = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_dmg_indicator = function(self, item)
		WolfHUD.settings.show_dmg_indicator = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_dmg_ind_time = function(self, item)
		WolfHUD.settings.dmg_ind_time = item:value()
		if HUDHitDirection then HUDHitDirection.seconds = WolfHUD.settings.dmg_ind_time end
	end
	
	MenuCallbackHandler.callback_dmg_ind_size = function(self, item)
		WolfHUD.settings.dmg_ind_size = item:value()
		if HUDHitDirection then 
			HUDHitDirection.sizeStart = WolfHUD.settings.dmg_ind_size 
			HUDHitDirection.sizeEnd = WolfHUD.settings.dmg_ind_size + 100
		end
	end
	
	MenuCallbackHandler.callback_dmg_shield_color = function(self, item)
		WolfHUD.settings.dmg_shield_color = item:value()
		if HUDHitDirection then HUDHitDirection.shieldColor = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] end
	end
	
	MenuCallbackHandler.callback_dmg_health_color = function(self, item)
		WolfHUD.settings.dmg_health_color = item:value()
		if HUDHitDirection then HUDHitDirection.healthColor = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] end
	end
	
	MenuCallbackHandler.callback_dmg_crit_color = function(self, item)
		WolfHUD.settings.dmg_crit_color = item:value()
		if HUDHitDirection then HUDHitDirection.critColor = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] end
	end
	
	MenuCallbackHandler.callback_dmg_vehicle_color = function(self, item)
		WolfHUD.settings.dmg_vehicle_color = item:value()
		if HUDHitDirection then HUDHitDirection.vehicleColor = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] end
	end
	
	MenuCallbackHandler.callback_show_drivinghud = function(self, item)
		WolfHUD.settings.use_drivinghud = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_show_vehicleimage = function(self, item)
		WolfHUD.settings.show_vehicle = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_speed_in_mph = function(self, item)
		WolfHUD.settings.speed_in_mph = (item:value() == "on")
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
	
	MenuCallbackHandler.callback_spam_filter = function(self, item)
		WolfHUD.settings.spam_filter = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_replace_weapon_names = function(self, item)
		WolfHUD.settings.replace_weapon_names = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_use_hudlist = function(self, item)
		WolfHUD.settings.use_hudlist = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_use_press2hold = function(self, item)
		WolfHUD.settings.use_press2hold = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_use_weaponlasers = function(self, item)
		WolfHUD.settings.use_weaponlasers = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_hudlist_boxcolor = function(self, item)
		WolfHUD.settings.hud_box_color = item:value()
	end
	
	MenuCallbackHandler.callback_hudlist_boxbgcolor = function(self, item)
		WolfHUD.settings.hud_box_bg_color = item:value()
	end
	
	MenuCallbackHandler.callback_hudlist_civcolor = function(self, item)
		WolfHUD.settings.civilian_color = item:value()
	end
	
	MenuCallbackHandler.callback_hudlist_thugcolor = function(self, item)
		WolfHUD.settings.thug_color = item:value()
	end
	
	MenuCallbackHandler.callback_hudlist_copcolor = function(self, item)
		WolfHUD.settings.enemy_color = item:value()
	end
	
	MenuCallbackHandler.callback_show_timers = function(self, item)
		WolfHUD.settings.show_timers = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_timers", WolfHUD.settings.show_timers) end
	end

	MenuCallbackHandler.callback_show_equipment = function(self, item)
		WolfHUD.settings.show_equipment = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_equipment", WolfHUD.settings.show_equipment) end
	end

	MenuCallbackHandler.callback_show_minions = function(self, item)
		WolfHUD.settings.show_minions = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_minions", WolfHUD.settings.show_minions) end
	end	

	MenuCallbackHandler.callback_show_pagers = function(self, item)
		WolfHUD.settings.show_pagers = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_pagers", WolfHUD.settings.show_pagers) end
	end	

	MenuCallbackHandler.callback_remove_answered_pager_contour = function(self, item)
		WolfHUD.settings.remove_answered_pager_contour = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("remove_answered_pager_contour", WolfHUD.settings.remove_answered_pager_contour) end
	end

	MenuCallbackHandler.callback_show_ecms = function(self, item)
		WolfHUD.settings.show_ecms = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_ecms", WolfHUD.settings.show_ecms) end
	end	

	MenuCallbackHandler.callback_show_enemies = function(self, item)
		WolfHUD.settings.show_enemies = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_enemies", WolfHUD.settings.show_enemies) end
	end	

	MenuCallbackHandler.callback_aggregate_enemies = function(self, item)
		WolfHUD.settings.aggregate_enemies = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("aggregate_enemies", WolfHUD.settings.aggregate_enemies) end
	end	

	MenuCallbackHandler.callback_show_civilians = function(self, item)
		WolfHUD.settings.show_civilians = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_civilians", WolfHUD.settings.show_civilians) end
	end	

	MenuCallbackHandler.callback_show_hostages = function(self, item)
		WolfHUD.settings.show_hostages = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_hostages", WolfHUD.settings.show_hostages) end
	end	

	MenuCallbackHandler.callback_show_pager_count = function(self, item)
		WolfHUD.settings.show_pager_count = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_pager_count", WolfHUD.settings.show_pager_count) end
	end	

	MenuCallbackHandler.callback_show_loot = function(self, item)
		WolfHUD.settings.show_loot = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_loot", WolfHUD.settings.show_loot) end
	end	

	MenuCallbackHandler.callback_aggregate_loot = function(self, item)
		WolfHUD.settings.aggregate_loot = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("aggregate_loot", WolfHUD.settings.aggregate_loot) end
	end	

	MenuCallbackHandler.callback_separate_bagged_loot = function(self, item)
		WolfHUD.settings.separate_bagged_loot = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("separate_bagged_loot", WolfHUD.settings.separate_bagged_loot) end
	end	

	MenuCallbackHandler.callback_show_special_pickups = function(self, item)
		WolfHUD.settings.show_special_pickups = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_special_pickups", WolfHUD.settings.show_special_pickups) end
	end	

	MenuCallbackHandler.callback_show_buffs = function(self, item)
		WolfHUD.settings.show_buffs = item:value()
		if HUDManager then HUDManager:change_list_setting("show_buffs", WolfHUD.settings.show_buffs) end
	end	

	MenuCallbackHandler.callback_show_sentries = function(self, item)
		WolfHUD.settings.show_sentries = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_sentries", WolfHUD.settings.show_sentries) end
	end
	
	MenuCallbackHandler.callback_hide_empty_sentries = function(self, item)
		WolfHUD.settings.hide_empty_sentries = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("hide_empty_sentries", WolfHUD.settings.hide_empty_sentries) end
	end
	
	MenuCallbackHandler.callback_show_turrets = function(self, item)
		WolfHUD.settings.show_turrets = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_turrets", WolfHUD.settings.show_turrets) end
	end
	
	MenuCallbackHandler.callback_show_minion_count = function(self, item)
		WolfHUD.settings.show_minion_count = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_minion_count", WolfHUD.settings.show_minion_count) end
	end
	
	MenuCallbackHandler.callback_show_ecm_retrigger = function(self, item)
		WolfHUD.settings.show_ecm_retrigger = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_ecm_retrigger", WolfHUD.settings.show_ecm_retrigger) end
	end
	
	MenuCallbackHandler.callback_show_tape_loop = function(self, item)
		WolfHUD.settings.show_tape_loop = (item:value() == "on")
		if HUDManager then HUDManager:change_list_setting("show_tape_loop", WolfHUD.settings.show_tape_loop) end
	end
	
	MenuCallbackHandler.callback_lock_mode = function(self, item)
		WolfHUD.settings.LOCK_MODE = item:value()
		PlayerStandard.LOCK_MODE = WolfHUD.settings.LOCK_MODE
	end
	
	MenuCallbackHandler.callback_min_timer_duration = function(self, item)
		WolfHUD.settings.MIN_TIMER_DURATION = item:value()
		PlayerStandard.MIN_TIMER_DURATION = WolfHUD.settings.MIN_TIMER_DURATION
	end
	
	MenuCallbackHandler.callback_show_lockindicator = function(self, item)
		WolfHUD.settings.SHOW_LOCK_INDICATOR = (item:value() == "on")
		if HUDInteraction then HUDInteraction.SHOW_LOCK_INDICATOR = WolfHUD.settings.SHOW_LOCK_INDICATOR end
	end
	
	MenuCallbackHandler.callback_equipment_cancel = function(self, item)
		WolfHUD.settings.EQUIPMENT_PRESS_INTERRUPT = (item:value() == "on")
		if PlayerStandard then PlayerStandard.EQUIPMENT_PRESS_INTERRUPT = WolfHUD.settings.EQUIPMENT_PRESS_INTERRUPT end
	end
	
	MenuCallbackHandler.callback_show_timer = function(self, item)
		WolfHUD.settings.SHOW_TIME_REMAINING = (item:value() == "on")
		if HUDInteraction then HUDInteraction.SHOW_TIME_REMAINING = WolfHUD.settings.SHOW_TIME_REMAINING end
	end
	
	MenuCallbackHandler.callback_timer_color = function(self, item)
		WolfHUD.settings.GRADIENT_COLOR = item:value()
		if HUDInteraction then HUDInteraction.GRADIENT_COLOR = WolfHUD.color_table[(WolfHUD.settings.GRADIENT_COLOR)] end
	end
	
	MenuCallbackHandler.callback_doubletap_nades_stealth = function(self, item)
		WolfHUD.settings.SUPRESS_NADES_STEALTH = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_hold_to_pick = function(self, item)
		WolfHUD.settings.HOLD2PICK = (item:value() == "on")
	end
	
	MenuCallbackHandler.callback_laser_light = function(self, item)
		WolfHUD.settings.laser_light = item:value()
	end
	
	MenuCallbackHandler.callback_laser_glow = function(self, item)
		WolfHUD.settings.laser_glow = item:value()
	end
	
	MenuCallbackHandler.callback_lasercolor_player = function(self, item)
		WolfHUD.settings.laser_player = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.player = true end
	end
	
	MenuCallbackHandler.callback_laseralpha_player = function(self, item)
		WolfHUD.settings.laser_player_alpha = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.player = true end
	end
	
	MenuCallbackHandler.callback_lasercolor_teammates = function(self, item)
		WolfHUD.settings.laser_teammates = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.default = true end
	end
	
	MenuCallbackHandler.callback_laseralpha_teammates = function(self, item)
		WolfHUD.settings.laser_teammates_alpha = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.default = true end
	end
	
	MenuCallbackHandler.callback_lasercolor_sniper = function(self, item)
		WolfHUD.settings.laser_sniper = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.cop_sniper = true end
	end
	
	MenuCallbackHandler.callback_laseralpha_sniper = function(self, item)
		WolfHUD.settings.laser_sniper_alpha = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.cop_sniper = true end
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_active = function(self, item)
		WolfHUD.settings.laser_turret_active = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.turret_module_active = true end
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_reloading = function(self, item)
		WolfHUD.settings.laser_turret_reloading = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.turret_module_rearming = true end
	end
	
	MenuCallbackHandler.callback_lasercolor_turret_jammed = function(self, item)
		WolfHUD.settings.laser_turret_jammed = item:value()
		if WeaponLasers then WeaponLasers.UPDATE.turret_module_mad = true end
	end
	
	MenuCallbackHandler.callback_laseralpha_turret = function(self, item)
		WolfHUD.settings.laser_turret_alpha = item:value()
		if WeaponLasers then 
			WeaponLasers.UPDATE.turret_module_active = true
			WeaponLasers.UPDATE.turret_module_rearming = true
			WeaponLasers.UPDATE.turret_module_mad = true
		end
	end
	
	MenuCallbackHandler.callback_flashlight_angle = function(self, item)
		WolfHUD.settings.flashlight_angle = item:value()
		if WeaponFlashLight then
			WeaponFlashLight.ANGLE = WolfHUD.settings.flashlight_angle
			WeaponFlashLight._changed = true
		end
	end
	
	MenuCallbackHandler.callback_flashlight_range = function(self, item)
		WolfHUD.settings.flashlight_range = item:value()
		if WeaponFlashLight then
			WeaponFlashLight.RANGE = (WolfHUD.settings.flashlight_range * 100)
			WeaponFlashLight._changed = true
		end
	end
	
	WolfHUD:Load()
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/options.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/gadgets.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/interaction.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_lower.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_upper.txt", WolfHUD, WolfHUD.settings)
	MenuHelper:LoadFromJsonFile(WolfHUD.mod_path .. "menu/hud_upper_adv.txt", WolfHUD, WolfHUD.settings)
end)

