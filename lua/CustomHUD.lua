--TODO: Setting update for interaction, but probably not necessary as they are temporary anyway
--TODO: Clean up interaction activation/deactivation animation, probably a lot of unnecessary rearranges going on
if not WolfHUD:getSetting({"CustomHUD", "ENABLED"}, true) then
	return
end

local print_info = function(...)
	local params = {...}
	table.insert(params, #params + 1, "info")
	WolfHUD:print_log(unpack(params))
end

local print_warning = function(...)
	local params = {...}
	table.insert(params, #params + 1, "warning")
	WolfHUD:print_log(unpack(params))
end

local print_error = function(...)
	local params = {...}
	table.insert(params, #params + 1, "error")
	WolfHUD:print_log(unpack(params))
end

if RequiredScript == "lib/managers/hud/hudteammate" then

	local ReverseTable = function(tbl)
		for i=1, math.floor(#tbl / 2) do
			local tmp = tbl[i]
			tbl[i] = tbl[#tbl - i + 1]
			tbl[#tbl - i + 1] = tmp
		end
	end

	HUDTeammateCustom = HUDTeammateCustom or class()

	--TODO: Switch to setting hierarchy with overloading for player/team instead of separate table?
	HUDTeammateCustom.SETTINGS = {
		MAX_WEAPONS = 2,	--Number of carried guns (...just don't...)

		PLAYER = {
			SCALE = WolfHUD:getSetting({"CustomHUD", "PLAYER", "SCALE"}, 1),			--Scale of all elements of the panel
			OPACITY = WolfHUD:getSetting({"CustomHUD", "PLAYER", "OPACITY"}, 0.85),	--Transparency/alpha of panel (1 is solid, 0 is invisible)

			NAME = WolfHUD:getSetting({"CustomHUD", "PLAYER", "NAME"}, false),	--Show name
			TRUNCATE_TAGS = WolfHUD:getSetting({"CustomHUD", "PLAYER", "TRUNCATE_TAGS"}, false),	--Truncate tags
			RANK = WolfHUD:getSetting({"CustomHUD", "PLAYER", "RANK"}, false),	--Show infamy/level
			CHARACTER = WolfHUD:getSetting({"CustomHUD", "PLAYER", "CHARACTER"}, false),	--Show character name
			LATENCY = false,	--Show latency (not used by player panel)
			STATUS = WolfHUD:getSetting({"CustomHUD", "PLAYER", "STATUS"}, true),	--Show health/armor/condition etc.
			CONDITION_ICON_COLOR = WolfHUD:getColorSetting({"CustomHUD", "PLAYER", "CONDITION_ICON_COLOR"}, "white"),
			EQUIPMENT = WolfHUD:getSetting({"CustomHUD", "PLAYER", "EQUIPMENT"}, true),	--Show throwables, cable ties and deployables
			SPECIAL_EQUIPMENT = WolfHUD:getSetting({"CustomHUD", "PLAYER", "SPECIAL_EQUIPMENT"}, true),	--Show special equipment/tools (keycards etc.)
			SPECIAL_EQUIPMENT_ROWS = WolfHUD:getSetting({"CustomHUD", "PLAYER", "SPECIAL_EQUIPMENT_ROWS"}, 3),
			CALLSIGN = WolfHUD:getSetting({"CustomHUD", "PLAYER", "CALLSIGN"}, false),	--Show the callsign and voice chat icon
			STAMINA = WolfHUD:getSetting({"CustomHUD", "PLAYER", "STAMINA"}, true),
			DOWNCOUNTER = WolfHUD:getSetting({"CustomHUD", "PLAYER", "DOWNCOUNTER"}, true),
			CARRY = WolfHUD:getSetting({"CustomHUD", "PLAYER", "CARRY"}, true),	--Show currently carried bag
			BUILD = {	--Show perk deck and number of skills acquired in each tree (not used by player)
				--Pick max one
				HIDE = true,	--Don't show build at all
				--DURATION = 30,	--Time in seconds to show the build from when player joins. Information is hidden when duration has expired, or never removed if value is nil/undefined
			},
			WEAPON = {
				--Show/hide various elements of the weapons panels.
				--HIDE option hides the element. SELECTED_ONLY shows only if the weapon is currently selected, UNSELECTED_ONLY the reverse
				--Pick max *one* setting for each element or results are undefined
				ICON = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "ICON"}, 4) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "ICON"}, 4) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "ICON"}, 4) == 3),
				},
				NAME = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "NAME"}, 1) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "NAME"}, 1) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "NAME"}, 1) == 3),
				},
				AMMO = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "AMMO"}, 4) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "AMMO"}, 4) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "AMMO"}, 4) == 3),
					TOTAL_AMMO_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "AMMO"}, 4) == 5),	--Shows only total ammo for all weapons
				},
				FIREMODE = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "FIREMODE"}, 2) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "FIREMODE"}, 2) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "PLAYER", "WEAPON", "FIREMODE"}, 2) == 3),
				},
			},
			INTERACTION = {	--(Interaction display only used by teammates, included for reference)
				HIDE = true,	--Hides the interaction activity/time/progress
				MIN_DURATION = 1,	--Shows the interaction display only if interaction duration in seconds exceeds this threshold
			},
			KILLCOUNTER = {
				--Requires external plugin to be loaded, else will be disabled no matter what
				HIDE = WolfHUD:getSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "HIDE"}, false),	--Hides the kill counter
				SHOW_BOT_KILLS = false,	--Show the kill counter for criminal bots
				SHOW_SPECIAL_KILLS = WolfHUD:getSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "SHOW_SPECIAL_KILLS"}, true),	--Separate counter for specials
				SHOW_HEADSHOT_KILLS = WolfHUD:getSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"}, true),	--Separate counter, of how many kills were due to headshots
				COLOR = WolfHUD:getColorSetting({"CustomHUD", "PLAYER", "KILLCOUNTER", "COLOR"}, "yellow")
			},
			SHOW_ACCURACY = WolfHUD:getSetting({"CustomHUD", "PLAYER", "SHOW_ACCURACY"}, true),	--Show accuracy information
		},

		TEAMMATE = {
			SCALE = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "SCALE"}, 0.8),			--Scale of all elements of the panel
			OPACITY = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "OPACITY"}, 0.85),	--Transparency/alpha of panel (1 is solid, 0 is invisible)

			NAME = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "NAME"}, true),	--Show name
			TRUNCATE_TAGS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "TRUNCATE_TAGS"}, false),	--Truncate tags
			RANK = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "RANK"}, true),	--Show infamy/level
			CHARACTER = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "CHARACTER"}, false),	--Show character name
			LATENCY = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "LATENCY"}, true),	--Show latency (not used by player panel)
			STATUS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "STATUS"}, true),	--Show health/armor/condition etc.
			CONDITION_ICON_COLOR = WolfHUD:getColorSetting({"CustomHUD", "TEAMMATE", "CONDITION_ICON_COLOR"}, "white"),
			EQUIPMENT = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "EQUIPMENT"}, true),	--Show throwables, cable ties and deployables
			SPECIAL_EQUIPMENT = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "SPECIAL_EQUIPMENT"}, true),	--Show special equipment/tools (keycards etc.)
			SPECIAL_EQUIPMENT_ROWS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "SPECIAL_EQUIPMENT_ROWS"}, 3),
			CALLSIGN = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "CALLSIGN"}, false),	--Show the callsign and voice chat icon
			STAMINA = false,
			DOWNCOUNTER = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "DOWNCOUNTER"}, true),
			CARRY = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "CARRY"}, true),	--Show currently carried bag
			BUILD = {	--Show perk deck and number of skills acquired in each tree (not used by player)
				--Pick max one
				HIDE = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "BUILD", "HIDE"}, false),	--Don't show build at all
				DURATION = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "BUILD", "DURATION"}, 15) > 0 and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "BUILD", "DURATION"}, 15) or nil,	--Time in seconds to show the build from when player joins. Information is hidden when duration has expired, or never removed if value is nil/undefined
			},
			WEAPON = {
				--Show/hide various elements of the weapons panels.
				--HIDE option hides the element. SELECTED_ONLY shows only if the weapon is currently selected, UNSELECTED_ONLY the reverse
				--Pick max *one* setting for each element or results are undefined
				ICON = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "ICON"}, 4) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "ICON"}, 4) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "ICON"}, 4) == 3),
				},
				NAME = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "NAME"}, 1) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "NAME"}, 1) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "NAME"}, 1) == 3),
				},
				AMMO = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "AMMO"}, 4) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "AMMO"}, 4) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "AMMO"}, 4) == 3),
					TOTAL_AMMO_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "AMMO"}, 4) == 5),	--Shows only total ammo for all weapons
				},
				FIREMODE = {
					HIDE = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "FIREMODE"}, 1) == 1),
					SELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "FIREMODE"}, 1) == 2),
					UNSELECTED_ONLY = (WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "WEAPON", "FIREMODE"}, 1) == 3),
				},
			},
			INTERACTION = {	--(Interaction display only used by teammates, included for reference)
				HIDE = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "HIDE"}, false),	--Hides the interaction activity/time/progress
				MIN_DURATION = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "INTERACTION", "MIN_DURATION"}, 1),	--Shows the interaction display only if interaction duration in seconds exceeds this threshold
			},
			KILLCOUNTER = {
				--Requires external plugin to be loaded, else will be disabled no matter what
				HIDE = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "HIDE"}, false),	--Hides the kill counter
				SHOW_BOT_KILLS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_BOT_KILLS"}, true),	--Show the kill counter for criminal bots
				SHOW_SPECIAL_KILLS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_SPECIAL_KILLS"}, true),	--Separate counter for specials
				SHOW_HEADSHOT_KILLS = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"}, true),	--Separate counter, of how many kills were due to headshots
				COLOR = WolfHUD:getColorSetting({"CustomHUD", "TEAMMATE", "KILLCOUNTER", "COLOR"}, "yellow")
			},
			SHOW_ACCURACY = false,	--Show accuracy information
		},
	}

	function HUDTeammateCustom:init(id, panel, is_player, alignment)
		self._panel = panel:panel({
			name = "teammate_panel_" .. tostring(id),
		})

		self._align = alignment
		self._listeners = {}
		self._all_components = {}
		self._settings = HUDTeammateCustom.SETTINGS[is_player and "PLAYER" or "TEAMMATE"]
		self._id = id
		self._is_player = is_player
		self._next_latency_update_t = 0

		self:_build_panel()
		self._panel:hide()
		self:_set_layout(true)
	end

	function HUDTeammateCustom:update(t, dt)
		if self:peer_id() and t > self._next_latency_update_t then
			local net_session = managers.network:session()
			local peer = net_session and net_session:peer(self:peer_id())
			local latency = peer and Network:qos(peer:rpc()).ping or "n/a"

			self:set_latency(latency)
			self._next_latency_update_t = t + 1
		end
	end

	function HUDTeammateCustom:arrange()
		if not self._component_layout then return end

		local MARGIN = 3
		local w = 0
		local h = 0

		for i, vertical_order in ipairs(self._component_layout) do
			local start = 1
			local stop = #vertical_order
			local step = 1

			local w_row = 0
			local h_row = 0

			for j = start, stop, step do
				local component = vertical_order[j]

				if component:visible() then
					component:set_y(h)
					component:set_x(w_row)
					w_row = w_row + MARGIN + component:w()
					h_row = math.max(h_row, component:h())
				end
			end

			h = h + h_row
			w = math.max(w, w_row)
		end

		if self._is_player then
			self._carry:set_center_x(w / 2)
		end

		self._latency:set_right(w)
		self._waiting_input:set_right(w)

		if not (self._latency:visible() or self._player_info:visible()) and self._player_status:visible() then
			self._callsign:set_center(self._player_status:center())
		end

		if self._panel:w() ~= w or self._panel:h() ~= h then
			self._panel:set_size(w, h)
			managers.hud:arrange_teammate_panels()
		end

		if self._align then
			for _, component in ipairs(self._all_components) do
				if self._align == "right" then
					component:set_right(self._panel:w() - component:left())
				end
				component:set_alignment(self._align)
			end
		end
	end

	function HUDTeammateCustom:change_setting(setting, value)
		local val = value
		if setting[1] == "WEAPON" then
			val = {
				HIDE = (value == 1),
				SELECTED_ONLY = (value == 2),
				UNSELECTED_ONLY = (value == 3),
				TOTAL_AMMO_ONLY = (value == 5),
			}
		elseif setting[1] == "BUILD" and setting[2] == "DURATION" then
			val = val == 0 and nil or val
		end

		local entry = self._settings
		if #setting > 1 then
			for i = 1, (#setting-1) do
				entry = entry[setting[i]]
				if entry == nil then
					return false
				end
			end
		end
		entry[setting[#setting]] = val

		self:update_settings()
	end

	function HUDTeammateCustom:update_settings()
		self._component_layout = nil	--Prevent constant rearranging during setting change

		for i, component in ipairs(self._all_components) do
			component:update_settings()
		end

		self._panel:set_alpha(self._settings.OPACITY)
		if self._scale ~= self._settings.SCALE then
			local scale_factor = self._settings.SCALE / self._scale
			for i, component in ipairs(self._all_components) do
				component:rescale(scale_factor)
			end
			self._scale = self._settings.SCALE
		end

		self:_rebuild_layout()
		self:arrange()
	end

	function HUDTeammateCustom:_build_panel()
		self._scale = (self._settings.SCALE or 1)

		local size = 50 * self._scale
		local name_size = 20 * self._scale

		self._player_info = PlayerInfoComponent.PlayerInfo:new(self._panel, self, name_size, self._settings)
		self._latency = PlayerInfoComponent.Latency:new(self._panel, self, name_size, self._settings)
		self._build = PlayerInfoComponent.Build:new(self._panel, self, name_size, self._settings)
		self._callsign = PlayerInfoComponent.Callsign:new(self._panel, self, name_size, self._settings)
		self._player_status = PlayerInfoComponent.PlayerStatus:new(self._panel, self, size, size, self._settings)
		self._waiting_status = PlayerInfoComponent.WaitingStatus:new(self._panel, self, size, size, self._settings)
		self._accuracy = PlayerInfoComponent.AccuracyCounter:new(self._panel, self, name_size * 0.8, self._settings)
		self._kills = PlayerInfoComponent.KillCounter:new(self._panel, self, name_size * 0.8, self._settings)
		self._waiting_input = PlayerInfoComponent.WaitingInput:new(self._panel, self, name_size * 0.8, self._settings)
		self._carry = PlayerInfoComponent.Carry:new(self._panel, self, name_size, size, self._settings)
		self._center_panel = PlayerInfoComponent.CenterPanel:new(self._panel, self, size, self._settings)

		self._all_components = {
			self._player_info,
			self._latency,
			self._build,
			self._accuracy,
			self._kills,
			self._waiting_input,
			self._callsign,
			self._player_status,
			self._waiting_status,
			self._carry,
			self._center_panel,
		}

		for i, component in ipairs(self._all_components) do
			component:set_is_local_player(self:is_local_player()) --self._is_player
		end
		self:update_settings()
	end

	function HUDTeammateCustom:_set_layout(human_layout)
		if self._human_layout ~= human_layout then
			self._human_layout = human_layout

			for i, component in ipairs(self._all_components) do
				component:set_is_ai(not self._human_layout)
				component:set_is_waiting(self._is_waiting)
			end
--[[
			for i, component in ipairs(self._all_components) do
				component:set_is_waiting(self._is_waiting)
			end
]]
			self:_rebuild_layout()
		end
	end

	function HUDTeammateCustom:_rebuild_layout()
		self._component_layout = {}

		if self._is_player then
			table.insert(self._component_layout, { self._carry })	--1st row
		end

		local top_components = { }
		if self._latency:visible() or self._player_info:visible() or not self._player_status:visible() then
			table.insert(top_components, self._callsign)
		end
		table.insert(top_components, self._player_info)
		table.insert(top_components, self._latency)
		table.insert(self._component_layout, top_components)	--2nd row

		table.insert(self._component_layout, { self._build })	--3rd row

		local center_components = { self._player_status, self._waiting_status, self._center_panel }
		if not self._is_player then
			table.insert(center_components, self._carry)
		end
		table.insert(self._component_layout, center_components)	--4th row

		table.insert(self._component_layout, { self._kills, self._accuracy, self._waiting_input })	--5th row

		self:arrange()
	end

	function HUDTeammateCustom:set_alignment(align)
		if self._align ~= align then
			self._align = align
			self:arrange()
		end
	end

	function HUDTeammateCustom:reset()
		self:stop_timer()
		self:set_cheater(false)
		self:set_ai(nil)
		self:set_ai_stopped(nil)
		self:set_peer_id(nil)
		self:set_condition("mugshot_normal")
		self:clear_special_equipment(true)
		self:teammate_progress(false, false, false, false)
		self:remove_carry_info()
		self:set_info_meter({ current = 0, total = 0, max = 1 })
		self:set_absorb_active(0)
		--self:set_cable_ties_amount(0)	--Necessary/dangerous?
		--self:set_deployable_equipment_amount(1, { amount = 0 })	--Necessary/dangerous?
		--self:set_grenades_amount({ amount = 0 })	--Necessary/dangerous?

		self:arrange()
	end

	function HUDTeammateCustom:add_panel()
		self._panel:show()
		managers.hud:arrange_teammate_panels()
	end

	function HUDTeammateCustom:remove_panel()
		self._panel:hide()
		self:reset()
	end

	function HUDTeammateCustom:peer_id()
		return self._peer_id
	end

	function HUDTeammateCustom:is_local_player()
		return not (self:peer_id() or self:is_ai())
	end

	function HUDTeammateCustom:name()
		return self._last_name or ""
	end

	function HUDTeammateCustom:is_ai()
		return self._ai
	end

	function HUDTeammateCustom:is_ai_stopped()
		return self._ai and self._ai_stopped or false
	end

	function HUDTeammateCustom:is_waiting()
		return self._is_waiting or false
	end

	function HUDTeammateCustom:alignment()
		return self._align
	end

	function HUDTeammateCustom:panel()
		return self._panel
	end

	function HUDTeammateCustom:register_listener(id, events, clbk, prefix_event)
		for _, event in pairs(events) do
			self._listeners[event] = self._listeners[event] or {}
			self._listeners[event][id] = { clbk = clbk, prefix_event = prefix_event }
		end
	end

	function HUDTeammateCustom:unregister_listener(id, events)
		for _, event in pairs(events) do
			if self._listeners[event] then
				self._listeners[event][id] = nil
			end
		end
	end

	function HUDTeammateCustom:call_listeners(event, ...)
		for listener, data in pairs(self._listeners[event] or {}) do
			if data.prefix_event then
				data.clbk(event, ...)
			else
				data.clbk(...)
			end
		end
	end

	function HUDTeammateCustom:set_health(data)
		self:call_listeners("health", data.current, data.total)
	end

	function HUDTeammateCustom:set_stored_health(amount)
		self:call_listeners("stored_health", amount)
	end

	function HUDTeammateCustom:set_stored_health_max(amount)
		self:call_listeners("stored_health_max", amount)
	end

	function HUDTeammateCustom:set_revives(value)
		self:call_listeners("set_revives", value)
	end

	function HUDTeammateCustom:increment_downs()
		self:call_listeners("increment_downs")
	end

	function HUDTeammateCustom:reset_downs()
		self:call_listeners("reset_downs")
	end

	function HUDTeammateCustom:set_detection(value)
		self:call_listeners("detection", value)
	end

	function HUDTeammateCustom:set_armor(data)
		self:call_listeners("armor", data.current, data.total)
	end

	function HUDTeammateCustom:set_stamina(amount)
		self:call_listeners("stamina", amount)
	end

	function HUDTeammateCustom:set_stamina_max(amount)
		self:call_listeners("stamina_max", amount)
	end

	function HUDTeammateCustom:set_info_meter(data)
		--print_info("(DEBUG) set_info_meter: c: %s, t: %s, m: %s", tostring(data.current), tostring(data.total), tostring(data.max))
		--Used to set hysteria stacks. Unused in this HUD at the moment
		self:call_listeners("absorb_stacks", data.current, data.total, data.max)
	end

	function HUDTeammateCustom:set_absorb_active(amount)
		self:call_listeners("absorb_active", amount)
	end

	function HUDTeammateCustom:set_condition(icon_data, text)
		if icon_data == "mugshot_normal" and self:is_ai_stopped() then
			icon_data = "ai_stopped"
		end
		self:call_listeners("condition", icon_data, text)
	end

	function HUDTeammateCustom:start_timer(t)
		self:call_listeners("start_condition_timer", t)
	end

	function HUDTeammateCustom:stop_timer()
		self:call_listeners("stop_condition_timer")
	end

	function HUDTeammateCustom:set_pause_timer(pause)
		self:call_listeners("pause_condition_timer", pause)
	end

	function HUDTeammateCustom:set_custom_radial(data)
		self:call_listeners("custom_radial", data.current, data.total)
	end

	function HUDTeammateCustom:activate_ability_radial(time_left, time_total)	--Teammates, handled in update function.
		self:call_listeners("activate_ability", time_left, time_total or time_left)

		if self:is_local_player() then
			local current_time = managers.game_play_central:get_heist_timer() or 0
			managers.network:session():send_to_peers("sync_ability_hud", time_left + current_time, time_total or time_left)
		end
	end

	function HUDTeammateCustom:set_ability_radial(data)		--Player
		self:call_listeners("ability_radial", data.current, data.total)
	end

	function HUDTeammateCustom:set_delayed_damage(damage)
		local player_unit = managers.player:player_unit()
		local player_damage = player_unit and player_unit:character_damage()
		if player_damage then
			local data = {
				damage = damage,
				health = player_damage:get_real_health(),
				armor = player_damage:get_real_armor(),
				total_health = player_damage:_max_health(),
				total_armor = player_damage:_max_armor(),
			}
			self:call_listeners("delayed_damage", data)
		end

		if self:is_local_player() then
			managers.network:session():send_to_peers("sync_delayed_damage_hud", damage)
		end
	end

	function HUDTeammateCustom:set_ability_icon(icon)
		self:call_listeners("ability_icon", icon)
	end

	function HUDTeammateCustom:set_weapon_firemode(index, fire_mode)
		self:call_listeners("weapon_fire_mode", index, fire_mode)
	end

	function HUDTeammateCustom:set_weapon_selected(index, hud_icon)
		self:call_listeners("weapon_selected", index)
	end

	function HUDTeammateCustom:set_ammo_amount_by_type(slot, mag_max, mag_current, total_current, total_max)
		local slot_index = { primary = 2, secondary = 1, }
		self:call_listeners("ammo_amount", slot_index[slot], mag_current, mag_max, total_current, total_max)
	end

	function HUDTeammateCustom:set_grenades(data)
		self:call_listeners("throwable", data.icon)
		self:set_grenades_amount(data)
	end

	function HUDTeammateCustom:set_grenades_amount(data)
		if data.amount then
			self:call_listeners("throwable_amount", data.amount)
		end
	end

	function HUDTeammateCustom:set_grenade_cooldown(data)
		if data and data.end_time and data.duration then
			local time_left = data.end_time - managers.game_play_central:get_heist_timer()
			self:call_listeners("throwable_cooldown", time_left, data.duration)

			if self:is_local_player() then
				managers.network:session():send_to_peers("sync_grenades_cooldown", data.end_time, data.duration)
			end
		end
	end

	function HUDTeammateCustom:animate_grenade_flash(...)
		self:call_listeners("throwable_cooldown_stop")
	end

	function HUDTeammateCustom:set_cable_tie(data)
		self:call_listeners("cable_tie", data.icon)
		self:set_cable_ties_amount(data.amount)
	end

	function HUDTeammateCustom:set_cable_ties_amount(amount)
		if amount then
			self:call_listeners("cable_tie_amount", amount)
		end
	end

	function HUDTeammateCustom:set_deployable_equipment(data)
		self:call_listeners("deployable", data.icon)
		self:set_deployable_equipment_amount(1, data)
	end

	function HUDTeammateCustom:set_deployable_equipment_amount(index, data)
		if data.amount then
			self:call_listeners("deployable_amount", data.amount)
		end
	end

	function HUDTeammateCustom:set_deployable_equipment_from_string(data)
		self:call_listeners("deployable", data.icon)
		self:set_deployable_equipment_amount_from_string(1, data)
	end

	function HUDTeammateCustom:set_deployable_equipment_amount_from_string(index, data)
		if data.amount then
			self:call_listeners("deployable_amount_from_string", data.amount)
		end
	end

	function HUDTeammateCustom:add_special_equipment(data)
		self:call_listeners("add_special_equipment", data.id, data.icon)
		self:set_special_equipment_amount(data.id, data.amount)
	end

	function HUDTeammateCustom:remove_special_equipment(id)
		self:call_listeners("remove_special_equipment", id)
	end

	function HUDTeammateCustom:set_special_equipment_amount(id, amount)
		if amount then
			self:call_listeners("special_equipment_amount", id, amount)
		end
	end

	function HUDTeammateCustom:clear_special_equipment(override)
		self:call_listeners("clear_special_equipment")

		if not override then
			self:reset()
		end

	end

	function HUDTeammateCustom:set_name(name)
		if self._last_name ~= name then	--TODO: Got to be a better place for this...
			self._last_name = name
			self:reset_kill_count()
			self:reset_accuracy()
			self:reset_downs()
		end
		self:call_listeners("name", name)
	end

	function HUDTeammateCustom:set_callsign(id)
		if self:is_local_player() then
			self:set_character(managers.criminals:character_name_by_peer_id(id))
			self:set_rank(managers.experience:current_rank(), managers.experience:current_level())
			local detection = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
			self:set_detection(math.round(detection * 100))
		end

		self:call_listeners("callsign", id)
	end

	function HUDTeammateCustom:set_rank(infamy, level)
		self:call_listeners("rank", infamy, level)
	end

	function HUDTeammateCustom:set_character(character)
		self:call_listeners("character", character)
	end

	function HUDTeammateCustom:set_latency(value)
		self:call_listeners("latency", value)
	end

	function HUDTeammateCustom:set_specialization(index, level)
		self:call_listeners("specialization", index, level)
	end

	function HUDTeammateCustom:set_skills(data)
		self:call_listeners("skills", data)
	end

	function HUDTeammateCustom:set_cheater(state)
		self:call_listeners("cheater", state)
	end

	function HUDTeammateCustom:set_peer_id(peer_id)
		self._peer_id = peer_id

		if peer_id then
			local peer = managers.network:session():peer(peer_id)
			managers.hud:_parse_outfit_string(self._id, peer_id)
			self:set_character(managers.criminals:character_name_by_peer_id(peer_id))
			self:set_rank(peer:rank(), peer:level())
		end
	end

	function HUDTeammateCustom:set_ai(status)
		self._ai = status
	end

	function HUDTeammateCustom:set_ai_stopped(status)
		self._ai_stopped = self:is_ai() and status or nil
	end

	function HUDTeammateCustom:set_waiting(status, peer)
		self._is_waiting = status
		self:reset()
		self:set_ai(not status)
		self:_set_layout(status)
		if status then
			self:set_name(peer:name())
			self:set_peer_id(peer:id())
			self:set_callsign(peer:id())

			local outfit = peer:profile().outfit
			outfit = outfit or managers.blackmarket:unpack_outfit_from_string(peer:profile().outfit_string) or {}
			if outfit.deployable then
				local amount = outfit.deployable_amount or 0
				if type(amount) == "table" then
					self:set_deployable_equipment_from_string({ icon = tweak_data.equipments[outfit.deployable].icon, amount = amount })
				else
					self:set_deployable_equipment({ icon = tweak_data.equipments[outfit.deployable].icon, amount = amount })
				end
			end
			if outfit.secondary_deployable then
				local amount = outfit.secondary_deployable_amount or 0
				if type(amount) == "table" then
					amount = amount[1]
				end
				self:set_cable_tie({ icon = tweak_data.equipments[outfit.secondary_deployable].icon, amount = amount })
			end
			if outfit.grenade then
				self:set_grenades({ icon = tweak_data.blackmarket.projectiles[outfit.grenade].icon, amount = managers.player:get_max_grenades(peer:grenade_id()) })
			end
		else
			local character = managers.criminals:character_name_by_panel_id(self._id)
			if character then
				self:set_name(managers.localization:text("menu_" .. character))
			end
			self:set_callsign(5)
		end
	end

	function HUDTeammateCustom:set_state(state)
		self:teammate_progress(false, "", 0, false)
		self:_set_layout(state == "player" and true or false)

		for i, component in ipairs(self._all_components or {}) do
			component:set_is_local_player(self:is_local_player())
		end
	end

	function HUDTeammateCustom:teammate_progress(enabled, tweak_id, timer, success)
		if enabled then
			self:call_listeners("interaction_start", tweak_id, timer)
		else
			self:call_listeners("interaction_stop", success)
		end
	end

	function HUDTeammateCustom:set_interaction_tweak(enabled, tweak_data)
		if enabled then
			self:call_listeners("interaction_tweak", tweak_data)
		end
	end

	function HUDTeammateCustom:set_carry_info(id, value)
		self:call_listeners("set_carry", id, value)
	end

	function HUDTeammateCustom:remove_carry_info()
		self:call_listeners("clear_carry")
	end

	function HUDTeammateCustom:recreate_weapon_firemode()
		--Obsolete, ignore
	end

	function HUDTeammateCustom:set_accuracy(value)
		self:call_listeners("accuracy", value)
	end

	function HUDTeammateCustom:reset_accuracy()
		self:set_accuracy(0)
	end

	function HUDTeammateCustom:increment_kill_count(is_special, headshot)
		self:call_listeners("increment_kill_count", is_special, headshot)
	end

	function HUDTeammateCustom:reset_kill_count()
		self:call_listeners("reset_kill_count")
	end

	function HUDTeammateCustom:set_weapon(index, id, silencer)
		self:call_listeners("weapon", index, id, silencer)
	end

	function HUDTeammateCustom:set_available_fire_modes(index, modes)
		self:call_listeners("available_fire_modes", index, modes)
	end

	function HUDTeammateCustom:set_voice_com_active(active)
		self:call_listeners("voice_com", active)
	end

	function HUDTeammateCustom:_damage_taken()
		self:call_listeners("damage_taken")
	end

	--Failsafe for unhandled functions
	for id, ptr in pairs(HUDTeammate) do
		if type(ptr) == "function" then
			HUDTeammateCustom[id] = HUDTeammateCustom[id] or function(self, ...)
				print_warning("HUDTeammateCustom: Unoverridden function call: %s", id)
			end
		end
	end

	PlayerInfoComponent = PlayerInfoComponent or {}

	PlayerInfoComponent.Base = PlayerInfoComponent.Base or class()

	function PlayerInfoComponent.Base:init(base_panel, owner, name, width, height)
		self._name = name
		self._owner_panel = base_panel
		self._owner = owner
		self._disable_reason = {}
		self._is_ai = nil
		self._is_local_player = nil
		self._align = "left"

		self._panel = self._owner_panel:panel({
			name = name,
			h = height or 0,
			w = width or 0,
		})
	end

	function PlayerInfoComponent.Base:destroy()
		self._panel:stop()
		self._owner_panel:remove(self._panel)
	end

	function PlayerInfoComponent.Base:set_size(w, h)
		w = w or self._panel:w()
		h = h or self._panel:h()

		if self._panel:w() ~= w or self._panel:h() ~= h then
			self._panel:set_size(w, h)
			return true
		end
	end

	function PlayerInfoComponent.Base:set_enabled(reason, status)
		self._disable_reason[reason] = (not status) and true or nil

		local visible = next(self._disable_reason) == nil
		if self._panel:visible() ~= visible then
			self._panel:set_visible(visible)
			return true
		end
	end

	function PlayerInfoComponent.Base:update_settings()	--Override for classes with settings

	end

	function PlayerInfoComponent.Base:set_alignment(align)
		if self._align ~= align then
			self._align = align
			return true
		end
	end

	function PlayerInfoComponent.Base:rescale(factor)
		if factor and factor ~= 1 then
			self._panel:set_w(self._panel:w() * factor)
			self._panel:set_h(self._panel:h() * factor)
			return true
		end
	end

	function PlayerInfoComponent.Base:set_is_ai(state)	--Override for classes that change behavior for AI/non-AI
		local state = state and true or false

		if self._is_ai ~= state then
			self._is_ai = state
			return true
		end
	end

	function PlayerInfoComponent.Base:set_is_local_player(state)	--Override for classes that change behavior for player/teammate
		local state = state and true or false

		if self._is_local_player ~= state then
			self._is_local_player = state
			return true
		end
	end

	function PlayerInfoComponent.Base:set_is_waiting(state)	--Override for classes that change behavior for waiting/non-waiting
		local state = state and true or false

		if self._is_waiting ~= state then
			self._is_waiting = state
			return true
		end
	end

	function PlayerInfoComponent.Base:enabled()
		return next(self._disable_reason) == nil
	end

	function PlayerInfoComponent.Base:panel() return self._panel end
	function PlayerInfoComponent.Base:alpha() return self._panel:alpha() end
	function PlayerInfoComponent.Base:w() return self._panel:w() end
	function PlayerInfoComponent.Base:h() return self._panel:h() end
	function PlayerInfoComponent.Base:x() return self._panel:x() end
	function PlayerInfoComponent.Base:y() return self._panel:y() end
	function PlayerInfoComponent.Base:left() return self._panel:left() end
	function PlayerInfoComponent.Base:right() return self._panel:right() end
	function PlayerInfoComponent.Base:top() return self._panel:top() end
	function PlayerInfoComponent.Base:bottom() return self._panel:bottom() end
	function PlayerInfoComponent.Base:center() return self._panel:center() end
	function PlayerInfoComponent.Base:center_x() return self._panel:center_x() end
	function PlayerInfoComponent.Base:center_y() return self._panel:center_y() end
	function PlayerInfoComponent.Base:visible() return self._panel:visible() end
	function PlayerInfoComponent.Base:layer() return self._panel:layer() end

	function PlayerInfoComponent.Base:set_alpha(v) self._panel:set_alpha(v) end
	function PlayerInfoComponent.Base:set_x(v) self._panel:set_x(v) end
	function PlayerInfoComponent.Base:set_y(v) self._panel:set_y(v) end
	function PlayerInfoComponent.Base:set_left(v) self._panel:set_left(v) end
	function PlayerInfoComponent.Base:set_right(v) self._panel:set_right(v) end
	function PlayerInfoComponent.Base:set_top(v) self._panel:set_top(v) end
	function PlayerInfoComponent.Base:set_bottom(v) self._panel:set_bottom(v) end
	function PlayerInfoComponent.Base:set_center(x, y) self._panel:set_center(x, y) end
	function PlayerInfoComponent.Base:set_center_x(v) self._panel:set_center_x(v) end
	function PlayerInfoComponent.Base:set_center_y(v) self._panel:set_center_y(v) end
	function PlayerInfoComponent.Base:set_layer(v) self._panel:set_layer(v) end

	function PlayerInfoComponent.Base.get_item_icon_data(type, id)
		local tweak_entry = {
			weapon_skin = tweak_data.blackmarket.weapon_skins,
			weapon = tweak_data.weapon,
			melee = tweak_data.blackmarket.melee_weapons,
			armor = tweak_data.blackmarket.armors,
			throwable = tweak_data.blackmarket.projectiles,
			deployables = tweak_data.blackmarket.deployables,
		}
		local texture_path = {
			weapon_skin = "weapon_skins/",
			weapon = "textures/pd2/blackmarket/icons/weapons/",
			melee = "textures/pd2/blackmarket/icons/melee_weapons/",
			armor = "textures/pd2/blackmarket/icons/armors/",
			throwable = "textures/pd2/blackmarket/icons/grenades/",
			deployables = "textures/pd2/blackmarket/icons/deployables/",
		}

		local bundle_folder = tweak_entry[type][id] and tweak_entry[type][id].texture_bundle_folder
		local guis_catalog = string.format("guis/%s", bundle_folder and string.format("dlcs/%s/", tostring(bundle_folder)) or "")
		local texture_name = tweak_entry[type][id] and tweak_entry[type][id].texture_name or tostring(id)
		local texture = string.format("%s%s%s", guis_catalog, texture_path[type], texture_name)

		if type == "weapon_skin" then
			id = tweak_entry[type][id] and tweak_entry[type][id].weapon_id
			type = "weapon"
		end
		local name_id = tweak_entry[type][id] and tweak_entry[type][id].name_id or tostring(id)
		local name_text = managers.localization:text(name_id)

		return texture, name_text
	end

	PlayerInfoComponent.PlayerInfo = PlayerInfoComponent.PlayerInfo or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.PlayerInfo:init(panel, owner, height, settings)
		PlayerInfoComponent.PlayerInfo.super.init(self, panel, owner, "player_info", 0, height)

		self._settings = settings
		self._components = {}

		for i, name in ipairs({ "name", "character", "rank" }) do
			self._components[name] = self._panel:text({
				name = name,
				color = Color.white,
				align = "center",
				vertical = "center",
				h = height,
				w = 0,
				font_size = height * 0.95,
				font = tweak_data.hud_players.name_font,
			})
		end

		self._owner:register_listener("PlayerInfo", { "callsign" }, callback(self, self, "set_id"), false)
		self._owner:register_listener("PlayerInfo", { "name" }, callback(self, self, "set_name"), false)
		self._owner:register_listener("PlayerInfo", { "character" }, callback(self, self, "set_character"), false)
		self._owner:register_listener("PlayerInfo", { "rank" }, callback(self, self, "set_rank"), false)
		self._owner:register_listener("PlayerInfo", { "cheater" }, callback(self, self, "set_cheater"), false)
	end

	function PlayerInfoComponent.PlayerInfo:destroy()
		self._owner:unregister_listener("PlayerInfo", { "callsign", "name", "character", "rank" })
		PlayerInfoComponent.PlayerInfo.super.destroy(self)
	end

	function PlayerInfoComponent.PlayerInfo:arrange()
		local MARGIN = 3
		local h = self._panel:h()
		local w = 0

		for i, name in ipairs({ "name", "character", "rank" }) do
			local component = self._components[name]

			if component:visible() then
				local _, _, t_w, _ = component:text_rect()
				component:set_w(t_w)
				component:set_x(w)
				w = w + t_w + MARGIN
			end
		end

		if self:set_size(w, self._panel:h()) then
			self:set_enabled("panel_size", w > 0)
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.PlayerInfo:update_settings()
		self:set_enabled("setting", self._settings.NAME or self._settings.RANK or self._settings.CHARACTER)
		self:_update_component_visibility()
	end

	function PlayerInfoComponent.PlayerInfo:rescale(factor)
		if PlayerInfoComponent.PlayerInfo.super.rescale(self, factor) then
			for name, component in pairs(self._components) do
				component:set_h(component:h() * factor)
				component:set_font_size(component:font_size() * factor)
			end
		end
	end

	function PlayerInfoComponent.PlayerInfo:set_is_ai(state)
		if PlayerInfoComponent.PlayerInfo.super.set_is_ai(self, state) then
			self:_update_component_visibility()
		end
	end

	function PlayerInfoComponent.PlayerInfo:set_id(id)
		self._id = id
		self:_set_text_color((id == 5 and WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "USE"}, false)) and WolfHUD:getColorSetting({"CustomHUD", "TEAMMATE", "AI_COLOR", "COLOR"}, "white") or tweak_data.chat_colors[id])
	end

	function PlayerInfoComponent.PlayerInfo:set_cheater(state)
		self._is_cheater = state and true or false

		if self._is_cheater then
			self:_set_text_color(tweak_data.screen_colors.pro_color)
		elseif self._id then
			self:set_id(self._id)
		end
	end

	function PlayerInfoComponent.PlayerInfo:set_name(name)
		if name then
			if self._settings.TRUNCATE_TAGS and not self._is_ai then
				name = WolfHUD:truncateNameTag(name)
			end
			self._components.name:set_text(name)
			self:arrange()
		end
	end

	function PlayerInfoComponent.PlayerInfo:set_character(character)
		if character then
			local str = string.format("(%s)", managers.localization:text("menu_" .. character))
			self._components.character:set_text(str)

			self:arrange()
		end
	end

	function PlayerInfoComponent.PlayerInfo:set_rank(infamy, level)
		if level then
			local str = string.format("[%s%s]",
				(infamy or 0) > 0 and string.format("%s-", managers.experience:rank_string(infamy)) or "",
				tostring(level)
			)
			self._components.rank:set_text(str)

			self:arrange()
		end
	end

	function PlayerInfoComponent.PlayerInfo:_update_component_visibility()
		self._components.name:set_visible(self._settings.NAME)
		self._components.character:set_visible(self._settings.CHARACTER and not self._is_ai)
		self._components.rank:set_visible(self._settings.RANK and not self._is_ai)
		self:arrange()
	end

	function PlayerInfoComponent.PlayerInfo:_set_text_color(color)
		for name, component in pairs(self._components) do
			component:set_color(color)
		end
	end

	PlayerInfoComponent.Latency = PlayerInfoComponent.Latency or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Latency:init(panel, owner, height, settings)
		PlayerInfoComponent.Latency.super.init(self, panel, owner, "latency", height*2, height)

		self._settings = settings

		self._text = self._panel:text({
			name = "latency",
			text = "n/a",
			color = Color('E24E4E'),
			halign = "grow",
			align = "center",
			vertical = "center",
			h = height,
			font_size = height * 0.95,
			font = tweak_data.hud_players.name_font,
		})

		self._owner:register_listener("Latency", { "latency" }, callback(self, self, "set_latency"), false)
	end

	function PlayerInfoComponent.Latency:destroy()
		self._owner:unregister_listener("Latency", { "latency" })

		PlayerInfoComponent.Latency.super.destroy(self)
	end

	function PlayerInfoComponent.Latency:update_settings()
		if self:set_enabled("setting", self._settings.LATENCY) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Latency:rescale(factor)
		if PlayerInfoComponent.Latency.super.rescale(self, factor) then
			self._text:set_h(self._text:h() * factor)
			self._text:set_font_size(self._text:font_size() * factor)
		end
	end

	function PlayerInfoComponent.Latency:set_is_ai(state)
		if PlayerInfoComponent.Latency.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Latency:set_is_local_player(state)
		if PlayerInfoComponent.Latency.super.set_is_local_player(self, state) and self:set_enabled("player", not self._is_local_player) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Latency:set_latency(value)
		if type(value) == "number" then
			self._text:set_text(string.format("%.0fms", value))
			self._text:set_color(value < 75 and Color('C2FC97') or value < 150 and Color('CEA168') or Color('E24E4E'))
		else
			self._text:set_text(value)
			self._text:set_color(Color('E24E4E'))
		end
	end

	PlayerInfoComponent.Build = PlayerInfoComponent.Build or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Build:init(panel, owner, height, settings)
		PlayerInfoComponent.Build.super.init(self, panel, owner, "build", 0, height)

		self._settings = settings

		self._specialization = self._panel:text({
			name = "specialization",
			color = Color.white,
			align = "center",
			vertical = "center",
			h = height,
			font_size = height * 0.95,
			font = tweak_data.hud_players.name_font,
		})

		self._skills = self._panel:text({
			name = "skills",
			color = Color.white,
			align = "center",
			vertical = "center",
			h = height,
			font_size = height * 0.95,
			font = tweak_data.hud_players.name_font,
		})

		self._owner:register_listener("Build", { "specialization" }, callback(self, self, "set_specialization"), false)
		self._owner:register_listener("Build", { "skills" }, callback(self, self, "set_skills"), false)
	end

	function PlayerInfoComponent.Build:destroy()
		self._owner:unregister_listener("Build", { "specialization", "skills" })
		PlayerInfoComponent.Build.super.destroy(self)
	end

	function PlayerInfoComponent.Build:update_settings()
		if self:set_enabled("setting", not self._settings.BUILD.HIDE) then
			self._owner:arrange()
		end
		self._duration = self._settings.BUILD.DURATION
	end

	function PlayerInfoComponent.Build:rescale(factor)
		if PlayerInfoComponent.Build.super.rescale(self, factore) then
			self._specialization:set_h(self._specialization:h() * factor)
			self._skills:set_h(self._skills:h() * factor)
			self._specialization:set_font_size(self._specialization:font_size() * factor)
			self._skills:set_font_size(self._skills:font_size() * factor)
		end
	end

	function PlayerInfoComponent.Build:set_is_ai(state)
		if PlayerInfoComponent.Build.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Build:set_is_local_player(state)
		if PlayerInfoComponent.Build.super.set_is_local_player(self, state) and self:set_enabled("player", not self._is_local_player) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Build:arrange()
		if self._duration then
			self._panel:stop()
			self._panel:animate(callback(self, self, "_expire"))
		end

		self._skills:set_x(0)
		local w = self._skills:w() + self._panel:h() * 0.3
		self._specialization:set_x(w)
		w = w + self._specialization:w()

		self._specialization:set_x(0)
		local w = self._specialization:w() + self._panel:h() * 0.3
		self._skills:set_x(w)
		w = w + self._skills:w()

		if self:set_size(w, self._panel:h()) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Build:set_specialization(index, level)
		local data = tweak_data.skilltree.specializations[index]
		local name_id = data and data.name_id

		if name_id then
			local text = managers.localization:text(name_id)
			self._specialization:set_text(string.format("%s: %d |", text, level))
			local _, _, w, _ = self._specialization:text_rect()
			self._specialization:set_w(w)
			self:arrange()
		end
	end

	function PlayerInfoComponent.Build:set_skills(data)
		local trees = {}
		for i, tree in ipairs(tweak_data.skilltree.skill_pages_order) do
			local tree = tweak_data.skilltree.skilltree[tree]
			if tree then
				table.insert(trees, tree.name_id and utf8.sub(managers.localization:text(tree.name_id), 1, 1) or "?")
			end
		end
		local subtree_amt = math.floor(#data / #trees)

		local text = ""

		for tree = 1, #trees, 1 do
			local tree_has_points = false
			local skill_string = ""

			for sub_tree = 1, subtree_amt, 1 do
				local skills = data[(tree-1) * subtree_amt + sub_tree] or 0
				skill_string = string.format("%s%02d%s", skill_string, tonumber(skills), sub_tree < 3 and "|" or "")
				if tonumber(skills) > 0 then
					tree_has_points = true
				end
			end

			if tree_has_points then
				text = string.format("%s%s:%s%s", text, trees[tree] or tostring(tree), skill_string, tree < #trees and " " or "")
			end
		end

		self._skills:set_text(text)
		local _, _, w, _ = self._skills:text_rect()
		self._skills:set_w(w)
		self:arrange()
	end

	function PlayerInfoComponent.Build:_expire(panel)
		if self:set_enabled("expiration", true) then
			self._owner:arrange()
		end
		self._panel:set_alpha(1)

		local t = 0
		while t < self._duration do
			t = t + coroutine.yield()
		end

		t = 3
		while t > 0 do
			t = t - coroutine.yield()
			self._panel:set_alpha(t/3)
		end

		if self:set_enabled("expiration", false) then
			self._owner:arrange()
		end
	end

	PlayerInfoComponent.KillCounter = PlayerInfoComponent.KillCounter or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.KillCounter:init(panel, owner, height, settings)
		PlayerInfoComponent.KillCounter.super.init(self, panel, owner, "kill_counter", 0, height)

		self._settings = settings

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/cn_miniskull",
			color = Color.white,
			h = height,
			w = height,
		})

		self._text = self._panel:text({
			name = "text",
			layer = 1,
			color = Color.white,
			vertical = "center",
			align = "center",
			h = height,
			font_size = height * 0.95,
			font = tweak_data.hud.medium_font_noshadow,
		})
		self._text:set_left(self._icon:right() + 1)

		self:reset()

		self._owner:register_listener("KillCounter", { "increment_kill_count" }, callback(self, self, "increment"), false)
		self._owner:register_listener("KillCounter", { "reset_kill_count" }, callback(self, self, "reset"), false)
	end

	function PlayerInfoComponent.KillCounter:destroy()
		self._owner:unregister_listener("KillCounter", { "increment_kill_count", "reset_kill_count" })

		PlayerInfoComponent.KillCounter.super.destroy(self)
	end

	function PlayerInfoComponent.KillCounter:update_settings()
		local setting = self:set_enabled("setting", not self._settings.KILLCOUNTER.HIDE)
		local plugin = self:set_enabled("plugin", HUDManager.KILL_COUNTER_PLUGIN)
		local ai = self:set_enabled("ai", self._settings.KILLCOUNTER.SHOW_BOT_KILLS or not self._is_ai)

		local color = self._settings.KILLCOUNTER.COLOR
		self._icon:set_color(color)
		self._text:set_color(color)

		if setting or plugin or ai then
			self:_update_text()
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.KillCounter:rescale(factor)
		if PlayerInfoComponent.KillCounter.super.rescale(self, factor) then
			self._icon:set_size(self._icon:w() * factor, self._icon:h() * factor)
			self._text:set_size(self._text:w() * factor, self._text:h() * factor)
			self._text:set_font_size(self._text:font_size() * factor)
			self._text:set_left(self._icon:right() + 1)
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.KillCounter:set_is_ai(state)
		if PlayerInfoComponent.KillCounter.super.set_is_ai(self, state) and self:set_enabled("ai", self._settings.KILLCOUNTER.SHOW_BOT_KILLS or not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.KillCounter:set_is_waiting(state)
		if PlayerInfoComponent.KillCounter.super.set_is_waiting(self, state) and self:set_enabled("waiting", not self._is_waiting) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.KillCounter:increment(is_special, headshot)
		self._kills = self._kills + 1
		self._special_kills = self._special_kills + (is_special and 1 or 0)
		self._headshot_kills = self._headshot_kills + (headshot and 1 or 0)
		self:_update_text()
	end

	function PlayerInfoComponent.KillCounter:reset()
		self._kills = 0
		self._special_kills = 0
		self._headshot_kills = 0
		self:_update_text()
	end

	function PlayerInfoComponent.KillCounter:_update_text()
		if self._settings.KILLCOUNTER.SHOW_SPECIAL_KILLS and self._settings.KILLCOUNTER.SHOW_HEADSHOT_KILLS then
			self._text:set_text(string.format("%d/%d (%d)", self._kills, self._special_kills, self._headshot_kills))
		elseif self._settings.KILLCOUNTER.SHOW_SPECIAL_KILLS then
			self._text:set_text(string.format("%d/%d", self._kills, self._special_kills))
		elseif self._settings.KILLCOUNTER.SHOW_HEADSHOT_KILLS then
			self._text:set_text(string.format("%d (%d)", self._kills, self._headshot_kills))
		else
			self._text:set_text(string.format("%d", self._kills))
		end

		local _, _, w, _ = self._text:text_rect()
		self._text:set_w(w)

		if self:set_size(self._text:right(), self._panel:h()) then
			self._owner:arrange()
		end
	end

	PlayerInfoComponent.AccuracyCounter = PlayerInfoComponent.AccuracyCounter or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.AccuracyCounter:init(panel, owner, height, settings)
		PlayerInfoComponent.AccuracyCounter.super.init(self, panel, owner, "accuracy_counter", 0, height)

		self._settings = settings

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/pd2_waypoints",
			texture_rect = { 96, 0, 32, 32 },
			color = Color.white,
			h = height,
			w = height,
		})

		self._text = self._panel:text({
			name = "text",
			layer = 1,
			color = Color.white,
			vertical = "center",
			align = "center",
			h = height,
			font_size = height * 0.95,
			font = tweak_data.hud.medium_font_noshadow,
		})
		self._text:set_left(self._icon:right() + 1)

		self:set_accuracy(0)

		self._owner:register_listener("AccuracyCounter", { "accuracy" }, callback(self, self, "set_accuracy"), false)
	end

	function PlayerInfoComponent.AccuracyCounter:destroy()
		self._owner:unregister_listener("AccuracyCounter", { "accuracy" })
		PlayerInfoComponent.AccuracyCounter.super.destroy(self)
	end

	function PlayerInfoComponent.AccuracyCounter:update_settings()
		local setting = self:set_enabled("setting", self._settings.SHOW_ACCURACY)
		local plugin = self:set_enabled("plugin", HUDManager.ACCURACY_PLUGIN)

		if setting or plugin then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.AccuracyCounter:rescale(factor)
		if PlayerInfoComponent.AccuracyCounter.super.rescale(self, factor) then
			self._icon:set_size(self._icon:w() * factor, self._icon:h() * factor)
			self._text:set_size(self._text:w() * factor, self._text:h() * factor)
			self._text:set_font_size(self._text:font_size() * factor)
			self._text:set_left(self._icon:right() + 1)
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.AccuracyCounter:set_is_local_player(state)
		if PlayerInfoComponent.AccuracyCounter.super.set_is_local_player(self, state) and self:set_enabled("player", self._is_local_player) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.AccuracyCounter:set_is_waiting(state)
		if PlayerInfoComponent.AccuracyCounter.super.set_is_waiting(self, state) and self:set_enabled("waiting", not self._is_waiting) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.AccuracyCounter:set_accuracy(value)
		self._text:set_text(string.format("%.0f%%", value))

		local _, _, w, _ = self._text:text_rect()
		self._text:set_w(w)

		if self:set_size(self._text:right(), self._panel:h()) then
			self._owner:arrange()
		end
	end

	PlayerInfoComponent.WaitingInput = PlayerInfoComponent.WaitingInput or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.WaitingInput:init(panel, owner, height, settings)
		PlayerInfoComponent.WaitingInput.super.init(self, panel, owner, "waiting_input", 0, height)

		self._settings = settings

		local buttons = {
			{ text = "hud_waiting_accept",  binding = "drop_in_accept"  },
			{ text = "hud_waiting_return",  binding = "drop_in_return"  },
			{ text = "hud_waiting_kick",    binding = "drop_in_kick"    }
		}
		local text = ""
		for i, btn in ipairs(buttons or {}) do
			local button_text = managers.localization:btn_macro(btn.binding, true, true)
			if button_text then
				text = string.format("%s%s%s", text, managers.localization:text(btn.text, {MY_BTN = button_text}), i < #buttons and "   |   " or "")
			end
		end
		if text:len() <= 0 then
			text = managers.localization:text("hud_waiting_no_binding_text")
		end

		local PADDING = 5

		self._text = self._panel:text({
			name = "text",
			layer = 1,
			text = text,
			color = Color.white,
			vertical = "center",
			align = "center",
			x = PADDING,
			y = PADDING * 0.5,
			h = self._panel:h(),
			font_size = height * 0.9,
			font = tweak_data.hud.medium_font_noshadow,
		})
		local _, _, w, _ = self._text:text_rect()
		self._text:set_w(w)

		if self:set_size(self._text:right() + (2 * PADDING), self._panel:h() + PADDING) then
			self._panel:rect({
				name = "bg",
				color = Color.black,
				alpha = 0.5,
				h = self._panel:h(),
				w = self._panel:w(),
			})

			self._owner:arrange()
		end

		self:set_enabled("waiting", false)
		--self:set_enabled("is_host", Network:is_server())
	end

	function PlayerInfoComponent.WaitingInput:rescale(factor)
		if PlayerInfoComponent.WaitingInput.super.rescale(self, factor) then
			self._text:set_font_size(self._text:font_size() * factor)
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingInput:set_is_ai(state)
		if PlayerInfoComponent.WaitingInput.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingInput:set_is_local_player(state)
		if PlayerInfoComponent.WaitingInput.super.set_is_local_player(self, state) and self:set_enabled("player", not self._is_local_player) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingInput:set_is_waiting(state)
		if PlayerInfoComponent.WaitingInput.super.set_is_waiting(self, state) and self:set_enabled("waiting", self._is_waiting) then
			self._owner:arrange()
			if self:enabled() and not self._animating_input_required then
				self._animating_input_required = true
				self._text:animate(callback(self, self, "_animate_input_required"))
			elseif self._animating_input_required then
				self._animating_input_required = nil
				self._text:stop()
			end
		end
	end

	function PlayerInfoComponent.WaitingInput:_animate_input_required(text)
		local t = 0
		text:set_color(Color(1, 1, 1, 1))
		while self._animating_input_required do
			t = t + coroutine.yield()
			text:set_color(Color(1, 1 , 1, 1 - (0.5 * math.sin(t * 240 * 2) + 0.5)))
		end
		text:set_color(Color(1, 1, 1, 1))
	end

	PlayerInfoComponent.Callsign = PlayerInfoComponent.Callsign or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Callsign:init(panel, owner, size, settings)
		PlayerInfoComponent.Callsign.super.init(self, panel, owner, "callsign", size, size)

		self._settings = settings
		self._size = size

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = { 84, 34, 19, 19 },
			color = Color.white,
			h = size * 0.75,
			w = size * 0.75,
			layer = self._panel:layer() - 2,
		})

		self._voice_com = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/jukebox_playing",
			texture_rect = { 0, 0, 16, 16 },
			color = Color.white,
			visible = false,
			h = size * 0.75,
			w = size * 0.75,
			layer = self._panel:layer() + 3,
		})

		self._condition_icon = self._panel:bitmap({
			name = "condition_icon",
			visible = false,
			color = self._settings.CONDITION_ICON_COLOR,
			h = size,
			w = size,
		})

		self._icon:set_center(self._panel:w() / 2, self._panel:h() / 2)

		self._owner:register_listener("Callsign", { "callsign" }, callback(self, self, "set_id"), false)
		self._owner:register_listener("Callsign", { "voice_com" }, callback(self, self, "set_voice_com_active"), false)
		self._owner:register_listener("Callsign", { "condition" }, callback(self, self, "set_condition"), false)
	end

	function PlayerInfoComponent.Callsign:destroy()
		self._owner:unregister_listener("Callsign", { "callsign", "voice_com", "condition" })
		PlayerInfoComponent.Callsign.super.destroy(self)
	end

	function PlayerInfoComponent.Callsign:set_is_ai(state)
		if PlayerInfoComponent.Callsign.super.set_is_ai(self, state) then

			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Callsign:update_settings()
		self._condition_icon:set_color(self._settings.CONDITION_ICON_COLOR)

		if self:set_enabled("setting", self._settings.CALLSIGN) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Callsign:rescale(factor)
		if PlayerInfoComponent.Callsign.super.rescale(self, factor) then
			self._size = self._size * factor
			self._icon:set_w(self._icon:w() * factor)
			self._icon:set_h(self._icon:h() * factor)
			self._voice_com:set_w(self._voice_com:w() * factor)
			self._voice_com:set_h(self._voice_com:h() * factor)
			self._condition_icon:set_w(self._condition_icon:w() * factor)
			self._condition_icon:set_h(self._condition_icon:h() * factor)
			self._icon:set_center(self._panel:w() / 2, self._panel:h() / 2)
			self._voice_com:set_center(self._panel:w() / 2, self._panel:h() / 2)
			self._condition_icon:set_center(self._panel:w() / 2, self._panel:h() / 2)
		end
	end

	function PlayerInfoComponent.Callsign:set_id(id)
		local color = (tweak_data.chat_colors[id] or Color.white):with_alpha(1)
		self._icon:set_color(color)
		self._voice_com:set_color(color)
	end

	function PlayerInfoComponent.Callsign:set_enabled(reason, status)
		if PlayerInfoComponent.Callsign.super.set_enabled(self, reason, status) then
			self._icon:set_visible(self._panel:visible())
			self._panel:set_visible(true)
		else
			self._icon:set_visible(true)
		end
	end

	function PlayerInfoComponent.Callsign:set_voice_com_active(status)
		self._voice_com_active = status

		if status and not self._animating_voice_com then
			self._voice_com:animate(callback(self, self, "_animate_voice_com"))
		end
	end

	function PlayerInfoComponent.Callsign:_animate_voice_com(icon)
		self._animating_voice_com = true
		local x = self._panel:w() / 2
		local y = self._panel:h() / 2
		icon:set_visible(true)

		while self._voice_com_active do
			local T = 2
			local t = 0

			while t < T do
				local r = (math.sin(t * 360)) * 0.15
				icon:set_size(self:w() * (1+r), self:h() * (1+r))
				icon:set_center(x, y)

				t = t + coroutine.yield()
			end
		end

		icon:set_visible(false)
		icon:set_center(x, y)
		icon:set_size(self:w(), self:h())
		self._animating_voice_com = false
	end

	function PlayerInfoComponent.Callsign:set_condition(icon_data)
		local visible = (icon_data ~= "mugshot_normal" and self._is_ai)

		if visible then
			local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon_data)
			self._condition_icon:set_image(icon, unpack(texture_rect))
			self._condition_icon:set_w(self._size * math.min(texture_rect[3] / texture_rect[4], 1))
			self._condition_icon:set_h(self._size * math.min(texture_rect[4] / texture_rect[3], 1))
			self._condition_icon:set_center(self._panel:w() / 2, self._panel:h() / 2)
		end

		self._condition_icon:set_visible(visible)
	end

	PlayerInfoComponent.PlayerStatus = PlayerInfoComponent.PlayerStatus or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.PlayerStatus:init(panel, owner, width, height, settings)
		PlayerInfoComponent.PlayerStatus.super.init(self, panel, owner, "player_status", width, height)

		self._settings = settings

		self._size = height

		local health_bg = self._panel:bitmap({
			name = "health_bg",
			texture = "guis/textures/pd2/hud_radialbg",
			h = self._size,
			w = self._size,
		})

		self._health_radial = self._panel:bitmap({
			name = "health_radial",
			texture = "guis/textures/pd2/hud_health",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(1, 1, 1),
			h = self._size,
			w = self._size,
			layer = health_bg:layer() + 1,
		})
		self._health_radial:set_texture_rect(self._health_radial:texture_width(), 0, -self._health_radial:texture_width(), self._health_radial:texture_height())

		self._stored_health_radial = self._panel:bitmap({
			name = "stored_health_radial",
			texture = "guis/textures/pd2/hud_health",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(0, 0, 0),
			alpha = 0.5,
			h = self._size,
			w = self._size,
			layer = self._health_radial:layer() - 1,
		})
		self._stored_health_radial:set_texture_rect(self._stored_health_radial:texture_width(), 0, -self._stored_health_radial:texture_width(), self._stored_health_radial:texture_height())

		self._armor_radial = self._panel:bitmap({
			name = "armor_radial",
			texture = "guis/textures/pd2/hud_shield",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(0, 1, 1),
			layer = self._stored_health_radial:layer() + 1,
			h = self._size,
			w = self._size,
			layer = self._stored_health_radial:layer() + 1,
		})
		self._armor_radial:set_texture_rect(self._armor_radial:texture_width(), 0, -self._armor_radial:texture_width(), self._armor_radial:texture_height())

		self._stamina_radial = self._panel:bitmap({
			name = "radial_shield",
			texture = "guis/textures/pd2/hud_radial_rim",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(1, 0, 0),
			halign = "scale",
			valign = "scale",
			align = "center",
			vertical = "center",
			layer = 2,
			w = self._size * 0.45,
			h = self._size * 0.45,
			layer = self._stored_health_radial:layer() + 1,
		})
		self._stamina_radial:set_center(self._size / 2, self._size / 2)

		self._damage_indicator = self._panel:bitmap({
			name = "damage_indicator",
			texture = "guis/textures/pd2/hud_radial_rim",
			blend_mode = "add",
			color = Color(1, 1, 1, 1),
			alpha = 0,
			h = self._size,
			w = self._size,
			layer = self._armor_radial:layer() + 1,
		})

		self._downs_counter = self._panel:text({
			name = "downs",
			color = Color.white,
			align = "center",
			vertical = "center",
			h = self._size * 0.25,
			w = self._size * 0.25,
			font_size = self._size * 0.2,
			font = "fonts/font_small_shadow_mf",
			layer = self._health_radial:layer() + 1,
			visible = HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER or false,
		})
		self._downs_counter:set_center(self._size / 2, self._size / 2)

		self._detection_counter = self._panel:text({
			name = "detection",
			text = utf8.char(57363),
			color = Color.red,
			align = "center",
			vertical = "center",
			h = self._size * 0.25,
			w = self._size * 0.25,
			font_size = self._size * 0.2,
			font = "fonts/font_small_mf",
			layer = self._health_radial:layer() + 1,
			visible = HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER or false,
		})
		self._detection_counter:set_center(self._size / 2, self._size / 2)

		local center_bg = self._panel:bitmap({
			name = "center_bg",
			texture = "guis/textures/pd2/crimenet_marker_glow",
			blend_mode = "normal",
			color = Color.black,
			alpha = 0.65,
			w = self._size,
			h = self._size,
			layer = self._health_radial:layer() - 2,
			visible = true,
		})

		self._condition_icon = self._panel:bitmap({
			name = "condition_icon",
			visible = false,
			color = self._settings.CONDITION_ICON_COLOR,
			h = self._size,
			w = self._size,
			layer = 10,
		})

		self._condition_timer = self._panel:text({
			name = "condition_timer",
			visible = false,
			color = Color.white,
			w = self._size,
			h = self._size,
			align = "center",
			vertical = "center",
			font_size = self._size * 0.5,
			font = tweak_data.hud_players.timer_font,
			layer = self._condition_icon:layer() + 1,
		})

		self._custom_radial_icon = self._panel:bitmap({
			name = "custom_radial_icon",
			texture = "guis/textures/pd2/hud_swansong",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(1, 0, 0, 0),
			visible = false,
			h = self._size,
			w = self._size,
			layer = self._condition_icon:layer(),
		})

		self._ability_radial_icon = self._panel:bitmap({
			name = "custom_radial_icon",
			texture = "guis/textures/pd2/hud_fearless",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			color = Color(1, 0, 0, 0),
			visible = false,
			h = self._size,
			w = self._size,
			layer = self._condition_icon:layer(),
		})

		self._maniac_absorb_radial = self._panel:bitmap({
			name = "maniac_absorb_radial",
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_shield",
			render_template = "VertexColorTexturedRadial",
			w = self._size * 0.92,
			h = self._size * 0.92,
			color = Color(1, 0, 0, 0),
			visible = false,
			layer = self._condition_icon:layer() - 1,
		})
		self._maniac_absorb_radial:set_center(self._size / 2, self._size / 2)

		self._radial_delayed_damage_armor = self._panel:bitmap({
			texture = "guis/textures/pd2/hud_dot_shield",
			name = "radial_delayed_damage_armor",
			visible = false,
			render_template = "VertexColorTexturedRadialFlex",
			layer = self._condition_icon:layer() - 1,
			w = self._size,
			h = self._size
		})

		self._radial_delayed_damage_health = self._panel:bitmap({
			texture = "guis/textures/pd2/hud_dot",
			name = "radial_delayed_damage_health",
			visible = false,
			render_template = "VertexColorTexturedRadialFlex",
			layer = self._condition_icon:layer() - 1,
			w = self._size,
			h = self._size
		})

		--self._maniac_stack_radial = ...
		self._components = { health_bg, self._health_radial, self._stored_health_radial, self._armor_radial, --[[self._stamina_radial,]] self._damage_indicator, self._downs_counter, self._detection_counter, center_bg, self._condition_icon, self._custom_radial_icon, self._ability_radial_icon, self._maniac_absorb_radial, self._radial_delayed_damage_armor, self._radial_delayed_damage_health }

		local tweak = tweak_data.upgrades
		self._max_absorb = tweak.cocaine_stacks_dmg_absorption_value * tweak.values.player.cocaine_stack_absorption_multiplier[1] * tweak.max_total_cocaine_stacks  / tweak.cocaine_stacks_convert_levels[2]

		self._stored_health = 0
		self._stored_health_max = 0

		self._risk = 0
		self._downs = 0
		self._max_downs = (Global.game_settings.one_down and 2 or tweak_data.player.damage.LIVES_INIT) - 1
		if managers.modifiers and managers.modifiers.modify_value then
			self._max_downs = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._max_downs)
		end

		self._reviver_count = 0

		self._owner:register_listener("PlayerStatus", { "health" }, callback(self, self, "set_health"), false)
		self._owner:register_listener("PlayerStatus", { "stored_health" }, callback(self, self, "set_stored_health"), false)
		self._owner:register_listener("PlayerStatus", { "stored_health_max" }, callback(self, self, "set_stored_health_max"), false)
		self._owner:register_listener("PlayerStatus", { "set_revives" }, callback(self, self, "set_revives"), false)
		self._owner:register_listener("PlayerStatus", { "increment_downs" }, callback(self, self, "increment_downs"), false)
		self._owner:register_listener("PlayerStatus", { "reset_downs" }, callback(self, self, "reset_downs"), false)
		self._owner:register_listener("PlayerStatus", { "detection" }, callback(self, self, "set_detection"), false)
		self._owner:register_listener("PlayerStatus", { "armor" }, callback(self, self, "set_armor"), false)
		self._owner:register_listener("PlayerStatus", { "stamina" }, callback(self, self, "set_stamina"), false)
		self._owner:register_listener("PlayerStatus", { "stamina_max" }, callback(self, self, "set_stamina_max"), false)
		self._owner:register_listener("PlayerStatus", { "damage_taken" }, callback(self, self, "damage_taken"), false)
		self._owner:register_listener("PlayerStatus", { "condition" }, callback(self, self, "set_condition"), false)
		self._owner:register_listener("PlayerStatus", { "start_condition_timer" }, callback(self, self, "start_timer"), false)
		self._owner:register_listener("PlayerStatus", { "stop_condition_timer" }, callback(self, self, "stop_timer"), false)
		self._owner:register_listener("PlayerStatus", { "pause_condition_timer" }, callback(self, self, "pause_timer"), false)
		self._owner:register_listener("PlayerStatus", { "custom_radial" }, callback(self, self, "set_custom_progress"), false)
		self._owner:register_listener("PlayerStatus", { "ability_radial" }, callback(self, self, "set_ability_progress"), false)
		self._owner:register_listener("PlayerStatus", { "activate_ability" }, callback(self, self, "set_ability_active"), false)
		self._owner:register_listener("PlayerStatus", { "absorb_active" }, callback(self, self, "set_absorb"), false)
		self._owner:register_listener("PlayerStatus", { "delayed_damage" }, callback(self, self, "set_delayed_damage"), false)
		if managers.gameinfo then
			local panel_id = self._owner._id
			managers.gameinfo:register_listener("HealthRadial_whisper_mode_listener" .. tostring(panel_id), "whisper_mode", "change", callback(self, self, "_whisper_mode_change"))
		end
	end

	function PlayerInfoComponent.PlayerStatus:destroy()
		self._owner:unregister_listener("PlayerStatus", {
			"health", "stored_health", "stored_health_max", "set_revives", "increment_downs", "reset_downs", "detection",
			"armor",
			"stamina", "stamina_max",
			"damage_taken",
			"condition", "start_condition_timer", "stop_condition_timer", "pause_condition_timer",
			"custom_radial",
			"ability_radial", "activate_ability",
			"absorb_active",
			"delayed_damage"
		})
		if managers.gameinfo then
			local panel_id = self._owner._id
			managers.gameinfo:unregister_listener("HealthRadial_whisper_mode_listener" .. tostring(panel_id), "whisper_mode", "change")
		end

		PlayerInfoComponent.PlayerStatus.super.destroy(self)
	end

	function PlayerInfoComponent.PlayerStatus:update_settings()
		self._stamina_radial:set_visible(self._is_local_player and self._settings.STAMINA)
		self._condition_icon:set_color(self._settings.CONDITION_ICON_COLOR)

		local disabled = self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER)
		self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
		self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())

		if self:set_enabled("setting", self._settings.STATUS) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.PlayerStatus:rescale(factor)
		if PlayerInfoComponent.PlayerStatus.super.rescale(self, factor) then
			self._size = self._size * factor
			for id, component in pairs(self._components) do
				component:set_w(component:w() * factor)
				component:set_h(component:h() * factor)
				component:set_center(self._health_radial:w() / 2, self._health_radial:h() / 2)
			end
			self._downs_counter:set_font_size(self._downs_counter:font_size() * factor)
			self._detection_counter:set_font_size(self._detection_counter:font_size() * factor)
			self._condition_timer:set_font_size(self._condition_timer:font_size() * factor)
		end
	end

	function PlayerInfoComponent.PlayerStatus:set_is_local_player(state)
		if PlayerInfoComponent.PlayerStatus.super.set_is_local_player(self, state) then
			self._stamina_radial:set_visible(self._is_local_player and self._settings.STAMINA)
			--self._max_downs = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", (Global.game_settings.one_down and 2 or tweak_data.player.damage.LIVES_INIT)) - 1
			if self._is_local_player then
				self._max_downs = self._max_downs + managers.player:upgrade_value("player", "additional_lives", 0)
				self:set_revives(self._max_downs)
			else
				self:set_downs(0)
			end
		end
	end

	function PlayerInfoComponent.PlayerStatus:set_is_ai(state)
		if PlayerInfoComponent.PlayerStatus.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.PlayerStatus:set_is_waiting(state)
		if PlayerInfoComponent.PlayerStatus.super.set_is_waiting(self, state) and self:set_enabled("waiting", not self._is_waiting) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.PlayerStatus:set_health(current, total)
		local ratio = current / total
		self._health_radial:stop()
		self._health_radial:animate(callback(self, self, "_animate_set_health"), self._stored_health_radial, ratio)
	end

	function PlayerInfoComponent.PlayerStatus:set_stored_health(amount)
		self._stored_health = amount
		self._stored_health_radial:set_color(Color(math.min(self._stored_health, self._stored_health_max), 0, 0))
	end

	function PlayerInfoComponent.PlayerStatus:set_stored_health_max(amount)
		self._stored_health_max = amount
		self:set_stored_health(self._stored_health)
	end

	function PlayerInfoComponent.PlayerStatus:set_downs(amount)
		if amount and self._downs ~= amount then
			self._downs = amount
			self._downs_counter:set_text(tostring(self._downs))
			local progress = math.clamp(self:down_amount() / self._max_downs, 0, 1)
			self._downs_counter:set_color(math.lerp(Color.white, Color(1, 1, 0.2, 0), progress))
			local disabled = self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER)
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
	end

	function PlayerInfoComponent.PlayerStatus:set_revives(value)
		self:set_downs(value)

		if value == 0 then
			self._downs_counter:stop()
			self._downs_counter:animate(callback(self, self, "_animate_low_life"), self._downs_counter:h() * 0.65, self._downs_counter:h() * 0.95)
		else
			self._downs_counter:stop()
			self._downs_counter:set_font_size(self._size * 0.2)
		end
	end

	function PlayerInfoComponent.PlayerStatus:increment_downs()
		self:set_downs(self._downs + 1)
	end

	function PlayerInfoComponent.PlayerStatus:reset_downs()
		self:set_downs(self._is_local_player and self._max_downs or 0)
	end

	function PlayerInfoComponent.PlayerStatus:down_amount()
		return self._is_local_player and self._max_downs - self._downs or self._downs
	end

	function PlayerInfoComponent.PlayerStatus:set_detection(risk)
		if risk and self._risk ~= risk then
			self._risk = risk

			local color = self._risk < 50 and Color(1, 0, 0.8, 1) or Color(1, 1, 0.2, 0)
			self._detection_counter:set_text(utf8.char(57363) .. tostring(self._risk))
			self._detection_counter:set_color(color)

			local disabled = self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER)
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
	end

	function PlayerInfoComponent.PlayerStatus:_whisper_mode_change(event, key, status)
		local disabled = self._condition_icon:visible() or not (HUDManager.DOWNS_COUNTER_PLUGIN and self._settings.DOWNCOUNTER)
		self._downs_counter:set_visible(not disabled and (not status or self:down_amount() > 0))
		self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
	end

	function PlayerInfoComponent.PlayerStatus:set_armor(current, total)
		local ratio = current / total
		self._armor_radial:set_color(Color(1, ratio, 1, 1))
	end

	function PlayerInfoComponent.PlayerStatus:set_stamina_max(amount)
		self._stamina_max = amount
	end

	function PlayerInfoComponent.PlayerStatus:set_stamina(amount)
		local ratio = amount / (self._stamina_max or 1)
		self._stamina_radial:set_color(Color(ratio, 1, 1))

		if amount <= tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD and not self._animating_low_stamina then
			self._animating_low_stamina = true
			self._stamina_radial:animate(callback(self, self, "_animate_low_stamina"))
		elseif amount > tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD and self._animating_low_stamina then
			self._animating_low_stamina = nil
		end
	end

	function PlayerInfoComponent.PlayerStatus:damage_taken()
		self._damage_indicator:stop()
		self._damage_indicator:animate(callback(self, self, "_animate_damage_taken"))
	end

	function PlayerInfoComponent.PlayerStatus:set_condition(icon_data)
		local visible = icon_data ~= "mugshot_normal"

		if visible then
			local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon_data)
			self._condition_icon:set_image(icon, unpack(texture_rect))
			self._condition_icon:set_w(self._size * math.min(texture_rect[3] / texture_rect[4], 1))
			self._condition_icon:set_h(self._size * math.min(texture_rect[4] / texture_rect[3], 1))
			self._condition_icon:set_center(self._panel:w() / 2, self._panel:h() / 2)
		end

		self._condition_icon:set_visible(visible)

		self._stamina_radial:set_visible(not visible and self._is_local_player and self._settings.STAMINA)
		if HUDManager.DOWNS_COUNTER_PLUGIN and self._downs_counter and self._detection_counter then
			local disabled = visible or not self._settings.DOWNCOUNTER
			self._downs_counter:set_visible(not disabled and (not managers.groupai:state():whisper_mode() or self:down_amount() > 0))
			self._detection_counter:set_visible(not disabled and not self._downs_counter:visible())
		end
	end

	function PlayerInfoComponent.PlayerStatus:start_timer(time)
		self._condition_timer:stop()

		self._reviver_count = 0
		self._condition_timer:set_font_size(self._panel:h() * 0.5)
		self._condition_timer:show()
		self._condition_timer:animate(callback(self, self, "_animate_timer"), time)
	end

	function PlayerInfoComponent.PlayerStatus:stop_timer()
		self._condition_timer:stop()

		self._reviver_count = 0
		self._condition_timer:hide()
	end

	function PlayerInfoComponent.PlayerStatus:pause_timer(pause)
		self._reviver_count = self._reviver_count + (pause and 1 or -1)
	end

	function PlayerInfoComponent.PlayerStatus:set_custom_progress(current, total)
		local ratio = current / total
		self._custom_radial_icon:set_color(Color(1, ratio, 1, 1))
		self._custom_radial_icon:set_visible(ratio > 0)
	end

	function PlayerInfoComponent.PlayerStatus:set_ability_progress(current, total)
		local ratio = current / total
		self._ability_radial_icon:set_color(Color(1, ratio, 1, 1))
		self._ability_radial_icon:set_visible(ratio > 0)
	end

	function PlayerInfoComponent.PlayerStatus:set_ability_active(time_left, time_total)
		self._ability_radial_icon:stop()
		self._ability_radial_icon:animate(callback(self, self, "_animate_ability"), time_left, time_total)
	end

	function PlayerInfoComponent.PlayerStatus:set_absorb(amount)
		local r = amount / (self._max_absorb or 1)
		self._maniac_absorb_radial:set_visible(r > 0)
		self._maniac_absorb_radial:set_color(Color(r, 1, 1))
	end

	function PlayerInfoComponent.PlayerStatus:set_stacks(data)
		--local r = math.clamp(data.current / data.max, 0, 1)
		--self._maniac_stack_radial:set_visible(r > 0)
		--self._maniac_stack_radial:set_color(Color(r, 1, 1))
	end

	function PlayerInfoComponent.PlayerStatus:set_delayed_damage(data)
		local damage = data.damage or 0
		local armor_max = data.total_armor or 1
		local armor_current = data.armor or 0
		local armor_ratio = (data.armor / data.total_armor)
		local health_max = data.total_health or 1
		local health_current = data.health or 0
		local health_ratio = (data.health / data.total_health)
		local armor_damage = damage < armor_current and damage or armor_current
		damage = damage - armor_damage
		local health_damage = damage < health_current and damage or health_current
		local armor_damage_ratio = armor_damage > 0 and armor_damage / armor_max or 0
		local health_damage_ratio = health_damage / health_max

		self._radial_delayed_damage_armor:set_visible(armor_damage_ratio > 0)
		self._radial_delayed_damage_health:set_visible(health_damage_ratio > 0)
		self._radial_delayed_damage_armor:set_color(Color(1, armor_damage_ratio, 1 - armor_ratio, 0))
		self._radial_delayed_damage_health:set_color(Color(1, health_damage_ratio, 1 - health_ratio, 0))

	end

	function PlayerInfoComponent.PlayerStatus:_animate_damage_taken(indicator)
		local st = 3
		local t = st
		local st_red_t = 0.5
		local red_t = st_red_t

		indicator:set_alpha(1)
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			red_t = math.clamp(red_t - dt, 0, 1)
			indicator:set_color(Color(1, red_t / st_red_t, red_t / st_red_t))
			indicator:set_alpha(t / st)
		end
		indicator:set_alpha(0)
	end

	function PlayerInfoComponent.PlayerStatus:_animate_set_health(health_radial, stored_health_radial, new_ratio)
		local old_ratio = health_radial:color().red
		local tt = new_ratio > old_ratio and 0.2 or 0.05
		local t = 0

		while t < tt do
			t = t + coroutine.yield()
			local current_ratio = math.lerp(old_ratio, new_ratio, math.clamp(t/tt, 0, 1))
			self:set_stored_health_max(1-current_ratio)
			health_radial:set_color(Color(current_ratio, 1, 1))
			stored_health_radial:set_rotation(-current_ratio * 360)
		end
		self:set_stored_health_max(1-new_ratio)
		health_radial:set_color(Color(new_ratio, 1, 1))
		stored_health_radial:set_rotation(-new_ratio * 360)
	end

	function PlayerInfoComponent.PlayerStatus:_animate_low_stamina(stamina_radial)
		local t = 0
		while self._animating_low_stamina do
			t = t + coroutine.yield()
			stamina_radial:set_alpha(math.sin(360 * t * 2) * 0.3 + 0.6)
		end
		stamina_radial:set_alpha(1)
	end

	function PlayerInfoComponent.PlayerStatus:_animate_low_life(text, min_size, max_size)
		local t = 0

		while alive(text) do
			local r = math.sin(t * 360) * 0.5 + 0.5
			text:set_font_size(math.lerp(min_size, max_size, r))
			t = t + coroutine.yield()
		end
	end

	function PlayerInfoComponent.PlayerStatus:_animate_ability(radial, time_left, duration)
		local t = duration - time_left
		radial:show()

		while t < duration do
			self._ability_radial_icon:set_color(Color(1, t / duration, 1, 1))
			t = t + coroutine.yield()
		end

		radial:hide()
	end

	function PlayerInfoComponent.PlayerStatus:_animate_timer(timer, initial)
		local T = initial
		local LOW = 10
		local t = initial

		timer:set_font_size(self._panel:h() * 0.5)

		while t >= 0 do
			local dt = coroutine.yield()
			if self._reviver_count <= 0 then
				t = t - dt

				local r = 1 - t / T
				--local red = 0.2 + 0.6 * math.min(2*r, 1)
				--local green = 0.8 - 0.6 * math.max(2*(r-0.5), 0)
				--local blue = 0.2
				local red = 0.0 + 0.6 * math.min(2*r, 1)
				local green = 0.6 - 0.6 * math.max(2*(r-0.5), 0)
				local blue = 0.0
				timer:set_color(Color(red, green, blue))
				timer:set_text(string.format("%02.0f", t))

				if t <= LOW then
					local r = -(t - LOW)
					local rate = 180 + 180 * (r/LOW)
					local n = (1 + math.sin(r * rate)) / 2
					timer:set_font_size(math.lerp(self._panel:h() * 0.5, self._panel:h() * 0.7, n))
				end
			end
		end

		timer:set_text("0")
	end

	PlayerInfoComponent.WaitingStatus = PlayerInfoComponent.WaitingStatus or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.WaitingStatus:init(panel, owner, width, height, settings)
		PlayerInfoComponent.WaitingStatus.super.init(self, panel, owner, "waiting_status", width, height)

		self._settings = settings

		self._size = height

		local detection_texture = "guis/textures/pd2/mission_briefing/inv_detection_meter"

		local detection_left_bg = self._panel:bitmap({
			name = "detection_left_bg",
			texture = detection_texture,
			alpha = 0.2,
			blend_mode = "add",
			w = self._size,
			h = self._size,
		})
		local detection_right_bg = self._panel:bitmap({
			name = "detection_right_bg",
			texture = detection_texture,
			alpha = 0.2,
			blend_mode = "add",
			w = self._size,
			h = self._size,
		})
		detection_right_bg:set_texture_rect(detection_right_bg:texture_width(), 0, -detection_right_bg:texture_width(), detection_right_bg:texture_height())
		local detection_left = self._panel:bitmap({
			name = "detection_left",
			texture = detection_texture,
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 1,
			w = self._size,
			h = self._size,
		})
		local detection_right = self._panel:bitmap({
			name = "detection_right",
			texture = detection_texture,
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 1,
			w = self._size,
			h = self._size,
		})
		detection_right:set_texture_rect(detection_right:texture_width(), 0, -detection_right:texture_width(), detection_right:texture_height())
		self._detection_value = self._panel:text({
			name = "detection_value",
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			align = "center",
			vertical = "center"
		})
		self._detection_value:set_center(self._panel:w() / 2, self._panel:h() / 2 + 2)

		self._detection_ring = { detection_left, detection_right }
		self._components = { detection_left_bg, detection_right_bg, detection_left, detection_right }

		self:set_enabled("waiting", false)

		self._owner:register_listener("WaitingStatus", { "detection" }, callback(self, self, "set_detection"), false)
	end

	function PlayerInfoComponent.WaitingStatus:destroy()
		self._owner:unregister_listener("WaitingStatus", { "detection" })
		PlayerInfoComponent.WaitingStatus.super.destroy(self)
	end

	function PlayerInfoComponent.WaitingStatus:set_is_local_player(state)
		if PlayerInfoComponent.WaitingStatus.super.set_is_local_player(self, state) and self:set_enabled("player", not self._is_local_player) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingStatus:set_is_ai(state)
		if PlayerInfoComponent.WaitingStatus.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingStatus:set_is_waiting(state)
		if PlayerInfoComponent.WaitingStatus.super.set_is_waiting(self, state) and self:set_enabled("waiting", self._is_waiting) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.WaitingStatus:rescale(factor)
		if PlayerInfoComponent.WaitingStatus.super.rescale(self, factor) then
			self._size = self._size * factor
			for _, comp in ipairs(self._components) do
				comp:set_w(self._size)
				comp:set_h(self._size)
			end

			local max_w = self._size * 0.7
			self._detection_value:set_center(self._panel:w() / 2, self._panel:h() / 2 + 2)
			local _, _, w, h = self._detection_value:text_rect()
			self._detection_value:set_font_size(math.min(self._detection_value:font_size() * (max_w / w), tweak_data.menu.pd2_medium_font_size))

			self:arrange()
		end
	end

	function PlayerInfoComponent.WaitingStatus:arrange()
		local w = self._panel:w()
		local h = self._panel:h()

		self._detection_value:set_center(w / 2, h / 2 + 2)

		self:set_size(w, h)
		self._owner:arrange()
	end

	function PlayerInfoComponent.WaitingStatus:set_detection(value)
		for _, image in ipairs(self._detection_ring) do
			image:set_color(Color(0.5 + (value / 100) * 0.5, 1, 1))
		end
		self._detection_value:set_text(value)
	end

	PlayerInfoComponent.Carry = PlayerInfoComponent.Carry or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Carry:init(panel, owner, player_height, team_height, settings)
		PlayerInfoComponent.Carry.super.init(self, panel, owner, "carry", 0, 0)

		self._player_height = player_height
		self._team_height = team_height
		self._settings = settings

		self._icon = self._panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = { 32, 33, 32, 31 },
			color = Color.white,
		})

		self._text = self._panel:text({
			name = "text",
			layer = 1,
			color = Color.white,
			vertical = "center",
			align = "center",
			font = tweak_data.hud.medium_font_noshadow,
		})

		local component_size = self._owner._is_player and self._player_height or self._team_height / 2
		self._icon:set_size(component_size, component_size)
		self._text:set_h(component_size)
		self._text:set_font_size(component_size * 0.8)
		self:set_enabled("active", false)
		self:arrange()

		self._owner:register_listener("Carry", { "set_carry" }, callback(self, self, "set"), false)
		self._owner:register_listener("Carry", { "clear_carry" }, callback(self, self, "clear"), false)
	end

	function PlayerInfoComponent.Carry:destroy()
		self._owner:unregister_listener("Carry", { "set_carry", "clear_carry" })
		PlayerInfoComponent.Carry.super.destroy(self)
	end

	function PlayerInfoComponent.Carry:update_settings()
		if self:set_enabled("setting", self._settings.CARRY) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Carry:rescale(factor)
		if PlayerInfoComponent.Carry.super.rescale(self, factor) then
			self._player_height = self._player_height * factor
			self._team_height = self._team_height * factor

			local component_size = self._owner._is_player and self._player_height or self._team_height / 2
			self._icon:set_size(component_size, component_size)
			self._text:set_h(component_size)
			self._text:set_font_size(component_size * 0.8)
			self:arrange()
		end
	end
--[[
	function PlayerInfoComponent.Carry:set_is_local_player(state)
		if PlayerInfoComponent.Carry.super.set_is_local_player(self, state) then
			local component_size = self._is_local_player and self._player_height or self._team_height / 2
			self._icon:set_size(component_size, component_size)
			self._text:set_h(component_size)
			self._text:set_font_size(component_size * 0.8)
			self:arrange()
		end
	end
]]
	function PlayerInfoComponent.Carry:set_is_ai(state)
		if PlayerInfoComponent.Carry.super.set_is_ai(self, state) then
			if self:set_enabled("ai", not self._is_ai) then
				self._owner:arrange()
			end
		end
	end

	function PlayerInfoComponent.Carry:arrange()
		local w = self._panel:w()
		local h = self._owner._is_player and self._player_height or self._team_height

		if self._owner._is_player then
			self._icon:set_left(0)
			self._text:set_left(self._icon:w() * 1.25)

			w = self._text:right()
		else
			w = self._text:w()

			self._icon:set_top(0)
			self._icon:set_center_x(w / 2)
			self._text:set_bottom(h)
			self._text:set_x(0)
		end

		if self:set_size(w, h) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Carry:set(id, value)
		self:_update_carry(id)
	end

	function PlayerInfoComponent.Carry:clear()
		self:_update_carry(nil)
	end

	function PlayerInfoComponent.Carry:_update_carry(id)
		if self._current_carry ~= id then
			self._current_carry = id

			if id then
				local name_id = tweak_data.carry[id] and tweak_data.carry[id].name_id
				local carry_text = utf8.to_upper(name_id and managers.localization:text(name_id) or "UNKNOWN")

				self._text:set_text(carry_text)
				local _, _, w, _ = self._text:text_rect()
				self._text:set_w(w)
			else
				self._text:set_text("")
				self._text:set_w(0)
			end

			if self:set_enabled("active", id) then
				self:arrange()
			end
		end
	end

	PlayerInfoComponent.CenterPanel = PlayerInfoComponent.CenterPanel or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.CenterPanel:init(panel, owner, height, settings)
		PlayerInfoComponent.CenterPanel.super.init(self, panel, owner, "center_panel", 0, height)

		self._settings = settings

		self._weapons = PlayerInfoComponent.Weapons:new(self._panel, self, height, settings)
		self._equipment = PlayerInfoComponent.Equipment:new(self._panel, self, height, settings)
		self._special_equipment = PlayerInfoComponent.SpecialEquipment:new(self._panel, self, height, settings)
		self._interaction = PlayerInfoComponent.Interaction:new(self._panel, self, height, settings)

		self._components = {
			self._weapons,
			self._equipment,
			self._special_equipment,
			self._interaction,
		}

		self._non_interaction_components = {
			self._weapons,
			self._equipment,
			self._special_equipment,
		}

		self._owner:register_listener("CenterPanel", { "interaction_start" }, callback(self, self, "_interaction_start"), false)
		self._owner:register_listener("CenterPanel", { "interaction_stop" }, callback(self, self, "_interaction_stop"), false)
	end

	function PlayerInfoComponent.CenterPanel:destroy()
		for _, component in pairs(self._components) do
			component:destroy()
		end
		PlayerInfoComponent.CenterPanel.super.destroy(self)
	end

	function PlayerInfoComponent.CenterPanel:update_settings()
		for _, component in pairs(self._components) do
			component:update_settings()
		end
	end

	function PlayerInfoComponent.CenterPanel:set_alignment(align)
		if PlayerInfoComponent.CenterPanel.super.set_alignment(self, align) then
			for _, component in ipairs(self._non_interaction_components) do
				component:set_right(self._panel:w() - component:left())
				component:set_alignment(align)
			end
			ReverseTable(self._non_interaction_components)
		end
	end

	function PlayerInfoComponent.CenterPanel:rescale(factor)
		if PlayerInfoComponent.Weapon.super.rescale(self, factor) then
			for _, component in pairs(self._components) do
				component:rescale(factor)
			end
		end
	end

	function PlayerInfoComponent.CenterPanel:set_is_local_player(state)
		if PlayerInfoComponent.CenterPanel.super.set_is_local_player(self, state) then
			for _, component in pairs(self._components) do
				component:set_is_local_player(state)
			end
		end
	end

	function PlayerInfoComponent.CenterPanel:set_is_ai(state)
		if PlayerInfoComponent.CenterPanel.super.set_is_ai(self, state) then
			for _, component in pairs(self._components) do
				component:set_is_ai(state)
			end
		end
	end

	function PlayerInfoComponent.CenterPanel:set_is_waiting(state)
		if PlayerInfoComponent.CenterPanel.super.set_is_waiting(self, state) then
			for _, component in pairs(self._components) do
				component:set_is_waiting(state)
			end
		end
	end

	function PlayerInfoComponent.CenterPanel:arrange()
		local MARGIN = 2
		local h = self._panel:h()
		local w = MARGIN

		for _, component in ipairs(self._non_interaction_components) do
			if component:visible() then
				component:set_x(w)
				w = w + component:w() + MARGIN
			end
		end

		self._interaction:set_min_w(w)

		if self._interaction:visible() then
			self._interaction:set_x(0)
			w = math.max(w, self._interaction:w())
		end

		local enable_changed = self:set_enabled("panel_size", w > MARGIN)
		local size_change = self:set_size(w, h)

		if enable_changed or size_change then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.CenterPanel:register_listener(...)
		self._owner:register_listener(...)
	end

	function PlayerInfoComponent.CenterPanel:unregister_listener(...)
		self._owner:unregister_listener(...)
	end

	function PlayerInfoComponent.CenterPanel:_interaction_start(id, timer)
		if not self._settings.INTERACTION.HIDE and (self._settings.INTERACTION.MIN_DURATION or 0) <= timer then
			self._panel:stop()
			self._panel:animate(callback(self, self, "_fade_in_interaction"))
		end
	end

	function PlayerInfoComponent.CenterPanel:_interaction_stop(success)
		self._panel:stop()
		self._panel:animate(callback(self, self, "_fade_out_interaction"))
	end

	function PlayerInfoComponent.CenterPanel:_fade_in_interaction(panel)
		coroutine.yield()

		self:arrange()

		if self._interaction:visible() then
			local rate = 2
			local alpha = self._interaction:alpha()
			local goal = 1

			while self._interaction:alpha() < goal do
				alpha = alpha + coroutine.yield() * rate

				self._interaction:set_alpha(alpha)
				for _, component in pairs(self._non_interaction_components) do
					component:set_alpha(1-alpha)
				end
			end
		end
	end

	function PlayerInfoComponent.CenterPanel:_fade_out_interaction(panel)
		wait(0.35)

		if self._interaction:visible() then
			local rate = 2
			local alpha = self._interaction:alpha()
			local goal = 0

			while self._interaction:alpha() > goal do
				alpha = alpha - coroutine.yield() * rate

				self._interaction:set_alpha(alpha)
				for _, component in pairs(self._non_interaction_components) do
					component:set_alpha(1-alpha)
				end
			end

			self._interaction:set_enabled("active", false)
			self:arrange()
		end
	end

	PlayerInfoComponent.Weapons = PlayerInfoComponent.Weapons or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Weapons:init(panel, owner, height, settings)
		PlayerInfoComponent.Weapons.super.init(self, panel, owner, "weapons", 0, height)

		self._weapons = {}
		self._aggregate_ammo = {}
		self._settings = settings
		self._weapon_count = HUDTeammateCustom.SETTINGS.MAX_WEAPONS
		self._event_callbacks = {
			weapon_fire_mode = "set_fire_mode",
			weapon = "set_weapon",
			available_fire_modes = "set_available_fire_modes",
		}

		self._panel:rect({
			name = "bg",
			color = Color.black,
			alpha = 0.25,
			halign = "grow",
			valign = "grow",
		})

		self._aggregate_ammo_panel = self._panel:panel({
			name = "aggregate_ammo_panel",
			h = height,
		})

		for i = 1, self._weapon_count, 1 do
			local weapon = PlayerInfoComponent.Weapon:new(self._panel, self, i, height, self._settings)
			table.insert(self._weapons, weapon)

			local text_h = self._aggregate_ammo_panel:h() * (1/self._weapon_count)
			self._aggregate_ammo[i] = self._aggregate_ammo_panel:text({
				name = "aggregate_ammo_" .. tostring(i),
				text = "000",
				color = Color.white,
				halign = "grow",
				valign = "scale",
				vertical = "center",
				align = "right",
				y = text_h * (self._weapon_count - i),
				h = text_h,
				font_size = text_h * 0.95,
				font = tweak_data.hud_players.ammo_font
			})

			local _, _, w, _ = self._aggregate_ammo[i]:text_rect()
			self._aggregate_ammo_panel:set_w(math.max(w, self._aggregate_ammo_panel:w()))
		end

		--self:_weapon_selected(1)

		self._owner:register_listener("Weapons", { "weapon_selected" }, callback(self, self, "_weapon_selected"), false)
		self._owner:register_listener("Weapons", { "ammo_amount" }, callback(self, self, "_ammo_amount"), false)
		self._owner:register_listener("Weapons", { "weapon_fire_mode" }, callback(self, self, "_weapon_event_handler"), true)
		self._owner:register_listener("Weapons", { "weapon" }, callback(self, self, "_weapon_event_handler"), true)
		self._owner:register_listener("Weapons", { "available_fire_modes" }, callback(self, self, "_weapon_event_handler"), true)
	end

	function PlayerInfoComponent.Weapons:destroy()
		for _, weapon in pairs(self._weapons) do
			weapon:destroy()
		end

		self._owner:unregister_listener("Weapons", { "weapon_selected", "ammo_amount", "weapon_fire_mode", "weapon", "available_fire_modes" })

		PlayerInfoComponent.Weapons.super.destroy(self)
	end

	function PlayerInfoComponent.Weapons:update_settings()
		for _, weapon in pairs(self._weapons) do
			weapon:update_settings()
		end

		self._aggregate_ammo_panel:set_visible(self._settings.WEAPON.AMMO.TOTAL_AMMO_ONLY and true or false)
		self:arrange()
	end

	function PlayerInfoComponent.Weapons:set_alignment(align)
		if PlayerInfoComponent.Weapons.super.set_alignment(self, align) then
			--for _, component in ipairs(self._weapons) do
			--	component:set_right(self._panel:w() - component:left())
			--	component:set_alignment(align)
			--end
			--self._aggregate_ammo_panel:set_right(self._panel:w() - self._aggregate_ammo_panel:left())
			--ReverseTable(self._weapons)
		end
	end

	function PlayerInfoComponent.Weapons:rescale(factor)
		if PlayerInfoComponent.Weapons.super.rescale(self, factor) then
			for _, weapon in pairs(self._weapons) do
				weapon:rescale(factor)
			end
			self._aggregate_ammo_panel:set_w(self._aggregate_ammo_panel:w() * factor)
			self._aggregate_ammo_panel:set_h(self._aggregate_ammo_panel:h() * factor)
			for i, panel in ipairs(self._aggregate_ammo) do
				panel:set_font_size(panel:font_size() * factor)
			end
			self:arrange()
		end
	end

	function PlayerInfoComponent.Weapons:set_is_ai(state)
		if PlayerInfoComponent.CenterPanel.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Weapons:arrange()
		local h = self._panel:h()
		local w = 0

		for i = self._weapon_count, 1, -1 do
			local weapon = self._weapons[i]
			if weapon:visible() then
				weapon:set_x(w)
				w = w + weapon:w()
			end
		end

		if self._aggregate_ammo_panel:visible() then
			if w > 0 then
				w = w + h * 0.2	--Margin
			end
			self._aggregate_ammo_panel:set_x(w)
			w = w + self._aggregate_ammo_panel:w()
		end

		if self:set_size(w, h) then
			self:set_enabled("panel_size", w > 0)
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Weapons:_weapon_selected(slot)
		for i = 1, self._weapon_count, 1 do
			local selected = i == slot
			self._aggregate_ammo[i]:set_alpha(selected and 1 or 0.5)
			self._weapons[i]:set_selected(selected)
		end
	end

	function PlayerInfoComponent.Weapons:_ammo_amount(slot, mag_current, mag_max, total_current, total_max)
		PlayerInfoComponent.Weapons._update_ammo_text(self._aggregate_ammo[slot], total_current, total_max)
		self._weapons[slot]:set_ammo_amount(mag_current, mag_max, total_current, total_max)
	end

	function PlayerInfoComponent.Weapons:_weapon_event_handler(event, slot, ...)
		local weapon = self._weapons[slot]
		local clbk = self._event_callbacks[event]

		weapon[clbk](weapon, ...)
	end

	function PlayerInfoComponent.Weapons._update_ammo_text(component, current, max)	--Static
		local ratio = current / max

		local green = 0.7 * math.clamp((ratio - 0.25) / 0.25, 0, 1) + 0.3
		local blue = 0.7 * math.clamp(ratio/0.25, 0, 1) + 0.3
		local color = ratio >= 1 and Color('C2FC97') or Color(1, 1, blue, green)
		component:set_text(string.format("%03.0f", current))
		component:set_color(color)

		local range = current < 10 and 2 or current < 100 and 1 or 0
		if range > 0 then
			component:set_range_color(0, range, color:with_alpha(0.5))
		end

		return ratio, component
	end

	PlayerInfoComponent.Weapon = PlayerInfoComponent.Weapon or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Weapon:init(panel, owner, slot, height, settings)
		PlayerInfoComponent.Weapon.super.init(self, panel, owner, "weapon_" .. tostring(slot), 0, height)

		self._settings = settings
		self._is_selected = false
		self._slot = slot
		self._fire_modes = {}
		self._fire_mode_count = 0

		self._icon_panel = self._panel:panel({
			name = "icon_panel",
			w = height * 2,
			h = height,
		})

		self._bg_panel = HUDBGBox_create(self._panel, {
			w = w,
			h = h,
		}, {})

		local weapon_icon = self._icon_panel:bitmap({
			name = "icon",
			halign = "grow",
			valign = "grow",
		})

		local silencer_icon = self._icon_panel:bitmap({
			name = "silencer_icon",
			texture = "guis/textures/pd2/blackmarket/inv_mod_silencer",
			visible = false,
			halign = "scale",
			valign = "scale",
			align = "right",
			vertical = "bottom",
			w = weapon_icon:h() * 0.25,
			h = weapon_icon:h() * 0.25,
			layer = weapon_icon:layer() + 1,
		})
		silencer_icon:set_bottom(weapon_icon:bottom())
		silencer_icon:set_right(weapon_icon:right())

		self._name = self._icon_panel:text({
			name = "label",
			text = "N/A",
			color = Color.white,
			halign = "grow",
			valign = "scale",
			align = "center",
			vertical = "top",
			h = weapon_icon:h(),
			font_size = weapon_icon:h() * 0.2,
			font = tweak_data.hud_players.name_font,
			layer = weapon_icon:layer() + 1,
			wrap = true,
			word_wrap = true,
		})

		self._ammo_panel = self._panel:panel({
			name = "ammo_panel",
			h = height,
		})

		local ammo_mag = self._ammo_panel:text({
			name = "mag",
			text = "000",
			color = Color.white,
			halign = "grow",
			valign = "scale",
			vertical = "center",
			align = "right",
			h = self._ammo_panel:h() * 0.55,
			font_size = self._ammo_panel:h() * 0.55,
			font = tweak_data.hud_players.ammo_font
		})

		local ammo_total = self._ammo_panel:text({
			name = "total",
			text = "000",
			color = Color.white,
			halign = "grow",
			valign = "scale",
			vertical = "center",
			align = "right",
			h = self._ammo_panel:h() * 0.45,
			font_size = self._ammo_panel:h() * 0.45,
			font = tweak_data.hud_players.ammo_font
		})
		ammo_total:set_center_y((self._ammo_panel:h() + ammo_mag:h()) / 2)

		local _, _, w, _ = ammo_mag:text_rect()
		self._ammo_panel:set_w(w)

		self._fire_mode_panel = self._panel:panel({
			name = "fire_mode_panel",
			w = height * 0.25,
			h = height,
			visible = false,
		})

		local fire_mode_bg = self._fire_mode_panel:rect({
			name = "bg",
			halign = "grow",
			color = Color.white,
		})

		local active_mode = self._fire_mode_panel:text({
			name = "active_mode",
			text = "O",
			color = Color.black,
			vertical = "center",
			align = "center",
			w = self._fire_mode_panel:h(),
			h = self._fire_mode_panel:w(),
			font_size = self._fire_mode_panel:w() * 0.9,
			font = "fonts/font_small_noshadow_mf",
			layer = fire_mode_bg:layer() + 1,
			rotation = -90,
		})
		active_mode:set_center(self._fire_mode_panel:center())
	end

	function PlayerInfoComponent.Weapon:update_settings()
		local data = self._settings.WEAPON

		local selected = {
			[self._icon_panel] = true,
			[self._ammo_panel] = not data.AMMO.TOTAL_AMMO_ONLY,
			[self._fire_mode_panel] = self._fire_mode_count > 1,
			[self._name] = true,
		}
		local unselected = {
			[self._icon_panel] = true,
			[self._ammo_panel] = not data.AMMO.TOTAL_AMMO_ONLY,
			[self._fire_mode_panel] = self._fire_mode_count > 1,
			[self._name] = true,
		}

		if data.ICON.HIDE then
			selected[self._icon_panel] = selected[self._icon_panel] and false
			unselected[self._icon_panel] = unselected[self._icon_panel] and false
		elseif data.ICON.SELECTED_ONLY then
			selected[self._icon_panel] = selected[self._icon_panel] and true
			unselected[self._icon_panel] = unselected[self._icon_panel] and false
		elseif data.ICON.UNSELECTED_ONLY then
			selected[self._icon_panel] = selected[self._icon_panel] and false
			unselected[self._icon_panel] = unselected[self._icon_panel] and true
		end

		if data.NAME then
			if data.NAME.HIDE then
				selected[self._name] = selected[self._name] and false
				unselected[self._name] = unselected[self._name] and false
			elseif data.NAME.SELECTED_ONLY then
				selected[self._name] = selected[self._name] and true
				unselected[self._name] = unselected[self._name] and false
			elseif data.NAME.UNSELECTED_ONLY then
				selected[self._name] = selected[self._name] and false
				unselected[self._name] = unselected[self._name] and true
			end
		end

		if data.FIREMODE then
			if data.FIREMODE.HIDE then
				selected[self._fire_mode_panel] = selected[self._fire_mode_panel] and false
				unselected[self._fire_mode_panel] = unselected[self._fire_mode_panel] and false
			elseif data.FIREMODE.SELECTED_ONLY then
				selected[self._fire_mode_panel] = selected[self._fire_mode_panel] and true
				unselected[self._fire_mode_panel] = unselected[self._fire_mode_panel] and false
			elseif data.FIREMODE.UNSELECTED_ONLY then
				selected[self._fire_mode_panel] = selected[self._fire_mode_panel] and false
				unselected[self._fire_mode_panel] = unselected[self._fire_mode_panel] and true
			end
		end

		if data.AMMO.HIDE then
			selected[self._ammo_panel] = selected[self._ammo_panel] and false
			unselected[self._ammo_panel] = unselected[self._ammo_panel] and false
		elseif data.AMMO.SELECTED_ONLY then
			selected[self._ammo_panel] = selected[self._ammo_panel] and true
			unselected[self._ammo_panel] = unselected[self._ammo_panel] and false
		elseif data.AMMO.UNSELECTED_ONLY then
			selected[self._ammo_panel] = selected[self._ammo_panel] and false
			unselected[self._ammo_panel] = unselected[self._ammo_panel] and true
		end

		self._component_visibility = { selected = selected, unselected = unselected }

		self:set_selected(self._is_selected)
	end

	function PlayerInfoComponent.Weapon:rescale(factor)
		if PlayerInfoComponent.Weapon.super.rescale(self, factor) then
			self._icon_panel:set_w(self._icon_panel:w() * factor)
			self._icon_panel:set_h(self._icon_panel:h() * factor)
			local name_label = self._icon_panel:child("label")
			name_label:set_font_size(name_label:font_size() * factor)
			self._ammo_panel:set_w(self._ammo_panel:w() * factor)
			self._ammo_panel:set_h(self._ammo_panel:h() * factor)
			local total_ammo = self._ammo_panel:child("total")
			local mag_ammo = self._ammo_panel:child("mag")
			total_ammo:set_font_size(total_ammo:font_size() * factor)
			mag_ammo:set_font_size(mag_ammo:font_size() * factor)
			self._fire_mode_panel:set_w(self._fire_mode_panel:w() * factor)
			self._fire_mode_panel:set_h(self._fire_mode_panel:h() * factor)
			local active_fire_mode = self._fire_mode_panel:child("active_mode")
			active_fire_mode:set_font_size(active_fire_mode:font_size() * factor)
			self:arrange()
		end
	end

	function PlayerInfoComponent.Weapon:arrange()
		local MARGIN = self._panel:h() * 0.05
		local w = MARGIN
		local h = self._panel:h()
		local visible = false

		local component_order = { self._icon_panel, self._fire_mode_panel, self._ammo_panel }
		--if self._statistics_panel then
		--	table.insert(component_order, self._statistics_panel)
		--end

		for _, component in ipairs(component_order) do
			if component:visible() then
				component:set_x(w)
				w = w + component:w() + MARGIN
				visible = true
			end
		end

		if self._bg_panel then
			self._bg_panel:set_w(w)
			self._bg_panel:set_h(h)
		end

		local changed_enabled = self:set_enabled("panel_size", visible)
		local changed_size = self:set_size(w, h)

		if changed_enabled or changed_size then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Weapon:set_selected(state)
		self._is_selected = state

		if not self._component_visibility then return end

		for component, visible in pairs(self._component_visibility[state and "selected" or "unselected"]) do
			component:set_visible(visible)
		end

		self:set_alpha(state and 1 or 0.5)
		self:arrange()
	end

	function PlayerInfoComponent.Weapon:set_ammo_amount(mag_current, mag_max, total_current, total_max)
		PlayerInfoComponent.Weapons._update_ammo_text(self._ammo_panel:child("mag"), mag_current, mag_max)
		PlayerInfoComponent.Weapons._update_ammo_text(self._ammo_panel:child("total"), total_current, total_max)
	end

	function PlayerInfoComponent.Weapon:set_fire_mode(active_mode)
		if self._fire_modes[active_mode] then
			local bg = self._fire_mode_panel:child("bg")
			local text = self._fire_mode_panel:child("active_mode")
			text:set_text(utf8.to_upper(active_mode))
			local _, _, w, _ = text:text_rect()
			bg:set_h(w * 1.3)
			bg:set_center_y(self._fire_mode_panel:h() / 2)

			--self._fire_mode_panel:child("active_mode"):set_text(self._fire_modes[active_mode])
		end
	end

	function PlayerInfoComponent.Weapon:set_weapon(id, silencer)
		local weapon_skin = tweak_data.blackmarket.weapon_skins[id] or false
		local bitmap_texture, text = PlayerInfoComponent.Base.get_item_icon_data(weapon_skin and "weapon_skin" or "weapon", id)

		self._icon_panel:child("icon"):set_image(bitmap_texture)
		self._icon_panel:child("silencer_icon"):set_visible(silencer)
		self._icon_panel:child("label"):set_text(text)
	end

	function PlayerInfoComponent.Weapon:set_available_fire_modes(modes, reset)
		if reset then
			self._fire_mode_count = 0
			self._fire_modes = {}
		end

		for _, mode in ipairs(modes) do
			local name = mode[1]
			local text = mode[2]
			if not self._fire_modes[name] then
				self._fire_modes[name] = text
				self._fire_mode_count = self._fire_mode_count + 1
			end
		end

		self:update_settings()
	end

	PlayerInfoComponent.Equipment = PlayerInfoComponent.Equipment or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Equipment:init(panel, owner, height, settings)
		PlayerInfoComponent.Equipment.super.init(self, panel, owner, "equipment", 0, height)

		self._settings = settings
		self._equipment_types = { "deployables", "cable_ties", "throwables" }
		self._throwable_data = { amount = 0, cooldown = 0 }

		local bg = self._panel:rect({
			name = "bg",
			color = Color.black,
			alpha = 0.25,
			halign = "grow",
			valign = "grow",
			layer = -1,
		})

		local size = height / #self._equipment_types

		for i, name in ipairs(self._equipment_types) do
			local panel = self._panel:panel({
				name = name,
				h = size,
				visible = false,
			})

			local icon = panel:bitmap({
				name = "icon",
				color = Color.white,
				w = panel:h(),
				h = panel:h(),
			})

			local amount = panel:text({
				name = "amount",
				text = "00",
				font = "fonts/font_medium_mf",
				font_size = panel:h(),
				color = Color.white,
				align = "right",
				vertical = "center",
				h = panel:h()
			})
		end

		self:set_enabled("active", false)

		self._owner:register_listener("Equipment", { "throwable" }, callback(self, self, "set_throwable"), false)
		self._owner:register_listener("Equipment", { "throwable_amount" }, callback(self, self, "set_throwable_amount"), false)
		self._owner:register_listener("Equipment", { "cable_tie" }, callback(self, self, "set_cable_tie"), false)
		self._owner:register_listener("Equipment", { "cable_tie_amount" }, callback(self, self, "set_cable_tie_amount"), false)
		self._owner:register_listener("Equipment", { "deployable" }, callback(self, self, "set_deployable"), false)
		self._owner:register_listener("Equipment", { "deployable_amount" }, callback(self, self, "set_deployable_amount"), false)
		self._owner:register_listener("Equipment", { "deployable_amount_from_string" }, callback(self, self, "set_deployable_amount_from_string"), false)
		self._owner:register_listener("Equipment", { "throwable_cooldown" }, callback(self, self, "set_throwable_cooldown"), false)
		self._owner:register_listener("Equipment", { "throwable_cooldown_stop" }, callback(self, self, "stop_throwable_cooldown"), false)
	end

	function PlayerInfoComponent.Equipment:destroy()
		self._owner:unregister_listener("Equipment", { "deployable_amount_from_string", "deployable_amount", "deployable", "cable_tie_amount", "cable_tie", "throwable_amount", "throwable", "throwable_cooldown", "throwable_cooldown_stop" })
		PlayerInfoComponent.Equipment.super.destroy(self)
	end

	function PlayerInfoComponent.Equipment:update_settings()
		if self:set_enabled("setting", self._settings.EQUIPMENT) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Equipment:rescale(factor)
		if PlayerInfoComponent.Equipment.super.rescale(self, factor) then
			for i, name in ipairs(self._equipment_types) do
				local panel = self._panel:child(name)
				local icon = panel:child("icon")
				local amount = panel:child("amount")
				panel:set_h(panel:h() * factor)
				icon:set_size(icon:w() * factor, icon:h() * factor)
				amount:set_size(amount:w() * factor, amount:h() * factor)
				amount:set_font_size(amount:font_size() * factor)
			end
			self:arrange()
		end
	end

	function PlayerInfoComponent.Equipment:set_is_local_player(state)
		if PlayerInfoComponent.Equipment.super.set_is_local_player(self, state) then

		end
	end

	function PlayerInfoComponent.Equipment:set_is_ai(state)
		if PlayerInfoComponent.Equipment.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Equipment:arrange()
		local MARGIN = self._panel:h() * 0.04
		local i = 0
		local w = 0
		local h = self._panel:h()

		for _, name in ipairs(self._equipment_types) do
			local panel = self._panel:child(name)
			local panel_w = 0

			if panel and panel:visible() then
				local icon = panel:child("icon")
				local amount = panel:child("amount")
				local _, _, text_w, _ = amount:text_rect()

				amount:set_w(text_w)
				panel_w = panel_w + icon:w() + MARGIN + amount:w() + MARGIN
				w = math.max(w, panel_w)
			end
		end

		for _, name in ipairs(self._equipment_types) do
			local panel = self._panel:child(name)

			if panel and panel:visible() then
				local icon = panel:child("icon")
				local amount = panel:child("amount")

				panel:set_w(w)
				amount:set_right(w)
				panel:set_y(i * panel:h())
				i = i + 1
			end
		end

		local change_enable = self:set_enabled("active", i > 0)
		local change_size = self:set_size(w, h)
		if change_enable or change_size then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Equipment:set_cable_tie(icon)
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {0, 0, 32, 32})
		self._panel:child("cable_ties"):child("icon"):set_image(texture, unpack(texture_rect))
	end

	function PlayerInfoComponent.Equipment:set_cable_tie_amount(amount)
		local panel = self._panel:child("cable_ties")
		local text = panel:child("amount")
		text:set_text(string.format("%02.0f", amount))
		text:set_range_color(0, amount < 10 and 1 or 0, Color.white:with_alpha(0.5))
		panel:set_visible(amount > 0)
		self:arrange()
	end

	function PlayerInfoComponent.Equipment:set_throwable(icon)
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {0, 0, 32, 32})
		self._panel:child("throwables"):child("icon"):set_image(texture, unpack(texture_rect))
	end

	function PlayerInfoComponent.Equipment:set_throwable_amount(amount)
		self._throwable_data.amount = amount

		if amount <= 0 then
			local t = managers.player:player_timer():time()
			if self._throwable_data.cooldown > t then
				local time_left = self._throwable_data.cooldown - t
				self:set_throwable_cooldown(time_left, time_left)
				return
			end
		else
			self:stop_throwable_cooldown(true)
		end

		local panel = self._panel:child("throwables")
		local icon = panel:child("icon")
		local text = panel:child("amount")

		text:set_text(string.format("%02.0f", amount))
		text:set_range_color(0, amount < 10 and 1 or 0, Color.white:with_alpha(0.5))
		panel:set_visible(amount > 0 or self._animating_throwable_cooldown)
		self:arrange()
	end

	function PlayerInfoComponent.Equipment:set_throwable_cooldown(time_left, time_total)
		self._throwable_data.cooldown = managers.player:player_timer():time() + time_left
		if self._throwable_data.amount <= 0 then
			local panel = self._panel:child("throwables")
			if self._animating_throwable_cooldown then
				panel:stop()
				self._animating_throwable_cooldown = nil
			end
			panel:animate(callback(self, self, "_animate_throwable_cooldown"), time_left)
		end
	end

	function PlayerInfoComponent.Equipment:stop_throwable_cooldown(visibility)
		if self._animating_throwable_cooldown then
			local panel = self._panel:child("throwables")
			local icon = panel:child("icon")
			local text = panel:child("amount")

			panel:stop()
			self._animating_throwable_cooldown = nil
			text:set_color(Color.white)
			icon:set_alpha(1)
			if visibility ~= panel:visible() then
				panel:set_visible(visibility)
				self:arrange()
			end
		end
	end

	function PlayerInfoComponent.Equipment:set_deployable(icon)
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {0, 0, 32, 32})
		self._panel:child("deployables"):child("icon"):set_image(texture, unpack(texture_rect))
	end

	function PlayerInfoComponent.Equipment:set_deployable_amount(amount)
		local panel = self._panel:child("deployables")
		local text = panel:child("amount")
		text:set_text(string.format("%02.0f", amount))
		text:set_range_color(0, amount < 10 and 1 or 0, Color.white:with_alpha(0.5))
		panel:set_visible(amount > 0)
		self:arrange()
	end

	function PlayerInfoComponent.Equipment:set_deployable_amount_from_string(amounts)
		local text_str = ""
		local color_range = {}
		for i = 1, #amounts do
			local amount = amounts[i]
			if amount > 0 then
				if amount < 10 then
					local l = text_str:len()
					table.insert(color_range, {l, l+1})
				end
				local has_next = amounts[i+1] and amounts[i+1] > 0
				text_str = text_str .. string.format("%02.0f", amount) .. (has_next and "|" or "")
			end
		end

		local panel = self._panel:child("deployables")
		local text = panel:child("amount")
		text:set_text(text_str)

		for _, range in ipairs(color_range) do
			text:set_range_color(range[1], range[2], Color.white:with_alpha(0.5))
		end

		panel:set_visible(text_str:len() > 0)
		self:arrange()
	end

	function PlayerInfoComponent.Equipment:set_bodybag(icon)	-- equipment_body_bag
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		self._panel:child("body_bags"):child("icon"):set_image(texture, unpack(texture_rect))
	end

	function PlayerInfoComponent.Equipment:set_bodybag_amount(amount)
		local panel = self._panel:child("body_bags")
		local text = panel:child("amount")
		text:set_text(string.format("%02.0f", amount))
		text:set_range_color(0, amount < 10 and 1 or 0, Color.white:with_alpha(0.5))
		panel:set_visible(amount > 0)
		self:arrange()
	end

	function PlayerInfoComponent.Equipment:_animate_throwable_cooldown(panel, time_left)
		self._animating_throwable_cooldown = true
		local text = panel:child("amount")
		local icon = panel:child("icon")
		text:set_color(Color('FF7575'))
		icon:set_alpha(0.5)
		panel:set_visible(true)
		self:arrange()

		while time_left > 0 and self._animating_throwable_cooldown do
			time_left = time_left - coroutine.yield()
			text:set_text(string.format("%02.0f", math.ceil(time_left)))
			text:set_range_color(0, math.ceil(time_left) < 10 and 1 or 0, Color('FF7575'):with_alpha(0.5))
		end

		self:stop_throwable_cooldown(false)
	end

	PlayerInfoComponent.SpecialEquipment = PlayerInfoComponent.SpecialEquipment or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.SpecialEquipment:init(panel, owner, height, settings)
		PlayerInfoComponent.SpecialEquipment.super.init(self, panel, owner, "special_equipment", 0, height)

		self._settings = settings
		self._items_per_column = self._settings.SPECIAL_EQUIPMENT_ROWS or 3
		self._special_equipment = {}

		self:set_enabled("active", false)

		self._owner:register_listener("SpecialEquipment", { "add_special_equipment" }, callback(self, self, "add"), false)
		self._owner:register_listener("SpecialEquipment", { "remove_special_equipment" }, callback(self, self, "remove"), false)
		self._owner:register_listener("SpecialEquipment", { "special_equipment_amount" }, callback(self, self, "set_amount"), false)
		self._owner:register_listener("SpecialEquipment", { "clear_special_equipment" }, callback(self, self, "clear"), false)
	end

	function PlayerInfoComponent.SpecialEquipment:destroy()
		self._owner:unregister_listener("SpecialEquipment", { "clear_special_equipment", "special_equipment_amount", "remove_special_equipment", "add_special_equipment" })
		PlayerInfoComponent.SpecialEquipment.super.destroy(self)
	end

	function PlayerInfoComponent.SpecialEquipment:update_settings()
		self:set_enabled("setting", self._settings.SPECIAL_EQUIPMENT)

		if self._items_per_column ~= (self._settings.SPECIAL_EQUIPMENT_ROWS or 3) then
			self._items_per_column = self._settings.SPECIAL_EQUIPMENT_ROWS or 3
			for i, panel in ipairs(self._special_equipment) do
				self:_scale_item(panel)
			end
		end

		self:arrange()
	end

	function PlayerInfoComponent.SpecialEquipment:set_alignment(align)
		if PlayerInfoComponent.SpecialEquipment.super.set_alignment(self, align) then
			self:arrange()
		end
	end

	function PlayerInfoComponent.SpecialEquipment:rescale(factor)
		if PlayerInfoComponent.SpecialEquipment.super.rescale(self, factor) then
			for i, panel in ipairs(self._special_equipment) do
				self:_scale_item(panel)
			end
			self:arrange()
		end
	end

	function PlayerInfoComponent.SpecialEquipment:set_is_ai(state)
		if PlayerInfoComponent.SpecialEquipment.super.set_is_ai(self, state) and self:set_enabled("ai", not self._is_ai) then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.SpecialEquipment:arrange()
		local rescale = false
		local w = 0
		local h = self._panel:h()

		for i, panel in ipairs(self._special_equipment) do
			local column = math.floor((i-1) / self._items_per_column)
			local row = (i-1) % self._items_per_column
			panel:set_left(column * panel:w())
			panel:set_top(row * panel:h())
			w = (column+1) * panel:w()
		end

		if self._align == "right" then
			for i, panel in ipairs(self._special_equipment) do
				panel:set_right(w - panel:left())
			end
		end

		if self:set_size(w, h) then
			self:set_enabled("active", w > 0)
			self._owner:arrange()
		end

	end

	function PlayerInfoComponent.SpecialEquipment:add(id, icon)
		if self._panel:child(id) then
			self._panel:remove(self._panel:child(id))
		end

		local panel = self._panel:panel({
			name = id,
		})

		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		local icon = panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			color = Color.white,
		})

		local flash_icon = panel:bitmap({
			name = "flash_icon",
			texture = texture,
			texture_rect = texture_rect,
			color = tweak_data.hud.prime_color,
			layer = icon:layer() + 1,
		})
		flash_icon:set_center(icon:center())

		local amount_bg = panel:bitmap({
			name = "amount_bg",
			texture = "guis/textures/pd2/equip_count",
			color = Color.white,
			layer = flash_icon:layer() + 1,
			visible = false,
		})

		local amount_text = panel:text({
			name = "amount",
			color = Color.black,
			align = "center",
			vertical = "center",
			layer = amount_bg:layer() + 1,
			font = "fonts/font_small_noshadow_mf",
			visible = false,
		})

		self:_scale_item(panel)

		table.insert(self._special_equipment, panel)
		self:arrange()

		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		flash_icon:animate(hud.flash_icon, nil, panel)
	end

	function PlayerInfoComponent.SpecialEquipment:set_amount(id, amount)
		local amount = amount or 0

		for i, panel in ipairs(self._special_equipment) do
			if panel:name() == id then
				panel:child("amount"):set_text(tostring(amount))
				panel:child("amount"):set_visible(amount > 1)
				panel:child("amount_bg"):set_visible(amount > 1)
				break
			end
		end
	end

	function PlayerInfoComponent.SpecialEquipment:remove(id)
		for i, panel in ipairs(self._special_equipment) do
			if panel:name() == id then
				self._panel:remove(table.remove(self._special_equipment, i))
				self:arrange()
				break
			end
		end
	end

	function PlayerInfoComponent.SpecialEquipment:clear()
		while #self._special_equipment > 0 do
			self._panel:remove(table.remove(self._special_equipment, 1))
		end
		self:arrange()
	end

	function PlayerInfoComponent.SpecialEquipment:_scale_item(panel)
		local icon = panel:child("icon")
		local flash_icon = panel:child("flash_icon")
		local amount_bg = panel:child("amount_bg")
		local amount_text = panel:child("amount")

		local size = math.floor(self._panel:h() / self._items_per_column)

		panel:set_size(size, size)
		icon:set_size(size, size)
		if flash_icon then
			flash_icon:set_size(size+2, size+2)
			flash_icon:set_center(icon:center())
		end
		amount_bg:set_size(size, size)
		amount_bg:set_position(size * 0.25, size * 0.25)
		amount_text:set_size(amount_bg:w(), amount_bg:h())
		amount_text:set_font_size(amount_bg:h() * 0.5)
		amount_text:set_center(amount_bg:center())
	end

	PlayerInfoComponent.Interaction = PlayerInfoComponent.Interaction or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Interaction:init(panel, owner, height, settings)
		PlayerInfoComponent.Interaction.super.init(self, panel, owner, "interaction", 0, height)

		self._settings = settings
		self._min_width = 0
		self._tweak_data = {}

		self._bg = self._panel:rect({
			name = "bg",
			color = Color.black,
			alpha = 0.25,
			valign = "grow",
			halign = "grow",
			layer = -1,
		})

		self._text = self._panel:text({
			name = "text",
			color = Color.white,
			h = self._panel:h() * 0.5,
			halign = "grow",
			vertical = "center",
			align = "center",
			font_size = self._panel:h() * 0.3,
			font = tweak_data.hud_players.name_font,
		})

		self._progress_bar_bg = self._panel:rect({
			name = "progress_bar_bg",
			color = Color.black,
			align = "center",
			h = self._panel:h() * 0.35,
		})
		self._progress_bar_bg:set_top(self._text:bottom())

		self._progress_bar_outline = self._panel:bitmap({
			name = "progress_bar_outline",
			texture = "guis/textures/hud_icons",
			texture_rect = { 252, 240, 12, 48 },
			w = self._panel:h() * 0.35 * 1.2,
			layer = 10,
			rotation = 90,
		})

		self._progress_bar = self._panel:gradient({
			name = "progress_bar",
			alpha = 0.75,
			layer = self._progress_bar_bg:layer() + 1,
			h = self._progress_bar_bg:h(),
		})
		self._progress_bar:set_center_y(self._progress_bar_bg:center_y())

		self._progress_timer = self._panel:text({
			name = "progress_timer",
			layer = self._progress_bar:layer() + 1,
			color = Color.white,
			halign = "grow",
			vertical = "center",
			align = "center",
			h = self._progress_bar_bg:h(),
			font_size = self._progress_bar_bg:h() * 0.95,
			font = tweak_data.hud_players.name_font
		})
		self._progress_timer:set_center_y(self._progress_bar:center_y())

		self:set_enabled("active", false)
		self:set_alpha(0)

		self._owner:register_listener("Interaction", { "interaction_start" }, callback(self, self, "start"), false)
		self._owner:register_listener("Interaction", { "interaction_tweak" }, callback(self, self, "set_tweak_data"), false)
		self._owner:register_listener("Interaction", { "interaction_stop" }, callback(self, self, "stop"), false)
	end

	function PlayerInfoComponent.Interaction:destroy()
		self._owner:unregister_listener("Interaction", { "interaction_start", "interaction_stop", "interaction_tweak" })
		PlayerInfoComponent.Interaction.super.destroy(self)
	end

	function PlayerInfoComponent.Interaction:arrange()
		local h = self._panel:h()
		local _, _, text_w, _ = self._text:text_rect()
		local w = math.max(text_w * 1.3, self._min_width)

		if self:set_size(w, h) then
			self._progress_bar_bg:set_w(w * 0.8)
			self._progress_bar_bg:set_center_x(w/2)
			self._progress_bar:set_x(self._progress_bar_bg:x())
			self._progress_bar_outline:set_h(self._progress_bar_bg:w() * 1.05)
			self._progress_bar_outline:set_center(self._progress_bar_bg:center())

			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Interaction:set_min_w(w)
		if self._min_width ~= w then
			self._min_width = w
			self:arrange()
		end
	end

	function PlayerInfoComponent.Interaction:start(id, timer)
		self._panel:stop()

		if not self._settings.INTERACTION.HIDE and (self._settings.INTERACTION.MIN_DURATION or 0) <= timer then
			local tweak_entry = self._tweak_data[id]
			local text_id, macros = "hud_action_generic", {}
			if tweak_entry and (tweak_entry.action_text_id or tweak_entry.quantity) then
				text_id = tweak_entry.action_text_id or "hud_deploying_equipment"
				macros = { EQUIPMENT = (tweak_entry.text_id and managers.localization:text(tweak_entry.text_id) or "N/A"), BTN_INTERACT = managers.localization:get_default_macro("BTN_INTERACT") }
			end
			local text = managers.localization:to_upper_text(text_id, macros) or ""

			self:set_enabled("active", true)
			self._text:set_color(Color.white)
			self._text:set_text(string.format("%s (%.1fs)", text, timer))
			self:arrange()
			self._panel:animate(callback(self, self, "_animate"), timer)
		end
	end

	function PlayerInfoComponent.Interaction:set_tweak_data(tweak_data)
		if tweak_data then
			self._tweak_data = tweak_data
		end
	end

	function PlayerInfoComponent.Interaction:stop(success)
		if self:visible() then
			self._panel:stop()
			self._text:set_color(success and Color.green or Color.red)
			self._text:set_text(managers.localization:to_upper_text(success and "wolfhud_customhud_interaction_done" or "wolfhud_customhud_interaction_aborted"))
			--self._interaction:set_enabled("active", false)
			--self:arrange()
		end
	end

	function PlayerInfoComponent.Interaction:_animate(panel, timer)
		local b = 0
		local g_max = 0.9
		local g_min = 0.1
		local r_max = 0.9
		local r_min = 0.1

		local T = 0.5
		local t = 0
		while timer > t do
			local time_left = timer - t
			local r = math.clamp(t / timer, 0, 1)

			self._progress_timer:set_text(string.format("%.1fs", time_left))
			self._progress_bar:set_w(self._progress_bar_bg:w() * r)

			if r < 0.5 then
				local green = math.clamp(r * 2, 0, 1) * (g_max - g_min) + g_min
				self._progress_bar:set_gradient_points({ 0, Color(r_max, g_min, b), 1, Color(r_max, green, b) })
			else
				local red = math.clamp(1 - (r - 0.5) * 2, 0, 1) * (r_max - r_min) + r_min
				self._progress_bar:set_gradient_points({ 0, Color(r_max, g_min, b), 0.5/r, Color(r_max, g_max, b), 1, Color(red, g_max, b) })
			end

			t = t + coroutine.yield()
		end

		self._progress_bar:set_w(self._progress_bar_bg:w())
		self._progress_bar:set_gradient_points({ 0, Color(r_max, g_min, b), 0.5, Color(r_max, g_max, b), 1, Color(r_min, g_max, b) })
	end

	--Unused, remember to update arrange handling
	PlayerInfoComponent.Throwable = PlayerInfoComponent.Throwable or class(PlayerInfoComponent.Base)
	function PlayerInfoComponent.Throwable:init(panel, owner, height)
		PlayerInfoComponent.Throwable.super.init(self, panel, owner, "throwable", 0, height)

		self._icon_panel = self._panel:panel({
			name = "icon_panel",
			w = self._panel:h() * 2,
			h = self._panel:h(),
		})

		local icon = self._icon_panel:bitmap({
			name = "icon",
			w = self._icon_panel:w(),
			h = self._icon_panel:h(),
		})

		local label = self._icon_panel:text({
			name = "label",
			text = "N/A",
			color = Color.white,
			align = "center",
			vertical = "top",
			h = self._icon_panel:h(),
			w = self._icon_panel:w(),
			font_size = self._icon_panel:h() * 0.2,
			font = tweak_data.hud_players.name_font,
			layer = weapon_icon:layer() + 1,
			wrap = true,
			word_wrap = true,
		})

		local amount = self._icon_panel:text({
			name = "amount",
			text = "0",
			color = Color.white,
			layer = weapon_icon:layer() + 1,
			w = self._icon_panel:w(),
			h = self._icon_panel:h() * 0.35,
			vertical = "center",
			align = "right",
			font_size = self._icon_panel:h() * 0.35,
			font = tweak_data.hud_players.ammo_font
		})
		amount:set_bottom(self._icon_panel:h())
	end

	function PlayerInfoComponent.Throwable:add_statistics_panel()
		self._statistics_panel = self._panel:panel({
			name = "statistics_panel",
			h = self._panel:h(),
			w = 0,
		})

		--TODO: Check killcount plugin, add stuff if so
		--[[
		if HUDManager.KILL_COUNT_PLUGIN then
			local kill_count_panel = parent:panel({
				name = "kill_count_panel",
				h = parent:h(),
			})

			local div = kill_count_panel:rect({
				name = "div",
				color = Color.white,
				w = 1,
				x = 1,
				h = kill_count_panel:h(),
				alpha = 1,
			})

			local header = kill_count_panel:text({
				name = "header",
				text = "Kills",
				color = Color.white,
				layer = 1,
				x = 1 + div:x(),
				h = kill_count_panel:h() * 0.5,
				vertical = "center",
				align = "center",
				font_size = kill_count_panel:h() * 0.5 * 0.75,
				font = tweak_data.hud_players.ammo_font
			})

			local count = kill_count_panel:text({
				name = "count",
				text = "1234/1234",
				color = Color.white,
				layer = 1,
				x = 1 + div:x(),
				y = kill_count_panel:h() * 0.5,
				h = kill_count_panel:h() * 0.5,
				vertical = "center",
				align = "center",
				font_size = kill_count_panel:h() * 0.5 * 0.75,
				font = tweak_data.hud_players.ammo_font
			})

			local _, _, w, _ = count:text_rect()
			w = w + div:w() + 2

			header:set_w(w)
			count:set_w(w)
			kill_count_panel:set_w(w)
			kill_count_panel:set_x(parent:w())
			parent:set_w(parent:w() + kill_count_panel:w())
		end
		]]

		--TODO: Update statisticspanel width
		self:arrange()
	end

	function PlayerInfoComponent.Throwable:arrange()
		local MARGIN = self._panel:h() * 0.1

		local w = 0
		local h = self:h()

		if self._icon_panel:visible() then
			self._icon_panel:set_left(w)
			w = w + MARGIN + self._icon_panel:w()
		end

		if self._statistics_panel and self._statistics_panel:visible() then
			self._statistics_panel:set_left(w)
			w = w + MARGIN + self._statistics_panel:w()
		end

		if w > 0 then
			w = w - MARGIN
		end

		PlayerInfoComponent.Throwable.super.arrange(self, w, h)
		if self._owner then
			self._owner:arrange()
		end
	end

	function PlayerInfoComponent.Throwable:set_icon(id)
		local texture, text = PlayerInfoComponent.Base.get_item_icon_data("throwable", id)

		self._icon_panel:child("icon"):set_image(texture)
		self._icon_panel:child("label"):set_text(text)
	end

	function PlayerInfoComponent.Throwable:set_amount(count)
		self._icon_panel:child("amount"):set_text(tostring(count))
	end

	PlayerInfoComponent.Melee = PlayerInfoComponent.Melee or class(PlayerInfoComponent.Base)
	PlayerInfoComponent.Armor = PlayerInfoComponent.Armor or class(PlayerInfoComponent.Base)
	PlayerInfoComponent.Deployable = PlayerInfoComponent.Deployable or class(PlayerInfoComponent.Base)

end

if RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDManager.CUSTOM_TEAMMATE_PANELS = true	--External flag

	local update_original = HUDManager.update
	local add_weapon_original = HUDManager.add_weapon
	local set_stamina_value_original = HUDManager.set_stamina_value
	local set_max_stamina_original = HUDManager.set_max_stamina
	local set_mugshot_voice_original = HUDManager.set_mugshot_voice
	local teammate_progress_original = HUDManager.teammate_progress
	local set_teammate_carry_info_original = HUDManager.set_teammate_carry_info
	local remove_teammate_carry_info_original = HUDManager.remove_teammate_carry_info

	function HUDManager:_create_teammates_panel(hud, ...)
		hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

		self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
		self._teammate_panels = {}

		if hud.panel:child("teammates_panel") then
			hud.panel:remove(hud.panel:child("teammates_panel"))
		end

		if hud.panel:child("bag_presenter") then
			hud.panel:remove(hud.panel:child("bag_presenter"))
		end

		self._bag_presenter = BagPresenter:new(hud.panel)

		local teammates_panel = hud.panel:panel({
			name = "teammates_panel",
			w = hud.panel:w(),
			h = hud.panel:h(),
		})

		local j = 1
		HUDManager.PLAYER_PANEL = math.max(CriminalsManager.MAX_NR_CRIMINALS, HUDManager.PLAYER_PANEL)	--TEST
		local num_panels = HUDManager.PLAYER_PANEL	--TEST
		--local num_panels = math.max(CriminalsManager.MAX_NR_CRIMINALS, HUDManager.PLAYER_PANEL) --4

		for i = 1, num_panels do
			local is_player = i == HUDManager.PLAYER_PANEL
			local align

			--if j < 4 or is_player or j <= math.ceil(num_panels / 2) then
			if is_player then
				align = WolfHUD:getSetting({"CustomHUD", "PLAYER", "POSITION"}, 2) < 3 and "left" or "right"
			elseif j <= 7 then
				align = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "POSITION"}, 1) < 3 and "left" or "right"
			else
				align = WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "POSITION"}, 1) > 1 and "right" or "left"
			end

			local teammate = HUDTeammateCustom:new(i, teammates_panel, is_player, align)

			self._hud.teammate_panels_data[i] = {
				--taken = is_player and (num_panels > HUDManager.PLAYER_PANEL),
				taken = false,
				special_equipments = {},
			}

			table.insert(self._teammate_panels, teammate)

			if is_player then
				teammate:add_panel()
			else
				j = j + 1
			end
		end

		self:arrange_teammate_panels()
	end

	function HUDManager:update(...)
		for i, panel in ipairs(self._teammate_panels) do
			panel:update(...)
		end

		return update_original(self, ...)
	end

	function HUDManager:add_weapon(data, ...)
		local wbase = data.unit:base()
		local name_id = wbase.name_id
		if wbase._cosmetics_data and wbase._cosmetics_data.name_id then
			local skin_id = wbase._cosmetics_data.name_id:gsub("bm_wskn_", "")
			local skin_tweak = tweak_data.blackmarket.weapon_skins[skin_id]
			if skin_tweak and not skin_tweak.is_a_color_skin and (table.contains(skin_tweak.weapon_ids or {}, weapon_id) or (skin_tweak.weapon_id and skin_tweak.weapon_id == weapon_id) ~= (skin_tweak.use_blacklist or false)) then
				name_id = skin_id
			end
		end

		self:set_teammate_weapon(HUDManager.PLAYER_PANEL, data.inventory_index, name_id, wbase:got_silencer())

		local active_mode = wbase:fire_mode()
		local fire_modes = {}
		if wbase:fire_mode() == "single" or (wbase:can_toggle_firemode() and not wbase._locked_fire_mode) then
			table.insert(fire_modes, { "single", "S" })
		end
		if wbase.can_use_burst_mode and wbase:can_use_burst_mode() and not wbase._locked_fire_mode then
			active_mode = wbase:in_burst_mode() and "burst" or active_mode
			table.insert(fire_modes, { "burst", "B" })
		end
		if wbase:fire_mode() == "auto" or (wbase:can_toggle_firemode() and not wbase._locked_fire_mode) then
			table.insert(fire_modes, { "auto", "A" })
		end

		self:set_teammate_available_fire_modes(HUDManager.PLAYER_PANEL, data.inventory_index, fire_modes)
		self:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, data.inventory_index, active_mode)

		return add_weapon_original(self, data, ...)
	end

	function HUDManager:set_stamina_value(...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(...)
		return set_stamina_value_original(self, ...)
	end

	function HUDManager:set_max_stamina(...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina_max(...)
		return set_max_stamina_original(self, ...)
	end

	function HUDManager:set_mugshot_voice(id, active, ...)
		for i, data in pairs(managers.criminals:characters()) do
			if data.data.mugshot_id == id then
				local panel_id = data.data and data.data.panel_id
				if panel_id and panel_id ~= HUDManager.PLAYER_PANEL then
					self._teammate_panels[panel_id]:set_voice_com_active(active)
				end
				break
			end
		end

		return set_mugshot_voice_original(self, id, active, ...)
	end

	function HUDManager:teammate_progress(peer_id, type_index, enabled, tweak_data_id, ...)
		local interact_tweak = {}
		if type_index == 1 then
			interact_tweak = tweak_data.interaction
		elseif type_index == 2 then
			interact_tweak = tweak_data.equipments
		elseif type_index == 3 then
			interact_tweak = { [tweak_data_id] = { action_text_id = "hud_starting_heist" } }
		end

		local character_data = managers.criminals:character_data_by_peer_id(peer_id)
		if character_data and interact_tweak then
			self._teammate_panels[character_data.panel_id]:set_interaction_tweak(enabled, interact_tweak)
		end

		teammate_progress_original(self, peer_id, type_index, enabled, tweak_data_id, ...)
	end

	function HUDManager:set_teammate_carry_info(i, ...)
		if i == HUDManager.PLAYER_PANEL then
			self._bag_presenter:set_carry(...)
		end

		return set_teammate_carry_info_original(self, i, ...)
	end

	function HUDManager:remove_teammate_carry_info(i, ...)
		if i == HUDManager.PLAYER_PANEL then
			self._bag_presenter:clear_carry()
			self._teammate_panels[i]:remove_carry_info(...)
		end

		return remove_teammate_carry_info_original(self, i, ...)
	end

	--HARD OVERRIDE (4 -> HUDManager.PLAYER_PANEL)
	function HUDManager:reset_player_hpbar()
		local crim_entry = managers.criminals:character_static_data_by_name(managers.criminals:local_character_name())
		if not crim_entry then
			return
		end
		local color_id = managers.network:session():local_peer():id()
		self:set_teammate_callsign(HUDManager.PLAYER_PANEL, color_id)
		self:set_teammate_name(HUDManager.PLAYER_PANEL, managers.network:session():local_peer():name())

	end

	function HUDManager:set_ai_stopped(ai_id, stopped, ...)
		local teammate_panel = self._teammate_panels[ai_id]
		if teammate_panel and teammate_panel:is_ai() then
			teammate_panel:set_ai_stopped(stopped)
			teammate_panel:set_condition(stopped and "ai_stopped" or "mugshot_normal", stopped and "HOLD" or "NORMAL")

			local name = string.gsub(teammate_panel:name(), "%W", "")
			for _, label in ipairs(self._hud.name_labels) do
				if string.gsub(label.character_name, "%W", "") == name then
					if stopped and not label.panel:child("stopped") then
						local texture, texture_rect = tweak_data.hud_icons:get_icon_data("ai_stopped")
						local label_stop_icon = label.panel:bitmap({name = "stopped", texture = texture, texture_rect = texture_rect})
						label_stop_icon:set_right(label.text:left())
						label_stop_icon:set_center_y(label.text:center_y())
					elseif not stopped and label.panel:child("stopped") then
						label.panel:remove(label.panel:child("stopped"))
					end
				end
			end
		end
	end

	--NEW FUNCTIONS
	function HUDManager:arrange_teammate_panels()
		local MARGIN = 5
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		local hud_panel = hud.panel

		local hud_w, hud_h = hud_panel:w(), hud_panel:h()
		local player_hud = self._teammate_panels[HUDManager.PLAYER_PANEL]
		local player_panel = player_hud and player_hud:panel() or nil
		if player_hud and player_panel then
			local teammate_offset = { 0, 0, 0 }

			local function getCenterX(hud_w, panel_w, pos_id)
				local hud_w2, panel_w2 = hud_w / 2, panel_w / 2
				return pos_id <= 1 and panel_w2 or pos_id == 2 and hud_w2 or (hud_w - panel_w2)
			end

			--Seperate Player Panel setup, so its always the most bottom one
			local player_pos = math.clamp(WolfHUD:getSetting({"CustomHUD", "PLAYER", "POSITION"}, 2), 1, 3)
			local player_w, player_h = player_panel:w() or 0, player_panel:h() or 0
			player_panel:set_center_x(getCenterX(hud_w, player_w, player_pos))
			player_panel:set_bottom(hud_h - teammate_offset[player_pos])
			player_hud:set_alignment((player_pos < 3) and "left" or "right")
			teammate_offset[player_pos] = math.round(teammate_offset[player_pos] + player_panel:h() + MARGIN)

			local j = 0
			local MAX_STACK_SIZE = math.max(math.ceil(#self._teammate_panels / 2), 7)
			local teammate_pos = { math.clamp(WolfHUD:getSetting({"CustomHUD", "TEAMMATE", "POSITION"}, 1), 1, 3) }
			table.insert(teammate_pos, (teammate_pos[1] > 1 and 1 or 3))

			for i, teammate in ipairs(self._teammate_panels) do
				local panel = teammate:panel()

				if i ~= HUDManager.PLAYER_PANEL and panel:visible() then
					local team_stack = j < MAX_STACK_SIZE and 1 or 2

					panel:set_center_x(getCenterX(hud_w, panel:w(), teammate_pos[team_stack]))
					panel:set_bottom(hud_h - teammate_offset[teammate_pos[team_stack]])
					teammate:set_alignment((teammate_pos[team_stack] < 3) and "left" or "right")

					teammate_offset[teammate_pos[team_stack]] = math.round(teammate_offset[teammate_pos[team_stack]] + panel:h() + MARGIN)
					j = j + 1
				end
			end

			local y = hud_h - (teammate_offset[2]) - 10
			if managers.hudlist then
				local list_panel = managers.hudlist:list("buff_list"):panel()
				list_panel:set_bottom(y)
				y = list_panel:top()
			end
			if managers.subtitle then
				local sub_presenter = managers.subtitle:presenter()
				if sub_presenter and sub_presenter.set_bottom then
					sub_presenter:set_bottom(y - 10)
				end
			end
			local align_id = teammate_offset[1] < teammate_offset[3] and 1 or 3
			if self._hud_driving and self._hud_driving.set_offset and self._hud_driving:panel():visible() then
				self._hud_driving:set_offset(teammate_offset[align_id] + HUDDriving._MARGIN, align_id < 2 and "left" or "right")
				teammate_offset[align_id] = math.round(self._hud_driving:panel():top())
				align_id = teammate_offset[1] < teammate_offset[3] and 1 or 3
			end
			if self._hud_chat_ingame and self._hud_chat_ingame.set_offset then
				self._hud_chat_ingame:set_offset(teammate_offset[align_id] + HUDChat.LINE_HEIGHT, align_id < 2 and "left" or "right")
			end
		end
	end

	function HUDManager:change_hud_setting(type, setting, value)
		if setting[1] == "POSITION" then
			self:arrange_teammate_panels()
		else
			for i, panel in ipairs(self._teammate_panels) do
				if panel._is_player and type == "PLAYER" or not panel._is_player and type == "TEAMMATE" then
					panel:change_setting(setting, value)
				end
			end
		end
	end

	function HUDManager:teammate_panel(i)
		return self._teammate_panels[i]
	end

	function HUDManager:set_player_carry_info(carry_id, value)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_carry_info(carry_id, value)
	end

	function HUDManager:set_teammate_weapon(i, index, id, silencer)
		self._teammate_panels[i]:set_weapon(index, id, silencer)
	end

	function HUDManager:set_teammate_available_fire_modes(i, index, modes)
		self._teammate_panels[i]:set_available_fire_modes(index, modes)
	end

	function HUDManager:set_teammate_weapon_firemode_burst(selection_index)
		self:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, selection_index, "burst")
	end

	function HUDManager:_parse_outfit_string(panel_id, peer_id)
		local outfit

		local local_peer = managers.network:session():local_peer()
		if peer_id == local_peer:id() then
			--outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
			--Weapons handled by HUDManager:add_weapon()
			--Detection handled by HUDTeammate:set_callsign()
		else
			local peer = managers.network:session():peer(peer_id)
			outfit = peer and peer:blackmarket_outfit()

			if outfit then
				--Weapon
				for selection, data in ipairs({ outfit.secondary, outfit.primary }) do
					local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(data.factory_id)
					local skin_id = data.cosmetics and data.cosmetics.id
					local skin_tweak = tweak_data.blackmarket.weapon_skins[skin_id]
					local weapon_skin = skin_tweak and not skin_tweak.is_a_color_skin and (table.contains(skin_tweak.weapon_ids or {}, weapon_id) or (skin_tweak.weapon_id and skin_tweak.weapon_id == weapon_id) ~= (skin_tweak.use_blacklist or false)) or false
					local silencer = managers.weapon_factory:has_perk("silencer", data.factory_id, data.blueprint)
					self:set_teammate_weapon(panel_id, selection, weapon_skin and skin_id or weapon_id, silencer)

					local tweak = tweak_data.weapon[weapon_id]
					if tweak then
						local clip_max = tweak.CLIP_AMMO_MAX
						local total_max = tweak.AMMO_MAX
						self:set_teammate_ammo_amount(panel_id, selection, clip_max, clip_max, total_max, total_max)
					end
				end

				--Perk deck
				local deck_index, deck_level = unpack(outfit.skills.specializations)
				local skills = outfit.skills.skills
				self:set_teammate_specialization(panel_id, tonumber(deck_index), tonumber(deck_level))
				self:set_teammate_skills(panel_id, skills)

				-- Detection
				local detection = managers.blackmarket:get_suspicion_offset_of_peer(peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
				self:set_teammate_detection(panel_id, math.round(detection * 100))
			end
		end

		--self:_set_armor(outfit.armor)
		--self:_set_melee(outfit.melee_weapon)
		--self:_set_deployable_id(outfit.deployable)
		--self:_set_throwable(outfit.grenade)
		--self:_set_skills(table.map_copy(outfit.skills.skills))
		--self:_set_specialization(table.map_copy(outfit.skills.specializations))
	end

	function HUDManager:set_teammate_accuracy(i, value)
		self._teammate_panels[i]:set_accuracy(value)
	end

	function HUDManager:set_teammate_weapon_accuracy(i, slot, value)
		--TODO
	end

	function HUDManager:increment_teammate_kill_count(i, is_special, headshot)
		self._teammate_panels[i]:increment_kill_count(is_special, headshot)
	end

	function HUDManager:reset_teammate_kill_count(i)
		self._teammate_panels[i]:reset_kill_count()
	end

	function HUDManager:increment_teammate_kill_count_detailed(i, unit, weapon_id, weapon_type, weapon_slot)
		--TODO
	end

	function HUDManager:set_player_revives(i, value)
		self._teammate_panels[i]:set_revives(value or 0)
	end

	function HUDManager:increment_teammate_downs(i)
		self._teammate_panels[i]:increment_downs()
	end

	function HUDManager:reset_teammate_downs(i)
		self._teammate_panels[i]:reset_downs()
	end

	function HUDManager:set_teammate_detection(i, value)
		self._teammate_panels[i]:set_detection(value)
	end

	function HUDManager:set_teammate_specialization(i, index, level)
		if index and level then
			self._teammate_panels[i]:set_specialization(index, level)
		end
	end

	function HUDManager:set_teammate_skills(i, data)
		self._teammate_panels[i]:set_skills(data)
	end

	BagPresenter = BagPresenter or class()

	function BagPresenter:init(parent_panel)
		self._parent_panel = parent_panel

		self._panel = parent_panel:panel({
			name = "bag_presenter",
			visible = false,
		})

		self._bg_box = HUDBGBox_create(self._panel, {
			name = "bg_box",
			halign = "grow",
			valign = "grow",
		})

		self._carry_text = self._panel:text({
			name = "carry_text",
			align = "center",
			vertical = "center",
			valign = "grow",
			halign = "grow",
			color = Color.white,
			font = "fonts/font_medium_mf",
		})
		self._carry_text:set_x(0)
		self._carry_text:set_y(0)
	end

	function BagPresenter:clear_carry()
		self:set_carry()
	end

	function BagPresenter:set_carry(carry_id, value)
		self._carry_id = carry_id
		self._carry_value = value

		self._panel:stop()

		if carry_id then
			local tweak = tweak_data.carry[self._carry_id]
			local name_id = tweak and tweak.name_id
			local carry_text = name_id and managers.localization:text(name_id) or "N/A"
			self._carry_text:set_font_size(30)
			self._carry_text:set_text(carry_text)
			local _, _, w, h = self._carry_text:text_rect()
			self._panel:animate(callback(self, self, "_animate_present"), w * 1.5, h * 1.5)
		else
			managers.hud:set_player_carry_info()
			self._panel:hide()
		end
	end

	function BagPresenter:_animate_present(panel, panel_w, panel_h)
		local player_panel = managers.hud:teammate_panel(HUDManager.PLAYER_PANEL)
		local x1 = self._parent_panel:w() * 0.5
		local y1 = self._parent_panel:h() * 0.75
		local x2 = player_panel:panel():center_x()
		local y2 = player_panel:panel():top()
		local w1 = panel_w
		local w2 = panel_w
		local w3 = w2 * 0.5
		local h1 = 0
		local h2 = panel_h
		local h3 = h2 * 0.5
		local f1 = self._carry_text:font_size()
		local f2 = f1 * 0.5
		local a1 = 1
		local a2 = 0.5

		self._panel:set_alpha(a1)
		self._panel:show()

		local T = 0.15
		local t = 0
		while t < T do
			local r = t/T
			self._panel:set_size(math.lerp(w1, w2, r), math.lerp(h1, h2, r))
			self._panel:set_center(x1, y1)
			t = t + coroutine.yield()
		end

		wait(0.1)

		local i = 8
		while i > 0 do
			self._panel:set_visible(not self._panel:visible())
			i = i - 1
			wait(0.1)
		end

		wait(0.25)

		T = 0.5
		t = 0
		while t < T do
			local r = t/T
			self._panel:set_size(math.lerp(w2, w3, r), math.lerp(h2, h3, r))
			self._carry_text:set_font_size(math.lerp(f1, f2, r))
			self._panel:set_center(math.lerp(x1, x2, r), math.lerp(y1, y2, r))
			self._panel:set_alpha(math.lerp(a1, a2, r))
			t = t + coroutine.yield()
		end

		self._panel:hide()
		managers.hud:set_player_carry_info(self._carry_id, self._carry_value)
	end
end

if RequiredScript == "lib/managers/hud/hudtemp" then

	local init_original = HUDTemp.init

	function HUDTemp:init(...)
		init_original(self, ...)
		if not self.carry_weight_string then
			self._temp_panel:set_alpha(0)
		end
	end

end

if RequiredScript == "lib/managers/hud/hudwaitinglegend" then
	local update_buttons_orig = HUDWaitingLegend.update_buttons
	function HUDWaitingLegend:update_buttons(...)
		update_buttons_orig(self, ...)
		self._panel:set_visible(false)
		self._box:stop()
	end
end
