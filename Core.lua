if not _G.WolfHUD then
	_G.WolfHUD = {}
	WolfHUD.mod_path = ModPath
	WolfHUD.save_path = SavePath
	WolfHUD.assets_path = "./assets/mod_overrides/"
	WolfHUD.settings_path = WolfHUD.save_path .. "WolfHUD_v2.json"
	WolfHUD.tweak_file = "WolfHUDTweakData.lua"
	WolfHUD.identifier = string.match(WolfHUD.mod_path, "[\\/]([%w_-]+)[\\/]$") or "WolfHUD"

	WolfHUD.settings = {}
	WolfHUD.tweak_data = {}

	function WolfHUD:Reset()
		local default_lang = "english"
		for _, filename in pairs(file.GetFiles(self.mod_path .. "/loc/")) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				default_lang = str
				break
			end
		end

		WolfHUD.settings = {
			LANGUAGE 								= default_lang,
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
				WIDTH									= 380,		--Width of the chat window
				MAX_OUTPUT_LINES						= 8,		--Chat Output lines
				MAX_INPUT_LINES							= 5,		--Number of lines of text you can type
				COLORED_BG								= true,		--Colorize the line bg based on the message source
				SCROLLBAR_ALIGN							= 2,		--Alignment of the scroll bar (1 = left, 2 = right)
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
				HEIGHT	 								= 20,
				ALPHA	 								= 1,
				COLOR									= "yellow",
				HEADSHOT_COLOR							= "red",
				CRITICAL_COLOR 							= "light_purple",
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
                REPLACE_PROFILE_MENU                    = true,
			},
			HUDList = {
				ENABLED	 								= true,
				right_list_scale						= 1,
				left_list_scale							= 1,
				buff_list_scale							= 1,
				right_list_progress_alpha 				= 0.4,
				left_list_progress_alpha 				= 0.4,
				buff_list_progress_alpha 				= 1.0,
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
					passive_health_regen 					= true,
					total_dodge_chance 						= true,
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
						ammo_give_out_debuff				= true,
						armorer								= true,
						biker								= true,
						chico_injector						= false,
						close_contact						= true,
						crew_chief							= true,
						damage_control_debuff 				= false,
						delayed_damage 						= true,
						hostage_situation					= false,
						medical_supplies_debuff				= true,
						grinder								= true,
						tooth_and_claw						= true,
						life_drain_debuff					= true,
						melee_stack_damage					= false,
						overdog								= false,
						maniac								= false,
						muscle_regen						= false,
						pocket_ecm_jammer 					= true,
						pocket_ecm_kill_dodge 				= false,
						sicario_dodge 						= true,
						smoke_screen_grenade 				= true,
						sociopath_debuff					= true,
						tag_team 							= true,
						yakuza								= false,
					},
					GAGE_BOOSTS = {
						invulnerable_buff					= true,
						life_steal_debuff					= true,
					},
					AI_SKILLS = {
						crew_inspire_debuff 				= true,
						crew_throwable_regen 				= true,
						crew_health_regen 					= false,
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
				SHOW_TIME_REMAINING_OUTLINE				= true,		--Show black outline around remaining Time text
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
						beam 							= { enabled = true, r = 0, g = 1, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					team = {
						beam 							= { enabled = true, r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					player_sentry = {
						beam 							= { enabled = true, r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					team_sentry = {
						beam 							= { enabled = true, r = 0, g = 1, b = 0, a = 0.05 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					cop_sniper = {
						beam 							= { enabled = true, r = 1, g = 0, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 1, g = 0, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 0, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_active = {
						beam 							= { enabled = true, r = 1, g = 0, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 1, g = 0, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 0, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_rearming = {
						beam 							= { enabled = true, r = 1, g = 1, b = 0, a = 0.11 },
						glow 							= { match_beam = true, r = 1, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 1, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					turret_module_mad = {
						beam 							= { enabled = true, r = 0, g = 1, b = 0, a = 0.15 },
						glow 							= { match_beam = true, r = 0, g = 1, b = 0, a = 0.02 },
						dot 							= { match_beam = true, r = 0, g = 1, b = 0, a = 1 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
				},
				flashlight = {
					player = {
						light 							= { enabled = true, r = 1, g = 1, b = 1, brightness = 1, range = 10, angle = 60 },
						pulse 							= { enabled = false, min = 0.5, max = 2, frequency = 0.25 },
						rainbow 						= { enabled = false, frequency = 0.25 },
					},
					team = {
						light 							= { enabled = true, r = 1, g = 1, b = 1, brightness = 1, range = 10, angle = 60 },
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
				KEYCARD_DOORS_DISABLED					= true,
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
				AUTOPICK_CARD_SPECIFIC 					= 4,		--left, center, right, random
				LOOT_SCREEN_DELAY 						= 3,		--Skip the loot screen after X seconds
				NO_SLOWMOTION 							= true,		--Disable mask-up and downed slow motion
			},
			MOD_OVERRIDES = {
				fed_inv									= true,
			},
			LOBBY_SETTINGS = {
				job_plan = -1,
				kick_option = 1,
				permission = "public",
				reputation_permission = 0,
				drop_in_option = 1,
				team_ai = true,
				team_ai_option = 1,
				auto_kick = true,
				difficulty = "normal",
				one_down = false,
			},
		}
	end

	function WolfHUD:print_log(...)
		local LOG_MODES = self:getTweakEntry("LOG_MODE", "table", {})
		local params = {...}
		local msg_type, text = table.remove(params, #params), table.remove(params, 1)
		if msg_type and LOG_MODES[tostring(msg_type)] then
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
				if not text[1] or type(text[1]) ~= "string" then
					log(string.format("[WolfHUD] %s:", string.upper(type(msg_type))))
					log_table(text)
					return
				else
					text = string.format(unpack(text))
				end
			elseif type(text) == "function" then
				msg_type = "error"
				text = "Cannot log function... "
			elseif type(text) == "string" then
				text = string.format(text, unpack(params or {}))
			end
			text = string.format("[WolfHUD] %s: %s", string.upper(msg_type), text)
			log(text)
			if LOG_MODES.to_console and con and con.print and con.error then
				local t = Application:time()
				text = string.format("%02d:%06.3f\t>\t%s", math.floor(t/60), t%60, text)
				if tostring(msg_type) == "info" then
					con:print(text)
				else
					con:error(text)
				end
			end
		end
	end

	function WolfHUD:Load()
		local corrupted = false
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
						self:print_log("Error while loading, Setting types don't match (%s->%s)", self:SafeTableConcat(setting_path, "->") or "", k or "N/A", "error")
						corrupted = corrupted or true
					end
				end
			end

			local settings = json.decode(file:read("*all"))
			parse_settings(self.settings, settings, {})
			file:close()
		else
			self:print_log("Error while loading, settings file could not be opened (" .. self.settings_path .. ")", "error")
		end
		if corrupted then
			self:Save()
			self:print_log("Settings file appears to be corrupted, resaving...", "error")
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

	function WolfHUD:createDirectory(path)
		local current = ""
		path = Application:nice_path(path, true):gsub("\\", "/")

		for folder in string.gmatch(path, "([^/]*)/") do
			current = Application:nice_path(current .. folder, true)

			if not self:DirectoryExists(current) then
				if SystemFS and SystemFS.make_dir then
					SystemFS:make_dir(current)
				elseif file and file.CreateDirectory then
					file.CreateDirectory(current)
				end
			end
		end

		return self:DirectoryExists(path)
	end

	function WolfHUD:DirectoryExists(path)
		if SystemFS and SystemFS.exists then
			return SystemFS:exists(path)
		elseif file and file.DirectoryExists then
			log("")	-- For some weird reason the function below always returns true if we don't log anything previously...
			return file.DirectoryExists(path)
		end
	end

	function WolfHUD:getVersion()
        local mod = BLT and BLT.Mods:GetMod(WolfHUD.identifier or "")
		return tostring(mod and mod:GetVersion() or "(n/a)")
	end

	function WolfHUD:SafeTableConcat(tbl, str)
		local res
		for i = 1, #tbl do
			local val = tbl[i] and tostring(tbl[i]) or "[nil]"
			res = res and res .. str .. val or val
		end
		return res
	end

	function WolfHUD:getSetting(id_table, default)
		if type(id_table) == "table" then
			local entry = self.settings
			for i = 1, #id_table do
				entry = entry[id_table[i]]
				if entry == nil then
					self:print_log("Requested setting doesn't exists!  (id='" .. self:SafeTableConcat(id_table, "->") .. "', type='" .. (default and type(default) or "n/a") .. "') ", "error")
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

	function WolfHUD:getColorSetting(id_table, default, ...)
		local color_name = self:getSetting(id_table, default)
		return self:getColor(color_name, ...) or default and self:getColor(default, ...)
	end

	function WolfHUD:getColorID(name)
		if self.tweak_data and type(name) == "string" then
			for i, data in ipairs(self:getTweakEntry("color_table", "table")) do
				if name == data.name then
					return i
				end
			end
		end
	end

	function WolfHUD:getColor(name, ...)
		if self.tweak_data and type(name) == "string" then
			for i, data in ipairs(self:getTweakEntry("color_table", "table")) do
				if name == data.name then
					return data.color and Color(data.color) or data.color_func and data.color_func(...) or nil
				end
			end
		end
	end

	function WolfHUD:getTweakEntry(id, val_type, default)
		local value = self.tweak_data[id]
		if value ~= nil and (not val_type or type(value) == val_type) then
			return value
		else
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
			self.tweak_data[id] = default
			self:print_log("Requested tweak_entry doesn't exists!  (id='" .. id .. "', type='" .. tostring(val_type) .. "') ", "error")
			return default
		end
	end

	function WolfHUD:getCharacterName(character_id, to_upper)
		local name = character_id or "UNKNOWN"
		local character_names = self:getTweakEntry("CHARACTER_NAMES", "table", {})
		local name_table = character_names and character_names[character_id]
		if name_table then
			local level_id = managers.job and managers.job:current_level_id() or "default"
			local name_id = name_table[level_id] or name_table.default
			name = to_upper and managers.localization:to_upper_text(name_id) or managers.localization:text(name_id)
		end

		return name
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
				if managers.hud and HUDListManager and setting then
					local list = tostring(setting[1])
					local category = tostring(setting[2])
					local option = tostring(setting[#setting])

					if list == "BUFF_LIST" and category ~= "show_buffs" then
						managers.hud:change_bufflist_setting(option, WolfHUD:getColor(value) or value)
					elseif list == "RIGHT_LIST" and category == "SHOW_PICKUP_CATEGORIES" then
						managers.hud:change_pickuplist_setting(option, WolfHUD:getColor(value) or value)
					else
						managers.hud:change_list_setting(option, WolfHUD:getColor(value) or value)
					end
				end
			end,
			["AssaultBanner"] = function(setting, value)
				if managers.hud and managers.hud.change_assaultbanner_setting then
					managers.hud:change_assaultbanner_setting(tostring(setting[#setting]), value)
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
				if WeaponGadgetBase and WeaponGadgetBase.update_theme_setting and #setting >= 4 then
					WeaponGadgetBase.update_theme_setting(setting[1], setting[2], setting[3], setting[4], WolfHUD:getColor(value) or value)
				end
			end,
			["MOD_OVERRIDES"] = function(setting, value)
				local update_id = setting[#setting]
				local mod = BLT and BLT.Mods:GetMod(WolfHUD.identifier or "")
				if mod and update_id then
					local update = mod:GetUpdate(update_id)
					if update then
						update:SetEnabled(value)
						BLT.Mods:Save()
					end
				end
			end,
		}
	end

	if not WolfHUD:DirectoryExists(WolfHUD.assets_path) then
		WolfHUD:print_log("Folder '%s' doesn't exist, creating....\t%s", WolfHUD.assets_path, tostring(WolfHUD:createDirectory(WolfHUD.assets_path)), "warining")
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

		create_menu({menu_options}, BLT and BLT.Mods.Constants:LuaModOptionsMenuID() or "blt_options")
	end)

	--Populate options menus
	Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_WolfHUD", function(menu_manager, nodes)
		-- Called on setting change
		local function change_setting(setting, value)
			if WolfHUD:getSetting(setting, nil) ~= value and WolfHUD:setSetting(setting, value) then
				WolfHUD:print_log(string.format("Change setting: %s = %s", WolfHUD:SafeTableConcat(setting, "->"), tostring(value)), "info")	-- Change type back!
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
				for _, req in ipairs(data.visible_reqs or {}) do
					if type(req) == "table" then
						local a = WolfHUD:getSetting(req.setting, nil)
						if req.equal then
							if a ~= req.equal then
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
					elseif type(req) == "boolean" then
						return req
					end
				end
				return true
			end

			--Add enable callback
			MenuCallbackHandler[enabled_clbk_id] = function(self, item)
				for _, req in ipairs(data.enabled_reqs or {}) do
					if type(req) == "table" then
						local a = WolfHUD:getSetting(req.setting, nil)
						if req.equal then
							if a ~= req.equal then
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
					elseif type(req) == "boolean" then
						return req
					end
				end
				return true
			end

			--Associate visual callback with item
			local menu = MenuHelper:GetMenu(menu_id)
			for i, item in pairs(menu._items_list) do
				if item:parameters().name == id then
					item._visible_callback_name_list = { visual_clbk_id }
					item._enabled_callback_name_list = { enabled_clbk_id }
					item._create_data = data
					break
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

				if data.visible_reqs or data.enabled_reqs then
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

				if data.visible_reqs or data.enabled_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			multi_choice = function(menu_id, offset, data, value)
				local id = string.format("%s_%s_multi", menu_id, data.name_id)
				local clbk_id = id .. "_clbk"

				local multi_data = {
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					callback = string.format("%s %s", clbk_id, update_visible_clbks),
					items = data.options,
					value = value,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				}

				do	-- Copy of MenuHelper:AddMultipleChoice (Without ipairs for options)
					local data = {
						type = "MenuItemMultiChoice"
					}
					for k, v in pairs( multi_data.items or {} ) do
						table.insert( data, { _meta = "option", text_id = v, value = k } )
					end

					local params = {
						name = multi_data.id,
						text_id = multi_data.title,
						help_id = multi_data.desc,
						callback = multi_data.callback,
						filter = true,
						localize = multi_data.localized,
					}

					local menu = MenuHelper:GetMenu( multi_data.menu_id )
					local item = menu:create_item(data, params)
					item._priority = multi_data.priority
					item:set_value( multi_data.value or 1 )

					if multi_data.disabled then
						item:set_enabled( not multi_data.disabled )
					end

					menu._items_list = menu._items_list or {}
					table.insert( menu._items_list, item )
				end

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
							break
						end
					end
				end

				if data.visible_reqs or data.enabled_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			input = function(menu_id, offset, data)
				local id = string.format("%s_%s_input", menu_id, data.name_id)
				local clbk_id = id .. "_clbk"

				MenuHelper:AddInput({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					value = tostring(data.value),
					callback = clbk_id,
					menu_id = menu_id,
					priority = offset,
					disabled_color = Color(0.6, 0.6, 0.6),
				})

				MenuCallbackHandler[clbk_id] = function(self, item)
					change_setting(clone(data.value), item:value())
				end

				if data.visible_reqs or data.enabled_reqs then
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

				if data.visible_reqs or data.enabled_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			keybind = function(menu_id, offset, data)
				local id = string.format("%s_%s_keybind", menu_id, data.name_id)
				local clbk_id = data.clbk or (id .. "_clbk")

				MenuHelper:AddKeybinding({
					id = id,
					title = data.name_id,
					desc = data.desc_id,
					connection_name = "",
					binding = "",
					button = "",
					callback = clbk_id,
					menu_id = menu_id,
					priority = offset,
					--disabled_color = Color(0.6, 0.6, 0.6),
				})

				MenuCallbackHandler[clbk_id] = MenuCallbackHandler[clbk_id] or function(self, item)

				end

				if data.visible_reqs or data.enabled_reqs then
					add_visible_reqs(menu_id, id, data)
				end
			end,
			divider = function(menu_id, offset, data)
				local id = string.format("%s_divider_%d", menu_id, offset)

				local item_data = {
					type = "MenuItemDivider"
				}
				local params = {
					name = id,
					no_text = not data.text_id,
					text_id = data.text_id,
					localize = "true",
					size = data.size or 8,
					color = tweak_data.screen_colors.text
				}

				local menu = MenuHelper:GetMenu( menu_id )
				local item = menu:create_item( item_data, params )
				item._priority = offset or 0
				menu._items_list = menu._items_list or {}
				table.insert( menu._items_list, item )
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

		populate_menu({menu_options}, BLT and BLT.Mods.Constants:LuaModOptionsMenuID() or "blt_options")
	end)

	-- Create callbacks and finalize menus
	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_WolfHUD", function(menu_manager, nodes)
		local back_clbk = "wolfhud_back_clbk"
		local focus_clbk = "wolfhud_focus_clbk"
		local reset_clbk = "wolfhud_reset_clbk"

		-- Add menu back callback
		MenuCallbackHandler[back_clbk] = function(node)
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
							enabled = enabled and MenuCallbackHandler[clbk](node.callback_handler, option_item)
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

		finalize_menu({menu_options}, BLT and BLT.Mods.Constants:LuaModOptionsMenuID() or "blt_options")
	end)

	--Add localiszation strings
	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_WolfHUD", function(loc)
        local loc_path = WolfHUD.mod_path .. "loc/"
		if file.DirectoryExists( loc_path ) then
			loc:load_localization_file(string.format("%s/%s.json", loc_path, WolfHUD:getSetting({"LANGUAGE"}, "english")))
			loc:load_localization_file(string.format("%s/english.json", loc_path), false)

			if WolfHUD:getSetting({"INVENTORY", "USE_REAL_WEAPON_NAMES"}, false) then
				loc:load_localization_file(string.format("%s/RealWeaponNames.json", loc_path))
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
