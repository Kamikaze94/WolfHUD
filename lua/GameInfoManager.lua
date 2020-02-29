--TODO: Fix Client Minion Damage upgrade sync (line: 1919)
local print_debug = function(text, ...)
	text = string.format("(GameInfo) %s", tostring(text))
	WolfHUD:print_log(text, ...)
end

if string.lower(RequiredScript) == "lib/setups/setup" then

	local init_managers_original = Setup.init_managers
	local update_original = Setup.update

	function Setup:init_managers(managers, ...)
		managers.gameinfo = managers.gameinfo or GameInfoManager:new()
		return init_managers_original(self, managers, ...)
	end

	function Setup:update(t, dt, ...)
		managers.gameinfo:update(t, dt)
		return update_original(self, t, dt, ...)
	end

	GameInfoManager = GameInfoManager or class()

	GameInfoManager._TIMER_CALLBACKS = {
		default = {
			--Digital specific functions
			set = function(timers, key, timer)
				GameInfoManager._TIMER_CALLBACKS.default.update(timers, key, Application:time(), timer)
			end,
			start_count_up = function(timers, key)
				if timers[key] and timers[key].ext._visible then
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
				end
			end,
			start_count_down = function(timers, key)
				if timers[key] and timers[key].ext._visible then
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
				end
			end,
			pause = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, true)
			end,
			resume = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_jammed(timers, key, false)
			end,
			stop = function(timers, key)
				GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, false)
			end,

			--General functions
			update = function(timers, key, t, timer, timer_ratio)
				if timers[key] then
					timers[key].timer_value = timer
					timers[key].timer_ratio = timer_ratio
					managers.gameinfo:_listener_callback("timer", "update", key, timers[key])
				end
			end,
			set_active = function(timers, key, status)
				if timers[key] and timers[key].active ~= status then
					timers[key].active = status
					managers.gameinfo:_listener_callback("timer", "set_active", key, timers[key])
				end
			end,
			set_jammed = function(timers, key, status)
				if timers[key] and timers[key].jammed ~= status then
					timers[key].jammed = status
					managers.gameinfo:_listener_callback("timer", "set_jammed", key, timers[key])
				end
			end,
			set_powered = function(timers, key, status)
				if timers[key] and timers[key].powered ~= status then
					timers[key].powered = status
					managers.gameinfo:_listener_callback("timer", "set_powered", key, timers[key])
				end
			end,
			-- Only securitylocks
			set_current_bar = function(timers, key, current_bar)
				if timers[key] and timers[key].current_bar ~= current_bar then
					timers[key].current_bar = current_bar
					managers.gameinfo:_listener_callback("timer", "set_current_bar", key, timers[key])
				end
			end,
			set_total_bars = function(timers, key, total_bars)
				if timers[key] and timers[key].total_bars ~= total_bars then
					timers[key].total_bars = total_bars
					managers.gameinfo:_listener_callback("timer", "set_total_bars", key, timers[key])
				end
			end,
			-- Only upgradable drills/saws
			set_upgradable = function(timers, key, upgradable)
				if timers[key] and timers[key].upgradable ~= upgradable then
					timers[key].upgradable = upgradable
					managers.gameinfo:_listener_callback("timer", "set_upgradable", key, timers[key])
				end
			end,
			set_upgrades = function(timers, key, upgrades)
				if timers[key] then
					timers[key].upgrades = upgrades
					managers.gameinfo:_listener_callback("timer", "set_upgrades", key, timers[key])
				end
			end,
			set_autorepair = function(timers, key, auto_repair)
				if timers[key] and timers[key].auto_repair ~= auto_repair then
					timers[key].auto_repair = auto_repair
					managers.gameinfo:_listener_callback("timer", "set_autorepair", key, timers[key])
				end
			end,
		},
		overrides = {
			--Common functions
			stop_on_loud_pause = function(...)
				if not managers.groupai:state():whisper_mode() then
					GameInfoManager._TIMER_CALLBACKS.default.stop(...)
				else
					GameInfoManager._TIMER_CALLBACKS.default.pause(...)
				end
			end,
			stop_on_pause = function(...)
				GameInfoManager._TIMER_CALLBACKS.default.stop(...)
			end,

			[132864] = {	--Meltdown vault temperature
				set = function(timers, key, timer)
					if timer > 0 then
						GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, true)
					end
					GameInfoManager._TIMER_CALLBACKS.default.set(timers, key, timer)
				end,
				start_count_down = function(timers, key)
					GameInfoManager._TIMER_CALLBACKS.default.set_active(timers, key, false)
				end,
				pause = function(...) end,
			},
			[101936] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--GO Bank time lock
			[139706] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Hoxton Revenge alarm	(UNTESTED)
			[132675] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Hoxton Revenge panic room time lock	(UNTESTED)
			[133922] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--The Diamond pressure plates timer
			[130022] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130122] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130222] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130322] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130422] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[130522] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_loud_pause(...) end },	--Train heist vaults
			[145557] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end }, -- Safehouse Killhouse Timer
			--[130320] = { },	--The Diamond outer time lock
			--[130395] = { },	--The Diamond inner time lock
			--[101457] = { },	--Big Bank time lock door #1
			--[104671] = { },	--Big Bank time lock door #2
			--[167575] = { },	--Golden Grin BFD timer
			--[135034] = { },	--Lab rats cloaker safe 1
			--[135076] = { },	--Lab rats cloaker safe 2
			--[135246] = { },	--Lab rats cloaker safe 3
			--[135247] = { },	--Lab rats cloaker safe 4
			[141821] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 1 timer
			[141822] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 1 timer
			[141823] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 1 timer
			[140321] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 2 timer
			[140322] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 2 timer
			[140323] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 2 timer
			[139821] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 3 timer
			[139822] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 3 timer
			[139823] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 3 timer
			[141321] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 4 timer
			[141322] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 4 timer
			[141323] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 4 timer
			[140821] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 5 timer
			[140822] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 5 timer
			[140823] = { pause = function(...) GameInfoManager._TIMER_CALLBACKS.overrides.stop_on_pause(...) end },	--Cursed kill room safe 5 timer
		}
	}

	GameInfoManager._INTERACTIONS = {
		INTERACTION_TO_CALLBACK = {
			corpse_alarm_pager =				"_pager_event",
			gen_pku_crowbar =					"_special_equipment_interaction_handler",	-- Crowbars
			pickup_keycard =					"_special_equipment_interaction_handler",	-- Keycards
			pickup_hotel_room_keycard =			"_special_equipment_interaction_handler",	-- GGC Keycard
			gage_assignment =					"_special_equipment_interaction_handler",	-- Gage Courier
			pickup_case = 						"_special_equipment_interaction_handler",	-- Gage Spec Ops Cases
			pickup_keys = 						"_special_equipment_interaction_handler",	-- Gage Spec Ops Keys
			hold_take_mask = 					"_special_equipment_interaction_handler",	-- Stealing Xmas Paycheck masks
			pickup_boards =						"_special_equipment_interaction_handler",	-- Planks
			stash_planks_pickup =				"_special_equipment_interaction_handler",	-- Planks
			muriatic_acid =						"_special_equipment_interaction_handler",	-- MU
			hydrogen_chloride =					"_special_equipment_interaction_handler",	-- HCL
			caustic_soda =						"_special_equipment_interaction_handler",	-- CS
			gen_pku_blow_torch =				"_special_equipment_interaction_handler",	-- Blowtorch
			drk_pku_blow_torch = 				"_special_equipment_interaction_handler",	-- Blowtorch
			hold_born_receive_item_blow_torch = "_special_equipment_interaction_handler",	-- Biker Blowtorch
			thermite = 							"_special_equipment_interaction_handler",
			gasoline = 							"_special_equipment_interaction_handler",	--Spots to place gas canister
			c4_consume = 						"_special_equipment_interaction_handler",	-- Spots to place mission c4
			c4_consume_x1 = 					"_special_equipment_interaction_handler",	-- Spots to place mission c4
			--c4_bag = 							"_special_equipment_interaction_handler", 	-- Yellow bag, pickup c4
			gasoline_engine = 					"_special_equipment_interaction_handler",
			gen_pku_thermite = 					"_special_equipment_interaction_handler",	-- Thermite
			gen_pku_thermite_paste = 			"_special_equipment_interaction_handler",	-- Thermite Paste
			hold_take_gas_can = 				"_special_equipment_interaction_handler",	-- HM / Slaughter Gas cans
			gen_pku_thermite_paste_z_axis = 	"_special_equipment_interaction_handler",	-- Thermite Paste
			money_wrap_single_bundle = 			"_special_equipment_interaction_handler",	-- Small loot
			money_wrap_single_bundle_active = 	"_special_equipment_interaction_handler",	-- Small loot
			money_wrap_single_bundle_dyn = 		"_special_equipment_interaction_handler",	-- Small loot
			cas_chips_pile = 					"_special_equipment_interaction_handler",	-- Small loot
			diamond_pickup = 					"_special_equipment_interaction_handler",	-- Small loot
			diamond_pickup_pal = 				"_special_equipment_interaction_handler",	-- Small loot
			ring_band = 						"_special_equipment_interaction_handler",	-- BoS Rings
			safe_loot_pickup = 					"_special_equipment_interaction_handler",	-- Small loot
			diamond_pickup_axis = 				"_special_equipment_interaction_handler",	-- Small loot, Diamond heist
			press_pick_up =						"_special_equipment_interaction_handler",	-- Biker Bottle
			hold_take_missing_animal_poster = 	"_special_equipment_interaction_handler",	-- Heat Streat Posters
			hold_pick_up_turtle = 				"_special_equipment_interaction_handler",	-- Heat Street Tutle
			diamond_single_pickup_axis = 		"_special_equipment_interaction_handler",
			glc_hold_take_handcuffs = 			"_special_equipment_interaction_handler",	-- Green Bridge Handcuffs
			pickup_tablet = 					"_special_equipment_interaction_handler",	-- Stealing Xmas Tablet
			pickup_phone = 						"_special_equipment_interaction_handler",	-- Stealing Xmas Phone
			press_take_folder = 				"_special_equipment_interaction_handler",
			take_jfr_briefcase = 				"_special_equipment_interaction_handler",
			take_confidential_folder_icc = 		"_special_equipment_interaction_handler",
			firstaid_box =						"_deployable_interaction_handler",
			ammo_bag =							"_deployable_interaction_handler",
			doctor_bag =						"_deployable_interaction_handler",
			first_aid_kit = 					"_deployable_interaction_handler",
			bodybags_bag =						"_deployable_interaction_handler",
			grenade_crate =						"_deployable_interaction_handler",
			--grenade_briefcase =					"_deployable_interaction_handler",		-- Thermal Paste uses this interaction as well... :(
		},
		INTERACTION_TO_CARRY = {
			weapon_case =					"weapon",
			weapon_case_axis_z =			"weapon",
			samurai_armor =					"samurai_suit",
			gen_pku_warhead_box =			"warhead",
			pku_toothbrush = 				"toothbrush",
			corpse_dispose =				"person",
			crate_loot = 					"crate",
			crate_loot_crowbar = 			"crate",
			crate_weapon_crowbar = 			"crate",
			hold_open_xmas_present = 		"xmas_present",
			hold_open_case =				"drone_control_helmet",	--May be reused in future heists for other loot

			cut_glass = 					"showcase",
			diamonds_pickup = 				"diamonds_dah",
			red_diamond_pickup = 			"red_diamond",
			red_diamond_pickup_no_axis = 	"red_diamond",

			hold_open_shopping_bag = 		"shopping_bag",
			hold_take_toy = 				"robot_toy",
			hold_take_wine = 				"ordinary_wine",
			hold_take_expensive_wine = 		"expensive_vine",
			hold_take_diamond_necklace =	"diamond_necklace",
			hold_take_vr_headset = 			"vr_headset",
			hold_take_shoes = 				"women_shoes",
			hold_take_old_wine = 			"old_wine",
		},
		BAGGED_IDS = {
			painting_carry_drop = true,
			carry_drop = true,
			safe_carry_drop = true,
			goat_carry_drop = true,
		},
		COMPOSITE_LOOT_UNITS = {
			gen_pku_warhead_box = 2,	--[132925] = 2, [132926] = 2, [132927] = 2,	--Meltdown warhead cases
			--hold_open_bomb_case = 4,	--The Bomb heists cases, extra cases on docks screws with counter...
			[103428] = 4, [103429] = 3, [103430] = 2, [103431] = 1,	--Shadow Raid armor
			--[102913] = 1, [102915] = 1, [102916] = 1,	--Train Heist turret (unit fixed, need workaround)
			[105025] = 10, [105026] = 9, [104515] = 8, [104518] = 7, [104517] = 6, [104522] = 5, [104521] = 4, [104520] = 3, [104519] = 2, [104523] = 1, --Slaughterhouse alt 1.
			[105027] = 10, [105028] = 9, [104525] = 8, [104524] = 7, [104490] = 6, [100779] = 5, [100778] = 4, [100777] = 3, [100773] = 2, [100771] = 1, --Slaughterhouse alt 2.
		},
		CONDITIONAL_COMPOSITE_LOOT_UNITS = {
			disassemble_turret = function(unit)	-- Turret - Armored Transport: Train
				return unit:body("body_01") and unit:body("body_01"):enabled() and 3 or unit:body("body_02") and unit:body("body_02"):enabled() and 2 or unit:body("body_03") and unit:body("body_03"):enabled() and 1 or 0
			end,
		},
		CONDITIONAL_IGNORE_IDS = {
			ff3_vault = function(...)
				if managers.job:current_level_id() == "framing_frame_3" then
					local wall_ids = { ... }
					for _, unit in pairs(World:find_units_quick("all", 1)) do
						if table.contains(wall_ids, tonumber(unit:editor_id())) then
							return true
						end
					end
				end
			end,

--[[ 		Vault_Door	closed_Wall		wine_Wall
upstairs	100476		101423			105879
bedroom		100490		101431			105876
lounge		100421		100448			102049
]]

			--FF3 lounge vault
			[100548] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100549] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100550] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100551] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100552] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100553] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100554] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			[100555] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448, 102049) end,
			--FF3 bedroom vault
			[100556] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100557] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100558] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100559] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100560] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100561] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100562] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			[100563] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431, 105876) end,
			--FF3 upstairs vault
			[100564] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100566] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100567] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100568] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100569] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100570] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100571] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
			[100572] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423, 105879) end,
		},
		IGNORE_IDS = {
			watchdogs_2 = {	--Watchdogs day 2 (8x coke)
				[100054] = true, [100058] = true, [100426] = true, [100427] = true, [100428] = true, [100429] = true, [100491] = true, [100492] = true, [100494] = true, [100495] = true,
			},
			family = {	--Diamond store (1x money, 3x safe_loot_pickup)
				[100899] = true,

				[100900] = true,
				[100901] = true,
				[100902] = true,
			},
			mia_1 = {	--Hotline Miami day 1 (1x money)
				[104526] = true,
			},
			welcome_to_the_jungle_1 = {	--Big Oil day 1 (1x money, 1x gold)
				[100886] = true, [100872] = true,
			},
			mus = {	--The Diamond (RNG)
				[300047] = true, [300686] = true, [300457] = true, [300458] = true, [301343] = true, [301346] = true,
			},
			arm_und = {	--Transport: Underpass (8x money)
				[101237] = true, [101238] = true, [101239] = true, [103835] = true, [103836] = true, [103837] = true, [103838] = true, [101240] = true,
			},
			ukrainian_job = {	--Ukrainian Job (3x money, 2x Small loot)
				[101514] = true,
				[102052] = true,
				[102402] = true,

				[100033] = true,
				[100034] = true,
			},
			firestarter_2 = {	--Firestarter day 2 (1x keycard)
				[107208] = true,
			},
			big = {	--Big Bank (1x keycard)
				[101499] = true,
			},
			roberts = {	--GO Bank (1x keycard)
				[106104] = true,
			},
			jewelry_store = {	--Jewelry Store (2x money)
				[102052] = true,
				[102402] = true,
			},
			chill = {	-- Custom Safehouse (1x Painting)
				[150416] = true
			},
			chill_combat = { -- Safehouse Raid (2x Ammo shelves, 1x Painting)
				[100751] = true,
				[101242] = true,
				[150416] = true
			},
			short2_stage1 = {	-- Keycard
				[104102] = true,
			},
			fish = {	--Yacht (1x artifact painting)
				[500533] = true,
			},
			dah = {	-- The Diamond Heist (1x Red Diamond Showcase)
				[100952] = true,
			},
			rvd2 = { -- Resevoir Dogs (1x money, 4x Small loot)
				[100296] = true,
				[100277] = true,
				[100278] = true,
				[100279] = true,
				[100280] = true,
			},
			des = { -- Henry's Rock (2x artifact, 2x painting)
				[101757] = true,
				[400513] = true,
				[400515] = true,
				[400617] = true,
			},
			tag = {	-- Breakin' Feds (1x evidence)
				[134563] = true,
			},
			sah = {	-- Shacklethorne Auction (2x artifact, 1x grenades)
				[400791] = true,
				[400792] = true,
				[400178] = true,
			},
			skm_run = { -- Heat Street Holdout (3x posters)
				[103636] = true,
				[103640] = true,
				[600479] = true,
			},
			skm_watchdogs_stage2 = { -- Watch Dogs Holdout (10x coke)
				[132355] = true,
				[100495] = true,
				[132565] = true,
				[132037] = true,
				[132042] = true,
				[132337] = true,
				[131842] = true,
				[100492] = true,
				[132365] = true,
				[100429] = true,
				[131855] = true,
				[100494] = true,
				[100491] = true,
				[132055] = true,
				[132542] = true,
				[131837] = true,
				[100427] = true,
				[132555] = true,
				[100054] = true,
				[131865] = true,
				[132342] = true,
				[100428] = true,
				[132065] = true,
				[100426] = true,
				[132537] = true,
				[100058] = true,
			},
			mex_cooking = { -- Border Crystals (4x Roman Armor)
				roman_armor = true,
			}
		},
	}
	GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2_day = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2)
	GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1_night = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1)

	GameInfoManager._CAMERAS = {
		["6c5d032fe7e08d01"] = "standard",	--units/payday2/equipment/gen_equipment_security_camera/gen_equipment_security_camera
		["0c721a9fa6d2fe0a"] = "standard",	--units/world/props/security_camera/security_camera
		["c64ffaefb39415bc"] = "standard",	--units/world/props/security_camera/security_camera_white
		["490a9313f945cccf"] = "drone",		--units/pd2_dlc_dark/equipment/gen_drone_camera/gen_drone_camera
	}

	GameInfoManager._EQUIPMENT = {
		SENTRY_KEYS = {	-- OBSOLETE
			--unit:name():key() for friendly sentries
			["07bd083cc5f2d3ba"] = true,	--Standard U100+
			["c71d763cd8d33588"] = true,	--Suppressed U100+
			["b1f544e379409e6c"] = true,	--GGC BFD sentries
		},
		INTERACTION_ID_TO_TYPE = {
			firstaid_box =						"doc_bag",
			ammo_bag =							"ammo_bag",
			doctor_bag =						"doc_bag",
			first_aid_kit = 					"first_aid_kit",
			bodybags_bag =						"body_bag",
			grenade_crate =						"grenade_crate",
			--grenade_briefcase =					"grenade_crate",
		},
		INTERACTON_ID_ALLOW_CREATE = {
			--grenade_briefcase =	true,
		},
		AMOUNT_OFFSETS = {
			--interaction_id or editor_id
			firstaid_box = -1,	--GGC drill asset, HB infirmary
			--grenade_briefcase = 3,
		},
		AGGREAGATE_ITEMS = {	-- [type] or [level_id + editor_id]
			["first_aid_kit"] = "first_aid_kits",	-- Aggregate all FAKs
			hox_2 = {	--Hoxton breakout
				[136859] = "armory_grenade",
				[136870] = "armory_grenade",
				[136869] = "armory_grenade",
				[136864] = "armory_grenade",
				[136866] = "armory_grenade",
				[136860] = "armory_grenade",
				[136867] = "armory_grenade",
				[136865] = "armory_grenade",
				[136868] = "armory_grenade",
				[136846] = "armory_ammo",
				[136844] = "armory_ammo",
				[136845] = "armory_ammo",
				[136847] = "armory_ammo",
				[101470] = "infirmary_cabinet",
				[101472] = "infirmary_cabinet",
				[101473] = "infirmary_cabinet",
			},
			kenaz = {	--GGC
				[151596] = "armory_grenade",
				[151597] = "armory_grenade",
				[151598] = "armory_grenade",
				[151611] = "armory_ammo",
				[151612] = "armory_ammo",
			},
			born = {	--Biker heist
				[100776] = "bunker_grenade",
				[101226] = "bunker_grenade",
				[101469] = "bunker_grenade",
				[101472] = "bunker_ammo",
				[101473] = "bunker_ammo",
			},
			spa = {		--10-10
				[132935] = "armory_ammo",
				[132938] = "armory_ammo",
				[133085] = "armory_ammo",
				[133088] = "armory_ammo",
				[133835] = "armory_ammo",
				[133838] = "armory_ammo",
				[134135] = "armory_ammo",
				[134138] = "armory_ammo",
				[137885] = "armory_ammo",
				[137888] = "armory_ammo",
			},
		},
	}

	GameInfoManager._UNITS = {
		TWEAK_ID_BY_NAME = {
			[tostring(Idstring("units/pd2_dlc_born/characters/npc_male_mechanic/npc_male_mechanic"))] 										= "mechanic",
			[tostring(Idstring("units/pd2_dlc_born/characters/npc_male_mechanic/npc_male_mechanic_husk"))] 									= "mechanic",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_male_bank_manager_hostage/civ_male_bank_manager_hostage"))] 				= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_male_bank_manager_hostage/civ_male_bank_manager_hostage_husk"))] 			= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_female_museum_curator_hostage/civ_female_museum_curator_hostage"))] 		= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_female_museum_curator_hostage/civ_female_museum_curator_hostage_husk"))] 	= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_female_drug_lord_hostage/civ_female_drug_lord_hostage"))] 				= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_female_drug_lord_hostage/civ_female_drug_lord_hostage_husk"))] 			= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_male_prisoner_hostage/civ_male_prisoner_hostage"))] 						= "civ_hostage",
			[tostring(Idstring("units/pd2_skirmish/characters/civ_male_prisoner_hostage/civ_male_prisoner_hostage_husk"))] 					= "civ_hostage",
		}
	}

	GameInfoManager._BUFFS = {
		on_activate = {
			armor_break_invulnerable_debuff = function(id, data)
				local upgrade_value = managers.player:upgrade_value("temporary", "armor_break_invulnerable")
				managers.gameinfo:event("timed_buff", "activate", "armor_break_invulnerable", { t = data.t, duration = upgrade_value and upgrade_value[1] or 0 })
			end,
		},
		on_set_duration = {
			overkill = function(id, data)
				if managers.player:has_category_upgrade("player", "overkill_all_weapons") then
					managers.gameinfo:event("timed_buff", "activate", "overkill_aced", data)
				end
			end,
		},
		on_set_value = {
			overkill = function(id, data)
				if managers.player:has_category_upgrade("player", "overkill_all_weapons") then
					managers.gameinfo:event("buff", "set_value", "overkill_aced", { value = data.value })
				end
			end,
		},

		--Temporary upgrades
		temporary = {
			bullet_storm = "bullet_storm",
			chico_injector = "chico_injector",
			damage_speed_multiplier = "second_wind",
			dmg_multiplier_outnumbered = "underdog",
			dmg_dampener_outnumbered = "underdog_aced",
			dmg_dampener_outnumbered_strong = "overdog",
			dmg_dampener_close_contact = { "close_contact_1", "close_contact_2", "close_contact_3" },
			overkill_damage_multiplier = "overkill",
			--melee_kill_increase_reload_speed = "bloodthirst_aced",
			passive_revive_damage_reduction = { "pain_killer", "pain_killer_aced" },
			berserker_damage_multiplier = { "swan_song", "swan_song_aced" },
			first_aid_damage_reduction = "quick_fix",
			increased_movement_speed = "running_from_death_aced",
			reload_weapon_faster = "running_from_death_basic",
			revive_damage_reduction = "combat_medic",
			revived_damage_resist = "up_you_go",
			swap_weapon_faster = "running_from_death_basic",
			team_damage_speed_multiplier_received = "second_wind",
			melee_life_leech = "life_drain_debuff",
			loose_ammo_restore_health = "medical_supplies_debuff",
			loose_ammo_give_team = "ammo_give_out_debuff",
			armor_break_invulnerable = "armor_break_invulnerable_debuff",
			single_shot_fast_reload = "aggressive_reload_aced",
            unseen_strike = "unseen_strike",
			pocket_ecm_kill_dodge =	"pocket_ecm_kill_dodge",

			--"properties"
			bloodthirst_reload_speed = "bloodthirst_aced",
			revived_damage_reduction = "pain_killer",
		},
		cooldown = {
			long_dis_revive = "inspire_revive_debuff",
		},
		--Team upgrades
		damage_dampener = {
			hostage_multiplier =  { id = "crew_chief_9", level = 9 },
			team_damage_reduction = { id = "crew_chief_1", level = 1 },
		},
		stamina = {
			multiplier = { id = "endurance", level = 0 },
			passive_multiplier = { id = "crew_chief_3", level = 3 },
			hostage_multiplier =  { id = "crew_chief_9", level = 9 },
		},
		health = {
			passive_multiplier = { id = "crew_chief_5", level = 5 },
			hostage_multiplier = { id = "crew_chief_9", level = 9 },
		},
		armor = {
			multiplier =  { id = "crew_chief_7", level = 7 },
			regen_time_multiplier = { id = "bulletproof", level = 0 },
			passive_regen_time_multiplier = { id = "armorer_9", level = 9 },
		},
		damage = {
			hostage_absorption = { id = "forced_friendship", level = 0 },
		},
		--[[
		weapon = {
			recoil_multiplier = "leadership_aced",
			suppression_recoil_multiplier = "leadership_aced",
		},
		pistol = {
			recoil_multiplier = "leadership",
			suppression_recoil_multiplier = "leadership",
		},
		akimbo = {
			recoil_multiplier = "leadership",
			suppression_recoil_multiplier = "leadership",
		},
		]]
	}

	function GameInfoManager:init()
		self._t = 0
		self._scheduled_callbacks = {}
		self._listeners = {}

		self._timers = {}
		self._units = {}
		self._unit_count = {}
		self._minions = {}
		self._turrets = {}
		self._pagers = {}
		self._cameras = {}
		self._bodybag_amount = 0
		self._loot = {}
		self._special_equipment = {}
		self._ecms = {}
		self._deployables = {
			ammo_bag = {},
			doc_bag = {},
			first_aid_kit = {},
			body_bag = {},
			grenade_crate = {},
		}
		self._sentries = {}
		self._buffs = {}
		self._player_actions = {}

		self._auto_expire_timers = {
			on_expire = {},
			expire_t = {},
		}
		self._timed_buff_expire_clbk = callback(self, self, "_on_timed_buff_expired")
		self._timed_stack_expire_clbk = callback(self, self, "_on_timed_stack_expired")
		self._player_actions_expire_clbk = callback(self, self, "_on_player_action_expired")
	end

	function GameInfoManager:update(t, dt)
		self._t = t
		self:_update_player_timer_expiration(t, dt)

		while self._scheduled_callbacks[1] and self._scheduled_callbacks[1].t <= t do
			local data = table.remove(self._scheduled_callbacks, 1)
			data.clbk(unpack(data.args))
			print_debug("Executed scheduled callback: %s", data.id, "info")
		end
	end

	function GameInfoManager:add_scheduled_callback(id, delay, clbk, ...)
		local t = self._t + delay
		local pos = 1

		for i, data in ipairs(self._scheduled_callbacks) do
			if data.t >= t then break end
			pos = pos + 1
		end

		table.insert(self._scheduled_callbacks, pos, { id = id, t = t, clbk = clbk, args = { ... } })
		print_debug("Added scheduled callback: %s", id, "info")
	end

	function GameInfoManager:remove_scheduled_callback(id)
		for i = 1, #self._scheduled_callbacks, 1 do
			if data.id == id then
				table.remove(self._scheduled_callbacks, i)
				i = i - 1
				print_debug("Removed scheduled callback: %s", id, "info")
			end
		end
	end

	function GameInfoManager:event(source, ...)
		local target = "_" .. source .. "_event"

		if self[target] then
			self[target](self, ...)
		else
			print_debug("No event handler for %s", target, "error")
		end
	end

	function GameInfoManager:get_timers(key)
		if key then
			return self._timers[key]
		else
			return self._timers
		end
	end

	function GameInfoManager:get_units(key)
		if key then
			return self._units[key]
		else
			return self._units
		end
	end

	function GameInfoManager:get_unit_count(id)
		if id then
			return self._unit_count[id] or 0
		else
			return self._unit_count
		end
	end

	function GameInfoManager:get_minions(key)
		if key then
			return self._minions[key]
		else
			return self._minions
		end
	end

	function GameInfoManager:get_pagers(key)
		if key then
			return self._pagers[key]
		else
			return self._pagers
		end
	end

	function GameInfoManager:get_bodybag_amount()
		return self._bodybag_amount
	end

	function GameInfoManager:get_special_equipment(key)
		if key then
			return self._special_equipment[key]
		else
			return self._special_equipment
		end
	end

	function GameInfoManager:get_loot(key)
		if key then
			return self._loot[key]
		else
			return self._loot
		end
	end

	function GameInfoManager:get_ecms(key)
		if key then
			return self._ecms[key]
		else
			return self._ecms
		end
	end

	function GameInfoManager:get_cameras(key)
		if key then
			return self._cameras[key]
		else
			return self._cameras
		end
	end

	function GameInfoManager:get_deployables(type, key)

		if type and key then
			return self._deployables[type][key]
		elseif type then
			return self._deployables[type]
		else
			return self._deployables
		end
	end

	function GameInfoManager:get_sentries(key)
		if key then
			return self._sentries[key]
		else
			return self._sentries
		end
	end

	function GameInfoManager:get_buffs(id)
		if id then
			return self._buffs[id]
		else
			return self._buffs
		end
	end

	function GameInfoManager:get_player_actions(id)
		if id then
			return self._player_actions[id]
		else
			return self._player_actions
		end
	end

	function GameInfoManager:_timer_event(event, key, ...)
		if event == "create" then
			if not self._timers[key] then
				local unit, ext, device_type = ...
				local id = unit:editor_id()
				self._timers[key] = { unit = unit, ext = ext, device_type = device_type, id = id, jammed = false, powered = true, upgradable = false }
				self:_listener_callback("timer", "create", key, self._timers[key])
			end
		elseif event == "destroy" then
			if self._timers[key] then
				GameInfoManager._TIMER_CALLBACKS.default.set_active(self._timers, key, false)
				self:_listener_callback("timer", "destroy", key, self._timers[key])
				self._timers[key] = nil
			end
		elseif self._timers[key] then
			local timer_id = self._timers[key].id
			local timer_override = GameInfoManager._TIMER_CALLBACKS.overrides[timer_id]

			if timer_override and timer_override[event] then
				timer_override[event](self._timers, key, ...)
			else
				GameInfoManager._TIMER_CALLBACKS.default[event](self._timers, key, ...)
			end
		end
	end

	function GameInfoManager:_unit_event(event, key, data)
		if event == "add" then
			if not self._units[key] then
				local lookup = GameInfoManager._UNITS.TWEAK_ID_BY_NAME
				local unit_type = lookup[tostring(data.unit:name())] or data.unit:base()._tweak_table
				self._units[key] = { unit = data.unit, type = unit_type }
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", unit_type, 1)
			end
		elseif event == "remove" then
			if self._units[key] then
				self:_listener_callback("unit", event, key, self._units[key])
				self:_unit_count_event("change", self._units[key].type, -1)
				self._units[key] = nil

				if self._minions[key] then
					self:_minion_event("remove", key)
				end
			end
		end
	end

	function GameInfoManager:_unit_count_event(event, unit_type, value)
		if event == "change" then
			if value ~= 0 then
				self._unit_count[unit_type] = (self._unit_count[unit_type] or 0) + value
				self:_listener_callback("unit_count", "change", unit_type, value)
			end
		elseif event == "set" then
			self:_unit_count_event("change", unit_type, value - (self._unit_count[unit_type] or 0))
		end
	end

	function GameInfoManager:_minion_event(event, key, data)
		if event == "add" then
			if not self._minions[key] then
				self._minions[key] = { unit = data.unit, kills = 0 }
				self:_listener_callback("minion", "add", key, self._minions[key])
				if self._minions[key].unit:base()._tweak_table:find("security") or self._minions[key].unit:base()._tweak_table:find("gensec") then
					self:_unit_count_event("change", "sec_minion", 1)
				else
					self:_unit_count_event("change", "cop_minion", 1)
				end
			end
		elseif self._minions[key] then
			if event == "remove" then
				self:_listener_callback("minion", "remove", key, self._minions[key])
				if self._minions[key].unit:base()._tweak_table:find("security") or self._minions[key].unit:base()._tweak_table:find("gensec") then
					self:_unit_count_event("change", "sec_minion", -1)
				else
					self:_unit_count_event("change", "cop_minion", -1)
				end
				self._minions[key] = nil
			else
				if event == "set_health_ratio" then
					self._minions[key].health_ratio = data.health_ratio
				elseif event == "increment_kills" then
					event = "set_kills"
					self._minions[key].kills = self._minions[key].kills + 1
				elseif event == "set_owner" then
					self._minions[key].owner = data.owner
				elseif event == "set_damage_resistance" then
					self._minions[key].damage_resistance = data.damage_resistance
				elseif event == "set_damage_multiplier" then
					self._minions[key].damage_multiplier = data.damage_multiplier
				end

				self:_listener_callback("minion", event, key, self._minions[key])
			end
		end
	end

	function GameInfoManager:_turret_event(event, key, unit)
		if event == "add" then
			if not self._turrets[key] then
				self._turrets[key] = unit
				self:_unit_count_event("change", "turret", 1)
			end
		elseif event == "remove" then
			if self._turrets[key] then
				self:_unit_count_event("change", "turret", -1)
				self._turrets[key] = nil
			end
		end
	end

	function GameInfoManager:_interactive_unit_event(event, key, data)
		local lookup = GameInfoManager._INTERACTIONS
		local level_id = managers.job:current_level_id()

		if lookup.IGNORE_IDS[level_id] and (lookup.IGNORE_IDS[level_id][data.editor_id] or lookup.IGNORE_IDS[level_id][data.interact_id]) then
			return
		end

		if lookup.CONDITIONAL_IGNORE_IDS[data.editor_id] then
			if lookup.CONDITIONAL_IGNORE_IDS[data.editor_id]() then
				return
			end
		end

		local interact_clbk = lookup.INTERACTION_TO_CALLBACK[data.interact_id]

		if interact_clbk then
			self[interact_clbk](self, event, key, data)
		else
			local carry_id = data.unit:carry_data() and data.unit:carry_data():carry_id() or lookup.INTERACTION_TO_CARRY[data.interact_id] or (self._loot[key] and self._loot[key].carry_id)

			if carry_id then
				print_debug("Loot Interaction: %s - %s (%d)", event, carry_id, data.editor_id, "info")
				data.carry_id = carry_id
				self:_loot_interaction_handler(event, key, data)
			else
				self:_listener_callback("interactable_unit", event, key, data.unit, data.interact_id, carry_id)
			end
		end
	end

	function GameInfoManager:_pager_event(event, key, data)
		if event == "add" then
			if not self._pagers[key] then
				local t = Application:time()
				self._pagers[key] = {
					unit = data.unit,
					active = true,
					answered = false,
					start_t = t,
					expire_t = t + 12,
				}
				self:_listener_callback("pager", "add", key, self._pagers[key])
			end
		elseif self._pagers[key] then
			if event == "remove" then
				if self._pagers[key].active then
					self._pagers[key].active = false
					self:_listener_callback("pager", "remove", key, self._pagers[key])
				end
			elseif event == "set_answered" then
				if not self._pagers[key].answered then
					self._pagers[key].answered = true
					self:_listener_callback("pager", "set_answered", key, self._pagers[key])
				end
			end
		end
	end

	function GameInfoManager:_camera_event(event, key, data)
		if event == "create" then
			if not self._cameras[key] then
				local type = GameInfoManager._CAMERAS[tostring(data.unit:name():key())]
				local is_drone = type == "drone"
				self._cameras[key] = { unit = data.unit, type = type, is_drone = is_drone }
				if is_drone then
					self._cameras[key].enabled = true
				end
				--self._cameras[key].active = data.active or Network:is_client()
				self:_listener_callback("camera", event, key, self._cameras[key])

				if not type then
					print_debug("UNKNOWN CAMERA UNIT TYPE: %s", tostring(data.unit:name():key()), "warning")
				end
			end
		elseif self._cameras[key] then
			if event == "set_active" then
				self._cameras[key].active = data.active
			elseif event == "set_enabled" then
				self._cameras[key].enabled = self._cameras[key].is_drone or data.enabled
			elseif event == "set_tape_loop_active" then
				self._cameras[key].tape_loop_active = data.tape_loop_active
			elseif event == "set_tape_loop_expire_t" then
				self._cameras[key].tape_loop_expire_t = data.tape_loop_expire_t
			elseif event == "set_tape_loop_restart_active" then
				self._cameras[key].tape_loop_restart_active = data.tape_loop_restart_active
			elseif event == "set_broken" then
				self._cameras[key].broken = data.broken
			elseif event == "destroy" then
				self._cameras[key] = nil
			end

			self:_listener_callback("camera", event, key, self._cameras[key])

			if not self._upd_camera_count then
				self._upd_camera_count = true
				self:add_scheduled_callback("camera_count", 0.1, callback(self, self, "_recount_active_cameras"))
			end
		end
	end

	function GameInfoManager:_bodybags_event(event, key, amount)
		if event == "set" then
			local change = amount - self._bodybag_amount
			self._bodybag_amount = amount
			self:_listener_callback("bodybags", "set", key, self._bodybag_amount)
			self:_listener_callback("bodybags", "change", key, change)
		end
	end

	function GameInfoManager:_special_equipment_interaction_handler(event, key, data)
		if event == "add" then
			if not self._special_equipment[key] then
				self._special_equipment[key] = { unit = data.unit, interact_id = data.interact_id }
				self:_listener_callback("special_equipment", "add", key, self._special_equipment[key])
				self:_special_equipment_count_event("change", data.interact_id, 1, self._special_equipment[key])
			end
		elseif event == "remove" then
			if self._special_equipment[key] then
				self:_listener_callback("special_equipment", "remove", key, self._special_equipment[key])
				self:_special_equipment_count_event("change", data.interact_id, -1, self._special_equipment[key])
				self._special_equipment[key] = nil
			end
		end
	end

	function GameInfoManager:_special_equipment_count_event(event, interact_id, value, data)
		if event == "change" then
			if value ~= 0 then
				self:_listener_callback("special_equipment_count", "change", interact_id, value, data)
			end
		end
	end

	function GameInfoManager:_deployable_interaction_handler(event, key, data)
		local type = GameInfoManager._EQUIPMENT.INTERACTION_ID_TO_TYPE[data.interact_id]
		local active = event == "add" or event == "interact"

		if not self._deployables[type][key] and GameInfoManager._EQUIPMENT.INTERACTON_ID_ALLOW_CREATE[data.interact_id] then
			if active then
				self:_bag_deployable_event("create", key, { unit = data.unit }, type)
			else
				self:_bag_deployable_event("destroy", key, {}, type)
			end
		end

		if self._deployables[type][key] then
			local offset = GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[data.unit:editor_id()] or GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[data.interact_id]

			self:_bag_deployable_event("set_active", key, { active = active }, type)

			if active and offset then
				self:_bag_deployable_event("set_amount_offset", key, { amount_offset = offset }, type)
			end
		end
	end

	function GameInfoManager:_loot_interaction_handler(event, key, data)
		if event == "add" then
			if not self._loot[key] then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local conditional_lookup = GameInfoManager._INTERACTIONS.CONDITIONAL_COMPOSITE_LOOT_UNITS
				local count_clbk = conditional_lookup[data.editor_id] or conditional_lookup[data.interact_id]
				local count = count_clbk and count_clbk(data.unit) or composite_lookup[data.editor_id] or composite_lookup[data.interact_id] or 1
				local bagged = GameInfoManager._INTERACTIONS.BAGGED_IDS[data.interact_id] and true or false

				self._loot[key] = { unit = data.unit, carry_id = data.carry_id, count = count, bagged = bagged }
				self:_listener_callback("loot", "add", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, bagged, count, self._loot[key])
			end
		elseif self._loot[key] then
			if event == "remove"then
				self:_listener_callback("loot", "remove", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, self._loot[key].bagged, -self._loot[key].count, self._loot[key])
				self._loot[key] = nil
			elseif event == "interact" then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local conditional_lookup = GameInfoManager._INTERACTIONS.CONDITIONAL_COMPOSITE_LOOT_UNITS
				local count_clbk = conditional_lookup[data.editor_id] or conditional_lookup[data.interact_id]
				local count = count_clbk and count_clbk(data.unit) or composite_lookup[data.editor_id] or composite_lookup[data.interact_id] or 1
				local bagged = GameInfoManager._INTERACTIONS.BAGGED_IDS[data.interact_id] and true or false
				local change = count - self._loot[key].count

				self._loot[key].count = count
				self._loot[key].bagged = bagged
				self:_listener_callback("loot", "interact", key, self._loot[key])
				self:_loot_count_event("change", data.carry_id, bagged, change, self._loot[key])
			end
		end
	end

	function GameInfoManager:_loot_count_event(event, carry_id, bagged, value, data)
		if event == "change" then
			if value ~= 0 then
				self:_listener_callback("loot_count", "change", carry_id, bagged, value, data)
			end
		end
	end

	function GameInfoManager:_ecm_event(event, key, data)
		if event == "create" then
			if not self._ecms[key] then
				self._ecms[key] = { unit = data.unit }
				self:_listener_callback("ecm", event, key, self._ecms[key])
			end
		elseif self._ecms[key] then
			if event == "set_jammer_battery" then
				if self._ecms[key].jammer_active then
					self._ecms[key].jammer_battery = data.jammer_battery
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_battery_low" then
				if self._ecms[key].battery_low ~= data.battery_low then
					self._ecms[key].battery_low = data.battery_low
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_retrigger_delay" then
				if self._ecms[key].retrigger_active then
					self._ecms[key].retrigger_delay = data.retrigger_delay
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_feedback_duration" then
				if self._ecms[key].feedback_active then
					self._ecms[key].feedback_duration = data.feedback_duration
					self._ecms[key].feedback_expire_t = data.feedback_expire_t
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_feedback_low" then
				if self._ecms[key].feedback_low ~= data.feedback_low then
					self._ecms[key].feedback_low = data.feedback_low
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_jammer_active" then
				if self._ecms[key].jammer_active ~= data.jammer_active then
					self._ecms[key].jammer_active = data.jammer_active
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_retrigger_active" then
				if self._ecms[key].retrigger_active ~= data.retrigger_active then
					self._ecms[key].retrigger_active = data.retrigger_active
					self._ecms[key].feedback_low = data.retrigger_active
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_feedback_active" then
				if self._ecms[key].feedback_active ~= data.feedback_active then
					self._ecms[key].feedback_active = data.feedback_active
					self:_listener_callback("ecm", event, key, self._ecms[key])
				end
			elseif event == "set_owner" then
				self._ecms[key].owner = data.owner
				self:_listener_callback("ecm", event, key, self._ecms[key])
			elseif event == "set_upgrade_level" then
				self._ecms[key].upgrade_level = data.upgrade_level
				self:_listener_callback("ecm", event, key, self._ecms[key])
			elseif event == "destroy" then
				self:_listener_callback("ecm", event, key, self._ecms[key])
				self._ecms[key] = nil
			end
		end
	end

	function GameInfoManager:_doc_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, "doc_bag")
	end

	function GameInfoManager:_first_aid_kit_event(event, key, data)
		self:_bag_deployable_event(event, key, data, "first_aid_kit")
	end

	function GameInfoManager:_ammo_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, "ammo_bag")
	end

	function GameInfoManager:_body_bag_event(event, key, data)
		self:_bag_deployable_event(event, key, data, "body_bag")
	end

	function GameInfoManager:_grenade_crate_event(event, key, data)
		self:_bag_deployable_event(event, key, data, "grenade_crate")
	end

	function GameInfoManager:_bag_deployable_event(event, key, data, type)
		if event == "create" then
			if not self._deployables[type][key] then
				self._deployables[type][key] = { unit = data.unit, type = type }
				self:_listener_callback(type, "create", key, self._deployables[type][key])
			end
		elseif self._deployables[type][key] then
			local function update_aggregate_attribute(aggregate_key, attr)
				if not self._deployables[type][aggregate_key] then return end

				local total = 0
				for k, v in pairs(self._deployables[type][aggregate_key].aggregate_members or {}) do
					if self._deployables[type][k].active then
						total = total + (self._deployables[type][k][attr] or 0)
					end
				end

				self._deployables[type][aggregate_key][attr] = total
				self:_listener_callback(type, "set_" .. attr, aggregate_key, self._deployables[type][aggregate_key])
				print_debug("UPDATE AGGREGATE %s: %s", tostring(attr), tostring(total), "info")
			end

			local lookup = GameInfoManager._EQUIPMENT.AGGREAGATE_ITEMS
			local level_id = managers.job:current_level_id() or ""
			local editor_id = self._deployables[type][key].unit:editor_id()
			local aggregate_key = lookup[type] or lookup[level_id] and lookup[level_id][editor_id]
			print_debug("_bag_deployable_event: %s | %s", type, self._deployables[type][key].unit:editor_id(), "info")
			if event == "destroy" then
				self:_listener_callback(type, "destroy", key, self._deployables[type][key])
				self._deployables[type][key] = nil

				if aggregate_key and self._deployables[type][aggregate_key] then
					self._deployables[type][aggregate_key].aggregate_members[key] = nil

					if next(self._deployables[type][aggregate_key].aggregate_members or {}) == nil then
						self:_listener_callback(type, "destroy", aggregate_key, self._deployables[type][aggregate_key])
						self._deployables[type][aggregate_key] = nil
					end
				end
			elseif event == "set_active" then
				if aggregate_key then
					self._deployables[type][key].aggregate_key = aggregate_key
				end

				if self._deployables[type][key].active ~= data.active then
					self._deployables[type][key].active = data.active
					self:_listener_callback(type, "set_active", key, self._deployables[type][key])
				end

				if aggregate_key then
					self._deployables[type][aggregate_key] = self._deployables[type][aggregate_key] or {
						position = self._deployables[type][key].unit:interaction():interact_position(),
						aggregate_members = {},
					}
					self._deployables[type][aggregate_key].aggregate_members[key] = true
					--TODO: Update position for each member added?

					local aggregate_active = false
					for k, v in pairs(self._deployables[type][aggregate_key].aggregate_members or {}) do
						if self._deployables[type][k].active then
							aggregate_active = true
							break
						end
					end

					if self._deployables[type][aggregate_key].active ~= aggregate_active then
						self._deployables[type][aggregate_key].active = aggregate_active
						self:_listener_callback(type, "set_active", aggregate_key, self._deployables[type][aggregate_key])
					end

					update_aggregate_attribute(aggregate_key, "amount")
					update_aggregate_attribute(aggregate_key, "max_amount")
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_owner" then
				self._deployables[type][key].owner = data.owner
				self:_listener_callback(type, "set_owner", key, self._deployables[type][key])

				--if aggregate_key then
				--	self._deployables[type][aggregate_key].owner = owner
				--	self:_listener_callback(type, "set_owner", aggregate_key, self._deployables[type][aggregate_key])
				--end
			elseif event == "set_upgrades" then
				self._deployables[type][key].upgrades = data.upgrades
				self:_listener_callback(type, "set_upgrades", key, self._deployables[type][key])
			elseif event == "set_max_amount" then
				self._deployables[type][key].max_amount = data.max_amount
				self:_listener_callback(type, "set_max_amount", key, self._deployables[type][key])

				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "max_amount")
				end
			elseif event == "set_amount_offset" then
				self._deployables[type][key].amount_offset = data.amount_offset
				self:_listener_callback(type, "set_amount_offset", key, self._deployables[type][key])

				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_amount" then
				self._deployables[type][key].amount = data.amount
				self:_listener_callback(type, "set_amount", key, self._deployables[type][key])

				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount")
				end
			end
		end
	end

	function GameInfoManager:_sentry_event(event, key, data)
		print_debug("_sentry_event(%s, %s)", event, key, "info")

		if event == "create" then
			local sentry_type = data.unit:base() and data.unit:base():get_type() or ""

			if not self._sentries[key] and (sentry_type == "sentry_gun" or sentry_type == "sentry_gun_silent") then --GameInfoManager._EQUIPMENT.SENTRY_KEYS[tostring(data.unit:name():key())] then
				self._sentries[key] = { unit = data.unit, kills = 0 }
				self:_listener_callback("sentry", event, key, self._sentries[key])
			end
		elseif self._sentries[key] then
			if event == "set_active" then
				if self._sentries[key].active == data.active then return end
				self._sentries[key].active = data.active
			elseif event == "set_ammo_ratio" then
				self._sentries[key].ammo_ratio = data.ammo_ratio
			elseif event == "increment_kills" then
				event = "set_kills"
				self._sentries[key].kills = self._sentries[key].kills + 1
			elseif event == "set_health_ratio" then
				self._sentries[key].health_ratio = data.health_ratio
			elseif event == "set_owner" then
				self._sentries[key].owner = data.owner
			elseif event == "destroy" then
				self:_sentry_event("set_active", key, { active = false })
				self._sentries[key] = nil
			end

			self:_listener_callback("sentry", event, key, self._sentries[key])
		end
	end

	function GameInfoManager:_whisper_mode_event(event, key, status)
		self:_listener_callback("whisper_mode", event, key, status)
	end

	function GameInfoManager:_temporary_buff_event(event, data)
		local buff_data = GameInfoManager._BUFFS[data.category][data.upgrade]
		local id = data.level and type(buff_data) == "table" and buff_data[data.level] or buff_data

		if id then
			self:_timed_buff_event(event, id, data)
			if data.value ~= 0 then
				self:_buff_event("set_value", id, { value = data.value })
			end
		else
			print_debug("Unknown temporary buff event: %s, %s, %s", tostring(event), tostring(data.category), tostring(data.upgrade), "warning")
		end
	end

	function GameInfoManager:_timed_buff_event(event, id, data)
		self:_buff_event(event, id, data)

		if event == "activate" then
			self:_buff_event("set_duration", id, { t = data.t, duration = data.duration, expire_t = data.expire_t })
            if data.expire_t or (data.t and data.duration) then
                self:_add_player_timer_expiration(id, id, data.expire_t or (data.t + data.duration), self._timed_buff_expire_clbk)
            end
		elseif event == "deactivate" then
			self:_remove_player_timer_expiration(id)
		elseif self._buffs[id] then
			if event == "set_expire" then
				self:_remove_player_timer_expiration(id)
				self:_add_player_timer_expiration(id, id, self._buffs[id].expire_t, self._timed_buff_expire_clbk)
			elseif event == "change_expire" then
				self:_remove_player_timer_expiration(id)
				self:_add_player_timer_expiration(id, id, self._buffs[id].expire_t, self._timed_buff_expire_clbk)
			end
		end
	end

	function GameInfoManager:_timed_stack_buff_event(event, id, data)
		print_debug("_timed_stack_buff_event(%s, %s)", tostring(event), tostring(id), "info")

		if event == "add_stack" then
			if not self._buffs[id] then
				self:_buff_event("activate", id)
				self._buffs[id].stacks = {}
			end

			local t = data.t or Application:time()
			local expire_t = data.expire_t or data.duration and (data.duration + t) or t
			local key = string.format("%s_%f_%f", id, t, math.random())

			local i = #self._buffs[id].stacks
			while self._buffs[id].stacks[i] and self._buffs[id].stacks[i].expire_t > expire_t do
				i = i - 1
			end
			table.insert(self._buffs[id].stacks, i + 1, { key = key, t = t, expire_t = expire_t })

			self:_listener_callback("buff", "add_timed_stack", id, self._buffs[id])
			self:_add_player_timer_expiration(key, id, expire_t, self._timed_stack_expire_clbk)
		end
	end

	function GameInfoManager:_buff_event(event, id, data)
		print_debug("_buff_event(%s, %s)", tostring(event), tostring(id), "info")

		if event == "activate" then
			if not self._buffs[id] then
				self._buffs[id] = data or {}
			else
				return
			end
		elseif self._buffs[id] then
			if event == "deactivate" then
				self._buffs[id] = nil
			elseif event == "set_duration" then
				local t = data.t or Application:time()
				local expire_t = data.expire_t or data.duration and (data.duration + t) or t
				self._buffs[id].t = t
				self._buffs[id].expire_t = expire_t
			elseif event == "set_stack_count" then
				self._buffs[id].stack_count = data.stack_count
			elseif event == "change_stack_count" then
				return self:_buff_event("set_stack_count", id, { stack_count = (self._buffs[id].stack_count or 0) + data.difference })
			elseif event == "increment_stack_count" then
				return self:_buff_event("set_stack_count", id, { stack_count = (self._buffs[id].stack_count or 0) + 1 })
			elseif event == "decrement_stack_count" then
				return self:_buff_event("set_stack_count", id, { stack_count = (self._buffs[id].stack_count or 0) - 1 })
			elseif event == "set_progress" then
				self._buffs[id].progress = data.progress
			elseif event == "set_value" then
				self._buffs[id].value = data.value
			elseif event == "set_expire" then
				local expire_t = data.duration and (data.duration + Application:time()) or data.expire_t
				return self:_buff_event("set_duration", id, { t = self._buffs[id].t, expire_t = expire_t })
			elseif event == "change_expire" then
				local expire_t = data.difference and (self._buffs[id].expire_t + data.difference) or data.expire_t
				return self:_buff_event("set_duration", id, { t = self._buffs[id].t, expire_t = expire_t })
			end
		else
			return
		end

		self:_listener_callback("buff", event, id, self._buffs[id])

		local clbk_name = "on_" .. event
		if GameInfoManager._BUFFS[clbk_name] and GameInfoManager._BUFFS[clbk_name][id] then
			GameInfoManager._BUFFS[clbk_name][id](id, self._buffs[id])
		end
	end

	function GameInfoManager:_team_buff_event(event, data)
		local buff_data = GameInfoManager._BUFFS[data.category] and GameInfoManager._BUFFS[data.category][data.upgrade]
		local id = buff_data and buff_data.id
		local level = buff_data and buff_data.level

		if id then
			if event == "activate" then
				local was_active = self._buffs[id]

				if not was_active then
					self:_buff_event("activate", id)
					self._buffs[id].peers = {}
					self._buffs[id].level = level
				end

				if not self._buffs[id].peers[data.peer] then
					self._buffs[id].peers[data.peer] = true
					self:_buff_event("change_stack_count", id, { difference = 1 })
				end

				if not was_active and data.value ~= 0 then
					self:_buff_event("set_value", id, { value = data.value })
				end
			elseif event == "deactivate" then
				if self._buffs[id] and self._buffs[id].peers[data.peer] then
					self._buffs[id].peers[data.peer] = nil
					self:_buff_event("change_stack_count", id, { difference = -1 })

					if next(self._buffs[id].peers) == nil then
						self:_buff_event("deactivate", id)
					end
				end
			end
		else
			print_debug("Unknown team buff event: %s, %s, %s", event, data.category, data.upgrade, "warning")
		end
	end

	function GameInfoManager:_player_action_event(event, id, data)
		print_debug("_player_action_event(%s, %s)", tostring(event), tostring(id), "info")

		if event == "activate" then
			if not self._player_actions[id] then
				self._player_actions[id] = {}
				self:_listener_callback("player_action", "activate", id, self._player_actions[id])
			end

			if data and (data.duration or data.expire_t) then
				self:_player_action_event("set_duration", id, data)
				self:_add_player_timer_expiration(id, id, self._player_actions[id].expire_t, self._player_actions_expire_clbk)
			end
		elseif self._player_actions[id] then
			if event == "deactivate" then
				self:_remove_player_timer_expiration(id)
				self._player_actions[id] = nil
			elseif event == "set_duration" then
				local t = data.t or Application:time()
				local expire_t = data.expire_t or data.duration and (data.duration + t) or t
				self._player_actions[id].t = t
				self._player_actions[id].expire_t = expire_t
			elseif event == "set_expire" then
				local expire_t = data.duration and (data.duration + Application:time()) or data.expire_t
				return self:_player_action_event("set_duration", id, { t = self._player_actions[id].t, expire_t = expire_t })
			elseif event == "change_expire" then
				local expire_t = data.difference and (self._player_actions[id].expire_t + data.difference) or data.expire_t
				return self:_player_action_event("set_duration", id, { t = self._player_actions[id].t, expire_t = expire_t })
			elseif event == "set_data" then
				self._player_actions[id].data = self._player_actions[id].data or {}
				for k, v in pairs(data) do
					self._player_actions[id].data[k] = v
				end
			end

			self:_listener_callback("player_action", event, id, self._player_actions[id])
		end
	end

	function GameInfoManager:register_listener(listener_id, source_type, event, clbk, keys, data_only)
		local listener_keys

		if keys then
			listener_keys = {}
			for _, key in ipairs(keys) do
				listener_keys[key] = true
			end
		end

		self._listeners[source_type] = self._listeners[source_type] or {}
		self._listeners[source_type][event] = self._listeners[source_type][event] or {}
		self._listeners[source_type][event][listener_id] = { clbk = clbk, keys = listener_keys, data_only = data_only }
	end

	function GameInfoManager:unregister_listener(listener_id, source_type, event)
		if self._listeners[source_type] then
			if self._listeners[source_type][event] then
				self._listeners[source_type][event][listener_id] = nil
			end
		end
	end

	function GameInfoManager:_listener_callback(source, event, key, ...)
		for listener_id, data in pairs(self._listeners[source] and self._listeners[source][event] or {}) do
			if not data.keys or data.keys[key] then
				if data.data_only then
					data.clbk(...)
				else
					data.clbk(event, key, ...)
				end
			end
		end
	end

	function GameInfoManager:_add_player_timer_expiration(key, id, expire_t, expire_clbk)
		if self._auto_expire_timers.on_expire[key] then
			self:_remove_player_timer_expiration(key)
		end

		local t = Application:time()
		if expire_t <= t then
			expire_clbk(t, key, id)
		else
			local expire_data = { key = key, id = id, expire_t = expire_t }
			local t_size = #self._auto_expire_timers.expire_t

			if (t_size <= 0) or (expire_t >= self._auto_expire_timers.expire_t[t_size].expire_t) then
				table.insert(self._auto_expire_timers.expire_t, expire_data)
			else
				for i = 1, t_size, 1 do
					if expire_t < self._auto_expire_timers.expire_t[i].expire_t then
						table.insert(self._auto_expire_timers.expire_t, i, expire_data)
						break
					end
				end
			end

			self._auto_expire_timers.on_expire[key] = expire_clbk
		end
	end

	function GameInfoManager:_remove_player_timer_expiration(key)
		if self._auto_expire_timers.on_expire[key] then
			for i, data in ipairs(self._auto_expire_timers.expire_t) do
				if data.key == key then
					table.remove(self._auto_expire_timers.expire_t, i)
					break
				end
			end

			self._auto_expire_timers.on_expire[key] = nil
		end
	end

	function GameInfoManager:_update_player_timer_expiration(ut, udt)
		local t = Application:time()
		local dt = t - self._t
		self._t = t

		while self._auto_expire_timers.expire_t[1] and self._auto_expire_timers.expire_t[1].expire_t < t do
			local data = self._auto_expire_timers.expire_t[1]
			local id = data.id
			local key = data.key
			self._auto_expire_timers.on_expire[key](t, key, id)
			self:_remove_player_timer_expiration(key)
		end
	end

	function GameInfoManager:_on_timed_buff_expired(t, key, id)
		self:_buff_event("deactivate", id)
	end

	function GameInfoManager:_on_timed_stack_expired(t, key, id)
		if self._buffs[id].stacks[1] then
			table.remove(self._buffs[id].stacks, 1)
			self:_listener_callback("buff", "remove_timed_stack", id, self._buffs[id])

			if #self._buffs[id].stacks <= 0 then
				self:_buff_event("deactivate", id)
			end
		end
	end

	function GameInfoManager:_on_player_action_expired(t, key, id)
		self:_player_action_event("deactivate", id)
	end

	function GameInfoManager:_recount_active_cameras()
		local count = 0

		for key, cam_data in pairs(self._cameras) do
			if cam_data.enabled ~= false and (cam_data.active or Network:is_client()) then
				local id = cam_data.unit and cam_data.unit:editor_id() or key
				print_debug("Camera (%s): Drone:%s Enabled:%s Active:%s Broken:%s Loop:%s", id, tostring(cam_data.is_drone), tostring(cam_data.enabled), tostring(cam_data.active), tostring(cam_data.broken), tostring(cam_data.tape_loop_expire_t and cam_data.tape_loop_expire_t > Application:time() and string.format("%.2f", cam_data.tape_loop_expire_t - Application:time()) or false), "info")

				if not cam_data.broken then
					count = count + 1
				end
			end
		end

		self._upd_camera_count = nil
		self:_listener_callback("camera_count", "set_count", nil, count)

		return count
	end

end

if string.lower(RequiredScript) == "lib/units/props/digitalgui" then

	local init_original = DigitalGui.init
	local update_original = DigitalGui.update
	local timer_set_original = DigitalGui.timer_set
	local timer_start_count_up_original = DigitalGui.timer_start_count_up
	local timer_start_count_down_original = DigitalGui.timer_start_count_down
	local timer_pause_original = DigitalGui.timer_pause
	local timer_resume_original = DigitalGui.timer_resume
	local _timer_stop_original = DigitalGui._timer_stop
	local load_original = DigitalGui.load
	local destroy_original = DigitalGui.destroy

	function DigitalGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		self._ignore = self.TYPE == "number"	--Maybe need move to after init?
		return init_original(self, unit, ...)
	end

	function DigitalGui:update(unit, t, ...)
		update_original(self, unit, t, ...)
		self._max_timer = self._max_timer or self._timer
		self:_do_timer_callback("update", t, self._timer, self._timer / self._max_timer)
	end

	function DigitalGui:timer_set(timer, ...)
		if not self._info_created and Network:is_server() then
			self._info_created = true
			self:_do_timer_callback("create", self._unit, self, "digital")
		end
		self:_do_timer_callback("set", timer)
		return timer_set_original(self, timer, ...)
	end

	function DigitalGui:timer_start_count_up(...)
		self:_do_timer_callback("start_count_up")
		return timer_start_count_up_original(self, ...)
	end

	function DigitalGui:timer_start_count_down(...)
		self:_do_timer_callback("start_count_down")
		return timer_start_count_down_original(self, ...)
	end

	function DigitalGui:timer_pause(...)
		self:_do_timer_callback("pause")
		return timer_pause_original(self, ...)
	end

	function DigitalGui:timer_resume(...)
		self:_do_timer_callback("resume")
		return timer_resume_original(self, ...)
	end

	function DigitalGui:_timer_stop(...)
		self:_do_timer_callback("stop")
		return _timer_stop_original(self, ...)
	end

	function DigitalGui:load(data, ...)
		self:_do_timer_callback("create", self._unit, self, "digital")

		load_original(self, data, ...)

		local state = data.DigitalGui
		if state.timer then
			self:_do_timer_callback("set", state.timer)
		end
		if state.timer_count_up then
			self:_do_timer_callback("start_count_up")
		end
		if state.timer_count_down then
			self:_do_timer_callback("start_count_down")
		end
		if state.timer_paused then
			self:_do_timer_callback("pause")
		end
	end

	function DigitalGui:destroy(...)
		self:_do_timer_callback("destroy")
		return destroy_original(self, ...)
	end

	function DigitalGui:_do_timer_callback(event, ...)
		if not self._ignore then
			managers.gameinfo:event("timer", event, self._info_key, ...)
		end
	end

end

if string.lower(RequiredScript) == "lib/units/props/drill" then

	local set_autorepair_original = Drill.set_autorepair

	function Drill:set_autorepair(...)
		set_autorepair_original(self, ...)

		local timer_gui = self._unit:timer_gui()
		if timer_gui and timer_gui._info_key then
			managers.gameinfo:event("timer", "set_autorepair", timer_gui._info_key, self._autorepair)
		end
	end

end

if string.lower(RequiredScript) == "lib/units/props/timergui" then

	local init_original = TimerGui.init
	local set_background_icons_original = TimerGui.set_background_icons
	local set_visible_original = TimerGui.set_visible
	local update_original = TimerGui.update
	local _start_original = TimerGui._start
	local _set_done_original = TimerGui._set_done
	local _set_jammed_original = TimerGui._set_jammed
	local _set_powered = TimerGui._set_powered
	local destroy_original = TimerGui.destroy

	function TimerGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		local device_type = unit:base().is_drill and "drill" or unit:base().is_hacking_device and "hack" or unit:base().is_saw and "saw" or "timer"
		if (unit:base().is_drill or unit:base().is_saw) and unit:base()._disable_upgrades then
			device_type = string.format("%s_noupgrade", device_type)
		end
		managers.gameinfo:event("timer", "create", self._info_key, unit, self, device_type)
		init_original(self, unit, ...)
	end

	function TimerGui:set_background_icons(...)
		if not self._unit:base()._disable_upgrades then
			local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
			local player_skills = Drill.get_upgrades(self._unit, nil)
			local function player_can_upgrade(drill_upgrades, player_upgrades)
				local template = Drill.create_upgrades(0, 0, 0, false, false)
				for k, v in pairs(template) do	--Force the tables to contain all data, at least in default value...
					drill_upgrades[k] 	= drill_upgrades[k] 	or v
					player_upgrades[k] 	= player_upgrades[k] 	or v
				end
				return player_upgrades.auto_repair_level_1 > drill_upgrades.auto_repair_level_1 or player_upgrades.auto_repair_level_2 > drill_upgrades.auto_repair_level_2 or player_upgrades.speed_upgrade_level > drill_upgrades.speed_upgrade_level or player_upgrades.silent_drill and not drill_upgrades.silent_drill or player_upgrades.reduced_alert and not drill_upgrades.reduced_alert
			end
			local can_upgrade = player_skills and player_can_upgrade(skills, player_skills) or false
			local upgrade_table = {
				restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
				faster = (skills.speed_upgrade_level or 0),
				silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0),
			}
			managers.gameinfo:event("timer", "set_upgradable", self._info_key, can_upgrade)
			managers.gameinfo:event("timer", "set_upgrades", self._info_key, upgrade_table)
		end

		return set_background_icons_original(self, ...)
	end

	function TimerGui:set_visible(visible, ...)
		if not visible and self._unit:base().is_drill then
			managers.gameinfo:event("timer", "set_active", self._info_key, false)
		end
		return set_visible_original(self, visible, ...)
	end

	function TimerGui:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)
		managers.gameinfo:event("timer", "update", self._info_key, t, self._time_left, self._current_timer / self._timer)
	end

	function TimerGui:_start(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, true)
		return _start_original(self, ...)
	end

	function TimerGui:_set_done(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, false)
		return _set_done_original(self, ...)
	end

	function TimerGui:_set_jammed(jammed, ...)
		managers.gameinfo:event("timer", "set_jammed", self._info_key, jammed and true or false)
		return _set_jammed_original(self, jammed, ...)
	end

	function TimerGui:_set_powered(powered, ...)
		managers.gameinfo:event("timer", "set_powered", self._info_key, powered and true or false)
		return _set_powered(self, powered, ...)
	end

	function TimerGui:destroy(...)
		managers.gameinfo:event("timer", "destroy", self._info_key)
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/props/securitylockgui" then

	local init_original = SecurityLockGui.init
	local update_original = SecurityLockGui.update
	local _start_original = SecurityLockGui._start
	local _set_done_original = SecurityLockGui._set_done
	local _set_jammed_original = SecurityLockGui._set_jammed
	local _set_powered = SecurityLockGui._set_powered
	local destroy_original = SecurityLockGui.destroy

	function SecurityLockGui:init(unit, ...)
		self._info_key = tostring(unit:key())
		managers.gameinfo:event("timer", "create", self._info_key, unit, self, "securitylock")
		managers.gameinfo:event("timer", "set_total_bars", self._info_key, self._bars)
		init_original(self, unit, ...)
	end

	function SecurityLockGui:update(unit, t, ...)
		update_original(self, unit, t, ...)
		managers.gameinfo:event("timer", "update", self._info_key, t, self._current_timer, self._current_timer / self._timer)
	end

	function SecurityLockGui:_start(bar, ...)
		managers.gameinfo:event("timer", "set_current_bar", self._info_key, bar)
		managers.gameinfo:event("timer", "set_active", self._info_key, true)

		return _start_original(self, bar, ...)
	end

	function SecurityLockGui:_set_done(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, false)
		return _set_done_original(self, ...)
	end

	function SecurityLockGui:_set_jammed(jammed, ...)
		managers.gameinfo:event("timer", "set_jammed", self._info_key, jammed and true or false)
		return _set_jammed_original(self, jammed, ...)
	end

	function SecurityLockGui:_set_powered(powered, ...)
		managers.gameinfo:event("timer", "set_powered", self._info_key, powered and true or false)
		return _set_powered(self, powered, ...)
	end

	function SecurityLockGui:destroy(...)
		managers.gameinfo:event("timer", "destroy", self._info_key)
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/managers/enemymanager" then

	local on_enemy_registered_original = EnemyManager.on_enemy_registered
	local on_enemy_unregistered_original = EnemyManager.on_enemy_unregistered
	local register_civilian_original = EnemyManager.register_civilian
	local on_civilian_died_original = EnemyManager.on_civilian_died
	local on_civilian_destroyed_original = EnemyManager.on_civilian_destroyed

	function EnemyManager:on_enemy_registered(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), { unit = unit })
		return on_enemy_registered_original(self, unit, ...)
	end

	function EnemyManager:on_enemy_unregistered(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_enemy_unregistered_original(self, unit, ...)
	end

	function EnemyManager:register_civilian(unit, ...)
		--if not unit:character_damage().immortal then
			managers.gameinfo:event("unit", "add", tostring(unit:key()), { unit = unit })
		--end
		return register_civilian_original(self, unit, ...)
	end

	function EnemyManager:on_civilian_died(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_civilian_died_original(self, unit, ...)
	end

	function EnemyManager:on_civilian_destroyed(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_civilian_destroyed_original(self, unit, ...)
	end

end

if string.lower(RequiredScript) == "lib/managers/group_ai_states/groupaistatebase" then

	local register_turret_original = GroupAIStateBase.register_turret
	local unregister_turret_original = GroupAIStateBase.unregister_turret
	local update_original = GroupAIStateBase.update
	local on_hostage_state_original = GroupAIStateBase.on_hostage_state
	local sync_hostage_headcount_original = GroupAIStateBase.sync_hostage_headcount
	local convert_hostage_to_criminal_original = GroupAIStateBase.convert_hostage_to_criminal
	local remove_minion_original = GroupAIStateBase.remove_minion
	local sync_converted_enemy_original = GroupAIStateBase.sync_converted_enemy
	local set_whisper_mode_original = GroupAIStateBase.set_whisper_mode

	function GroupAIStateBase:register_turret(unit, ...)
		managers.gameinfo:event("turret", "add", tostring(unit:key()), unit)
		return register_turret_original(self, unit, ...)
	end

	function GroupAIStateBase:unregister_turret(unit, ...)
		managers.gameinfo:event("turret", "remove", tostring(unit:key()), unit)
		return unregister_turret_original(self, unit, ...)
	end

	function GroupAIStateBase:update(t, ...)
		if self._hostage_count_expire_t and t < self._hostage_count_expire_t then
			self:_update_hostage_count()
		end

		return update_original(self, t, ...)
	end

	function GroupAIStateBase:on_hostage_state(...)
		on_hostage_state_original(self, ...)
		managers.enemy:add_delayed_clbk("hostage_count_update", callback(self, self, "_update_hostage_count"), Application:time() + 0.05)
	end

	function GroupAIStateBase:sync_hostage_headcount(...)
		sync_hostage_headcount_original(self, ...)

		self._hostage_count_expire_t = self._t + 10
	end

	function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		convert_hostage_to_criminal_original(self, unit, peer_unit, ...)

		if unit:brain()._logic_data.is_converted then
			local key = tostring(unit:key())
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
			local owner_base = peer_id and peer_id ~= managers.network:session():local_peer():id() and peer_unit:base() or managers.player
			local damage_mult = (owner_base:upgrade_value("player", "convert_enemies_damage_multiplier", 0) or 0)

			managers.gameinfo:event("minion", "add", key, { unit = unit })
			managers.gameinfo:event("minion", "set_owner", key, { owner = peer_id })
			if damage_mult > 0 then
				managers.gameinfo:event("minion", "set_damage_multiplier", key, { damage_multiplier = damage_mult })
			end
		end
	end

	function GroupAIStateBase:remove_minion(minion_key, ...)
		remove_minion_original(self, minion_key, ...)

		managers.gameinfo:event("minion", "remove", minion_key)
	end

	function GroupAIStateBase:sync_converted_enemy(converted_enemy, ...)
		if self._police[converted_enemy:key()] then
			managers.gameinfo:event("minion", "add", tostring(converted_enemy:key()), { unit = converted_enemy })
		end
		return sync_converted_enemy_original(self, converted_enemy, ...)
	end

	function GroupAIStateBase:set_whisper_mode(enabled, ...)
		set_whisper_mode_original(self, enabled, ...)
		managers.gameinfo:event("whisper_mode", "change", nil, enabled)
	end

	function GroupAIStateBase:_update_hostage_count()
		managers.player:update_hostage_situation(self._hostage_headcount)

		local police_hostages = 0
		local security_hostages = 0
		local civilian_hostages = self._hostage_headcount

		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) and (u_data.unit:brain():surrendered() or u_data.unit:base().mic_is_being_moved) then
				if u_data.unit:base()._tweak_table:find("security") or u_data.unit:base()._tweak_table:find("gensec") then
					security_hostages = security_hostages + 1
				else
					police_hostages = police_hostages + 1
				end
			end
		end

		civilian_hostages = civilian_hostages - police_hostages - security_hostages
		managers.gameinfo:event("unit_count", "set", "civ_hostage", civilian_hostages)
		managers.gameinfo:event("unit_count", "set", "cop_hostage", police_hostages)
		managers.gameinfo:event("unit_count", "set", "sec_hostage", security_hostages)
	end

end

if string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then

	local mark_minion_original = UnitNetworkHandler.mark_minion
	local hostage_trade_original = UnitNetworkHandler.hostage_trade
	local unit_traded_original = UnitNetworkHandler.unit_traded
	local interaction_set_active_original = UnitNetworkHandler.interaction_set_active
	local alarm_pager_interaction_original = UnitNetworkHandler.alarm_pager_interaction

	function UnitNetworkHandler:mark_minion(unit, owner_id, ...)
		mark_minion_original(self, unit, owner_id, ...)

		if self._verify_character(unit) then
			local key = tostring(unit:key())
            local peer = owner_id and owner_id ~= managers.network:session():local_peer():id() and managers.network:session():peer(owner_id)
			local owner_base = peer and peer:unit() and peer:unit():base() or managers.player
			local damage_mult = (owner_base:upgrade_value("player", "convert_enemies_damage_multiplier", 1) or 1) --* (owner_base:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1) or 1)

			managers.gameinfo:event("minion", "add", key, { unit = unit })
			managers.gameinfo:event("minion", "set_owner", key, { owner = owner_id })
			if damage_mult > 1 then
				managers.gameinfo:event("minion", "set_damage_multiplier", key, { damage_multiplier = damage_mult })
			end
		end
	end

	function UnitNetworkHandler:hostage_trade(unit, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end

		return hostage_trade_original(self, unit, ...)
	end

	function UnitNetworkHandler:unit_traded(unit, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end

		return unit_traded_original(self, unit, ...)
	end

	function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_sender(sender) then
			if tweak_data == "corpse_alarm_pager" then
				if not alive(unit) then
					local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
					unit = u_data and u_data.unit
				end

				if alive(unit) then
					if not active then
						--managers.gameinfo:event("pager", "remove", tostring(unit:key()))
					elseif not flash then
						managers.gameinfo:event("pager", "set_answered", tostring(unit:key()))
					end
				end
			end
		end

		return interaction_set_active_original(self, unit, u_id, active, tweak_data, flash, sender, ...)
	end

	function UnitNetworkHandler:alarm_pager_interaction(u_id, tweak_table, status, sender, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) then
			local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
			if unit_data and unit_data.unit:interaction():active() and unit_data.unit:interaction().tweak_data == tweak_table and self._verify_sender(sender) then
				if status == 1 then
					managers.gameinfo:event("pager", "set_answered", tostring(unit_data.unit:key()))
				else
					--managers.gameinfo:event("pager", "remove", tostring(unit_data.unit:key()))
				end
			end
		end

		return alarm_pager_interaction_original(self, u_id, tweak_table, status, sender, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/enemies/cop/copdamage" then

	local convert_to_criminal_original = CopDamage.convert_to_criminal
	local _on_damage_received_original = CopDamage._on_damage_received
	local chk_killshot_original = CopDamage.chk_killshot

	function CopDamage:_update_minion_dmg_resist(data)
		if alive(self._unit) then
			managers.gameinfo:event("minion", "set_damage_resistance", tostring(self._unit:key()), data)
		end
	end

	function CopDamage:convert_to_criminal(...)
		convert_to_criminal_original(self, ...)

		if self._damage_reduction_multiplier < 1 then
			local key = tostring(self._unit:key())
			local data = { damage_resistance = self._damage_reduction_multiplier }
			managers.enemy:add_delayed_clbk(key .. "_update_minion_dmg_resist", callback(self, self, "_update_minion_dmg_resist", data), 0)
		end
	end

	function CopDamage:_on_damage_received(damage_info, ...)
		if self._unit:in_slot(16) then
			managers.gameinfo:event("minion", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
		end
		return _on_damage_received_original(self, damage_info, ...)
	end

	function CopDamage:chk_killshot(attacker_unit, ...)
		if alive(attacker_unit) then
			local key = tostring(attacker_unit:key())

			if attacker_unit:in_slot(16) and managers.gameinfo:get_minions(key) then
				managers.gameinfo:event("minion", "increment_kills", key)
			elseif attacker_unit:in_slot(25) and managers.gameinfo:get_sentries(key) then
				managers.gameinfo:event("sentry", "increment_kills", key)
			end
		end

		return chk_killshot_original(self, attacker_unit, ...)
	end

end

if string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then

	local init_original = ObjectInteractionManager.init
	local update_original = ObjectInteractionManager.update
	local add_unit_original = ObjectInteractionManager.add_unit
	local remove_unit_original = ObjectInteractionManager.remove_unit
	local interact_original = ObjectInteractionManager.interact
	local end_action_interact_original = ObjectInteractionManager.end_action_interact

	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		self._queued_units = {}
	end

	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_process_queued_units(t)
	end

	function ObjectInteractionManager:add_unit(unit, ...)
		self:add_unit_clbk(unit)
		return add_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:remove_unit(unit, ...)
		self:remove_unit_clbk(unit)
		return remove_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:interact(...)
		if alive(self._active_unit) and self._active_unit:interaction() then
			if self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
				managers.gameinfo:event("pager", "set_answered", tostring(self._active_unit:key()))
			end
		end

		return interact_original(self, ...)
	end

	function ObjectInteractionManager:end_action_interact(...)
		local value = end_action_interact_original(self, ...)

		if alive(self._active_unit) and self._active_unit:interaction() then
			local id = self._active_unit:interaction().tweak_data
			local editor_id = self._active_unit:editor_id()
			managers.gameinfo:event("interactive_unit", "interact", tostring(self._active_unit:key()), { unit = self._active_unit, editor_id = editor_id, interact_id = id })
		end

		return value
	end

	function ObjectInteractionManager:add_unit_clbk(unit)
		self._queued_units[tostring(unit:key())] = unit
	end

	function ObjectInteractionManager:remove_unit_clbk(unit, interact_id)
		local key = tostring(unit:key())

		if self._queued_units[key] then
			self._queued_units[key] = nil
		else
			local id = interact_id or unit:interaction().tweak_data
			local editor_id = unit:editor_id()
			managers.gameinfo:event("interactive_unit", "remove", key, { unit = unit, editor_id = editor_id, interact_id = id })
		end
	end

	function ObjectInteractionManager:_process_queued_units(t)
		for key, unit in pairs(self._queued_units) do
			if alive(unit) then
				local interact_id = unit:interaction().tweak_data
				local editor_id = unit:editor_id()
				managers.gameinfo:event("interactive_unit", "add", key, { unit = unit, editor_id = editor_id, interact_id = interact_id })
			end
		end

		self._queued_units = {}
	end

end

if string.lower(RequiredScript) == "lib/units/interactions/interactionext" then

	local set_tweak_data_original = BaseInteractionExt.set_tweak_data

	function BaseInteractionExt:set_tweak_data(...)
		local old_tweak = self.tweak_data
		local was_active = self:active()

		set_tweak_data_original(self, ...)

		if was_active and self:active() and self.tweak_data ~= old_tweak then
			managers.interaction:remove_unit_clbk(self._unit, old_tweak)
			managers.interaction:add_unit_clbk(self._unit)
		end
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/ecm_jammer/ecmjammerbase" then

	local init_original = ECMJammerBase.init
	local setup_original = ECMJammerBase.setup
	local sync_setup_original = ECMJammerBase.sync_setup
	local set_active_original = ECMJammerBase.set_active
	local _set_feedback_active_original = ECMJammerBase._set_feedback_active
	local clbk_feedback_original = ECMJammerBase.clbk_feedback
	local sync_net_event_original = ECMJammerBase.sync_net_event
	local _set_battery_low_original = ECMJammerBase._set_battery_low
	local update_original = ECMJammerBase.update
	local contour_interaction_original = ECMJammerBase.contour_interaction
	local destroy_original = ECMJammerBase.destroy

	function ECMJammerBase:init(unit, ...)
		self._ecm_unit_key = tostring(unit:key())
		managers.gameinfo:event("ecm", "create", self._ecm_unit_key, { unit = unit })
		return init_original(self, unit, ...)
	end

	function ECMJammerBase:setup(upgrade_lvl, owner, ...)
		setup_original(self, upgrade_lvl, owner, ...)

		managers.gameinfo:event("ecm", "set_owner", self._ecm_unit_key, { owner = self._owner_id })
		managers.gameinfo:event("ecm", "set_upgrade_level", self._ecm_unit_key, { upgrade_level = upgrade_lvl })
	end

	function ECMJammerBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("ecm", "set_owner", self._ecm_unit_key, { owner = peer_id })
		managers.gameinfo:event("ecm", "set_upgrade_level", self._ecm_unit_key, { upgrade_level = upgrade_lvl })
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end

	function ECMJammerBase:set_active(active, ...)
		if self._jammer_active ~= active then
			managers.gameinfo:event("ecm", "set_jammer_active", self._ecm_unit_key, { jammer_active = active })
		end

		return set_active_original(self, active, ...)
	end

	function ECMJammerBase:_set_feedback_active(state, ...)
		if not state and self._feedback_active and managers.network and managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id() then
			local peer_id = managers.network:session():local_peer():id()

			if self._owner_id == peer_id and managers.player:has_category_upgrade("ecm_jammer", "can_retrigger") then
				self._retrigger_delay = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				managers.gameinfo:event("ecm", "set_retrigger_active", self._ecm_unit_key, { retrigger_active = true })
			end
		end
		managers.gameinfo:event("ecm", "set_feedback_active", self._ecm_unit_key, { feedback_active = state })
		local val = _set_feedback_active_original(self, state, ...)
		if Network:is_server() then
			managers.gameinfo:event("ecm", "set_feedback_duration", self._ecm_unit_key, { feedback_duration = self._feedback_duration, feedback_expire_t = self._feedback_expire_t })
		end
		return val
	end

	function ECMJammerBase:clbk_feedback(...)
		clbk_feedback_original(self, ...)
		if self._feedback_expire_t - TimerManager:game():time() < self._feedback_duration * 0.1 then
			managers.gameinfo:event("ecm", "set_feedback_low", self._ecm_unit_key, { feedback_low = true })
		end
	end

	function ECMJammerBase:sync_net_event(event_id, ...)
		sync_net_event_original(self, event_id, ...)

		if self._NET_EVENTS and event_id == self._NET_EVENTS.feedback_flash then
			managers.gameinfo:event("ecm", "set_feedback_low", self._ecm_unit_key, { feedback_low = true })
		end
	end

	function ECMJammerBase:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)

		if not self._battery_empty then
			managers.gameinfo:event("ecm", "set_jammer_battery", self._ecm_unit_key, { jammer_battery = self._battery_life })
		end

		if self._retrigger_delay then
			self._retrigger_delay = self._retrigger_delay - dt
			managers.gameinfo:event("ecm", "set_retrigger_delay", self._ecm_unit_key, { retrigger_delay = self._retrigger_delay })
			if self._retrigger_delay <= 0 then
				self._retrigger_delay = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
			end
		end

		if self._feedback_active and self._feedback_expire_t and self._feedback_expire_t < t then
			managers.gameinfo:event("ecm", "set_feedback_active", self._ecm_unit_key, { feedback_active = false })
		end
	end

	function ECMJammerBase:_set_battery_low(...)
		_set_battery_low_original(self, ...)
		managers.gameinfo:event("ecm", "set_battery_low", self._ecm_unit_key, { battery_low = true })
	end

	function ECMJammerBase:contour_interaction(...)
		if managers.network:session() and self._owner_id == managers.network:session():local_peer():id() and managers.player:has_category_upgrade("ecm_jammer", "can_activate_feedback") then
			self._retrigger_delay = nil
			managers.gameinfo:event("ecm", "set_retrigger_active", self._ecm_unit_key, { retrigger_active = false })
		end
		managers.gameinfo:event("ecm", "set_feedback_low", self._ecm_unit_key, { feedback_low = false })

		return contour_interaction_original(self, ...)
	end

	function ECMJammerBase:destroy(...)
		managers.gameinfo:event("ecm", "set_feedback_active", self._ecm_unit_key, { feedback_active = false })
		managers.gameinfo:event("ecm", "set_retrigger_active", self._ecm_unit_key, { retrigger_active = false })
		managers.gameinfo:event("ecm", "destroy", self._ecm_unit_key)
		destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/doctor_bag/doctorbagbase" then

	local spawn_original = DoctorBagBase.spawn
	local init_original = DoctorBagBase.init
	local setup_original = DoctorBagBase.setup
	local sync_setup_original = DoctorBagBase.sync_setup
	local _set_visual_stage_original = DoctorBagBase._set_visual_stage
	local _get_upgrade_levels_original = DoctorBagBase._get_upgrade_levels
	local destroy_original = DoctorBagBase.destroy

	function DoctorBagBase.spawn(pos, rot, amount_upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, amount_upgrade_lvl, peer_id, ...)
		if alive(unit) then
			local key = tostring(unit:key())
			managers.gameinfo:event("doc_bag", "create", key, { unit = unit })
			managers.gameinfo:event("doc_bag", "set_owner", key, { owner = peer_id })
		end
		return unit
	end

	function DoctorBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("doc_bag", "create", key, { unit = unit })
		managers.gameinfo:event("doc_bag", "set_max_amount", key, { max_amount = self._max_amount })
		init_original(self, unit, ...)
	end

	function DoctorBagBase:setup(...)
		local value = setup_original(self, ...)
		managers.gameinfo:event("doc_bag", "set_max_amount", tostring(self._unit:key()), { max_amount = self._amount })
		return value
	end

	function DoctorBagBase:sync_setup(amount_upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("doc_bag", "set_owner", tostring(self._unit:key()), { owner = peer_id })
		return sync_setup_original(self, amount_upgrade_lvl, peer_id, ...)
	end

	function DoctorBagBase:_set_visual_stage(...)
		managers.gameinfo:event("doc_bag", "set_amount", tostring(self._unit:key()), { amount = self._amount })
		return _set_visual_stage_original(self, ...)
	end

	function DoctorBagBase:_get_upgrade_levels(...)
		local upgrade_values = { _get_upgrade_levels_original(self, ...) }
		managers.gameinfo:event("doc_bag", "set_upgrades", tostring(self._unit:key()), { upgrades = { damage_reduction = upgrade_values[2] } })
		return unpack(upgrade_values)
	end

	function DoctorBagBase:destroy(...)
		managers.gameinfo:event("doc_bag", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/first_aid_kit/firstaidkitbase" then

	local spawn_original = FirstAidKitBase.spawn
	local init_original = FirstAidKitBase.init
	local sync_setup_original = FirstAidKitBase.sync_setup
	local _get_upgrade_levels_original = FirstAidKitBase._get_upgrade_levels
	local destroy_original = FirstAidKitBase.destroy

	function FirstAidKitBase.spawn(pos, rot, bits, peer_id, ...)
		local unit = spawn_original(pos, rot, bits, peer_id, ...)
		if alive(unit) then
			local key = tostring(unit:key())
			managers.gameinfo:event("first_aid_kit", "create", key, { unit = unit })
			managers.gameinfo:event("first_aid_kit", "set_owner", key, { owner = peer_id })
		end
		return unit
	end

	function FirstAidKitBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("first_aid_kit", "create", key, { unit = unit })
		init_original(self, unit, ...)
		managers.gameinfo:event("first_aid_kit", "set_amount", key, { amount = 1 })
	end

	function FirstAidKitBase:sync_setup(bits, peer_id, ...)
		managers.gameinfo:event("first_aid_kit", "set_owner", tostring(self._unit:key()), { owner = peer_id })
		return sync_setup_original(self, bits, peer_id, ...)
	end

	function FirstAidKitBase:_get_upgrade_levels(...)
		local upgrade_values = { _get_upgrade_levels_original(self, ...) }
		managers.gameinfo:event("first_aid_kit", "set_upgrades", tostring(self._unit:key()), { upgrades = { damage_reduction = upgrade_values[1], auto_recovery = upgrade_values[2] } })
		return unpack(upgrade_values)
	end

	function FirstAidKitBase:destroy(...)
		managers.gameinfo:event("first_aid_kit", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/ammo_bag/ammobagbase" then

	local spawn_original = AmmoBagBase.spawn
	local init_original = AmmoBagBase.init
	local setup_original = AmmoBagBase.setup
	local sync_setup_original = AmmoBagBase.sync_setup
	local _set_visual_stage_original = AmmoBagBase._set_visual_stage
	local destroy_original = AmmoBagBase.destroy

	function AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, peer_id, bullet_storm_level, ...)
		local unit = spawn_original(pos, rot, ammo_upgrade_lvl, peer_id, bullet_storm_level, ...)
		if alive(unit) then
			local key = tostring(unit:key())
			managers.gameinfo:event("ammo_bag", "create", key, { unit = unit })
			managers.gameinfo:event("ammo_bag", "set_owner", key, { owner = peer_id })
			managers.gameinfo:event("ammo_bag", "set_upgrades", key, { upgrades = { bullet_storm = bullet_storm_level } })
		end
		return unit
	end

	function AmmoBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("ammo_bag", "create", key, { unit = unit })
		managers.gameinfo:event("ammo_bag", "set_max_amount", key, { max_amount = self._max_ammo_amount })
		init_original(self, unit, ...)
	end

	function AmmoBagBase:setup(...)
		local value = setup_original(self, ...)
		managers.gameinfo:event("ammo_bag", "set_max_amount", tostring(self._unit:key()), { max_amount = self._ammo_amount })
		return value
	end

	function AmmoBagBase:sync_setup(ammo_upgrade_lvl, peer_id, bullet_storm_level, ...)
		local key = tostring(self._unit:key())
		managers.gameinfo:event("ammo_bag", "set_owner", key, { owner = peer_id })
		managers.gameinfo:event("ammo_bag", "set_upgrades", key, { upgrades = { bullet_storm = bullet_storm_level } })
		return sync_setup_original(self, ammo_upgrade_lvl, peer_id, bullet_storm_level, ...)
	end

	function AmmoBagBase:_set_visual_stage(...)
		managers.gameinfo:event("ammo_bag", "set_amount", tostring(self._unit:key()), { amount = self._ammo_amount })
		return _set_visual_stage_original(self, ...)
	end

	function AmmoBagBase:destroy(...)
		managers.gameinfo:event("ammo_bag", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/bodybags_bag/bodybagsbagbase" then

	local spawn_original = BodyBagsBagBase.spawn
	local init_original = BodyBagsBagBase.init
	local sync_setup_original = BodyBagsBagBase.sync_setup
	local _set_visual_stage_original = BodyBagsBagBase._set_visual_stage
	local destroy_original = BodyBagsBagBase.destroy

	function BodyBagsBagBase.spawn(pos, rot, upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, upgrade_lvl, peer_id, ...)
		if alive(unit) then
			local key = tostring(unit:key())
			managers.gameinfo:event("body_bag", "create", key, { unit = unit })
			managers.gameinfo:event("body_bag", "set_owner", key, { owner = peer_id })
		end
		return unit
	end

	function BodyBagsBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("body_bag", "create", key, { unit = unit })
		init_original(self, unit, ...)
		managers.gameinfo:event("body_bag", "set_max_amount", key, { max_amount = self._max_bodybag_amount })
	end

	function BodyBagsBagBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("body_bag", "set_owner", tostring(self._unit:key()), { owner = peer_id })
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end

	function BodyBagsBagBase:_set_visual_stage(...)
		managers.gameinfo:event("body_bag", "set_amount", tostring(self._unit:key()), { amount = self._bodybag_amount })
		return _set_visual_stage_original(self, ...)
	end

	function BodyBagsBagBase:destroy(...)
		managers.gameinfo:event("body_bag", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/grenade_crate/grenadecratebase" then

	local init_original = GrenadeCrateBase.init
	local _set_visual_stage_original = GrenadeCrateBase._set_visual_stage
	local destroy_original = GrenadeCrateBase.destroy
	local custom_init_original = CustomGrenadeCrateBase.init

	function GrenadeCrateBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("grenade_crate", "create", key, { unit = unit })
		init_original(self, unit, ...)
		managers.gameinfo:event("grenade_crate", "set_max_amount", key, { max_amount = self._max_grenade_amount })
	end

	function GrenadeCrateBase:_set_visual_stage(...)
		managers.gameinfo:event("grenade_crate", "set_amount", tostring(self._unit:key()), { amount = self._grenade_amount })
		return _set_visual_stage_original(self, ...)
	end

	function GrenadeCrateBase:destroy(...)
		managers.gameinfo:event("grenade_crate", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

	function CustomGrenadeCrateBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("grenade_crate", "create", key, { unit = unit })
		custom_init_original(self, unit, ...)
		managers.gameinfo:event("grenade_crate", "set_max_amount", key, { max_amount = self._max_grenade_amount })
	end

end

if string.lower(RequiredScript) == "lib/units/props/securitycamera" then

	local init_original = SecurityCamera.init
	local _start_tape_loop_original = SecurityCamera._start_tape_loop
	local _activate_tape_loop_restart_original = SecurityCamera._activate_tape_loop_restart
	local _deactivate_tape_loop_restart_original = SecurityCamera._deactivate_tape_loop_restart
	local _deactivate_tape_loop_original = SecurityCamera._deactivate_tape_loop
	local on_unit_set_enabled_original = SecurityCamera.on_unit_set_enabled
	local set_update_enabled_original = SecurityCamera.set_update_enabled
	local generate_cooldown_original = SecurityCamera.generate_cooldown
	local destroy_original = SecurityCamera.destroy

	function SecurityCamera:init(unit)
		managers.gameinfo:event("camera", "create", tostring(unit:key()), { unit = unit })
		return init_original(self, unit)
	end

	function SecurityCamera:_start_tape_loop(...)
		_start_tape_loop_original(self, ...)
		managers.gameinfo:event("camera", "set_tape_loop_active", tostring(self._unit:key()), { tape_loop_active = true })
		managers.gameinfo:event("camera", "set_tape_loop_expire_t", tostring(self._unit:key()), { tape_loop_expire_t = self._tape_loop_end_t + 5 })
	end

	function SecurityCamera:_activate_tape_loop_restart(...)
		_activate_tape_loop_restart_original(self, ...)
		managers.gameinfo:event("camera", "set_tape_loop_restart_active", tostring(self._unit:key()), { tape_loop_restart_active = true })
	end

	function SecurityCamera:_deactivate_tape_loop_restart(...)
		managers.gameinfo:event("camera", "set_tape_loop_restart_active", tostring(self._unit:key()), { tape_loop_restart_active = false })
		if not self._tape_loop_end_t then
			managers.gameinfo:event("camera", "set_tape_loop_active", tostring(self._unit:key()), { tape_loop_active = false })
		end

		return _deactivate_tape_loop_restart_original(self, ...)
	end

	function SecurityCamera:_deactivate_tape_loop(...)
		managers.gameinfo:event("camera", "set_tape_loop_active", tostring(self._unit:key()), { tape_loop_active = false })
		return _deactivate_tape_loop_original(self, ...)
	end

	function SecurityCamera:on_unit_set_enabled(enabled, ...)
		managers.gameinfo:event("camera", "set_enabled", tostring(self._unit:key()), {enabled = enabled})

		on_unit_set_enabled_original(self, enabled, ...)
	end

	function SecurityCamera:set_update_enabled(state, ...)
		managers.gameinfo:event("camera", "set_active", tostring(self._unit:key()), {active = state})

		return set_update_enabled_original(self, state, ...)
	end

	function SecurityCamera:generate_cooldown(...)
		managers.gameinfo:event("camera", "set_broken", tostring(self._unit:key()), { broken = true } )
		return generate_cooldown_original(self, ...)
	end

	function SecurityCamera:destroy(unit)
		managers.gameinfo:event("camera", "destroy", tostring(self._unit:key()))
		return destroy_original(self, unit)
	end
end

if string.lower(RequiredScript) == "lib/units/equipment/sentry_gun/sentrygunbase" then

	local spawn_original = SentryGunBase.spawn
	local init_original = SentryGunBase.init
	local sync_setup_original = SentryGunBase.sync_setup
	local destroy_original = SentryGunBase.destroy

	function SentryGunBase.spawn(owner, pos, rot, peer_id, ...)
		local unit = spawn_original(owner, pos, rot, peer_id, ...)
		if alive(unit) then
			managers.gameinfo:event("sentry", "create", tostring(unit:key()), { unit = unit })
			managers.gameinfo:event("sentry", "set_owner", tostring(unit:key()), { owner = peer_id })
		end
		return unit
	end

	function SentryGunBase:init(unit, ...)
		managers.gameinfo:event("sentry", "create", tostring(unit:key()), { unit = unit })
		init_original(self, unit, ...)
	end

	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("sentry", "set_owner", tostring(self._unit:key()), { owner = peer_id })
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end

	function SentryGunBase:destroy(...)
		managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end

end

if string.lower(RequiredScript) == "lib/units/equipment/sentry_gun/sentrygundamage" then

	local init_original = SentryGunDamage.init
	local set_health_original = SentryGunDamage.set_health
	local sync_health_original = SentryGunDamage.sync_health
	local _apply_damage_original = SentryGunDamage._apply_damage
	local die_original = SentryGunDamage.die
	local load_original = SentryGunDamage.load

	function SentryGunDamage:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), { active = true })
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
	end

	function SentryGunDamage:set_health(...)
		set_health_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
	end

	function SentryGunDamage:sync_health(...)
		sync_health_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
	end

	function SentryGunDamage:_apply_damage(...)
		local result = _apply_damage_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
		return result
	end

	function SentryGunDamage:die(...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), { active = false })
		return die_original(self, ...)
	end

	function SentryGunDamage:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), { health_ratio = self:health_ratio() })
	end

end

if string.lower(RequiredScript) == "lib/units/weapons/sentrygunweapon" then

	local init_original = SentryGunWeapon.init
	local change_ammo_original = SentryGunWeapon.change_ammo
	local sync_ammo_original = SentryGunWeapon.sync_ammo
	local load_original = SentryGunWeapon.load

	function SentryGunWeapon:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
	end

	function SentryGunWeapon:change_ammo(...)
		change_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
	end

	function SentryGunWeapon:sync_ammo(...)
		sync_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
	end

	function SentryGunWeapon:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
	end

end

if string.lower(RequiredScript) == "lib/managers/playermanager" then

	local spawned_player_original = PlayerManager.spawned_player
	local disable_cooldown_upgrade_original = PlayerManager.disable_cooldown_upgrade
	local activate_temporary_upgrade_original = PlayerManager.activate_temporary_upgrade
	local activate_temporary_upgrade_by_level_original = PlayerManager.activate_temporary_upgrade_by_level
	local deactivate_temporary_upgrade_original = PlayerManager.deactivate_temporary_upgrade
	local count_up_player_minions_original = PlayerManager.count_up_player_minions
	local count_down_player_minions_original = PlayerManager.count_down_player_minions
	local set_melee_dmg_multiplier_original = PlayerManager.set_melee_dmg_multiplier
	local mul_to_accuracy_multiplier_original = PlayerManager.mul_to_accuracy_multiplier
	local on_killshot_original = PlayerManager.on_killshot
	local aquire_team_upgrade_original = PlayerManager.aquire_team_upgrade
	local unaquire_team_upgrade_original = PlayerManager.unaquire_team_upgrade
	local add_synced_team_upgrade_original = PlayerManager.add_synced_team_upgrade
	local peer_dropped_out_original = PlayerManager.peer_dropped_out
	local on_headshot_dealt_original = PlayerManager.on_headshot_dealt
	local _on_messiah_recharge_event_original = PlayerManager._on_messiah_recharge_event
	local use_messiah_charge_original = PlayerManager.use_messiah_charge
	local mul_to_property_original = PlayerManager.mul_to_property
	local set_property_original = PlayerManager.set_property
	local remove_property_original = PlayerManager.remove_property
	local chk_wild_kill_counter_original = PlayerManager.chk_wild_kill_counter
	local set_synced_cocaine_stacks_original = PlayerManager.set_synced_cocaine_stacks
	local add_grenade_amount_original = PlayerManager.add_grenade_amount
	local start_ability_timer_original = PlayerManager.start_ability_timer
	local stop_ability_timer_original = PlayerManager.stop_ability_timer
	local speed_up_ability_timer_original = PlayerManager.speed_up_ability_timer
	local _dodge_shot_gain_original = PlayerManager._dodge_shot_gain
	local replenish_grenades_original = PlayerManager.replenish_grenades
	local _on_grenade_cooldown_end_original = PlayerManager._on_grenade_cooldown_end
	local speed_up_grenade_cooldown_original = PlayerManager.speed_up_grenade_cooldown
	local start_custom_cooldown_original = PlayerManager.start_custom_cooldown
	local _set_body_bags_amount_original = PlayerManager._set_body_bags_amount

	local PLAYER_HAS_SPAWNED = false
	function PlayerManager:spawned_player(id, ...)
		spawned_player_original(self, id, ...)

		if id == 1 then
			if not PLAYER_HAS_SPAWNED then
				PLAYER_HAS_SPAWNED = true

				for category, data in pairs(self._global.team_upgrades) do
					for upgrade, value in pairs(data) do
						local value = self:team_upgrade_value(category, upgrade, 0)
						managers.gameinfo:event("team_buff", "activate", { peer = 0, category = category, upgrade = upgrade, value = value })
					end
				end
			end

			if self:has_category_upgrade("player", "messiah_revive_from_bleed_out") and (self._messiah_charges or 0) > 0 then
				managers.gameinfo:event("buff", "activate", "messiah")
				managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = (self._messiah_charges or 0) })
			end

			if self:has_category_upgrade("player", "health_damage_reduction") then
				local value = (1 - self:upgrade_value("player", "health_damage_reduction", 1))
				managers.gameinfo:event("buff", "activate", "frenzy")
				managers.gameinfo:event("buff", "set_value", "frenzy", { value = value })
			end

			if self:has_category_upgrade("player", "headshot_regen_armor_bonus") then
				local function on_headshot()
					managers.gameinfo:event("timed_buff", "activate", "bullseye_debuff", { duration = tweak_data.upgrades.on_headshot_dealt_cooldown or 0 })
				end

				self._message_system:register(Message.OnHeadShot, "bullseye_debuff_listener", on_headshot)
			end

			self._is_sociopath = self:has_category_upgrade("player", "killshot_regen_armor_bonus") or
					self:has_category_upgrade("player", "killshot_close_regen_armor_bonus") or
					self:has_category_upgrade("player", "killshot_close_panic_chance") or
					self:has_category_upgrade("player", "melee_kill_life_leech")
		end
	end

	function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)
		activate_temporary_upgrade_original(self, category, upgrade, ...)

		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._temporary_upgrades[category][upgrade].expire_time
			local level
			local upgrade_level = self:upgrade_level(category, upgrade, 0)
			if upgrade_level > 0 then
				level = upgrade_level
			end
			local value = self:temporary_upgrade_value(category, upgrade, 0)

			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade, level = level, value = value })
			end
		end
	end

	function PlayerManager:disable_cooldown_upgrade(category, upgrade, ...)
		disable_cooldown_upgrade_original(self, category, upgrade, ...)

		if self._global.cooldown_upgrades[category] and self._global.cooldown_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._global.cooldown_upgrades[category][upgrade].cooldown_time

			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade })
			end
		end
	end

	function PlayerManager:activate_temporary_upgrade_by_level(category, upgrade, level, ...)
		activate_temporary_upgrade_by_level_original(self, category, upgrade, level, ...)

		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			local t = Application:time()
			local expire_t = self._temporary_upgrades[category][upgrade].expire_time
			local value = self:temporary_upgrade_value(category, upgrade, 0)
			if expire_t > t then
				managers.gameinfo:event("temporary_buff", "activate", { t = t, expire_t = expire_t, category = category, upgrade = upgrade, level = level, value = value })
			end
		end
	end

	function PlayerManager:deactivate_temporary_upgrade(category, upgrade, ...)
		if self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] then
			managers.gameinfo:event("temporary_buff", "deactivate", { category = category, upgrade = upgrade })
		end

		return deactivate_temporary_upgrade_original(self, category, upgrade, ...)
	end

	function PlayerManager:count_up_player_minions(...)
		local result = count_up_player_minions_original(self, ...)
		if self._local_player_minions > 0 then
			if self:has_category_upgrade("player", "minion_master_speed_multiplier") then
				managers.gameinfo:event("buff", "activate", "partner_in_crime")
			end
			if self:has_category_upgrade("player", "minion_master_health_multiplier") then
				managers.gameinfo:event("buff", "activate", "partner_in_crime_aced")
			end
		end
		return result
	end

	function PlayerManager:count_down_player_minions(...)
		local result = count_down_player_minions_original(self, ...)
		if self._local_player_minions <= 0 then
			managers.gameinfo:event("buff", "deactivate", "partner_in_crime")
			managers.gameinfo:event("buff", "deactivate", "partner_in_crime_aced")
		end
		return result
	end

	function PlayerManager:update_hostage_situation(num_hostages)
		local hostages = num_hostages or (managers.groupai and managers.groupai:state():hostage_count()) or 0
		local minions = self:num_local_minions() or 0
		local stack_count = hostages + minions

		if self:has_team_category_upgrade("health", "hostage_multiplier") or self:has_team_category_upgrade("stamina", "hostage_multiplier") or self:has_team_category_upgrade("damage_dampener", "hostage_multiplier") then
			if stack_count > 0 then
				local value = self:team_upgrade_value("damage_dampener", "hostage_multiplier", 0)
				managers.gameinfo:event("buff", "activate", "hostage_situation")
				managers.gameinfo:event("buff", "set_stack_count", "hostage_situation", { stack_count = stack_count })
				if value ~= 0 then
					managers.gameinfo:event("buff", "set_value", "hostage_situation", { value = value })
				end
			else
				managers.gameinfo:event("buff", "deactivate", "hostage_situation")
			end
		end

		self._HAS_HOSTAGES = (stack_count > 0)
	end

	function PlayerManager:set_melee_dmg_multiplier(...)
		local old_mult = self._melee_dmg_mul
		set_melee_dmg_multiplier_original(self, ...)
		if old_mult ~= self._melee_dmg_mul then
			managers.gameinfo:event("buff", "change_stack_count", "bloodthirst_basic", { difference = 1 })
		end
		managers.gameinfo:event("buff", "set_value", "bloodthirst_basic", { value = self._melee_dmg_mul })
	end

	function PlayerManager:on_killshot(...)
		local last_killshot = self._on_killshot_t
		local result = on_killshot_original(self, ...)

		if self._is_sociopath and self._on_killshot_t ~= last_killshot then
			managers.gameinfo:event("timed_buff", "activate", "sociopath_debuff", { expire_t = self._on_killshot_t })
		end

		local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)
		if gain_throwable_per_kill > 0 then
			managers.gameinfo:event("buff", "set_stack_count", "crew_throwable_regen", { stack_count = (gain_throwable_per_kill - (self._throw_regen_kills or 0)) })
		end

		return result
	end

	function PlayerManager:aquire_team_upgrade(upgrade, ...)
		aquire_team_upgrade_original(self, upgrade, ...)

		local value = self:team_upgrade_value(upgrade.category, upgrade.upgrade, 0)
		managers.gameinfo:event("team_buff", "activate", { peer = 0, category = upgrade.category, upgrade = upgrade.upgrade, value = value })
	end

	function PlayerManager:unaquire_team_upgrade(upgrade, ...)
		unaquire_team_upgrade_original(self, upgrade, ...)

		managers.gameinfo:event("team_buff", "deactivate", { peer = 0, category = upgrade.category, upgrade = upgrade.upgrade })
	end

	function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, ...)
		add_synced_team_upgrade_original(self, peer_id, category, upgrade, ...)

		local value = self:team_upgrade_value(category, upgrade, 0)
		managers.gameinfo:event("team_buff", "activate", { peer = peer_id, category = category, upgrade = upgrade, value = value })
	end

	function PlayerManager:peer_dropped_out(peer, ...)
		local peer_id = peer:id()

		for category, data in pairs(self._global.synced_team_upgrades[peer_id] or {}) do
			for upgrade, value in pairs(data) do
				managers.gameinfo:event("team_buff", "deactivate", { peer = peer_id, category = category, upgrade = upgrade })
			end
		end

		return peer_dropped_out_original(self, peer, ...)
	end

	function PlayerManager:on_headshot_dealt(...)
		local t = Application:time()
		if (self._on_headshot_dealt_t or 0) <= t and self:has_category_upgrade("player", "headshot_regen_armor_bonus") then
			managers.gameinfo:event("timed_buff", "activate", "bullseye_debuff", { t = t, duration = tweak_data.upgrades.on_headshot_dealt_cooldown or 0 })
		end

		return on_headshot_dealt_original(self, ...)
	end

	function PlayerManager:_on_messiah_recharge_event(...)
		_on_messiah_recharge_event_original(self, ...)

		if (self._messiah_charges or 0) > 0 then
			managers.gameinfo:event("buff", "activate", "messiah")
			managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = self._messiah_charges })
		else
			managers.gameinfo:event("buff", "deactivate", "messiah")
		end
	end

	function PlayerManager:use_messiah_charge(...)
		use_messiah_charge_original(self, ...)
		if (self._messiah_charges or 0) > 0 then
			managers.gameinfo:event("buff", "activate", "messiah")
			managers.gameinfo:event("buff", "set_stack_count", "messiah", { stack_count = self._messiah_charges })
		else
			managers.gameinfo:event("buff", "deactivate", "messiah")
		end
	end

	function PlayerManager:mul_to_property(name, value, ...)
		mul_to_property_original(self, name, value, ...)
		managers.gameinfo:event("buff", "change_stack_count", name, { difference = 1 })
		managers.gameinfo:event("buff", "set_value", name, { value = self:get_property(name, 1) })
	end

	function PlayerManager:set_property(name, value, ...)
		set_property_original(self, name, value, ...)

		if name == "revive_damage_reduction" then
			managers.gameinfo:event("buff", "activate", "combat_medic_passive")
			managers.gameinfo:event("buff", "set_value", "combat_medic_passive", { value = value })
		end
	end

	function PlayerManager:remove_property(name, ...)
		remove_property_original(self, name, ...)

		if name == "revive_damage_reduction" then
			managers.gameinfo:event("buff", "deactivate", "combat_medic_passive")
		end
	end

	function PlayerManager:chk_wild_kill_counter(...)
		local t = Application:time()
		local player = self:player_unit()
		local expire_t

		if alive(player) and (managers.player:has_category_upgrade("player", "wild_health_amount") or managers.player:has_category_upgrade("player", "wild_armor_amount")) then
			local dmg = player:character_damage()
			local missing_health_ratio = math.clamp(1 - dmg:health_ratio(), 0, 1)
			local missing_armor_ratio = math.clamp(1 - dmg:armor_ratio(), 0, 1)
			local less_armor_wild_cooldown = managers.player:upgrade_value("player", "less_armor_wild_cooldown", 0)
			local less_health_wild_cooldown = managers.player:upgrade_value("player", "less_health_wild_cooldown", 0)
			local trigger_cooldown = tweak_data.upgrades.wild_trigger_time or 30

			if less_health_wild_cooldown ~= 0 and less_health_wild_cooldown[1] ~= 0 then
				local missing_health_stacks = math.floor(missing_health_ratio / less_health_wild_cooldown[1])
				trigger_cooldown = trigger_cooldown - less_health_wild_cooldown[2] * missing_health_stacks
			end
			if less_armor_wild_cooldown ~= 0 and less_armor_wild_cooldown[1] ~= 0 then
				local missing_armor_stacks = math.floor(missing_armor_ratio / less_armor_wild_cooldown[1])
				trigger_cooldown = trigger_cooldown - less_armor_wild_cooldown[2] * missing_armor_stacks
			end

			expire_t = t + math.max(trigger_cooldown, 0)
		end

		local old_stacks = 0
		if self._wild_kill_triggers then
			old_stacks = #self._wild_kill_triggers
			for i = 1, #self._wild_kill_triggers, 1 do
				if self._wild_kill_triggers[i] > t then
					break
				end
				old_stacks = old_stacks - 1
			end
		end

		chk_wild_kill_counter_original(self, ...)

		if self._wild_kill_triggers and #self._wild_kill_triggers > old_stacks then
			managers.gameinfo:event("timed_stack_buff", "add_stack", "biker", { t = t, expire_t = expire_t })
		end
	end

	function PlayerManager:set_synced_cocaine_stacks(...)
		set_synced_cocaine_stacks_original(self, ...)

		local max_stack_data = { amount = 0 }
		for peer_id, data in pairs(self._global.synced_cocaine_stacks) do
			if data.in_use and data.amount > max_stack_data.amount then
				max_stack_data = data
			end
		end

		local ratio = max_stack_data.amount / tweak_data.upgrades.max_total_cocaine_stacks
		if ratio > 0 then
			managers.gameinfo:event("buff", "activate", "maniac")
			managers.gameinfo:event("buff", "set_progress", "maniac", { progress = ratio } )

			local my_id = managers.network:session() and managers.network:session():local_peer():id()
			local mult_level = my_id and self._global.synced_cocaine_stacks[my_id] and self._global.synced_cocaine_stacks[my_id].power_level or 0
			local damage_absorb = self:_get_cocaine_damage_absorption_from_data(max_stack_data) * self:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", mult_level or 0, 1)
			managers.gameinfo:event("buff", "set_value", "maniac", { value = damage_absorb * 10 } )

			if (self._last_stack_decay or 0) < (self._damage_dealt_to_cops_decay_t or tweak_data.upgrades.cocaine_stacks_decay_t or 5) then
				managers.gameinfo:event("timed_buff", "activate", "maniac_debuff", { expire_t = self._damage_dealt_to_cops_decay_t })
			end

			self._last_stack_decay = (self._damage_dealt_to_cops_decay_t or 0)
		else
			managers.gameinfo:event("buff", "deactivate", "maniac")
		end
	end

	function PlayerManager:add_grenade_amount(...)
		add_grenade_amount_original(self, ...)

		local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)
		if gain_throwable_per_kill > 0 and not self:got_ability() and not self:got_max_grenades() then
			managers.gameinfo:event("buff", "activate", "crew_throwable_regen")
			managers.gameinfo:event("buff", "set_stack_count", "crew_throwable_regen", { stack_count = (gain_throwable_per_kill - (self._throw_regen_kills or 0) + 1) })
		else
			managers.gameinfo:event("buff", "deactivate", "crew_throwable_regen")
		end
	end

	function PlayerManager:_dodge_shot_gain(gain_value, ...)
		if gain_value then
			if gain_value > 0 then
				managers.gameinfo:event("buff", "activate", "sicario_dodge")
				managers.gameinfo:event("buff", "set_value", "sicario_dodge", { value = gain_value * self:upgrade_value("player", "sicario_multiplier", 1) })
				managers.gameinfo:event("timed_buff", "activate", "sicario_dodge_debuff", { duration = tweak_data.upgrades.values.player.dodge_shot_gain[1][2] })	--self:upgrade_value("player", "dodge_shot_gain")[2]
			else
				managers.gameinfo:event("buff", "deactivate", "sicario_dodge")
			end
		end

		return _dodge_shot_gain_original(self, gain_value, ...)
	end

	function PlayerManager:replenish_grenades(cooldown, ...)
		if not self:has_active_timer("replenish_grenades") then
			local id = managers.blackmarket:equipped_grenade()

			if id then
				managers.gameinfo:event("buff", "activate", id .. "_debuff")
				managers.gameinfo:event("buff", "set_duration", id .. "_debuff", { duration = cooldown })
			end
		end

		return replenish_grenades_original(self, cooldown, ...)
 	end

	function PlayerManager:_on_grenade_cooldown_end(...)
		local id = managers.blackmarket:equipped_grenade()

		if id then
			managers.gameinfo:event("buff", "deactivate", id .. "_debuff")
		end

		return _on_grenade_cooldown_end_original(self, ...)
	end

	function PlayerManager:speed_up_grenade_cooldown(time, ...)
		if self:has_active_timer("replenish_grenades") then
			local equipped_grenade = managers.blackmarket:equipped_grenade()
			managers.gameinfo:event("timed_buff", "change_expire", equipped_grenade .. "_debuff", { difference = -time })
		end

		return speed_up_grenade_cooldown_original(self, time, ...)
	end

	function PlayerManager:start_custom_cooldown(category, upgrade, cooldown, ...)
		managers.gameinfo:event("timed_buff", "activate", upgrade .. "_debuff", { duration = cooldown })
		return start_custom_cooldown_original(self, category, upgrade, cooldown, ...)
	end

	function PlayerManager:_set_body_bags_amount(body_bags_amount)
		managers.gameinfo:event("bodybags", "set", nil, body_bags_amount)
		return _set_body_bags_amount_original(self, body_bags_amount)
	end

	function PlayerManager:got_ability(grenade_id)
		local equipped_grenade = grenade_id or managers.blackmarket:equipped_grenade()
		return tweak_data.blackmarket.projectiles[equipped_grenade].ability
	end

end

if string.lower(RequiredScript) == "lib/managers/player/smokescreeneffect" then

	local init_original = SmokeScreenEffect.init

	function SmokeScreenEffect:init(position, normal, time, has_dodge_bonus, grenade_unit, ...)
		init_original(self, position, normal, time, has_dodge_bonus, grenade_unit, ...)

		self._unit_key = grenade_unit and tostring(grenade_unit:key())
	end

	function SmokeScreenEffect:get_key()
		return self._unit_key
	end

	function SmokeScreenEffect:get_time_remaining()
		return self._timer or 0
	end

end

if string.lower(RequiredScript) == "lib/utils/temporarypropertymanager" then

	local activate_property_original = TemporaryPropertyManager.activate_property
	local remove_property_original = TemporaryPropertyManager.remove_property

	function TemporaryPropertyManager:activate_property(prop, time, value, ...)
		managers.gameinfo:event("temporary_buff", "activate", { duration = time, category = "temporary", upgrade = prop, value = value })
		return activate_property_original(self, prop, time, value, ...)
	end

	function TemporaryPropertyManager:remove_property(prop, ...)
		managers.gameinfo:event("temporary_buff", "deactivate", { category = "temporary", upgrade = prop })
		return remove_property_original(self, prop, ...)
	end

end

if string.lower(RequiredScript) == "lib/modifiers/boosts/gagemodifiermeleeinvincibility" then

	local OnPlayerManagerKillshot_original = GageModifierMeleeInvincibility.OnPlayerManagerKillshot

	function GageModifierMeleeInvincibility:OnPlayerManagerKillshot(...)
		local last_kill_t = self._special_kill_t or 0

		OnPlayerManagerKillshot_original(self, ...)

		if (self._special_kill_t or 0) > last_kill_t then
			managers.gameinfo:event("timed_buff", "activate", "invulnerable_buff", { duration = self:value() })
		end
	end

end

if string.lower(RequiredScript) == "lib/modifiers/boosts/gagemodifierlifesteal" then

	local OnPlayerManagerKillshot_original = GageModifierLifeSteal.OnPlayerManagerKillshot

	function GageModifierLifeSteal:OnPlayerManagerKillshot(...)
		local last_kill_t = self._last_killshot_t or 0

		OnPlayerManagerKillshot_original(self, ...)

		if (self._last_killshot_t or 0) > last_kill_t then
			managers.gameinfo:event("timed_buff", "activate", "life_steal_debuff", { duration = self:value("cooldown")})
		end
	end

end

if string.lower(RequiredScript) == "lib/units/beings/player/playermovement" then

	local update_original = PlayerMovement.update
	local on_morale_boost_original = PlayerMovement.on_morale_boost

	function PlayerMovement:update(unit, t, dt, ...)
		self:_update_position_buffs(t, dt)
		self:_update_base_dodge(t, dt)
		return update_original(self, unit, t, dt, ...)
	end

	function PlayerMovement:on_morale_boost(...)
		managers.gameinfo:event("timed_buff", "activate", "inspire", { duration = tweak_data.upgrades.morale_boost_time })
		return on_morale_boost_original(self, ...)
	end

	local BUFFS_RECHECK_T = 0
	local BUFFS_RECHECK_INTERVAL = 0.5

	local FAK_IN_RANGE = false
	local IN_SMOKE_SCREEN = false

	function PlayerMovement:_update_position_buffs(t, dt)
		if t > BUFFS_RECHECK_T and alive(self._unit) then
			if FirstAidKitBase.GetFirstAidKit(self._unit:position()) then
				if not FAK_IN_RANGE then
					FAK_IN_RANGE = true
					managers.gameinfo:event("buff", "activate", "uppers")
				end
			elseif FAK_IN_RANGE then
				FAK_IN_RANGE = false
				managers.gameinfo:event("buff", "deactivate", "uppers")
			end

			local longest_smoke, smoke_dodge, smoked_units = nil, 0, {}
			for _, smoke_screen in ipairs(managers.player:smoke_screens() or {}) do
				if smoke_screen:alive() and smoke_screen:is_in_smoke(self._unit) then
					if not longest_smoke or (longest_smoke:get_time_remaining() < smoke_screen:get_time_remaining()) then
						longest_smoke = smoke_screen
					end

					if not smoke_screen:mine() then
						smoke_dodge = smoke_dodge + smoke_screen:dodge_bonus()
					end

					for key, _ in pairs(smoke_screen._unit_list or {}) do
						smoked_units[key] = smoked_units[key] or true
					end
				end
			end

			if longest_smoke and longest_smoke:alive() then
				if not IN_SMOKE_SCREEN or type(IN_SMOKE_SCREEN) == "string" and IN_SMOKE_SCREEN ~= (longest_smoke:get_key() or "") then
					IN_SMOKE_SCREEN = longest_smoke:get_key() or true
					managers.gameinfo:event("buff", "activate", "smoke_screen_grenade")
					managers.gameinfo:event("buff", "set_duration", "smoke_screen_grenade", { duration = longest_smoke:get_time_remaining() })
				end
				managers.gameinfo:event("buff", "set_stack_count", "smoke_screen_grenade", { stack_count = table.size(smoked_units) })
				managers.gameinfo:event("buff", "set_value", "smoke_screen_grenade", { value = smoke_dodge })
			elseif IN_SMOKE_SCREEN then
				IN_SMOKE_SCREEN = false
				managers.gameinfo:event("buff", "set_stack_count", "smoke_screen_grenade", { stack_count = nil })
				managers.gameinfo:event("buff", "set_value", "smoke_screen_grenade", { value = 0 })
				managers.gameinfo:event("buff", "deactivate", "smoke_screen_grenade")
			end

			BUFFS_RECHECK_T = t + BUFFS_RECHECK_INTERVAL
		end
	end

	local LAST_BASE_DODGE
	local DODGE_RECHECK_T = 0
	local DODGE_RECHECK_INTERVAL = 0.5
	function PlayerMovement:_update_base_dodge(t, dt)
		if t > DODGE_RECHECK_T and alive(self._unit) then
			local base_dodge = 0
			if self:running() then
				base_dodge = base_dodge + managers.player:upgrade_value("player", "run_dodge_chance", 0)
			elseif self:crouching() then
				base_dodge = base_dodge + managers.player:upgrade_value("player", "crouch_dodge_chance", 0)
			elseif self:zipline_unit() then
				base_dodge = base_dodge + managers.player:upgrade_value("player", "on_zipline_dodge_chance", 0)
			end

			if not LAST_BASE_DODGE or LAST_BASE_DODGE ~= base_dodge then
                if base_dodge > 0 then
                    managers.gameinfo:event("buff", "activate", "movement_dodge")
                    managers.gameinfo:event("buff", "set_value", "movement_dodge", { value = base_dodge })
                else
                    managers.gameinfo:event("buff", "deactivate", "movement_dodge")
                end
				LAST_BASE_DODGE = base_dodge
			end

			DODGE_RECHECK_T = t + DODGE_RECHECK_INTERVAL
		end
	end
end

if string.lower(RequiredScript) == "lib/units/beings/player/playerinventory" then

	local _start_jammer_effect_original = PlayerInventory._start_jammer_effect
	local _stop_jammer_effect_original = PlayerInventory._stop_jammer_effect
	local _start_feedback_effect_original = PlayerInventory._start_feedback_effect
	local _stop_feedback_effect_original = PlayerInventory._stop_feedback_effect
	local get_jammer_time_original = PlayerInventory.get_jammer_time

	function PlayerInventory:_start_jammer_effect(end_time, ...)
		managers.gameinfo:event("buff", "activate", "pocket_ecm_jammer")
		managers.gameinfo:event("buff", "set_duration", "pocket_ecm_jammer", { expire_t = end_time or ((self:get_jammer_time() or 0) + (TimerManager:game():time() or 0)) })

		return _start_jammer_effect_original(self, end_time, ...)
	end

	function PlayerInventory:_stop_jammer_effect(...)
		if self._jammer_data and self._jammer_data.effect == "jamming" then
			managers.gameinfo:event("buff", "deactivate", "pocket_ecm_jammer")
		end

		return _stop_jammer_effect_original(self, ...)
	end

	function PlayerInventory:_start_feedback_effect(end_time, ...)
		managers.gameinfo:event("buff", "activate", "pocket_ecm_jammer")
		managers.gameinfo:event("buff", "set_duration", "pocket_ecm_jammer", { expire_t = end_time or ((self:get_jammer_time() or 0) + (TimerManager:game():time() or 0)) })

		return _start_feedback_effect_original(self, end_time, ...)
	end

	function PlayerInventory:_stop_feedback_effect(...)
		if self._jammer_data and self._jammer_data.effect == "feedback" then
			managers.gameinfo:event("buff", "deactivate", "pocket_ecm_jammer")
		end

		return _stop_feedback_effect_original(self, ...)
	end

	function PlayerInventory:get_jammer_time(...)	-- TMP: Fix for non existing upgrade values causing crashes
		local tweak = tweak_data.upgrades.values.player.pocket_ecm_jammer_base
		local result

		if self._unit:base():upgrade_value("player", "pocket_ecm_jammer_base") then
			result = get_jammer_time_original(self, ...)
		end

		return result or tweak and tweak[1] and tweak[1].duration or 6
	end
end

if string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then

	local _do_action_intimidate_original = PlayerStandard._do_action_intimidate
	local _start_action_melee_original = PlayerStandard._start_action_melee
	local _interupt_action_melee_original = PlayerStandard._interupt_action_melee
	local _do_melee_damage_original = PlayerStandard._do_melee_damage
	local _start_action_interact_original = PlayerStandard._start_action_interact
	local _interupt_action_interact_original = PlayerStandard._interupt_action_interact
	local _start_action_use_item_original = PlayerStandard._start_action_use_item
	local _interupt_action_use_item_original = PlayerStandard._interupt_action_use_item
	local _update_use_item_timers_original = PlayerStandard._update_use_item_timers
	local _start_action_reload_original = PlayerStandard._start_action_reload
	local _update_reload_timers_original = PlayerStandard._update_reload_timers
	local _interupt_action_reload_original = PlayerStandard._interupt_action_reload
	local _start_action_charging_weapon_original = PlayerStandard._start_action_charging_weapon
	local _end_action_charging_weapon_original = PlayerStandard._end_action_charging_weapon
	local _update_equip_weapon_timers_original = PlayerStandard._update_equip_weapon_timers

	function PlayerStandard:_do_action_intimidate(t, interact_type, ...)
		if interact_type == "cmd_gogo" or interact_type == "cmd_get_up" then
			local duration = (tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1)) or 3.5
			managers.gameinfo:event("timed_buff", "activate", "inspire_debuff", { duration = duration })
		end

		return _do_action_intimidate_original(self, t, interact_type, ...)
	end

	function PlayerStandard:_start_action_melee(t, input, instant, ...)
		if not instant then
			local duration = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time
			managers.gameinfo:event("player_action", "activate", "melee_charge")
			managers.gameinfo:event("player_action", "set_duration", "melee_charge", { duration = duration })
		end

		return _start_action_melee_original(self, t, input, instant, ...)
	end

	function PlayerStandard:_interupt_action_melee(...)
		if self._state_data.melee_start_t then
			managers.gameinfo:event("player_action", "deactivate", "melee_charge")
		end

		return _interupt_action_melee_original(self, ...)
	end

	function PlayerStandard:_do_melee_damage(t, ...)
		if self._state_data.melee_start_t then
			managers.gameinfo:event("player_action", "deactivate", "melee_charge")
		end

		local result = _do_melee_damage_original(self, t, ...)

		if self._state_data.stacking_dmg_mul then
			self:_check_damage_stack_skill(t, "melee")
		end

		return result
	end

	function PlayerStandard:_start_action_interact(t, input, timer, interact_object, ...)
		if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
			local value = managers.player:upgrade_value("player", "interacting_damage_multiplier", 0)
			managers.gameinfo:event("buff", "activate", "die_hard")
			managers.gameinfo:event("buff", "set_value", "die_hard", { value = value })
		end

		local time = Application:time()
		managers.gameinfo:event("player_action", "activate", "interact", { t = time, duration = timer })
		managers.gameinfo:event("player_action", "set_data", "interact", { interact_id = interact_object:interaction().tweak_data })

		return _start_action_interact_original(self, t, input, timer, interact_object, ...)
	end

	function PlayerStandard:_interupt_action_interact(t, input, complete, ...)
		if self._interact_expire_t then
			if managers.player:has_category_upgrade("player", "interacting_damage_multiplier") then
				managers.gameinfo:event("buff", "deactivate", "die_hard")
			end

			managers.gameinfo:event("player_action", "deactivate", "interact")
		end

		local previous_weapon_exire_t = self._equip_weapon_expire_t
		local value = _interupt_action_interact_original(self, t, input, complete, ...)

		if self._equip_weapon_expire_t and not previous_weapon_exire_t then
			local t = Application:time()
			managers.gameinfo:event("player_action", "activate", "interact_debuff", { t = t, expire_t = self._equip_weapon_expire_t })
		end

		return value
	end

	function PlayerStandard:_start_action_use_item(t, ...)
		local equipment_id = managers.player:selected_equipment_id()
		local timer = managers.player:selected_equipment_deploy_timer()
		managers.gameinfo:event("player_action", "activate", "interact", { t = t, duration = timer })
		managers.gameinfo:event("player_action", "set_data", "interact", { interact_id = equipment_id })

		return _start_action_use_item_original(self, t, ...)
	end

	function PlayerStandard:_interupt_action_use_item(t, input, complete, ...)
		if self._use_item_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "interact")
		end

		local previous_weapon_exire_t = self._equip_weapon_expire_t
		local value = _interupt_action_use_item_original(self, t, input, complete, ...)

		if self._equip_weapon_expire_t and not previous_weapon_exire_t then
			local t = Application:time()
			managers.gameinfo:event("player_action", "activate", "interact_debuff", { t = t, expire_t = self._equip_weapon_expire_t })
		end

		return value
	end

	function PlayerStandard:_update_use_item_timers(...)
		_update_use_item_timers_original(self, ...)

		if self._use_item_expire_t then
			local valid = managers.player:check_selected_equipment_placement_valid(self._unit)
			managers.gameinfo:event("player_action", "set_data", "interact", { invalid = not valid })
		end
	end

	function PlayerStandard:_start_action_reload(t, ...)
		_start_action_reload_original(self, t, ...)

		if self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "activate", "reload", { expire_t = self._state_data.reload_expire_t })
		end
	end

	function PlayerStandard:_update_reload_timers(...)
		local reloading = self._state_data.reload_expire_t

		_update_reload_timers_original(self, ...)

		if reloading and not self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "reload")
		end
	end

	function PlayerStandard:_interupt_action_reload(...)
		if self._state_data.reload_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "reload")
		end
		return _interupt_action_reload_original(self, ...)
	end

	function PlayerStandard:_start_action_charging_weapon(t, ...)
		managers.gameinfo:event("player_action", "activate", "weapon_charge")
		managers.gameinfo:event("player_action", "set_duration", "weapon_charge", { duration = self._equipped_unit:base():charge_max_t() })
		return _start_action_charging_weapon_original(self, t, ...)
	end

	function PlayerStandard:_end_action_charging_weapon(...)
		if self._state_data.charging_weapon then
			managers.gameinfo:event("player_action", "deactivate", "weapon_charge")
		end
		return _end_action_charging_weapon_original(self, ...)
	end

	function PlayerStandard:_update_equip_weapon_timers(...)
		local old_equip_weapon_expire_t = self._equip_weapon_expire_t
		local value = _update_equip_weapon_timers_original(self, ...)

		if old_equip_weapon_expire_t and not self._equip_weapon_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "interact_debuff")
		end

		return value
	end

	--OVERRIDE
	function PlayerStandard:_update_omniscience(t, dt)
		local action_forbidden =
		not managers.player:has_category_upgrade("player", "standstill_omniscience") or
				managers.player:current_state() == "civilian" or
				self:_interacting() or
				self._ext_movement:has_carry_restriction() or
				self:is_deploying() or
				self:_changing_weapon() or
				self:_is_throwing_projectile() or
				self:_is_meleeing() or
				self:_on_zipline() or
				self._moving or
				self:running() or
				self:_is_reloading() or
				self:in_air() or
				self:in_steelsight() or
				self:is_equipping() or
				self:shooting() or
				not managers.groupai:state():whisper_mode() or
				not tweak_data.player.omniscience

		if action_forbidden then
			if self._state_data.omniscience_t then
				managers.gameinfo:event("buff", "deactivate", "sixth_sense")
				self._state_data.omniscience_t = nil
			end
			return
		end

		if not self._state_data.omniscience_t then
			managers.gameinfo:event("buff", "activate", "sixth_sense")
			managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.start_t })
			managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = nil })
		end

		self._state_data.omniscience_t = self._state_data.omniscience_t or t + tweak_data.player.omniscience.start_t
		if t >= self._state_data.omniscience_t then
			local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, managers.slot:get_mask("trip_mine_targets"))
			managers.gameinfo:event("buff", "set_stack_count", "sixth_sense", { stack_count = #sensed_targets })

			for _, unit in ipairs(sensed_targets) do
				if alive(unit) and not unit:base():char_tweak().is_escort then
					self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}
					if not self._state_data.omniscience_units_detected[unit:key()] or t >= self._state_data.omniscience_units_detected[unit:key()] then
						self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t
						managers.game_play_central:auto_highlight_enemy(unit, true)
					end
				else
				end
			end
			self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
			managers.gameinfo:event("buff", "set_duration", "sixth_sense", { duration = tweak_data.player.omniscience.interval_t })
		end
	end

	--local PREV_DMG_STACK = {}	--Prevent event flooding
	function PlayerStandard:_check_damage_stack_skill(t, category)
		local stack = self._state_data.stacking_dmg_mul[category]

		if stack then
			local buff_id = category .. "_stack_damage"

			--if not PREV_DMG_STACK[category] or (PREV_DMG_STACK[category][1] ~= stack[1] or PREV_DMG_STACK[category][2] ~= stack[2]) then
			--	PREV_DMG_STACK[category] = { stack[1], stack[2] }

			if stack[2] > 0 then
				local value = managers.player:upgrade_value(category, "stacking_hit_damage_multiplier", 0)
				managers.gameinfo:event("timed_buff", "activate", buff_id, { expire_t = stack[1] })
				managers.gameinfo:event("buff", "set_stack_count", buff_id, { stack_count = stack[2] })
				managers.gameinfo:event("buff", "set_value", buff_id, { value = 1 + stack[2] * value })
			else
				managers.gameinfo:event("buff", "deactivate", buff_id)
			end
			--end
		end
	end

end

if string.lower(RequiredScript) == "lib/units/beings/player/states/playermaskoff" then
	local _start_action_state_standard_original = PlayerMaskOff._start_action_state_standard
	local _interupt_action_start_standard_original = PlayerMaskOff._interupt_action_start_standard

	function PlayerMaskOff:_start_action_state_standard(...)
		local timer = tweak_data.player.put_on_mask_time or 2
		managers.gameinfo:event("player_action", "activate", "interact", { duration = timer })
		managers.gameinfo:event("player_action", "set_data", "interact", { interact_id = "mask_up" })

		return _start_action_state_standard_original(self, ...)
	end

	function PlayerMaskOff:_interupt_action_start_standard(t, input, complete, ...)
		if self._start_standard_expire_t then
			managers.gameinfo:event("player_action", "deactivate", "interact")
		end

		return _interupt_action_start_standard_original(self, t, input, complete, ...)
	end
end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then

	local add_damage_to_hot_original = PlayerDamage.add_damage_to_hot
	local set_health_original = PlayerDamage.set_health
	local _upd_health_regen_original = PlayerDamage._upd_health_regen
	local _start_regen_on_the_side_original = PlayerDamage._start_regen_on_the_side
	local _regenerate_armor_original = PlayerDamage._regenerate_armor
	local _update_armor_grinding_original = PlayerDamage._update_armor_grinding
	local _on_damage_armor_grinding_original = PlayerDamage._on_damage_armor_grinding
	local change_regenerate_speed_original = PlayerDamage.change_regenerate_speed
	local _on_damage_event_original = PlayerDamage._on_damage_event
	local set_armor_original = PlayerDamage.set_armor
	local _check_bleed_out_original = PlayerDamage._check_bleed_out
	local _update_delayed_damage_original = PlayerDamage._update_delayed_damage
	local delay_damage_original = PlayerDamage.delay_damage
	local clear_delayed_damage_original = PlayerDamage.clear_delayed_damage

	local HEALTH_RATIO_BONUSES = {
		melee_damage_health_ratio_multiplier 			= { category = "melee", buff_id = "berserker" },
		damage_health_ratio_multiplier 					= { category = "damage", buff_id = "berserker_aced" },
		armor_regen_damage_health_ratio_multiplier 		= { category = "armor_regen", buff_id = "yakuza_recovery" },
		movement_speed_damage_health_ratio_multiplier 	= { category = "movement_speed", buff_id = "yakuza_speed" },
	}

	local PASSIVE_HEALTH_REGEN = {
		muscle_regen 		= { category = "player", 	upgrade = "passive_health_regen" },
		crew_health_regen 	= { category = "team", 		upgrade = "crew_health_regen"	 },
		hostage_taker 		= { category = "player", 	upgrade = "hostage_health_regen_addend", 	check_clbk = function() return managers.player._HAS_HOSTAGES end },
	}

	local LAST_HEALTH_RATIO = 0
	local LAST_ARMOR_REGEN_BUFF_RESET = 0
	local LAST_CHECK_T = 0
	local ARMOR_GRIND_ACTIVE = false

	function PlayerDamage:add_damage_to_hot(...)
		local num_old_stacks = #self._damage_to_hot_stack or 0

		add_damage_to_hot_original(self, ...)

		local num_new_stacks = #self._damage_to_hot_stack or 0

		if num_new_stacks > num_old_stacks then
			local stack_duration = ((self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)) * (self._doh_data.tick_time or 1)
			managers.gameinfo:event("timed_buff", "activate", "grinder_debuff", { duration = tweak_data.upgrades.damage_to_hot_data.stacking_cooldown })
			managers.gameinfo:event("timed_stack_buff", "add_stack", "grinder", { duration = stack_duration })
		end
	end

	function PlayerDamage:set_health(...)
		set_health_original(self, ...)

		local health_ratio = self:health_ratio()

		if health_ratio ~= LAST_HEALTH_RATIO then
			LAST_HEALTH_RATIO = health_ratio

			for upgrade, data in pairs(HEALTH_RATIO_BONUSES) do
				if managers.player:has_category_upgrade("player", upgrade) then
					local bonus_ratio = managers.player:get_damage_health_ratio(health_ratio, data.category)
					if bonus_ratio > 0 then
						managers.gameinfo:event("buff", "activate", data.buff_id)
						managers.gameinfo:event("buff", "set_value", data.buff_id, { value = bonus_ratio })
					else
						managers.gameinfo:event("buff", "deactivate", data.buff_id)
					end
				end
			end

			if managers.player:has_category_upgrade("player", "passive_damage_reduction") then
				local threshold = managers.player:upgrade_value("player", "passive_damage_reduction")
				local value = managers.player:team_upgrade_value("damage_dampener", "team_damage_reduction")
				if health_ratio < threshold then
					value = 2 * value - 1
				end
				managers.gameinfo:event("buff", "set_value", "crew_chief_1", { value = value })
			end
		end

		for buff_id, data in pairs(PASSIVE_HEALTH_REGEN) do
			if not self:full_health() and managers.player:has_category_upgrade(data.category, data.upgrade) and (not data.check_clbk or data.check_clbk()) then
				managers.gameinfo:event("buff", "activate", buff_id)
				managers.gameinfo:event("buff", "set_value", buff_id, { value = managers.player:upgrade_value(data.category, data.upgrade, 0) })
			else
				managers.gameinfo:event("buff", "deactivate", buff_id)
			end
		end
	end

	function PlayerDamage:_upd_health_regen(t, ...)
		local old_timer = self._health_regen_update_timer

		local result = _upd_health_regen_original(self, t, ...)

		if self._health_regen_update_timer then
			if self._health_regen_update_timer > (old_timer or 0) --[[and not self:full_health()]] then
				for buff_id, data in pairs(PASSIVE_HEALTH_REGEN) do
					managers.gameinfo:event("buff", "set_duration", buff_id, { duration = self._health_regen_update_timer })
				end
			end
		end
	end

	function PlayerDamage:_start_regen_on_the_side(time, ...)
		if not self._regen_on_the_side and time > 0 then
			managers.gameinfo:event("timed_buff", "activate", "tooth_and_claw", { duration = time })
		end

		return _start_regen_on_the_side_original(self, time, ...)
	end

	function PlayerDamage:_update_armor_grinding(t, ...)
		_update_armor_grinding_original(self, t, ...)

		if self._armor_grinding.elapsed == 0 and ARMOR_GRIND_ACTIVE then
			managers.gameinfo:event("player_action", "set_duration", "anarchist_armor_regeneration", { duration = self._armor_grinding.target_tick })
		end
	end

	function PlayerDamage:_on_damage_armor_grinding(...)
		if not ARMOR_GRIND_ACTIVE then
			local t = Application:time() - (self._armor_grinding.elapsed or 0)
			managers.gameinfo:event("player_action", "activate", "anarchist_armor_regeneration")
			managers.gameinfo:event("player_action", "set_duration", "anarchist_armor_regeneration", { t = t, duration = self._armor_grinding.target_tick })
			ARMOR_GRIND_ACTIVE = true
		end
		return _on_damage_armor_grinding_original(self, ...)
	end

	function PlayerDamage:change_regenerate_speed(...)
		change_regenerate_speed_original(self, ...)
		self:_check_armor_regen_timer()
	end

	function PlayerDamage:_on_damage_event(...)
		_on_damage_event_original(self, ...)
		self:_check_armor_regen_timer(true)
	end

	function PlayerDamage:set_armor(armor, ...)
		if armor >= self:_max_armor() then
			ARMOR_GRIND_ACTIVE = false
			managers.gameinfo:event("player_action", "deactivate", "anarchist_armor_regeneration")
			managers.gameinfo:event("player_action", "deactivate", "standard_armor_regeneration")
		elseif self._armor_grinding then
			if not ARMOR_GRIND_ACTIVE then
				ARMOR_GRIND_ACTIVE = true
				local t = Application:time()
				local t_start = t - self._armor_grinding.elapsed
				local expire_t = t_start + self._armor_grinding.target_tick
				managers.gameinfo:event("player_action", "activate", "anarchist_armor_regeneration")
				managers.gameinfo:event("player_action", "set_value", "anarchist_armor_regeneration", { value = self._armor_grinding.armor_value })
				managers.gameinfo:event("player_action", "set_duration", "anarchist_armor_regeneration", { t = t_start, expire_t = expire_t })
			end
		end

		return set_armor_original(self, armor, ...)
	end

	function PlayerDamage:_check_bleed_out(...)
		local last_uppers = self._uppers_elapsed or 0

		local result = _check_bleed_out_original(self, ...)

		if (self._uppers_elapsed or 0) > last_uppers then
			managers.gameinfo:event("timed_buff", "activate", "uppers_debuff", { duration = self._UPPERS_COOLDOWN })
		end
	end

	local REGEN_EXPIRE_T = 0
	function PlayerDamage:_check_armor_regen_timer(reset)
		if not self._armor_grinding and not self:is_downed() and self._regenerate_timer and self:get_real_armor() < self:_max_armor() then
			local t = managers.player:player_timer():time()
			local armor_regen_delay = self._regenerate_timer / (self._regenerate_speed or 1)
			local suppression_delay = 0

			if self._supperssion_data.decay_start_t and self._supperssion_data.value == tweak_data.player.suppression.max_value then
				suppression_delay = self._supperssion_data.decay_start_t - t
			end

			local expire_t = t + armor_regen_delay + suppression_delay

			if expire_t ~= REGEN_EXPIRE_T then
				REGEN_EXPIRE_T = expire_t
				managers.gameinfo:event("player_action", "activate", "standard_armor_regeneration")
				managers.gameinfo:event("player_action", reset and "set_duration" or "set_expire", "standard_armor_regeneration", { duration = armor_regen_delay + suppression_delay })
			end
		end
	end

	function PlayerDamage:_custom_on_enter_bleedout_clbk()
		if self:is_downed() then
			ARMOR_GRIND_ACTIVE = false
			managers.gameinfo:event("player_action", "deactivate", "anarchist_armor_regeneration")
			managers.gameinfo:event("player_action", "deactivate", "standard_armor_regeneration")

			for buff_id, data in pairs(PASSIVE_HEALTH_REGEN) do
				if not data.skip_activation then
					managers.gameinfo:event("buff", "deactivate", buff_id)
				end
			end

			managers.gameinfo:event("buff", "deactivate", "delayed_damage")
		end
	end

	function PlayerDamage:_update_delayed_damage(t, ...)
		local result = _update_delayed_damage_original(self, t, ...)

		if self._delayed_damage.next_tick then
			managers.gameinfo:event("buff", "set_value", "delayed_damage", { value = math.round((self:remaining_delayed_damage()) * 10) })
		end

		return result
	end

	local DELAYED_DAMAGE_DURATION = math.round(1 / (tweak_data.upgrades.values.player.damage_control_passive[1][2] * 0.01))
	function PlayerDamage:delay_damage(damage, seconds, ...)
		local has_calm = managers.player:has_category_upgrade("player", "damage_control_auto_shrug")
		if not self._delayed_damage.next_tick then
			if has_calm then
				managers.gameinfo:event("buff", "activate", "delayed_damage")
			end
			managers.gameinfo:event("buff", "activate", "delayed_damage_debuff")
		end

		local t = TimerManager:game():time()
		if has_calm then
			managers.gameinfo:event("buff", "set_duration", "delayed_damage", { t = t, duration = managers.player:upgrade_value("player", "damage_control_auto_shrug") })
		end

		managers.gameinfo:event("buff", "set_duration", "delayed_damage_debuff", { t = t, duration = DELAYED_DAMAGE_DURATION })
		managers.gameinfo:event("buff", "set_value", "delayed_damage", { value = math.round((self:remaining_delayed_damage() + damage) * 10) })

		return delay_damage_original(self, damage, seconds, ...)
	end

	function PlayerDamage:clear_delayed_damage(...)
		managers.gameinfo:event("buff", "deactivate", "delayed_damage_debuff")
		managers.gameinfo:event("buff", "deactivate", "delayed_damage")

		return clear_delayed_damage_original(self, ...)
	end
end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractionbloodthirstbase" then

	local bloodthirstbase_original = PlayerAction.BloodthirstBase.Function

	function PlayerAction.BloodthirstBase.Function(...)
		managers.gameinfo:event("buff", "activate", "bloodthirst_basic")
		managers.gameinfo:event("buff", "set_value", "bloodthirst_basic", { value = 1 })
		bloodthirstbase_original(...)
		managers.gameinfo:event("buff", "deactivate", "bloodthirst_basic")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractionexperthandling" then

	local experthandling_original = PlayerAction.ExpertHandling.Function

	function PlayerAction.ExpertHandling.Function(player_manager, accuracy_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "activate", "desperado")
		managers.gameinfo:event("buff", "set_duration", "desperado", { expire_t = max_time })
		experthandling_original(player_manager, accuracy_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "deactivate", "desperado")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractionshockandawe" then

	local shockandawe_original = PlayerAction.ShockAndAwe.Function

	function PlayerAction.ShockAndAwe.Function(player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, ...)
		local kill_count = 1

		local function on_enemy_killed(weapon_unit, variant)
			if alive(weapon_unit) then
				kill_count = kill_count + 1

				if kill_count >= target_enemies then
					local min_threshold = min_bullets + (weapon_unit:base():is_category("smg", "assault_rifle", "lmg") and player_manager:upgrade_value("player", "automatic_mag_increase", 0) or 0)
					local max_threshold = math.floor(min_threshold + math.log(min_reload_increase/max_reload_increase) / math.log(penalty))
					local ammo = weapon_unit:base():get_ammo_max_per_clip()
					local bonus = math.clamp(max_reload_increase * math.pow(penalty, ammo - min_threshold), min_reload_increase, max_reload_increase)
					managers.gameinfo:event("buff", "activate", "lock_n_load")
					managers.gameinfo:event("buff", "set_value", "lock_n_load", { value = bonus })
					managers.player:unregister_message(Message.OnEnemyKilled, "lock_n_load_buff_listener")
				end
			end
		end

		--managers.gameinfo:event("buff", "activate", "shock_and_awe")
		--managers.gameinfo:event("buff", "set_stack_count", "shock_and_awe" { stack_count = target_enemies - kill_count })
		managers.player:register_message(Message.OnEnemyKilled, "lock_n_load_buff_listener", on_enemy_killed)
		shockandawe_original(player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, ...)
		managers.gameinfo:event("buff", "deactivate", "lock_n_load")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractiondireneed" then

	local direneed_original = PlayerAction.DireNeed.Function

	function PlayerAction.DireNeed.Function(...)
		managers.gameinfo:event("buff", "activate", "dire_need")
		direneed_original(...)
		managers.gameinfo:event("buff", "deactivate", "dire_need")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractionunseenstrike" then

	local unseenstrike_original = PlayerAction.UnseenStrike.Function

	function PlayerAction.UnseenStrike.Function(player_manager, min_time, ...)
		local function on_damage_taken()
			managers.gameinfo:event("timed_buff", "activate", "unseen_strike_debuff", { duration = min_time })
		end

		player_manager:register_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener", on_damage_taken)
		unseenstrike_original(player_manager, min_time, ...)
		player_manager:unregister_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractionammoefficiency" then

	local ammo_efficieny_original = PlayerAction.AmmoEfficiency.Function

	function PlayerAction.AmmoEfficiency.Function(player_manager, target_headshots, bullet_refund, target_time, ...)
		local headshots = 1

		local function on_headshot()
			headshots = headshots + 1
			if headshots < target_headshots then
				managers.gameinfo:event("buff", "set_stack_count", "ammo_efficiency", { stack_count = target_headshots - headshots })
			end
		end

		--local duration = math.max(target_time - Application:time(), 0)
		--player_manager:register_message(Message.OnHeadShot, "ammo_efficiency_buff_listener", on_headshot)
		--managers.gameinfo:event("buff", "activate", "ammo_efficiency")
		--managers.gameinfo:event("buff", "set_duration", "ammo_efficiency", { duration = duration })

		ammo_efficieny_original(player_manager, target_headshots, bullet_refund, target_time, ...)

		player_manager:unregister_message(Message.OnHeadShot, "ammo_efficiency_buff_listener")
		managers.gameinfo:event("buff", "deactivate", "ammo_efficiency")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractiontriggerhappy" then

	local trigger_happy_original = PlayerAction.TriggerHappy.Function

	function PlayerAction.TriggerHappy.Function(player_manager, damage_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "activate", "trigger_happy")
		managers.gameinfo:event("buff", "set_duration", "trigger_happy", { expire_t = max_time })
		trigger_happy_original(player_manager, damage_bonus, max_stacks, max_time, ...)
		managers.gameinfo:event("buff", "deactivate", "trigger_happy")
	end

end

if string.lower(RequiredScript) == "lib/player_actions/skills/playeractiontagteam" then

	local tag_team_original = PlayerAction.TagTeam.Function
	local tag_team_tagged_original = PlayerAction.TagTeamTagged.Function

	local function GetUnitName(unit)
		local name = "N/A"
		if unit:in_slot(3) or unit:in_slot(5) then	-- Human criminal (mask off/on)
			local peer = managers.network:session() and managers.network:session():peer_by_unit(unit)
			name = peer and peer:name()
		elseif unit:in_slot(16) or unit:in_slot(24) then	-- Bot (mask on/off)/Joker
			local key = tostring(unit:key())
			local tweak_id
			if managers.gameinfo:get_minions(key) then	-- Joker
				tweak_id = unit:base()._tweak_table
			else -- Bot
				tweak_id = CriminalsManager.convert_new_to_old_character_workname(managers.criminals:character_name_by_unit(unit))
			end
			name = WolfHUD:getCharacterName(tweak_id, false)
		end
		return name
	end

	function PlayerAction.TagTeam.Function(tagged, owner, ...)
		local on_dmg_listener_key = string.format("gameinfo_tag_team_on_damage_listener_%s", tostring(owner:key()))
		local tagged_name = GetUnitName(tagged)
		local base_values = managers.player:upgrade_value("player", "tag_team_base")
		local duration = base_values.duration or 0
		managers.gameinfo:event("timed_buff", "activate", "tag_team", { duration = duration })
		managers.gameinfo:event("buff", "set_value", "tag_team", { value = tagged_name })

		CopDamage.register_listener(on_dmg_listener_key, {"on_damage"}, function(damage_info)
			local was_killed = damage_info.result.type == "death"
			local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged

			if was_killed and valid_player then
				managers.gameinfo:event("timed_buff", "change_expire", "tag_team", { difference = base_values.kill_extension })
			end
		end)
		tag_team_original(tagged, owner, ...)
		CopDamage.unregister_listener(on_dmg_listener_key)
	end

	function PlayerAction.TagTeamTagged.Function(tagged, owner, ...)
		local on_dmg_listener_key = string.format("gameinfo_tag_team_tagged_on_damage_listener_%s", tostring(owner:key()))

		if tagged == managers.player:local_player() then
			local tagged_name = GetUnitName(owner)
			local base_values = managers.player:upgrade_value("player", "tag_team_base")
			local duration = base_values.duration or 0
			managers.gameinfo:event("timed_buff", "activate", "tag_team", { duration = duration })
			managers.gameinfo:event("buff", "set_value", "tag_team", { value = tagged_name })

			CopDamage.register_listener(on_dmg_listener_key, {"on_damage"}, function(damage_info)
				local was_killed = damage_info.result.type == "death"
				local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged

				if was_killed and valid_player then
					managers.gameinfo:event("timed_buff", "change_expire", "tag_team", { difference = base_values.kill_extension })
				end
			end)
		end

		tag_team_tagged_original(tagged, owner, ...)
		CopDamage.unregister_listener(on_dmg_listener_key)
	end

end

--[[
if string.lower(RequiredScript) == "lib/managers/objectinteractionmanager" then

	local init_original = ObjectInteractionManager.init
	local update_original = ObjectInteractionManager.update
	local add_unit_original = ObjectInteractionManager.add_unit
	local remove_unit_original = ObjectInteractionManager.remove_unit


	ObjectInteractionManager.TRIGGERS = {
		[136843] = {
			136844, 136845, 136846, 136847, --HB armory ammo shelves
			136859, 136860, 136864, 136865, 136866, 136867, 136868, 136869, 136870, --HB armory grenades
		},
		[151868] = { 151611 }, --GGC armory ammo shelf 1
		[151869] = {
			151612, --GGC armory ammo shelf 2
			151596, 151597, 151598, --GGC armory grenades
		},
		--[101835] = { 101470, 101472, 101473 },	--HB infirmary med boxes (not needed, triggers on interaction activation)
	}

	ObjectInteractionManager.INTERACTION_TRIGGERS = {
		requires_ecm_jammer_double = {
			[Vector3(-2217.05, 2415.52, -354.502)] = 136843,	--HB armory door 1
			[Vector3(1817.05, 3659.48, 45.4985)] = 136843,	--HB armory door 2
		},
		drill = {
			[Vector3(142, 3098, -197)] = 151868,	--GGC armory cage 1 alt 1
			[Vector3(-166, 3413, -197)] = 151869,	--GGC armory cage 2 alt 1
			[Vector3(3130, 1239, -195.5)] = 151868,	--GGC armory cage X alt 2	(may be reversed)
			[Vector3(3445, 1547, -195.5)] = 151869,	--GGC armory cage Y alt 2	(may be reversed)
		},
	}

	function ObjectInteractionManager:init(...)
		init_original(self, ...)

		self._queued_units = {}
		self._unit_triggers = {}
		self._trigger_blocks = {}

		GroupAIStateBase.register_listener_clbk("ObjectInteractionManager_cancel_pager_listener", "on_whisper_mode_change", callback(self, self, "_whisper_mode_change"))
	end

	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_check_queued_units(t)
	end

	function ObjectInteractionManager:add_unit(unit, ...)
		for pos, trigger_id in pairs(ObjectInteractionManager.INTERACTION_TRIGGERS[unit:interaction().tweak_data] or {}) do
			if mvector3.distance(unit:position(), pos) <= 10 then
				self:block_trigger(trigger_id, true)
				break
			end
		end

		table.insert(self._queued_units, unit)
		return add_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:remove_unit(unit, ...)
		for pos, trigger_id in pairs(ObjectInteractionManager.INTERACTION_TRIGGERS[unit:interaction().tweak_data] or {}) do
			if mvector3.distance(unit:position(), pos) <= 10 then
				self._trigger_blocks[trigger_id] = false
				break
			end
		end

		self:_check_remove_unit(unit)
		return remove_unit_original(self, unit, ...)
	end

	function ObjectInteractionManager:_check_queued_units(t)
		local level_id = managers.job:current_level_id()

		for i, unit in ipairs(self._queued_units) do
			if alive(unit) then
				local editor_id = unit:editor_id()
				local interaction_id = unit:interaction().tweak_data

				if false then --ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
					local data = ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id]
					local blocked

					for trigger_id, editor_ids in pairs(ObjectInteractionManager.TRIGGERS) do
						if table.contains(editor_ids, editor_id) then
							blocked = self._trigger_blocks[trigger_id]
							self._unit_triggers[trigger_id] = self._unit_triggers[trigger_id] or {}
							table.insert(self._unit_triggers[trigger_id], { unit = unit, class = data.class, offset = data.offset })
							break
						end
					end

					unit:base():set_equipment_active(data.class, not blocked, data.offset)
				end

				self._do_listener_callback("on_unit_added", unit)
			end
		end

		self._queued_units = {}
	end

	function ObjectInteractionManager:_check_remove_unit(unit)
		for i, queued_unit in ipairs(self._queued_units) do
			if queued_unit:key() == unit:key() then
				table.remove(self._queued_units, i)
				return
			end
		end

		local editor_id = unit:editor_id()
		local interaction_id = unit:interaction().tweak_data

		if false then --ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
			unit:base():set_equipment_active(ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id].class, false)
		end

		self._do_listener_callback("on_unit_removed", unit)
	end

	function ObjectInteractionManager:block_trigger(trigger_id, status)
		if ObjectInteractionManager.TRIGGERS[trigger_id] then
			--io.write("ObjectInteractionManager:block_trigger(" .. tostring(trigger_id) .. ", " .. tostring(status) .. ")\n")
			self._trigger_blocks[trigger_id] = status

			for id, data in ipairs(self._unit_triggers[trigger_id] or {}) do
				if alive(data.unit) then
					--io.write("Set active " .. tostring(data.unit:editor_id()) .. ": " .. tostring(not status) .. "\n")
					data.unit:base():set_equipment_active(data.class, not status, data.offset)
				end
			end
		end
	end

end

if string.lower(RequiredScript) == "lib/units/props/missiondoor" then

	local deactivate_original = MissionDoor.deactivate

	function MissionDoor:deactivate(...)
		managers.interaction:block_trigger(self._unit:editor_id(), false)
		return deactivate_original(self, ...)
	end

end
]]
