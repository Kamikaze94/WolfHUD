-- CotractBoxGui suddenly sends empty outfit table...?
if string.lower(RequiredScript) == "lib/managers/menu/contractboxgui" then
	local init_original = ContractBoxGui.init
	local update_original = ContractBoxGui.update
	local update_character_menu_state_original = ContractBoxGui.update_character_menu_state
	local update_bg_state_original = ContractBoxGui.update_bg_state
	local mouse_wheel_up_original = ContractBoxGui.mouse_wheel_up
	local mouse_wheel_down_original = ContractBoxGui.mouse_wheel_down
	local mouse_pressed_original = ContractBoxGui.mouse_pressed
	local mouse_moved_original = ContractBoxGui.mouse_moved
	local set_enabled_original = ContractBoxGui.set_enabled

	ContractBoxGui._LOADOUT_W = 750
	ContractBoxGui._LOADOUT_H = 590

	function ContractBoxGui:init(...)
		init_original(self, ...)

		if managers.network:session() then
			self._peer_loadout = self._peer_loadout or {}
			self._loadout_enabled = true

			self._loadout_icon = self._loadout_icon or self._panel:bitmap({
				name = "toggle_loadout_icon",
				texture = "guis/textures/pd2/mouse_buttons",
				texture_rect = {35, 1, 17, 23},
				w = tweak_data.menu.pd2_small_font_size * 0.85,
				h = tweak_data.menu.pd2_small_font_size * 1.10,
			})
			self._loadout_icon:set_left(self._panel:left())
			self._loadout_icon:set_bottom(self._panel:bottom())

			self._loadout_btn = self._loadout_btn or self._panel:text({
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

			self._loadout_panel = self._loadout_panel or self._panel:panel({
				name = "crew_loadout",
				w = ContractBoxGui._LOADOUT_W,
				h = ContractBoxGui._LOADOUT_H,
				layer = _G.tweak_data.gui.CRIMENET_CHAT_LAYER + 5,
			})

			self._loadout_data = self._loadout_data or self._loadout_panel:panel({
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

			self._loadout_data:bitmap({
				texture = "guis/textures/test_blur_df",
				w = self._loadout_data:w(),
				h = self._loadout_data:h(),
				render_template = "VertexColorTexturedBlur3D",
				halign = "grow",
				valign = "grow",
				layer = -1,
				alpha = 1
			})

			self._borders = self._borders or BoxGuiObject:new(self._loadout_data, {
				sides = { 1, 1, 2, 2 }
			})

			self._loadout_panel:set_bottom(self._loadout_btn:top())
			self._loadout_panel:set_left(self._panel:left())

			self:populate_loadout_panel()
			self:set_loadout_enabled(WolfHUD:getSetting({"CrewLoadout", "SHOW_IN_LOBBY"}, true) and managers.menu:is_pc_controller())
		end
	end

	function ContractBoxGui:update(t, dt, ...)
		update_original(self, t, dt, ...)

		if self._loadout_visible then
			for _, panel in ipairs(self._peer_loadout) do
				if panel:enabled() then
					panel:update(t, dt)
				end
			end
		end
	end

	function ContractBoxGui:update_character_menu_state(peer_id, ...)
		update_character_menu_state_original(self, peer_id, ...)

		if self._peer_loadout[peer_id] then
			self:update_loadout_panel(peer_id)
		end
	end

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
		if self:can_take_input() and self._enabled and not self._loadout_visible and not self._active_move then
			self:toggle_loadout()
		end

		mouse_wheel_up_original(self, ...)
	end

	function ContractBoxGui:mouse_wheel_down(...)
		if self:can_take_input() and self._enabled and self._loadout_visible and not self._active_move then
			self:toggle_loadout()
		end

		mouse_wheel_down_original(self, ...)
	end

	function ContractBoxGui:mouse_pressed(button, x, y, ...)
		if self:can_take_input() and self._enabled and alive(self._loadout_btn) and button == Idstring("0") and self._loadout_btn:inside(x, y) and not self._active_move then
			self:toggle_loadout()
		elseif self._loadout_visible then

		else
			return mouse_pressed_original(self, button, x, y, ...)
		end
	end

	function ContractBoxGui:mouse_moved(x, y, ...)
		if self._loadout_enabled then
			if self:can_take_input() and alive(self._loadout_btn) and not self._active_move then
				if self._loadout_btn:inside(x, y) then
					if not self._loadout_btn_highlighted and self._enabled then
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
		end

		if not self._loadout_visible then
			return mouse_moved_original(self, x, y, ...)
		end

		return true, "arrow"
	end

	function ContractBoxGui:set_enabled(...)
		set_enabled_original(self, ...)

		self:set_loadout_enabled(self._enabled and WolfHUD:getSetting({"CrewLoadout", "SHOW_IN_LOBBY"}, true) and managers.menu:is_pc_controller())
	end

	function ContractBoxGui:set_loadout_enabled(status)
		if self._loadout_enabled ~= status then
			if self._loadout_visible and not status then
				self:toggle_loadout(true)
			end
			if alive(self._loadout_btn) then
				self._loadout_btn:set_visible(status)
			end
			if alive(self._loadout_icon) then
				self._loadout_icon:set_visible(status)
			end
			self._loadout_enabled = status
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
				self._peer_loadout[peer_id] = LoadoutPanel:new(self._loadout_data, self, peer_id, width, ContractBoxGui._LOADOUT_H + 8, {
					component_layout = WolfHUD:getTweakEntry("STD_LOBBY_LOADOUT_LAYOUT", "table",
						{
							{ "playtime", "ping" },
							{ "name" },
							{ "character" },
							{ "skills" },
							{ "perk" },
							{ "primary" },
							{ "secondary" },
							{ "melee_weapon" },
							{ "grenade", "armor" },
							{ "deployable", "secondary_deployable" }
						}),
					name = 		{ alpha = 1, use_peer_color = true },
					character = { alpha = 1, use_peer_color = true },
					default = 	{ alpha = 0.9 },
					margin = 5,
					borders = {1, 1, 1, 1}
				})
			end
		end
		self:arrange_loadout_panels()
	end

	function ContractBoxGui:update_loadout_panel(peer_id)
		local panel = self._peer_loadout[peer_id]
		if panel then
			local outfit
			if panel:local_peer() then
				outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
			else
				local peer = managers.network:session():peer(peer_id)
				outfit = peer and peer:blackmarket_outfit()
			end
			panel:set_outfit(outfit)
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
				max_h = math.max(max_h, math.ceil(panel:h()))
			end
			x = x + width
		end
	end

	function ContractBoxGui:toggle_loadout(instant)
		if alive(self._loadout_panel) and alive(self._loadout_btn) then
			local y = self._loadout_panel:bottom()
			if self._loadout_enabled and not self._loadout_visible then
				y = 0
				self._loadout_visible = true
			elseif self._loadout_enabled then
				y = self._loadout_panel:h()
				self._loadout_visible = false
			else
				return
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

			self._loadout_data:animate(callback(self, self, "_animate_move"), self._loadout_data:x(), y, instant or false, callback(self, self, "finish_loadout_animation"))
		end
	end

	function ContractBoxGui:finish_loadout_animation()
		if alive(self._loadout_btn) then
			self._loadout_btn:set_color(self._loadout_btn_highlighted and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
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
elseif string.lower(RequiredScript) == "lib/managers/menu/crimespreedetailsmenucomponent" then
	local populate_tabs_data_original = CrimeSpreeDetailsMenuComponent.populate_tabs_data
	local _add_panels_original = CrimeSpreeDetailsMenuComponent._add_panels
	local update_original = CrimeSpreeDetailsMenuComponent.update
	CrimeSpreeDetailsMenuComponent._LOADOUT_INDEX = 2
	function CrimeSpreeDetailsMenuComponent:populate_tabs_data(tabs_data, ...)
		populate_tabs_data_original(self, tabs_data, ...)

		if not self:_is_in_preplanning() and not Global.game_settings.single_player and WolfHUD:getSetting({"CrewLoadout", "SHOW_IN_CS_LOBBY"}, true) then
			table.insert(tabs_data, CrimeSpreeDetailsMenuComponent._LOADOUT_INDEX, {
				name_id = "menu_team_loadout",
				page_class = "CrimeSpreeCrewLoadoutPage",
				width_multiplier = 1
			})
		end

		if not self:_is_in_game() then
			table.insert(tabs_data, {
				name_id = "menu_button_hide",
				page_class = "CrimeSpreeEmptyPage",
				width_multiplier = 1
			})
		end
	end

	function CrimeSpreeDetailsMenuComponent:_add_panels(...)
		_add_panels_original(self, ...)
		if alive(self._tabs_panel) and alive(self._tabs_scroll_panel) then
			self._tabs_panel:set_w(self._panel:w())
			self._tabs_scroll_panel:set_w(self._panel:w())
		end
	end

	function CrimeSpreeDetailsMenuComponent:update(t, dt, ...)
		update_original(self, t, dt, ...)

		if WolfHUD:getSetting({"CrewLoadout", "SHOW_IN_CS_LOBBY"}, true) then
			for _, data in ipairs(self._tabs) do
				if data.tab._index == CrimeSpreeDetailsMenuComponent._LOADOUT_INDEX then
					data.page:update(t, dt)
				end
			end
		end
	end

	CrimeSpreeEmptyPage = CrimeSpreeEmptyPage or class(CrimeSpreeDetailsPage)

	CrimeSpreeCrewLoadoutPage = CrimeSpreeCrewLoadoutPage or class(CrimeSpreeDetailsPage)

	function CrimeSpreeCrewLoadoutPage:init(...)
		CrimeSpreeCrewLoadoutPage.super.init(self, ...)

		self._loadout_data = self:panel():panel({
			name = "crew_loadout",
			w = self:panel():w(),
			h = 240,
		})

		self._loadout_data:rect({
			color = Color(0.6, 0, 0, 0),
			layer = -1,
			halign = "grow",
			valign = "grow"
		})

		self._loadout_data:bitmap({
			texture = "guis/textures/test_blur_df",
			w = self._loadout_data:w(),
			h = self._loadout_data:h(),
			render_template = "VertexColorTexturedBlur3D",
			halign = "scale",
			valign = "scale",
			layer = -1,
			alpha = 1
		})

		self._borders = BoxGuiObject:new(self._loadout_data, {
			sides = { 1, 1, 2, 1 }
		})

		self._peer_loadout = self._peer_loadout or {}
		self._next_loadout_update_t = self._next_loadout_update_t or {}
		self:populate_loadout_panel()
	end

	function CrimeSpreeCrewLoadoutPage:update(t, dt, ...)
		if self._active then
			for _, panel in ipairs(self._peer_loadout or {}) do
				if panel:enabled() then
					panel:update(t, dt)
				end

				local peer_id = panel:get_peer_id()
				if (self._next_loadout_update_t[peer_id] or 0) <= t then
					self:update_loadout_panel(peer_id)
					self._next_loadout_update_t[peer_id] = t + 3
				end
			end
		end
	end

	function CrimeSpreeCrewLoadoutPage:populate_loadout_panel()
		for peer_id, panel in ipairs(self._peer_loadout or {}) do
			if panel then
				panel:destroy()
				self._peer_loadout[peer_id] = nil
			end
		end

		local width = math.floor(self._loadout_data:w() / 4)
		for i, peer_id in ipairs({3, 2, 1, 4}) do
			if not self._peer_loadout[peer_id] then
				self._peer_loadout[peer_id] = LoadoutPanel:new(self._loadout_data, self, peer_id, width, math.floor(self._loadout_data:h() + 9), {
					component_layout = WolfHUD:getTweakEntry("CS_LOBBY_LOADOUT_LAYOUT", "table",
						{
							{ "playtime", "ping" },
							{ "name" },
							{ "skills" },
							{ "perk" },
							{ "primary", "secondary" },
							{ "grenade", "armor" },
							{ "deployable", "secondary_deployable" }
						}),
					name = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.95, height = tweak_data.menu.pd2_medium_font_size * 1.00, align = "center", margin = 3, use_peer_color = true, alpha = 1 },
					level = 	{ font_size = tweak_data.menu.pd2_medium_font_size * 0.9,  height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "right",  margin = 3, use_peer_color = true, alpha = 1 },
					skills = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.7,  height = tweak_data.menu.pd2_small_font_size  * 0.75, align = "center", use_peer_color = true, alpha = 0.95 },
					perk = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.7,  height = tweak_data.menu.pd2_medium_font_size * 0.75, align = "center", use_peer_color = true, alpha = 0.95 },
					ping = 		{ font_size = tweak_data.menu.pd2_small_font_size  * 0.75, height = tweak_data.menu.pd2_small_font_size  * 0.8,  align = "right",  alpha = 1 	},
					playtime = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.7,  height = tweak_data.menu.pd2_small_font_size  * 0.75, align = "center", alpha = 1 	},
					default = 	{ hide_name = true, alpha = 0.9 },
					margin = 5,
					borders = { 1, 1, 1, 1 }
				})
			end
		end
		self:arrange_loadout_panels()
	end

	function CrimeSpreeCrewLoadoutPage:update_loadout_panel(peer_id)
		local panel = self._peer_loadout[peer_id]
		if panel then
			local outfit
			if panel:local_peer() then
				outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
			else
				local peer = managers.network:session():peer(peer_id)
				outfit = peer and peer:blackmarket_outfit()
			end
			panel:set_outfit(outfit)
		end
	end

	function CrimeSpreeCrewLoadoutPage:arrange_loadout_panels()
		local x = 0
		local width = math.floor(self._loadout_data:w() / 4)
		for i, peer_id in ipairs({3, 2, 1, 4}) do
			local panel = self._peer_loadout[peer_id]
			if panel and panel:enabled() then
				panel:set_x(x)
				--panel:set_w(width)
			end
			x = x + width
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/missionbriefinggui" then
	TeamLoadoutCustom = TeamLoadoutCustom or class(MissionBriefingTabItem)

	function TeamLoadoutCustom:init(panel, text, i)
		TeamLoadoutCustom.super.init(self, panel, text, i)

		self._player_slots = {}
		local quarter_width = math.floor(self._panel:w() / 4)
		for peer_id = 1, 4 do
			self._player_slots[peer_id] = LoadoutPanel:new(self._panel, self, peer_id, quarter_width, self._panel:h() + 7, {
				component_layout = WolfHUD:getTweakEntry("BRIEFING_LOADOUT_LAYOUT", "table",
					{
						{ "perk" },
						{ "skills" },
						{ "primary" },
						{ "secondary" },
						{ "melee_weapon", "grenade" },
						{ "armor", "mask" },
						{ "deployable", "secondary_deployable" }
					}),
				name = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.95, height = tweak_data.menu.pd2_medium_font_size * 1.00, align = "center", margin = 3, use_peer_color = true },
				level = 	{ font_size = tweak_data.menu.pd2_medium_font_size * 0.9,  height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "right",  margin = 3, use_peer_color = true },
				skills = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.9,  height = tweak_data.menu.pd2_small_font_size  * 0.95, align = "center", use_peer_color = true },
				perk = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.9,  height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "left",   use_peer_color = true },
				ping = 		{ font_size = tweak_data.menu.pd2_small_font_size  * 0.75, height = tweak_data.menu.pd2_small_font_size  * 0.8,  align = "right" 	},
				playtime = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.7,  height = tweak_data.menu.pd2_small_font_size  * 0.75, align = "center" 	},
				default = 	{ hide_name = true },
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

	function TeamLoadoutCustom:update(t, dt)
		for _, panel in ipairs(self._player_slots) do
			if panel:enabled() then
				panel:update(t, dt)
			end
		end
	end

	function TeamLoadoutCustom:arrange_loadout_panels()
		local x = 0
		local width = math.floor(self._panel:w() / 4)
		for peer_id = 1, 4 do
			local panel = self._player_slots[peer_id]
			if panel and panel:enabled() then
				panel:set_x(x)
				--panel:set_center_y(self._panel:h() / 2)
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
	if CoreClass and WolfHUD:getSetting({"CrewLoadout", "REPLACE_IN_BRIEFING"}, true) then
		CoreClass.override_class(TeamLoadoutItem, TeamLoadoutCustom)
	end

	local BriefingGUI_update = MissionBriefingGui.update
	function MissionBriefingGui:update(t, dt, ...)
		BriefingGUI_update(self, t, dt, ...)

		if self._team_loadout_item and self._team_loadout_item.update then
			self._team_loadout_item:update(t, dt)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/hud/newhudstatsscreen" then
	local recreate_right_original = HUDStatsScreen.recreate_right
	local show_original = HUDStatsScreen.show
	local hide_original = HUDStatsScreen.hide
	local update_original = HUDStatsScreen.update

	HUDStatsScreen._LOADOUT_H = 215
	function HUDStatsScreen:recreate_right(...)
		self:_destroy_player_info()
		
		recreate_right_original(self, ...)
		
		self:_create_player_info()
	end

	function HUDStatsScreen:_create_player_info()
		self._USING_CREW_LOADOUT = WolfHUD:getSetting({"CrewLoadout", "SHOW_ON_STATS_PANEL"}, true) and not (_G.LobbyPlayerInfo and LobbyPlayerInfo.settings.show_skills_in_stats_screen)
		if self._USING_CREW_LOADOUT then
			if alive(self._right) and not self._loadout_data then
				self._loadout_data = self._right:panel({
					name = "crew_loadout",
					w = self._right:w() - 20,
					h = HUDStatsScreen._LOADOUT_H,
					visible = true
				})

				self._peer_loadout = self._peer_loadout or {}
				self:populate_loadout_panel(self._loadout_data)
				
				for peer_id = 1, 4  do
					self:update_loadout_panel(peer_id)
				end
			end
		end
	end

	function HUDStatsScreen:_destroy_player_info()
		if self._loadout_data then
			for _, panel in ipairs(self._peer_loadout or {}) do
				if not panel:destroyed() then
					panel:destroy()
				end
			end

			self._right:remove(self._loadout_data)
			self._loadout_data = nil
		end
	end

	function HUDStatsScreen:update(t, dt, ...)
		if self._USING_CREW_LOADOUT and table.size(self._peer_loadout or {}) > 0 then
			for peer_id = 1, 4 do
				if self._peer_loadout[peer_id] and not self._peer_loadout[peer_id]:destroyed() then
					self._peer_loadout[peer_id]:update(t, dt)
				end
			end
		end
		
		return update_original(self, t, dt, ...)
	end

	function HUDStatsScreen:populate_loadout_panel(parent_panel)
		for peer_id, panel in ipairs(self._peer_loadout or {}) do
			if panel then
				panel:destroy()
				self._peer_loadout[peer_id] = nil
			end
		end

		if parent_panel then
			local width = math.floor(self._loadout_data:w() / 2)
			for peer_id = 1, 4  do
				if not self._peer_loadout[peer_id] then
					self._peer_loadout[peer_id] = LoadoutPanel:new(parent_panel, self, peer_id, parent_panel:w(), parent_panel:h() * 0.17, {
						component_layout = WolfHUD:getTweakEntry("TAB_LOADOUT_LAYOUT", "table",
							{
								{ "name", "ping" },
								{ "skills", "perk" },
							}),
						name = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.90, height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "left",  margin = 0, use_peer_color = true },
						level = 	{ font_size = tweak_data.menu.pd2_medium_font_size * 0.90, height = tweak_data.menu.pd2_medium_font_size * 0.95, align = "left",  margin = 0, use_peer_color = true },
						skills = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 1.10, height = tweak_data.menu.pd2_small_font_size  * 1.15, align = "left",  margin = 3 },
						perk = 		{ font_size = tweak_data.menu.pd2_medium_font_size * 0.95, height = tweak_data.menu.pd2_medium_font_size * 1.00, align = "left",  margin = 3 },
						ping = 		{ font_size = tweak_data.menu.pd2_small_font_size  * 0.75, height = tweak_data.menu.pd2_small_font_size  * 0.80, align = "right" 			 },
						playtime = 	{ font_size = tweak_data.menu.pd2_small_font_size  * 0.75, height = tweak_data.menu.pd2_small_font_size  * 0.80, align = "left" 			 },
						default = 	{ hide_name = true },
						margin = 5,
						borders = { 0, 0, 0, 2 }
					})
				end
			end
			self:arrange_loadout_panels(parent_panel)
		end
	end

	function HUDStatsScreen:update_loadout_panel(peer_id)
		if self._peer_loadout[peer_id] and not self._peer_loadout[peer_id]:destroyed() then
			local outfit
			if self._peer_loadout[peer_id]:local_peer() then
				outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
			else
				local peer = managers.network:session():peer(peer_id)
				outfit = peer and peer:blackmarket_outfit()
			end
			self._peer_loadout[peer_id]:set_outfit(outfit)
		end
	end

	function HUDStatsScreen:arrange_loadout_panels(parent_panel)
		if parent_panel then
			local y = parent_panel:h()
			local height = math.floor(parent_panel:h() * 0.17)
			for peer_id = 4, 1, -1 do
				local panel = self._peer_loadout[peer_id]
				if panel and panel:enabled() and not panel:destroyed() then
					y = y - panel:h() - (parent_panel:h() * 0.08)
					panel:set_y(y)
				end
			end
			parent_panel:set_leftbottom(10, self._right:h() - (WolfHUD:getSetting({"TabStats", "ENABLED"}, true) and 10 or 40))
		end
	end
end