if string.lower(RequiredScript) == "lib/managers/menu/contractboxgui" then
	local init_original = ContractBoxGui.init
	local update_character_original = ContractBoxGui.update_character
	local update_character_menu_state_original = ContractBoxGui.update_character_menu_state
	local update_bg_state_original = ContractBoxGui.update_bg_state
	local mouse_wheel_up_original = ContractBoxGui.mouse_wheel_up
	local mouse_wheel_down_original = ContractBoxGui.mouse_wheel_down
	local mouse_pressed_original = ContractBoxGui.mouse_pressed
	local mouse_moved_original = ContractBoxGui.mouse_moved
	local set_enabled_original = ContractBoxGui.set_enabled

	ContractBoxGui._LOADOUT_W = 750
	ContractBoxGui._LOADOUT_H = 580

	function ContractBoxGui:init(...)
		init_original(self, ...)

		if managers.network:session() then
			self._peer_loadout = _peer_loadout or {}

			self._loadout_icon = self._panel:bitmap({
				name = "toggle_loadout_icon",
				texture = "guis/textures/pd2/mouse_buttons",
				texture_rect = {35, 1, 17, 23},
				w = tweak_data.menu.pd2_small_font_size * 0.85,
				h = tweak_data.menu.pd2_small_font_size * 1.10,
			})
			self._loadout_icon:set_left(self._panel:left())
			self._loadout_icon:set_bottom(self._panel:bottom())

			self._loadout_btn = self._panel:text({
				name = "toggle_loadout",
				text = utf8.to_upper(managers.localization:text("menu_team_loadout") .. ": " .. managers.localization:text("menu_button_show")),
				h = tweak_data.menu.pd2_small_font_size * 1.05,
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.button_stage_3,
				blend_mode = "add",
			})
			local _, _, w, _ = self._loadout_btn:text_rect()
			self._loadout_btn:set_w(w)
			self._loadout_btn:set_left(self._loadout_icon:right() + 5)
			self._loadout_btn:set_bottom(self._panel:bottom() - 1)

			self._loadout_panel = self._panel:panel({
				name = "crew_loadout",
				w = ContractBoxGui._LOADOUT_W,
				h = ContractBoxGui._LOADOUT_H,
				layer = _G.tweak_data.gui.CRIMENET_CHAT_LAYER + 5,
			})

			self._loadout_data = self._loadout_panel:panel({
				name = "crew_loadout",
				y = self._loadout_panel:bottom(),
				w = self._loadout_panel:w(),
				h = self._loadout_panel:h(),
			})

			self._loadout_data:rect({
				color = Color(0.6, 0, 0, 0),
				layer = -1,
				halign = "grow",
				valign = "grow"
			})

			self._borders = BoxGuiObject:new(self._loadout_data, {
				sides = { 1, 1, 2, 2 }
			})

			self._loadout_panel:set_bottom(self._loadout_btn:top())
			self._loadout_panel:set_left(self._panel:left())

			self:populate_loadout_panel()
		end
	end

	function ContractBoxGui:update_character(peer_id, ...)
		update_character_original(self, peer_id, ...)

		if self._peer_loadout[peer_id] then
			self:update_loadout_panel(peer_id)
		end
	end
	--[[
	function ContractBoxGui:update_character_menu_state(peer_id, ...)
		update_character_menu_state_original(self, peer_id, ...)
		
		if self._peer_loadout[peer_id] then
			self:update_loadout_panel(peer_id)
		end
	end
	]]

	function ContractBoxGui:update_bg_state(peer_id, ...)
		update_bg_state_original(self, peer_id, ...)

		-- Re-Hide Chat
		if managers.menu_component and self._loadout_visible then
			if self._peer_loadout[peer_id] and self._peer_loadout[peer_id]:local_peer() then
				managers.menu_component:hide_game_chat_gui()
			end
		end
	end

	function ContractBoxGui:mouse_wheel_up(...)
		if self:can_take_input() and not self._loadout_visible and not self._active_move then
			self:toggle_loadout()
		end

		mouse_wheel_up_original(self, ...)
	end

	function ContractBoxGui:mouse_wheel_down(...)
		if self:can_take_input() and self._loadout_visible and not self._active_move then
			self:toggle_loadout()
		end

		mouse_wheel_down_original(self, ...)
	end

	function ContractBoxGui:mouse_pressed(button, x, y, ...)
		if self:can_take_input() and alive(self._loadout_btn) and button == Idstring("0") and self._loadout_btn:inside(x, y) and not self._active_move then
			self:toggle_loadout()
		elseif self._loadout_visible then

		else
			return mouse_pressed_original(self, button, x, y, ...)
		end
	end

	function ContractBoxGui:mouse_moved(x, y, ...)
		if self:can_take_input() and alive(self._loadout_btn) and not self._active_move then
			if self._loadout_btn:inside(x, y) then
				if not self._loadout_btn_highlighted then
					self._loadout_btn:set_color(tweak_data.screen_colors.button_stage_2)
					managers.menu_component:post_event("highlight")
					self._loadout_btn_highlighted = true
				end
				return true, "link"
			elseif self._loadout_btn_highlighted then
				self._loadout_btn:set_color(tweak_data.screen_colors.button_stage_3)
				self._loadout_btn_highlighted = nil
			end
		end

		if not self._loadout_visible then
			return mouse_moved_original(self, x, y, ...)
		end

		return true, "arrow"
	end

	function ContractBoxGui:set_enabled(...)
		set_enabled_original(self, ...)

		if alive(self._loadout_panel) and alive(self._loadout_btn) then
			self._loadout_panel:set_visible(self._enabled)
			self._loadout_btn:set_visible(self._enabled)
		end
	end

	function ContractBoxGui:populate_loadout_panel()
		for peer_id, panel in ipairs(self._peer_loadout or {}) do
			if panel then
				panel:destroy()
				self._peer_loadout[peer_id] = nil
			end
		end

		local width = math.floor(ContractBoxGui._LOADOUT_W / 4)
		for i, peer_id in ipairs({3, 2, 1, 4}) do
			if not self._peer_loadout[peer_id] then
				self._peer_loadout[peer_id] = LoadoutPanel:new(self._loadout_data, self, peer_id, width, ContractBoxGui._LOADOUT_H, {
					component_layout = { { "name" }, { "character" }, { "skills" }, { "perk" }, { "primary" }, { "secondary" }, { "melee_weapon" }, { "grenade", "armor" }, { "deployable", "secondary_deployable" } },
					margin = 5,
					borders = {1, 1, 1, 1}
				})
			end
		end
		self:arrange_loadout_panels()
	end

	function ContractBoxGui:update_loadout_panel(peer_id)
		if self._peer_loadout[peer_id] then
			if self._peer_loadout[peer_id]:local_peer() then
				local outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string()) or {}
				self._peer_loadout[peer_id]:set_outfit(outfit)
			else
				local peer = managers.network:session():peer(peer_id)
				local outfit = peer and peer:blackmarket_outfit() or {}
				self._peer_loadout[peer_id]:set_outfit(outfit)
			end
		end
	end

	function ContractBoxGui:arrange_loadout_panels()
		local x = 0
		local max_h = 0
		local width = math.floor(ContractBoxGui._LOADOUT_W / 4)
		for i, peer_id in ipairs({3, 2, 1, 4}) do
			local panel = self._peer_loadout[peer_id]
			if panel and panel:enabled() then
				panel:set_x(x)
				--panel:set_w(width)
				max_h = math.max(max_h, math.ceil(panel:h()))
			end
			x = x + width
		end

		local new_h = math.min(max_h, ContractBoxGui._LOADOUT_H)
		if new_h ~= self._loadout_panel:h() then
			self._loadout_panel:set_h(new_h)
			self._loadout_data:set_h(self._loadout_panel:h())

			self._loadout_panel:set_bottom(self._loadout_btn:top())
			if self._loadout_visible then
				self._loadout_data:set_top(0)
			else
				self._loadout_data:set_top(self._loadout_panel:bottom())
			end

			if self._borders then
				self._borders:create_sides(self._loadout_data, {
					sides = { 1, 1, 2, 2 }
				})
			end
		end
	end

	function ContractBoxGui:toggle_loadout()
		if alive(self._loadout_panel) and alive(self._loadout_btn) then
			local y = self._loadout_panel:bottom()
			if not self._loadout_visible then
				y = 0
				self._loadout_visible = true
			else
				y = self._loadout_panel:h()
				self._loadout_visible = false
			end

			local text_id = self._loadout_visible and managers.localization:text("menu_button_hide") or managers.localization:text("menu_button_show")
			self._loadout_btn:set_text(utf8.to_upper(managers.localization:text("menu_team_loadout") .. ": " .. text_id))
			local _, _, w, _ = self._loadout_btn:text_rect()
			self._loadout_btn:set_w(w)
			self._loadout_btn:set_color(tweak_data.screen_color_grey)

			if managers.menu_component then
				if self._loadout_visible then
					managers.menu_component:hide_game_chat_gui()
				end
			end

			self._loadout_data:animate(callback(self, self, "_animate_move"), self._loadout_data:x(), y, false, callback(self, self, "finish_loadout_animation"))
		end
	end

	function ContractBoxGui:finish_loadout_animation()
		if alive(self._loadout_btn) then
			self._loadout_btn:set_color(tweak_data.screen_colors.button_stage_3)
		end

		if not self._loadout_visible and managers.menu_component then
			managers.menu_component:show_game_chat_gui()
		end
	end

	function ContractBoxGui:_animate_move(panel, x, y, instant, done_clbk)
		self._active_move = true
		if not instant then
			local move_speed = 1250
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

		if alive(panel) then
			panel:set_x(x)
			panel:set_y(y)
		end

		done_clbk()

		self._active_move = nil
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/missionbriefinggui" then
	core:import("CoreClass")

	TeamLoadoutCustom = TeamLoadoutCustom or class(MissionBriefingTabItem)

	function TeamLoadoutCustom:init(panel, text, i)
		TeamLoadoutCustom.super.init(self, panel, text, i)

		self._player_slots = {}
		local quarter_width = math.floor(self._panel:w() / 4)
		local total_x = 0
		for peer_id = 1, 4 do
			self._player_slots[peer_id] = LoadoutPanel:new(self._panel, self, peer_id, quarter_width, self._panel:h() + 7, {
				component_layout = { { "perk" }, { "skills" }, { "primary" }, { "secondary" }, { "melee_weapon", "grenade" }, { "armor", "mask" }, {"deployable", "secondary_deployable"} },
				--level = 	{ font_size = tweak_data.menu.pd2_medium_font_size * 0.9, height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "right", margin = 3 },
				skills = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.7, height = tweak_data.menu.pd2_small_font_size  * 0.75, align = "center" 			},
				perk = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.9, height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "left"  			},
				hide_names = true,
				margin = 5,
				borders = { 1, 1, 1, 1 }
			})

			local kit_menu = managers.menu:get_menu("kit_menu")
			if kit_menu then
				local kit_slot = kit_menu.renderer:get_player_slot_by_peer_id(peer_id)
				if kit_slot then
					local outfit = kit_slot.outfit
					local character = kit_slot.params and kit_slot.params.character
					if outfit and character then
						self:set_slot_outfit(peer_id, character, outfit)
					end
				end
			end
		end

		self:arrange_loadout_panels()
	end
	function TeamLoadoutCustom:reduce_to_small_font()
		TeamLoadoutCustom.super.reduce_to_small_font(self)

		self:arrange_loadout_panels()
	end
	function TeamLoadoutCustom:set_slot_outfit(slot, criminal_name, outfit)
		if self._player_slots[slot] then
			self._player_slots[slot]:set_outfit(outfit)
		end
	end

	function TeamLoadoutCustom:arrange_loadout_panels()
		local x = 0
		local width = math.floor(self._panel:w() / 4)
		for peer_id = 1, 4 do
			local panel = self._player_slots[peer_id]
			if panel and panel:enabled() then
				panel:set_x(x)
				panel:set_center_y(self._panel:h() / 2)
				x = x + panel:w()
			else
				x = x + width
			end
		end
	end

	-- Failsafe for unoverwritten functions...
	for id, ptr in pairs(TeamLoadoutItem) do
		if type(ptr) == "function" then
			TeamLoadoutCustom[id] = TeamLoadoutCustom[id] or function(self, ...)
				WolfHUD:print_log(string.format("TeamLoadoutCustom: Unoverwritten function call: %s", id), "warning")
			end
		end
	end

	CoreClass.override_class(TeamLoadoutItem, TeamLoadoutCustom)
elseif string.lower(RequiredScript) == "lib/setups/setup" then

	LoadoutBaseItem = LoadoutBaseItem or class()
	function LoadoutBaseItem:init(base_panel, owner, name, width, height, params)
		self._name = name
		self._owner_panel = base_panel
		self._owner = owner
		self._disable_reason = {}
		self._align = "right"
		self._margin = params.margin or 0

		self._panel = self._owner_panel:panel({
			name = name,
			h = (height or 0),
			w = (width or 0),
		})
	end

	function LoadoutBaseItem:destroy()
		self._panel:stop()
		self._owner_panel:remove(self._panel)
	end
	function LoadoutBaseItem:enabled()
		return next(self._disable_reason) == nil
	end

	function LoadoutBaseItem:set_enabled(reason, status)
		self._disable_reason[reason] = (not status) and true or nil

		local visible = next(self._disable_reason) == nil
		if self._panel:visible() ~= visible then
			self._panel:set_visible(visible)
			self._owner:arrange()
			return true
		end
	end

	function LoadoutBaseItem:set_size(w, h)
		w = w or self._panel:w()
		h = h or self._panel:h()

		if self._panel:w() ~= w or self._panel:h() ~= h then
			self._panel:set_size(w, h)
			return true
		end
	end

	function LoadoutBaseItem:set_w(w)
		return self:set_size(w, nil)
	end

	function LoadoutBaseItem:set_h(h)
		return self:set_size(nil, h)
	end

	function LoadoutBaseItem:arrange()

	end

	function LoadoutBaseItem:panel() return self._panel end
	function LoadoutBaseItem:alpha() return self._panel:alpha() end
	function LoadoutBaseItem:w() return self._panel:w() end
	function LoadoutBaseItem:h() return self._panel:h() end
	function LoadoutBaseItem:x() return self._panel:x() end
	function LoadoutBaseItem:y() return self._panel:y() end
	function LoadoutBaseItem:left() return self._panel:left() end
	function LoadoutBaseItem:right() return self._panel:right() end
	function LoadoutBaseItem:top() return self._panel:top() end
	function LoadoutBaseItem:bottom() return self._panel:bottom() end
	function LoadoutBaseItem:center() return self._panel:center() end
	function LoadoutBaseItem:center_x() return self._panel:center_x() end
	function LoadoutBaseItem:center_y() return self._panel:center_y() end
	function LoadoutBaseItem:visible() return self._panel:visible() end
	function LoadoutBaseItem:layer() return self._panel:layer() end
	function LoadoutBaseItem:text_rect() return self:x(), self:y(), self:w(), self:h() end

	function LoadoutBaseItem:set_alpha(v) self._panel:set_alpha(v) end
	function LoadoutBaseItem:set_x(v) self._panel:set_x(v) end
	function LoadoutBaseItem:set_y(v) self._panel:set_y(v) end
	function LoadoutBaseItem:set_left(v) self._panel:set_left(v) end
	function LoadoutBaseItem:set_right(v) self._panel:set_right(v) end
	function LoadoutBaseItem:set_top(v) self._panel:set_top(v) end
	function LoadoutBaseItem:set_bottom(v) self._panel:set_bottom(v) end
	function LoadoutBaseItem:set_center(x, y) self._panel:set_center(x, y) end
	function LoadoutBaseItem:set_center_x(v) self._panel:set_center_x(v) end
	function LoadoutBaseItem:set_center_y(v) self._panel:set_center_y(v) end
	function LoadoutBaseItem:set_layer(v) self._panel:set_layer(v) end

	LoadoutPanel = LoadoutPanel or class(LoadoutBaseItem)
	LoadoutPanel.NAME_TO_CLASS = {
		name 					= { class = "LoadoutNameItem", 			params = { font_size = tweak_data.menu.pd2_medium_font_size, 		height = tweak_data.menu.pd2_medium_font_size, margin = 0 } },
		level 					= { class = "LoadoutLevelItem", 		params = { font_size = tweak_data.menu.pd2_medium_font_size, 		height = tweak_data.menu.pd2_medium_font_size, margin = 0 } },
		character				= { class = "LoadoutCharacterItem", 	params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.9,  height = tweak_data.menu.pd2_medium_font_size, margin = 2 } },
		skills 					= { class = "LoadoutSkillsItem", 		params = { height = tweak_data.menu.pd2_small_font_size, 			margin = 2 } },
		perk 					= { class = "LoadoutPerkItem", 			params = { height = tweak_data.menu.pd2_small_font_size, 			margin = 2 } },
		primary 				= { class = "LoadoutWeaponItem", 	 	params = { margin = 2 } },
		secondary 				= { class = "LoadoutWeaponItem", 		params = { margin = 2 } },
		melee_weapon			= { class = "LoadoutMeleeItem", 	 	params = { margin = 2 } },
		grenade 				= { class = "LoadoutImageItem", 	 	params = { margin = 2 } },
		mask					= { class = "LoadoutMaskItem", 		 	params = { margin = 2 } },
		armor 					= { class = "LoadoutImageItem", 	 	params = { margin = 2 } },
		deployable 				= { class = "LoadoutDeployableItem", 	params = { margin = 2 } },
		secondary_deployable 	= { class = "LoadoutDeployableItem", 	params = { margin = 2 } },
	}
	function LoadoutPanel:init(base_panel, owner, peer_id, width, height, params)

		LoadoutPanel.super.init(self, base_panel, owner, string.format("Peer_%d", peer_id), width, height, params)

		self._peer_id = peer_id
		self._peer_color = tweak_data.chat_colors[peer_id]
		self._local_peer = not managers.network:session() or managers.network:session():local_peer():id() == peer_id

		-- Setup sub components
		self._components = {}
		self._component_layout = params.component_layout or { { "name" }, {"character"}, { "skills" }, { "perk" }, { "primary" }, { "secondary" }, { "melee_weapon", "grenade" }, { "armor", "mask" }, { "deployable", "secondary_deployable" } }

		local fixed_comp_h, fixed_comp_amnt = (2 * self._margin), 0
		for i, data in ipairs(self._component_layout) do
			if type(data) == "string" then
				data = { data }
			end

			local max_h = 0
			for i, name in ipairs(data) do
				local config = params[name] or self.NAME_TO_CLASS[name] and self.NAME_TO_CLASS[name].params or {}
				if config and config.height then
					max_h = math.max(max_h, (config.height or 0))
				end
			end

			if max_h > 0 then
				fixed_comp_h = fixed_comp_h + max_h
				fixed_comp_amnt = fixed_comp_amnt + 1
			end
		end

		local comp_w = (self._panel:w() - 2 * self._margin)
		local comp_h = (self._panel:h() - 2 * self._margin - math.ceil(fixed_comp_h)) / (table.size(self._component_layout) - fixed_comp_amnt)

		for i, data in ipairs(self._component_layout) do
			if type(data) == "string" then
				data = { data }
			end

			for i, name in ipairs(data) do
				local sub_comp_w = comp_w / #data
				local config = self.NAME_TO_CLASS[name]
				local class = config and config.class
				if class then
					local component_params = params[name] or config.params
					component_params.hide_name = component_params.hide_name ~= nil and component_params.hide_name or params.hide_names or false
					self._components[name] = _G[class]:new(self._panel, self, name, sub_comp_w, component_params and component_params.height or math.ceil(comp_h), component_params or {})
				end
			end
		end

		self:arrange()

		self._border_config = params.borders or {1, 1, 1 ,1}
		self._borders = BoxGuiObject:new(self._panel, {
			sides = self._border_config
		})

		if params.outfit then
			self:set_outfit(params.outfit)
		else
			self:set_enabled("active_components", false)
		end

		if self._components["name"] then
			self._components["name"]:set_color(self._peer_color)
		else
			if self._components["skills"] then
				self._components["skills"]:set_color(self._peer_color)
			end
			if self._components["perk"] then
				self._components["perk"]:set_color(self._peer_color)
			end
		end
		if self._components["level"] then
			self._components["level"]:set_color(self._peer_color)
		end
		if self._components["character"] then
			self._components["character"]:set_color(self._peer_color)
		end
	end

	function LoadoutPanel:set_enabled(reason, status)
		self._disable_reason[reason] = (not status) and true or nil

		local visible = next(self._disable_reason) == nil
		if self._panel:visible() ~= visible then
			self._panel:set_visible(visible)
			self._owner:arrange_loadout_panels()
			return true
		end
	end

	function LoadoutPanel:set_size(w, h)
		if LoadoutPanel.super.set_size(self, w, h) then
			if self._borders then
				self._borders:create_sides(self._panel, {
					sides = self._border_config
				})
			end
		end
	end

	function LoadoutPanel:arrange()
		local total_y = self._margin or 0
		local row_w = {}
		local active_comps = {}
		for i, data in ipairs(self._component_layout) do
			if type(data) == "string" then
				data = { data }
			end
			local x = self._margin or 0
			local max_h = 0
			active_comps[i] = 0
			for j, name in ipairs(data) do
				local component = self._components[name]
				if component:enabled() then
					component:set_x(x)
					component:set_y(total_y)
					x = x + component:w()
					max_h = math.max(max_h, component:h())
					active_comps[i] = active_comps[i] + 1
				end
			end
			row_w[i] = x
			total_y = total_y + max_h
		end

		for i, data in ipairs(self._component_layout) do
			if type(data) == "string" then
				data = { data }
			end

			local free_w = math.floor((self._panel:w() - row_w[i]) / active_comps[i])
			if free_w > 0 then
				local x = self._margin or 0
				for i, name in ipairs(data) do
					local component = self._components[name]
					if component:enabled() then
						component:set_x(x)
						if component:set_w(component:w() + free_w) then
							component:arrange()
						end
						x = x + component:w()
					end
				end
			end
		end

		if self:set_h(total_y + self._margin) then
			self._owner:arrange_loadout_panels()
		end

	end

	function LoadoutPanel:set_outfit(outfit)
		local enabled = false
		for name, component in pairs(self._components) do
			component:set_outfit(outfit or {})
			enabled = enabled or component:enabled()
		end

		self:set_enabled("active_components", enabled)
	end

	function LoadoutPanel:get_peer_id()
		return self._peer_id
	end

	function LoadoutPanel:get_peer()
		if managers.network:session() then
			return managers.network:session():peer(self._peer_id)
		end
	end

	function LoadoutPanel:local_peer()
		return self._local_peer
	end

	LoadoutTextItem = LoadoutTextItem or class(LoadoutBaseItem)
	function LoadoutTextItem:init(base_panel, owner, name, width, height, params)

		LoadoutTextItem.super.init(self, base_panel, owner, name, width, height, params)

		self._font_size = math.min(params.font_size or tweak_data.menu.pd2_medium_font_size, self._panel:h() - 2 * self._margin)
		self._loadout = ""

		self._text = self._panel:text({
			name = name,
			text = params.text or "",
			color = Color.white,
			align = params.align or "center",
			vertical = "center",
			x = self._margin,
			y = self._margin,
			w = self._panel:w() - 2 * self._margin,
			h = self._font_size,
			layer = 2,
			font_size = self._font_size * 0.95,
			font = tweak_data.menu.pd2_medium_font,
			blend_mode = "add",
		})
	end

	function LoadoutTextItem:arrange()
		self._text:set_x(self._margin)
		self._text:set_y(self._margin)
		self._text:set_w(self._panel:w() - 2 * self._margin)
		self._text:set_h(self._panel:h() - 2 * self._margin)
	end

	function LoadoutTextItem:set_text(text)
		if text then
			self._text:set_text(text)

			local _, _, actual_w, _ = self._text:text_rect()
			local new_font_size = math.min(self._text:font_size() * math.max(self._panel:w() - 2 * self._margin, 0.1) / actual_w, self._font_size * 0.95)
			self._text:set_font_size(new_font_size)
		end
	end

	function LoadoutTextItem:set_color(color)
		if color then
			self._text:set_color(color)
		end
	end

	function LoadoutTextItem:set_outfit(outfit)

	end

	LoadoutImageItem = LoadoutImageItem or class(LoadoutBaseItem)
	function LoadoutImageItem:init(base_panel, owner, name, width, height, params)

		LoadoutImageItem.super.init(self, base_panel, owner, name, width, height, params)

		self._hide_name = params.hide_name
		self._font_size = params.font_size or tweak_data.menu.pd2_small_font_size
		self._loadout = ""

		self._text = self._panel:text({
			name = name .. "_title",
			text = params.text or "",
			color = params.color or Color.white,
			align = "left",
			vertical = "center",
			h = self._font_size,
			layer = 3,
			font_size = self._font_size * 0.95,
			font = tweak_data.menu.pd2_medium_font,
			blend_mode = "add",
			visible = not self._hide_name,
		})
		self._text:set_top(self._margin)
		self._text:set_left(self._margin)

		self._icon = self._panel:bitmap({
			name = name .. "_icon",
			texture = params.texture,
			texture_rect = params.texture_rect,
			align = "center",
			valign = "scale",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h() - self._text:h(),
			visible = false,
			layer = 2,
		})

		self._amount_text = self._panel:text({
			name = name .. "_amount",
			text = "",
			w = self._panel:w() * 0.5,
			h = tweak_data.menu.pd2_small_font_size,
			font_size = tweak_data.menu.pd2_small_font_size * 0.9,
			font = tweak_data.menu.pd2_small_font,
			color = params.color or Color.white,
			blend_mode = "add",
			align = "right",
			vertical = "bottom",
			blend_mode = "add",
			layer = 3,
		})
		self._amount_text:set_right(self._panel:w() - self._margin)
		self._amount_text:set_bottom(self._panel:h() - self._margin)

		if params.amount then
			self:set_amount(params.text)
		end

		self:arrange()
	end

	function LoadoutImageItem:arrange()
		self._text:set_top(self._margin)
		self._text:set_left(self._margin)
		self._text:set_w(self._panel:w() - 2 * self._margin)

		local max_w, max_h = self._panel:w() - 2 * self._margin, (self._panel:h() - (self._text:visible() and self._text:h() or 0)) - 2 * self._margin
		local texture_w, texture_h = self._icon:texture_width() or 1, self._icon:texture_height() or 1

		local calc_w = max_h * (texture_w / texture_h)
		local calc_h = max_w * (texture_h / texture_w)

		if calc_w < max_w then
			self._icon:set_size(calc_w, max_h)
		else
			self._icon:set_size(max_w, calc_h)
		end

		self._icon:set_center_x(self._panel:w() / 2)
		self._icon:set_center_y(self._panel:h() / 2 + ((self._text:visible() and self._text:h() or 0) * 0.5))

		self._amount_text:set_right(self._panel:w() - self._margin)
		self._amount_text:set_bottom(self._panel:h() - self._margin)
	end

	function LoadoutImageItem:set_text(text)
		if text and self._text:visible() then
			self._text:set_text(text)

			local _, _, actual_w, _ = self._text:text_rect()
			local new_h = math.min(self._text:h() * math.max(self._panel:w() - 2 * self._margin, 0.1) / actual_w, self._font_size)
			self._text:set_font_size(new_h * 0.95)
		end
	end

	function LoadoutImageItem:set_color(color)
		if color then
			self._text:set_color(color)
			self._amount_text:set_color(color)
		end
	end

	function LoadoutImageItem:set_image(texture, text_rect)
		if texture then
			if text_rect then
				self._icon:set_image(texture, unpack(text_rect))
			else
				self._icon:set_image(texture)
			end

			self._icon:set_visible(true)
		else
			self._icon:set_visible(false)
		end
	end

	function LoadoutImageItem:set_amount(amount)
		if amount then
			local text = amount > 1 and string.format("x%d", amount) or ""
			self._amount_text:set_text(text)

			local _, _, actual_w, _ = self._amount_text:text_rect()
			local new_h = math.min(self._amount_text:h() * (math.max(self._panel:w() - 2 * self._margin, 0.1) / 3) / actual_w, tweak_data.menu.pd2_small_font_size)
			self._amount_text:set_h(new_h)
			self._amount_text:set_font_size(new_h * 0.9)
		end
	end

	function LoadoutImageItem:set_outfit(outfit)
		if outfit[self._name] then
			if self._loadout ~= outfit[self._name] then
				self:set_enabled("outfit", true)
				self._loadout = outfit[self._name]
				local texture, name = self:get_outfit_data(self._name, self._loadout)
				local amount = (self._name == "grenade") and tweak_data.blackmarket.projectiles[self._loadout] and tweak_data.blackmarket.projectiles[self._loadout].max_amount or 0

				self:set_text(name)
				self:set_image(texture)
				self:set_amount(amount)

				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	function LoadoutImageItem:get_outfit_data(type, id)
		local tweak_entry = {
			weapon_skin = tweak_data.blackmarket.weapon_skins,
			weapon = tweak_data.weapon,
			melee_weapon = tweak_data.blackmarket.melee_weapons,
			mask = tweak_data.blackmarket.masks,
			armor = tweak_data.blackmarket.armors,
			grenade = tweak_data.blackmarket.projectiles,
			deployables = tweak_data.blackmarket.deployables,
		}
		local texture_path = {
			weapon_skin = "weapon_skins/",
			weapon = "textures/pd2/blackmarket/icons/weapons/",
			melee_weapon = "textures/pd2/blackmarket/icons/melee_weapons/",
			mask = "textures/pd2/blackmarket/icons/masks/",
			armor = "textures/pd2/blackmarket/icons/armors/",
			grenade = "textures/pd2/blackmarket/icons/grenades/",
			deployables = "textures/pd2/blackmarket/icons/deployables/",
		}

		local bundle_folder = tweak_entry[type][id] and tweak_entry[type][id].texture_bundle_folder
		local guis_catalog = string.format("guis/%s", bundle_folder and string.format("dlcs/%s/", tostring(bundle_folder)) or "")
		local texture_name = tweak_entry[type][id] and tweak_entry[type][id].texture_name or tostring(id)
		local texture = string.format("%s%s%s", guis_catalog, texture_path[type], texture_name)

		local rarity_texture
		if type == "weapon_skin" then
			local rarity = tweak_entry[type][id] and tweak_entry[type][id].rarity
			rarity_texture = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture

			id = tweak_entry[type][id] and tweak_entry[type][id].weapon_id or id
			type = "weapon"
		end

		local name_id = tweak_entry[type][id] and tweak_entry[type][id].name_id or tostring(id)
		local name_text = managers.localization:text(name_id)

		return texture, name_text, rarity_texture
	end

	LoadoutNameItem = LoadoutNameItem or class(LoadoutTextItem)

	function LoadoutNameItem:init(base_panel, owner, name, width, height, params)

		LoadoutNameItem.super.init(self, base_panel, owner, name, width, height, params)

		self._show_level = not params.hide_level
	end

	function LoadoutNameItem:set_outfit(outfit)
		local peer = self._owner:get_peer()
		local peer_uid = peer and peer:user_id()
		if peer_uid then
			self:set_enabled("peer", true)
			if peer_uid ~= self._loadout then
				local name = peer:name()
				local level, infamy = self._owner:local_peer() and managers.experience:current_level() or peer:level(), self._owner:local_peer() and managers.experience:current_rank() or peer:rank()
				local level_str = string.format(" [%s%s]",
					(infamy or 0) > 0 and string.format("%s-", managers.experience:rank_string(infamy)) or "",
					tostring(level or 0)
				)
				self:set_text(string.format("%s%s", name, self._show_level and level_str or ""))

				if name and level then
					self._loadout = peer_uid
				end

				self:arrange()
			end
		else
			self:set_enabled("peer", false)
		end
	end

	LoadoutLevelItem = LoadoutLevelItem or class(LoadoutTextItem)

	function LoadoutLevelItem:set_outfit(outfit)
		local peer = self._owner:get_peer()
		local peer_uid = peer and peer:user_id()
		if peer_uid then
			self:set_enabled("peer", true)
			if peer_uid ~= self._loadout then
				local level, infamy = self._owner:local_peer() and managers.experience:current_level() or peer:level(), self._owner:local_peer() and managers.experience:current_rank() or peer:rank()
				local level_str = string.format(" [%s%s]",
					(infamy or 0) > 0 and string.format("%s-", managers.experience:rank_string(infamy)) or "",
					tostring(level or 0)
				)
				self:set_text(level_str or "")

				if level then
					self._loadout = peer_uid
				end

				self:arrange()
			end
		else
			self:set_enabled("peer", false)
		end
	end

	LoadoutCharacterItem = LoadoutCharacterItem or class(LoadoutTextItem)

	function LoadoutCharacterItem:set_outfit(outfit)
		local peer = self._owner:get_peer()
		if peer then
			local character = peer:character()
			self:set_enabled("peer", true)
			if character ~= self._loadout then
				self._loadout = character
				self:set_text(managers.localization:text("menu_" .. character))

				self:arrange()
			end
		else
			self:set_enabled("peer", false)
		end
	end

	LoadoutSkillsItem = LoadoutSkillsItem or class(LoadoutTextItem)
	function LoadoutSkillsItem:init(base_panel, owner, name, width, height, params)

		LoadoutSkillsItem.super.init(self, base_panel, owner, name, width, height, params)

		self._tree_names = {}

		for i, tree in ipairs(tweak_data.skilltree.skill_pages_order) do
			local tree = tweak_data.skilltree.skilltree[tree]
			if tree then
				table.insert(self._tree_names, tree.name_id and utf8.sub(managers.localization:text(tree.name_id), 1, 1) or "?")
			end
		end
	end

	function LoadoutSkillsItem:set_outfit(outfit)
		if outfit.skills and outfit.skills.skills then
			self:set_enabled("outfit", true)

			local skill_data = outfit.skills.skills
			local skill_str = json.encode(skill_data)
			if skill_data and skill_str ~= self._loadout then
				self._loadout = skill_str
				local subtree_amt = math.floor(#skill_data / #self._tree_names)
				local text = ""

				for tree = 1, #self._tree_names, 1 do
					local tree_has_points = false
					local tree_sum = 0

					for sub_tree = 1, subtree_amt, 1 do
						local skills = skill_data[(tree-1) * subtree_amt + sub_tree] or 0
						tree_sum = tree_sum + skills
					end
					text = string.format("%s%s:%02d ", text, self._tree_names[tree] or "?", tree_sum)
				end

				self:set_text(text)

				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	LoadoutPerkItem = LoadoutPerkItem or class(LoadoutTextItem)

	function LoadoutPerkItem:set_outfit(outfit)
		if outfit.skills and outfit.skills.specializations then
			self:set_enabled("outfit", true)
			local deck_index, deck_level = unpack(outfit.skills.specializations or {})
			local data = tweak_data.skilltree.specializations[tonumber(deck_index)]
			local name_id = data and data.name_id
			local deck_id = string.format("%s_%s", name_id or "", tostring(deck_level))
			if name_id and self._loadout ~= deck_id then
				self._loadout = deck_id
				local text = managers.localization:text(name_id)
				self:set_text(string.format("%s%s", text, tonumber(deck_level) < 9 and string.format(" (%d/9)", deck_level) or ""))

				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	LoadoutWeaponItem = LoadoutWeaponItem or class(LoadoutImageItem)
	function LoadoutWeaponItem:init(base_panel, owner, name, width, height, params)

		LoadoutWeaponItem.super.init(self, base_panel, owner, name, width, height, params)

		self._show_perks = (params.show_perks ~= false)
		self._perk_str = ""
		self._perks = {}

		self._rarity = self._panel:bitmap({
			name = name .. "_rarity",
			align = "center",
			valign = "scale",
			vertical = "center",
			w = self._panel:w(),
			h = self._panel:h() - self._text:h(),
			visible = false,
			blend_mode = "add",
			layer = 1,
		})
	end

	function LoadoutWeaponItem:arrange()
		LoadoutWeaponItem.super.arrange(self)

		if alive(self._rarity) then
			local max_w, max_h = self._panel:w() - 2 * self._margin, (self._panel:h() - (self._text:visible() and self._text:h() or 0)) - 2 * self._margin
			local texture_w, texture_h = self._rarity:texture_width() or 1, self._rarity:texture_height() or 1

			local calc_w = max_h * (texture_w / texture_h)
			local calc_h = max_w * (texture_h / texture_w)

			if calc_w < max_w then
				self._rarity:set_size(calc_w, max_h)
			else
				self._rarity:set_size(max_w, calc_h)
			end

			self._rarity:set_center_x(self._panel:w() / 2)
			self._rarity:set_center_y(self._panel:h() / 2 + ((self._text:visible() and self._text:h() or 0) * 0.5))
		end

		for i, perk in ipairs(self._perks or {}) do
			if alive(perk) and perk:visible() then
				perk:set_rightbottom(math.round(self._panel:w() - self._margin - ((i-1) * 16)), math.round(self._panel:h() - self._margin))
			end
		end
	end

	function LoadoutWeaponItem:set_outfit(outfit)
		if outfit[self._name] then
			local weapon_changed = self:update_weapon(outfit)
			local perks_changed = self:update_perks(outfit)

			if weapon_changed or perks_changed then
				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	function LoadoutWeaponItem:set_rarity(texture)
		if texture then
			self._rarity:set_image(texture)
			self._rarity:set_visible(true)
		else
			self._rarity:set_visible(false)
		end
	end

	function LoadoutWeaponItem:update_weapon(outfit)
		local weapon_id = outfit[self._name].cosmetics and outfit[self._name].cosmetics.id or managers.weapon_factory:get_weapon_id_by_factory_id(outfit[self._name].factory_id)
		if self._loadout ~= weapon_id then
			self:set_enabled("outfit", true)
			self._loadout = weapon_id
			local skinned = tweak_data.blackmarket.weapon_skins[self._loadout] and true
			local texture, name, rarity = self:get_outfit_data(skinned and "weapon_skin" or "weapon", self._loadout)

			self:set_text(name)
			self:set_image(texture)
			self:set_rarity(rarity)

			return true
		end
	end

	function LoadoutWeaponItem:update_perks(outfit)
		local perks = {}
		if outfit[self._name] and outfit[self._name].factory_id and outfit[self._name].blueprint then
			perks = managers.blackmarket:get_perks_from_weapon_blueprint(outfit[self._name].factory_id, outfit[self._name].blueprint)

			local factory = tweak_data.weapon.factory.parts
			local parts = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("bonus", outfit[self._name].factory_id, outfit[self._name].blueprint) or {}
			local stats, custom_stats, has_stat_boost, has_team_boost, has_stat, has_team
			for _, part_id in ipairs(parts) do
				stats = factory[part_id] and factory[part_id].stats or false
				custom_stats = factory[part_id] and factory[part_id].custom_stats or false
				has_stat_boost = stats and 1 < table.size(stats) and true or false
				has_team_boost = custom_stats and (custom_stats.exp_multiplier or custom_stats.money_multiplier and true) or false
				if has_stat_boost then
					perks.bonus_stats = stats
				end
				if has_team_boost then
					perks.bonus_team = custom_stats
				end
			end
			if outfit[self._name].cosmetics and outfit[self._name].cosmetics.bonus and not managers.job:is_current_job_competitive() then
				local bonus_data = tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[outfit[self._name].cosmetics.id].bonus]
				has_stat = bonus_data and bonus_data.stats and true or false
				has_team = bonus_data and (bonus_data.exp_multiplier or bonus_data.money_multiplier and true) or false
				if has_stat and not has_stat_boost then
					perks.bonus_stats = stats
				end
				if has_team and not has_team_boost then
					perks.bonus_team = custom_stats
				end
			end
		end

		local perk_str = ""
		for perk_name, _ in pairs(perks or {}) do
			perk_str = string.format("%s_%s", perk_str, perk_name)
		end

		if perk_str ~= self._perk_str then
			for i, perk in ipairs(self._perks or {}) do
				if alive(perk) then
					local parent = perk and perk:parent()
					if alive(parent) then
						parent:remove(perk)
					end
				end
			end
			self._perks = {}

			for perk in pairs(perks or {}) do
				if perk ~= "bonus" then
					local texture = "guis/textures/pd2/blackmarket/inv_mod_" .. perk
					if DB:has(Idstring("texture"), texture) then
						local perk_object = self._panel:bitmap({
							name = "perk_" .. tostring(perk),
							texture = texture,
							w = 16,
							h = 16,
							rotation = math.random(2) - 1.5,
							visible = self._show_perks,
							alpha = 0.8,
							layer = 3
						})
						table.insert(self._perks, perk_object)
					end
				end
			end

			self._perk_str = perk_str
			return true
		end
	end

	LoadoutMeleeItem = LoadoutMeleeItem or class(LoadoutImageItem)
	function LoadoutMeleeItem:init(base_panel, owner, name, width, height, params)

		LoadoutMeleeItem.super.init(self, base_panel, owner, name, width, height, params)

		local stock_img_height = (self._panel:h() - (self._text:visible() and self._text:h() or 0)) / 2

		local weapon_stock_1 = self._panel:bitmap({
			name = "weapon_stock_1",
			align = "center",
			valign = "scale",
			vertical = "center",
			w = self._panel:w(),
			h = stock_img_height,
			rotation = 15 + math.random(5),
			visible = false,
			layer = 1,
		})

		local weapon_stock_2 = self._panel:bitmap({
			name = "weapon_stock_2",
			align = "center",
			valign = "scale",
			vertical = "center",
			w = self._panel:w(),
			h = stock_img_height,
			rotation = 15 + math.random(5),
			visible = false,
			layer = 1,
		})
		self._weapon_stock = { weapon_stock_1, weapon_stock_2 }
	end

	function LoadoutMeleeItem:arrange()
		LoadoutMeleeItem.super.arrange(self)

		local y = (self._text:visible() and self._text:h() or 0)
		local max_w, max_h = self._panel:w() - 2 * self._margin, ((self._panel:h() - (self._text:visible() and self._text:h() or 0)) - 2 * self._margin) / 2
		for i, panel in ipairs(self._weapon_stock or {}) do
			if alive(panel) and panel:visible() then
				local texture_w, texture_h = panel:texture_width() or 1, panel:texture_height() or 1

				local calc_w = max_h * (texture_w / texture_h)
				local calc_h = max_w * (texture_h / texture_w)

				if calc_w < max_w then
					panel:set_size(calc_w, max_h)
				else
					panel:set_size(max_w, calc_h)
				end

				panel:set_center_x(self._panel:w() / 2)
				panel:set_y(y)
				y = y + max_h
			end
		end
	end

	function LoadoutMeleeItem:set_outfit(outfit)
		if outfit.melee_weapon then
			if outfit.melee_weapon == "weapon" then
				self:set_enabled("outfit", true)

				local loadout_id = outfit.melee_weapon
				local weapon_textures = {}
				for i, name in ipairs({"primary", "secondary"}) do
					local weapon_id = outfit[name].cosmetics and outfit[name].cosmetics.id or managers.weapon_factory:get_weapon_id_by_factory_id(outfit[name].factory_id)
					local skinned = tweak_data.blackmarket.weapon_skins[weapon_id] and true
					local texture, name, rarity = self:get_outfit_data(skinned and "weapon_skin" or "weapon", weapon_id)
					table.insert(weapon_textures, texture)
					loadout_id = string.format("%s_%s", loadout_id, weapon_id)
				end

				if loadout_id ~= self._loadout then
					self._loadout = loadout_id
					local _, name, _ = self:get_outfit_data("melee_weapon", outfit.melee_weapon)
					self:set_text(name)

					self:set_image(nil)
					for i, panel in ipairs(self._weapon_stock or {}) do
						if alive(panel) then
							local texture = weapon_textures[i]
							if texture then
								panel:set_image(texture)
								panel:set_visible(true)
							else
								panel:set_visible(false)
							end
						end
					end

					self:arrange()
				end
			else
				for i, panel in ipairs(self._weapon_stock or {}) do
					if alive(panel) then
						panel:set_visible(false)
					end
				end

				LoadoutMeleeItem.super.set_outfit(self, outfit)
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	LoadoutMaskItem = LoadoutMaskItem or class(LoadoutImageItem)

	function LoadoutMaskItem:set_outfit(outfit)
		if outfit.mask and outfit.mask.mask_id then
			if self._loadout ~= outfit.mask.mask_id then
				self:set_enabled("outfit", true)
				self._loadout = outfit.mask.mask_id
				local texture, name = self:get_outfit_data("mask", self._loadout)

				self:set_text(name)
				self:set_image(texture)

				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end
	end

	LoadoutDeployableItem = LoadoutDeployableItem or class(LoadoutImageItem)

	function LoadoutDeployableItem:set_outfit(outfit)
		if outfit[self._name] and tostring(outfit[self._name]) ~= "nil" and (self._name ~= "secondary_deployable" or (outfit.skills and outfit.skills.skills and tonumber(outfit.skills.skills[7]) >= 12)) then
			local deployable_id = outfit[self._name]
			if self._loadout ~= deployable_id then
				self:set_enabled("outfit", true)
				self._loadout = deployable_id
				local texture, name = self:get_outfit_data("deployables", self._loadout)

				self:set_text(name)
				self:set_image(texture)

				self:arrange()
			end
		else
			self:set_enabled("outfit", false)
		end

		local amount = outfit[string.format("%s_amount", self._name)]
		if amount and (not self._loadout_amount or self._loadout_amount ~= amount) then
			if self._name == "secondary_deployable" then
				amount = math.floor(amount / 2)
			end

			self:set_amount(amount)
		end
	end
end