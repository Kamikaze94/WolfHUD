if string.lower(RequiredScript) == "lib/managers/menumanager" then
	function MenuCallbackHandler:is_dlc_latest_locked(check_dlc) return false end
elseif string.lower(RequiredScript) == "lib/managers/menu/blackmarketgui" then 
	--Always enable mod mini icons, put ghost icon behind silent weapon names
	local populate_weapon_category_new_original = BlackMarketGui.populate_weapon_category_new
	function BlackMarketGui:populate_weapon_category_new(data, ...)
		local value = populate_weapon_category_new_original(self, data, ...)
		local show_icons = not WolfHUD:getSetting("show_mini_icons", "boolean")
		for id, w_data in ipairs(data) do
			if tweak_data.weapon[w_data.name] then	--Filter out locked or empty slots
				local category = tweak_data.weapon[w_data.name].category
				local is_saw = (category == "saw")
				local has_silencer = (category == "bow" or category == "crossbow")
				local has_explosive = false
				for id, i_data in pairs(w_data.mini_icons) do	--Needs to handle silent motor saw
					if i_data.alpha == 1 then		--Icon enabled
						if i_data.texture == "guis/textures/pd2/blackmarket/inv_mod_silencer" then
							has_silencer = true
						elseif i_data.texture == "guis/textures/pd2/blackmarket/inv_mod_ammo_explosive" then
							has_explosive = true
						end
					end
				end
				local silent = has_silencer and not has_explosive
				w_data.name_localized = tostring(w_data.name_localized) .. (not is_saw and (" " .. (silent and utf8.char(57363) or "")) or "")
				w_data.hide_unselected_mini_icons = show_icons
			end
		end
		return value
	end
	
	-- Remove free Buckshot ammo, if you own Gage Shotty DLC
	local populate_mods_original = BlackMarketGui.populate_mods
	function BlackMarketGui:populate_mods(data, ...)
		if managers.dlc:has_dlc("gage_pack_shotgun") then
			for index, mod_t in ipairs(data.on_create_data) do
				if mod_t[1] == "wpn_fps_upg_a_custom_free"  then
					table.remove(data.on_create_data, index)
					break
				end
			end
		end

		return populate_mods_original(self, data, ...)
	end
	
	local function getEquipmentAmount(name_id)
		local data = tweak_data.equipments[name_id]
		if data and data.quantity then
			if type(data.quantity) == "table" then
				local amounts = data.quantity
				local amount_str = ""
				for i = 1, #amounts do
					local equipment_name = name_id
					if data.upgrade_name then
						equipment_name = data.upgrade_name[i]
					end
					amount_str = amount_str .. (i > 1 and "/x" or "x") .. tostring((amounts[i] or 0) + managers.player:equiptment_upgrade_value(equipment_name, "quantity"))
				end
				return " (" .. amount_str .. ")"
			else
				return " (x" .. tostring(data.quantity) .. ")"
			end
		end
		return ""
	end
	
	local populate_deployables_original = BlackMarketGui.populate_deployables
	function BlackMarketGui:populate_deployables(data, ...)
		populate_deployables_original(self, data, ...)
		for i, equipment in ipairs(data) do
			equipment.name_localized = equipment.name_localized .. (equipment.unlocked and getEquipmentAmount(equipment.name) or "")
		end
	end
	
	local populate_grenades_original = BlackMarketGui.populate_grenades
	function BlackMarketGui:populate_grenades(data, ...)
		populate_grenades_original(self, data, ...)
		local t_data = tweak_data.blackmarket.projectiles
		for i, throwable in ipairs(data) do
			local has_amount = throwable.unlocked and t_data[throwable.name] or false
			throwable.name_localized = throwable.name_localized .. (has_amount and " (x" .. t_data[throwable.name].max_amount .. ")" or "")
		end
	end

	-- Show all Names in Inventory Boxxes
	local orig_blackmarket_gui_slot_item_init = BlackMarketGuiSlotItem.init
	function BlackMarketGuiSlotItem:init(main_panel, data, ...)
		if WolfHUD:getSetting("inventory_names", "boolean") then
			data.custom_name_text = data.custom_name_text or not data.empty_slot and data.name_localized
		end
		return orig_blackmarket_gui_slot_item_init(self, main_panel, data, ...)
	end
	
	local orig_blackmarket_gui_slot_item_select = BlackMarketGuiItem.select
	function BlackMarketGuiItem:select(instant, ...)
		self._is_selected = true
		self:set_highlight(true, instant)
		
		return orig_blackmarket_gui_slot_item_select(self, instant, ...)
	end
	
	local orig_blackmarket_gui_slot_item_deselect = BlackMarketGuiItem.deselect
	function BlackMarketGuiItem:deselect(instant, ...)
		self._is_selected = false
		self:set_highlight(false, instant)
		
		return orig_blackmarket_gui_slot_item_deselect(self, instant, ...)
	end
	
	local orig_blackmarket_gui_slot_item_set_highlight = BlackMarketGuiSlotItem.set_highlight
	function BlackMarketGuiSlotItem:set_highlight(highlight, ...)
		if highlight or self._is_selected or self._data.equipped then
			local name_text = self._panel:child("custom_name_text")
			if name_text then
				name_text:set_alpha(1)
			end
			if self._mini_panel then
				self._mini_panel:set_alpha(1)
			end
		else
			local name_text = self._panel:child("custom_name_text")
			if name_text then
				name_text:set_alpha(0.5)
			end
			if self._mini_panel then
				self._mini_panel:set_alpha(0.4)
			end
		end
		
		return orig_blackmarket_gui_slot_item_set_highlight(self, highlight, ...)
	end

	local orig_blackmarket_gui_set_selected_tab = BlackMarketGui.set_selected_tab
	function BlackMarketGui:set_selected_tab(...)	
		local value = orig_blackmarket_gui_set_selected_tab(self, ...)
		
		local current_tab = self._tabs[self._selected]
		local selected_slot = current_tab and current_tab._slots[current_tab._slot_selected]
		local highlighted_slot 	= current_tab and current_tab._slots[current_tab._slot_highlighted]
		
		if selected_slot then
			selected_slot:select(true, true)
			if highlighted_slot and selected_slot ~= highlighted_slot then
				selected_slot:set_highlight(false, true)
				highlighted_slot:set_highlight(true, false)
			end
		end
		
		return value
	end

	--Replace Tab Names with custom ones...
	local BlackMarketGuiTabItem_init_original = BlackMarketGuiTabItem.init
	function BlackMarketGuiTabItem:init(main_panel, data, ...)
		if WolfHUD:getSetting("inventory_tab_names", "boolean") and WolfHUD.inventory_names and WolfHUD.inventory_names[data.category] and type(data.on_create_data[1]) == "number" then
			local id = math.floor((data.on_create_data[1] / #data.on_create_data) + 1)
			data.name_localized = WolfHUD.inventory_names[data.category][id] or nil
		end
		return BlackMarketGuiTabItem_init_original(self, main_panel, data, ...)
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/skilltreeguinew" then
	local orig_newskilltreeskillitem_refresh = NewSkillTreeSkillItem.refresh
	function NewSkillTreeSkillItem:refresh(...)
		local value = orig_newskilltreeskillitem_refresh(self, ...)
		
		--Always show Skill names
		if alive(self._skill_panel) and WolfHUD:getSetting("skill_names", "boolean") then
			local skill_name = self._skill_panel:child("SkillName")
			if skill_name then
				local unlocked = self._skill_id and self._tree and managers.skilltree and managers.skilltree:skill_unlocked(self._tree, self._skill_id) or false
				local step = (self._skilltree:next_skill_step(self._skill_id) or 0)
				local skilled = unlocked and step > 0
				skill_name:set_visible(true)
				skill_name:set_alpha(self._selected and 1 or skilled and 0.6 or 0.4)
			end
		end
		
		return value
	end
	
	--Fix mouse pointer for locked skills
	local orig_newskilltreeskillitem_is_active = NewSkillTreeSkillItem.is_active
	function NewSkillTreeSkillItem:is_active(...)
		local unlocked = self._skill_id and self._tree and managers.skilltree and managers.skilltree:skill_unlocked(self._tree, self._skill_id) or false		
		return orig_newskilltreeskillitem_is_active(self, ...) or not unlocked
	end
	
	--Resize and move total points label
	local orig_newskilltreetieritem_init = NewSkillTreeTierItem.init
	local orig_newskilltreetieritem_refresh_points = NewSkillTreeTierItem.refresh_points
	local orig_newskilltreetieritem_refresh_tier_text = NewSkillTreeTierItem._refresh_tier_text
	function NewSkillTreeTierItem:init(...)
		local val = orig_newskilltreetieritem_init(self, ...)
		if WolfHUD:getSetting("skill_names", "boolean") then
			if self._tier_points_needed and self._tier_points_needed_curr and self._tier_points_needed_zero then
				--self._tier_points_needed_zero:set_left(self._text_space)
				--self._tier_points_needed_curr:set_left(self._tier_points_needed_zero:right())
				--self._tier_points_needed:set_left(self._tier_points_needed_curr:right())	
			end	
			
			if self._tier_points_total and self._tier_points_total_zero and self._tier_points_total_curr then
				local font_size = tweak_data.menu.pd2_small_font_size * 0.75
				self._tier_points_total:set_font_size(font_size)
				local _, _, w, h = self._tier_points_total:text_rect()
				self._tier_points_total:set_size(w, h)
				self._tier_points_total_zero:set_font_size(font_size)
				self._tier_points_total_curr:set_font_size(font_size)
				self._tier_points_total:set_alpha(0.9)
				self._tier_points_total_curr:set_alpha(0.9)
				self._tier_points_total_zero:set_alpha(0.6)
			end
		end
		return val
	end
	function NewSkillTreeTierItem:refresh_points(selected, ...)
		orig_newskilltreetieritem_refresh_points(self, selected, ...)
		if WolfHUD:getSetting("skill_names", "boolean") then
			if alive(self._tier_points_total) and alive(self._tier_points_total_zero) and alive(self._tier_points_total_curr) then
				self._tier_points_total:set_y(self._text_space or 10)
				self._tier_points_total_zero:set_y(self._text_space or 10)
				self._tier_points_total_curr:set_y(self._text_space or 10)
			end
		end
	end
	function NewSkillTreeTierItem:_refresh_tier_text(selected, ...)
		orig_newskilltreetieritem_refresh_tier_text(self, selected, ...)
		if WolfHUD:getSetting("skill_names", "boolean") then
			if selected and alive(self._tier_points_needed) and alive(self._tier_points_needed_curr) and alive(self._tier_points_needed_zero) then
				self._tier_points_needed_zero:set_left(self._tier_points_0:left())
				self._tier_points_needed_curr:set_left(self._tier_points_needed_zero:right())
				self._tier_points_needed:set_left(self._tier_points_needed_curr:right() + self._text_space)
			end			
			if alive(self._tier_points_0) and alive(self._tier_points) then
				self._tier_points:set_visible(not self._tier_points_needed:visible())
				self._tier_points_0:set_visible(not self._tier_points_needed:visible())
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/tweak_data/tweakdata" then
	if tweak_data then
		tweak_data.menu = tweak_data.menu or {}
		tweak_data.menu.MUSIC_CHANGE = 1
		tweak_data.menu.SFX_CHANGE = 1
		tweak_data.menu.VOICE_CHANGE = 0.01
	end
elseif string.lower(RequiredScript) == "lib/tweak_data/guitweakdata" then
	local GuiTweakData_init_orig = GuiTweakData.init
	function GuiTweakData:init(...)
		GuiTweakData_init_orig(self, ...)
		self.rename_max_letters = 30
		self.rename_skill_set_max_letters = 25
	end
elseif string.lower(RequiredScript) == "core/lib/managers/menu/items/coremenuitemslider" then
	core:module("CoreMenuItemSlider")
	core:import("CoreMenuItem")
	local init_actual = ItemSlider.init
	local highlight_row_item_actual = ItemSlider.highlight_row_item
	local set_value_original = ItemSlider.set_value
	function ItemSlider:init(...)
		init_actual(self, ...)
		self._show_slider_text = true
	end
	
	function ItemSlider:highlight_row_item(node, row_item, mouse_over, ...)
		local val = highlight_row_item_actual(self, node, row_item, mose_over, ...)
		row_item.gui_slider_gfx:set_gradient_points({
			0, _G.tweak_data.screen_colors.button_stage_2:with_alpha(0.6),
			1, _G.tweak_data.screen_colors.button_stage_2:with_alpha(0.6)
		})
		return val
	end
	
	function ItemSlider:set_value(value, ...)
		local times = math.round((value - self._min) / self._step)
		value = self._min + self._step * times
		
		set_value_original(self, value, ...)
	end
elseif string.lower(RequiredScript) == "lib/states/ingamewaitingforplayers" then
	local SKIP_BLACKSCREEN = WolfHUD:getSetting("skip_blackscreen", "boolean")
	local update_original = IngameWaitingForPlayersState.update
	function IngameWaitingForPlayersState:update(...)
		update_original(self, ...)
		
		if self._skip_promt_shown and SKIP_BLACKSCREEN then
			self:_skip()
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/stageendscreengui" then
	local update_original = StageEndScreenGui.update
	local SKIP_STAT_SCREEN_DELAY = WolfHUD:getSetting("stat_screen_delay", "number")
	function StageEndScreenGui:update(t, ...)
		update_original(self, t, ...)
		if not self._button_not_clickable and SKIP_STAT_SCREEN_DELAY > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + SKIP_STAT_SCREEN_DELAY)
			if t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				game_state_machine:current_state()._continue_cb()
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/lootdropscreengui" then
	local SKIP_LOOT_SCREEN_DELAY = WolfHUD:getSetting("loot_screen_delay", "number")
	local AUTO_PICK_CARD = WolfHUD:getSetting("autopick_card", "boolean")
	local update_original = LootDropScreenGui.update
	function LootDropScreenGui:update(t, ...)
		update_original(self, t, ...)

		if not self._card_chosen and AUTO_PICK_CARD then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end
		
		if not self._button_not_clickable and SKIP_LOOT_SCREEN_DELAY > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + SKIP_LOOT_SCREEN_DELAY)
			if t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/renderers/menunodeskillswitchgui" then
	local _create_menu_item=MenuNodeSkillSwitchGui._create_menu_item
	function MenuNodeSkillSwitchGui:_create_menu_item(row_item, ...)
		_create_menu_item(self, row_item, ...)
		if row_item.type~="divider" and row_item.name~="back" then
			local gd=Global.skilltree_manager.skill_switches[row_item.name]
			row_item.status_gui:set_text( managers.localization:to_upper_text( ("menu_st_spec_%d"):format( managers.skilltree:digest_value(gd.specialization, false, 1) or 1 ) ) )
			if row_item.skill_points_gui:text()==managers.localization:to_upper_text("menu_st_points_all_spent_skill_switch") then
				local pts, pt, pp, st, sp=0, 1, 0, 2, 0
				for i=1, #gd.trees do
					pts=Application:digest_value(gd.trees[i].points_spent, false)
					if pts>pp then
						sp, st, pp, pt=pp, pt, pts, i
					elseif pts>sp then
						sp, st=pts, i
					end
				end
				row_item.skill_points_gui:set_text(	managers.localization:to_upper_text( tweak_data.skilltree.trees[pt].name_id	) .." / "..	managers.localization:to_upper_text( tweak_data.skilltree.trees[st].name_id	) )
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/chatmanager" then
	if not WolfHUD:getSetting("spam_filter", "boolean") then return end
	ChatManager._SUB_TABLE = {
			[utf8.char(57364)] = "<SKULL>",	--Skull icon
			[utf8.char(57363)] = "<GHOST>",	--Ghost icon
			[utf8.char(139)] = "<LC>",		--broken bar
			[utf8.char(155)] = "<RC>",		
			[utf8.char(1035)] = "<DRC>",		
			[utf8.char(1014)] = "<DIV>",	--PocoHuds bar
			[utf8.char(57344)] = "<A>",		--Controller A
			[utf8.char(57345)] = "<B>",		--Controller B
			[utf8.char(57346)] = "<X>",		--Controller X
			[utf8.char(57347)] = "<Y>",		--Controller Y
			[utf8.char(57348)] = "<BACK>",	--Controller BACK
			[utf8.char(57349)] = "<START>",	--Controller START
			[utf8.char(1031)] = "<DOT>",		
			[utf8.char(1015)] = "<CHAPTER>",	
			[utf8.char(1012)] = "<BIGDOT>",	
			[utf8.char(215)] = "<TIMES>",	--Mult
			[utf8.char(247)] = "<DIVIDED>",	--Divided
			[utf8.char(1024)] = "<DEG>",	--Degree
			[utf8.char(1030)] = "<PM>",		--PM Sign
			[utf8.char(1033)] = "<NO>"		--Number
			
	}
	
	ChatManager._BLOCK_PATTERNS = {
	  ".-%[NGBT%w+%].+",
	  --NGBTO info blocker Should work since its mass spam.
	  "[%d:]+%d:%d%d.-<DIV>.+"
	  --Blocks anything, that starts with numbers and ':' and then has a divider (Might block other mods, not only Poco...)
	}

	local _receive_message_original = ChatManager._receive_message

	function ChatManager:_receive_message(channel_id, name, message, ...)
		local message2 = message
		for key, subst in pairs(ChatManager._SUB_TABLE) do
				message2 = message2:gsub(key, subst)
		end
		for _, pattern in ipairs(ChatManager._BLOCK_PATTERNS) do
			if message2:match("^" .. pattern .. "$") then
				return WolfHUD.DEBUG_MODE and _receive_message_original(self, channel_id, name, "Pattern found: " .. pattern, ...)
			end
		end
		return _receive_message_original(self, channel_id, name, message, ...)
	end
elseif string.lower(RequiredScript) == "lib/managers/menumanagerdialogs" then
	local function expect_yes(self, params) params.yes_func() end
	MenuManager.show_confirm_buy_premium_contract = expect_yes
	MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
	MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
	MenuManager.show_confirm_mission_asset_buy = expect_yes
	MenuManager.show_confirm_pay_casino_fee = expect_yes
	
	local show_person_joining_original = MenuManager.show_person_joining
	local update_person_joining_original = MenuManager.update_person_joining
	local close_person_joining_original = MenuManager.close_person_joining
	function MenuManager:show_person_joining( id, nick, ... )
		self["peer_join_" .. id] = os.clock()
		local peer = managers.network:session():peer(id)
		if peer then
			if peer:rank() > 0 then
				managers.hud:post_event("infamous_player_join_stinger")
			end
			nick = "(" .. (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "-" or "") .. peer:level() .. ") " .. nick
		end
		return show_person_joining_original(self, id, nick, ...)
	end
	
	function MenuManager:update_person_joining( id, progress_percentage, ... )
		self["peer_join_" .. id] = self["peer_join_" .. id] or os.clock()
		local t = os.clock() - self["peer_join_" .. id]
		local result = update_person_joining_original(self, id, progress_percentage, ...)
		local time_left = (t / progress_percentage) * (100 - progress_percentage)
		local dialog = managers.system_menu:get_dialog("user_dropin" .. id)
		if dialog and time_left then
			dialog:set_text(managers.localization:text("dialog_wait") .. string.format(" %d%% (%0.2fs)", progress_percentage, time_left))
		end
	end
	
	function MenuManager:close_person_joining(id, ...)
		self["peer_join_" .. id] = nil
		close_person_joining_original(self, id, ...)
	end
end