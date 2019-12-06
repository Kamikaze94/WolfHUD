local PROFILE_MENU_ID = "wolfhud_profile_switch_node_menu"

if RequiredScript == "lib/managers/menumanager" then
	local function create_profile_menu_node(nodes, menu_id)
		local arugements = {
			gui_class = "MenuNodeProfileSwitchGui",
			help_id = "menu_skill_switch_help",
			menu_components = nodes.kit and "mission_briefing" or managers.menu:is_pc_controller() and "inventory" or "",
			modifier = "ProfileSwitchInitiator",
			name = PROFILE_MENU_ID,
			no_item_parent = false,
			no_menu_wrapper = true,
			refresh = "ProfileSwitchInitiator",
			scene_state = "inventory", --"standard",
			sync_state = "inventory",
			topic_id = "menu_inventory",
			--back_callback = "profile_menu_back",
			{
				["_meta"] = "legend",
				["name"] = "menu_legend_select"
			},
			{
				["_meta"] = "legend",
				["name"] = "menu_legend_back"
			},
		}

		local node_class = CoreSerialize.string_to_classtable("MenuNodeTable")
		if node_class then
			nodes[menu_id] = node_class:new(arugements)

			local callback_handler = CoreSerialize.string_to_classtable("MenuCallbackHandler")
			if callback_handler then
				nodes[menu_id]:set_callback_handler(callback_handler:new())
			end
		end
	end

	Hooks:Add("MenuManagerBuildCustomMenus", "WolfHUD_MenuManager_BuildProfileMenu", function( menu_manager, nodes )
		if nodes.main and not nodes[PROFILE_MENU_ID]then
			create_profile_menu_node(nodes, PROFILE_MENU_ID)
		end
	end)

	local LobbyOptionInitiator_modify_node_orig = LobbyOptionInitiator.modify_node
	function LobbyOptionInitiator:modify_node(node, ...)
		local active_menu = managers.menu:active_menu()
		local briefing_nodes = active_menu and active_menu.logic and active_menu.logic._data._nodes
		if briefing_nodes and briefing_nodes.kit and not briefing_nodes[PROFILE_MENU_ID] then
			create_profile_menu_node(briefing_nodes, PROFILE_MENU_ID, true)
		end
		return LobbyOptionInitiator_modify_node_orig(self, node, ...)
	end

	ProfileSwitchInitiator = ProfileSwitchInitiator or class(SkillSwitchInitiator)
	function ProfileSwitchInitiator:modify_node(node, data)
		node:clean_items()
		self:create_divider(node, "title", "wolfhud_profile_switch_title_profiles", nil, tweak_data.screen_colors.text)
		local mpm = managers.multi_profile
		for i = 1, mpm:profile_count() do
			local profile = mpm:profile(i)
			if profile then
				local hightlight_color, row_item_color, callback
				if (i == mpm:current_profile_id()) then
					hightlight_color = tweak_data.screen_colors.text
					row_item_color = tweak_data.screen_colors.text
					callback = "menu_back"
				else
					hightlight_color = tweak_data.screen_colors.button_stage_2
					row_item_color = tweak_data.screen_colors.button_stage_3
					callback = "profile_menu_switch"
				end

				self:create_item(node, {
					name = i,
					text_id = profile.name or string.format("Profile %d", i),
					enabled = true,
					localize = false,
					callback = callback,
					hightlight_color = hightlight_color,
					row_item_color = row_item_color,
					disabled_color = row_item_color,
				})
			end
		end
		self:create_divider(node, "back_div")
		self:add_back_button(node)
		node:set_default_item_name(1)
		return node
	end

	function MenuCallbackHandler:profile_menu_switch(item)
		local mpm = managers.multi_profile
		local profile_id = item:parameters().name
		if mpm and mpm:is_valid_id(profile_id) then
			mpm:set_current_profile(profile_id)
		end

		self:refresh_node()
	end
elseif RequiredScript == "lib/managers/menu/renderers/menunodeskillswitchgui" then
	MenuNodeProfileSwitchGui = MenuNodeProfileSwitchGui or class(MenuNodeSkillSwitchGui)
	MenuNodeProfileSwitchGui.SKILL_POINTS_X = 0.24
	MenuNodeProfileSwitchGui.STATUS_X = 0.52
	MenuNodeProfileSwitchGui.PROFILE_PREVIEW_W = 195

	function MenuNodeProfileSwitchGui:_setup_item_panel(...)
		MenuNodeProfileSwitchGui.super._setup_item_panel(self, ...)

		if alive(self.title_text) then
			self.title_text:set_text(managers.localization:to_upper_text("wolfhud_profile_switch_title"))
		end

		local ws_panel = self.item_panel:parent()
		if alive(ws_panel) then
			ws_panel:bitmap({
				texture = "guis/textures/test_blur_df",
				w = ws_panel:w(),
				h = ws_panel:h(),
				render_template = "VertexColorTexturedBlur3D",
				halign = "scale",
				valign = "scale",
				layer = 50,
				alpha = 1
			})
		end

		if alive(self.item_panel) and LoadoutPanel then
			local offset_h = managers.menu:is_pc_controller() and 25 or 0
			self.profile_preview = LoadoutPanel:new(self.item_panel:parent(), self, 0, self.PROFILE_PREVIEW_W, math.floor(self.item_panel:h()) - offset_h, {
				component_layout = {
					{ "skills" },
					{ "perk" },
					{ "primary", "secondary" },
					{ "grenade", "armor" },
					{ "deployable", "secondary_deployable" }
				},
				default =     { alpha = 0.9 },
				margin = 5,
				borders = { 1, 1, 1, 1 },
				layer = 53,
			})
			local outfit = managers.multi_profile:get_profile_outfit(managers.multi_profile:current_profile_id())
			self.profile_preview:set_outfit(outfit)
		end
	end

	function MenuNodeProfileSwitchGui:_create_menu_item(row_item, ...)
		MenuNodeProfileSwitchGui.super._create_menu_item(self, row_item, ...)
		if row_item.type ~= "divider" and row_item.name ~= "back" then
			local mpm = managers.multi_profile
			local profile_id = row_item.name
			local profile = mpm:profile(profile_id)
			local skill_name, perk_name = "", ""

			skill_name = profile.skillset and managers.skilltree:get_skill_switch_name(profile.skillset, false) or managers.localization:to_upper_text("menu_st_locked_skill_switch")
			if profile.perk_deck then
				local data = tweak_data.skilltree.specializations[tonumber(profile.perk_deck)]
				local name_id = data and data.name_id
				perk_name = managers.localization:to_upper_text(name_id)
			end

			if alive(row_item.skill_points_gui) then
				row_item.skill_points_gui:set_text(utf8.to_upper(skill_name))
                row_item.skill_points_gui:set_alpha(1)
			end
			if alive(row_item.status_gui) then
				row_item.status_gui:set_text(perk_name)
			end
            row_item.distribution_after_text = false
		elseif row_item.type == "divider" and row_item.name == "divider_title" then

			if alive(row_item.skill_points_gui) then
				row_item.skill_points_gui:set_text(string.format("%s-%s", managers.localization:to_upper_text("menu_st_skilltree", {}), managers.localization:to_upper_text("menu_st_skill_switch_title_name", {})))
				row_item.skill_points_gui:show()
			end
			if alive(row_item.status_gui) then
				row_item.status_gui:set_text(managers.localization:to_upper_text("menu_specialization", {}) .. ":")
			end
		end
	end

	function MenuNodeProfileSwitchGui:arrange_loadout_panels()
		if self.profile_preview then
			self.profile_preview:set_top(self.item_panel:top())
			self.profile_preview:set_right(self.item_panel:right())
		end
	end

	function MenuNodeProfileSwitchGui:_highlight_row_item(row_item, mouse_over, ...)
		MenuNodeProfileSwitchGui.super._highlight_row_item(self, row_item, mouse_over, ...)

		local mpm = managers.multi_profile
		local profile_id = row_item.name and mpm:is_valid_id(row_item.name) and row_item.name or mpm:current_profile_id()
		self:change_outfit_preview(profile_id)
	end

	function MenuNodeProfileSwitchGui:_align_marker(row_item, ...)
		MenuNodeProfileSwitchGui.super._align_marker(self, row_item, ...)

		if self.profile_preview then
			if row_item.name ~= "back" then
				self._marker_data.marker:set_w(self.item_panel:w() - self.profile_preview:w() - 10)
			else
				self._marker_data.marker:set_w(self.profile_preview:w())
				self._marker_data.marker:set_right(self.item_panel:w())
			end
		end
	end

	function MenuNodeProfileSwitchGui:_clear_gui(...)
		if self.profile_preview then
			self.profile_preview:destroy()
		end

		MenuNodeProfileSwitchGui.super._clear_gui(self, ...)
	end

	function MenuNodeProfileSwitchGui:mouse_moved(o, x, y, ...)
		local used, icon = MenuNodeProfileSwitchGui.super.mouse_moved(self, o, x, y, ...)
		return true, icon
	end

	function MenuNodeProfileSwitchGui:change_outfit_preview(profile_id)
		local mpm = managers.multi_profile
		if self.profile_preview and mpm:is_valid_id(profile_id) and (self._previewing_outfit or 0) ~= profile_id then
			local outfit = mpm:get_profile_outfit(profile_id)
			self.profile_preview:set_outfit(outfit)
			self._previewing_outfit = profile_id
		end
	end
elseif RequiredScript == "lib/managers/multiprofilemanager" then
    local open_quick_select_original = MultiProfileManager.open_quick_select
    function MultiProfileManager:open_quick_select(...)
        if WolfHUD:getSetting({"CrewLoadout", "REPLACE_PROFILE_MENU"}, true) then
            managers.menu:open_node(PROFILE_MENU_ID, {})
        else
            open_quick_select_original(self, ...)
        end
    end


	function MultiProfileManager:current_profile_id()
		return self._global._current_profile or 1
	end

	function MultiProfileManager:is_valid_id(profile_id)
		return profile_id and type(profile_id) == "number" and profile_id > 0 and profile_id <= self:profile_count() and true or false
	end

	function MultiProfileManager:get_profile_outfit(profile_id)
		if profile_id ~= self:current_profile_id() then
			local profile = self:profile(profile_id)
			local gd = Global.skilltree_manager.skill_switches[profile.skillset]
			local skills = {}
			if gd.trees then
				local pts = 0
				for i=1, #gd.trees do
					pts=Application:digest_value(gd.trees[i].points_spent, false)
					table.insert(skills, pts)
				end
			end
			local outfit = {
				skills = {
					skills = skills,
					specializations = { profile.perk_deck, 9 },
				},
				primary = self:get_item_data("primaries", profile.primary),
				secondary = self:get_item_data("secondaries", profile.secondary),
				melee_weapon = profile.melee,
				grenade = profile.throwable,
				armor = profile.armor,
				armor_skin = profile.armor_skin,
				mask = self:get_item_data("mask", profile.mask),
				player_style = profile.player_style or managers.blackmarket:get_default_player_style(),
				suit_variations = (profile.suit_variations or {}),
				deployable = profile.deployable,
				secondary_deployable = profile.deployable_secondary,
				deployable_amount = self:get_deployable_amount(profile.deployable, gd.skills),
				secondary_deployable_amount = self:get_deployable_amount(profile.deployable_secondary, gd.skills),
			}
			return outfit
		else
			local outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
			return outfit
		end
	end

	function MultiProfileManager:get_item_data(category, slot)
		if not Global.blackmarket_manager.crafted_items[category] then
			return nil
		end
		if not Global.blackmarket_manager.crafted_items[category][slot] then
			slot = 1
		end
		local item_data = Global.blackmarket_manager.crafted_items[category][slot]
		return item_data or {}
	end

	function MultiProfileManager:get_deployable_amount(deployable, skills)
		local amount = 0
		if deployable then
			if deployable == "sentry_gun_silent" then
				deployable = "sentry_gun"
			end
			amount = tweak_data.equipments[deployable] and tweak_data.equipments[deployable].quantity[1] or 0
			local upgrade_def, upgrade_values, skill_tweak = tweak_data.upgrades.definitions, tweak_data.upgrades.values, tweak_data.skilltree.skills
			if skills and upgrade_values[deployable] and upgrade_values[deployable]["quantity"] then
				local value_index = 0
				for skill, data in pairs(skills) do
					local skill_data = skill_tweak[skill]
					for i = 1, data.unlocked do
						local upgrade_ids = skill_data and skill_data[i].upgrades
						for _, upgrade_id in ipairs(upgrade_ids) do
							local u_data = upgrade_def[upgrade_id] and upgrade_def[upgrade_id].upgrade
							if u_data and u_data.category == deployable and u_data.upgrade == "quantity" then
								if upgrade_def[upgrade_id].incremental then
									value_index = value_index + (u_data.value or 0)
								else
									value_index = u_data.value
								end
							end
						end
					end
				end
				if value_index > 0 then
					amount = amount + (upgrade_values[deployable]["quantity"][math.floor(value_index)] or 0)
				end
			end
		end
		return amount
	end
elseif RequiredScript == "lib/managers/menu/multiprofileitemgui" then
    local init_orig = MultiProfileItemGui.init

	function MultiProfileItemGui:init(...)
		init_orig(self, ...)

		self._max_length = WolfHUD:getTweakEntry("MAX_PROFILE_NAME_LENGTH", "number", 20)
	end
elseif RequiredScript == "lib/managers/menu/missionbriefinggui" then
	local special_btn_pressed_orig = MissionBriefingGui.special_btn_pressed
	local input_focus_orig = MissionBriefingGui.input_focus
	local reload_loadout_orig = MissionBriefingGui.reload_loadout
	function MissionBriefingGui:special_btn_pressed(button, ...)
		if self._enabled and  button == Idstring("menu_change_profile_right") and managers.menu:get_controller():get_input_bool("menu_change_profile_left") then
			managers.menu:open_node(PROFILE_MENU_ID, {})
			return
		end

		return special_btn_pressed_orig(self, button, ...)
	end

	function MissionBriefingGui:input_focus(...)
		local focus = input_focus_orig(self, ...)
		if focus then
			local active_menu = managers.menu:active_menu()
			local selected_node = active_menu and active_menu.logic:selected_node()
			if selected_node and selected_node:parameters().name == PROFILE_MENU_ID then
				focus = false
			end
		end
		return focus
	end

	JukeboxItemNew = JukeboxItemNew or class(JukeboxItem)
	function JukeboxItemNew:select(...)
		local active_menu = managers.menu:active_menu()
		local selected_node = active_menu and active_menu.logic:selected_node()
		if not selected_node or selected_node:parameters().name == "kit" then
			JukeboxItemNew.super.select(self, ...)
		else
			self.displayed = true
			JukeboxItemNew.super.super.select(self, ...)
		end
	end
	function JukeboxItemNew:deselect(...)
		local active_menu = managers.menu:active_menu()
		local selected_node = active_menu and active_menu.logic:selected_node()
		if not selected_node or selected_node:parameters().name == "jukebox" then
			JukeboxItemNew.super.deselect(self, ...)
		else
			self.closing = true
			self.displayed = nil
			JukeboxItemNew.super.super.deselect(self, ...)
		end
	end

	if CoreClass then
		CoreClass.override_class(JukeboxItem, JukeboxItemNew)
	end
elseif RequiredScript == "lib/managers/menu/playerinventorygui" then
	local special_btn_pressed_orig = PlayerInventoryGui.special_btn_pressed
	function PlayerInventoryGui:special_btn_pressed(button, ...)
		if button == Idstring("menu_change_profile_right") and managers.menu:get_controller():get_input_bool("menu_change_profile_left") then
			managers.menu:open_node(PROFILE_MENU_ID, {})
			return
		end

		return special_btn_pressed_orig(self, button, ...)
	end
end
