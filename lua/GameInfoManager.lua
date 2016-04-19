printf = function(...) 
	WolfHUD:print_log(string.format(...))
end

if string.lower(RequiredScript) == "lib/setups/gamesetup" then
	
	local init_managers_original = GameSetup.init_managers

	function GameSetup:init_managers(managers, ...)
		managers.gameinfo = managers.gameinfo or GameInfoManager:new()
		init_managers_original(self, managers, ...)
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
			update = function(timers, key, t, timer)
				if timers[key] then
					timers[key].t = t
					timers[key].timer = timer
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
			set_upgradable = function(timers, key, status)
				if timers[key] and timers[key].upgradable ~= status then
					timers[key].upgradable = status
					managers.gameinfo:_listener_callback("timer", "set_upgradable", key, timers[key])
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
			--[130320] = { },	--The Diamond outer time lock
			--[130395] = { },	--The Diamond inner time lock
			--[101457] = { },	--Big Bank time lock door #1
			--[104671] = { },	--Big Bank time lock door #2
			--[167575] = { },	--Golden Grin BFD timer
			--[135034] = { },	--Lab rats cloaker safe 1
			--[135076] = { },	--Lab rats cloaker safe 2
			--[135246] = { },	--Lab rats cloaker safe 3
			--[135247] = { },	--Lab rats cloaker safe 4
		}
	}

	GameInfoManager._INTERACTIONS = {
		INTERACTION_TO_CALLBACK = {
			corpse_alarm_pager =				"_pager_event",
			gen_pku_crowbar =					"_special_equipment_interaction_handler",
			pickup_keycard =					"_special_equipment_interaction_handler",
			pickup_hotel_room_keycard =			"_special_equipment_interaction_handler",
			gage_assignment =					"_special_equipment_interaction_handler",
			pickup_boards =						"_special_equipment_interaction_handler",
			stash_planks_pickup =				"_special_equipment_interaction_handler",
			muriatic_acid =						"_special_equipment_interaction_handler",
			hydrogen_chloride =					"_special_equipment_interaction_handler",
			caustic_soda =						"_special_equipment_interaction_handler",
			gen_pku_blow_torch =				"_special_equipment_interaction_handler",
			gen_pku_thermite = 					"_special_equipment_interaction_handler",
			gen_pku_thermite_paste = 			"_special_equipment_interaction_handler",
			hold_take_gas_can = 				"_special_equipment_interaction_handler",
			money_wrap_single_bundle = 			"_special_equipment_interaction_handler",
			money_wrap_single_bundle_active = 	"_special_equipment_interaction_handler",
			money_wrap_single_bundle_dyn = 		"_special_equipment_interaction_handler",
			cas_chips_pile = 					"_special_equipment_interaction_handler",
			diamond_pickup = 					"_special_equipment_interaction_handler",
			diamond_pickup_pal = 				"_special_equipment_interaction_handler",
			safe_loot_pickup = 					"_special_equipment_interaction_handler",
			firstaid_box =						"_deployable_interaction_handler",
			ammo_bag =							"_deployable_interaction_handler",
			doctor_bag =						"_deployable_interaction_handler",
			bodybags_bag =						"_deployable_interaction_handler",
			grenade_crate =						"_deployable_interaction_handler",
		},
		INTERACTION_TO_CARRY = {
			weapon_case =				"weapon",
			samurai_armor =			"samurai_suit",
			gen_pku_warhead_box =	"warhead",
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
		CONDITIONAL_IGNORE_IDS = {
			ff3_vault = function(wall_id)
				if managers.job:current_level_id() == "framing_frame_3" then
					for _, unit in pairs(World:find_units_quick("all", 1)) do
						if unit:editor_id() == wall_id then
							return true
						end
					end
				end
			end,

			--FF3 lounge vault
			[100548] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100549] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100550] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100551] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100552] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100553] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100554] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			[100555] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(100448) end,
			--FF3 bedroom vault
			[100556] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100557] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100558] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100559] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100560] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100561] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100562] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			[100563] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101431) end,
			--FF3 upstairs vault
			[100564] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100566] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100567] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100568] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100569] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100570] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100571] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
			[100572] = function() return GameInfoManager._INTERACTIONS.CONDITIONAL_IGNORE_IDS.ff3_vault(101423) end,
		},
		IGNORE_IDS = {
			watchdogs_2 = {	--Watchdogs day 2 (8x coke)
				[100054] = true, [100058] = true, [100426] = true, [100427] = true, [100428] = true, [100429] = true, [100491] = true, [100492] = true, [100494] = true, [100495] = true,
			},
			family = {	--Diamond store (1x money)
				[100899] = true,
			},	--Hotline Miami day 1 (1x money)
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
			ukrainian_job = {	--Ukrainian Job (1x money)
				[101514] = true,
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
		},
	}
	GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2_day = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.watchdogs_2)
	GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1_night = table.deep_map_copy(GameInfoManager._INTERACTIONS.IGNORE_IDS.welcome_to_the_jungle_1)
	
	GameInfoManager._EQUIPMENT = {
		AMOUNT_OFFSETS = {
			--interaction_id or editor_id
			firstaid_box = -1,	--GGC drill asset, HB infirmary
		},
		AGGREAGATE_ITEMS = {
			[136859] = "hb_armory_grenade",
			[136870] = "hb_armory_grenade",
			[136869] = "hb_armory_grenade",
			[136864] = "hb_armory_grenade",
			[136866] = "hb_armory_grenade",
			[136860] = "hb_armory_grenade",
			[136867] = "hb_armory_grenade",
			[136865] = "hb_armory_grenade",
			[136868] = "hb_armory_grenade",
			[136846] = "hb_armory_ammo",
			[136844] = "hb_armory_ammo",
			[136845] = "hb_armory_ammo",
			[136847] = "hb_armory_ammo",
			[101470] = "hb_infirmary_cabinet",
			[101472] = "hb_infirmary_cabinet",
			[101473] = "hb_infirmary_cabinet",
			[151596] = "ggc_armory_grenade",
			[151597] = "ggc_armory_grenade",
			[151598] = "ggc_armory_grenade",
			[151611] = "ggc_armory_ammo",
			[151612] = "ggc_armory_ammo",
		},
	}
	
	function GameInfoManager:init()
		self._listeners = {}
		
		self._timers = {}
		self._units = {}
		self._unit_count = {}
		self._minions = {}
		self._turrets = {}
		self._pagers = {}
		self._loot = {}
		self._special_equipment = {}
		self._ecms = {}
		self._deployables = {}
		self._sentries = {}
	end

	function GameInfoManager:event(source, ...)
		local target = "_" .. source .. "_event"
		
		if self[target] then
			self[target](self, ...)
		else
			printf("Error: No event handler for %s\n", target)
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
			return self._unit_count[id]
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
	
	function GameInfoManager:get_deployables(key)
		if key then
			return self._deployables[key]
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

	function GameInfoManager:_unit_event(event, key, unit, unit_type)
		if event == "add" then
			if not self._units[key] then
				self._units[key] = { unit = unit, type = unit_type }
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
	
	function GameInfoManager:_minion_event(event, key, ...)
		if event == "add" then
			local unit, owner, health_multiplier, damage_multiplier = ...
			
			if not self._minions[key] then
				self._minions[key] = { unit = unit, kills = 0 }
				self:_listener_callback("minion", "add", key, self._minions[key])
				self:_unit_count_event("change", "minion", 1)
			end
			
			if owner and self._minions[key].owner ~= owner then
				self._minions[key].owner = owner
				self:_listener_callback("minion", "set_owner", key, self._minions[key])
			end
			
			if health_multiplier and self._minions[key].health_multiplier ~= health_multiplier then
				self._minions[key].health_multiplier = health_multiplier
				self:_listener_callback("minion", "set_health_multiplier", key, self._minions[key])
			end
			
			if damage_multiplier and self._minions[key].damage_multiplier ~= damage_multiplier then
				self._minions[key].damage_multiplier = damage_multiplier
				self:_listener_callback("minion", "set_damage_multiplier", key, self._minions[key])
			end
		elseif self._minions[key] then
			if event == "remove" then
				self:_listener_callback("minion", "remove", key, self._minions[key])
				self:_unit_count_event("change", "minion", -1)
				self._minions[key] = nil
			elseif event == "set_health" then
				local health = ...
				self._minions[key].health = health
				self:_listener_callback("minion", "set_health", key, self._minions[key])
			elseif event == "increment_kills" then
				self._minions[key].kills = self._minions[key].kills + 1
				self:_listener_callback("minion", "set_kills", key, self._minions[key])
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
	
	function GameInfoManager:_interactive_unit_event(event, key, unit)
		local lookup = GameInfoManager._INTERACTIONS
		local level_id = managers.job:current_level_id()
		local editor_id = unit:editor_id()
		
		if lookup.IGNORE_IDS[level_id] and lookup.IGNORE_IDS[level_id][editor_id] then
			return
		end
		
		if lookup.CONDITIONAL_IGNORE_IDS[editor_id] then
			if lookup.CONDITIONAL_IGNORE_IDS[editor_id]() then
				return
			end
		end
		
		local interact_id = unit:interaction().tweak_data
		local interact_clbk = lookup.INTERACTION_TO_CALLBACK[interact_id]
		
		if interact_clbk then
			self[interact_clbk](self, event, key, unit, interact_id)
		else
			local carry_id = unit:carry_data() and unit:carry_data():carry_id() or lookup.INTERACTION_TO_CARRY[interact_id] or (self._loot[key] and self._loot[key].carry_id)
			
			if carry_id then
				self:_loot_interaction_handler(event, key, unit, interact_id, carry_id)
			else
				self:_listener_callback("interactable_unit", event, key, unit, interact_id, carry_id)
			end
		end
	end
	
	function GameInfoManager:_pager_event(event, key, unit)
		if event == "add" then
			if not self._pagers[key] then
				self._pagers[key] = { unit = unit, active = true, answered = false }
				self:_listener_callback("pager", "add", key, self._pagers[key])
			end
		elseif event == "remove" then
			if self._pagers[key] and self._pagers[key].active then
				self._pagers[key].active = false
				self:_listener_callback("pager", "remove", key, self._pagers[key])
			end
		elseif event == "answered" then
			if self._pagers[key] and not self._pagers[key].answered then
				self._pagers[key].answered = true
				self:_listener_callback("pager", "answered", key, self._pagers[key])
			end
		end
	end
	
	function GameInfoManager:_special_equipment_interaction_handler(event, key, unit, interact_id)
		if event == "add" then
			if not self._special_equipment[key] then
				self._special_equipment[key] = { unit = unit, interact_id = interact_id }
				self:_listener_callback("special_equipment", "add", key, self._special_equipment[key])
			end
		elseif event == "remove" then
			if self._special_equipment[key] then
				self:_listener_callback("special_equipment", "remove", key, self._special_equipment[key])
				self._special_equipment[key] = nil
			end
		end
	end
	
	function GameInfoManager:_deployable_interaction_handler(event, key, unit, interact_id)
		if self._deployables[key] then
			local active = event == "add"
			self:_bag_deployable_event("set_active", key, active)
			
			local offset = GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[unit:editor_id()] or GameInfoManager._EQUIPMENT.AMOUNT_OFFSETS[interact_id]
			if active and offset then
				self:_bag_deployable_event("set_amount_offset", key, offset)
			end
		end
	end
	
	function GameInfoManager:_loot_interaction_handler(event, key, unit, interact_id, carry_id)
		if event == "add" then
			if not self._loot[key] then
				local composite_lookup = GameInfoManager._INTERACTIONS.COMPOSITE_LOOT_UNITS
				local count = composite_lookup[unit:editor_id()] or composite_lookup[interact_id] or 1
				local bagged = GameInfoManager._INTERACTIONS.BAGGED_IDS[interact_id] and true or false
			
				self._loot[key] = { unit = unit, carry_id = carry_id, count = count, bagged = bagged }
				self:_listener_callback("loot", "add", key, self._loot[key])
			end
		elseif event == "remove" then
			if self._loot[key] then
				self:_listener_callback("loot", "remove", key, self._loot[key])
				self._loot[key] = nil
			end
		end
	end
	
	function GameInfoManager:_ecm_event(event, key, ...)
		if event == "create" then
			if not self._ecms[key] then
				local unit = ...
				self._ecms[key] = { unit = unit }
				self:_listener_callback("ecm", "create", key, self._ecms[key])
			end
		elseif event == "destroy" then
			if self._ecms[key] then
				self:_listener_callback("ecm", "destroy", key, self._ecms[key])
				self._ecms[key] = nil
			end
		else
			if self._ecms[key] then
				if event == "set_jammer_active" then
					local active = ...
					if self._ecms[key].active ~= active then
						self._ecms[key].active = active
						self:_listener_callback("ecm", "set_jammer_active", key, self._ecms[key])
					end
				elseif event == "set_retrigger_active" then
					local active = ...
					if self._ecms[key].retrigger ~= active then
						self._ecms[key].retrigger = active
						self:_listener_callback("ecm", "set_retrigger_active", key, self._ecms[key])
					end
				elseif event == "update" then
					local battery, retrigger_t = ...
					
					if self._ecms[key].active then
						self._ecms[key].battery = battery
						self:_listener_callback("ecm", "set_battery", key, self._ecms[key])
					end
					
					if self._ecms[key].retrigger then
						self._ecms[key].retrigger_t = retrigger_t
						self:_listener_callback("ecm", "set_retrigger", key, self._ecms[key])
					end
				end
			end
		end
	end
--[[
	function GameInfoManager:_bag_deployable_event(event, key, ...)
		if event == "create" then
			if not self._deployables[key] then
				local unit, bag_type = ...
				self._deployables[key] = { unit = unit, type = bag_type }
				self:_listener_callback("bag_deployable", "create", key, self._deployables[key])
			end
		elseif self._deployables[key] then
			local aggregate_key = GameInfoManager._EQUIPMENT.AGGREAGATE_ITEMS[self._deployables[key].unit:editor_id()]
			
			if aggregate_key then
				local function update_aggregate_attribute(aggregate_key, attr)
					if not self._deployables[aggregate_key] then return end
				
					local total = 0
					for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
						if self._deployables[k].active then
							total = total + (self._deployables[k][attr] or 0)
						end
					end
					
					self._deployables[aggregate_key][attr] = total
					self:_listener_callback("bag_deployable", "set_" .. attr, aggregate_key, self._deployables[aggregate_key])
					--printf("UPDATE AGGREGATE %s: %s\n", tostring(attr), tostring(total))
				end
			
				if event == "destroy" then
					self._deployables[key] = nil
					
					if self._deployables[aggregate_key] then
						self._deployables[aggregate_key].aggregate_members[key] = nil
						
						if next(self._deployables[aggregate_key] and self._deployables[aggregate_key].aggregate_members or {}) == nil then
							self:_listener_callback("bag_deployable", "destroy", aggregate_key, self._deployables[aggregate_key])
							update_aggregate_attribute(aggregate_key, "amount")
							update_aggregate_attribute(aggregate_key, "max_amount")
							update_aggregate_attribute(aggregate_key, "amount_offset")
						end
					end
				elseif event == "set_active" then
					local active = ...
					self._deployables[key].aggregate = true
					self._deployables[key].active = active
					
					self._deployables[aggregate_key] = self._deployables[aggregate_key] or { 
						type = self._deployables[key].type, 
						position = self._deployables[key].unit:interaction():interact_position(),
						--position = GameInfoManager._EQUIPMENT.AGGREAGATE_ITEMS_POSITION[aggregate_key],
						aggregate_members = {},
					}
					self._deployables[aggregate_key].aggregate_members[key] = true
					
					local aggregate_active = false
					for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
						if self._deployables[k].active then
							aggregate_active = true
							break
						end
					end
				
					if self._deployables[aggregate_key].active ~= aggregate_active then
						self._deployables[aggregate_key].active = aggregate_active
						self:_listener_callback("bag_deployable", "set_active", aggregate_key, self._deployables[aggregate_key])
					end
					
					update_aggregate_attribute(aggregate_key, "amount")
					update_aggregate_attribute(aggregate_key, "max_amount")
					update_aggregate_attribute(aggregate_key, "amount_offset")
				elseif event == "set_owner" then
					local owner = ...
					self._deployables[key].owner = owner
					self._deployables[aggregate_key].owner = owner
					self:_listener_callback("bag_deployable", "set_owner", aggregate_key, self._deployables[aggregate_key])
				elseif event == "set_max_amount" then
					local max_amount = ...
					self._deployables[key].max_amount = max_amount
					update_aggregate_attribute(aggregate_key, "max_amount")
				elseif event == "set_amount_offset" then
					local amount_offset = ...
					self._deployables[key].amount_offset = amount_offset
					update_aggregate_attribute(aggregate_key, "amount_offset")
				elseif event == "set_amount" then
					local amount = ...
					self._deployables[key].amount = amount
					update_aggregate_attribute(aggregate_key, "amount")
				end
			else
				if event == "destroy" then
					self:_listener_callback("bag_deployable", "destroy", key, self._deployables[key])
					self._deployables[key] = nil
				elseif event == "set_active" then
					local active = ...
					if self._deployables[key].active ~= active then
						self._deployables[key].active = active
						self:_listener_callback("bag_deployable", "set_active", key, self._deployables[key])
						--printf("EDITOR ID: %s\n", tostring(self._deployables[key].unit:editor_id()))
					end
				elseif event == "set_owner" then
					local owner = ...
					self._deployables[key].owner = owner
					self:_listener_callback("bag_deployable", "set_owner", key, self._deployables[key])
				elseif event == "set_max_amount" then
					local max_amount = ...
					self._deployables[key].max_amount = max_amount
					self:_listener_callback("bag_deployable", "set_max_amount", key, self._deployables[key])
				elseif event == "set_amount_offset" then
					local amount_offset = ...
					self._deployables[key].amount_offset = amount_offset
					self:_listener_callback("bag_deployable", "set_amount_offset", key, self._deployables[key])
				elseif event == "set_amount" then
					local amount = ...
					self._deployables[key].amount = amount
					self:_listener_callback("bag_deployable", "set_amount", key, self._deployables[key])
				end
			end
		end
	end
]]	
	function GameInfoManager:_bag_deployable_event(event, key, ...)
		if event == "create" then
			if not self._deployables[key] then
				local unit, bag_type = ...
				self._deployables[key] = { unit = unit, type = bag_type }
				self:_listener_callback("bag_deployable", "create", key, self._deployables[key])
			end
		elseif self._deployables[key] then
			local function update_aggregate_attribute(aggregate_key, attr)
				if not self._deployables[aggregate_key] then return end
			
				local total = 0
				for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
					if self._deployables[k].active then
						total = total + (self._deployables[k][attr] or 0)
					end
				end
				
				self._deployables[aggregate_key][attr] = total
				self:_listener_callback("bag_deployable", "set_" .. attr, aggregate_key, self._deployables[aggregate_key])
				--printf("UPDATE AGGREGATE %s: %s\n", tostring(attr), tostring(total))
			end
			
			local aggregate_key = GameInfoManager._EQUIPMENT.AGGREAGATE_ITEMS[self._deployables[key].unit:editor_id()]
			
			if event == "destroy" then
				self:_listener_callback("bag_deployable", "destroy", key, self._deployables[key])
				self._deployables[key] = nil
				
				if aggregate_key and self._deployables[aggregate_key] then
					self._deployables[aggregate_key].aggregate_members[key] = nil
					
					if next(self._deployables[aggregate_key].aggregate_members or {}) == nil then
						self:_listener_callback("bag_deployable", "destroy", aggregate_key, self._deployables[aggregate_key])
						self._deployables[aggregate_key] = nil
						--update_aggregate_attribute(aggregate_key, "amount")
						--update_aggregate_attribute(aggregate_key, "max_amount")
						--update_aggregate_attribute(aggregate_key, "amount_offset")
					end
				end
			elseif event == "set_active" then
				local active = ...
				
				if aggregate_key then
					self._deployables[key].aggregate_key = aggregate_key
				end
				
				if self._deployables[key].active ~= active then
					self._deployables[key].active = active
					self:_listener_callback("bag_deployable", "set_active", key, self._deployables[key])
				end
				
				if aggregate_key then
					self._deployables[aggregate_key] = self._deployables[aggregate_key] or {
						type = self._deployables[key].type, 
						position = self._deployables[key].unit:interaction():interact_position(),
						aggregate_members = {},
					}
					self._deployables[aggregate_key].aggregate_members[key] = true
					--TODO: Update position for each member added?
					
					local aggregate_active = false
					for k, v in pairs(self._deployables[aggregate_key].aggregate_members or {}) do
						if self._deployables[k].active then
							aggregate_active = true
							break
						end
					end
			
					if self._deployables[aggregate_key].active ~= aggregate_active then
						self._deployables[aggregate_key].active = aggregate_active
						self:_listener_callback("bag_deployable", "set_active", aggregate_key, self._deployables[aggregate_key])
					end
					
					update_aggregate_attribute(aggregate_key, "amount")
					update_aggregate_attribute(aggregate_key, "max_amount")
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_owner" then
				local owner = ...
				self._deployables[key].owner = owner
				self:_listener_callback("bag_deployable", "set_owner", key, self._deployables[key])
					
				if aggregate_key then
					self._deployables[aggregate_key].owner = owner
					self:_listener_callback("bag_deployable", "set_owner", aggregate_key, self._deployables[aggregate_key])
				end
			elseif event == "set_max_amount" then
				local max_amount = ...
				self._deployables[key].max_amount = max_amount
				self:_listener_callback("bag_deployable", "set_max_amount", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "max_amount")
				end
			elseif event == "set_amount_offset" then
				local amount_offset = ...
				self._deployables[key].amount_offset = amount_offset
				self:_listener_callback("bag_deployable", "set_amount_offset", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount_offset")
				end
			elseif event == "set_amount" then
				local amount = ...
				self._deployables[key].amount = amount
				self:_listener_callback("bag_deployable", "set_amount", key, self._deployables[key])
				
				if aggregate_key then
					update_aggregate_attribute(aggregate_key, "amount")
				end
			end
		end
	end

	function GameInfoManager:_tape_loop_event(event, key, ...)
		if event == "start" then
			local unit, duration = ...
			self:_listener_callback("tape_loop", "start", key, unit, duration)
		elseif event == "stop" then
			self:_listener_callback("tape_loop", "stop", key)
		end
	end
	
	function GameInfoManager:_sentry_event(event, key, ...)
		--printf("GameInfoManager:_sentry_event(%s, %s)\n", event, key)
		
		if event == "create" then
			if not self._sentries[key] then
				local unit = ...
				self._sentries[key] = { unit = unit }
				self:_listener_callback("sentry", "create", key, self._sentries[key])
			end
		elseif self._sentries[key] then
			if event == "destroy" then
				self._sentries[key].active = false
				self:_listener_callback("sentry", "set_active", key, self._sentries[key])
				self:_listener_callback("sentry", "destroy", key, self._sentries[key])
				self._sentries[key] = nil
			elseif event == "set_active" then
				local active = ...
				if self._sentries[key].active ~= active then
					self._sentries[key].active = active
					self:_listener_callback("sentry", "set_active", key, self._sentries[key])
				end
			elseif event == "set_ammo_ratio" then
				local ammo_ratio = ...
				self._sentries[key].ammo_ratio = ammo_ratio
				self:_listener_callback("sentry", "set_ammo_ratio", key, self._sentries[key])
			elseif event == "set_health_ratio" then
				local health_ratio = ...
				self._sentries[key].health_ratio = health_ratio
				self:_listener_callback("sentry", "set_health_ratio", key, self._sentries[key])
			elseif event == "set_owner" then
				local owner = ...
				self._sentries[key].owner = owner
				self:_listener_callback("sentry", "set_owner", key, self._sentries[key])
			end
		end
	end
	
	function GameInfoManager:_whisper_mode_event(event, key, status)
		self:_listener_callback("whisper_mode", "change", key, status)
	end
	
	
	function GameInfoManager:register_listener(listener_id, source_type, event, clbk)
		self._listeners[source_type] = self._listeners[source_type] or {}
		self._listeners[source_type][event] = self._listeners[source_type][event] or {}
		self._listeners[source_type][event][listener_id] = clbk
	end

	function GameInfoManager:unregister_listener(listener_id, source_type, event)
		if self._listeners[source_type] then
			if self._listeners[source_type][event] then
				self._listeners[source_type][event][listener_id] = nil
			end
		end
	end

	function GameInfoManager:_listener_callback(source, event, key, ...)
		for listener_id, clbk in pairs(self._listeners[source] and self._listeners[source][event] or {}) do
			clbk(event, key, ...)
		end
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
		self:_do_timer_callback("update", t, self._timer)
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
		managers.gameinfo:event("timer", "create", self._info_key, unit, self, device_type)
		init_original(self, unit, ...)
	end
	
	function TimerGui:set_background_icons(...)
		local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
		local interact_ext = self._unit:interaction()
		local can_upgrade = false
		local pinfo = interact_ext and interact_ext.get_player_info_id and interact_ext:get_player_info_id()
		if skills and interact_ext and pinfo then
			for i, _ in pairs(interact_ext:split_info_id(pinfo)) do
				if not skills[i] then
					can_upgrade = true
					break
				end
			end
		end
		
		managers.gameinfo:event("timer", "set_upgradable", self._info_key, can_upgrade)
		
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
		managers.gameinfo:event("timer", "update", self._info_key, t, self._time_left)
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
		init_original(self, unit, ...)
	end

	function SecurityLockGui:update(unit, t, ...)
		update_original(self, unit, t, ...)
		managers.gameinfo:event("timer", "update", self._info_key, t, self._current_timer)
	end

	function SecurityLockGui:_start(...)
		managers.gameinfo:event("timer", "set_active", self._info_key, true)
		return _start_original(self, ...)
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
	
	local register_enemy_original = EnemyManager.register_enemy
	local on_enemy_died_original = EnemyManager.on_enemy_died
	local on_enemy_destroyed_original = EnemyManager.on_enemy_destroyed
	local register_civilian_original = EnemyManager.register_civilian
	local on_civilian_died_original = EnemyManager.on_civilian_died
	local on_civilian_destroyed_original = EnemyManager.on_civilian_destroyed
	
	function EnemyManager:register_enemy(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), unit, unit:base()._tweak_table)
		return register_enemy_original(self, unit, ...)
	end
	
	function EnemyManager:on_enemy_died(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_enemy_died_original(self, unit, ...)
	end
	
	function EnemyManager:on_enemy_destroyed(unit, ...)
		managers.gameinfo:event("unit", "remove", tostring(unit:key()))
		return on_enemy_destroyed_original(self, unit, ...)
	end
	
	function EnemyManager:register_civilian(unit, ...)
		managers.gameinfo:event("unit", "add", tostring(unit:key()), unit, unit:base()._tweak_table)
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
		if self._client_hostage_count_expire_t and t < self._client_hostage_count_expire_t then
			self:_client_hostage_count_cbk()
		end
		
		return update_original(self, t, ...)
	end
	
	function GroupAIStateBase:on_hostage_state(...)
		on_hostage_state_original(self, ...)
		self:_update_hostage_count()
	end
	
	function GroupAIStateBase:sync_hostage_headcount(...)
		sync_hostage_headcount_original(self, ...)
		
		if Network:is_server() then
			self:_update_hostage_count()
		else
			self._client_hostage_count_expire_t = self._t + 10
		end
	end
	
	function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		convert_hostage_to_criminal_original(self, unit, peer_unit, ...)
		
		if unit:brain()._logic_data.is_converted then
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
			local owner_base = peer_unit and peer_unit:base() or managers.player
			
			local health_mult = 1
			local damage_mult = 1
			local joker_level = (owner_base:upgrade_level("player", "convert_enemies_health_multiplier", 0) or 0)
			local partner_in_crime_level = (owner_base:upgrade_level("player", "passive_convert_enemies_health_multiplier", 0) or 0)
			if joker_level > 0 then
				health_mult = health_mult * tweak_data.upgrades.values.player.convert_enemies_health_multiplier[joker_level]
				damage_mult = damage_mult * tweak_data.upgrades.values.player.convert_enemies_damage_multiplier[joker_level]
			end
			if partner_in_crime_level > 0 then
				health_mult = health_mult * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[partner_in_crime_level]
			end
			
			managers.gameinfo:event("minion", "add", tostring(unit:key()), unit, peer_id, health_mult, damage_mult)
		end
	end
	
	function GroupAIStateBase:sync_converted_enemy(converted_enemy, ...)
		sync_converted_enemy_original(self, converted_enemy, ...)
		managers.gameinfo:event("minion", "add", tostring(converted_enemy:key()), converted_enemy)
	end
	
	function GroupAIStateBase:set_whisper_mode(enabled, ...)
		if self._whisper_mode ~= enabled then
			managers.gameinfo:event("whisper_mode", "change", nil, enabled)
		end
		set_whisper_mode_original(self, enabled, ...)
	end
	
	
	function GroupAIStateBase:_client_hostage_count_cbk()
		local police_hostages = 0
		local civilian_hostages = self._hostage_headcount
	
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if u_data and u_data.unit and u_data.unit.anim_data and u_data.unit:anim_data() then
				if u_data.unit:anim_data().surrender then
					police_hostages = police_hostages + 1
				end
			end
		end
		
		civilian_hostages = civilian_hostages - police_hostages
		managers.gameinfo:event("unit_count", "set", "civ_hostage", civilian_hostages)
		managers.gameinfo:event("unit_count", "set", "cop_hostage", police_hostages)
	end
	
	function GroupAIStateBase:_update_hostage_count()
		if Network:is_server() then
			managers.gameinfo:event("unit_count", "set", "civ_hostage", self._hostage_headcount - self._police_hostage_headcount)
			managers.gameinfo:event("unit_count", "set", "cop_hostage", self._police_hostage_headcount)
		else
			self:_client_hostage_count_cbk()
		end
	end
	
end

if string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then

	local mark_minion_original = UnitNetworkHandler.mark_minion
	local hostage_trade_original = UnitNetworkHandler.hostage_trade
	local unit_traded_original = UnitNetworkHandler.unit_traded
	local interaction_set_active_original = UnitNetworkHandler.interaction_set_active
	local alarm_pager_interaction_original = UnitNetworkHandler.alarm_pager_interaction
	
	function UnitNetworkHandler:mark_minion(unit, owner_id, joker_level, partner_in_crime_level, ...)
		mark_minion_original(self, unit, owner_id, joker_level, partner_in_crime_level, ...)
		
		if self._verify_character(unit) then
			local health_mult = 1
			local damage_mult = 1
			if joker_level > 0 then
				health_mult = health_mult * tweak_data.upgrades.values.player.convert_enemies_health_multiplier[joker_level]
				damage_mult = damage_mult * tweak_data.upgrades.values.player.convert_enemies_damage_multiplier[joker_level]
			end
			if partner_in_crime_level > 0 then
				health_mult = health_mult * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[partner_in_crime_level]
			end
			
			managers.gameinfo:event("minion", "add", tostring(unit:key()), unit, owner_id, health_mult, damage_mult)
		end
	end

	function UnitNetworkHandler:hostage_trade(unit, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end
		
		return hostage_trade_original(self, unit, ...)
	end
	
	function UnitNetworkHandler:unit_traded(unit, trader, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
			managers.gameinfo:event("minion", "remove", tostring(unit:key()))
		end
		
		return unit_traded_original(self, unit, trader, ...)
	end
	
	function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender, ...)
		if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_sender(sender) then
			if tweak_data == "corpse_alarm_pager" then
				if not alive(unit) then
					local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
					if not u_data then return end
					unit = u_data and u_data.unit
				end
				
				if not active then
					managers.gameinfo:event("pager", "remove", tostring(unit:key()))
				elseif not flash then
					managers.gameinfo:event("pager", "answered", tostring(unit:key()))
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
					managers.gameinfo:event("pager", "answered", tostring(unit_data.unit:key()))
				else
					managers.gameinfo:event("pager", "remove", tostring(unit_data.unit:key()))
				end
			end
		end
	
		return alarm_pager_interaction_original(self, u_id, tweak_table, status, sender, ...)
	end
	
end

if string.lower(RequiredScript) == "lib/units/enemies/cop/copdamage" then
	
	local _on_damage_received_original = CopDamage._on_damage_received
	local chk_killshot_original = CopDamage.chk_killshot
	
	function CopDamage:_on_damage_received(damage_info, ...)
		if self._unit:in_slot(16) then
			managers.gameinfo:event("minion", "set_health", tostring(self._unit:key()), self._health)
		end
		return _on_damage_received_original(self, damage_info, ...)
	end
	
	function CopDamage:chk_killshot(attacker_unit, ...)
		if alive(attacker_unit) and managers.gameinfo:get_minions(tostring(attacker_unit:key())) then
			managers.gameinfo:event("minion", "increment_kills", tostring(attacker_unit:key()))
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
	local interupt_action_interact_original = ObjectInteractionManager.interupt_action_interact
	
	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		self._queued_units_NEW = {}
	end
	
	function ObjectInteractionManager:update(t, ...)
		update_original(self, t, ...)
		self:_process_queued_units(t)
	end
	
	function ObjectInteractionManager:add_unit(unit, ...)
		self._queued_units_NEW[tostring(unit:key())] = unit
		return add_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:remove_unit(unit, ...)
		local key = tostring(unit:key())
		
		if self._queued_units_NEW[key] then
			self._queued_units_NEW[key] = nil
		else
			managers.gameinfo:event("interactive_unit", "remove", key, unit)
		end
	
		return remove_unit_original(self, unit, ...)
	end
	
	function ObjectInteractionManager:interact(...)
		if alive(self._active_unit) and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
			managers.gameinfo:event("pager", "answered", tostring(self._active_unit:key()))
		end
		
		return interact_original(self, ...)
	end
	
	function ObjectInteractionManager:interupt_action_interact(...)
		if alive(self._active_unit) and self._active_unit:interaction() and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
			managers.gameinfo:event("pager", "remove", tostring(self._active_unit:key()))
		end
		
		return interupt_action_interact_original(self, ...)
	end
	

	function ObjectInteractionManager:_process_queued_units(t)
		for key, unit in pairs(self._queued_units_NEW) do
			if alive(unit) then
				managers.gameinfo:event("interactive_unit", "add", key, unit)
			end
		end
	
		self._queued_units_NEW = {}
	end
	
end

if string.lower(RequiredScript) == "lib/units/equipment/ecm_jammer/ecmjammerbase" then

	local init_original = ECMJammerBase.init
	local set_active_original = ECMJammerBase.set_active
	local _set_feedback_active_original = ECMJammerBase._set_feedback_active
	local update_original = ECMJammerBase.update
	local _send_net_event_original = ECMJammerBase._send_net_event
	local sync_net_event_original = ECMJammerBase.sync_net_event
	local destroy_original = ECMJammerBase.destroy
	
	function ECMJammerBase:init(...)
		init_original(self, ...)
		managers.gameinfo:event("ecm", "create", tostring(self._unit:key()), self._unit)
	end
	
	function ECMJammerBase:set_active(active, ...)
		managers.gameinfo:event("ecm", "set_jammer_active", tostring(self._unit:key()), active)
		return set_active_original(self, active, ...)
	end
	
	function ECMJammerBase:_set_feedback_active(state, ...)
		if not state then
			local peer_id = managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id()
			if peer_id and (peer_id == self._owner_id) and managers.player:has_category_upgrade("ecm_jammer", "can_retrigger") then
				self._feedback_recharge_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), true)
			end
		end
	
		return _set_feedback_active_original(self, state, ...)
	end
	
	function ECMJammerBase:update(unit, t, dt, ...)
		update_original(self, unit, t, dt, ...)
		
		if self._chk_feedback_retrigger_t then
			self._feedback_recharge_t = self._chk_feedback_retrigger_t
		elseif self._feedback_recharge_t then
			self._feedback_recharge_t = self._feedback_recharge_t - dt
		end
			
		if self._feedback_recharge_t or self._jammer_active then
			managers.gameinfo:event("ecm", "update", tostring(self._unit:key()), self._battery_life or 0, self._feedback_recharge_t or 0)
		end
	end
	
	function ECMJammerBase:_send_net_event(event_id, ...)
		if event_id == self._NET_EVENTS.feedback_restart then
			self._feedback_recharge_t = nil
			managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		end
		
		return _send_net_event_original(self, event_id, ...)
	end
	
	function ECMJammerBase:sync_net_event(event_id, ...)
		if event_id == self._NET_EVENTS.feedback_restart then
			self._feedback_recharge_t = nil
			managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		end
		
		return sync_net_event_original(self, event_id, ...)
	end
	
	function ECMJammerBase:destroy(...)
		managers.gameinfo:event("ecm", "set_jammer_active", tostring(self._unit:key()), false)
		managers.gameinfo:event("ecm", "set_retrigger_active", tostring(self._unit:key()), false)
		managers.gameinfo:event("ecm", "destroy", tostring(self._unit:key()))
		destroy_original(self, ...)
	end
	
end

if string.lower(RequiredScript) == "lib/units/equipment/doctor_bag/doctorbagbase" then

	local spawn_original = DoctorBagBase.spawn
	local init_original = DoctorBagBase.init
	local sync_setup_original = DoctorBagBase.sync_setup
	local _set_visual_stage_original = DoctorBagBase._set_visual_stage
	local destroy_original = DoctorBagBase.destroy
	
	function DoctorBagBase.spawn(pos, rot, amount_upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, amount_upgrade_lvl, peer_id, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "doc_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function DoctorBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "doc_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_amount)
	end
	
	function DoctorBagBase:sync_setup(amount_upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, amount_upgrade_lvl, peer_id, ...)
	end
	
	function DoctorBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function DoctorBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
end

if string.lower(RequiredScript) == "lib/units/equipment/ammo_bag/ammobagbase" then

	local spawn_original = AmmoBagBase.spawn
	local init_original = AmmoBagBase.init
	local sync_setup_original = AmmoBagBase.sync_setup
	local _set_visual_stage_original = AmmoBagBase._set_visual_stage
	local destroy_original = AmmoBagBase.destroy
	
	function AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, peer_id, ...)
		local unit = spawn_original(pos, rot, ammo_upgrade_lvl, peer_id, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "ammo_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function AmmoBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "ammo_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_ammo_amount * 100)
	end
	
	function AmmoBagBase:sync_setup(ammo_upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, ammo_upgrade_lvl, peer_id, ...)
	end
	
	function AmmoBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._ammo_amount * 100)
		return _set_visual_stage_original(self, ...)
	end
	
	function AmmoBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
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
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "body_bag")
		managers.gameinfo:event("bag_deployable", "set_owner", key, peer_id)
		return unit
	end
	
	function BodyBagsBagBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "body_bag")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_bodybag_amount)
	end
	
	function BodyBagsBagBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("bag_deployable", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end
	
	function BodyBagsBagBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._bodybag_amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function BodyBagsBagBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
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
		managers.gameinfo:event("bag_deployable", "create", key, unit, "grenade_crate")
		init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_grenade_amount)
	end
	
	function GrenadeCrateBase:_set_visual_stage(...)
		managers.gameinfo:event("bag_deployable", "set_amount", tostring(self._unit:key()), self._grenade_amount)
		return _set_visual_stage_original(self, ...)
	end
	
	function GrenadeCrateBase:destroy(...)
		managers.gameinfo:event("bag_deployable", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
	function CustomGrenadeCrateBase:init(unit, ...)
		local key = tostring(unit:key())
		managers.gameinfo:event("bag_deployable", "create", key, unit, "grenade_crate", true)
		custom_init_original(self, unit, ...)
		managers.gameinfo:event("bag_deployable", "set_max_amount", key, self._max_grenade_amount)
	end
	
end

if string.lower(RequiredScript) == "lib/units/props/securitycamera" then

	local _start_tape_loop_original = SecurityCamera._start_tape_loop
	local _deactivate_tape_loop_original = SecurityCamera._deactivate_tape_loop
	
	function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
		managers.gameinfo:event("tape_loop", "start", tostring(self._unit:key()), self._unit, tape_loop_t + 6)
		return _start_tape_loop_original(self, tape_loop_t, ...)
	end

	function SecurityCamera:_deactivate_tape_loop(...)
		managers.gameinfo:event("tape_loop", "stop", tostring(self._unit:key()))
		return _deactivate_tape_loop_original(self, ...)
	end
	
end

if string.lower(RequiredScript) == "lib/units/equipment/sentry_gun/sentrygunbase" then

	local spawn_original = SentryGunBase.spawn
	local init_original = SentryGunBase.init
	local sync_setup_original = SentryGunBase.sync_setup
	local activate_as_module_original = SentryGunBase.activate_as_module
	local destroy_original = SentryGunBase.destroy
	
	function SentryGunBase.spawn(owner, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, peer_id, ...)
		local unit = spawn_original(owner, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, peer_id, ...)
		managers.gameinfo:event("sentry", "create", tostring(unit:key()), unit)
		managers.gameinfo:event("sentry", "set_owner", tostring(unit:key()), peer_id)
		return unit
	end
	
	function SentryGunBase:init(unit, ...)
		managers.gameinfo:event("sentry", "create", tostring(unit:key()), unit)
		init_original(self, unit, ...)
	end
	
	function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
		managers.gameinfo:event("sentry", "set_owner", tostring(self._unit:key()), peer_id)
		return sync_setup_original(self, upgrade_lvl, peer_id, ...)
	end
	
	function SentryGunBase:activate_as_module(...)
		managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		return activate_as_module_original(self, ...)
	end
	
	function SentryGunBase:destroy(...)
		managers.gameinfo:event("sentry", "destroy", tostring(self._unit:key()))
		return destroy_original(self, ...)
	end
	
end

if string.lower(RequiredScript) == "lib/units/equipment/sentry_gun/sentrygundamage" then

	local init_original = SentryGunDamage.init
	local set_health_original = SentryGunDamage.set_health
	local _apply_damage_original = SentryGunDamage._apply_damage
	local die_original = SentryGunDamage.die
	local load_original = SentryGunDamage.load

	function SentryGunDamage:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), true)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
	function SentryGunDamage:set_health(...)
		set_health_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
	function SentryGunDamage:_apply_damage(...)
		local result = _apply_damage_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
		return result
	end
	
	function SentryGunDamage:die(...)
		managers.gameinfo:event("sentry", "set_active", tostring(self._unit:key()), false)
		return die_original(self, ...)
	end

	function SentryGunDamage:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_health_ratio", tostring(self._unit:key()), self:health_ratio())
	end
	
end

if string.lower(RequiredScript) == "lib/units/weapons/sentrygunweapon" then

	local init_original = SentryGunWeapon.init
	local change_ammo_original = SentryGunWeapon.change_ammo
	local sync_ammo_original = SentryGunWeapon.sync_ammo
	local load_original = SentryGunWeapon.load

	function SentryGunWeapon:init(...)
		init_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:change_ammo(...)
		change_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:sync_ammo(...)
		sync_ammo_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
	function SentryGunWeapon:load(...)
		load_original(self, ...)
		managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), self:ammo_ratio())
	end
	
end