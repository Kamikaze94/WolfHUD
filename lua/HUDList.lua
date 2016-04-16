if WolfHUD and not WolfHUD:getSetting("use_hudlist", "boolean") then return end
printf = function(...) 
	WolfHUD:print_log(string.format(...))
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	local function format_time_string(value)
		local frmt_string
	
		if value >= 60 then
			frmt_string = string.format("%d:%02d", math.floor(value / 60), math.ceil(value % 60))
		elseif value >= 9.9 then
			frmt_string = string.format("%d", math.ceil(value))
		elseif value >= 0 then
			frmt_string = string.format("%.1f", value)
		else
			frmt_string = string.format("%.1f", 0)
		end
		
		return frmt_string
	end

	local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
	local update_original = HUDManager.update

	function HUDManager:_setup_player_info_hud_pd2(...)
		_setup_player_info_hud_pd2_original(self, ...)
		
		managers.hudlist = HUDListManager:new()
	end
	
	function HUDManager:update(t, dt, ...)
		if managers.hudlist then
			managers.hudlist:update(t, dt)
		end
		
		return update_original(self, t, dt, ...)
	end
	
	function HUDManager:change_list_setting(setting, value)
		if managers.hudlist then
			return managers.hudlist:change_setting(setting, value)
		else
			HUDListManager.ListOptions[setting] = value
			return true
		end
	end


	HUDListManager = HUDListManager or class()
	HUDListManager.ListOptions = {
		--General settings
        right_list_height_offset = HUDManager.CUSTOM_TEAMMATE_PANEL and 0 or 50,   --Margin from top for the right list
        right_list_scale = 1,   --Size scale of right list
        left_list_height_offset = HUDManager.CUSTOM_TEAMMATE_PANEL and 40 or 70,   --Margin from top for the left list
        left_list_scale = 1,    --Size scale of left list
        buff_list_height_offset = 80,   --Margin from bottom for the buff list
        buff_list_scale = 1,    --Size scale of buff list
        
        --Left side list
        show_timers 					= WolfHUD:getSetting("show_timers", "boolean"),     				--Drills, time locks, hacking etc.
        show_equipment 					= WolfHUD:getSetting("show_equipment", "boolean"),  				--Deployables (ammo, doc bags, body bags)
        show_sentries 					= WolfHUD:getSetting("show_sentries", "boolean"),   				--Deployable sentries
            hide_empty_sentries 		= WolfHUD:getSetting("hide_empty_sentries", "boolean"),     		--Hide sentries with no ammo if player lacks the skill to refill them
        show_ecms 						= WolfHUD:getSetting("show_ecms", "boolean"),       				--Active ECMs
        show_ecm_retrigger 				= WolfHUD:getSetting("show_ecm_retrigger", "boolean"),      		--Countdown for players own ECM feedback retrigger delay
        show_minions 					= WolfHUD:getSetting("show_minions", "boolean"),    				--Converted enemies, type and health
        show_pagers 					= WolfHUD:getSetting("show_pagers", "boolean"),     				--Show currently active pagers
        show_tape_loop 					= WolfHUD:getSetting("show_tape_loop", "boolean"),  				--Show active tape loop duration
        remove_answered_pager_contour 	= WolfHUD:getSetting("remove_answered_pager_contour", "boolean"), 	--Removes the interaction contour on answered pagers
        
        --Right side list
        show_enemies 					= WolfHUD:getSetting("show_enemies", "boolean"),            		--Currently spawned enemies
            aggregate_enemies 			= WolfHUD:getSetting("aggregate_enemies", "boolean"),      			--Don't split enemies on type; use a single entry for all
        show_turrets 					= WolfHUD:getSetting("show_turrets", "boolean"),    				--Show active SWAT turrets
        show_civilians 					= WolfHUD:getSetting("show_civilians", "boolean"),  				--Currently spawned, untied civs
        show_hostages 					= WolfHUD:getSetting("show_hostages", "boolean"),   				--Currently tied civilian and dominated cops
        show_minion_count 				= WolfHUD:getSetting("show_minion_count", "boolean"),       		--Current number of jokered enemies
        show_pager_count 				= WolfHUD:getSetting("show_pager_count", "boolean"),        		--Show number of triggered pagers (only counts pagers triggered while you were present)
        show_loot 						= WolfHUD:getSetting("show_loot", "boolean"),       				--Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
            aggregate_loot 				= WolfHUD:getSetting("aggregate_loot", "boolean"), 					--Don't split loot on type; use a single entry for all
            separate_bagged_loot 		= WolfHUD:getSetting("separate_bagged_loot", "boolean"),     		--Show bagged loot as a separate value
        show_special_pickups 			= WolfHUD:getSetting("show_special_pickups", "boolean"),    		--Show number of special equipment/items
        
        --Buff list
        show_buffs 						= WolfHUD:getSetting("show_buffs", "number"),       				--Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
	}
	
	local RightListColor 	= WolfHUD:getSetting("hud_box_color", "color")
	local RightListBgColor 	= WolfHUD:getSetting("hud_box_bg_color", "color")
	local LeftListColor 	= RightListColor
	local LeftListBgColor 	= RightListBgColor
	local TimerColor 		= LeftListColor
	local TimerBgColor 		= LeftListBgColor
	local EquipmentColor 	= LeftListColor
	local EquipmentBgColor 	= LeftListBgColor
	local PagerColor 		= LeftListColor
	local PagerbgColor 		= LeftListBgColor
	local ECMColor 			= LeftListColor
	local ECMBgColor 		= LeftListBgColor
	local TapeLoopColor 	= LeftListColor
	local TapeLoopBgColor 	= LeftListBgColor
	
    local civilian_color 	= WolfHUD:getSetting("civilian_color", "color")
    local hostage_color 	= civilian_color
    local thug_color 		= WolfHUD:getSetting("thug_color", "color")
	local enemy_color 		= WolfHUD:getSetting("enemy_color", "color")
    local guard_color 		= enemy_color
    local special_color 	= enemy_color
    local turret_color 		= special_color
	
	HUDListManager.TIMER_SETTINGS = {
		[132864] = {	--Meltdown vault temperature
			class = "TemperatureGaugeItem",
			params = { start = 0, goal = 50 },
		},
		[135076] = { ignore = true },	--Lab rats cloaker safe 2
		[135246] = { ignore = true },	--Lab rats cloaker safe 3
		[135247] = { ignore = true },	--Lab rats cloaker safe 4
	}
	
	HUDListManager.UNIT_TYPES = {
		cop = 						{ type_id = "cop",			category = "enemies",	long_name = "Cop" },
		fbi = 						{ type_id = "cop",			category = "enemies",	long_name = "FBI" },
		swat = 						{ type_id = "cop",			category = "enemies",	long_name = "SWAT" },
		heavy_swat = 				{ type_id = "cop",			category = "enemies",	long_name = "H. SWAT" },
		fbi_swat = 					{ type_id = "cop",			category = "enemies",	long_name = "FBI SWAT" },
		fbi_heavy_swat = 			{ type_id = "cop",			category = "enemies",	long_name = "H. FBI SWAT" },
		city_swat = 				{ type_id = "cop",			category = "enemies",	long_name = "Elite" },
		security = 					{ type_id = "security",		category = "enemies",	long_name = "Sec. guard" },
		gensec = 					{ type_id = "security",		category = "enemies",	long_name = "GenSec" },
		gangster = 					{ type_id = "thug",			category = "enemies",	long_name = "Gangster" },
		mobster = 					{ type_id = "thug",			category = "enemies",	long_name = "Mobster" },
		biker_escape = 				{ type_id = "thug",			category = "enemies",	long_name = "Gangster" },
		tank = 						{ type_id = "tank",			category = "enemies",	long_name = "Bulldozer" },
		spooc = 					{ type_id = "spooc",			category = "enemies",	long_name = "Cloaker" },
		taser = 					{ type_id = "taser",			category = "enemies",	long_name = "Taser" },
		shield = 					{ type_id = "shield",		category = "enemies",	long_name = "Shield" },
		sniper = 					{ type_id = "sniper",		category = "enemies",	long_name = "Sniper" },
		mobster_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "Commissar" },
		hector_boss = 				{ type_id = "thug_boss",	category = "enemies",	long_name = "Hector" },
		hector_boss_no_armor = 		{ type_id = "thug_boss",	category = "enemies",	long_name = "Hector" },
		phalanx_vip = 				{ type_id = "phalanx",		category = "enemies",	long_name = "Cpt. Winter" },
		phalanx_minion = 			{ type_id = "phalanx",		category = "enemies",	long_name = "Phalanx" },
		civilian = 					{ type_id = "civ",			category = "civilians",	long_name = "Civilian" },
		civilian_female = 			{ type_id = "civ",			category = "civilians",	long_name = "Civilian" },
		bank_manager = 				{ type_id = "civ",			category = "civilians",	long_name = "Bank mngr." },
		drunk_pilot = 				{ type_id = "unique",		category = "civilians",	long_name = "Pilot" },
		escort = 					{ type_id = "unique",		category = "civilians",	long_name = "Escort" },
		old_hoxton_mission = 		{ type_id = "unique",		category = "civilians",	long_name = "Hoxton" },
		inside_man = 				{ type_id = "unique",		category = "civilians",	long_name = "Insider" },
		boris = 					{ type_id = "unique",		category = "civilians",	long_name = "?" },
		escort_undercover = 		{ type_id = "unique",		category = "civilians",	long_name = "Taxman" },
		
		--Custom unit definitions
		turret = 					{ type_id = "turret",		category = "turrets",	long_name = "SWAT Turret" },
		cop_hostage =				{ type_id = "cop_hostage",	category = "hostages",	--[[force_update = { "cop", "enemies" }]] },
		civ_hostage =				{ type_id = "civ_hostage",	category = "hostages",	force_update = { "civ" } },
		minion =					{ type_id = "minion",		category = "minions",		--[[force_update = { "cop", "enemies" }]] },
	}
	
	HUDListManager.SPECIAL_PICKUP_TYPES = {
		gen_pku_crowbar =				"crowbar",
		pickup_keycard =				"keycard",
		pickup_hotel_room_keycard =		"keycard",
		gage_assignment =				"courier",
		pickup_boards =					"planks",
		stash_planks_pickup =			"planks",
		muriatic_acid =					"meth_ingredients",
		hydrogen_chloride =				"meth_ingredients",
		caustic_soda =					"meth_ingredients",
		gen_pku_blow_torch =			"blowtorch",
		gen_pku_thermite = 				"thermite",
		gen_pku_thermite_paste = 		"thermite",
		hold_take_gas_can = 			"thermite",
		money_wrap_single_bundle = 		"small_loot",
		cas_chips_pile = 				"small_loot",
		diamond_pickup = 				"small_loot",
		diamond_pickup_pal = 			"small_loot",
		safe_loot_pickup = 				"small_loot",
	}
	
	HUDListManager.LOOT_TYPES = {
		ammo =						"shell",
		artifact_statue =			"artifact",
		circuit =					"server",
		coke =						"coke",
		coke_pure =					"coke",
		counterfeit_money =			"money",
		cro_loot1 =					"bomb",
		cro_loot2 =					"bomb",
		diamonds =					"jewelry",
		din_pig =					"pig",
		drk_bomb_part =				"bomb",
		evidence_bag =				"evidence",
		goat = 						"goat",
		gold =						"gold",
		hope_diamond =				"diamond",
		lost_artifact = 			"artifact",
		mad_master_server_value_1 =	"server",
		mad_master_server_value_2 =	"server",
		mad_master_server_value_3 =	"server",
		mad_master_server_value_4 =	"server",
		master_server = 			"server",
		masterpiece_painting =		"painting",
		meth =						"meth",
		meth_half =					"meth",
		money =						"money",
		mus_artifact =				"artifact",
		mus_artifact_paint =		"painting",
		painting =					"painting",
		present = 					"present",
		prototype = 				"prototype",
		safe_ovk =					"safe",
		safe_wpn =					"safe",
		samurai_suit =				"armor",
		sandwich =					"toast",
		turret =					"turret",
		unknown =					"dentist",
		warhead =					"warhead",
		weapon =					"weapon",
		weapon_glock =				"weapon",
		weapon_scar =				"weapon",
	}
	
	function HUDListManager:init()
		self._lists = {}
		self._unit_count_listeners = 0
	
		self:_setup_left_list()
		self:_setup_right_list()
		self:_setup_buff_list()

		managers.gameinfo:register_listener("HUDList_whisper_mode_listener", "whisper_mode", "change", callback(self, self, "_whisper_mode_change"))
	end
	
	function HUDListManager:update(t, dt)
		for _, list in pairs(self._lists) do
			if list:is_active() then
				list:update(t, dt)
			end
		end
	end
	
	function HUDListManager:list(name)
		return self._lists[name]
	end
	
	function HUDListManager:change_setting(setting, value)
		local clbk = "_set_" .. setting
		if HUDListManager[clbk] and HUDListManager.ListOptions[setting] ~= value then
			HUDListManager.ListOptions[setting] = value
			self[clbk](self)
			return true
		end
	end
	
	function HUDListManager:register_list(name, class, params, ...)
		if not self._lists[name] then
			class = type(class) == "string" and _G.HUDList[class] or class
			self._lists[name] = class and class:new(nil, name, params, ...)
		end
		
		return self._lists[name]
	end
	
	function HUDListManager:unregister_list(name, instant)
		if self._lists[name] then
			self._lists[name]:delete(instant)
		end
		self._lists[name] = nil
	end
	
	function HUDListManager:_setup_left_list()
		local list_width = 600
		local list_height = 800
		local x = 0
		local y = HUDListManager.ListOptions.left_list_height_offset or 40
		local scale = HUDListManager.ListOptions.left_list_scale or 1
		local list = self:register_list("left_side_list", HUDList.VerticalList, { align = "left", x = x, y = y, w = list_width, h = list_height, top_to_bottom = true, item_margin = 5 })
	
		--Timers
		local timer_list = list:register_item("timers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
		timer_list:set_static_item(HUDList.LeftListIcon, 1, 4/5, { 
			{ atlas = true, texture_rect = { 3 * 64, 6 * 64, 64, 64 }, color = TimerColor },
		})
		
		--Deployables
		local equipment_list = list:register_item("equipment", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
		equipment_list:set_static_item(HUDList.LeftListIcon, 1, 1, { 
			{ atlas = true, h = 2/3, w = 2/3, texture_rect = { HUDList.EquipmentItem.EQUIPMENT_TABLE.ammo_bag.atlas[1] * 64, HUDList.EquipmentItem.EQUIPMENT_TABLE.ammo_bag.atlas[2] * 64, 64, 64 }, valign = "top", halign = "right", color = EquipmentColor },
			{ atlas = true, h = 2/3, w = 2/3, texture_rect = { HUDList.EquipmentItem.EQUIPMENT_TABLE.doc_bag.atlas[1] * 64, HUDList.EquipmentItem.EQUIPMENT_TABLE.doc_bag.atlas[2] * 64, 64, 64 }, valign = "bottom", halign = "left", color = EquipmentColor },
		})
		
		--Minions
		local minion_list = list:register_item("minions", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, left_to_right = true, item_margin = 5 })
		minion_list:set_static_item(HUDList.LeftListIcon, 1, 4/5, { 
			{ atlas = true, texture_rect = { 6 * 64, 8 * 64, 64, 64 } },
		})
		
		--Pagers
		local pager_list = list:register_item("pagers", HUDList.HorizontalList, { align = "top", w = list_width, h = 40 * scale, left_to_right = true, item_margin = 5 })
		pager_list:set_static_item(HUDList.LeftListIcon, 1, 1, { 
			{ spec = true, texture_rect = { 1 * 64, 4 * 64, 64, 64 }, color = PagerColor },
		})
		
		--ECMs
		local ecm_list = list:register_item("ecms", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5 })
		ecm_list:set_static_item(HUDList.LeftListIcon, 1, 1, { 
			{ atlas = true, texture_rect = { 1 * 64, 4 * 64, 64, 64 }, color = ECMColor },
		})
		
		--ECM trigger
		local retrigger_list = list:register_item("ecm_retrigger", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5 })
		retrigger_list:set_static_item(HUDList.LeftListIcon, 1, 1, { 
			{ atlas = true, texture_rect = { 6 * 64, 2 * 64, 64, 64 }, color = ECMColor },
		})
		
		--Tape loop
		local tape_loop_list = list:register_item("tape_loop", HUDList.HorizontalList, { align = "top", w = list_width, h = 30 * scale, left_to_right = true, item_margin = 5 })
		tape_loop_list:set_static_item(HUDList.LeftListIcon, 1, 1, { 
			{ atlas = true, texture_rect = { 4 * 64, 2 * 64, 64, 64 }, color = TapeLoopColor },
		})
		
		self:_set_show_timers()
		self:_set_show_equipment()
		self:_set_show_sentries()
		self:_set_show_minions()
		self:_set_show_pagers()
		self:_set_show_ecms()
		self:_set_show_ecm_retrigger()
		self:_set_show_tape_loop()
	end
	
	function HUDListManager:_setup_right_list()
		local list_width = 800
		local list_height = 800
		local x = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:right() - list_width
		local y = HUDListManager.ListOptions.right_list_height_offset or 0
		local scale = HUDListManager.ListOptions.right_list_scale or 1
		local list = self:register_list("right_side_list", HUDList.VerticalList, { align = "right", x = x, y = y, w = list_width, h = list_height, top_to_bottom = true, item_margin = 5 })
		
		local unit_count_list = list:register_item("unit_count_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 1 })
		local hostage_count_list = list:register_item("hostage_count_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 4 })
		local loot_list = list:register_item("loot_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 2 })
		local special_equipment_list = list:register_item("special_pickup_list", HUDList.HorizontalList, { align = "top", w = list_width, h = 50 * scale, right_to_left = true, item_margin = 3, priority = 4 })
		
		self:_set_show_enemies()
		self:_set_show_turrets()
		self:_set_show_civilians()
		self:_set_show_hostages()
		self:_set_show_minion_count()
		self:_set_show_pager_count()
		self:_set_show_loot()
		self:_set_show_special_pickups()
	end
	
	function HUDListManager:_setup_buff_list()
		local hud_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel
		local scale = HUDListManager.ListOptions.buff_list_scale or 1
		local list_height = 45 * scale
		local list_width = hud_panel:w()
		local x = 0
		local y
		
		if HUDManager.CUSTOM_TEAMMATE_PANEL then
			if managers.hud._teammate_panels_custom then
				y = managers.hud._teammate_panels_custom[HUDManager.PLAYER_PANEL]:panel():top() - (list_height + 5)
			else
				y = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:panel():top() - (list_height + 5)
			end
		else
			y = hud_panel:bottom() - ((HUDListManager.ListOptions.buff_list_height_offset or 80) + list_height)
		end
		
		local buff_list = self:register_list("buff_list", HUDList.HorizontalList, { 
			align = "center", 
			x = x, 
			y = y , 
			w = list_width, 
			h = list_height, 
			centered = true, 
			item_margin = 0,
			item_move_speed = 300,
			fade_time = 0.15,
		})

		self:_set_show_buffs()
	end
	
	function HUDListManager:_whisper_mode_change(event, key, status)
		local pager_count = self:list("right_side_list"):item("hostage_count_list"):item("PagerCount")
		if pager_count then
			pager_count:set_active(pager_count:get_count() > 0 and status)
		end
		
		for _, item in pairs(self:list("left_side_list"):item("pagers"):items()) do
			item:set_active(status)
		end
		
		for _, item in pairs(self:list("left_side_list"):item("equipment"):items()) do
			if item:get_type() == "body_bag" then
				item:set_active(item:current_amount() > 0 and status)
			end
		end
	end
	
	
	--Event handlers
	function HUDListManager:_timer_event(event, key, data)
		local timer_list = self:list("left_side_list"):item("timers")
		local settings = HUDListManager.TIMER_SETTINGS[data.id] or {}
		
		if not settings.ignore then
			if event == "set_active" and data.active then
				local item = timer_list:register_item(key, settings.class or HUDList.TimerItem, data, settings.params)
				item:activate()
			elseif event == "set_active" and not data.active then
				timer_list:unregister_item(key)
			else
				local item = timer_list:item(key)
				
				if item then
					if event == "update" then
						item:update_timer(data.t, data.timer)
					elseif event == "set_jammed" then
						item:set_jammed(data.jammed)
					elseif event == "set_powered" then
						item:set_powered(data.powered)
					elseif event == "set_upgradable" then
						item:set_upgradable(data.upgradable)
					end
				end
			end
		end
	end
	
	function HUDListManager:_unit_count_event(event, unit_type, difference)
		if HUDListManager.UNIT_TYPES[unit_type] then
			local list = self:list("right_side_list"):item("unit_count_list")
			local type_id = HUDListManager.UNIT_TYPES[unit_type].type_id
			local category = HUDListManager.UNIT_TYPES[unit_type].category
			
			local item = list:item(type_id) or list:item(category)
			if item then
				item:change_count(difference)
			end
			
			for _, id in pairs(HUDListManager.UNIT_TYPES[unit_type].force_update or {}) do
				local item = list:item(id)
				if item then
					item:change_count(0)
				end
			end
		end
	end
	
	function HUDListManager:_minion_event(event, key, data)
		local minion_list = self:list("left_side_list"):item("minions")
		
		if event == "add" then
			local item = minion_list:register_item(key, HUDList.MinionItem, data.unit)
			item:activate()
		elseif event == "remove" then
			minion_list:unregister_item(key)
		elseif event == "set_owner" then
			minion_list:item(key):set_owner(data.owner)
		elseif event == "set_health_multiplier" then
			minion_list:item(key):set_health_multiplier(data.health_multiplier)
		elseif event == "set_damage_multiplier" then
			minion_list:item(key):set_damage_multiplier(data.damage_multiplier)
		elseif event == "set_health" then
			minion_list:item(key):set_health(data.health)
		elseif event == "set_kills" then
			minion_list:item(key):set_kills(data.kills)
		end
	end
	
	function HUDListManager:_pager_event(event, key, data)
		local pager_list = self:list("left_side_list"):item("pagers")
		
		if event == "add" then
			pager_list:register_item(key, HUDList.PagerItem, data.unit):activate()
		elseif event == "remove" then
			pager_list:unregister_item(key)
		elseif event == "answered" then
			pager_list:item(key):set_answered()
		end
	end
	
	function HUDListManager:_pager_count_event(event, key, data)
		local item = self:list("right_side_list"):item("hostage_count_list"):item("PagerCount")
		if item then
			item:change_count(1)
		end
	end
	
	function HUDListManager:_special_pickup_event(event, key, data)
		local pickup_type = HUDListManager.SPECIAL_PICKUP_TYPES[data.interact_id]
		
		if pickup_type then
			local item = self:list("right_side_list"):item("special_pickup_list"):item(pickup_type)
			if event == "add" then
				item:change_count(1)
			elseif event == "remove" then
				item:change_count(-1)
			end
		end
	end
	
	function HUDListManager:_loot_count_event(event, key, data)
		local loot_type = HUDListManager.LOOT_TYPES[data.carry_id]
		
		if loot_type then
			local item = self:list("right_side_list"):item("loot_list"):item(loot_type)
			local aggregate_item = self:list("right_side_list"):item("loot_list"):item("aggregate")
			local bagged_diff = data.bagged and data.count or 0
			local unbagged_diff = data.bagged and 0 or data.count
			
			if event == "add" then
				if item then
					item:change_count(unbagged_diff, bagged_diff)
				end
				if aggregate_item then
					aggregate_item:change_count(unbagged_diff, bagged_diff)
				end
			elseif event == "remove" then
				if item then
					item:change_count(-unbagged_diff, -bagged_diff)
				end
				if aggregate_item then
					aggregate_item:change_count(-unbagged_diff, -bagged_diff)
				end
			end
		end
	end
	
	function HUDListManager:_ecm_event(event, key, data)
		local ecm_list = self:list("left_side_list"):item("ecms")
		
		if event == "set_jammer_active" then
			if data.active then
				ecm_list:register_item(key, HUDList.ECMItem):activate()
			else
				ecm_list:unregister_item(key)
			end
		elseif event == "set_battery" then
			ecm_list:item(key):update_timer(data.battery)
		end
	end
	
	function HUDListManager:_ecm_retrigger_event(event, key, data)
		local list = self:list("left_side_list"):item("ecm_retrigger")
		
		if event == "set_retrigger_active" then
			if data.retrigger then
				list:register_item(key, HUDList.ECMRetriggerItem):activate()
			else
				list:unregister_item(key)
			end
		elseif event == "set_retrigger" then
			list:item(key):update_timer(data.retrigger_t)
		end
	end
	
	function HUDListManager:_bag_equipment_event(event, key, data)
		--printf("HUDListManager:_bag_equipment_event(%s, %s)\n", event, key)
	
		if data.aggregate_key then return end
	
		local equipment_list = self:list("left_side_list"):item("equipment")
		
		if event == "set_active" then
			if data.active then
				local item = equipment_list:register_item(key, HUDList.BagEquipmentItem, data)
				if data.type == "body_bag" then
					item:set_active(managers.groupai:state():whisper_mode())
				else
					item:activate()
				end
			else
				equipment_list:unregister_item(key)
			end
		else
			local item = equipment_list:item(key)
			
			if item then
				if event == "set_owner" then
					item:set_owner(data.owner)
				elseif event == "set_max_amount" then
					item:set_max_amount(data.max_amount or 0)
				elseif event == "set_amount" then
					item:set_amount(data.amount or 0)
				elseif event == "set_amount_offset" then
					item:set_amount_offset(data.amount_offset or 0)
				end
			end
		end
	end
	
	function HUDListManager:_tape_loop_event(event, key, unit, duration)
		local tape_loop_list = self:list("left_side_list"):item("tape_loop")
		
		if event == "start" then
			local item = tape_loop_list:register_item(key, HUDList.TapeLoopItem, unit)
			item:set_duration(duration)
			item:activate()
		elseif event == "stop" then
			tape_loop_list:unregister_item(key)
		end
	end
	
	function HUDListManager:_sentry_equipment_event(event, key, data)
		local equipment_list = self:list("left_side_list"):item("equipment")
		
		if event == "set_active" then
			if data.active then
				equipment_list:register_item(key, HUDList.SentryEquipmentItem, data):activate()
			else
				equipment_list:unregister_item(key)
			end
		else
			local item = equipment_list:item(key)
			
			if item then
				if event == "set_owner" then
					item:set_owner(data.owner)
				elseif event == "set_ammo_ratio" then
					item:set_ammo_ratio(data.ammo_ratio)
					
					if HUDListManager.ListOptions.hide_empty_sentries then
						if not managers.player:has_category_upgrade("sentry_gun", "can_reload") then
							item:set_active(data.ammo_ratio > 0)
						end
					end
				elseif event == "set_health_ratio" then
					item:set_health_ratio(data.health_ratio)
				end
			end
		end
	end
	

	--Left list config
	function HUDListManager:_set_show_timers()
		local listener_id = "HUDListManager_timer_listener"
		local events = { "update", "set_active", "set_jammed", "set_powered", "set_upgradable" }
		
		if HUDListManager.ListOptions.show_timers then
			local clbk = callback(self, self, "_timer_event")
			local spawned_items = managers.gameinfo:get_timers()
			
			for key, data in pairs(spawned_items) do
				if data.active then
					self:_timer_event("set_active", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "timer", event, clbk)
			end
		else
			local list = self:list("left_side_list"):item("timers")
		
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "timer", event)
			end
			
			for _, item in pairs(list:items()) do
				item:delete(true)
			end
		end
	end
	
	function HUDListManager:_set_show_minions()
		local listener_id = "HUDListManager_minion_listener"
		local events = { "add", "remove", "set_owner", "set_health_multiplier", "set_damage_multiplier", "set_health", "set_kills" }
		local spawned_minions = managers.gameinfo:get_minions()
		
		if HUDListManager.ListOptions.show_minions then
			local clbk = callback(self, self, "_minion_event")
			
			for key, data in pairs(spawned_minions) do
				self:_minion_event("add", key, data)
				self:_minion_event("set_owner", key, data)
				self:_minion_event("set_health_multiplier", key, data)
				self:_minion_event("set_damage_multiplier", key, data)
				self:_minion_event("set_health", key, data)
				self:_minion_event("set_kills", key, data)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "minion", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "minion", event)
			end
		
			for key, data in pairs(spawned_minions) do
				self:_minion_event("remove", key, data)
			end
		end
	end
	
	function HUDListManager:_set_show_pagers()
		local pagers = managers.gameinfo:get_pagers()
		local listener_id = "HUDListManager_pager_listener"
		local events = { "add", "remove", "answered" }
		
		if HUDListManager.ListOptions.show_pagers then
			local clbk = callback(self, self, "_pager_event")
		
			for key, data in pairs(pagers) do
				if data.active then
					self:_pager_event("add", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "pager", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "pager", event)
			end
			
			for key, data in pairs(pagers) do
				if data.active then
					self:_pager_event("remove", key, data)
				end
			end
		end
	end
	
	function HUDListManager:_set_show_ecms()
		local list = self:list("left_side_list"):item("ecms")
		local ecms = managers.gameinfo:get_ecms()
		local listener_id = "HUDListManager_ecm_listener"
		local events = { "set_jammer_active", "set_battery" } 
	
		if HUDListManager.ListOptions.show_ecms then
			local clbk = callback(self, self, "_ecm_event")
		
			for key, data in pairs(ecms) do
				if data.active then
					self:_ecm_event("set_jammer_active", key, data)
					self._ecm_event("set_battery", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "ecm", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "ecm", event)
			end
			
			for _, item in pairs(list:items()) do
				item:delete()
			end
		end
	end
	
	function HUDListManager:_set_show_ecm_retrigger()
		local list = self:list("left_side_list"):item("ecm_retrigger")
		local ecms = managers.gameinfo:get_ecms()
		local listener_id = "HUDListManager_ecm_listener"
		local events = { "set_retrigger_active", "set_retrigger" } 
	
		if HUDListManager.ListOptions.show_ecm_retrigger then
			local clbk = callback(self, self, "_ecm_retrigger_event")
		
			for key, data in pairs(ecms) do
				if data.retrigger then
					self:_ecm_event("set_retrigger_active", key, data)
					self._ecm_event("set_retrigger", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "ecm", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "ecm", event)
			end
			
			for _, item in pairs(list:items()) do
				item:delete()
			end
		end
	end
	
	function HUDListManager:_set_show_equipment()
		local listener_id = "HUDListManager_equipment_listener"
		local events = { "set_active", "set_owner", "set_max_amount", "set_amount_offset", "set_amount" }
		local spawned_items = managers.gameinfo:get_deployables()
		
		if HUDListManager.ListOptions.show_equipment then
			local clbk = callback(self, self, "_bag_equipment_event")
			
			for key, data in pairs(spawned_items) do
				if not data.aggregate then
					self:_bag_equipment_event("set_owner", key, data)
					self:_bag_equipment_event("set_max_amount", key, data)
					self:_bag_equipment_event("set_amount_offset", key, data)
					self:_bag_equipment_event("set_amount", key, data)
					self:_bag_equipment_event("set_active", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "bag_deployable", event, clbk)
			end
		else
			local list = self:list("left_side_list"):item("equipment")
		
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "bag_deployable", event)
			end
			
			for key, data in pairs(spawned_items) do
				list:unregister_item(key)
			end
		end
	end

	function HUDListManager:_set_show_tape_loop()
		local list = self:list("left_side_list"):item("tape_loop")
		local listener_id = "HUDListManager_tape_loop_listener"
		local events = { "start", "stop" }
		
		if HUDListManager.ListOptions.show_tape_loop then		
			local clbk = callback(self, self, "_tape_loop_event")
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "tape_loop", event, clbk)
			end
		else
			for _, item in pairs(list:items()) do
				item:delete(true)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "tape_loop", event)
			end
		end
	end
	
	function HUDListManager:_set_show_sentries()
		local listener_id = "HUDListManager_sentry_listener"
		local events = { "set_active", "set_owner", "set_ammo_ratio", "set_health_ratio" }
		local spawned_items = managers.gameinfo:get_sentries()
		
		if HUDListManager.ListOptions.show_sentries then
			local clbk = callback(self, self, "_sentry_equipment_event")
			
			for key, data in pairs(spawned_items) do
				if data.active then
					self:_sentry_event("set_active", key, data)
				end
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "sentry", event, clbk)
			end
		else
			local list = self:list("left_side_list"):item("equipment")
		
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "sentry", event)
			end
			
			for key, data in pairs(spawned_items) do
				list:unregister_item(key)
			end
		end
	end

	--Right list config
	function HUDListManager:_set_show_enemies()
		local list = self:list("right_side_list"):item("unit_count_list")
		local listener_id = "HUDListManager_unit_count_listener"
		local events = { "change" }
		
		local category = "enemies"
		local items = {}
		
		if HUDListManager.ListOptions.aggregate_enemies then
			items.enemies = category
		else
			for id, data in pairs(HUDListManager.UNIT_TYPES) do
				if data.category == category then
					items[data.type_id] = category
				end
			end
		end
		
		
		if HUDListManager.ListOptions.show_enemies then
			self._unit_count_listeners = self._unit_count_listeners + 1
			local clbk = callback(self, self, "_unit_count_event")
			
			for id, category in pairs(items) do
				local data = HUDList.UnitCountItem.MAP[id]
				list:register_item(id, data.class or HUDList.UnitCountItem, id, category)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "unit_count", event, clbk)
			end
		else
			self._unit_count_listeners = self._unit_count_listeners - 1
			if self._unit_count_listeners <= 0 then
				for _, event in pairs(events) do
					managers.gameinfo:unregister_listener(listener_id, "unit_count", event)
				end
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_aggregate_enemies()	--TODO: Needs to be fixed for new version
		do return end
		
		local list = self:list("right_side_list"):item("unit_count_list")
		
		for name, data in pairs(HUDList.UnitCountItem.ENEMY_ICON_MAP) do
			if not data.manual_add then
				list:unregister_item(name, true)
			end
			list:unregister_item("all", true)
		end
		
		self:_set_show_enemies()
	end
	
	function HUDListManager:_set_show_civilians()
		local list = self:list("right_side_list"):item("unit_count_list")
		local listener_id = "HUDListManager_unit_count_listener"
		local events = { "change" }
		
		local category = "civilians"
		local items = {}
		
		for id, data in pairs(HUDListManager.UNIT_TYPES) do
			if data.category == category then
				items[data.type_id] = category
			end
		end
		
		if HUDListManager.ListOptions.show_civilians then
			self._unit_count_listeners = self._unit_count_listeners + 1
			local clbk = callback(self, self, "_unit_count_event")
			
			for id, category in pairs(items) do
				local data = HUDList.UnitCountItem.MAP[id]
				list:register_item(id, data.class or HUDList.UnitCountItem, id, category)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "unit_count", event, clbk)
			end
		else
			self._unit_count_listeners = self._unit_count_listeners - 1
			if self._unit_count_listeners <= 0 then
				for _, event in pairs(events) do
					managers.gameinfo:unregister_listener(listener_id, "unit_count", event)
				end
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_show_hostages()
		local list = self:list("right_side_list"):item("unit_count_list")
		local listener_id = "HUDListManager_unit_count_listener"
		local events = { "change" }
		
		local category = "hostages"
		local items = {}
		
		for id, data in pairs(HUDListManager.UNIT_TYPES) do
			if data.category == category then
				items[data.type_id] = category
			end
		end
		
		if HUDListManager.ListOptions.show_civilians then
			self._unit_count_listeners = self._unit_count_listeners + 1
			local clbk = callback(self, self, "_unit_count_event")
			
			for id, category in pairs(items) do
				local data = HUDList.UnitCountItem.MAP[id]
				list:register_item(id, data.class or HUDList.UnitCountItem, id, category)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "unit_count", event, clbk)
			end
		else
			self._unit_count_listeners = self._unit_count_listeners - 1
			if self._unit_count_listeners <= 0 then
				for _, event in pairs(events) do
					managers.gameinfo:unregister_listener(listener_id, "unit_count", event)
				end
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_show_minion_count()
		local list = self:list("right_side_list"):item("unit_count_list")
		local listener_id = "HUDListManager_unit_count_listener"
		local events = { "change" }
		
		local category = "minions"
		local items = {}
		
		for id, data in pairs(HUDListManager.UNIT_TYPES) do
			if data.category == category then
				items[data.type_id] = category
			end
		end
		
		if HUDListManager.ListOptions.show_minion_count then
			self._unit_count_listeners = self._unit_count_listeners + 1
			local clbk = callback(self, self, "_unit_count_event")
			
			for id, category in pairs(items) do
				local data = HUDList.UnitCountItem.MAP[id]
				list:register_item(id, data.class or HUDList.UnitCountItem, id, category)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "unit_count", event, clbk)
			end
		else
			self._unit_count_listeners = self._unit_count_listeners - 1
			if self._unit_count_listeners <= 0 then
				for _, event in pairs(events) do
					managers.gameinfo:unregister_listener(listener_id, "unit_count", event)
				end
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_show_turrets()
		local list = self:list("right_side_list"):item("unit_count_list")
		local listener_id = "HUDListManager_unit_count_listener"
		local events = { "change" }
		
		local category = "turrets"
		local items = {}
		
		for id, data in pairs(HUDListManager.UNIT_TYPES) do
			if data.category == category then
				items[data.type_id] = category
			end
		end
		
		if HUDListManager.ListOptions.show_turrets then
			self._unit_count_listeners = self._unit_count_listeners + 1
			local clbk = callback(self, self, "_unit_count_event")
			
			for id, category in pairs(items) do
				local data = HUDList.UnitCountItem.MAP[id]
				list:register_item(id, data.class or HUDList.UnitCountItem, id, category)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "unit_count", event, clbk)
			end
		else
			self._unit_count_listeners = self._unit_count_listeners - 1
			if self._unit_count_listeners <= 0 then
				for _, event in pairs(events) do
					managers.gameinfo:unregister_listener(listener_id, "unit_count", event)
				end
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end	
	
	function HUDListManager:_set_show_pager_count()
		local list = self:list("right_side_list"):item("hostage_count_list")
		local listener_id = "HUDListManager_pager_count_listener"
		local events = { "add" }
		
		if HUDListManager.ListOptions.show_pager_count then
			local clbk = callback(self, self, "_pager_count_event")
			
			list:register_item("PagerCount", HUDList.UsedPagersItem)
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "pager", event, clbk)
			end
		else
			list:unregister_item("PagerCount", true)
		end
	end
	
	function HUDListManager:_set_show_special_pickups()
		local list = self:list("right_side_list"):item("special_pickup_list")
		local listener_id = "HUDListManager_special_pickup_count_listener"
		local events = { "add", "remove" }
		
		local items = {}
		
		for id, pickup_type in pairs(HUDListManager.SPECIAL_PICKUP_TYPES) do
			items[pickup_type] = true
		end
		
		if HUDListManager.ListOptions.show_special_pickups then
			local special_pickups = managers.gameinfo:get_special_equipment()
			local clbk = callback(self, self, "_special_pickup_event")
			
			local count = {}
			for key, interact_id in pairs(special_pickups) do
				local id = HUDListManager.SPECIAL_PICKUP_TYPES[interact_id]
				if id then
					count[id] = (count[id] or 0) + 1
				end
			end
			
			for id, _ in pairs(items) do
				local item = list:register_item(id, HUDList.SpecialPickupItem)
				item:set_count(count[id] or 0)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "special_equipment", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "special_equipment", event)
			end
			
			for id, _ in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_show_loot()
		local list = self:list("right_side_list"):item("loot_list")
		local listener_id = "HUDListManager_loot_count_listener"
		local events = { "add", "remove" }
		
		local items = {}
		
		if HUDListManager.ListOptions.aggregate_loot then
			table.insert(items, "aggregate")
		else
			for _, id in pairs(HUDListManager.LOOT_TYPES) do
				table.insert(items, id)
			end
		end
		
		if HUDListManager.ListOptions.show_loot then
			local loot_units = managers.gameinfo:get_loot()
			local clbk = callback(self, self, "_loot_count_event")
			
			local bagged = {}
			local unbagged = {}
			for key, data in pairs(loot_units) do
				local id = HUDListManager.LOOT_TYPES[data.carry_id]
				if id then
					bagged[id] = (bagged[id] or 0) + (data.bagged and data.count or 0)
					unbagged[id] = (unbagged[id] or 0) + (data.bagged and 0 or data.count)
				end
			end
			
			for _, id in pairs(items) do
				local item = list:register_item(id, HUDList.LootItem)
				item:set_count(unbagged[id] or 0, bagged[id] or 0)
			end
			
			for _, event in pairs(events) do
				managers.gameinfo:register_listener(listener_id, "loot", event, clbk)
			end
		else
			for _, event in pairs(events) do
				managers.gameinfo:unregister_listener(listener_id, "loot", event)
			end
			
			for _, id in pairs(items) do
				list:unregister_item(id)
			end
		end
	end
	
	function HUDListManager:_set_aggregate_loot()	--TODO: Needs to be fixed for new version
		do return end
	
		local list = self:list("right_side_list"):item("loot_list")
		
		for name, data in pairs(HUDList.LootItem.LOOT_ICON_MAP) do
			list:unregister_item(name, true)
		end
		
		self:_set_show_loot()
	end
	
	
	--Buff list
	function HUDListManager:_buff_activation(status, buff, ...)
		local data = HUDList.BuffItemBase.COMPOSITE_ITEMS[buff]
		local buff = data and data.item or buff
	
		if not HUDList.BuffItemBase.IGNORED_BUFFS[buff] then
			local item = self:list("buff_list"):item(buff)
			
			if item then
				if status then
					item:activate()
				elseif not (data and data.keep_on_deactivation) then
					item:deactivate()
				end
				
				if data then
					if data.level then
						item:set_level(data.level(), true)
					end
					if data.aced then
						item:set_aced(data.aced(), true)
					end
				end
			end
			
			local buff_data = HUDList.BuffItemBase.BUFF_MAP[buff]
			if status and buff_data.on_activate then
				buff_data.on_activate()
			end
		end
	end
	
	function HUDListManager:_buff_event(event, buff, ...)
		local data = HUDList.BuffItemBase.COMPOSITE_ITEMS[buff]
	
		if not HUDList.BuffItemBase.IGNORED_BUFFS[data and data.item or buff] then
			local item = self:list("buff_list"):item(data and data.item or buff)
			
			if item then
				item[event](item, ...)
			end
		end
	end
	
	function HUDListManager:_set_show_buffs()
		local list = self:list("buff_list")
		
		local listener_name = "HUDListManager_buff_listener"
		local listeners = {
			on_buff_activated = callback(self, self, "_buff_activation", true),
			on_buff_deactivated = callback(self, self, "_buff_activation", false),
			--on_buff_set_duration = callback(self, self, "_buff_event", "set_duration"),
			--on_buff_set_expiration = callback(self, self, "_buff_event", "set_expiration"),
			on_buff_refresh = callback(self, self, "_buff_event", "refresh"),
			on_buff_set_aced = callback(self, self, "_buff_event", "set_aced"),
			on_buff_set_level = callback(self, self, "_buff_event", "set_level"),
			on_buff_set_stack_count = callback(self, self, "_buff_event", "set_stack_count"),
			on_buff_set_flash = callback(self, self, "_buff_event", "set_flash"),
			on_buff_set_progress = callback(self, self, "_buff_event", "set_progress"),
		}
		
		if HUDListManager.ListOptions.show_buffs < 3 then
			for name, data in pairs(HUDList.BuffItemBase.BUFF_MAP) do
				if HUDListManager.ListOptions.show_buffs <= 1 or (data.class == "TimedBuffItem" or data.class == "ChargedBuffItem") then
					local item = list:register_item(name, data.class or "BuffItemBase", data)
					if data.aced then
						item:set_aced(data.aced)
					end
					
					if data.level then
						item:set_level(data.level)
					end
					
					if data.no_fade then
						item:set_fade_time(0)
					end
				end
			end
			
			for _, src in ipairs({ PlayerManager.ACTIVE_BUFFS, PlayerManager.ACTIVE_TEAM_BUFFS }) do
				for buff, data in pairs(src) do
					self:_buff_activation(true, buff)
					
					for _, info in ipairs({ "aced", "level", "stack_count", "progress", "flash" }) do
						if data[info] then
							self:_buff_event("set_" .. info, buff, unpack(data[info]))
						end
					end
				end
			end
		
			for event, clbk in pairs(listeners) do
				PlayerManager.register_listener_clbk(listener_name, event, clbk)
			end
		else
			for _, item in pairs(list:items()) do
				item:delete(true)
			end
			
			for event, _ in pairs(listeners) do
				PlayerManager.unregister_listener_clbk(listener_name, event)
			end
		end
	end
	
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--LIST CLASS DEFINITION BLOCK
	HUDList = HUDList or {}
	
	HUDList.ItemBase = HUDList.ItemBase or class()
	function HUDList.ItemBase:init(parent_list, name, params)
		self._parent_list = parent_list
		self._name = name
		self._align = params.align or "center"
		self._fade_time = params.fade_time or 0.25
		self._move_speed = params.move_speed or 150
		self._priority = params.priority
		
		self._panel = (self._parent_list and self._parent_list:panel() or params.native_panel or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel):panel({
			name = name,
			visible = true,
			alpha = 0,
			w = params.w or 0,
			h = params.h or 0,
			x = params.x or 0,
			y = params.y or 0,
			layer = 10
		})
	end

	function HUDList.ItemBase:post_init(...) end
	function HUDList.ItemBase:destroy() end
	function HUDList.ItemBase:name() return self._name end
	function HUDList.ItemBase:panel() return self._panel end
	function HUDList.ItemBase:parent_list() return self._parent_list end
	function HUDList.ItemBase:align() return self._align end
	function HUDList.ItemBase:is_active() return self._active end
	function HUDList.ItemBase:priority() return self._priority end
	function HUDList.ItemBase:fade_time() return self._fade_time end
	function HUDList.ItemBase:hidden() return self._force_hide end

	function HUDList.ItemBase:_set_item_visible(status)
		self._panel:set_visible(status and not self._force_hide)
	end
	
	function HUDList.ItemBase:set_force_hide(status)
		self._force_hide = status
		self:_set_item_visible(self._active)
		if self._parent_list then
			self._parent_list:set_item_hidden(self, status)
		end
	end
	
	function HUDList.ItemBase:set_priority(priority)
		self._priority = priority
	end
	
	function HUDList.ItemBase:set_fade_time(time)
		self._fade_time = time
	end
	
	function HUDList.ItemBase:set_move_speed(speed)
		self._move_speed = speed
	end

	function HUDList.ItemBase:set_active(status)
		if status then
			self:activate()
		else
			self:deactivate()
		end
	end

	function HUDList.ItemBase:activate()
		self._active = true
		self._scheduled_for_deletion = nil
		self:_show()
	end

	function HUDList.ItemBase:deactivate()
		self._active = false
		self:_hide()
	end

	function HUDList.ItemBase:delete(instant)
		self._scheduled_for_deletion = true
		self._active = false
		self:_hide(instant)
	end
	
	function HUDList.ItemBase:_delete()
		self:destroy()
		if alive(self._panel) then
			--self._panel:stop()		--Should technically do this, but screws with unrelated animations for some reason...
			if self._parent_list then
				self._parent_list:_remove_item(self)
				self._parent_list:set_item_visible(self, false)
			end
			if alive(self._panel:parent()) then
				self._panel:parent():remove(self._panel)
			end
		end
	end

	function HUDList.ItemBase:_show(instant)
		if alive(self._panel) then
			--self._panel:set_visible(true)
			self:_set_item_visible(true)
			self:_fade(1, instant)
			if self._parent_list then
				self._parent_list:set_item_visible(self, true)
			end
		end
	end

	function HUDList.ItemBase:_hide(instant)
		if alive(self._panel) then
			self:_fade(0, instant)
			if self._parent_list then
				self._parent_list:set_item_visible(self, false)
			end
		end
	end
	
	function HUDList.ItemBase:_fade(target_alpha, instant)
		self._panel:stop()
		--if self._panel:alpha() ~= target_alpha then
			--self._active_fade = { instant = instant, alpha = target_alpha }
			self._active_fade = { instant = instant or self._panel:alpha() == target_alpha, alpha = target_alpha }
		--end
		self:_animate_item()
	end

	function HUDList.ItemBase:move(x, y, instant)
		if alive(self._panel) then
			self._panel:stop()
			--if self._panel:x() ~= x or self._panel:y() ~= y then
				--self._active_move = { instant = instant, x = x, y = y }
				self._active_move = { instant = instant or (self._panel:x() == x and self._panel:y() == y), x = x, y = y }
			--end
			self:_animate_item()
		end
	end
	
	function HUDList.ItemBase:cancel_move()
		self._panel:stop()
		self._active_move = nil
		self:_animate_item()
	end
	
	function HUDList.ItemBase:_animate_item()
		if alive(self._panel) and self._active_fade then
			self._panel:animate(callback(self, self, "_animate_fade"), self._active_fade.alpha, self._active_fade.instant)
		end
		
		if alive(self._panel) and self._active_move then
			self._panel:animate(callback(self, self, "_animate_move"), self._active_move.x, self._active_move.y, self._active_move.instant)
		end
	end
	
	function HUDList.ItemBase:_animate_fade(panel, alpha, instant)
		if not instant and self._fade_time > 0 then
			local fade_time = self._fade_time
			local init_alpha = panel:alpha()
			local change = alpha > init_alpha and 1 or -1
			local T = math.abs(alpha - init_alpha) * fade_time
			local t = 0
			
			while alive(panel) and t < T do
				panel:set_alpha(math.clamp(init_alpha + t * change * 1 / fade_time, 0, 1))
				t = t + coroutine.yield()
			end
		end
		
		self._active_fade = nil
		if alive(panel) then
			panel:set_alpha(alpha)
			--panel:set_visible(alpha > 0)
			self:_set_item_visible(alpha > 0)
		end
		--if self._parent_list and alpha == 0 then
		--	self._parent_list:set_item_visible(self, false)
		--end
		if self._scheduled_for_deletion then
			self:_delete()
		end
	end
	
	function HUDList.ItemBase:_animate_move(panel, x, y, instant)
		if not instant and self._move_speed > 0 then
			local move_speed = self._move_speed
			local init_x = panel:x()
			local init_y = panel:y()
			local x_change = x > init_x and 1 or x < init_x and -1
			local y_change = y > init_y and 1 or y < init_y and -1
			local T = math.max(math.abs(x - init_x) / move_speed, math.abs(y - init_y) / move_speed)
			local t = 0
			
			while alive(panel) and t < T do
				if x_change then
					panel:set_x(init_x  + t * x_change * move_speed)
				end
				if y_change then
					panel:set_y(init_y  + t * y_change * move_speed)
				end
				t = t + coroutine.yield()
			end
		end

		self._active_move = nil
		if alive(panel) then
			panel:set_x(x)
			panel:set_y(y)
		end
	end
	
	--TODO: Move this stuff. Good to have, but has nothing to do with the list and should be localized to subclasses where it is used
	HUDList.ItemBase.DEFAULT_COLOR_TABLE = {
		{ ratio = 0.0, color = Color(1, 0.9, 0.1, 0.1) }, --Red
		{ ratio = 0.5, color = Color(1, 0.9, 0.9, 0.1) }, --Yellow
		{ ratio = 1.0, color = Color(1, 0.1, 0.9, 0.1) } --Green
	}
	function HUDList.ItemBase:_get_color_from_table(value, max_value, color_table, default_color)
		local color_table = color_table or HUDList.ItemBase.DEFAULT_COLOR_TABLE
		local ratio = math.clamp(value / max_value, 0 , 1)
		local tmp_color = color_table[#color_table].color
		local color = default_color or Color(tmp_color.alpha, tmp_color.red, tmp_color.green, tmp_color.blue)
		
		for i, data in ipairs(color_table) do
			if ratio < data.ratio then
				local nxt = color_table[math.clamp(i-1, 1, #color_table)]
				local scale = (ratio - data.ratio) / (nxt.ratio - data.ratio)
				color = Color(
					(data.color.alpha or 1) * (1-scale) + (nxt.color.alpha or 1) * scale, 
					(data.color.red or 0) * (1-scale) + (nxt.color.red or 0) * scale, 
					(data.color.green or 0) * (1-scale) + (nxt.color.green or 0) * scale, 
					(data.color.blue or 0) * (1-scale) + (nxt.color.blue or 0) * scale)
				break
			end
		end
		
		return color
	end

	function HUDList.ItemBase:_create_icons(data)
		local icons_added = {}
	
		for i, icon in ipairs(data) do
			local x, y = unpack((icon.atlas or icon.spec) or { 0, 0 })
			local texture = icon.texture
				or icon.spec and "guis/textures/pd2/specialization/icons_atlas" 
				or icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" 
				or icon.waypoints and "guis/textures/pd2/pd2_waypoints"
				or icon.hudtabs and "guis/textures/pd2/hud_tabs"
				or icon.hudpickups and "guis/textures/pd2/hud_pickups"
				or icon.hudicons and "guis/textures/hud_icons"
			local texture_rect = (icon.spec or icon.atlas) and { x * 64, y * 64, 64, 64 } or icon.waypoints or icon.hudtabs or icon.hudpickups or icon.hudicons or icon.texture_rect
			
			local new_icon = self._panel:bitmap({
				name = data.name or "icon",
				texture = texture,
				texture_rect = texture_rect,
				h = icon.h or self._panel:h(),
				w = icon.w or self._panel:w(),
				alpha = icon.alpha or 1,
				blend_mode = icon.blend_mode or "normal",
				color = icon.color or Color.white,
				layer = icon.layer or 0,
			})
			
			if icon.halign == "center" then
				new_icon:set_center_x(self._panel:w() / 2)
			elseif icon.halign == "right" then
				new_icon:set_right(self._panel:w())
			end
			
			if icon.valign == "center" then
				new_icon:set_center_y(self._panel:h() / 2)
			elseif icon.valign == "bottom" then
				new_icon:set_bottom(self._panel:h())
			end
			
			table.insert(icons_added, new_icon)
		end
		
		return icons_added
	end
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.ListBase = HUDList.ListBase or class(HUDList.ItemBase) --DO NOT INSTANTIATE THIS CLASS
	function HUDList.ListBase:init(parent, name, params)
		params.fade_time = params.fade_time or 0
		HUDList.ListBase.super.init(self, parent, name, params)

		self._stack = params.stack or false
		self._queue = not self._stack
		self._item_fade_time = params.item_fade_time
		self._item_move_speed = params.item_move_speed
		self._item_margin = params.item_margin or 0
		self._margin = params.item_margin or 0
		self._stack = params.stack or false
		self._items = {}
		self._shown_items = {}
	end

	function HUDList.ListBase:item(name)
		return self._items[name]
	end

	function HUDList.ListBase:items()
		return self._items
	end
	
	function HUDList.ListBase:num_items()
		return table.size(self._items)
	end

	function HUDList.ListBase:active_items()
		local count  = 0
		for name, item in pairs(self._items) do
			if item:is_active() then
				count = count + 1
			end
		end
		return count
	end

	function HUDList.ListBase:shown_items()
		return #self._shown_items
	end

	function HUDList.ListBase:update(t, dt)
		local delete_items = {}
		for name, item in pairs(self._items) do
			if item.update and item:is_active() then
				item:update(t, dt)
			end
		end
	end

	function HUDList.ListBase:register_item(name, class, ...)
		if not self._items[name] then
			class = type(class) == "string" and _G.HUDList[class] or class
			local new_item = class and class:new(self, name, ...)
			
			if new_item then
				if self._item_fade_time then
					new_item:set_fade_time(self._item_fade_time)
				end
				if self._item_move_speed then
					new_item:set_move_speed(self._item_move_speed)
				end
				new_item:post_init(...)
				self:_set_default_item_position(new_item)
			end
			
			self._items[name] = new_item
		end
		
		return self._items[name]
	end

	function HUDList.ListBase:unregister_item(name, instant)
		if self._items[name] then
			self._items[name]:delete(instant)
		end
	end

	function HUDList.ListBase:set_static_item(class, ...)
		self:delete_static_item()
		
		if type(class) == "string" then
			class = _G.HUDList[class]
		end
		
		self._static_item = class and class:new(self, "static_list_item", ...)
		if self._static_item then
			self:setup_static_item()
			self._static_item:panel():show()
			self._static_item:panel():set_alpha(1)
		end
		
		return self._static_item
	end

	function HUDList.ListBase:delete_static_item()
		if self._static_item then
			self._static_item:delete(true)
			self._static_item = nil
		end
	end

	function HUDList.ListBase:set_item_visible(item, visible)
		local index
		for i, shown_item in ipairs(self._shown_items) do
			if shown_item == item then
				index = i
				break
			end
		end
	
		--local threshold = self._static_item and 1 or 0	--TODO
	
		if visible and not index then
			if #self._shown_items <= 0 then
				self:activate()
			end
			
			local insert_index = #self._shown_items + 1
			if item:priority() then
				for i, list_item in ipairs(self._shown_items) do
					if not list_item:priority() or (list_item:priority() > item:priority()) then
						insert_index = i
						break
					end
				end
			end
			
			table.insert(self._shown_items, insert_index, item)
		elseif not visible and index then
			table.remove(self._shown_items, index)
			if #self._shown_items <= 0 then
				managers.enemy:add_delayed_clbk("visibility_cbk_" .. self._name, callback(self, self, "_cbk_update_visibility"), Application:time() + item:fade_time())
				--self:deactivate()
			end
		else
			return
		end
		
		self:_update_item_positions(item)
	end
	
	function HUDList.ListBase:set_item_hidden(item, hidden)
		self:_update_item_positions(nil, true)
	end
	
	function HUDList.ListBase:_cbk_update_visibility()
		if #self._shown_items <= 0 then
			self:deactivate()
		end
	end
	
	function HUDList.ListBase:_remove_item(item)
		self._items[item:name()] = nil
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.HorizontalList = HUDList.HorizontalList or class(HUDList.ListBase)
	function HUDList.HorizontalList:init(parent, name, params)
		params.align = params.align == "top" and "top" or params.align == "bottom" and "bottom" or "center"
		HUDList.HorizontalList.super.init(self, parent, name, params)
		self._left_to_right = params.left_to_right
		self._right_to_left = params.right_to_left and not self._left_to_right
		self._centered = params.centered and not (self._right_to_left or self._left_to_right)
	end

	function HUDList.HorizontalList:_set_default_item_position(item)
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		item:panel():set_top(y)
	end
	
	function HUDList.HorizontalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:h() - item:panel():h()
		local y = item:align() == "top" and 0 or item:align() == "bottom" and offset or offset / 2
		local x = self._left_to_right and 0 or self._panel:w() - item:panel():w()
		item:panel():set_left(x)
		item:panel():set_top(y)
		self:_update_item_positions()
	end
	
	function HUDList.HorizontalList:_update_item_positions(insert_item, instant_move)
		if self._centered then
			local total_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					total_width = total_width + item:panel():w() + self._item_margin
				end
			end
			total_width = total_width - self._item_margin
			
			local left = (self._panel:w() - math.min(total_width, self._panel:w())) / 2
			
			if self._static_item then
				self._static_item:move(left, item:panel():y(), instant_move)
				left = left + self._static_item:panel():w() + self._item_margin
			end
			
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					if insert_item and item == insert_item then
						if item:panel():x() ~= left then
							item:panel():set_x(left - item:panel():w() / 2)
							item:move(left, item:panel():y(), instant_move)
						end
					else
						item:move(left, item:panel():y(), instant_move)
					end
					left = left + item:panel():w() + self._item_margin
				end
			end
		else
			local prev_width = self._static_item and (self._static_item:panel():w() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					local width = item:panel():w()
					local new_x = (self._left_to_right and prev_width) or (self._panel:w() - (width+prev_width))
					if insert_item and item == insert_item then
						item:panel():set_x(new_x)
						item:cancel_move()
					else
						item:move(new_x, item:panel():y(), instant_move)
					end
					
					prev_width = prev_width + width + self._item_margin
				end
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	HUDList.VerticalList = HUDList.VerticalList or class(HUDList.ListBase)
	function HUDList.VerticalList:init(parent, name, params)
		params.align = params.align == "left" and "left" or params.align == "right" and "right" or "center"
		HUDList.VerticalList.super.init(self, parent, name, params)
		self._top_to_bottom = params.top_to_bottom
		self._bottom_to_top = params.bottom_to_top and not self._top_to_bottom
		self._centered = params.centered and not (self._bottom_to_top or self._top_to_bottom)
	end

	function HUDList.VerticalList:_set_default_item_position(item)
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		item:panel():set_left(x)
	end

	function HUDList.VerticalList:setup_static_item()
		local item = self._static_item
		local offset = self._panel:w() - item:panel():w()
		local x = item:align() == "left" and 0 or item:align() == "right" and offset or offset / 2
		local y = self._top_to_bottom and 0 or self._panel:h() - item:panel():h()
		item:panel():set_left(x)
		item:panel():set_y(y)
		self:_update_item_positions()
	end
	
	function HUDList.VerticalList:_update_item_positions(insert_item, instant_move)
		if self._centered then
			local total_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					total_height = total_width + item:panel():h() + self._item_margin
				end
			end
			total_height = total_height - self._item_margin
			
			local top = (self._panel:h() - math.min(total_height, self._panel:h())) / 2
			
			if self._static_item then
				self._static_item:move(item:panel():x(), top, instant_move)
				top = top + self._static_item:panel():h() + self._item_margin
			end
			
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					if insert_item and item == insert_item then
						if item:panel():y() ~= top then
							item:panel():set_y(top - item:panel():h() / 2)
							item:move(item:panel():x(), top, instant_move)
						end
					else
						item:move(item:panel():x(), top, instant_move)
					end
					top = top + item:panel():h() + self._item_margin
				end
			end
		else
			local prev_height = self._static_item and (self._static_item:panel():h() + self._item_margin) or 0
			for i, item in ipairs(self._shown_items) do
				if not item:hidden() then
					local height = item:panel():h()
					local new_y = (self._top_to_bottom and prev_height) or (self._panel:h() - (height+prev_height))
					if insert_item and item == insert_item then
						item:panel():set_y(new_y)
						item:cancel_move()
					else
						item:move(item:panel():x(), new_y, instant_move)
					end
					prev_height = prev_height + height + self._item_margin
				end
			end
		end
	end
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--LIST ITEM CLASS DEFINITION BLOCK
	
	--Right list
	
	HUDList.RightListItem = HUDList.RightListItem or class(HUDList.ItemBase)
	function HUDList.RightListItem:init(parent, name, icon, params)
		params = params or {}
		params.align = params.align or "right"
		params.w = params.w or parent:panel():h() / 2
		params.h = params.h or parent:panel():h()
		HUDList.RightListItem.super.init(self, parent, name, params)
		local x, y = unpack(icon.atlas or icon.spec or { 0, 0 })
		local texture = icon.texture
			or icon.spec and "guis/textures/pd2/specialization/icons_atlas" 
			or icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" 
			or icon.waypoints and "guis/textures/pd2/pd2_waypoints"
			or icon.hudtabs and "guis/textures/pd2/hud_tabs"
			or icon.hudpickups and "guis/textures/pd2/hud_pickups"
			or icon.hudicons and "guis/textures/hud_icons"
		local texture_rect = (icon.spec or icon.atlas) and { x * 64, y * 64, 64, 64 } or icon.waypoints or icon.hudtabs or icon.hudpickups or icon.hudicons or icon.texture_rect
		
		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			h = self._panel:w() * (icon.h_ratio or 1),
			w = self._panel:w() * (icon.w_ratio or 1),
			alpha = icon.alpha or 1,
			blend_mode = icon.blend_mode or "normal",
			color = icon.color or RightListColor or Color.white,
		})
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:w(),
			}, {color = RightListColor, bg_color =  RightListBgColor})
		self._box:set_bottom(self._panel:bottom())
		
		self._text = self._box:text({
			name = "text",
			text = "",
			align = "center",
			vertical = "center",
			w = self._box:w(),
			h = self._box:h(),
			color = RightListColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6
		})
		
		self._listener_clbks = {}
		self._count = 0
	end
	
	function HUDList.RightListItem:post_init()
		for i, data in ipairs(self._listener_clbks) do
			data.server.register_listener_clbk(data.name, data.event, data.clbk)
		end
	end
	
	function HUDList.RightListItem:destroy()
		for i, data in ipairs(self._listener_clbks) do
			data.server.unregister_listener_clbk(data.name, data.event)
		end

		HUDList.RightListItem.super.destroy(self)
	end
	
	function HUDList.RightListItem:change_count(diff)
		self:set_count(self._count + diff)
	end
	
	function HUDList.RightListItem:set_count(num)
		self._count = num
		self._text:set_text(tostring(self._count))
		self:set_active(self._count > 0)
	end
	
	HUDList.UnitCountItem = HUDList.UnitCountItem or class(HUDList.RightListItem)
	HUDList.UnitCountItem.MAP = {
		enemies =		{ atlas = {0, 5},  color = enemy_color, --[[subtract = { "cop_hostage", "minions" }]] },	--Aggregated enemies
		cop =			{ atlas = {0, 5},  color = enemy_color, priority = 5, --[[subtract = { "cop_hostage", "minions" }]] },	--Non-special police
		security =		{ spec = {1, 4},   color = guard_color, priority = 4 },
		thug =			{ atlas = {4, 12}, color = thug_color, priority = 4 },
		tank =			{ atlas = {3, 1},  color = special_color, priority = 6 },
		spooc =			{ atlas = {1, 3},  color = special_color, priority = 6 },
		taser =			{ atlas = {3, 5},  color = special_color, priority = 6 },
		shield =		{ texture = "guis/textures/pd2/hud_buff_shield", color = special_color, priority = 6 },
		sniper =		{ atlas = {6, 5},  color = special_color, priority = 6 },
		thug_boss =		{ atlas = {1, 1},  color = thug_color, priority = 4 },
		phalanx =		{ texture = "guis/textures/pd2/hud_buff_shield", color = special_color, priority = 7 },
		
		turret =		{ atlas = {7, 5},  color = turret_color, priority = 4 },
		unique =		{ atlas = {3, 8},  color = civilian_color, priority = 3, },
		cop_hostage =	{ atlas = {2, 8},  color = hostage_color, priority = 2 },
		civ_hostage =	{ atlas = {4, 7},  color = hostage_color, priority = 1 },
		minion =		{ atlas = {6, 8},  color = hostage_color, priority = 0 },
		civ =			{ atlas = {6, 7},  color = civilian_color, priority = 3, subtract = { "civ_hostage" } },
	}
	function HUDList.UnitCountItem:init(parent, name, unit_type, unit_category, subtract_type, unit_data)
		local unit_data = unit_data or HUDList.UnitCountItem.MAP[unit_type]
		local params = { priority = unit_data.priority }
		
		HUDList.UnitCountItem.super.init(self, parent, name, unit_data, params)
		
		self._unit_type = unit_type
		self._unit_category = unit_category
		self._subtract_types = unit_data.subtract
		
		if self._unit_type == "shield" then	--Shield special case for filling the shield icon
			self._shield_filler = self._panel:rect({
				name = "shield_filler",
				w = self._icon:w() * 0.4,
				h = self._icon:h() * 0.4,
				color = special_color,
				blend_mode = "normal",
				layer = self._icon:layer() - 1,
			})
			self._shield_filler:set_center(self._icon:center())
		end
		
		--TODO: Fetch currently spawned units for mid-heist enabling
	end
	
	function HUDList.UnitCountItem:set_count(num)
		if self._subtract_types then
			local subtract = 0
			
			for _, id in pairs(self._subtract_types) do
				subtract = subtract + (managers.gameinfo:get_unit_count(id) or 0)
			end
		
			self._count = num
			local adjusted = self._count - subtract
			self._text:set_text(tostring(adjusted))
			self:set_active(adjusted > 0)
		else
			HUDList.UnitCountItem.super.set_count(self, num)
		end
	end
	

	HUDList.UsedPagersItem = HUDList.UsedPagersItem or class(HUDList.RightListItem)
	function HUDList.UsedPagersItem:init(parent, name)
		HUDList.UsedPagersItem.super.init(self, parent, name, { spec = {1, 4} })
		local pager_count = table.size(managers.gameinfo:get_pagers() or {})
		self:set_count(pager_count)
	end
	
	function HUDList.UsedPagersItem:set_count(num)
		HUDList.UsedPagersItem.super.set_count(self, num)
		
		if self._count >= 5 then
			self._text:set_color(Color.red)
		end
	end
	
	function HUDList.UsedPagersItem:get_count()
		return self._count or 0
	end

	HUDList.SpecialPickupItem = HUDList.SpecialPickupItem or class(HUDList.RightListItem)
	HUDList.SpecialPickupItem.MAP = {
		crowbar =					{ hudpickups = { 0, 64, 32, 32 } },
		keycard =					{ hudpickups = { 32, 0, 32, 32 } },
		small_loot = 				{ hudpickups = { 32, 224, 32, 32} },
		courier = 					{ atlas = { 6, 0 } },
		planks =					{ hudpickups = { 0, 32, 32, 32 } },
		meth_ingredients =			{ waypoints = { 192, 32, 32, 32 } },
		blowtorch = 				{ hudpickups = { 96, 192, 32, 32 } },
		thermite = 					{ hudpickups = { 64, 64, 32, 32 } },
	}
	function HUDList.SpecialPickupItem:init(parent, name, pickup_data)
		HUDList.SpecialPickupItem.super.init(self, parent, name, pickup_data or HUDList.SpecialPickupItem.MAP[name])
	end
	
	
	HUDList.LootItem = HUDList.LootItem or class(HUDList.RightListItem)
	HUDList.LootItem.MAP = {
		aggregate =		{ text = "" },	--Aggregated loot
		armor =			{ text = "Armor" },
		artifact =		{ text = "Artifact" },
		bomb =			{ text = "Bomb" },
		coke =			{ text = "Coke" },
		dentist =		{ text = "Unknown" },
		diamond =		{ text = "Diamond" },
		evidence =		{ text = "Evidence" },
		goat =			{ text = "Goat" },
		gold =			{ text = "Gold" },
		jewelry =		{ text = "Jewelry" },
		meth =			{ text = "Meth" },
		money =			{ text = "Money" },
		painting =		{ text = "Painting" },
		pig =			{ text = "Pig" },
		present =		{ text = "Present" },
		prototype =		{ text = "Prototype" },
		safe =			{ text = "Safe" },
		server =		{ text = "Server" },
		shell =			{ text = "Shell" },
		toast =			{ text = "Toast" },
		turret =		{ text = "Turret" },
		warhead =		{ text = "Warhead" },
		weapon =		{ text = "Weapon" },
	}
	function HUDList.LootItem:init(parent, name, loot_data)
		local loot_data = loot_data or HUDList.LootItem.MAP[name]
		HUDList.LootItem.super.init(self, parent, name, loot_data.icon_data or { hudtabs = { 32, 33, 32, 32 }, alpha = 0.75, w_ratio = 1.2 })
	
		self._icon:set_center(self._panel:center())
		self._icon:set_top(self._panel:top())

		if loot_data.text then
			self._name_text = self._panel:text({
				name = "text",
				text = string.sub(loot_data.text, 1, 6) or "",
				align = "center",
				vertical = "center",
				w = self._panel:w(),
				h = self._panel:w(),
				color = RightListBgColor or Color(0.0, 0.5, 0.0),
				blend_mode = "normal",
				font = tweak_data.hud_corner.assault_font,
				font_size = self._panel:w() * 0.4,
				layer = 10
			})
			self._name_text:set_center(self._icon:center())
			self._name_text:set_y(self._name_text:y() + self._icon:h() * 0.1)
		end

		self:set_count(0, 0)
	end
	
	function HUDList.LootItem:change_count(unbagged_diff, bagged_diff)
		self:set_count(self._count + (unbagged_diff or 0), self._bagged_count + (bagged_diff or 0))
	end
	
	function HUDList.LootItem:set_count(unbagged, bagged)
		self._count = unbagged
		self._bagged_count = bagged
		self._total = self._count + self._bagged_count
		
		if HUDListManager.ListOptions.separate_bagged_loot then
			self._text:set_text(self._count .. "/" .. self._bagged_count)
		else
			self._text:set_text(self._total)
		end
		
		self:set_active(self._total > 0)
	end
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Left list items
	
	HUDList.LeftListIcon = HUDList.LeftListIcon or class(HUDList.ItemBase)
	function HUDList.LeftListIcon:init(parent, name, ratio_w, ratio_h, icons)
		HUDList.ItemBase.init(self, parent, name, { align = "center", w = parent:panel():h() * (ratio_w or 1), h = parent:panel():h() * (ratio_h or 1) })
		
		self._icons = {}
		for i, icon in ipairs(icons) do
			local texture = icon.spec and "guis/textures/pd2/specialization/icons_atlas" 
				or icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" 
				or icon.waypoints and "guis/textures/pd2/pd2_waypoints"
				or icon.texture
		
			local bitmap = self._panel:bitmap({
				name = "icon_" .. tostring(i),
				texture = texture,
				texture_rect = icon.texture_rect or nil,
				h = self:panel():w() * (icon.h or 1),
				w = self:panel():w() * (icon.w or 1),
				blend_mode = "add",
				color = icon.color or Color.white,
			})
			
			bitmap:set_center(self._panel:center())
			if icon.valign == "top" then 
				bitmap:set_top(self._panel:top())
			elseif icon.valign == "bottom" then 
				bitmap:set_bottom(self._panel:bottom())
			end
			if icon.halign == "left" then
				bitmap:set_left(self._panel:left())
			elseif icon.halign == "right" then
				bitmap:set_right(self._panel:right())
			end
		
			table.insert(self._icons, bitmap)
		end
	end
	
	HUDList.TimerItem = HUDList.TimerItem or class(HUDList.ItemBase)
	HUDList.TimerItem.STANDARD_COLOR = TimerColor or Color(1, 1, 1, 1)
	HUDList.TimerItem.UPGRADE_COLOR = Color(1, 0.0, 0.8, 1.0)
	HUDList.TimerItem.DISABLED_COLOR = Color(1, 1, 0, 0)
	HUDList.TimerItem.FLASH_SPEED = 2
	HUDList.TimerItem.DEVICE_TYPES = {
		digital = "Timer", 
		drill = "Drill",
		hack = "Hack",
		saw = "Saw",
		timer = "Timer", 
		securitylock = "Hack",
	}
	function HUDList.TimerItem:init(parent, name, timer_data)
		HUDList.ItemBase.init(self, parent, name, { align = "left", w = parent:panel():h() * 4/5, h = parent:panel():h() })
		
		self._show_distance = true
		self._unit = timer_data.unit
		self._device_type = timer_data.device_type
		self._jammed = timer_data.jammed
		self._powered = timer_data.powered
		self._upgradable = timer_data.upgradable
		
		self._type_text = self._panel:text({
			name = "type_text",
			text = self.DEVICE_TYPES[self._device_type] or "Timer",
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:h() * 0.3,
            color = TimerColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 1/3
		})
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h() * 0.7,
			}, { color = TimerColor, bg_color = TimerBgColor })
		self._box:set_bottom(self._panel:bottom())
		
		self._distance_text = self._box:text({
			name = "distance",
			align = "center",
			vertical = "top",
			w = self._box:w(),
			h = self._box:h(),
            color = TimerColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.4
		})
		
		self._time_text = self._box:text({
			name = "time",
			align = "center",
			vertical = "bottom",
			w = self._box:w(),
			h = self._box:h(),
            color = TimerColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6
		})
		
		local current_color = self._upgradable and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = current_color }
		}
		self:_set_colors(current_color)
		
		if timer_data.t and timer_data.timer then
			self:update_timer(timer_data.t, timer_data.timer)
		end
	end
	
	function HUDList.TimerItem:update(t, dt)
		if not alive(self._unit) then
			self:delete()
			return
		end
		
		local player = managers.player:player_unit()
		local distance = alive(player) and (mvector3.normalize(player:position() - self._unit:position()) / 100) or 0
		self._distance_text:set_text(string.format("%.0fm", distance))
		
		if self._jammed or not self._powered then
			local new_color = self:_get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
			self:_set_colors(new_color)
		end
	end
	
	function HUDList.TimerItem:update_timer(t, time_left)
		self._remaining = time_left
		self._time_text:set_text(format_time_string(self._remaining))
	end
	
	function HUDList.TimerItem:set_jammed(status)
		self._jammed = status
		self:_check_is_running()
	end
	
	function HUDList.TimerItem:set_powered(status)
		self._powered = status
		self:_check_is_running()
	end
	
	function HUDList.TimerItem:set_upgradable(status)
		self._upgradable = status
		local current_color = self._upgradable and self.UPGRADE_COLOR or self.STANDARD_COLOR
		self._flash_color_table[2].color = current_color
		self:_set_colors(current_color)
	end
	
	function HUDList.TimerItem:_check_is_running()
		if not self._jammed and self._powered then
			self:_set_colors(self._flash_color_table[2].color)
		end
	end
	
	function HUDList.TimerItem:_set_colors(color)
		self._time_text:set_color(color)
		self._type_text:set_color(color)
		self._distance_text:set_color(color)
	end
	
	
	HUDList.TemperatureGaugeItem = HUDList.TemperatureGaugeItem or class(HUDList.TimerItem)
	function HUDList.TemperatureGaugeItem:init(parent, name, timer_data, params)
		self._start = params.start
		self._goal = params.goal
		self._last_value = self._start
		
		HUDList.TimerItem.init(self, parent, name, timer_data)
		
		self._type_text:set_text("Temp")
	end
	
	function HUDList.TemperatureGaugeItem:update(t, dt)
	
	end
	
	function HUDList.TemperatureGaugeItem:update_timer(t, value)
		--local ratio = math.clamp((value - self._start) / (self._goal - self._start), 0, 1) * 100
		local dv = math.abs(self._last_value - value)
		local estimate = "n/a"
		
		if dv > 0 then
			local time_left = math.round(math.abs(self._goal - value) / dv)
			estimate = format_time_string(time_left)
		end
	
		--self._distance_text:set_text(string.format("%.0f%%", ratio))
		self._distance_text:set_text(string.format("%d / %d", value, self._goal))
		self._time_text:set_text(estimate)
		self._last_value = value
	end
	
	
	HUDList.EquipmentItem = HUDList.EquipmentItem or class(HUDList.ItemBase)
	HUDList.EquipmentItem.EQUIPMENT_TABLE = {
		sentry = {				atlas = { 7, 5 }, priority = 1 },
		ammo_bag = {		atlas = { 1, 0 }, priority = 3 },
		doc_bag = {			atlas = { 2, 7 }, priority = 4 },
		body_bag = {			atlas = { 5, 11 }, priority = 5 },
		grenade_crate = {	preplanning = { 1, 0 }, priority = 2 },
	}
	function HUDList.EquipmentItem:init(parent, name, equipment_type, unit, owner)
		local data = HUDList.EquipmentItem.EQUIPMENT_TABLE[equipment_type]
		
		HUDList.ItemBase.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h(), priority = data.priority })

		self._unit = unit
		self._type = equipment_type
		local texture = data.atlas and "guis/textures/pd2/skilltree/icons_atlas" or data.preplanning and "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types"
		local x, y = unpack((data.atlas or data.preplanning) or { 0, 0 })
		local w = data.atlas and 64 or data.preplanning and 48
		local texture_rect = (data.atlas or data.preplanning) and { x * w, y * w, w, w }
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, { color = EquipmentColor, bg_color = EquipmentBgColor })
		
		self._icon = self._panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			h = self:panel():w() * 0.8,
			w = self:panel():w() * 0.8,
			blend_mode = "add",
			layer = 0,
			color = EquipmentColor or Color.white,
		})
		self._icon:set_center(self._panel:center())
		self._icon:set_top(self._panel:top())
		
		self._info_text = self._panel:text({
			name = "info",
			text = "",
			align = "center",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:h() * 0.4,
			color = Color.white,
			layer = 1,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:h() * 0.4,
		})
		self._info_text:set_bottom(self._panel:bottom())
		
		self:set_owner(owner)
	end
	
	function HUDList.EquipmentItem:set_owner(peer_id)
		if peer_id then
			self._owner = peer_id
			self:_set_color()
		end
	end
	
	function HUDList.EquipmentItem:get_type()
		return self._type
	end
	
	function HUDList.EquipmentItem:_set_color()
		if self._owner then
			local color = self._owner > 0 and tweak_data.chat_colors[self._owner]:with_alpha(1) or Color.white
			self._icon:set_color(color)
		end
	end
	
	
	HUDList.BagEquipmentItem = HUDList.BagEquipmentItem or class(HUDList.EquipmentItem)
	function HUDList.BagEquipmentItem:init(parent, name, data)
		HUDList.EquipmentItem.init(self, parent, name, data.type, data.unit, data.owner)
		
		self._amount_format = "%.0f" .. (data.type == "ammo_bag" and "%%" or "")
		self._amount_offset = 0
		self:set_max_amount(data.max_amount)
		self:set_amount(data.amount)
		self:set_amount_offset(data.amount_offset)
	end
	
	function HUDList.BagEquipmentItem:current_amount()
		return self._current_amount
	end
	
	function HUDList.BagEquipmentItem:set_max_amount(max_amount)
		self._max_amount = (max_amount or 0)
		self:_update_info_text()
	end
	
	function HUDList.BagEquipmentItem:set_amount(amount)
		self._current_amount = (amount or 0)
		self:_update_info_text()
	end
	
	function HUDList.BagEquipmentItem:set_amount_offset(offset)
		self._amount_offset = offset or 0
		self:set_max_amount(self._max_amount)
		self:set_amount(self._current_amount)
	end
	
	function HUDList.BagEquipmentItem:_update_info_text()
		if self._current_amount and self._max_amount then
			self._info_text:set_text(string.format(self._amount_format, self._current_amount + self._amount_offset))
			self._info_text:set_color(self:_get_color_from_table(self._current_amount, self._max_amount + self._amount_offset))
		end
	end
	
	
	HUDList.SentryEquipmentItem = HUDList.SentryEquipmentItem or class(HUDList.EquipmentItem)
	function HUDList.SentryEquipmentItem:init(parent, name, data)
		HUDList.EquipmentItem.init(self, parent, name, "sentry", data.unit)
		self:set_owner(data.owner)
		self:set_ammo_ratio(data.ammo_ratio)
		self:set_health_ratio(data.health_ratio)
	end
	
	function HUDList.SentryEquipmentItem:set_ammo_ratio(ratio)
		self._ammo_ratio = ratio or 0
		self._info_text:set_text(string.format("%.0f%%", self._ammo_ratio * 100))
	end
	
	function HUDList.SentryEquipmentItem:set_health_ratio(ratio)
		self._health_ratio = ratio or 0
		self._info_text:set_color(self:_get_color_from_table(self._health_ratio, 1))
	end
	
	
	HUDList.MinionItem = HUDList.MinionItem or class(HUDList.ItemBase)
	function HUDList.MinionItem:init(parent, name, unit)
		HUDList.MinionItem.super.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h() })
		
		self._unit = unit
		self._max_health = unit:character_damage()._HEALTH_INIT
		local type_string = HUDListManager.UNIT_TYPES[unit:base()._tweak_table] and
			HUDListManager.UNIT_TYPES[unit:base()._tweak_table].long_name or "UNDEF"
	
		self._health_bar = self._panel:bitmap({
			name = "radial_health",
			texture = "guis/textures/pd2/hud_health",
			texture_rect = { 64, 0, -64, 64 },
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 2,
			color = Color(1, 1, 0, 0),
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._health_bar:set_bottom(self._panel:bottom())
		
		if WolfHUD:getSetting("colorize_healthbars", "boolean") > 1 then
			self._health_bar:set_color(Color(1, 0, 0, 0))
			self._health_bar:set_blend_mode("sub")
			self._panel:bitmap({
				name = "radial_health_fill",
				color = tweak_data.chat_colors[1],
				texture = "guis/textures/pd2/hud_health",
				texture_rect = { 64, 0, -64, 64 },
				blend_mode = "add",
				w = self._panel:w(),
				h = self._panel:w(),
				alpha = 1,
				layer = 1
			}):set_bottom(self._panel:bottom())
		end
		
		self._hit_indicator = self._panel:bitmap({
			name = "radial_health",
			texture = "guis/textures/pd2/hud_radial_rim",
			blend_mode = "add",
			layer = 1,
			color = Color.red,
			alpha = 0,
			w = self._panel:w(),
			h = self._panel:w(),
		})
		self._hit_indicator:set_center(self._health_bar:center())

		self._outline = self._panel:bitmap({
			name = "outline",
			texture = "guis/textures/pd2/hud_shield",
			texture_rect = { 64, 0, -64, 64 },
			--render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			w = self._panel:w() * 0.95,
			h = self._panel:w() * 0.95,
			layer = 1,
			alpha = 0,
			color = Color(0.8, 0.8, 1.0),
		})
		self._outline:set_center(self._health_bar:center())
		
		self._damage_upgrade_text = self._panel:text({
			name = "type",
			text = utf8.char(57364),
			align = "center",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:w(),
			color = Color.white,
			layer = 3,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:w() * 0.4,
			alpha  = 0.5
		})
		self._damage_upgrade_text:set_bottom(self._panel:bottom())
		
		self._unit_type = self._panel:text({
			name = "type",
			text = type_string,
			align = "center",
			vertical = "top",
			w = self._panel:w(),
			h = self._panel:w() * 0.3,
			color = Color.white,
			layer = 3,
			font = tweak_data.hud_corner.assault_font,
			font_size = math.min(8 / string.len(type_string), 1) * 0.25 * self._panel:h(),
		})
		
		self._kills = self._panel:text({
			name = "kills",
			text = "0",
			align = "right",
			vertical = "bottom",
			w = self._panel:w(),
			h = self._panel:w(),
			color = Color.white,
			layer = 10,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._panel:w() * 0.3,
		})
		self._kills:set_center(self._health_bar:center())

		self:set_health(self._max_health, true)
	end
	
	function HUDList.MinionItem:set_health(health, skip_animate)
		local red = health/ self._max_health
		if WolfHUD:getSetting("colorize_healthbars", "boolean") > 1 then
			red = 1 - red
			self._health_bar:set_rotation(360 * red)
		end
		self._health_bar:set_color(Color(1, red, 1, 1))
                   
        if not (skip_animate or self._dead) then
            self._hit_indicator:stop()
            self._hit_indicator:animate(callback(self, self, "_animate_damage"))
        end
	end
	
	function HUDList.MinionItem:set_owner(peer_id)
		self._unit_type:set_color(peer_id and tweak_data.chat_colors[peer_id]:with_alpha(1) or Color(1, 1, 1, 1))
	end
	
	function HUDList.MinionItem:set_health_multiplier(mult)
		local max_mult = tweak_data.upgrades.values.player.convert_enemies_health_multiplier[1] * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[2]
		local alpha = math.clamp(1 - (mult - max_mult) / (1 - max_mult), 0, 1) * 0.8 + 0.2
		self._outline:set_alpha(alpha)
	end
	
	function HUDList.MinionItem:set_damage_multiplier(mult)
		self._damage_upgrade_text:set_alpha(mult > 1 and 1 or 0.5)
	end
	
	function HUDList.MinionItem:set_kills(amount)
		self._kills:set_text(amount)
	end
	
	function HUDList.MinionItem:_animate_damage(icon)
		local duration = 1
		local t = duration
		icon:set_alpha(1)
		
		while t > 0 do
			local dt = coroutine.yield()
			t = math.clamp(t - dt, 0, duration)
			icon:set_alpha(t/duration)
		end
		
		icon:set_alpha(0)
	end
	
	
	HUDList.PagerItem = HUDList.PagerItem or class(HUDList.ItemBase)
	function HUDList.PagerItem:init(parent, name, unit)
		HUDList.PagerItem.super.init(self, parent, name, { align = "left", w = parent:panel():h(), h = parent:panel():h() })
		
		self._unit = unit
		self._max_duration_t = 12
		self._duration_t = self._max_duration_t
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, { color = PagerColor, bg_color = PagerbgColor })

		self._timer_text = self._box:text({
			name = "time",
			align = "center",
			vertical = "top",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.red,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.5,
		})
		
		self._distance_text = self._box:text({
			name = "distance",
			align = "center",
			vertical = "bottom",
			w = self._box:w(),
			h = self._box:h(),
			color = PagerColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.5,
			text = "DIST"
		})
	end
	
	function HUDList.PagerItem:set_duration(duration_t)
		self._duration_t = duration_t
	end
	
	function HUDList.PagerItem:set_answered()
		if not self._answered then
			self._answered = true
			self._timer_text:set_color(Color(1, 0.1, 0.9, 0.1))
		end
	end
	
	function HUDList.PagerItem:update(t, dt)
		if not self._answered then
			self._duration_t = math.max(self._duration_t - dt, 0)
			self._timer_text:set_text(format_time_string(self._duration_t))
			self._timer_text:set_color(self:_get_color_from_table(self._duration_t, self._max_duration_t))
		end

		local distance = 0
		if alive(self._unit) and alive(managers.player:player_unit()) then
			distance = mvector3.normalize(managers.player:player_unit():position() - self._unit:position()) / 100
		end
		self._distance_text:set_text(string.format("%.0fm", distance))
	end	
	
	
	HUDList.ECMItem = HUDList.ECMItem or class(HUDList.ItemBase)
	function HUDList.ECMItem:init(parent, name)
		HUDList.ItemBase.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })
		
		self._max_duration = tweak_data.upgrades.ecm_jammer_base_battery_life * 
			tweak_data.upgrades.values.ecm_jammer.duration_multiplier[1] * 
			tweak_data.upgrades.values.ecm_jammer.duration_multiplier_2[1]
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, { color = ECMColor, bg_color = ECMBgColor })
		
		self._text = self._box:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._box:w(),
			h = self._box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6,
		})
	end
	
	function HUDList.ECMItem:update_timer(time_left)
		self._text:set_text(format_time_string(time_left))
		self._text:set_color(self:_get_color_from_table(time_left, self._max_duration))
	end
	
	
	HUDList.ECMRetriggerItem = HUDList.ECMRetriggerItem or class(HUDList.ECMItem)
	function HUDList.ECMRetriggerItem:init(parent, name)
		HUDList.ECMRetriggerItem.super.init(self, parent, name)
		
		self._max_duration = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
	end
	
	function HUDList.ECMRetriggerItem:update_timer(time_left)
		self._text:set_text(format_time_string(time_left))
		self._text:set_color(self:_get_color_from_table(self._max_duration - time_left, self._max_duration))
	end
	
	
	HUDList.TapeLoopItem = HUDList.TapeLoopItem or class(HUDList.ItemBase)
	HUDList.TapeLoopItem = HUDList.TapeLoopItem or class(HUDList.ItemBase)
    HUDList.TapeLoopItem.STANDARD_COLOR = Color(1, 1, 1, 1)
    HUDList.TapeLoopItem.DISABLED_COLOR = Color(1, 1, 0, 0)
    HUDList.TapeLoopItem.FLASH_SPEED = 0.8
	function HUDList.TapeLoopItem:init(parent, name, unit)
		HUDList.TapeLoopItem.super.init(self, parent, name, { align = "right", w = parent:panel():h(), h = parent:panel():h() })
		
		self._unit = unit
		self._flash_color_table = {
			{ ratio = 0.0, color = self.DISABLED_COLOR },
			{ ratio = 1.0, color = self.STANDARD_COLOR }
        }
		
		self._box = HUDBGBox_create(self._panel, {
				w = self._panel:w(),
				h = self._panel:h(),
			}, { color = TapeLoopColor, bg_color = TapeLoopBgColor })
		
		self._text = self._box:text({
			name = "text",
			align = "center",
			vertical = "center",
			w = self._box:w(),
			h = self._box:h(),
			color = TapeLoopColor or Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = self._box:h() * 0.6,
		})
	end
	
	function HUDList.TapeLoopItem:set_duration(duration)
		self._duration = duration
		
		self._text:set_text(format_time_string(self._duration))
		if self._duration <= 0 then
			self:delete()
		end
	end
	
	function HUDList.TapeLoopItem:update(t, dt)
		self:set_duration(math.max(self._duration - dt, 0))
		if self._duration < 6 then
			local new_color = self:_get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
            self._text:set_color(new_color)
		else
			self._text:set_color(TapeLoopColor)
        end
	end
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--Buff list
	
	HUDList.BuffItemBase = HUDList.BuffItemBase or class(HUDList.ItemBase)
	HUDList.BuffItemBase.ICON_COLORS = {
		buff = {
			icon = Color.white,
			flash = Color.red,
			bg = Color(0.75, 1, 1, 1),
			aced_icon = Color.white,
			--level_icon = Color(0.4, 0, 1, 0),
		},
		team = {
			icon = Color.white,
			flash = Color.red,
			bg = Color(0.5, 0.2, 1, 0.2),
			aced_icon = Color.white,
			--level_icon = Color(0.4, 0, 1, 0),
		},
		debuff = {
			icon = Color.white,
			flash = Color.red,
			bg = Color(1, 0, 0),
			aced_icon = Color.white,
			--level_icon = Color(0.4, 0, 1, 0),
		},
	}
	
	HUDList.BuffItemBase.BUFF_MAP = {
		hostage_situation = {
			spec = { 0, 1 },
			priority = 2,
			type = "buff"
		},
		partner_in_crime = {
			atlas = { 1, 10 },
			priority = 2,
			type = "buff"
		},
		hostage_taker = {
			atlas = { 2, 10 },
			priority = 2,
			type = "buff",	
			icon_scale = 1.35
		},
		underdog = {
			atlas = { 2, 1 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		overdog = {
			spec = { 6, 4 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		close_combat = {
			spec = { 5, 4 },
			priority = 3,
			type = "buff",	
			class = "TimedBuffItem"
		},
		combat_medic = {
			atlas = { 5, 7 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		overkill = {
			atlas = { 3, 2 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		bullet_storm = {
			atlas = { 4, 5 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		pain_killer = {
			atlas = { 0, 10 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		swan_song = {
			atlas = { 5, 12 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		quick_fix = {
			atlas = { 1, 11 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		trigger_happy = {
			atlas = { 7, 11 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		inspire = {
			atlas = { 4, 9 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		melee_stack_damage = {
			spec = { 5, 4 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		damage_to_hot = {
			spec = { 4, 6 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem"
		},
		sixth_sense = {
			atlas = { 6, 10 },
			priority = 3,
			type = "buff",
			class = "TimedBuffItem",
			flash_color = Color.blue,
			flash_speed = tweak_data.player.omniscience.interval_t * 0.5
		},
		bow_charge = {
			priority = 3,
			type = "buff",
			class = "ChargedBuffItem",
			texture = "guis/dlcs/west/textures/pd2/blackmarket/icons/weapons/plainsrider", 
			icon_rotation = 90, 
			icon_w_ratio = 0.5, 
			icon_scale = 2,
			flash_speed = 0.2,
			no_fade = true
		},
		melee_charge = {
			atlas = { 4, 10 },
			priority = 3,
			type = "buff",
			class = "ChargedBuffItem",
			flash_speed = 0.2,
			no_fade = true
		},
		berserker = {
			atlas = { 2, 2 },
			priority = 2,
			type = "buff",
			class = "BerserkerBuffItem"
		},
		crew_chief = {
			atlas = { 2, 7 },
			priority = 1,
			type = "team"
		},
		leadership = {
			atlas = { 7, 7 },
			priority = 1,
			type = "team"
		},
		bulletproof = {
			atlas = { 6, 4 },
			priority = 1,
			type = "team",
			aced = true,
		},
		armorer = {
			spec = { 6, 0 },
			priority = 1,
			type = "team",
			level = 9,
		},
		endurance = {
			atlas = { 1, 8 },
			priority = 1,
			type = "team",
			aced = true,
		},
		life_drain = {
			spec = { 7, 4 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem"
		},
		medical_supplies = {
			spec = { 4, 5 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem"
		},
		ammo_give_out = {
			spec = { 5, 5 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
		},
		inspire_debuff = {
			atlas = { 4, 9 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
		},
		bullseye_debuff = {
			atlas = { 6, 11 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
		},
		tension_debuff = {
			spec = { 0, 5 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
		},
		damage_to_hot_debuff = {
			spec = { 4, 6 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
		},
		armor_regen_debuff = {
			spec = { 6, 0 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
			no_fade = true,
		},
		suppression_debuff = {
			atlas = { 7, 0 },
			priority = 5,
			type = "debuff",
			class = "SuppressionBuffItem",
			flash_speed = 0.25,
			no_fade = true,
		},
		armor_break_invulnerable = {
			spec = { 6, 1 },
			priority = 5,
			type = "buff",
			class = "TimedBuffItem",
		},
		armor_break_invulnerable_debuff = {
			spec = { 6, 1 },
			priority = 5,
			type = "debuff",
			class = "TimedBuffItem",
			on_activate = function()
				local upgrade_value = managers.player:upgrade_value("temporary", "armor_break_invulnerable")
				
				managers.player:activate_timed_buff(
					"armor_break_invulnerable",
					upgrade_value and upgrade_value[1] or 0
				)
			end,
		}
	}
	
	HUDList.BuffItemBase.IGNORED_BUFFS = {
		suppression_debuff = true,
		hostage_taker = true,
		crew_chief = true,
		--hostage_situation = true,
		swan_song = true,
		damage_to_hot_debuff = true,
	}
	
	HUDList.BuffItemBase.COMPOSITE_ITEMS = {
		underdog_aced = {		item = "underdog",		keep_on_deactivation = true,
			aced = function() 
				return true
			end
		},
		leadership = {			item = "leadership",
			aced = function()
				return managers.player:has_team_category_upgrade("weapon", "recoil_multiplier") or managers.player:has_team_category_upgrade("weapon", "suppression_recoil_multiplier")
			end
		},
		crew_chief_3 = {		item = "crew_chief",
			level = function()
				if managers.player:has_team_category_upgrade("health", "hostage_multiplier") or managers.player:has_team_category_upgrade("stamina", "hostage_multiplier")  or managers.player:has_team_category_upgrade("damage_dampener", "hostage_multiplier") then
					return 9
				elseif managers.player:has_team_category_upgrade("armor", "multiplier") then
					return 7
				elseif managers.player:has_team_category_upgrade("health", "passive_multiplier") then
					return 5
				elseif managers.player:has_team_category_upgrade("stamina", "passive_multiplier") then
					return 3
				else
					return 0
				end
			end
		},
	}
	HUDList.BuffItemBase.COMPOSITE_ITEMS.leadership_aced = table.deep_map_copy(HUDList.BuffItemBase.COMPOSITE_ITEMS.leadership)
	HUDList.BuffItemBase.COMPOSITE_ITEMS.leadership_aced.keep_on_deactivation = true
	HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_5 = table.deep_map_copy(HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_3)
	HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_5.keep_on_deactivation = true
	HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_7 = table.deep_map_copy(HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_5)
	HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_9 = table.deep_map_copy(HUDList.BuffItemBase.COMPOSITE_ITEMS.crew_chief_5)
	
	function HUDList.BuffItemBase:init(parent, name, icon, w, h)
		HUDList.BuffItemBase.super.init(self, parent, name, { priority = icon.priority, align = "bottom", w = w or parent:panel():h(), h = h or parent:panel():h() })
		
		local x, y = unpack(icon.atlas or icon.spec or { 0, 0 })
		local texture = icon.atlas and "guis/textures/pd2/skilltree/icons_atlas" or icon.spec and "guis/textures/pd2/specialization/icons_atlas" or icon.texture
		local texture_rect = (icon.atlas or icon.spec) and { x * 64, y * 64, 64, 64 } or icon.rect
		
		self._icon = self._panel:bitmap({
				name = "icon",
				texture = texture,
				texture_rect = texture_rect,
				valign = "center",
				align = "center",
				h = self:panel():w() * 0.7 * (icon.icon_scale or 1) * (icon.icon_h_ratio or 1),
				w = self:panel():w() * 0.7 * (icon.icon_scale or 1) * (icon.icon_w_ratio or 1),
				blend_mode = "normal",
				layer = 0,
				color = icon.icon_color or HUDList.BuffItemBase.ICON_COLORS[icon.type].icon or Color.white,
				rotation = icon.icon_rotation or 0,
		})
		self._icon:set_center(self:panel():center())
		
		self._flash_icon = self._panel:bitmap({
				name = "flash_icon",
				texture = texture,
				texture_rect = texture_rect,
				valign = "center",
				align = "center",
				layer = 0,
				h = self._icon:h(),
				w = self._icon:w(),
				blend_mode = "normal",
				color = icon.flash_color or HUDList.BuffItemBase.ICON_COLORS[icon.type].flash or Color.blue,
				alpha = 0,
				rotation = icon.icon_rotation or 0,
		})
		self._flash_icon:set_center(self._icon:center())
		
		self._bg = self._panel:bitmap({
			name = "bg",
			texture = "guis/textures/pd2/skilltree/ace",
			texture_rect = { 37, 28, 54, 70 },
			valign = "center",
			align = "center",
			layer = 0,
			h = self._icon:h(),
			w = 0.8 * self._icon:w(),
			blend_mode = "normal",
			layer = -1,
			color = icon.bg_color or HUDList.BuffItemBase.ICON_COLORS[icon.type].bg or Color.white,
		})
		self._bg:set_center(self._icon:center())
		
		self._ace_icon = self._panel:bitmap({
			name = "ace_icon",
			texture = "guis/textures/pd2/infamous_symbol",
			texture_rect = { 2, 5, 12, 16 },
			w = 1.15 * 12 * self:panel():w()/45,
			h = 1.15 * 16 * self:panel():w()/45,
			blend_mode = "normal",
			valign = "center",
			align = "center",
			layer = 2,
			color = icon.aced_icon_color or HUDList.BuffItemBase.ICON_COLORS[icon.type].aced_icon or Color.white,
			visible = false,
		})
		
		self._level_bg = self._panel:bitmap({
			texture = "guis/textures/pd2/infamous_symbol",
			texture_rect = { 2, 5, 12, 16 },
			w = 1.15 * 12 * self:panel():w()/45,
			h = 1.15 * 16 * self:panel():w()/45,
			blend_mode = "normal",
			valign = "center",
			align = "center",
			layer = 2,
			color = icon.level_icon_color or HUDList.BuffItemBase.ICON_COLORS[icon.type].level_icon or Color.white,
			visible = false,
		})
		self._level_text = self._panel:text({
			name = "level_text",
			text = "",
			valign = "center",
			align = "center",
			vertical = "center",
			w = self._level_bg:w(),
			h = self._level_bg:h(),
			layer = 3,
			color = Color.black,
			blend_mode = "normal",
			font = tweak_data.hud.small_font,
			font_size = self._level_bg:h() * 0.75,
			visible = false,
		})
		self._level_text:set_top(self._level_bg:top())
		self._level_text:set_left(self._level_bg:left())
		
		self._stack_bg = self._panel:bitmap({
			w = 26 * self:panel():w()/45,
			h = 26 * self:panel():w()/45,
			blend_mode = "normal",
			texture = "guis/textures/pd2/equip_count",
			layer = 2,
			alpha = 0.8,
			visible = false
		})
		self._stack_bg:set_right(self._panel:w())
		self._stack_bg:set_bottom(self._panel:h())
		
		self._stack_text = self._panel:text({
			name = "stack_text",
			text = "",
			valign = "center",
			align = "center",
			vertical = "center",
			w = self._stack_bg:w(),
			h = self._stack_bg:h(),
			layer = 3,
			color = Color.black,
			blend_mode = "normal",
			font = tweak_data.hud.small_font,
			font_size = self._stack_bg:h() * 0.55,
			visible = false,
		})
		self._stack_text:set_center(self._stack_bg:center())
		
		self._flash_speed = icon.flash_speed
	end
	
	function HUDList.BuffItemBase:deactivate(...)
		HUDList.BuffItemBase.super.deactivate(self, ...)
		self:set_aced(false, true)
		self:set_level(0, true)
	end
	
	function HUDList.BuffItemBase:set_aced(status, override)
		if override then
			self._is_aced = status
		else
			self._is_aced = self._is_aced or status
		end
		self._ace_icon:set_visible(self._is_aced)
	end
	
	function HUDList.BuffItemBase:set_level(new_level, override)
		self._current_level = override and new_level or math.max(self._current_level or 0, new_level)
		self._level_text:set_text(tostring(self._current_level))
		self._level_bg:set_visible(self._current_level > 1)
		self._level_text:set_visible(self._current_level > 1)
	end
	
	function HUDList.BuffItemBase:set_stack_count(new_count, show_zero)
		if not show_zero and new_count <= 0 then
			self._stack_text:set_visible(false)
			self._stack_bg:set_visible(false)
			self._stack_text:set_text("")
		else
			self._stack_text:set_visible(true)
			self._stack_bg:set_visible(true)
			self._stack_text:set_text(tostring(new_count))
		end
	end
	
	function HUDList.BuffItemBase:set_flash(continuous)
		self:stop_flash()
		self._flash_icon:animate(callback(self, self, "_animate_flash"), self._flash_speed or 0.5, continuous)
	end
	
	function HUDList.BuffItemBase:stop_flash()
		self._flash_icon:stop()
		self._flash_icon:set_alpha(0)
		self._icon:set_alpha(1)
	end
	
	function HUDList.BuffItemBase:_animate_flash(icon, duration, continuous)
		repeat
			local t = duration
			while t > 0 do
				local dt = coroutine.yield()
				t = math.max(t - dt, 0)
				local value = math.sin(t/duration * 180)
				self._flash_icon:set_alpha(value)
				self._icon:set_alpha(1-value)
			end
		until not continuous

		self._flash_icon:set_alpha(0)
		self._icon:set_alpha(1)
	end
	
	HUDList.TimedBuffItem = HUDList.TimedBuffItem or class(HUDList.BuffItemBase)
	function HUDList.TimedBuffItem:init(parent, name, icon)
		HUDList.TimedBuffItem.super.init(self, parent, name, icon)
		
		self._timer = CircleBitmapGuiObject:new(self._panel, {
			use_bg = true,
			radius = 0.9 * self:panel():w() / 2,
			color = Color(1, 1, 1, 1),
			blend_mode = "add",
			layer = 0
		})
		self._timer._circle:set_center(self._icon:center())
		self._timer._bg_circle:set_center(self._icon:center())
	end
	
	function HUDList.TimedBuffItem:set_duration(duration)
		self._duration = duration
	end
	
	function HUDList.TimedBuffItem:refresh()
		self:set_progress(0)
	end
	
	function HUDList.TimedBuffItem:set_progress(ratio)
		self._timer._circle:set_color(Color(1, ratio, 1, 1))	--TODO: why the hell wont set_current directly on the timer work?
	end
	
	HUDList.ChargedBuffItem = HUDList.ChargedBuffItem or class(HUDList.TimedBuffItem)			
	function HUDList.ChargedBuffItem:init(...)
		HUDList.ChargedBuffItem.super.init(self, ...)
		self._bg:set_visible(false)
	end
	
	function HUDList.ChargedBuffItem:set_progress(ratio)
		HUDList.ChargedBuffItem.super.set_progress(self, ratio)
		if ratio >= 1 and not self._flashing then
			self._flashing = true
			self:set_flash(true)
		elseif ratio == 0 and self._flashing then
			self._flashing = nil
			self:stop_flash()
		end
	end
	
	HUDList.BerserkerBuffItem = HUDList.BerserkerBuffItem or class(HUDList.BuffItemBase)
	function HUDList.BerserkerBuffItem:init(parent, name)
		HUDList.BuffItemBase.init(self, parent, name, HUDList.BuffItemBase.BUFF_MAP.berserker)
		
		self._text = self._panel:text({
			name = "text",
			text = "0",
			valign = "bottom",
			halign = "center",
			align = "center",
			vertical = "bottom",
			horizontal = "center",
			w = self._icon:w(),
			h = math.round(self._icon:w() * 0.4),
			layer = 0,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = math.round(self._icon:w() * 0.4),
			blend_mode = "normal"
		})
		self._icon:set_top(self:panel():top() + self._icon:h() * 0.1) --Extra space for ace card bg
		self._flash_icon:set_center(self._icon:center())
		self._bg:set_center(self._icon:center())
		self._text:set_center(self._icon:center())
		self._text:set_bottom(self:panel():bottom())
		self._text_bg = self._panel:rect({
			name = "text_bg",
			color = Color.black,
			layer = -1,
			alpha = 0.5,
			blend_mode = "normal",
			w = self._text:w(),
			h = self._text:h(),
		})
		self._text_bg:set_center(self._text:center())
	end
	
	function HUDList.BerserkerBuffItem:set_progress(ratio)
		self._text:set_color(self:_get_color_from_table(ratio, 1))
		self._text:set_text(string.format("%.0f", ratio * 100) .. "%")
		
		local _, _, w, _ = self._text:text_rect()
		self._text_bg:set_w(w)
		self._text_bg:set_center(self._text:center())
	end
	
	HUDList.SuppressionBuffItem = HUDList.SuppressionBuffItem or class(HUDList.TimedBuffItem)
	function HUDList.SuppressionBuffItem:set_progress(ratio)
		HUDList.SuppressionBuffItem.super.set_progress(self, ratio)
		
		local max = tweak_data.player.suppression.max_value
		local current = ratio * (tweak_data.player.suppression.decay_start_delay + max)
		if current > max and not self._flashing then
			self._flashing = true
			self:set_flash(true)
		elseif current < max and self._flashing then
			self._flashing = nil
			self:stop_flash()
		end
	end
	
end

if RequiredScript == "lib/managers/hud/hudassaultcorner" then
	local HUDAssaultCorner_init = HUDAssaultCorner.init
	function HUDAssaultCorner:init(...)
		HUDAssaultCorner_init(self, ...)
		local hostages_panel = self._hud_panel:child("hostages_panel")
		hostages_panel:set_alpha(0)
	end
end

if RequiredScript == "lib/managers/playermanager" then

	PlayerManager._CHECK_BUFF_ACED = {
		overkill = function() return managers.player:has_category_upgrade("player", "overkill_all_weapons") end,
		pain_killer = function(level) return (level and level > 1) end,
		swan_song = function() return managers.player:has_category_upgrade("player", "berserker_no_ammo_cost") end,
	}
	
	PlayerManager._TEAM_BUFFS = {
		damage_dampener = {
			hostage_multiplier =  "crew_chief_9", 
		},
		stamina = {
			multiplier = "endurance",
			passive_multiplier = "crew_chief_3", 
			hostage_multiplier =  "crew_chief_9", 
		},
		health = {
			passive_multiplier = "crew_chief_5", 
			hostage_multiplier = "crew_chief_9", 
		},
		armor = {
			multiplier =  "crew_chief_7", 
			regen_time_multiplier = "bulletproof", 
			passive_regen_time_multiplier = "armorer", 
		},
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
	}
	
	PlayerManager._TEMPORARY_BUFFS = {
		dmg_multiplier_outnumbered = "underdog",
		dmg_dampener_outnumbered = "underdog_aced",
		dmg_dampener_outnumbered_strong = "overdog",
		dmg_dampener_close_contact = "close_combat",
		combat_medic_damage_multiplier = "combat_medic",
		overkill_damage_multiplier = "overkill",
		no_ammo_cost = "bullet_storm",
		passive_revive_damage_reduction = "pain_killer",
		berserker_damage_multiplier = "swan_song",
		first_aid_damage_reduction = "quick_fix",
		melee_life_leech = "life_drain",
		loose_ammo_restore_health = "medical_supplies",
		loose_ammo_give_team = "ammo_give_out",
		armor_break_invulnerable = "armor_break_invulnerable_debuff",
	}

	
	PlayerManager.ACTIVE_TEAM_BUFFS = {}
	PlayerManager.ACTIVE_BUFFS = {}
	PlayerManager._LISTENER_CALLBACKS = {}
	
	local init_original = PlayerManager.init
	local update_original = PlayerManager.update
	local count_up_player_minions_original = PlayerManager.count_up_player_minions
	local count_down_player_minions_original = PlayerManager.count_down_player_minions
	local update_hostage_skills_original = PlayerManager.update_hostage_skills
	local activate_temporary_upgrade_original = PlayerManager.activate_temporary_upgrade
	local activate_temporary_upgrade_by_level_original = PlayerManager.activate_temporary_upgrade_by_level
	local deactivate_temporary_upgrade_original = PlayerManager.deactivate_temporary_upgrade
	local aquire_team_upgrade_original = PlayerManager.aquire_team_upgrade
	local unaquire_team_upgrade_original = PlayerManager.unaquire_team_upgrade
	local add_synced_team_upgrade_original = PlayerManager.add_synced_team_upgrade
	local peer_dropped_out_original = PlayerManager.peer_dropped_out
	
	function PlayerManager:init(...)
		init_original(self, ...)
		
		for category, data in pairs(self._global.team_upgrades) do
			for upgrade, value in pairs(data) do
				local buff = PlayerManager._TEAM_BUFFS[category] and PlayerManager._TEAM_BUFFS[category][upgrade]
				if buff then
					self:activate_team_buff(buff, 0)
				else
					--DEBUG_PRINT("warnings", "Attempting to activate undefined local team buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. "\n")
				end
			end
		end
	end
	
	function PlayerManager:update(t, dt, ...)
		update_original(self, t, dt, ...)
		
		local expired_buffs = {}
		for buff, data in pairs(PlayerManager.ACTIVE_BUFFS) do
			if data.timed then
				if data.expire_t <= t then
					table.insert(expired_buffs, buff)
				else
					self:set_buff_attribute(buff, "progress", 1 - (t - data.activation_t) / data.duration)
				end
			end
		end
		
		for _, buff in ipairs(expired_buffs) do
			self:deactivate_buff(buff)
		end

		self._t = t
	end
	
	function PlayerManager:count_up_player_minions(...)
		local result = count_up_player_minions_original(self, ...)
		if self._local_player_minions > 0 and self:has_category_upgrade("player", "minion_master_speed_multiplier") then
			self:activate_buff("partner_in_crime")
			self:set_buff_attribute("partner_in_crime", "aced", self:has_category_upgrade("player", "minion_master_health_multiplier"))
		end
		return result
	end
	
	function PlayerManager:count_down_player_minions(...)
		local result = count_down_player_minions_original(self, ...)
		if self._local_player_minions <= 0 then
			self:deactivate_buff("partner_in_crime")
		end
		return result
	end
	
	function PlayerManager:update_hostage_skills(...)
		local stack_count = (managers.groupai and managers.groupai:state():hostage_count() or 0) + (self:num_local_minions() or 0)
		
		if self:has_team_category_upgrade("health", "hostage_multiplier") or self:has_team_category_upgrade("stamina", "hostage_multiplier") or self:has_team_category_upgrade("damage_dampener", "hostage_multiplier") then
			self:set_buff_active("hostage_situation", stack_count > 0)
			self:set_buff_attribute("hostage_situation", "stack_count", stack_count)
		end
		
		if self:has_category_upgrade("player", "hostage_health_regen_addend") then
			self:set_buff_active("hostage_taker", stack_count > 0)
			self:set_buff_attribute("hostage_taker", "aced", self:upgrade_level("player", "hostage_health_regen_addend", 0) > 1)
		end
		
		return update_hostage_skills_original(self, ...)
	end
	
	function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if upgrade_value ~= 0 then
			local buff = PlayerManager._TEMPORARY_BUFFS[upgrade]
			if buff then
				self:activate_timed_buff(buff, upgrade_value[2])
				local check_aced = PlayerManager._CHECK_BUFF_ACED[buff]
				if check_aced then
					self:set_buff_attribute(buff, "aced", check_aced() or false)
				end
			else
				--DEBUG_PRINT("warnings", "Attempting to activate undefined buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. "\n")
			end
		end
		
		return activate_temporary_upgrade_original(self, category, upgrade, ...)
	end
	
	function PlayerManager:activate_temporary_upgrade_by_level(category, upgrade, level, ...)
		local upgrade_level = self:upgrade_level(category, upgrade, 0) or 0
		if level > upgrade_level then
			local upgrade_value = self:upgrade_value_by_level(category, upgrade, level, 0)
			if upgrade_value ~= 0 then
				local buff = PlayerManager._TEMPORARY_BUFFS[upgrade]
				if buff then
					self:activate_timed_buff(buff, upgrade_value[2])
					local check_aced = PlayerManager._CHECK_BUFF_ACED[buff]
					if check_aced then
						self:set_buff_attribute(buff, "aced", check_aced() or false)
					end
				else
					--DEBUG_PRINT("warnings", "Attempting to activate undefined buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. " (" .. "level: " .. tostring(level) .. ")\n")
				end
			end
		end

		return activate_temporary_upgrade_by_level_original(self, category, upgrade, level, ...)
	end

	function PlayerManager:deactivate_temporary_upgrade(category, upgrade, ...)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if self._temporary_upgrades[category] and upgrade_value ~= 0 then
			local buff = PlayerManager._TEMPORARY_BUFFS[upgrade]
			if buff then
				self:deactivate_buff(buff)
			else
					--DEBUG_PRINT("warnings", "Attempting to deactivate undefined buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. "\n")
			end
		end
		
		return deactivate_temporary_upgrade_original(self, category, upgrade, ...)
	end
	
	function PlayerManager:aquire_team_upgrade(upgrade, ...)
		aquire_team_upgrade_original(self, upgrade, ...)
		
		local buff = PlayerManager._TEAM_BUFFS[upgrade.category] and PlayerManager._TEAM_BUFFS[upgrade.category][upgrade.upgrade]
		if buff then
			self:activate_team_buff(buff, 0)
		else
			--DEBUG_PRINT("warnings", "Attempting to activate undefined local team buff: " .. tostring(upgrade.category) .. ", " .. tostring(upgrade.upgrade) .. "\n")
		end
	end
	
	function PlayerManager:unaquire_team_upgrade(upgrade, ...)
		unaquire_team_upgrade_original(self, upgrade, ...)
		
		local buff = PlayerManager._TEAM_BUFFS[upgrade.category] and PlayerManager._TEAM_BUFFS[upgrade.category][upgrade.upgrade]
		if buff then
			self:deactivate_team_buff(buff, 0)
		else
			--DEBUG_PRINT("warnings", "Attempting to deactivate undefined local team buff: " .. tostring(upgrade.category) .. ", " .. tostring(upgrade.upgrade) .. "\n")
		end
	end

	function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, ...)
		add_synced_team_upgrade_original(self, peer_id, category, upgrade, ...)
	
		local buff = PlayerManager._TEAM_BUFFS[category] and PlayerManager._TEAM_BUFFS[category][upgrade]
		if buff then
			self:activate_team_buff(buff, peer_id)
		else
			--DEBUG_PRINT("warnings", "Attempting to activate undefined team buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. " from peer ID: " .. tostring(peer_id) .. "\n")
		end
	end
	
	function PlayerManager:peer_dropped_out(peer, ...)
		local peer_id = peer:id()
		local buffs = {}
		
		for category, data in pairs(self._global.synced_team_upgrades[peer_id] or {}) do
			for upgrade, value in pairs(data) do
				local buff = PlayerManager._TEAM_BUFFS[category] and PlayerManager._TEAM_BUFFS[category][upgrade]
				if buff then
					table.insert(buffs, buff)
				else
					--DEBUG_PRINT("warnings", "Attempting to deactivate undefined local team buff: " .. tostring(category) .. ", " .. tostring(upgrade) .. "\n")
				end
			end
		end
		
		peer_dropped_out_original(self, peer, ...)
		
		for _, buff in pairs(buffs) do
			self:deactivate_team_buff(buff, peer_id)
		end
	end
	
	
	
	function PlayerManager:activate_team_buff(buff, peer)
		PlayerManager.ACTIVE_TEAM_BUFFS[buff] = PlayerManager.ACTIVE_TEAM_BUFFS[buff] or {}
		
		if not PlayerManager.ACTIVE_TEAM_BUFFS[buff][peer] then
			PlayerManager.ACTIVE_TEAM_BUFFS[buff][peer] = true
			PlayerManager.ACTIVE_TEAM_BUFFS[buff].count = (PlayerManager.ACTIVE_TEAM_BUFFS[buff].count or 0) + 1
			--DEBUG_PRINT("buff_basic", "TEAM BUFF ADD: " .. tostring(buff) .. " -> " .. tostring(PlayerManager.ACTIVE_TEAM_BUFFS[buff].count) .. "\n")
			
			if PlayerManager.ACTIVE_TEAM_BUFFS[buff].count == 1 then
				--DEBUG_PRINT("buff_basic", "\tACTIVATE\n")
				PlayerManager._do_listener_callback("on_buff_activated", buff)
			end
		end
	end
	
	function PlayerManager:deactivate_team_buff(buff, peer)
		if PlayerManager.ACTIVE_TEAM_BUFFS[buff] and PlayerManager.ACTIVE_TEAM_BUFFS[buff][peer] then
			PlayerManager.ACTIVE_TEAM_BUFFS[buff][peer] = nil
			PlayerManager.ACTIVE_TEAM_BUFFS[buff].count = PlayerManager.ACTIVE_TEAM_BUFFS[buff].count - 1
			--DEBUG_PRINT("buff_basic", "TEAM BUFF REMOVE: " .. tostring(buff) .. " -> " .. tostring(PlayerManager.ACTIVE_TEAM_BUFFS[buff].count) .. "\n")
			
			if PlayerManager.ACTIVE_TEAM_BUFFS[buff].count <= 0 then
				--DEBUG_PRINT("buff_basic", "\tDEACTIVATE\n")
				PlayerManager.ACTIVE_TEAM_BUFFS[buff] = nil
				PlayerManager._do_listener_callback("on_buff_deactivated", buff)
			end
		end
	end
	
	function PlayerManager:set_buff_active(buff, status)
		if status then
			self:activate_buff(buff)
		else
			self:deactivate_buff(buff)
		end
	end
	
	function PlayerManager:activate_buff(buff)
		if not PlayerManager.ACTIVE_BUFFS[buff] then
			PlayerManager._do_listener_callback("on_buff_activated", buff)
			PlayerManager.ACTIVE_BUFFS[buff] = {}
		end
	end
	
	function PlayerManager:deactivate_buff(buff)
		if PlayerManager.ACTIVE_BUFFS[buff] then
			PlayerManager._do_listener_callback("on_buff_deactivated", buff)
			PlayerManager.ACTIVE_BUFFS[buff] = nil
		end
	end
	
	function PlayerManager:activate_timed_buff(buff, duration)
		self:activate_buff(buff)
		
		PlayerManager.ACTIVE_BUFFS[buff].timed = true
		PlayerManager.ACTIVE_BUFFS[buff].activation_t = self._t
		
		if PlayerManager.ACTIVE_BUFFS[buff].duration ~= duration then
			PlayerManager.ACTIVE_BUFFS[buff].duration = duration
			PlayerManager._do_listener_callback("on_buff_set_duration", buff, duration)
		end
		
		local expiration_t = self._t + duration
		if PlayerManager.ACTIVE_BUFFS[buff].expire_t ~=  expiration_t then
			PlayerManager.ACTIVE_BUFFS[buff].expire_t = expiration_t
			PlayerManager._do_listener_callback("on_buff_set_expiration", buff, expiration_t)
		end
	end
	
	function PlayerManager:refresh_timed_buff(buff)
		if PlayerManager.ACTIVE_BUFFS[buff] then
			PlayerManager.ACTIVE_BUFFS[buff].activation_t = self._t
			local expire_t = self._t + PlayerManager.ACTIVE_BUFFS[buff].duration
			PlayerManager.ACTIVE_BUFFS[buff].expire_t = expire_t
			PlayerManager._do_listener_callback("on_buff_set_expiration", buff, expire_t)
			PlayerManager._do_listener_callback("on_buff_refresh", buff)
		end
	end
	
	function PlayerManager:set_buff_attribute(buff, attribute, ...)
		if PlayerManager.ACTIVE_BUFFS[buff] then
			PlayerManager.ACTIVE_BUFFS[buff][attribute] = { ... }
		end
		
		PlayerManager._do_listener_callback("on_buff_set_" .. attribute, buff, ...)
	end
	

	function PlayerManager.register_listener_clbk(name, event, clbk)
		PlayerManager._LISTENER_CALLBACKS[event] = PlayerManager._LISTENER_CALLBACKS[event] or {}
		PlayerManager._LISTENER_CALLBACKS[event][name] = clbk
	end
	
	function PlayerManager.unregister_listener_clbk(name, event)
		for event_id, listeners in pairs(PlayerManager._LISTENER_CALLBACKS) do
			if not event or event_id == event then
				for id, clbk in pairs(listeners) do
					if id == name then
						PlayerManager._LISTENER_CALLBACKS[event_id][id] = nil
						break
					end
				end
			end
		end
	end
	
	function PlayerManager._do_listener_callback(event, ...)
		if PlayerManager._LISTENER_CALLBACKS[event] then
			for id, clbk in pairs(PlayerManager._LISTENER_CALLBACKS[event]) do
				clbk(...)
			end
		end
	end
	
end

if RequiredScript == "lib/units/beings/player/playerdamage" then

	local set_health_original = PlayerDamage.set_health
	local _damage_screen_original = PlayerDamage._damage_screen
	local build_suppression_original = PlayerDamage.build_suppression
	local restore_armor_original = PlayerDamage.restore_armor
	local set_armor_original = PlayerDamage.set_armor
	local _upd_health_regen_original = PlayerDamage._upd_health_regen
	local add_damage_to_hot_original = PlayerDamage.add_damage_to_hot
	

	PlayerDamage._ARMOR_REGEN_TABLE = {
		[tweak_data.upgrades.values.player.headshot_regen_armor_bonus[1] ] = "bullseye_debuff",
		[tweak_data.upgrades.values.player.killshot_regen_armor_bonus[1] ] = "tension_debuff",
		[tweak_data.upgrades.values.player.headshot_regen_armor_bonus[2] ] = "bullseye_debuff",
		[tweak_data.upgrades.values.player.killshot_regen_armor_bonus[1] + tweak_data.upgrades.values.player.killshot_close_regen_armor_bonus[1] ] = "tension_debuff",
	}

	function PlayerDamage:set_health(...)
		set_health_original(self, ...)
		
		local threshold = tweak_data.upgrades.player_damage_health_ratio_threshold
		local ratio = self:health_ratio()
		if managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
			if ratio <= threshold then
				managers.player:activate_buff("berserker")
				managers.player:set_buff_attribute("berserker", "progress", 1 - ratio / math.max(0.01, threshold))
				managers.player:set_buff_attribute("berserker", "aced", managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier"), true)
			else
				managers.player:deactivate_buff("berserker")
			end
		end
	end
	
	function PlayerDamage:_damage_screen(...)
		_damage_screen_original(self, ...)
		local delay = self._regenerate_timer + (self._supperssion_data.decay_start_t and (self._supperssion_data.decay_start_t - managers.player:player_timer():time()) or 0)
		managers.player:activate_timed_buff("armor_regen_debuff", delay)
	end
	
	function PlayerDamage:build_suppression(amount, ...)
		if not self:_chk_suppression_too_soon(amount) then
			build_suppression_original(self, amount, ...)
			
			if self._supperssion_data.value > 0 then
				managers.player:activate_timed_buff("suppression_debuff", tweak_data.player.suppression.decay_start_delay + self._supperssion_data.value)
			end

			if self._supperssion_data.value == tweak_data.player.suppression.max_value then
				if self:get_real_armor() < self:_total_armor() then
					managers.player:refresh_timed_buff("armor_regen_debuff")
				end
			end
		end
	end
	
	function PlayerDamage:restore_armor(armor_regen, ...)
		restore_armor_original(self, armor_regen, ...)

		local buff = PlayerDamage._ARMOR_REGEN_TABLE[armor_regen]
		if buff then
			local cooldown_key = buff == "bullseye_debuff" and "on_headshot_dealt_cooldown" or "on_killshot_cooldown"
			managers.player:activate_timed_buff(buff, tweak_data.upgrades[cooldown_key])
		end
	end
	
	function PlayerDamage:set_armor(armor, ...)
		set_armor_original(self, armor, ...)
		
		if armor >= self:_total_armor() then
			managers.player:deactivate_buff("armor_regen_debuff")
		end
	end
	
	function PlayerDamage:_upd_health_regen(...)
		local old_stack_count = #self._damage_to_hot_stack
		
		_upd_health_regen_original(self, ...)
		
		if #self._damage_to_hot_stack ~= old_stack_count then
			managers.player:set_buff_attribute("damage_to_hot", "stack_count", #self._damage_to_hot_stack)
		end
	end

	function PlayerDamage:add_damage_to_hot(...)
		if not (self:got_max_doh_stacks() or self:need_revive() or self:dead() or self._check_berserker_done) then
			local duration = ((self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)) * self._doh_data.tick_time
			local stacks = (#self._damage_to_hot_stack or 0) + 1
			managers.player:activate_timed_buff("damage_to_hot_debuff", tweak_data.upgrades.damage_to_hot_data.stacking_cooldown)
			managers.player:activate_timed_buff("damage_to_hot", duration)
			managers.player:set_buff_attribute("damage_to_hot", "stack_count", stacks)
		end
		
		return add_damage_to_hot_original(self, ...)
	end
	
end

if RequiredScript == "lib/units/beings/player/playermovement" then

	local on_morale_boost_original = PlayerMovement.on_morale_boost

	function PlayerMovement:on_morale_boost(...)
		managers.player:activate_timed_buff("inspire", tweak_data.upgrades.morale_boost_time)
		return on_morale_boost_original(self, ...)
	end

end

if RequiredScript == "lib/units/beings/player/states/playerstandard" then

	local _start_action_charging_weapon_original = PlayerStandard._start_action_charging_weapon
	local _end_action_charging_weapon_original = PlayerStandard._end_action_charging_weapon
	local _update_charging_weapon_timers_original = PlayerStandard._update_charging_weapon_timers
	local _start_action_melee_original = PlayerStandard._start_action_melee
	local _update_melee_timers_original = PlayerStandard._update_melee_timers
	local _do_melee_damage_original = PlayerStandard._do_melee_damage
	local _do_action_intimidate_original = PlayerStandard._do_action_intimidate
	local _check_action_primary_attack_original = PlayerStandard._check_action_primary_attack

	function PlayerStandard:_update_omniscience(t, dt)
		if managers.groupai:state():whisper_mode() then
			local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or managers.player:current_state() == "civilian" or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_grenade() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not tweak_data.player.omniscience
			if action_forbidden then
				if self._state_data.omniscience_t then
					--managers.player:set_buff_attribute("sixth_sense", "stack_count", 0)
					managers.player:deactivate_buff("sixth_sense")
					self._state_data.omniscience_t = nil
					self._state_data.omniscience_units_detected = {}
				end
				return
			end
			
			if not self._state_data.omniscience_t then
				managers.player:activate_timed_buff("sixth_sense", tweak_data.player.omniscience.start_t + 0.05)
				managers.player:set_buff_attribute("sixth_sense", "stack_count", 0)
				self._state_data.omniscience_t = t + tweak_data.player.omniscience.start_t
			end
			
			if t >= self._state_data.omniscience_t then
				local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, World:make_slot_mask(12, 21, 33))
				self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}
				managers.player:set_buff_attribute("sixth_sense", "stack_count", #sensed_targets, true)
				
				for _, unit in ipairs(sensed_targets) do
					if alive(unit) and not tweak_data.character[unit:base()._tweak_table].is_escort and not unit:anim_data().tied then
						if not self._state_data.omniscience_units_detected[unit:key()] or t >= self._state_data.omniscience_units_detected[unit:key()] then
							self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t
							managers.game_play_central:auto_highlight_enemy(unit, true)
							--managers.player:set_buff_attribute("sixth_sense", "flash")
							break
						end
					end
				end
				self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
				managers.player:activate_timed_buff("sixth_sense", tweak_data.player.omniscience.interval_t + 0.05)
			end
		end
	end

	function PlayerStandard:_start_action_charging_weapon(...)
		managers.player:activate_buff("bow_charge")
		managers.player:set_buff_attribute("bow_charge", "progress", 0)
		return _start_action_charging_weapon_original(self, ...)
	end

	function PlayerStandard:_end_action_charging_weapon(...)
		managers.player:deactivate_buff("bow_charge")
		return _end_action_charging_weapon_original(self, ...)
	end

	function PlayerStandard:_update_charging_weapon_timers(...)
		if self._state_data.charging_weapon then
			local weapon = self._equipped_unit:base()
			if not weapon:charge_fail() then
				managers.player:set_buff_attribute("bow_charge", "progress", weapon:charge_multiplier())
			end
		end
		return _update_charging_weapon_timers_original(self, ...)
	end

	function PlayerStandard:_start_action_melee(...)
		managers.player:set_buff_attribute("melee_charge", "progress", 0)
		return _start_action_melee_original(self, ...)
	end

	function PlayerStandard:_update_melee_timers(t, ...)
		if self._state_data.meleeing and self._state_data.melee_start_t and self._state_data.melee_start_t + 0.3 < t then
			managers.player:activate_buff("melee_charge")
			managers.player:set_buff_attribute("melee_charge", "progress", self:_get_melee_charge_lerp_value(t))
		end
		return _update_melee_timers_original(self, t, ...)
	end
	
	function PlayerStandard:_do_melee_damage(t, ...)
		managers.player:deactivate_buff("melee_charge")
		
		local result = _do_melee_damage_original(self, t, ...)
		if self._state_data.stacking_dmg_mul then
			local stack = self._state_data.stacking_dmg_mul.melee
			if stack then
				if stack[2] > 0 then
					managers.player:activate_timed_buff("melee_stack_damage", (stack[1] or 0) - t)
					managers.player:set_buff_attribute("melee_stack_damage", "stack_count", stack[2])
				else
					managers.player:deactivate_buff("melee_stack_damage")
				end
			end
		end
		return result
	end
	
	function PlayerStandard:_do_action_intimidate(t, interact_type, ...)
		if interact_type == "cmd_gogo" or interact_type == "cmd_get_up" then
			managers.player:activate_timed_buff("inspire_debuff", self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		end
		return _do_action_intimidate_original(self, t, interact_type, ...)
	end
	
	function PlayerStandard:_check_action_primary_attack(t, ...)
		local result = _check_action_primary_attack_original(self, t, ...)
		if self._state_data.stacking_dmg_mul then
			local weapon_category = self._equipped_unit:base():weapon_tweak_data().category
			local stack = self._state_data.stacking_dmg_mul[weapon_category]
			if stack then
				if stack[2] > 0 then
					managers.player:activate_timed_buff("trigger_happy", (stack[1] or 0) - t)
					managers.player:set_buff_attribute("trigger_happy", "stack_count", stack[2])
				else
					managers.player:deactivate_buff("trigger_happy")
				end
			end
		end
		return result
	end
end

if RequiredScript == "lib/managers/objectinteractionmanager" then
	local init_original = ObjectInteractionManager.init

	function ObjectInteractionManager:init(...)
		init_original(self, ...)
		if HUDListManager.ListOptions.remove_answered_pager_contour then
			managers.gameinfo:register_listener("pager_contour_remover", "pager", "answered", callback(nil, _G, "pager_answered_clbk"))
		else
			managers.gameinfo:unregister_listener("pager_contour_remover", "pager", "answered")
		end
	end

	function pager_answered_clbk(event, key, data)
		managers.enemy:add_delayed_clbk("contour_remove_" .. key, callback(nil, _G, "remove_answered_pager_contour_clbk", data.unit), Application:time() + 0.01)
	end

	function remove_answered_pager_contour_clbk(unit)
		if alive(unit) then
			unit:contour():remove(tweak_data.interaction.corpse_alarm_pager.contour_preset)
		end
	end
end