if WolfHUD and not WolfHUD.settings.use_hudlist then return end
if RequiredScript == "lib/managers/hudmanagerpd2" then
 
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
                show_timers = WolfHUD.settings.show_timers or not WolfHUD and true,     --Drills, time locks, hacking etc.
                show_equipment = WolfHUD.settings.show_equipment or not WolfHUD and true,  --Deployables (ammo, doc bags, body bags)
                show_sentries = WolfHUD.settings.show_sentries or not WolfHUD and true,   --Deployable sentries
                        hide_empty_sentries = WolfHUD.settings.hide_empty_sentries or not WolfHUD and true,     --Hide sentries with no ammo if player lacks the skill to refill them
                show_ecms = WolfHUD.settings.show_ecms or not WolfHUD and true,       --Active ECMs
                show_ecm_retrigger = WolfHUD.settings.show_ecm_retrigger or not WolfHUD and true,      --Countdown for players own ECM feedback retrigger delay
                show_minions = WolfHUD.settings.show_minions or not WolfHUD and true,    --Converted enemies, type and health
                show_pagers = WolfHUD.settings.show_pagers or not WolfHUD and true,     --Show currently active pagers
                show_tape_loop = WolfHUD.settings.show_tape_loop or not WolfHUD and true,  --Show active tape loop duration
                remove_answered_pager_contour = WolfHUD.settings.remove_answered_pager_contour or not WolfHUD and true,   --Removes the interaction contour on answered pagers
       
                --Right side list
                show_enemies = WolfHUD.settings.show_enemies or not WolfHUD and true,            --Currently spawned enemies
                        aggregate_enemies = WolfHUD.settings.aggregate_enemies or false,      --Don't split enemies on type; use a single entry for all
                show_turrets = WolfHUD.settings.show_turrets or not WolfHUD and true,    --Show active SWAT turrets
                show_civilians = WolfHUD.settings.show_civilians or not WolfHUD and true,  --Currently spawned, untied civs
                show_hostages = WolfHUD.settings.show_hostages or not WolfHUD and true,   --Currently tied civilian and dominated cops
                show_minion_count = WolfHUD.settings.show_minion_count or not WolfHUD and true,       --Current number of jokered enemies
                show_pager_count = WolfHUD.settings.show_pager_count or not WolfHUD and true,        --Show number of triggered pagers (only counts pagers triggered while you were present)
                show_loot = WolfHUD.settings.show_loot or not WolfHUD and true,       --Show spawned and active loot bags/piles (may not be shown if certain mission parameters has not been met)
                        aggregate_loot = WolfHUD.settings.aggregate_loot or false, --Don't split loot on type; use a single entry for all
                        separate_bagged_loot = WolfHUD.settings.separate_bagged_loot or not WolfHUD and true,     --Show bagged loot as a separate value
                show_special_pickups = WolfHUD.settings.show_special_pickups or not WolfHUD and true,    --Show number of special equipment/items
               
                --Buff list
                show_buffs = WolfHUD.settings.show_buffs or 1,       --Active effects (buffs/debuffs). Also see HUDList.BuffItemBase.IGNORED_BUFFS table to ignore specific buffs that you don't want listed, or enable some of those not shown by default
        }
		
		local RightListColor 	= WolfHUD.color_table[(WolfHUD.settings.hud_box_color)] or Color.white
		local RightListBgColor 	= WolfHUD.color_table[(WolfHUD.settings.hud_box_bg_color)] or Color.black
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
		
        local civilian_color 	= WolfHUD.color_table[(WolfHUD.settings.civilian_color)] or Color.white
        local hostage_color 	= civilian_color
        local thug_color 		= WolfHUD.color_table[(WolfHUD.settings.thug_color)] or Color.white
		local enemy_color 		= WolfHUD.color_table[(WolfHUD.settings.enemy_color)] or Color.white
        local guard_color 		= enemy_color
        local special_color 	= enemy_color
        local turret_color 		= special_color
       
        function HUDListManager:init()
                self._lists = {}
       
                self:_setup_left_list()
                self:_setup_right_list()
                self:_setup_buff_list()
               
                self:_set_remove_answered_pager_contour()
               
                GroupAIStateBase.register_listener_clbk("HUDList_whisper_mode_change", "on_whisper_mode_change", callback(self, self, "_whisper_mode_change"))
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
       
        function HUDListManager:_pager_event(event, unit)
                local pager_list = self:list("left_side_list"):item("pagers")
               
                if event == "add" then
                        pager_list:register_item(tostring(unit:key()), HUDList.PagerItem, unit):activate()
                elseif event == "remove" then
                        pager_list:unregister_item(tostring(unit:key()))
                elseif event == "answer" then
                        pager_list:item(tostring(unit:key())):set_answered()
                elseif event == "remove_contour" then
                        managers.enemy:add_delayed_clbk("contour_remove_" .. tostring(unit:key()), callback(self, self, "_remove_pager_contour_clbk", unit), Application:time() + 0.01)
                end
        end
       
        function HUDListManager:_remove_pager_contour_clbk(unit)
                if alive(unit) then
                        unit:contour():remove(tweak_data.interaction.corpse_alarm_pager.contour_preset)
                end
        end
       
        function HUDListManager:_minion_event(event, unit, arg1)
                local minion_list = self:list("left_side_list"):item("minions")
       
                if event == "add" then
                        local item = minion_list:register_item(tostring(unit:key()), HUDList.MinionItem, unit)
                        item:activate()
                elseif event == "remove" then
                        --local killed = arg1
                        minion_list:unregister_item(tostring(unit:key()))
                elseif event == "set_owner" then
                        minion_list:item(tostring(unit:key())):set_owner(arg1)
                elseif event == "set_health_mult" then
                        minion_list:item(tostring(unit:key())):set_health_multiplier(arg1)
                elseif event == "set_damage_mult" then
                        minion_list:item(tostring(unit:key())):set_damage_multiplier(arg1)
                elseif event == "change_health" then
                        minion_list:item(tostring(unit:key())):set_health(arg1)
                end
        end
       
        function HUDListManager:_ecm_event(event, unit, arg1, arg2)
                local ecm_list = self:list("left_side_list"):item("ecms")
               
                if event == "add" then
                        ecm_list:register_item(tostring(unit:key()), HUDList.ECMItem)
                elseif event == "remove" then
                        ecm_list:unregister_item(tostring(unit:key()))
                elseif event == "update_battery" then
                        ecm_list:item(tostring(unit:key())):update_timer(arg1, arg2)
                elseif event == "jammer_status_change" then
                        ecm_list:item(tostring(unit:key())):set_active(arg1)
                end
        end
       
        function HUDListManager:_ecm_retrigger_event(event, unit, arg1, arg2)
                local list = self:list("left_side_list"):item("ecm_retrigger")
               
                if event == "set_active" then
                        if arg1 then
                                list:register_item(tostring(unit:key()), HUDList.ECMRetriggerItem):activate()
                        else
                                list:unregister_item(tostring(unit:key()))
                        end
                elseif event == "update" then
                        list:item(tostring(unit:key())):update_timer(arg1, arg2)
                end
        end
       
        function HUDListManager:_bag_equipment_event(event, unit, arg1)
                local equipment_list = self:list("left_side_list"):item("equipment")
                --local key = type(unit) == "string" and ("aggregated_" .. unit) or tostring(unit:key())
                local key = unit and tostring(unit:key()) or "aggregated"
               
                if event == "add" then
                        equipment_list:register_item(key, HUDList.BagEquipmentItem, arg1, unit)
                elseif event == "remove" then
                        equipment_list:unregister_item(key)
                else
                        local item = equipment_list:item(key)
                       
                        if item then
                                if event == "update_owner" then
                                        item:set_owner(arg1)
                                elseif event == "update_max" then
                                        item:set_max_amount(arg1 or 0)
                                elseif event == "update_amount" then
                                        item:set_amount(arg1 or 0)
                                elseif event == "update_amount_offset" then
                                        item:set_amount_offset(arg1 or 0)
                                elseif event == "set_active" then
                                        if item:get_type() == "body_bag" and not managers.groupai:state():whisper_mode() then
                                                arg1 = false
                                        end
                                        item:set_active(arg1)
                                end
                        end
                end
        end
       
        function HUDListManager:_sentry_equipment_event(event, unit, arg1)
                local equipment_list = self:list("left_side_list"):item("equipment")
                local key = unit:key()
               
                if event == "add" then
                        equipment_list:register_item(key, HUDList.SentryEquipmentItem, unit)
                elseif event == "remove" then
                        equipment_list:unregister_item(key)
                else
                        local item = equipment_list:item(key)
                       
                        if item then
                                if event == "update_owner" then
                                        item:set_owner(arg1)
                                elseif event == "update_ammo" then
                                        item:set_ammo_ratio(arg1 or 0)
                                        if HUDListManager.ListOptions.hide_empty_sentries then
                                                if not managers.player:has_category_upgrade("sentry_gun", "can_reload") then
                                                        item:set_active((arg1 or 0) > 0)
                                                end
                                        end
                                elseif event == "update_health" then
                                        item:set_health_ratio(arg1 or 0)
                                elseif event == "set_active" then
                                        item:set_active(arg1)
                                end
                        end
                end
        end
       
        function HUDListManager:_timer_event(event, unit, arg1, arg2)
                local timer_list = self:list("left_side_list"):item("timers")
               
                if event == "add" then
                        timer_list:register_item(tostring(unit:key()), arg1 or HUDList.TimerItem, unit, arg2)
                elseif event == "remove" then
                        timer_list:unregister_item(tostring(unit:key()))
                elseif event == "set_active" then
                        timer_list:item(tostring(unit:key())):set_active(arg1)
                elseif event == "set_jammed" then
                        timer_list:item(tostring(unit:key())):set_jammed(arg1)
                elseif event == "timer_update" then
                        timer_list:item(tostring(unit:key())):update_timer(arg1, arg2)
 
                --Drill/hack/saw stuff
                elseif event == "upgrade_update" then
                        timer_list:item(tostring(unit:key())):set_can_upgrade(arg1)
                elseif event == "set_powered" then
                        timer_list:item(tostring(unit:key())):set_powered(arg1)
                elseif event == "type_update" then
                        timer_list:item(tostring(unit:key())):set_type(arg1)
                end
        end
       
        function HUDListManager:_tape_loop_event(event, unit, duration)
                local tape_loop_list = self:list("left_side_list"):item("tape_loop")
               
                if event == "start" then
                        local item = tape_loop_list:register_item(tostring(unit:key()), HUDList.TapeLoopItem, unit)
                        item:set_duration(duration)
                        item:activate()
                elseif event == "stop" then
                        tape_loop_list:unregister_item(tostring(unit:key()))
                end
        end
       
        function HUDListManager:_whisper_mode_change(status)
                for _, item in pairs(self:list("left_side_list"):item("equipment"):items()) do
                        if item:get_type() == "body_bag" then
                                item:set_active(item:current_amount() > 0 and status)
                        end
                end
        end
       
        --Left list config
        function HUDListManager:_set_show_timers()
                local list = self:list("left_side_list"):item("timers")
               
                local timer_listener_name = "HUDListManager_timer_items_listener"
                local timer_listeners = {
                        on_create = callback(self, self, "_timer_event", "add"),
                        on_destroy = callback(self, self, "_timer_event", "remove"),
                        on_set_active = callback(self, self, "_timer_event", "set_active"),
                        on_set_jammed = callback(self, self, "_timer_event", "set_jammed"),
                        on_timer_update = callback(self, self, "_timer_event", "timer_update"),
                }
                local drill_listener_name = "HUDListManager_drill_items_listener"
                local drill_listeners = {
                        on_create = callback(self, self, "_timer_event", "add"),
                        on_destroy = callback(self, self, "_timer_event", "remove"),
                        on_set_active = callback(self, self, "_timer_event", "set_active"),
                        on_set_jammed = callback(self, self, "_timer_event", "set_jammed"),
                        on_update = callback(self, self, "_timer_event", "timer_update"),
                        on_can_upgrade = callback(self, self, "_timer_event", "upgrade_update"),
                        on_set_powered = callback(self, self, "_timer_event", "set_powered"),
                        on_type_set = callback(self, self, "_timer_event", "type_update"),
                }
               
                if HUDListManager.ListOptions.show_timers then
                        local timer_types = { DigitalGui, SecurityLockGui, TimerGui }
                       
                        for i, class in pairs(timer_types) do
                                for key, data in pairs(class.SPAWNED_ITEMS) do
                                        if not data.ignore then
                                                local item = list:register_item(tostring(key), data.class or HUDList.TimerItem, data.unit, data.params)
                                                item:set_can_upgrade(data.can_upgrade)
                                                item:set_active(data.active)
                                                item:set_jammed(data.jammed)
                                                item:set_powered(data.powered)
                                                if data.t and data.time_left then
                                                        item:update_timer(data.t, data.time_left)
                                                end
                                                if data.type then
                                                        item:set_type(data.type)
                                                end
                                        end
                                end
                        end
                       
                        for event, clbk in pairs(timer_listeners) do
                                DigitalGui.register_listener_clbk(timer_listener_name, event, clbk)
                        end
                        for event, clbk in pairs(drill_listeners) do
                                TimerGui.register_listener_clbk(drill_listener_name, event, clbk)
								SecurityLockGui.register_listener_clbk(drill_listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(timer_listeners) do
                                DigitalGui.unregister_listener_clbk(timer_listener_name, event)
                        end
                        for event, _ in pairs(drill_listeners) do
                                TimerGui.unregister_listener_clbk(drill_listener_name, event)
								SecurityLockGui.unregister_listener_clbk(drill_listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_equipment()
                local list = self:list("left_side_list"):item("equipment")
               
                local listener_name = "HUDListManager_bag_items_listener"
                local listeners = {
                        on_bag_create = callback(self, self, "_bag_equipment_event", "add"),
                        on_bag_destroy = callback(self, self, "_bag_equipment_event", "remove"),
                        on_bag_owner_update = callback(self, self, "_bag_equipment_event", "update_owner"),
                        on_bag_max_amount_update = callback(self, self, "_bag_equipment_event", "update_max"),
                        on_bag_amount_update = callback(self, self, "_bag_equipment_event", "update_amount"),
                        on_bag_amount_offset_update = callback(self, self, "_bag_equipment_event", "update_amount_offset"),
                        on_bag_set_active = callback(self, self, "_bag_equipment_event", "set_active"),
                }
       
                if HUDListManager.ListOptions.show_equipment then
                        local equipment_types = {
                                doc_bag = DoctorBagBase,
                                ammo_bag = AmmoBagBase,
                                body_bag = BodyBagsBagBase,
                                grenade_crate = GrenadeCrateBase,
                        }
                       
                        for type, class in pairs(equipment_types) do
                                for key, data in pairs(class.SPAWNED_BAGS) do
                                        local unit = data.unit
                                        self:_bag_equipment_event("add", unit, type)
                                        self:_bag_equipment_event("update_owner", unit, data.owner)
                                        self:_bag_equipment_event("update_max", unit, data.max_amount)
                                        self:_bag_equipment_event("update_amount", unit, data.amount)
                                        self:_bag_equipment_event("update_amount_offset", unit, data.amount_offset)
                                        self:_bag_equipment_event("set_active", unit, data.active)
                                end
                               
                                if class.AGGREGATED_BAGS then
                                        self:_bag_equipment_event("add", nil, type)
                                        self:_bag_equipment_event("update_max", nil, class.total_aggregated_max_amount())
                                        self:_bag_equipment_event("update_amount", nil, class.total_aggregated_amount())
                                        self:_bag_equipment_event("set_active", nil, class.AGGREAGATED_ITEM_ACTIVE)
                                end
                        end                    
                       
                        for event, clbk in pairs(listeners) do
                                UnitBase.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(listeners) do
                                UnitBase.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
 
        function HUDListManager:_set_show_sentries()
       
                local list = self:list("left_side_list"):item("equipment")
 
                local listener_name = "HUDListManager_sentry_items_listener"
                local listeners = {
                        on_sentry_create = callback(self, self, "_sentry_equipment_event", "add"),
                        on_sentry_destroy = callback(self, self, "_sentry_equipment_event", "remove"),
                        on_sentry_owner_update = callback(self, self, "_sentry_equipment_event", "update_owner"),
                        on_sentry_ammo_update = callback(self, self, "_sentry_equipment_event", "update_ammo"),
                        on_sentry_health_update = callback(self, self, "_sentry_equipment_event", "update_health"),
                        on_sentry_set_active = callback(self, self, "_sentry_equipment_event", "set_active"),
                }
       
                if HUDListManager.ListOptions.show_sentries then
                                for key, data in pairs(SentryGunBase.SPAWNED_SENTRIES) do
                                        local unit = data.unit
                                        self:_sentry_equipment_event("add", unit, "sentry")
                                        self:_sentry_equipment_event("update_owner", unit, data.owner)
                                        self:_sentry_equipment_event("update_ammo", unit, data.ammo)
                                        self:_sentry_equipment_event("update_health", unit, data.health)
                                        self:_sentry_equipment_event("set_active", unit, data.active)
                                end
                       
                        for event, clbk in pairs(listeners) do
                                UnitBase.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(listeners) do
                                UnitBase.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_minions()
                local list = self:list("left_side_list"):item("minions")
       
                local listener_name = "HUDListManager_minion_items_listener"
                local listeners = {
                        on_add_minion_unit = callback(self, self, "_minion_event", "add"),
                        on_remove_minion_unit = callback(self, self, "_minion_event", "remove"),
                        on_minion_set_owner = callback(self, self, "_minion_event", "set_owner"),
                        on_minion_set_health_mult = callback(self, self, "_minion_event", "set_health_mult"),
                        on_minion_set_damage_mult = callback(self, self, "_minion_event", "set_damage_mult"),
                        on_minion_health_change = callback(self, self, "_minion_event", "change_health"),
                }
               
                if HUDListManager.ListOptions.show_minions then
                        for key, data in pairs(EnemyManager.MINION_UNITS) do
                                local item = list:register_item(tostring(key), HUDList.MinionItem, data.unit)
                                item:activate()
                                item:set_owner(data.owner_id)
                                item:set_upgrade(data.upgraded)
                                item:set_health(data.health, true)
                        end
               
                        for event, clbk in pairs(listeners) do
                                EnemyManager.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
               
                        for event, _ in pairs(listeners) do
                                EnemyManager.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_pagers()
                local list = self:list("left_side_list"):item("pagers")
               
                local listener_name = "HUDListManager_active_pager_items_listener"
                local listeners = {
                        on_pager_started = callback(self, self, "_pager_event", "add"),
                        on_pager_ended = callback(self, self, "_pager_event", "remove"),
                        on_pager_answered = callback(self, self, "_pager_event", "answer"),
                }
       
                if HUDListManager.ListOptions.show_pagers then
                        for key, data in pairs(ObjectInteractionManager.ACTIVE_PAGERS) do
                                local item = list:register_item(tostring(key), HUDList.PagerItem, data.unit)
                                item:activate()
                                if data.answered then
                                        item:set_answered()
                                end
                        end
 
                        for event, clbk in pairs(listeners) do
                                ObjectInteractionManager.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
               
                        for event, _ in pairs(listeners) do
                                ObjectInteractionManager.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_ecms()
                local list = self:list("left_side_list"):item("ecms")
 
                local listener_name = "HUDListManager_ecm_items_listener"
                local listeners = {
                        on_ecm_create = callback(self, self, "_ecm_event", "add"),
                        on_ecm_destroy = callback(self, self, "_ecm_event", "remove"),
                        on_ecm_update = callback(self, self, "_ecm_event", "update_battery"),
                        on_ecm_set_active = callback(self, self, "_ecm_event", "jammer_status_change"),
                }
               
                if HUDListManager.ListOptions.show_ecms then
                        for key, data in pairs(ECMJammerBase.SPAWNED_ECMS) do
                                local item = list:register_item(tostring(key), HUDList.ECMItem)
                                item:set_active(data.active)
                                item:update_timer(data.t, data.battery_life)
                        end
                       
                        for event, clbk in pairs(listeners) do
                                UnitBase.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(listeners) do
                                UnitBase.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_ecm_retrigger()
                local list = self:list("left_side_list"):item("ecm_retrigger")
               
                local listener_name = "HUDListManager_ecm_retrigger_listener"
                local listeners = {
                        on_ecm_set_retrigger = callback(self, self, "_ecm_retrigger_event", "set_active"),
                        on_ecm_update_retrigger_delay = callback(self, self, "_ecm_retrigger_event", "update"),
                }
               
                if HUDListManager.ListOptions.show_ecm_retrigger then
                        for key, data in pairs(ECMJammerBase.SPAWNED_ECMS) do
                                if data.retrigger_t then
                                        local item = list:register_item(tostring(key), HUDList.ECMRetriggerItem)
                                        item:set_active(true)
                                        item:update_timer(data.t, data.retrigger_t)
                                end
                        end
                       
                        for event, clbk in pairs(listeners) do
                                UnitBase.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(listeners) do
                                UnitBase.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_remove_answered_pager_contour()
                local listener_name = "HUDListManager_remove_pager_contour_listener"
                local listeners = {
                        on_pager_answered = callback(self, self, "_pager_event", "remove_contour")
                }
       
                if HUDListManager.ListOptions.remove_answered_pager_contour then
                        for event, clbk in pairs(listeners) do
                                ObjectInteractionManager.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for event, _ in pairs(listeners) do
                                ObjectInteractionManager.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        function HUDListManager:_set_show_tape_loop()
                local list = self:list("left_side_list"):item("tape_loop")
               
                local listener_name = "HUDListManager_tape_loop_listener"
                local listeners = {
                        on_tape_loop_start = callback(self, self, "_tape_loop_event", "start"),
                        on_tape_loop_stop = callback(self, self, "_tape_loop_event", "stop"),
                }
               
                if HUDListManager.ListOptions.show_tape_loop then                      
                        for event, clbk in pairs(listeners) do
                                ObjectInteractionManager.register_listener_clbk(listener_name, event, clbk)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                       
                        for event, _ in pairs(listeners) do
                                ObjectInteractionManager.unregister_listener_clbk(listener_name, event)
                        end
                end
        end
       
        --Right list config
        function HUDListManager:_set_show_enemies()
                local list = self:list("right_side_list"):item("unit_count_list")
               
                if HUDListManager.ListOptions.show_enemies then
                        if HUDListManager.ListOptions.aggregate_enemies then
                                local data = HUDList.UnitCountItem.ENEMY_ICON_MAP.all
                                list:register_item("all", data.class or HUDList.UnitCountItem)
                        else
                                for name, data in pairs(HUDList.UnitCountItem.ENEMY_ICON_MAP) do
                                        if not data.manual_add then
                                                list:register_item(name, data.class or HUDList.UnitCountItem)
                                        end
                                end
                        end
                else
                        for name, data in pairs(HUDList.UnitCountItem.ENEMY_ICON_MAP) do
                                if not data.manual_add then
                                        list:unregister_item(name, true)
                                end
                        end
                        list:unregister_item("all", true)
                end
        end    
       
        function HUDListManager:_set_aggregate_enemies()
                local list = self:list("right_side_list"):item("unit_count_list")
               
                for name, data in pairs(HUDList.UnitCountItem.ENEMY_ICON_MAP) do
                        if not data.manual_add then
                                list:unregister_item(name, true)
                        end
                        list:unregister_item("all", true)
                end
               
                self:_set_show_enemies()
        end
       
        function HUDListManager:_set_show_turrets()
                local list = self:list("right_side_list"):item("unit_count_list")
                local data = HUDList.UnitCountItem.MISC_ICON_MAP.turret
                       
                if HUDListManager.ListOptions.show_turrets then
                        list:register_item("turret", data.class or HUDList.UnitCountItem)
                else
                        list:unregister_item("turret", true)
                end
        end    
       
        function HUDListManager:_set_show_civilians()
                local list = self:list("right_side_list"):item("unit_count_list")
                local data = HUDList.UnitCountItem.MISC_ICON_MAP.civilian
               
                if HUDListManager.ListOptions.show_civilians then
                        list:register_item("civilian", data.class or HUDList.UnitCountItem)
                else
                        list:unregister_item("civilian", true)
                end
        end
       
        function HUDListManager:_set_show_hostages()
                --local list = self:list("right_side_list"):item("hostage_count_list")
                local list = self:list("right_side_list"):item("unit_count_list")
               
                if HUDListManager.ListOptions.show_hostages then
                        for name, data in pairs(HUDList.UnitCountItem.HOSTAGE_ICON_MAP) do
                                if not data.manual_add then
                                        list:register_item(name, data.class or HUDList.HostageUnitCountItem)
                                end
                        end
                else
                        for name, data in pairs(HUDList.UnitCountItem.HOSTAGE_ICON_MAP) do
                                if not data.manual_add then
                                        list:unregister_item(name, true)
                                end
                        end
                end
        end
       
        function HUDListManager:_set_show_minion_count()
                --local list = self:list("right_side_list"):item("hostage_count_list")
                local list = self:list("right_side_list"):item("unit_count_list")
                local data = HUDList.UnitCountItem.MISC_ICON_MAP.minion
               
                if HUDListManager.ListOptions.show_minion_count then
                        list:register_item("minion", data.class or HUDList.UnitCountItem)
                else
                        list:unregister_item("minion", true)
                end
        end
       
        function HUDListManager:_set_show_pager_count()
                local list = self:list("right_side_list"):item("hostage_count_list")
               
                if HUDListManager.ListOptions.show_pager_count then
                        list:register_item("PagerCount", HUDList.UsedPagersItem)
                else
                        list:unregister_item("PagerCount", true)
                end
        end
       
        function HUDListManager:_set_show_loot()
                local list = self:list("right_side_list"):item("loot_list")
       
                if HUDListManager.ListOptions.show_loot then
                        if HUDListManager.ListOptions.aggregate_loot then
                                local data = HUDList.LootItem.LOOT_ICON_MAP.all
                                list:register_item("all", data.class or HUDList.LootItem)
                        else
                                for name, data in pairs(HUDList.LootItem.LOOT_ICON_MAP) do
                                        if not data.manual_add then
                                                list:register_item(name, data.class or HUDList.LootItem)
                                        end
                                end
                        end
                else
                        for name, data in pairs(HUDList.LootItem.LOOT_ICON_MAP) do
                                if not data.manual_add then
                                        list:unregister_item(name, true)
                                end
                        end
                        list:unregister_item("all", true)
                end
        end
       
        function HUDListManager:_set_aggregate_loot()
                local list = self:list("right_side_list"):item("loot_list")
               
                for name, data in pairs(HUDList.LootItem.LOOT_ICON_MAP) do
                        list:unregister_item(name, true)
                end
               
                self:_set_show_loot()
        end
       
        function HUDListManager:_set_show_special_pickups()
                local list = self:list("right_side_list"):item("special_pickup_list")
               
                if HUDListManager.ListOptions.show_special_pickups then
                        for id, data in pairs(HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP) do
                                list:register_item(id, data.class or HUDList.SpecialPickupItem)
                        end
                else
                        for _, item in pairs(list:items()) do
                                item:delete(true)
                        end
                end
        end
       
        function HUDListManager:_buff_activation(status, buff, ...)
                local data = HUDList.BuffItemBase.COMPOSITE_ITEMS[buff]
       
                if not HUDList.BuffItemBase.IGNORED_BUFFS[data and data.item or buff] then
                        local item = self:list("buff_list"):item(data and data.item or buff)
                       
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
								if (HUDListManager.ListOptions.show_buffs == 2 and (data.class == "TimedBuffItem" or data.class == "ChargedBuffItem")) or HUDListManager.ListOptions.show_buffs <= 1 then
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
        do
       
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
                                --self._panel:stop()            --Should technically do this, but screws with unrelated animations for some reason...
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
                        --      self._parent_list:set_item_visible(self, false)
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
               
                --TODO: Move this color stuff. Good to have, but has nothing to do with the list and should be localized to subclasses where it is used
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
               
                        --local threshold = self._static_item and 1 or 0        --TODO
               
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
               
        end
       
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       
        --LIST ITEM CLASS DEFINITION BLOCK
        do
               
                --Right list
               
                HUDList.RightListItem = HUDList.RightListItem or class(HUDList.ItemBase)
                function HUDList.RightListItem:init(parent, name, icon, params)
                        params = params or {}
                        params.align = params.align or "right"
                        params.w = params.w or parent:panel():h() / 2
                        params.h = params.h or parent:panel():h()
                        HUDList.RightListItem.super.init(self, parent, name, params)
               
                        local x, y = unpack((icon.atlas or icon.spec) or { 0, 0 })
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
               
                function HUDList.RightListItem:set_count(num)
                        self._count = num
                        self._text:set_text(tostring(self._count))
                        if self._count > 0 then
                                self:activate()
                        else
                                self:deactivate()
                        end
                end
               
                function HUDList.RightListItem:_animate_change(text, duration, incr)
                        text:set_color(RightListColor or Color.white)
                       
                        local t = duration
                        while t > 0 do
                                local dt = coroutine.yield()
                                t = math.max(t - dt, 0)
                                local ratio = math.sin(t/duration * 1440 + 90) * 0.5 + 0.5
                                text:set_color(Color(incr and ratio or 1, incr and 1 or ratio, ratio))
                        end
                       
                        text:set_color(RightListColor or Color.white)
                end
               
                HUDList.UnitCountItem = HUDList.UnitCountItem or class(HUDList.RightListItem)
                HUDList.UnitCountItem.ENEMY_ICON_MAP = {
                        all =							{ atlas = {6, 1}, color = enemy_color, manual_add = true },     --Aggregated enemies
                        cop =							{ atlas = {0, 5}, color = enemy_color, priority = 5 },  --Non-special police
                        sniper =						{ atlas = {6, 5}, color = special_color, priority = 6 },
                        tank =							{ atlas = {3, 1}, color = special_color, priority = 6 },
                        taser =							{ atlas = {3, 5}, color = special_color, priority = 6 },
                        spooc =							{ atlas = {1, 3}, color = special_color, priority = 6 },
                        shield =						{ texture = "guis/textures/pd2/hud_buff_shield", color = special_color, priority = 6 },
                        security =						{ spec = {1, 4}, color = guard_color, priority = 4 },
                        mobster_boss =					{ atlas = {1, 1}, color = thug_color, priority = 4 },
                        thug =							{ atlas = {4, 12}, color = thug_color, priority = 4 },
                        phalanx =						{ texture = "guis/textures/pd2/hud_buff_shield", color = special_color, priority = 7 },
                }
               
                HUDList.UnitCountItem.HOSTAGE_ICON_MAP = {
                        cop_hostage =           { atlas = {2, 8}, color = hostage_color, priority = 2 },
                        civilian_hostage =      { atlas = {4, 7}, color = hostage_color, priority = 1 },
                }
                HUDList.UnitCountItem.MISC_ICON_MAP = {
                        turret =                { atlas = {7, 5}, color = turret_color, priority = 4 },
                        civilian =      { atlas = {6, 7}, color = civilian_color, priority = 3, class = "CivilianUnitCountItem" },
                        minion =        { atlas = {6, 8}, color = hostage_color, priority = 0, class = "MinionCountItem" },
                }
                function HUDList.UnitCountItem:init(parent, name, unit_data)
                        local unit_data = unit_data or HUDList.UnitCountItem.ENEMY_ICON_MAP[name] or HUDList.UnitCountItem.HOSTAGE_ICON_MAP[name] or HUDList.UnitCountItem.MISC_ICON_MAP[name]
                        local params = unit_data.priority and { priority = unit_data.priority }
                        HUDList.UnitCountItem.super.init(self, parent, name, unit_data, params)
 
                        if name == "all" then
                                table.insert(self._listener_clbks, { server = EnemyManager, name = "total_enemy_count", event = "on_total_enemy_count_change", clbk = callback(self, self, "set_count") })
                        else
                                table.insert(self._listener_clbks, { server = EnemyManager, name = name .. "_count", event = "on_" .. name .. "_count_change", clbk = callback(self, self, "set_count") })
                                self._unit_type = name
 
                                if name == "shield" then        --Shield special case for screwing around with the icon
                                        self._shield_filler = self._panel:rect({
                                                name = "shield_filler",
                                                w = self._icon:w() * 0.4,
                                                h = self._icon:h() * 0.4,
                                                color = special_color,
                                                blend_mode = "normal",
                                                layer = self._icon:layer() - 1,
                                        })
                                        self._shield_filler:set_center(self._icon:center())
                                --[[
                                        self._icon:set_w(self._panel:w() * 0.8)
                                        self._icon:set_right(self._panel:right() - self._icon:w() * 0.2)
                                       
                                        self._shield_icon = self._panel:bitmap({
                                                name = "shield_icon",
                                                texture = "guis/textures/pd2/skilltree/icons_atlas",
                                                texture_rect = { 2 * 64, 0, 64 * 0.3, 64 },
                                                rotation = 180,
                                                h = self._panel:w(),
                                                w = self._panel:w() * 0.4,
                                                blend_mode = "normal",
                                                color = special_color,
                                        })
                                        self._shield_icon:set_right(self._panel:right())
                                ]]
                                end
                        end
                       
                        self:set_count(managers.enemy:unit_count(self._unit_type) or 0)
                end
                
                HUDList.CivilianUnitCountItem = HUDList.CivilianUnitCountItem or class(HUDList.UnitCountItem)
                function HUDList.CivilianUnitCountItem:init(parent, name, unit_data)
                        HUDList.CivilianUnitCountItem.super.init(self, parent, name, unit_data)
                        table.insert(self._listener_clbks, { server = GroupAIStateBase, name = "civilian_count", event = "on_civilian_count_change", clbk = callback(self, self, "set_count") })
                end
               
                function HUDList.CivilianUnitCountItem:set_count(count)
                        HUDList.CivilianUnitCountItem.super.set_count(self, count - (managers.groupai:state():civilian_hostage_count() or 0))
                end
                       
                HUDList.HostageUnitCountItem = HUDList.HostageUnitCountItem or class(HUDList.UnitCountItem)
                function HUDList.HostageUnitCountItem:init(parent, name, unit_data)
                        HUDList.HostageUnitCountItem.super.init(self, parent, name, unit_data)
                        self._listener_clbks = {}       --Clear table of default EnemyManager callbacks
                        table.insert(self._listener_clbks, { server = GroupAIStateBase, name = name .. "_count", event = "on_" .. name .. "_count_change", clbk = callback(self, self, "set_count") })
                        self:set_count(managers.groupai:state():hostage_count_by_type(self._unit_type) or 0)
                end
               
                HUDList.MinionCountItem = HUDList.MinionCountItem or class(HUDList.UnitCountItem)
                function HUDList.MinionCountItem:init(parent, name, unit_data)
                        HUDList.MinionCountItem.super.init(self, parent, name, unit_data)
                        self:set_count(managers.enemy:minion_count() or 0)
                end
               
               
                HUDList.UsedPagersItem = HUDList.UsedPagersItem or class(HUDList.RightListItem)
                function HUDList.UsedPagersItem:init(parent, name)
                        HUDList.UsedPagersItem.super.init(self, parent, name, { spec = {1, 4} })
                       
                        table.insert(self._listener_clbks, { server = ObjectInteractionManager, name = "used_pager_count", event = "on_pager_count_change", clbk = callback(self, self, "set_count") })
                        table.insert(self._listener_clbks, { server = ObjectInteractionManager, name = "used_pager_count", event = "on_remove_all_pagers", clbk = callback(self, self, "delete") })
                       
                        self:set_count(managers.interaction:used_pager_count() or 0)
                end
               
                function HUDList.UsedPagersItem:set_count(num)
                        HUDList.UsedPagersItem.super.set_count(self, num)
                       
                        if self._count >= 5 then
                                self._text:set_color(Color.red)
                        end
                end
               
               
                HUDList.SpecialPickupItem = HUDList.SpecialPickupItem or class(HUDList.RightListItem)
                HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP = {
						crowbar =                                       { hudpickups = { 0, 64, 32, 32 } },
                        keycard =                                       { hudpickups = { 32, 0, 32, 32 } },
                        small_loot = 									{ hudpickups = { 32, 224, 32, 32} },
                        courier =                                       { atlas = { 6, 0 } },
                        planks =                                        { hudpickups = { 0, 32, 32, 32 } },
                        meth_ingredients =      						{ waypoints = { 192, 32, 32, 32 } },
						Blowtorch = 									{ hudpickups = { 96, 192, 32, 32 } },
						thermite = 										{ hudpickups = { 64, 64, 32, 32 } },
                }
                function HUDList.SpecialPickupItem:init(parent, name, pickup_data)
                        local pickup_data = pickup_data or HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP[name]
                        HUDList.SpecialPickupItem.super.init(self, parent, name, pickup_data)
                       
                        self._id = name
                        table.insert(self._listener_clbks, { server = ObjectInteractionManager, name = "special_pickup_count_" .. name, event = "on_" .. name .. "_count_change", clbk = callback(self, self, "set_count") })
                       
                        self:set_count(managers.interaction:special_pickup_count(self._id) or 0)
                end
               
               
                HUDList.LootItem = HUDList.LootItem or class(HUDList.RightListItem)
                HUDList.LootItem.LOOT_ICON_MAP = {
                        --If you add stuff here, be sure to add the loot type to ObjectInteractionManager as well
                        all =					{ manual_add = true },  --Aggregated loot
                        gold =					{ text = "Gold" },
                        money =					{ text = "Money" },
                        jewelry =				{ text = "Jewelry" },
                        painting =				{ text = "Painting" },
                        coke =					{ text = "Coke" },
                        meth =					{ text = "Meth" },
                        weapon =				{ text = "Weapon" },
                        server =				{ text = "Server" },
                        turret =				{ text = "Turret" },
                        shell =					{ text = "Shell" },
                        artifact =				{ text = "Artifact" },
                        armor =					{ text = "Armor" },
                        toast =					{ text = "Toast" },
                        diamond =				{ text = "Diamond" },
                        bomb =					{ text = "Bomb" },
                        evidence =				{ text = "Evidence" },
                        warhead =				{ text = "Nuke" },
                        dentist =				{ text = "Pandora" },
						pig =					{ text = "Pig" },
						safe =					{ text = "Safe" },
						prototype =				{ text = "Prototype" },
						charges =				{ text = "Charges" },
						MU =					{ text = "MU" },
						CS =					{ text = "CS" },
						HCL =					{ text = "HCL" },
						present =				{ text = "Gift" },	
						goat = 					{ text = "Goat" },
                        container =   			{ text = "Crate" },
                }
                function HUDList.LootItem:init(parent, name, loot_data)
                        local loot_data = loot_data or HUDList.LootItem.LOOT_ICON_MAP[name]
                        HUDList.LootItem.super.init(self, parent, name, loot_data.icon_data or { hudtabs = { 32, 32, 32, 32 }, alpha = 0.75, w_ratio = 1.2 })
               
                        self._icon:set_center(self._panel:center())
                        self._icon:set_top(self._panel:top())
                        if HUDListManager.ListOptions.separate_bagged_loot then
                                self._text:set_font_size(self._text:font_size() * 0.9)
                        end
 
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
                       
                        if name == "all" then
                                table.insert(self._listener_clbks, { server = ObjectInteractionManager, name = "loot_count_total", event = "on_total_loot_count_change", clbk = callback(self, self, "set_count") })
                        else
                                self._id = name
                                table.insert(self._listener_clbks, { server = ObjectInteractionManager, name = "loot_count_" .. name, event = "on_" .. name .. "_count_change", clbk = callback(self, self, "set_count") })
                        end
 
                        self._bagged_count = 0
                        local unbagged, bagged = managers.interaction:loot_count(self._id)
                        self:set_count(bagged or 0, unbagged or 0)
                end
                       
                function HUDList.LootItem:set_count(value, bagged_value)
                        local old_total = self._count + self._bagged_count
                        local new_total = value + bagged_value
                        if old_total > 0 and new_total > 0 then
                                self._text:stop()
                                self._text:animate(callback(self, self, "_animate_change"), 1, old_total < new_total)
                        end
                       
                        self._count = value
                        self._bagged_count = bagged_value
                        if HUDListManager.ListOptions.separate_bagged_loot then
                                self._text:set_text(self._count .. "/" .. self._bagged_count)
                        else
                                self._text:set_text(new_total)
                        end
                       
                        if self._count > 0 or self._bagged_count > 0 then
                                self:activate()
                        else
                                self:deactivate()
                        end
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
                function HUDList.TimerItem:init(parent, name, unit)
                        HUDList.ItemBase.init(self, parent, name, { align = "left", w = parent:panel():h() * 4/5, h = parent:panel():h() })
                       
                        self._show_distance = true
                        self._jammed = false
                        self._powered = true
                        self._unit = unit
                        self._name = name
                        self._flash_color_table = {
                                { ratio = 0.0, color = self.DISABLED_COLOR },
                                { ratio = 1.0, color = self.STANDARD_COLOR }
                        }
                        self._current_color = self.STANDARD_COLOR
                       
                        self._type_text = self._panel:text({
                                name = "type_text",
                                text = "Timer",
                                align = "center",
                                vertical = "top",
                                w = self._panel:w(),
                                h = self._panel:h() * 0.3,
                                color = TimerColor,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = self._panel:h() * 1/3
                        })
                       
                        self._box = HUDBGBox_create(self._panel, {
                                        w = self._panel:w(),
                                        h = self._panel:h() * 0.7,
                                }, {color = TimerColor, bg_color = TimerBgColor})
                        self._box:set_bottom(self._panel:bottom())
                       
                        self._distance_text = self._box:text({
                                name = "distance",
                                align = "center",
                                vertical = "top",
                                w = self._box:w(),
                                h = self._box:h(),
                                color = TimerColor,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = self._box:h() * 0.4
                        })
                       
                        self._time_text = self._box:text({
                                name = "time",
                                align = "center",
                                vertical = "bottom",
                                w = self._box:w(),
                                h = self._box:h(),
                                color = TimerColor,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = self._box:h() * 0.6
                        })
                       
                        self:_set_colors(self._current_color)
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
                        self._time_text:set_text(string.format("%d:%02d", time_left/60, time_left%60))
                end
				
				function HUDList.TimerItem:set_jammed(status)
                        self._jammed = status
                        self:_check_is_running()
                end
               
                function HUDList.TimerItem:set_jammed(status)
                        self._jammed = status
                        self:_check_is_running()
                end
               
                function HUDList.TimerItem:set_powered(status)
                        self._powered = status
                        self:_check_is_running()
                end
               
                function HUDList.TimerItem:_check_is_running()
                        if not self._jammed and self._powered then
                                self:_set_colors(self._current_color)
                        end
                end
               
                function HUDList.TimerItem:_set_colors(color)
                        self._time_text:set_color(color)
                        self._type_text:set_color(color)
                        self._distance_text:set_color(color)
                end
               
                function HUDList.TimerItem:set_can_upgrade(status)
                        self._can_upgrade = status
                        self._current_color = status and self.UPGRADE_COLOR or self.STANDARD_COLOR
                        self._flash_color_table[2].color = status and self.UPGRADE_COLOR or self.STANDARD_COLOR
                        self:_set_colors(self._current_color)
                end
               
                function HUDList.TimerItem:set_type(type)
                        self._type_text:set_text(type)
                end
               
               
                HUDList.TemperatureGaugeItem = HUDList.TemperatureGaugeItem or class(HUDList.TimerItem)
                function HUDList.TemperatureGaugeItem:init(parent, name, unit, params)
                        HUDList.TimerItem.init(self, parent, name, unit)
                       
                        self:set_type("Temp")
                        self._start = params.start
                        self._goal = params.goal
                        self._last_value = self._start
                end
               
                function HUDList.TemperatureGaugeItem:update(t, dt)
               
                end
               
                function HUDList.TemperatureGaugeItem:update_timer(t, value)
                        local ratio = math.clamp((value - self._start) / (self._goal - self._start), 0, 1) * 100
                        local dv = math.abs(self._last_value - value)
                        local estimate = "n/a"
                       
                        if dv > 0 then
                                local time_left = math.round(math.abs(self._goal - value) / dv)
                                estimate = string.format("%d:%02d", time_left/60, time_left%60)
                        end
               
                        self._distance_text:set_text(string.format("%.0f%%", ratio))
                        self._time_text:set_text(estimate)
                        self._last_value = value
                end
				
				HUDList.SecurityLockItem = HUDList.SecurityLockItem or class(HUDList.TimerItem)
                
				function HUDList.SecurityLockItem:init(parent, name, unit, params)
                        HUDList.TimerItem.init(self, parent, name, unit)
                       
                        self._distance_text:set_text(self.current_bar .. "/" .. self.bars)
                end
				
				function HUDList.SecurityLockItem:update(t, dt)
                        if not alive(self._unit) then
                                self:delete()
                                return
                        end
                        
                        if self._jammed or not self._powered then
                                local new_color = self:_get_color_from_table(math.sin(t*360 * self.FLASH_SPEED) * 0.5 + 0.5, 1, self._flash_color_table, self.STANDARD_COLOR)
                                self:_set_colors(new_color)
                        end
                end
               
                HUDList.EquipmentItem = HUDList.EquipmentItem or class(HUDList.ItemBase)
                HUDList.EquipmentItem.EQUIPMENT_TABLE = {
                        sentry = {              atlas = { 7,  5 }, priority = 1 },
                        ammo_bag = {            atlas = { 1,  0 }, priority = 3 },
                        doc_bag = {             atlas = { 2,  7 }, priority = 4 },
                        body_bag = {            atlas = { 5, 11 }, priority = 5 },
                        grenade_crate = { preplanning = { 1,  0 }, priority = 2 },
                }
                function HUDList.EquipmentItem:init(parent, name, equipment_type, unit)
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
                                }, {color = EquipmentColor, bg_color = EquipmentBgColor})
                       
                        self._icon = self._panel:bitmap({
                                name = "icon",
                                texture = texture,
                                texture_rect = texture_rect,
                                h = self:panel():w() * 0.8,
                                w = self:panel():w() * 0.8,
                                blend_mode = "add",
                                layer = 0,
                                color = EquipmentColor,
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
                end
               
                function HUDList.EquipmentItem:set_owner(peer_id)
                        self._owner = peer_id
                        self:_set_color()
                end
               
                function HUDList.EquipmentItem:get_type()
                        return self._type
                end
               
                function HUDList.EquipmentItem:_set_color()
                        if self._owner then
                                local color = self._owner > 0 and tweak_data.chat_colors[self._owner]:with_alpha(1) or EquipmentColor or Color.white
                                self._icon:set_color(color)
                        end
                end
               
                HUDList.BagEquipmentItem = HUDList.BagEquipmentItem or class(HUDList.EquipmentItem)
               
                function HUDList.BagEquipmentItem:init(parent, name, equipment_type, unit)
                        HUDList.EquipmentItem.init(self, parent, name, equipment_type, unit)
                        self._amount_format = "%.0f" .. (equipment_type == "ammo_bag" and "%%" or "")
                        self._amount_offset = 0
                end
               
                function HUDList.BagEquipmentItem:current_amount()
                        return self._current_amount
                end
               
                function HUDList.BagEquipmentItem:set_max_amount(max_amount)
                        self._max_amount = (max_amount or 0) + self._amount_offset
                        self:_update_info_text()
                end
               
                function HUDList.BagEquipmentItem:set_amount(amount)
                        self._current_amount = (amount or 0) + self._amount_offset
                        self:_update_info_text()
                end
               
                function HUDList.BagEquipmentItem:set_amount_offset(offset)
                        self._amount_offset = offset or 0
                        self:set_max_amount(self._max_amount)
                        self:set_amount(self._current_amount)
                end
               
                function HUDList.BagEquipmentItem:_update_info_text()
                        if self._current_amount and self._max_amount then
                                self._info_text:set_text(string.format(self._amount_format, self._current_amount))
                                self._info_text:set_color(self:_get_color_from_table(self._current_amount, self._max_amount))
                        end
                end
               
               
                HUDList.SentryEquipmentItem = HUDList.SentryEquipmentItem or class(HUDList.EquipmentItem)
                function HUDList.SentryEquipmentItem:init(parent, name, unit)
                        HUDList.EquipmentItem.init(self, parent, name, "sentry", unit)
                        self:set_ammo_ratio(unit:weapon() and unit:weapon():ammo_ratio() or 0)
                        self:set_ammo_ratio(unit:character_damage() and unit:character_damage():health_ratio() or 0)
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
                HUDList.MinionItem._UNIT_NAMES = {
                        security = "Security",
                        gensec = "Security",
                        cop = "Cop",
                        fbi = "FBI",
                        swat = "SWAT",
                        heavy_swat = "H. SWAT",
                        fbi_swat = "FBI SWAT",
                        fbi_heavy_swat = "H. FBI SWAT",
                        city_swat = "GenSec",
                }
                function HUDList.MinionItem:init(parent, name, unit)
                        HUDList.MinionItem.super.init(self, parent, name, { align = "center", w = parent:panel():h() * 4/5, h = parent:panel():h() })
                       
                        self._unit = unit
                        self._max_health = unit:character_damage()._HEALTH_INIT
                        local type_str = self._UNIT_NAMES[unit:base()._tweak_table] or "UNKNOWN"
               
                        self._health_bar = self._panel:bitmap({
                                name = "radial_health",
                                texture = "guis/textures/pd2/hud_health",
                                texture_rect = { 64, 0, -64, 64 },
                                render_template = "VertexColorTexturedRadial",
                                blend_mode = "sub",
                                layer = 2,
                                color = Color(1, 0, 0, 0),
                                w = self._panel:w(),
                                h = self._panel:w(),
                        })
                        self._health_bar:set_bottom(self._panel:bottom())
						
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
                                text = type_str,
                                align = "center",
                                vertical = "top",
                                w = self._panel:w(),
                                h = self._panel:w() * 0.3,
                                color = Color.white,
                                layer = 3,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = math.min(8 / string.len(type_str), 1) * 0.25 * self._panel:h(),
                        })
 
                        self:set_health(self._max_health, true)
                end
               
                function HUDList.MinionItem:set_health(health, skip_animate)
                        local red = 1 - (health/ self._max_health)
						self._health_bar:set_color(Color(1, red, 1, 1))
						self._health_bar:set_rotation(360 * red)
                       
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
                                }, {color = PagerColor, bg_color = PagerbgColor})
 
                        self._timer_text = self._box:text({
                                name = "time",
                                align = "center",
                                vertical = "top",
                                w = self._box:w(),
                                h = self._box:h(),
                                color = Color.red,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = self._box:h() * 0.5,
                                text = string.format("%.1fs", self._duration_t)
                        })
                       
                        self._distance_text = self._box:text({
                                name = "distance",
                                align = "center",
                                vertical = "bottom",
                                w = self._box:w(),
                                h = self._box:h(),
                                color = PagerColor,
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
                                self._timer_text:set_text(string.format("%.1fs", self._duration_t))
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
                                }, {color = ECMColor, bg_color = ECMBgColor})
                       
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
               
                function HUDList.ECMItem:update_timer(t, time_left)
                        self._text:set_text(string.format("%.1f", time_left))
                        self._text:set_color(self:_get_color_from_table(time_left, self._max_duration))
                end
               
               
                HUDList.ECMRetriggerItem = HUDList.ECMRetriggerItem or class(HUDList.ECMItem)
                function HUDList.ECMRetriggerItem:init(parent, name)
                        HUDList.ECMRetriggerItem.super.init(self, parent, name)
                       
                        self._max_duration = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
                end
               
                function HUDList.ECMRetriggerItem:update_timer(t, time_left)
                        local text = ""
                        if time_left > 60 then
                                text = string.format("%d:%02d", time_left/60, time_left%60)
                        else
                                text = string.format("%d", time_left)
                        end
                        self._text:set_text(text)
                        self._text:set_color(self:_get_color_from_table(self._max_duration - time_left, self._max_duration))
                end
               
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
                                }, {color = TapeLoopColor, bg_color = TapeLoopBgColor})
                       
                        self._text = self._box:text({
                                name = "text",
                                align = "center",
                                vertical = "center",
                                w = self._box:w(),
                                h = self._box:h(),
                                color = TapeLoopColor,
                                font = tweak_data.hud_corner.assault_font,
                                font_size = self._box:h() * 0.6,
                        })
                end
               
                function HUDList.TapeLoopItem:set_duration(duration)
                        self._duration = duration
                        self._text:set_text(string.format("%.1f", self._duration))
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
                        hostage_situation = {                   spec = { 0, 1 },                priority = 2,   type = "buff" },
                        partner_in_crime = {                    atlas = { 1, 10 },      priority = 2,   type = "buff" },
                        hostage_taker = {                               atlas = { 2, 10 },      priority = 2,   type = "buff", 
                                icon_scale = 1.35
                        },
                        underdog = {                                            atlas = { 2, 1 },               priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        overdog = {                                             spec = { 6, 4 },                priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        close_combat = {                                spec = { 5, 4 },                priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        combat_medic = {                                atlas = { 5, 7 },               priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        overkill = {                                                    atlas = { 3, 2 },               priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        bullet_storm = {                                        atlas = { 4, 5 },               priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        pain_killer = {                                 atlas = { 0, 10 },      priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        swan_song = {                                   atlas = { 5, 12 },      priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        quick_fix = {                                           atlas = { 1, 11 },      priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        trigger_happy = {                               atlas = { 7, 11 },      priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        inspire = {                                                     atlas = { 4, 9 },               priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        melee_stack_damage = {  spec = { 5, 4 },                priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        damage_to_hot = {                       spec = { 4, 6 },                priority = 3,   type = "buff",                  class = "TimedBuffItem" },
                        sixth_sense = {                                 atlas = { 6, 10 },      priority = 3,   type = "buff",                  class = "TimedBuffItem",
                                flash_color = Color.blue,
                                flash_speed = tweak_data.player.omniscience.interval_t * 0.5
                        },
                        bow_charge = {                                                                                          priority = 3,   type = "buff",                  class = "ChargedBuffItem",
                                texture = "guis/dlcs/west/textures/pd2/blackmarket/icons/weapons/plainsrider",
                                icon_rotation = 90,
                                icon_w_ratio = 0.5,
                                icon_scale = 2,
                                flash_speed = 0.2,
                                no_fade = true
                        },
                        melee_charge = {                                atlas = { 4, 10 },      priority = 3,   type = "buff",                  class = "ChargedBuffItem",
                                flash_speed = 0.2,
                                no_fade = true
                        },
                        berserker = {                                           atlas = { 2, 2 },               priority = 2,   type = "buff",                  class = "BerserkerBuffItem" },
                        crew_chief = {                                  atlas = { 2, 7 },               priority = 1,   type = "team" },
                        leadership = {                                  atlas = { 7, 7 },               priority = 1,   type = "team" },
                        bulletproof = {                                 atlas = { 6, 4 },               priority = 1,   type = "team",
                                aced = true,
                        },
                        armorer = {                                             spec = { 6, 0 },                priority = 1,   type = "team",
                                level = 9,
                        },
                        endurance = {                                   atlas = { 1, 8 },               priority = 1,   type = "team",
                                aced = true,
                        },
                        life_drain = {                                          spec = { 7, 4 },                priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        medical_supplies = {                    spec = { 4, 5 },                priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        ammo_give_out = {                       spec = { 5, 5 },                priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        inspire_debuff = {                              atlas = { 4, 9 },               priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        bullseye_debuff = {                     atlas = { 6, 11 },      priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        tension_debuff = {                              spec = { 0, 5 },                priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        damage_to_hot_debuff = {        spec = { 4, 6 },                priority = 5,   type = "debuff",                class = "TimedBuffItem" },
                        armor_regen_debuff = {          spec = { 6, 0 },                priority = 5,   type = "debuff",                class = "TimedBuffItem",
                                no_fade = true
                        },
                        suppression_debuff = {          atlas = { 7, 0 },               priority = 5,   type = "debuff",                class = "SuppressionBuffItem",
                                flash_speed = 0.25,
                                no_fade = true
                        },
                }
               
                HUDList.BuffItemBase.IGNORED_BUFFS = {
				hostage_situation = false,
				partner_in_crime = false,
				hostage_taker = false,
				underdog = false,
				underdog_aced = false,
				overdog = false,
				close_combat = false,
				combat_medic = false,
				overkill = false,
				bullet_storm = false,
				pain_killer = false,
				swan_song = false,
				quick_fix = false,
				trigger_happy = false,
				inspire = false,
				melee_stack_damage = false,
				damage_to_hot = false,
				sixth_sense = false,
				bow_charge = false,
				melee_charge = false,
				berserker = false,
				crew_chief = false,
				crew_chief_3 = false,
				crew_chief_5 = false,
				crew_chief_7 = false,
				crew_chief_9 = false,
				leadership = false,
				leadership_aced = false,
				bulletproof = false,
				armorer = false,
				endurance = false,
				life_drain = false,
				medical_supplies = false,
				ammo_give_out = false,
				inspire_debuff = false,
				bullseye_debuff = false,
				tension_debuff = false,
				damage_to_hot_debuff = false,
				armor_regen_debuff = false,
				suppression_debuff = true,
                }
               
                HUDList.BuffItemBase.COMPOSITE_ITEMS = {
                        underdog_aced = {               item = "underdog",              keep_on_deactivation = true,
                                aced = function()
                                        return true
                                end
                        },
                        leadership = {                  item = "leadership",
                                aced = function()
                                        return managers.player:has_team_category_upgrade("weapon", "recoil_multiplier") or managers.player:has_team_category_upgrade("weapon", "suppression_recoil_multiplier")
                                end
                        },
                        crew_chief_3 = {                item = "crew_chief",
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
                                texture ="guis/textures/pd2/equip_count",
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
                end
               
                function HUDList.TimedBuffItem:set_duration(duration)
                        self._duration = duration
                end
               
                function HUDList.TimedBuffItem:refresh()
                        self:set_progress(0)
                end
               
                function HUDList.TimedBuffItem:set_progress(ratio)
                        self._timer._circle:set_color(Color(1, ratio, 1, 1))    --TODO: why the hell wont set_current directly on the timer work?
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
               
                if self:get_real_armor() >= self:_total_armor() then
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
 
if RequiredScript == "lib/units/props/timergui" then
 
        TimerGui.SPAWNED_ITEMS = {}
        TimerGui._LISTENER_CALLBACKS = {}
 
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
                TimerGui.SPAWNED_ITEMS[unit:key()] = { unit = unit, powered = true }
                self._do_listener_callback("on_create", unit)
                init_original(self, unit, ...)
                self._device_type = unit:base().is_drill and "Drill" or unit:base().is_hacking_device and "Hack" or unit:base().is_saw and "Saw" or "Unknown"
                TimerGui.SPAWNED_ITEMS[self._unit:key()].type = self._device_type
                self._do_listener_callback("on_type_set", unit, self._device_type)
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
               
                TimerGui.SPAWNED_ITEMS[self._unit:key()].can_upgrade = can_upgrade or nil
                self._do_listener_callback("on_can_upgrade", self._unit, can_upgrade)
               
                return set_background_icons_original(self, ...)
        end
       
        function TimerGui:set_visible(visible, ...)
                if not visible and self._unit:base().is_drill then
                        TimerGui.SPAWNED_ITEMS[self._unit:key()].active = nil
                        self._do_listener_callback("on_set_active", self._unit, visible)
                end
                return set_visible_original(self, visible, ...)
        end
       
        function TimerGui:update(unit, t, ...)
                update_original(self, unit, t, ...)
				self._gui_script.time_text:set_text(string.format("%d:%02d", self._time_left/60, self._time_left%60))
                TimerGui.SPAWNED_ITEMS[self._unit:key()].t = t
                TimerGui.SPAWNED_ITEMS[self._unit:key()].time_left = self._time_left
                self._do_listener_callback("on_update", self._unit, t, self._time_left)
        end
 
        function TimerGui:_start(...)
                TimerGui.SPAWNED_ITEMS[self._unit:key()].active = true
                self._do_listener_callback("on_set_active", self._unit, true)
                return _start_original(self, ...)
        end
       
        function TimerGui:_set_done(...)
                TimerGui.SPAWNED_ITEMS[self._unit:key()].active = nil
                self._do_listener_callback("on_set_active", self._unit, false)
                return _set_done_original(self, ...)
        end
       
        function TimerGui:_set_jammed(jammed, ...)
                TimerGui.SPAWNED_ITEMS[self._unit:key()].jammed = jammed and true or nil
                self._do_listener_callback("on_set_jammed", self._unit, jammed and true or false)
                return _set_jammed_original(self, jammed, ...)
        end
       
        function TimerGui:_set_powered(powered, ...)
                TimerGui.SPAWNED_ITEMS[self._unit:key()].powered = powered and true or nil
                self._do_listener_callback("on_set_powered", self._unit, powered and true or false)
                return _set_powered(self, powered, ...)
        end
       
        function TimerGui:destroy(...)
                TimerGui.SPAWNED_ITEMS[self._unit:key()] = nil
                self._do_listener_callback("on_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
       
        function TimerGui.register_listener_clbk(name, event, clbk)
                TimerGui._LISTENER_CALLBACKS[event] = TimerGui._LISTENER_CALLBACKS[event] or {}
                TimerGui._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function TimerGui.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(TimerGui._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                TimerGui._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function TimerGui._do_listener_callback(event, ...)
                if TimerGui._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(TimerGui._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end

if RequiredScript == "lib/units/props/securitylockgui" then
		SecurityLockGui.SPAWNED_ITEMS = {}
        SecurityLockGui._LISTENER_CALLBACKS = {}
		
		local init_original = SecurityLockGui.init
        --local set_background_icons_original = SecurityLockGui.set_background_icons
        local set_visible_original = SecurityLockGui.set_visible
        local update_original = SecurityLockGui.update
        local _start_original = SecurityLockGui._start
        local _set_done_original = SecurityLockGui._set_done
        local _set_jammed_original = SecurityLockGui._set_jammed
        local _set_powered = SecurityLockGui._set_powered
        local destroy_original = SecurityLockGui.destroy
       
        function SecurityLockGui:init(unit, ...)
                SecurityLockGui.SPAWNED_ITEMS[unit:key()] = { unit = unit, powered = true }
                self._do_listener_callback("on_create", unit)
                init_original(self, unit, ...)
                self._device_type = "Hack"
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].type = self._device_type
				self._do_listener_callback("on_type_set", unit, self._device_type)
        end
       
        function SecurityLockGui:set_visible(visible, ...)
                return set_visible_original(self, visible, ...)
        end
       
        function SecurityLockGui:update(unit, t, ...)
                update_original(self, unit, t, ...)
				self._gui_script.time_text:set_text(string.format("%d:%02d", self._current_timer/60, self._current_timer%60))
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].t = t
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].time_left = self._current_timer
                self._do_listener_callback("on_update", self._unit, t, self._current_timer)
        end
 
        function SecurityLockGui:_start(...)
				local res = _start_original(self, ...)
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].active = true
				--SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].type = self._device_type .. " " .. self._current_bar
                self._do_listener_callback("on_set_active", self._unit, true)
                return res
        end
       
        function SecurityLockGui:_set_done(...)
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].active = nil
                self._do_listener_callback("on_set_active", self._unit, false)
                return _set_done_original(self, ...)
        end
       
        function SecurityLockGui:_set_jammed(jammed, ...)
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].jammed = jammed and true or nil
                self._do_listener_callback("on_set_jammed", self._unit, jammed and true or false)
                return _set_jammed_original(self, jammed, ...)
        end
       
        function SecurityLockGui:_set_powered(powered, ...)
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()].powered = powered and true or nil
                self._do_listener_callback("on_set_powered", self._unit, powered and true or false)
                return _set_powered(self, powered, ...)
        end
       
        function SecurityLockGui:destroy(...)
                SecurityLockGui.SPAWNED_ITEMS[self._unit:key()] = nil
                self._do_listener_callback("on_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
       
        function SecurityLockGui.register_listener_clbk(name, event, clbk)
                SecurityLockGui._LISTENER_CALLBACKS[event] = SecurityLockGui._LISTENER_CALLBACKS[event] or {}
                SecurityLockGui._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function SecurityLockGui.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(SecurityLockGui._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                SecurityLockGui._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function SecurityLockGui._do_listener_callback(event, ...)
                if SecurityLockGui._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(SecurityLockGui._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
end
 
if RequiredScript == "lib/units/props/digitalgui" then
 
        DigitalGui.SPAWNED_ITEMS = {}
        DigitalGui._LISTENER_CALLBACKS = {}
       
        DigitalGui._DEFAULT_CALLBACKS = {
                update = function(unit, t, timer)
                        DigitalGui.SPAWNED_ITEMS[unit:key()].t = t
                        DigitalGui.SPAWNED_ITEMS[unit:key()].timer = timer
                        DigitalGui._do_listener_callback("on_timer_update", unit, t, timer)
                end,
                timer_set = function(unit, timer)
                        DigitalGui._DEFAULT_CALLBACKS.update(unit, Application:time(), timer)
                end,
                timer_start_count = function(unit, up)
                        if unit:digital_gui()._visible then
                                DigitalGui.SPAWNED_ITEMS[unit:key()].active = true
                                DigitalGui._do_listener_callback("on_set_active", unit, true)
                                DigitalGui._DEFAULT_CALLBACKS.timer_pause(unit, false)
                        end
                end,
                timer_pause = function(unit, paused)
                        DigitalGui.SPAWNED_ITEMS[unit:key()].jammed = paused and true or nil
                        DigitalGui._do_listener_callback("on_set_jammed", unit, paused and true or false)
                end,
                timer_stop = function(unit)
                        DigitalGui.SPAWNED_ITEMS[unit:key()].active = nil
                        DigitalGui._do_listener_callback("on_set_active", unit, false)
                end
        }
       
        local function stop_on_pause(unit, paused)
                if paused then
                        DigitalGui._DEFAULT_CALLBACKS.timer_stop(unit)
                else
                        DigitalGui._DEFAULT_CALLBACKS.timer_pause(unit, paused)
                end
        end
       
        local function stop_on_loud_pause(unit, paused)
                if not managers.groupai:state():whisper_mode() and paused then
                        DigitalGui._DEFAULT_CALLBACKS.timer_stop(unit)
                else
                        DigitalGui._DEFAULT_CALLBACKS.timer_pause(unit, paused)
                end
        end
       
        DigitalGui._TIMER_DATA = {
                [132864] = {    									--Meltdown vault temperature
                        class = "TemperatureGaugeItem",
                        params = { start = 0, goal = 50 },
                       
                        timer_set = function(unit, timer, ...)
                                if timer > 0 then
                                        DigitalGui._DEFAULT_CALLBACKS.timer_start_count(unit, true)
                                end
                                DigitalGui._DEFAULT_CALLBACKS.timer_set(unit, timer, ...)
                        end,
                        timer_start_count = function(unit, ...)
                                unit:digital_gui()._ignore = true
                                DigitalGui._DEFAULT_CALLBACKS.timer_stop(unit)
                        end,
                        timer_pause = false,
                },
                [139706] = { timer_pause = stop_on_pause },     	--Hoxton Revenge alarm  (UNTESTED)
                [132675] = { timer_pause = stop_on_loud_pause },    --Hoxton Revenge panic room time lock   (UNTESTED)
                [101936] = { timer_pause = stop_on_pause },     	--GO Bank time lock
                [133922] = { timer_pause = stop_on_loud_pause },    --The Diamond pressure plates timer
                [130320] = { }, 									--The Diamond outer time lock
                [130395] = { }, 									--The Diamond inner time lock
                [101457] = { }, 									--Big Bank time lock door #1
                [104671] = { }, 									--Big Bank time lock door #2
                [167575] = { }, 									--Golden Grin BFD timer
        }
        for i, editor_id in ipairs({ 130022, 130122, 130222, 130322, 130422, 130522 }) do               --Train heist vaults (1-6)
                DigitalGui._TIMER_DATA[editor_id] = { timer_pause = stop_on_loud_pause }
        end
       
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
                init_original(self, unit, ...)
               
                if self.TYPE == "number" then
                        self._ignore = true
                else
                        DigitalGui.SPAWNED_ITEMS[unit:key()] = { unit = unit, jammed = false, powered = true }
                end
        end
       
        function DigitalGui:update(unit, t, ...)
                update_original(self, unit, t, ...)
                self:_do_timer_callback("update", t, self._timer)
        end
       
        function DigitalGui:timer_set(timer, ...)
                if not self._timer_callbacks and not self._ignore and Network:is_server() then
                        self:_setup_timer_data()
                end
               
                self:_do_timer_callback("timer_set", timer)
                return timer_set_original(self, timer, ...)
        end
       
        function DigitalGui:timer_start_count_up(...)
                self:_do_timer_callback("timer_start_count", true)
                return timer_start_count_up_original(self, ...)
        end
       
        function DigitalGui:timer_start_count_down(...)
                self:_do_timer_callback("timer_start_count", false)
                return timer_start_count_down_original(self, ...)
        end
       
        function DigitalGui:timer_pause(...)
                self:_do_timer_callback("timer_pause", true)
                return timer_pause_original(self, ...)
        end
       
        function DigitalGui:timer_resume(...)
                self:_do_timer_callback("timer_pause", false)
                return timer_resume_original(self, ...)
        end
       
        function DigitalGui:_timer_stop(...)
                self:_do_timer_callback("timer_stop")
                return _timer_stop_original(self, ...)
        end
       
        function DigitalGui:load(data, ...)
                if not self._ignore then
                        self:_setup_timer_data()
                        --DEBUG_PRINT("timer", "TIMER EVENT: load (" ..tostring(self._name_id or self._unit:editor_id()) .. ")\n", true)
                end
               
                load_original(self, data, ...)
               
                local state = data.DigitalGui
                if state.timer then
                        self:_do_timer_callback("timer_set", state.timer)
                end
                if state.timer_count_up then
                        self:_do_timer_callback("timer_start_count", true)
                end
                if state.timer_count_down then
                        self:_do_timer_callback("timer_start_count", false)
                end
                if state.timer_paused then
                        self:_do_timer_callback("timer_pause", true)
                end
        end
       
        function DigitalGui:destroy(...)
                DigitalGui.SPAWNED_ITEMS[self._unit:key()] = nil
                DigitalGui._do_listener_callback("on_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
       
        function DigitalGui:_do_timer_callback(event, ...)
                if not self._ignore then
                --[[
                        if event ~= "update" then
                                local str = "TIMER EVENT: " .. tostring(event) .. " (" .. tostring(self._name_id or self._unit:editor_id()) .. ")\n"
                                for i, v in ipairs({ ... }) do
                                        str = str .. "\t" .. tostring(v) .. "\n"
                                end
                                DEBUG_PRINT("timer", str, event ~= "update")
                        end
                ]]
                       
                        if self._timer_callbacks[event] == false then
                                return
                        elseif self._timer_callbacks[event] then
                                self._timer_callbacks[event](self._unit, ...)
                        elseif DigitalGui._DEFAULT_CALLBACKS[event] then
                                DigitalGui._DEFAULT_CALLBACKS[event](self._unit, ...)
                        end
                end
        end
       
        function DigitalGui:_setup_timer_data()
                local timer_data = DigitalGui._TIMER_DATA[self._unit:editor_id()] or {}
                DigitalGui.SPAWNED_ITEMS[self._unit:key()].class = timer_data.class
                DigitalGui.SPAWNED_ITEMS[self._unit:key()].params = timer_data.params
                DigitalGui.SPAWNED_ITEMS[self._unit:key()].ignore = timer_data.ignore
                self._name_id = timer_data.name_id
                self._ignore = timer_data.ignore
                self._timer_callbacks = {
                        update = timer_data.update,
                        timer_set = timer_data.timer_set,
                        timer_start_count = timer_data.timer_start_count,
                        timer_start_count = timer_data.timer_start_count,
                        timer_pause = timer_data.timer_pause,
                        timer_stop = timer_data.timer_stop,
                }
               
                DigitalGui._do_listener_callback("on_create", self._unit, timer_data.class, timer_data.params)
        end
       
       
        function DigitalGui.register_listener_clbk(name, event, clbk)
                DigitalGui._LISTENER_CALLBACKS[event] = DigitalGui._LISTENER_CALLBACKS[event] or {}
                DigitalGui._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function DigitalGui.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(DigitalGui._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                DigitalGui._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function DigitalGui._do_listener_callback(event, ...)
                if DigitalGui._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(DigitalGui._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end
 
if RequiredScript == "lib/units/unitbase" then
 
        --Propagates down to equipment (and other things we don't care about). Just make sure events are named appropriately to avoid overlap
        UnitBase._LISTENER_CALLBACKS = {}
       
        function UnitBase:set_equipment_active(equipment, status, offset)
                local base_class = _G[equipment]
                local bag_data = base_class.SPAWNED_BAGS[self._unit:key()]
               
                if bag_data then
                        bag_data.active = status
                        bag_data.amount_offset = offset or 0
                        base_class._do_listener_callback("on_bag_set_active", self._unit, status)
                        base_class._do_listener_callback("on_bag_amount_offset_update", self._unit, offset or 0)
                elseif self._is_aggregated and status then
                        base_class.AGGREAGATED_ITEM_ACTIVE = true
                        base_class._do_listener_callback("on_bag_set_active", nil, true)
                end
        end
       
       
        function UnitBase.register_listener_clbk(name, event, clbk)
                UnitBase._LISTENER_CALLBACKS[event] = GroupAIStateBase._LISTENER_CALLBACKS[event] or {}
                UnitBase._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function UnitBase.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(UnitBase._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                UnitBase._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function UnitBase._do_listener_callback(event, ...)
                if UnitBase._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(UnitBase._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end
 
if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
 
        SentryGunBase.SPAWNED_SENTRIES = {}
 
        local spawn_original = SentryGunBase.spawn
        local init_original = SentryGunBase.init
        local sync_setup_original = SentryGunBase.sync_setup
        local activate_as_module_original = SentryGunBase.activate_as_module
        local destroy_original = SentryGunBase.destroy
       
        function SentryGunBase.spawn(owner, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, peer_id, ...)
                local unit = spawn_original(owner, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, peer_id, ...)
                if not SentryGunBase.SPAWNED_SENTRIES[unit:key()] then
                        SentryGunBase.SPAWNED_SENTRIES[unit:key()] = { unit = unit }
                        UnitBase._do_listener_callback("on_sentry_create", unit)
                end
                SentryGunBase.SPAWNED_SENTRIES[unit:key()].owner = peer_id
                UnitBase._do_listener_callback("on_sentry_owner_update", unit, peer_id)
                return unit
        end
       
        function SentryGunBase:init(unit, ...)
                if not SentryGunBase.SPAWNED_SENTRIES[unit:key()] then
                        SentryGunBase.SPAWNED_SENTRIES[unit:key()] = { unit = unit }
                        UnitBase._do_listener_callback("on_sentry_create", unit)
                end
                init_original(self, unit, ...)
        end
       
        function SentryGunBase:sync_setup(upgrade_lvl, peer_id, ...)
                SentryGunBase.SPAWNED_SENTRIES[self._unit:key()].owner = peer_id
                UnitBase._do_listener_callback("on_sentry_owner_update", self._unit, peer_id)
                return sync_setup_original(self, upgrade_lvl, peer_id, ...)
        end
       
        function SentryGunBase:activate_as_module(...)
                SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] = nil
                UnitBase._do_listener_callback("on_sentry_destroy", self._unit)
                return activate_as_module_original(self, ...)
        end
       
        function SentryGunBase:destroy(...)
                SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] = nil
                UnitBase._do_listener_callback("on_sentry_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
end
 
if RequiredScript == "lib/units/equipment/sentry_gun/sentrygundamage" then
 
        local init_original = SentryGunDamage.init
        local set_health_original = SentryGunDamage.set_health
        local _apply_damage_original = SentryGunDamage._apply_damage
        local die_original = SentryGunDamage.die
        local load_original = SentryGunDamage.load
 
        function SentryGunDamage:init(...)
                init_original(self, ...)
                if SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] then
                        SentryGunBase.SPAWNED_SENTRIES[self._unit:key()].active = true
                        UnitBase._do_listener_callback("on_sentry_set_active", self._unit, true)
                        self:_update_health()
                end
        end
       
        function SentryGunDamage:set_health(...)
                set_health_original(self, ...)
                self:_update_health()
        end
       
        function SentryGunDamage:_apply_damage(...)
                local result = _apply_damage_original(self, ...)
                self:_update_health()
                return result
        end
       
        function SentryGunDamage:die(...)
                die_original(self, ...)
                if SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] then
                        SentryGunBase.SPAWNED_SENTRIES[self._unit:key()].active = nil
                        UnitBase._do_listener_callback("on_sentry_set_active", self._unit, false)
                end
        end
 
        function SentryGunDamage:load(...)
                load_original(self, ...)
                self:_update_health()
        end
       
       
        function SentryGunDamage:_update_health()
                if SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] then
                        SentryGunBase.SPAWNED_SENTRIES[self._unit:key()].health = self:health_ratio()
                        UnitBase._do_listener_callback("on_sentry_health_update", self._unit, self:health_ratio())
                end
        end
       
end
 
if RequiredScript == "lib/units/weapons/sentrygunweapon" then
 
        local init_original = SentryGunWeapon.init
        local change_ammo_original = SentryGunWeapon.change_ammo
        local sync_ammo_original = SentryGunWeapon.sync_ammo
        local load_original = SentryGunWeapon.load
 
        function SentryGunWeapon:init(...)
                init_original(self, ...)
                self:_update_ammo()
        end
       
        function SentryGunWeapon:change_ammo(...)
                change_ammo_original(self, ...)
                self:_update_ammo()
        end
       
        function SentryGunWeapon:sync_ammo(...)
                sync_ammo_original(self, ...)
                self:_update_ammo()
        end
       
        function SentryGunWeapon:load(...)
                load_original(self, ...)
                self:_update_ammo()
        end
 
        function SentryGunWeapon:_update_ammo()
                if SentryGunBase.SPAWNED_SENTRIES[self._unit:key()] then
                        local ammo_ratio = self:ammo_ratio()
                        SentryGunBase.SPAWNED_SENTRIES[self._unit:key()].ammo = ammo_ratio
                        UnitBase._do_listener_callback("on_sentry_ammo_update", self._unit, ammo_ratio)
                end
        end
       
end
 
if RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" then
 
        DoctorBagBase.SPAWNED_BAGS = {}
       
        local spawn_original = DoctorBagBase.spawn
        local init_original = DoctorBagBase.init
        local sync_setup_original = DoctorBagBase.sync_setup
        local _set_visual_stage_original = DoctorBagBase._set_visual_stage
        local destroy_original = DoctorBagBase.destroy
       
        function DoctorBagBase.spawn(pos, rot, amount_upgrade_lvl, peer_id, ...)
                local unit = spawn_original(pos, rot, amount_upgrade_lvl, peer_id, ...)
                DoctorBagBase.SPAWNED_BAGS[unit:key()] = DoctorBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                DoctorBagBase.SPAWNED_BAGS[unit:key()].owner = peer_id
                UnitBase._do_listener_callback("on_bag_create", unit, "doc_bag")
                UnitBase._do_listener_callback("on_bag_owner_update", unit, peer_id)
                return unit
        end
       
        function DoctorBagBase:init(unit, ...)
                DoctorBagBase.SPAWNED_BAGS[unit:key()] = DoctorBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                self._do_listener_callback("on_bag_create", unit, "doc_bag")
                init_original(self, unit, ...)
                DoctorBagBase.SPAWNED_BAGS[unit:key()].max_amount = self._max_amount
                self._do_listener_callback("on_bag_max_amount_update", unit, self._max_amount)
        end
       
        function DoctorBagBase:sync_setup(amount_upgrade_lvl, peer_id, ...)
                DoctorBagBase.SPAWNED_BAGS[self._unit:key()].owner = peer_id
                self._do_listener_callback("on_bag_owner_update", self._unit, peer_id)
                return sync_setup_original(self, amount_upgrade_lvl, peer_id, ...)
        end
       
        function DoctorBagBase:_set_visual_stage(...)
                DoctorBagBase.SPAWNED_BAGS[self._unit:key()].amount = self._amount
                self._do_listener_callback("on_bag_amount_update", self._unit, self._amount)
                return _set_visual_stage_original(self, ...)
        end
       
        function DoctorBagBase:destroy(...)
                DoctorBagBase.SPAWNED_BAGS[self._unit:key()] = nil
                self._do_listener_callback("on_bag_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
end
 
if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" then
 
        AmmoBagBase.SPAWNED_BAGS = {}
       
        local spawn_original = AmmoBagBase.spawn
        local init_original = AmmoBagBase.init
        local sync_setup_original = AmmoBagBase.sync_setup
        local _set_visual_stage_original = AmmoBagBase._set_visual_stage
        local destroy_original = AmmoBagBase.destroy
       
        function AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, peer_id, ...)
                local unit = spawn_original(pos, rot, ammo_upgrade_lvl, peer_id, ...)
                AmmoBagBase.SPAWNED_BAGS[unit:key()] = AmmoBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                AmmoBagBase.SPAWNED_BAGS[unit:key()].owner = peer_id
                UnitBase._do_listener_callback("on_bag_create", unit, "ammo_bag")
                UnitBase._do_listener_callback("on_bag_owner_update", unit, peer_id)
                return unit
        end
       
        function AmmoBagBase:init(unit, ...)
                AmmoBagBase.SPAWNED_BAGS[unit:key()] = AmmoBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                self._do_listener_callback("on_bag_create", unit, "ammo_bag")
                init_original(self, unit, ...)
                AmmoBagBase.SPAWNED_BAGS[unit:key()].max_amount = self._max_ammo_amount * 100
                self._do_listener_callback("on_bag_max_amount_update", unit, self._max_ammo_amount * 100)
        end
       
        function AmmoBagBase:sync_setup(ammo_upgrade_lvl, peer_id, ...)
                AmmoBagBase.SPAWNED_BAGS[self._unit:key()].owner = peer_id
                self._do_listener_callback("on_bag_owner_update", self._unit, peer_id)
                return sync_setup_original(self, ammo_upgrade_lvl, peer_id, ...)
        end
       
        function AmmoBagBase:_set_visual_stage(...)
                AmmoBagBase.SPAWNED_BAGS[self._unit:key()].amount = self._ammo_amount * 100
                self._do_listener_callback("on_bag_amount_update", self._unit, self._ammo_amount * 100)
                return _set_visual_stage_original(self, ...)
        end
       
        function AmmoBagBase:destroy(...)
                AmmoBagBase.SPAWNED_BAGS[self._unit:key()] = nil
                self._do_listener_callback("on_bag_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
end
 
if RequiredScript == "lib/units/equipment/bodybags_bag/bodybagsbagbase" then
 
        BodyBagsBagBase.SPAWNED_BAGS = {}
       
        local spawn_original = BodyBagsBagBase.spawn
        local init_original = BodyBagsBagBase.init
        local sync_setup_original = BodyBagsBagBase.sync_setup
        local _set_visual_stage_original = BodyBagsBagBase._set_visual_stage
        local destroy_original = BodyBagsBagBase.destroy
       
        function BodyBagsBagBase.spawn(pos, rot, upgrade_lvl, peer_id, ...)
                local unit = spawn_original(pos, rot, upgrade_lvl, peer_id, ...)
                BodyBagsBagBase.SPAWNED_BAGS[unit:key()] = BodyBagsBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                BodyBagsBagBase.SPAWNED_BAGS[unit:key()].owner = peer_id
                UnitBase._do_listener_callback("on_bag_create", unit, "body_bag")
                UnitBase._do_listener_callback("on_bag_owner_update", unit, peer_id)
                return unit
        end
       
        function BodyBagsBagBase:init(unit, ...)
                BodyBagsBagBase.SPAWNED_BAGS[unit:key()] = BodyBagsBagBase.SPAWNED_BAGS[unit:key()] or { unit = unit }
                self._do_listener_callback("on_bag_create", unit, "body_bag")
                init_original(self, unit, ...)
                BodyBagsBagBase.SPAWNED_BAGS[self._unit:key()].max_amount = self._max_bodybag_amount
                self._do_listener_callback("on_bag_max_amount_update", unit, self._max_bodybag_amount)
        end
       
        function BodyBagsBagBase:sync_setup(ammo_upgrade_lvl, peer_id, ...)
                BodyBagsBagBase.SPAWNED_BAGS[self._unit:key()].owner = peer_id
                self._do_listener_callback("on_bag_owner_update", self._unit, peer_id)
                return sync_setup_original(self, ammo_upgrade_lvl, peer_id, ...)
        end
       
        function BodyBagsBagBase:_set_visual_stage(...)
                BodyBagsBagBase.SPAWNED_BAGS[self._unit:key()].amount = self._bodybag_amount
                self._do_listener_callback("on_bag_amount_update", self._unit, self._bodybag_amount)
                return _set_visual_stage_original(self, ...)
        end
       
        function BodyBagsBagBase:destroy(...)
                BodyBagsBagBase.SPAWNED_BAGS[self._unit:key()] = nil
                self._do_listener_callback("on_bag_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
end
 
if RequiredScript == "lib/units/equipment/grenade_crate/grenadecratebase" then
 
        GrenadeCrateBase.SPAWNED_BAGS = {}
        GrenadeCrateBase.AGGREGATED_BAGS = {}
       
        --TODO: Fix this dumb-ass stacking implementation, preferably before I get to pay for being lazy
       
        local init_original = GrenadeCrateBase.init
        local _set_visual_stage_original = GrenadeCrateBase._set_visual_stage
        local destroy_original = GrenadeCrateBase.destroy
        local custom_init_original = CustomGrenadeCrateBase.init
        local custom_destroy_original = CustomGrenadeCrateBase.destroy
 
        function GrenadeCrateBase:init(unit, ...)
                GrenadeCrateBase.SPAWNED_BAGS[unit:key()] = { unit = unit }
                self._do_listener_callback("on_bag_create", unit, "grenade_crate")
                init_original(self, unit, ...)
                GrenadeCrateBase.SPAWNED_BAGS[self._unit:key()].max_amount = self._max_grenade_amount
                self._do_listener_callback("on_bag_max_amount_update", unit, self._max_grenade_amount)
        end
       
        function GrenadeCrateBase:_set_visual_stage(...)
                if self._is_aggregated then
                        GrenadeCrateBase.AGGREGATED_BAGS[self._unit:key()].amount = self._grenade_amount
                        local total = GrenadeCrateBase.total_aggregated_amount()
                        self._do_listener_callback("on_bag_amount_update", nil, total)
                        if total <= 0 then
                                GrenadeCrateBase.AGGREAGATED_ITEM_ACTIVE = nil
                                self._do_listener_callback("on_bag_set_active", nil, false)
                        end
                else
                        GrenadeCrateBase.SPAWNED_BAGS[self._unit:key()].amount = self._grenade_amount
                        self._do_listener_callback("on_bag_amount_update", self._unit, self._grenade_amount)
                end
 
                return _set_visual_stage_original(self, ...)
        end
       
        function GrenadeCrateBase:destroy(...)
                GrenadeCrateBase.SPAWNED_BAGS[self._unit:key()] = nil
                self._do_listener_callback("on_bag_destroy", self._unit)
                return destroy_original(self, ...)
        end
       
        function CustomGrenadeCrateBase:init(unit, ...)
                self._is_aggregated = true
                GrenadeCrateBase.AGGREGATED_BAGS[unit:key()] = { unit = unit }
                custom_init_original(self, unit, ...)
                GrenadeCrateBase.AGGREGATED_BAGS[self._unit:key()].max_amount = self._max_grenade_amount
                self._do_listener_callback("on_bag_max_amount_update", nil, GrenadeCrateBase.total_aggregated_max_amount())
        end
       
        function CustomGrenadeCrateBase:destroy(...)
                GrenadeCrateBase.AGGREGATED_BAGS[self._unit:key()] = nil
                if GrenadeCrateBase.total_aggregated_amount() <= 0 then
                        self._do_listener_callback("on_bag_destroy", nil)
                else
                        self._do_listener_callback("on_bag_amount_update", nil, GrenadeCrateBase.total_aggregated_amount())
                end
               
                return custom_destroy_original(self, ...)
        end
       
       
        function GrenadeCrateBase.total_aggregated_amount()
                local amount = 0
                for key, data in pairs(GrenadeCrateBase.AGGREGATED_BAGS) do
                        amount = amount + data.amount
                end
                return amount
        end
       
        function GrenadeCrateBase.total_aggregated_max_amount()
                local max_amount = 0
                for key, data in pairs(GrenadeCrateBase.AGGREGATED_BAGS) do
                        max_amount = max_amount + data.max_amount
                end
                return max_amount
        end
       
end
 
if RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
 
        local init_original = ECMJammerBase.init
        local set_active_original = ECMJammerBase.set_active
        local _set_feedback_active_original = ECMJammerBase._set_feedback_active
        local update_original = ECMJammerBase.update
        local sync_net_event_original = ECMJammerBase.sync_net_event
        local destroy_original = ECMJammerBase.destroy
       
        ECMJammerBase.SPAWNED_ECMS = {}
       
        function ECMJammerBase:init(...)
                init_original(self, ...)
                ECMJammerBase.SPAWNED_ECMS[self._unit:key()] = { unit = self._unit }
                self._do_listener_callback("on_ecm_create", self._unit)
        end
       
        function ECMJammerBase:set_active(active, ...)
                if self._jammer_active ~= active then
                        ECMJammerBase.SPAWNED_ECMS[self._unit:key()].active = active
                        self._do_listener_callback("on_ecm_set_active", self._unit, active)
                end
                return set_active_original(self, active, ...)
        end
       
        function ECMJammerBase:_set_feedback_active(state, ...)
                if not state then
                        local peer_id = managers.network:session() and managers.network:session():local_peer() and managers.network:session():local_peer():id()
                        if peer_id and (peer_id == self._owner_id) and managers.player:has_category_upgrade("ecm_jammer", "can_retrigger") then
                                ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
                                self._do_listener_callback("on_ecm_set_retrigger", self._unit, true)
                        end
                end
       
                return _set_feedback_active_original(self, state, ...)
        end
       
        function ECMJammerBase:update(unit, t, dt, ...)
                update_original(self, unit, t, dt, ...)
               
                if self._jammer_active then
                        ECMJammerBase.SPAWNED_ECMS[self._unit:key()].t = t
                        ECMJammerBase.SPAWNED_ECMS[self._unit:key()].battery_life = self._battery_life
                        self._do_listener_callback("on_ecm_update", self._unit, t, self._battery_life)
                end
               
                if ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t then
                        local rt = ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t - dt
                        if rt <= 0 then
                                self:_deactivate_feedback_retrigger()
                        else
                                ECMJammerBase.SPAWNED_ECMS[self._unit:key()].t = t
                                ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t = rt
                                self._do_listener_callback("on_ecm_update_retrigger_delay", self._unit, t, rt)
                        end
                end
        end
       
        function ECMJammerBase:sync_net_event(event_id, ...)
                if event_id == self._NET_EVENTS.feedback_restart  then
                        self:_deactivate_feedback_retrigger()
                end
               
                return sync_net_event_original(self, event_id, ...)
        end
       
        function ECMJammerBase:destroy(...)
                destroy_original(self, ...)
               
                self:_deactivate_feedback_retrigger()
                ECMJammerBase.SPAWNED_ECMS[self._unit:key()] = nil
        end
       
       
        function ECMJammerBase:_deactivate_feedback_retrigger()
                if ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t then
                        ECMJammerBase.SPAWNED_ECMS[self._unit:key()].retrigger_t = nil
                        self._do_listener_callback("on_ecm_set_retrigger", self._unit, false)
                end
        end
       
end
 
if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
 
        local init_original = GroupAIStateBase.init
        local update_original = GroupAIStateBase.update
        local register_turret_original = GroupAIStateBase.register_turret
        local unregister_turret_original = GroupAIStateBase.unregister_turret
        local set_whisper_mode_original = GroupAIStateBase.set_whisper_mode
        local convert_hostage_to_criminal_original = GroupAIStateBase.convert_hostage_to_criminal
        local sync_converted_enemy_original = GroupAIStateBase.sync_converted_enemy
        local on_hostage_state_original = GroupAIStateBase.on_hostage_state
        local sync_hostage_headcount_original = GroupAIStateBase.sync_hostage_headcount
       
        GroupAIStateBase._LISTENER_CALLBACKS = {}
       
        function GroupAIStateBase:init(...)
                self._civilian_hostages = 0
                return init_original(self, ...)
        end
 
        function GroupAIStateBase:update(t, ...)
                if self._client_hostage_count_expire_t and t < self._client_hostage_count_expire_t then
                        self:_client_hostage_count_cbk()
                end
               
                return update_original(self, t, ...)
        end
       
        function GroupAIStateBase:register_turret(unit, ...)
                self._turrets_registered = self._turrets_registered or {}
                if not self._turrets_registered[unit:key()] then
                        self._turrets_registered[unit:key()] = true
                        managers.enemy:_change_swat_turret_count(1)
                end
               
                return register_turret_original(self, unit, ...)
        end
 
        function GroupAIStateBase:unregister_turret(unit, ...)
                self._turrets_registered = self._turrets_registered or {}
                if self._turrets_registered[unit:key()] then
                        self._turrets_registered[unit:key()] = nil
                        managers.enemy:_change_swat_turret_count(-1)
                end
               
                return unregister_turret_original(self, unit, ...)
        end
       
        function GroupAIStateBase:set_whisper_mode(enabled, ...)
                set_whisper_mode_original(self, enabled, ...)
                self._do_listener_callback("on_whisper_mode_change", enabled)
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
                       
                        managers.enemy:add_minion_unit(unit, peer_id, health_mult, damage_mult)
                end
        end
       
        function GroupAIStateBase:sync_converted_enemy(converted_enemy, ...)
                sync_converted_enemy_original(self, converted_enemy, ...)
                managers.enemy:add_minion_unit(converted_enemy)
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
       
       
        function GroupAIStateBase:hostage_count_by_type(u_type)
                if u_type == "cop_hostage" then
                        return self:police_hostage_count()      --Default function, updated for client-side
                elseif u_type == "civilian_hostage" then
                        return self:civilian_hostage_count()    --Custom function
                elseif u_type == nil then
                        return  self:hostage_count()    --Default function, total hostages
                end
        end
       
        function GroupAIStateBase:civilian_hostage_count()
                return self._civilian_hostages
        end
       
        function GroupAIStateBase:_client_hostage_count_cbk()
                local old_police_count = self._police_hostage_headcount
                local old_civ_hostages = self._civilian_hostages
       
                local police_count = 0
                for u_key, u_data in pairs(managers.enemy:all_enemies()) do
                        if u_data and u_data.unit and u_data.unit.anim_data and u_data.unit:anim_data() then
                                if u_data.unit:anim_data().surrender then
                                        police_count = police_count + 1
                                end
                        end
                end
               
                self._police_hostage_headcount = police_count
                self._civilian_hostages = self:hostage_count() - self._police_hostage_headcount
                if old_police_count ~= self._police_hostage_headcount or old_civ_hostages ~= self._civilian_hostages then
                        self:_update_hostage_count()
                end
        end
       
        function GroupAIStateBase:_update_hostage_count()
                if Network:is_server() then
                        self._civilian_hostages = self._hostage_headcount - self._police_hostage_headcount
                end
 
                self._do_listener_callback("on_civilian_count_change", managers.enemy:unit_count("civilian"))
                self._do_listener_callback("on_civilian_hostage_count_change", self:civilian_hostage_count())
                self._do_listener_callback("on_cop_hostage_count_change", self:police_hostage_count())
        end
       
       
        function GroupAIStateBase.register_listener_clbk(name, event, clbk)
                GroupAIStateBase._LISTENER_CALLBACKS[event] = GroupAIStateBase._LISTENER_CALLBACKS[event] or {}
                GroupAIStateBase._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function GroupAIStateBase.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(GroupAIStateBase._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                GroupAIStateBase._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function GroupAIStateBase._do_listener_callback(event, ...)
                if GroupAIStateBase._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(GroupAIStateBase._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end
 
if RequiredScript == "lib/units/enemies/cop/copdamage" then
       
        local _on_damage_received_original = CopDamage._on_damage_received
       
        function CopDamage:_on_damage_received(damage_info, ...)
                if self._unit:in_slot(16) then
                        managers.enemy:update_minion_health(self._unit, self._health)
                end
                return _on_damage_received_original(self, damage_info, ...)
        end
 
end
 
if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
 
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
                       
                        managers.enemy:add_minion_unit(unit, owner_id, health_mult, damage_mult)
                end
        end
 
        function UnitNetworkHandler:hostage_trade(unit, ...)
                if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
                        managers.enemy:remove_minion_unit(unit)
                end
               
                return hostage_trade_original(self, unit, ...)
        end
       
        function UnitNetworkHandler:unit_traded(unit, trader, ...)
                if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_character(unit) then
                        managers.enemy:remove_minion_unit(unit)
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
                                        managers.interaction:pager_ended(unit)
                                elseif not flash then
                                        managers.interaction:pager_answered(unit)
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
                                        managers.interaction:pager_answered(unit_data.unit)
                                else
                                        managers.interaction:pager_ended(unit_data.unit)
                                end
                        end
                end
       
                return alarm_pager_interaction_original(self, u_id, tweak_table, status, sender, ...)
        end
       
end
 
if RequiredScript == "lib/managers/enemymanager" then
       
        local init_original = EnemyManager.init
        local register_enemy_original = EnemyManager.register_enemy
        local on_enemy_died_original = EnemyManager.on_enemy_died
        local on_enemy_destroyed_original = EnemyManager.on_enemy_destroyed
        local register_civilian_original = EnemyManager.register_civilian
        local on_civilian_died_original = EnemyManager.on_civilian_died
        local on_civilian_destroyed_original = EnemyManager.on_civilian_destroyed
       
        EnemyManager._LISTENER_CALLBACKS = {}
        EnemyManager.MINION_UNITS = {}
 
        EnemyManager._UNIT_TYPES = {
                cop = "cop",    --All non-special police
                tank = "tank",
				tank_hw = "tank",
                spooc = "spooc",
                taser = "taser",
                shield = "shield",
                sniper = "sniper",
                mobster_boss = "mobster_boss",
                hector_boss = "mobster_boss",
                hector_boss_no_armor = "mobster_boss",
                gangster = "thug",
                mobster = "thug",
				biker = "thug",
                biker_escape = "thug",
                security = "security",
                gensec = "security",
                turret = "turret",      --SWAT turrets
                civilian = "civilian",  --All civilians
				civilian_female = "civilian",
				bank_manager = "civilian",
                phalanx_vip = "phalanx",
                phalanx_minion = "phalanx",
        }

        EnemyManager._UNIT_TYPE_IGNORE = {
                drunk_pilot = true,
                escort = true,
                old_hoxton_mission = true,
				escort_undercover = true,
				boris = true,
				inside_man = true,
        }
       
        function EnemyManager:init(...)
                init_original(self, ...)
                self._minion_count = 0
                self._total_enemy_count = 0
                self._unit_count = {}
                for tweak, utype in pairs(EnemyManager._UNIT_TYPES) do
                        self._unit_count[utype] = 0
                end
        end
 
        function EnemyManager:register_enemy(unit, ...)
                self:_change_enemy_count(unit, 1)
                return register_enemy_original(self, unit, ...)
        end
       
        function EnemyManager:on_enemy_died(unit, ...)
                self:_change_enemy_count(unit, -1)
                self:_check_minion(unit, true)
                return on_enemy_died_original(self, unit, ...)
        end
       
        function EnemyManager:on_enemy_destroyed(unit, ...)
                if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
                        self:_change_enemy_count(unit, -1)
                        self:_check_minion(unit)
                end
                return on_enemy_destroyed_original(self, unit, ...)
        end
       
        function EnemyManager:register_civilian(unit, ...)
                self:_change_civilian_count(unit, 1)
                return register_civilian_original(self, unit, ...)
        end
       
        function EnemyManager:on_civilian_died(unit, ...)
                self:_change_civilian_count(unit, -1)
                return on_civilian_died_original(self, unit, ...)
        end
       
        function EnemyManager:on_civilian_destroyed(unit, ...)
                if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
                        self:_change_civilian_count(unit, -1)
                end
                return on_civilian_destroyed_original(self, unit, ...)
        end
       
       
        function EnemyManager:_check_minion(unit, killed)
                if EnemyManager.MINION_UNITS[unit:key()] then
                        self:remove_minion_unit(unit, killed)
                end
        end
       
        function EnemyManager:_change_enemy_count(unit, change)
                local tweak = unit:base()._tweak_table
               
                if not EnemyManager._UNIT_TYPE_IGNORE[tweak] then
                        local u_type = EnemyManager._UNIT_TYPES[tweak] or "cop"
                        self._total_enemy_count = self._total_enemy_count + change
                        self._unit_count[u_type] = self._unit_count[u_type] + change
                        self._do_listener_callback("on_total_enemy_count_change", self._total_enemy_count)
                        self._do_listener_callback("on_" .. u_type .. "_count_change", self._unit_count[u_type])
                end
        end
       
        function EnemyManager:_change_swat_turret_count(change)
                self._unit_count.turret = self._unit_count.turret + change
                self._do_listener_callback("on_turret_count_change", self._unit_count.turret)
        end
       
        function EnemyManager:_change_civilian_count(unit, change)
                local tweak = unit:base()._tweak_table
               
                if not EnemyManager._UNIT_TYPE_IGNORE[tweak] then
                        self._unit_count.civilian = self._unit_count.civilian + change
                        self._do_listener_callback("on_civilian_count_change", self._unit_count.civilian)
                end
        end
       
        function EnemyManager:unit_count(u_type)
                return u_type and (self._unit_count[u_type] or 0) or self._total_enemy_count
        end
       
        function EnemyManager:add_minion_unit(unit, owner_id, health_mult, damage_mult)
                if not EnemyManager.MINION_UNITS[unit:key()] then
                        self._minion_count = self._minion_count + 1
                        EnemyManager.MINION_UNITS[unit:key()] = { unit = unit }
                        self._do_listener_callback("on_add_minion_unit", unit)
                        self._do_listener_callback("on_minion_count_change", self._minion_count)
                end
               
                if not EnemyManager.MINION_UNITS[unit:key()].owner_id and owner_id then
                        EnemyManager.MINION_UNITS[unit:key()].owner_id = owner_id
                        self._do_listener_callback("on_minion_set_owner", unit, owner_id)
                end
               
                if not EnemyManager.MINION_UNITS[unit:key()].health_mult and health_mult then
                        EnemyManager.MINION_UNITS[unit:key()].health_mult = health_mult
                        self._do_listener_callback("on_minion_set_health_mult", unit, health_mult)
                end
               
                if not EnemyManager.MINION_UNITS[unit:key()].damage_mult and damage_mult then
                        EnemyManager.MINION_UNITS[unit:key()].damage_mult = damage_mult
                        self._do_listener_callback("on_minion_set_damage_mult", unit, damage_mult)
                end
        end
       
        function EnemyManager:remove_minion_unit(unit, killed)
                if EnemyManager.MINION_UNITS[unit:key()] then
                        self._minion_count = self._minion_count - 1
                        EnemyManager.MINION_UNITS[unit:key()] = nil
                        self._do_listener_callback("on_remove_minion_unit", unit, killed)
                        self._do_listener_callback("on_minion_count_change", self._minion_count)
                end
        end
       
        function EnemyManager:update_minion_health(unit, health)
                if EnemyManager.MINION_UNITS[unit:key()] then
                        EnemyManager.MINION_UNITS[unit:key()].health = health
                        self._do_listener_callback("on_minion_health_change", unit, health)
                end
        end
       
        function EnemyManager:minion_count()
                return table.size(EnemyManager.MINION_UNITS)
        end
       
       
        function EnemyManager.register_listener_clbk(name, event, clbk)
                EnemyManager._LISTENER_CALLBACKS[event] = EnemyManager._LISTENER_CALLBACKS[event] or {}
                EnemyManager._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function EnemyManager.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(EnemyManager._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                EnemyManager._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function EnemyManager._do_listener_callback(event, ...)
                if EnemyManager._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(EnemyManager._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end
 
if RequiredScript == "lib/managers/objectinteractionmanager" then
       
        local init_original = ObjectInteractionManager.init
        local update_original = ObjectInteractionManager.update
        local add_unit_original = ObjectInteractionManager.add_unit
        local remove_unit_original = ObjectInteractionManager.remove_unit
        local interact_original = ObjectInteractionManager.interact
        local interupt_action_interact_original = ObjectInteractionManager.interupt_action_interact
       
        ObjectInteractionManager._LISTENER_CALLBACKS = {}
        ObjectInteractionManager.ACTIVE_PAGERS = {}
       
        ObjectInteractionManager.COMPOSITE_LOOT_UNITS = {
                [103428] = 4, [103429] = 3, [103430] = 2, [103431] = 1, --Shadow Raid armor
                gen_pku_warhead_box = 2,        --[132925] = 2, [132926] = 2, [132927] = 2,     --Meltdown warhead cases
                --hold_open_bomb_case = 4,      --The Bomb heists cases, extra cases on docks screws with counter...
                --[102913] = 1, [102915] = 1, [102916] = 1,     --Train Heist turret (unit fixed, need workaround)
        }
       
        ObjectInteractionManager.LOOT_TYPE_FROM_INTERACTION_ID = {
                --If you add stuff here, make sure you add it to HUDList.LootItem.LOOT_ICON_MAP as well
                weapon_case = 							"weapon",
                samurai_armor = 						"armor",
                gen_pku_warhead_box = 					"warhead",
                --hold_open_bomb_case = "bomb"
                --crate_loot_crowbar =                  "container",
                --crate_loot =                          "container",
                --crate_loot_close =                    "container",
                --Crates and suitcases etc interaction ID's here -> type "container"
        }
       
        ObjectInteractionManager.LOOT_TYPE_FROM_CARRY_ID = {
                --If you add stuff here, make sure you add it to HUDList.LootItem.LOOT_ICON_MAP as well
                gold =									"gold",
                money =									"money",
				counterfeit_money = 					"money",
                diamonds =								"jewelry",
                painting =								"painting",
                mus_artifact_paint =					"painting",
                coke =									"coke",
                coke_pure =								"coke",
                meth =									"meth",
                weapon =								"weapon",
				weapons = 								"weapon",
				weapon_scar = 							"weapon",
				weapon_glock = 							"weapon",
                circuit =								"server",
                turret =								"turret",
                ammo =									"shell",
                artifact_statue =						"artifact",
                mus_artifact =							"artifact",
                samurai_suit =							"armor",
                sandwich =								"toast",
                hope_diamond =							"diamond",
                cro_loot1 =								"bomb",
                cro_loot2 =								"bomb",
                evidence_bag =							"evidence",
                warhead =								"warhead",
				din_pig =								"pig",
				safe_wpn =								"safe",
				safe_ovk =								"safe",
                unknown =								"dentist",
				meth_half =								"meth",
				masterpiece_painting =					"painting",
				master_server =							"server",
				lost_artifact =							"artifact",
				prototype =								"prototype",
				breaching_charges =						"charges",
				nail_muriatic_acid =					"MU",
				nail_caustic_soda =						"CS",
				nail_hydrogen_chloride =				"HCL",
				present =								"present",
				goat = 									"goat",
				drk_bomb_part = 						"bomb",
				mad_master_server_value_1 = 			"server",
				mad_master_server_value_2 = 			"server",
				mad_master_server_value_3 = 			"server",
				mad_master_server_value_4 = 			"server"
        }
       
        ObjectInteractionManager.LOOT_TYPE_LEVEL_COMPENSATION = {
                framing_frame_3 = { gold = 16, },
        }
       
        ObjectInteractionManager.LOOT_BAG_INTERACTION_ID = {
                painting_carry_drop = true,     --Painting
                carry_drop = true,              --Generic bag
				safe_carry_drop = true,			--Safe
				goat_carry_drop = true,			--Goat
        }
       
        ObjectInteractionManager.IGNORE_EDITOR_ID = {
                watchdogs_2 = { --Watchdogs day 2 (8x coke)
                        [100054] = true,
                        [100058] = true,
                        [100426] = true,
                        [100427] = true,
                        [100428] = true,
                        [100429] = true,
                        [100491] = true,
                        [100492] = true,
                        [100494] = true,
                        [100495] = true,
                },
                family = {      --Diamond store (1x money)
                        [100899] = true,
                },      --Hotline Miami day 1 (1x money)
                mia_1 = {       --Hotline Miami day 1 (1x money)
                        [104526] = true,
                },
                welcome_to_the_jungle_1 = {     --Big Oil day 1 (1x money, 1x gold)
                        [100886] = true,
                        [100872] = true,
                },
                mus = { --The Diamond (RNG)
                        [300047] = true,
                        [300686] = true,
                        [300457] = true,
                        [300458] = true,
                        [301343] = true,
                        [301346] = true,
                },
                arm_und = {     --Transport: Underpass (8x money)
                        [101237] = true,
                        [101238] = true,
                        [101239] = true,
                        [103835] = true,
                        [103836] = true,
                        [103837] = true,
                        [103838] = true,
                        [101240] = true,
                },
                ukrainian_job = {       --Ukrainian Job (1x money)
                        [101514] = true,
                },
                firestarter_2 = {       --Firestarter day 2 (1x keycard)
                        [107208] = true,
                },
                big = { --Big Bank (1x keycard)
                        [101499] = true,
                },
                roberts = {     --GO Bank (1x keycard)
                        [106104] = true,
                },
        }
        ObjectInteractionManager.IGNORE_EDITOR_ID.watchdogs_2_day = table.deep_map_copy(ObjectInteractionManager.IGNORE_EDITOR_ID.watchdogs_2)
        ObjectInteractionManager.IGNORE_EDITOR_ID.welcome_to_the_jungle_1_night = table.deep_map_copy(ObjectInteractionManager.IGNORE_EDITOR_ID.welcome_to_the_jungle_1)
       
        ObjectInteractionManager.SPECIAL_PICKUP_TYPE_FROM_INTERACTION_ID = {
                --If you add stuff here, make sure you add it to HUDList.SpecialPickupItem.SPECIAL_PICKUP_ICON_MAP as well
                gen_pku_crowbar =					"crowbar",
                pickup_keycard =					"keycard",
                pickup_hotel_room_keycard =			"keycard",
                gage_assignment =					"courier",
                pickup_boards =						"planks",
                stash_planks_pickup =				"planks",
                muriatic_acid =						"meth_ingredients",
                hydrogen_chloride =					"meth_ingredients",
                caustic_soda =						"meth_ingredients",
				gen_pku_blow_torch =				"Blowtorch",
				gen_pku_thermite = 					"thermite",
				gen_pku_thermite_paste = 			"thermite",
				gen_pku_thermite_timer = 			"thermite",
				hold_take_gas_can = 				"thermite",
				money_wrap_single_bundle = 			"small_loot",
				cas_chips_pile = 					"small_loot",
				diamond_pickup = 					"small_loot",
				diamond_pickup_pal = 				"small_loot",
				safe_loot_pickup = 					"small_loot",
        }
       
        ObjectInteractionManager.EQUIPMENT_INTERACTION_ID = {
                firstaid_box = { class = "DoctorBagBase", offset = -1 },
                ammo_bag = { class = "AmmoBagBase" },
                doctor_bag = { class = "DoctorBagBase" },
                bodybags_bag = { class = "BodyBagsBagBase" },
                grenade_crate = { class = "GrenadeCrateBase" },
        }
       
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
                --[101835] = { 101470, 101472, 101473 },        --HB infirmary med boxes (not needed, triggers on interaction activation)
        }
       
        ObjectInteractionManager.INTERACTION_TRIGGERS = {
                requires_ecm_jammer_double = {
                        [Vector3(-2217.05, 2415.52, -354.502)] = 136843,        --HB armory door 1
                        [Vector3(1817.05, 3659.48, 45.4985)] = 136843,  --HB armory door 2
                },
                drill = {
                        [Vector3(142, 3098, -197)] = 151868,    --GGC armory cage 1 alt 1
                        [Vector3(-166, 3413, -197)] = 151869,   --GGC armory cage 2 alt 1
                        [Vector3(3130, 1239, -195.5)] = 151868, --GGC armory cage X alt 2       (may be reversed)
                        [Vector3(3445, 1547, -195.5)] = 151869, --GGC armory cage Y alt 2       (may be reversed)
                },
				
        }
       
        function ObjectInteractionManager:init(...)
                init_original(self, ...)
               
                self._queued_units = {}
                self._pager_count = 0
                self._total_loot_count = { bagged = 0, unbagged = 0 }
                self._loot_count = {}
                self._loot_units_added = {}
                self._special_pickup_count = {}
               
                for carry_id, type_id in pairs(ObjectInteractionManager.LOOT_TYPE_FROM_CARRY_ID) do
                        self._loot_count[type_id] = { bagged = 0, unbagged = 0 }
                end
                for interaction_id, type_id in pairs(ObjectInteractionManager.LOOT_TYPE_FROM_INTERACTION_ID) do
                        self._loot_count[type_id] = { bagged = 0, unbagged = 0 }
                end
               
                for interaction_id, type_id in pairs(ObjectInteractionManager.SPECIAL_PICKUP_TYPE_FROM_INTERACTION_ID) do
                        self._special_pickup_count[type_id] = 0
                end
               
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
       
        function ObjectInteractionManager:interact(...)
                if alive(self._active_unit) and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
                        self:pager_answered(self._active_unit)
                end
               
                return interact_original(self, ...)
        end
       
        function ObjectInteractionManager:interupt_action_interact(...)
                if alive(self._active_unit) and self._active_unit:interaction() and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
                        self:pager_ended(self._active_unit)
                end
               
                return interupt_action_interact_original(self, ...)
        end
       
       
        function ObjectInteractionManager:_check_queued_units(t)
                local level_id = managers.job:current_level_id()
                local ignore_ids = level_id and ObjectInteractionManager.IGNORE_EDITOR_ID[level_id]
               
                for i, unit in ipairs(self._queued_units) do
                        if alive(unit) then
                                local editor_id = unit:editor_id()
                               
                                if not (ignore_ids and ignore_ids[editor_id]) then
                                        local carry_id = unit:carry_data() and unit:carry_data():carry_id()
                                        local interaction_id = unit:interaction().tweak_data
                                        local loot_type_id = carry_id and ObjectInteractionManager.LOOT_TYPE_FROM_CARRY_ID[carry_id] or ObjectInteractionManager.LOOT_TYPE_FROM_INTERACTION_ID[interaction_id]
                                        local special_pickup_type_id = ObjectInteractionManager.SPECIAL_PICKUP_TYPE_FROM_INTERACTION_ID[interaction_id]
                                       
                                        if ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
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
                                               
                                                --io.write("Equipment unit " .. tostring(editor_id) .. " (" .. tostring(data.class) .. ") made interactive, blocked: " .. tostring(blocked) .. "\n")
                                                unit:base():set_equipment_active(data.class, not blocked, data.offset)
                                        elseif loot_type_id then
                                                local count = ObjectInteractionManager.COMPOSITE_LOOT_UNITS[editor_id] or ObjectInteractionManager.COMPOSITE_LOOT_UNITS[interaction_id] or 1
                                                self._loot_units_added[unit:key()] = loot_type_id
                                                self:_change_loot_count(unit, loot_type_id, count, ObjectInteractionManager.LOOT_BAG_INTERACTION_ID[interaction_id] or false)
                                        elseif special_pickup_type_id then
                                                self:_change_special_pickup_count(unit, special_pickup_type_id, 1)
                                        elseif interaction_id == "corpse_alarm_pager" then
                                                self:_pager_started(unit)
                                        end
                                       
                                        self._do_listener_callback("on_unit_added", unit)
                                end
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
               
                local level_id = managers.job:current_level_id()
                local ignore_ids = level_id and ObjectInteractionManager.IGNORE_EDITOR_ID[level_id]
                local editor_id = unit:editor_id()
               
                if not (ignore_ids and ignore_ids[editor_id]) then
                        local carry_id = unit:carry_data() and unit:carry_data():carry_id()
                        local interaction_id = unit:interaction().tweak_data
                        local loot_type_id = carry_id and ObjectInteractionManager.LOOT_TYPE_FROM_CARRY_ID[carry_id] or ObjectInteractionManager.LOOT_TYPE_FROM_INTERACTION_ID[interaction_id]
                        local special_pickup_type_id = ObjectInteractionManager.SPECIAL_PICKUP_TYPE_FROM_INTERACTION_ID[interaction_id]
                       
                        if ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id] then
                                unit:base():set_equipment_active(ObjectInteractionManager.EQUIPMENT_INTERACTION_ID[interaction_id].class, false)
                        elseif loot_type_id or self._loot_units_added[unit:key()] then
                                local count = -(ObjectInteractionManager.COMPOSITE_LOOT_UNITS[editor_id] or ObjectInteractionManager.COMPOSITE_LOOT_UNITS[interaction_id] or 1)
                                loot_type_id = loot_type_id or self._loot_units_added[unit:key()]
                                self:_change_loot_count(unit, loot_type_id, count, ObjectInteractionManager.LOOT_BAG_INTERACTION_ID[interaction_id] or false)
                                self._loot_units_added[unit:key()] = nil
                        elseif special_pickup_type_id then
                                self:_change_special_pickup_count(unit, special_pickup_type_id, -1)
                        elseif interaction_id == "corpse_alarm_pager" then
                                self:pager_ended(unit)
                        end
                       
                        self._do_listener_callback("on_unit_removed", unit)
                end
        end
       
        function ObjectInteractionManager:_change_loot_count(unit, loot_type, change, bagged)
                self._total_loot_count.bagged = self._total_loot_count.bagged + (bagged and change or 0)
                self._loot_count[loot_type].bagged = self._loot_count[loot_type].bagged + (bagged and change or 0)
                self._total_loot_count.unbagged = self._total_loot_count.unbagged + (bagged and 0 or change)
                self._loot_count[loot_type].unbagged = self._loot_count[loot_type].unbagged + (bagged and 0 or change)
               
                local total_compensation = self:_get_loot_level_compensation()
                local type_compensation = self:_get_loot_level_compensation(loot_type)
                self._do_listener_callback("on_total_loot_count_change", self._total_loot_count.unbagged - total_compensation, self._total_loot_count.bagged)
                self._do_listener_callback("on_" .. loot_type .. "_count_change", self._loot_count[loot_type].unbagged - type_compensation, self._loot_count[loot_type].bagged)
        end
       
        function ObjectInteractionManager:_get_loot_level_compensation(loot_type)
                local count = 0
                local level_id = managers.job and managers.job:current_level_id()
                local level_data = level_id and ObjectInteractionManager.LOOT_TYPE_LEVEL_COMPENSATION[level_id]
                for id, amount in pairs(level_data or {}) do
                        if not loot_type or loot_type == id then
                                count = count + amount
                        end
                end
               
                return count
        end
       
        function ObjectInteractionManager:loot_count(loot_type)
                local data = loot_type and self._loot_count[loot_type] or self._total_loot_count
                local compensation = self:_get_loot_level_compensation(loot_type)
                return data.unbagged - compensation, data.bagged
        end
       
        function ObjectInteractionManager:_change_special_pickup_count(unit, pickup_type, change)
                self._special_pickup_count[pickup_type] = self._special_pickup_count[pickup_type] + change
                self._do_listener_callback("on_" .. pickup_type .. "_count_change", self._special_pickup_count[pickup_type])
        end
       
        function ObjectInteractionManager:special_pickup_count(pickup_type)
                return self._special_pickup_count[pickup_type]
        end
       
        function ObjectInteractionManager:_pager_started(unit)
                if not ObjectInteractionManager.ACTIVE_PAGERS[unit:key()] then
                        self._pager_count = self._pager_count + 1
                        ObjectInteractionManager.ACTIVE_PAGERS[unit:key()] = { unit = unit }
                        self._do_listener_callback("on_pager_count_change", self._pager_count)
                        self._do_listener_callback("on_pager_started", unit)
                end
        end
       
        function ObjectInteractionManager:pager_ended(unit)
                if ObjectInteractionManager.ACTIVE_PAGERS[unit:key()] then
                        ObjectInteractionManager.ACTIVE_PAGERS[unit:key()] = nil
                        self._do_listener_callback("on_pager_ended", unit)
                end
        end
       
        function ObjectInteractionManager:pager_answered(unit)
                if ObjectInteractionManager.ACTIVE_PAGERS[unit:key()] and not ObjectInteractionManager.ACTIVE_PAGERS[unit:key()].answered then
                        ObjectInteractionManager.ACTIVE_PAGERS[unit:key()].answered = true
                        self._do_listener_callback("on_pager_answered", unit)
                end
        end
       
        function ObjectInteractionManager:_whisper_mode_change(status)
                if not status then
                        for key, data in pairs(ObjectInteractionManager.ACTIVE_PAGERS) do
                                self:pager_ended(data.unit)
                        end
                        self._do_listener_callback("on_remove_all_pagers")
                end
        end
       
        function ObjectInteractionManager:used_pager_count()
                return self._pager_count
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
       
       
        function ObjectInteractionManager.register_listener_clbk(name, event, clbk)
                ObjectInteractionManager._LISTENER_CALLBACKS[event] = ObjectInteractionManager._LISTENER_CALLBACKS[event] or {}
                ObjectInteractionManager._LISTENER_CALLBACKS[event][name] = clbk
        end
       
        function ObjectInteractionManager.unregister_listener_clbk(name, event)
                for event_id, listeners in pairs(ObjectInteractionManager._LISTENER_CALLBACKS) do
                        if not event or event_id == event then
                                for id, clbk in pairs(listeners) do
                                        if id == name then
                                                ObjectInteractionManager._LISTENER_CALLBACKS[event_id][id] = nil
                                                break
                                        end
                                end
                        end
                end
        end
       
        function ObjectInteractionManager._do_listener_callback(event, ...)
                if ObjectInteractionManager._LISTENER_CALLBACKS[event] then
                        for id, clbk in pairs(ObjectInteractionManager._LISTENER_CALLBACKS[event]) do
                                clbk(...)
                        end
                end
        end
       
end
 
if RequiredScript == "lib/units/props/missiondoor" then
 
        local deactivate_original = MissionDoor.deactivate
       
        function MissionDoor:deactivate(...)
                managers.interaction:block_trigger(self._unit:editor_id(), false)
                return deactivate_original(self, ...)
        end
       
end
 
if RequiredScript == "lib/units/props/securitycamera" then
 
        local _start_tape_loop_original = SecurityCamera._start_tape_loop
        local _deactivate_tape_loop_original = SecurityCamera._deactivate_tape_loop
       
        function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
                ObjectInteractionManager._do_listener_callback("on_tape_loop_start", self._unit, tape_loop_t + 6)
                return _start_tape_loop_original(self, tape_loop_t, ...)
        end
 
        function SecurityCamera:_deactivate_tape_loop(...)
                ObjectInteractionManager._do_listener_callback("on_tape_loop_stop", self._unit)
                return _deactivate_tape_loop_original(self, ...)
        end
       
end