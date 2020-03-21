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
		layer = params.layer
	})
end

function LoadoutBaseItem:destroy()
	if not self:destroyed() then
		self._to_destroy = true
		self._panel:stop()
		self._owner_panel:remove(self._panel)
	end
end

function LoadoutBaseItem:destroyed()
	return self._to_destroy
end

function LoadoutBaseItem:name()
	return self._name
end

function LoadoutBaseItem:enabled()
	return next(self._disable_reason) == nil
end

function LoadoutBaseItem:set_enabled(reason, status)
	self._disable_reason[reason] = (not status) and true or nil

	local visible = next(self._disable_reason) == nil
	if self._panel:visible() ~= visible then
		self._panel:set_visible(visible)
		--self._owner:arrange()
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

function LoadoutBaseItem:update(t, dt)

end

function LoadoutBaseItem:arrange()

end

function LoadoutBaseItem:set_outfit(outfit)
	return table.size(outfit) > 0
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

function LoadoutBaseItem:set_alpha(v)
	if not self:destroyed() then
		self._panel:set_alpha(v)
	end
end
function LoadoutBaseItem:set_x(v)
	if not self:destroyed() then
		self._panel:set_x(v)
	end
end
function LoadoutBaseItem:set_y(v)
	if not self:destroyed() then
		self._panel:set_y(v)
	end
end
function LoadoutBaseItem:set_left(v)
	if not self:destroyed() then
		self._panel:set_left(v)
	end
end
function LoadoutBaseItem:set_right(v)
	if not self:destroyed() then
		self._panel:set_right(v)
	end
end
function LoadoutBaseItem:set_top(v)
	if not self:destroyed() then
		self._panel:set_top(v)
	end
end
function LoadoutBaseItem:set_bottom(v)
	if not self:destroyed() then
		self._panel:set_bottom(v)
	end
end
function LoadoutBaseItem:set_center(x, y)
	if not self:destroyed() then
		self._panel:set_center(x, y)
	end
end
function LoadoutBaseItem:set_center_x(v)
	if not self:destroyed() then
		self._panel:set_center_x(v)
	end
end
function LoadoutBaseItem:set_center_y(v)
	if not self:destroyed() then
		self._panel:set_center_y(v)
	end
end
function LoadoutBaseItem:set_layer(v)
	if not self:destroyed() then
		self._panel:set_layer(v)
	end
end

LoadoutPanel = LoadoutPanel or class(LoadoutBaseItem)
LoadoutPanel.NAME_TO_CLASS = {
	name 					= { class = "LoadoutNameItem", 			params = { font_size = tweak_data.menu.pd2_medium_font_size, 		height = tweak_data.menu.pd2_medium_font_size, margin = 0, use_peer_color = true } },
	level 					= { class = "LoadoutLevelItem", 		params = { font_size = tweak_data.menu.pd2_medium_font_size, 		height = tweak_data.menu.pd2_medium_font_size, margin = 0, use_peer_color = true } },
	ping					= { class = "LoadoutPingItem", 			params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.6, 	height = tweak_data.menu.pd2_medium_font_size, margin = 2 } },
	playtime 				= { class = "LoadoutPlaytimeItem", 		params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.6, 	height = tweak_data.menu.pd2_medium_font_size, margin = 0 } },
	cs_level 				= { class = "LoadoutCSLevelItem", 		params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.6, 	height = tweak_data.menu.pd2_medium_font_size, margin = 0 } },
	detection 				= { class = "LoadoutDetectionItem", 	params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.6, 	height = tweak_data.menu.pd2_medium_font_size, margin = 0 } },
	character				= { class = "LoadoutCharacterItem", 	params = { font_size = tweak_data.menu.pd2_medium_font_size * 0.9,  height = tweak_data.menu.pd2_medium_font_size, margin = 2 } },
	skills 					= { class = "LoadoutSkillsItem", 		params = { height = tweak_data.menu.pd2_small_font_size, 			margin = 2 } },
	perk 					= { class = "LoadoutPerkItem", 			params = { height = tweak_data.menu.pd2_small_font_size, 			margin = 2 } },
	primary 				= { class = "LoadoutWeaponItem", 	 	params = { margin = 5 } },
	secondary 				= { class = "LoadoutWeaponItem", 		params = { margin = 5 } },
	melee_weapon			= { class = "LoadoutImageItem", 	 	params = { margin = 5 } },
	grenade 				= { class = "LoadoutImageItem", 	 	params = { margin = 5 } },
	mask					= { class = "LoadoutMaskItem", 		 	params = { margin = 5 } },
	player_style			= { class = "LoadoutImageItem", 		params = { margin = 5 } },
	armor 					= { class = "LoadoutImageItem", 	 	params = { margin = 5 } },
	deployable 				= { class = "LoadoutDeployableItem", 	params = { margin = 5 } },
	secondary_deployable 	= { class = "LoadoutDeployableItem", 	params = { margin = 5 } },
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
		local max_h = 0
		for i, name in ipairs(data) do
			local config = params[name] or {}
			if self.NAME_TO_CLASS[name] then
				for name, value in pairs(self.NAME_TO_CLASS[name].params or {}) do
					config[name] = config[name] or value
				end
			end
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
		for i, name in ipairs(data) do
			local sub_comp_w = comp_w / #data
			local config = self.NAME_TO_CLASS[name]
			local class = config and config.class
			if class then
				local component_params = params[name] or clone(config.params)
				if params.default then
					for name, value in pairs(params.default) do
						component_params[name] = component_params[name] or value
					end
				end
				if component_params.use_peer_color then
					component_params.color = self._peer_color
				end
				self._components[name] = _G[class]:new(self._panel, self, name, sub_comp_w, component_params and component_params.height or math.ceil(comp_h), component_params or {})
			end
		end
	end

	self._border_config = params.borders or {1, 1, 1 ,1}
	self._borders = BoxGuiObject:new(self._panel, {
		sides = self._border_config
	})

	if params.add_bg then
		self._panel:rect({
			color = self._peer_color,
			alpha = 0.15,
			layer = -1,
			x = self._margin * 0.5,
			y = self._margin * 0.5,
			w = self._panel:w() - self._margin,
			h = self._panel:w() - self._margin
		})
	end

	self:arrange()

	self:set_outfit(params.outfit or {})
end

function LoadoutPanel:set_enabled(reason, status)
	self._disable_reason[reason] = (not status) and true or nil

	local visible = next(self._disable_reason) == nil
	if self._panel:visible() ~= visible then
		self._panel:set_visible(visible)
		if self._borders then
			self._borders:create_sides(self._panel, { sides = (visible and self._border_config or {0, 0, 0, 0})})
		end
		return true
	end
end

function LoadoutPanel:set_size(w, h)
	if LoadoutPanel.super.set_size(self, w, h) then
		if self._borders and self:enabled() then
			self._borders:create_sides(self._panel, {
				sides = self._border_config or {0, 0, 0, 0}
			})
		end
	end
end

function LoadoutPanel:update(t, dt)
	for name, component in pairs(self._components) do
		component:update(t, dt)
	end
end

function LoadoutPanel:arrange()
	local total_y = self._margin or 0
	local active_comps = {}
	for i, data in ipairs(self._component_layout) do
		local max_h = 0
		active_comps[i] = {}
		for j, name in ipairs(data) do
			local component = self._components[name]
			if component:enabled() then
				component:set_y(total_y)
				max_h = math.max(max_h, component:h())
				table.insert(active_comps[i], component)
			end
		end
		total_y = total_y + max_h
	end

	for i, components in ipairs(active_comps) do
		local new_w = math.floor((self._panel:w() - (2 * self._margin)) / table.size(components))
		local x = self._margin or 0
		for i, component in ipairs(components) do
			if component:enabled() then
				component:set_x(x)
				if component:set_w(new_w) then
					component:arrange()
				end
				x = x + component:w()
			end
		end
	end

	if self:set_h(total_y + self._margin) and not self:destroyed() then
		self._owner:arrange_loadout_panels(self._owner_panel)
	end

end

function LoadoutPanel:set_outfit(outfit)
	local enabled = false
	for name, component in pairs(self._components) do
		component:set_outfit(outfit or {})
		enabled = enabled or component:enabled()
	end

	if enabled then
		self:arrange()
	end

	local outfit_changed = self:set_enabled("outfit", outfit and true or false)
	local active_comp_changed = self:set_enabled("active_components", enabled)
	if not self:destroyed() and outfit_changed or active_comp_changed then
		self._owner:arrange_loadout_panels(self._owner_panel)
	end
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

function LoadoutPanel:mark_cheater(status, reason)
	for _, item_name in ipairs({"name", "character", "level"}) do
		local item = self:items(item_name)
		if item then
			item:set_color(status and tweak_data.screen_colors.pro_color or item._default_color or Color.white)
		end
	end
--[[
	if status and managers.chat then	-- TODO: Needs localization
		local message = string.format("[WolfHUD] %s is cheating: %s", self:get_peer():name(), reason or "N/A")
		managers.chat:feed_system_message(ChatManager.GAME, message)
	end
]]
end

function LoadoutPanel:items(name)
	if name then
		return self._components[name]
	else
		return self._components
	end
end

LoadoutTextItem = LoadoutTextItem or class(LoadoutBaseItem)
function LoadoutTextItem:init(base_panel, owner, name, width, height, params)

	LoadoutTextItem.super.init(self, base_panel, owner, name, width, height, params)

	self._font_size = math.min(params.font_size or tweak_data.menu.pd2_medium_font_size, self._panel:h() - 2 * self._margin)
	self._default_color = params.color or Color.white
	self._loadout = ""

	self._text = self._panel:text({
		name = name,
		text = params.text or "",
		color = self._default_color,
		alpha = params.alpha or 1,
		align = params.align or "center",
		vertical = "center",
		x = self._margin,
		y = self._margin,
		w = self._panel:w() - 2 * self._margin,
		h = self._font_size,
		layer = 2,
		font_size = self._font_size * 0.95,
		font = tweak_data.menu.pd2_medium_font,
		blend_mode = params.blend_mode or "normal",
	})
end

function LoadoutTextItem:arrange()
	if self:enabled() and alive(self._text) then
		self._text:set_font_size(self._font_size * 0.95)
		local _, _, w, h = self._text:text_rect()
		while w > math.max(self._panel:w() - 2 * self._margin, 1) do
			if self._text:font_size() > 11 then
				self._text:set_font_size(self._text:font_size() - 0.1)
			else
				self._text:set_text(self._text:text():sub(1, self._text:text():len() - 1))
			end
			_, _, w, h = self._text:text_rect()
		end

		self._text:set_x(self._margin)
		self._text:set_y(self._margin)
		self._text:set_w(self._panel:w() - 2 * self._margin)
		self._text:set_h(self._panel:h() - 2 * self._margin)
	end
end

function LoadoutTextItem:set_text(text, color_range)
	if text and alive(self._text) then
		self._text:set_text(text)
		if color_range then
			local color, alpha = self._text:color(), self._text:alpha()
			for _, range in ipairs(color_range) do
				self._text:set_range_color(range[1], range[2], color:with_alpha(alpha * 0.75))
			end
		end
	end
end

function LoadoutTextItem:set_color(color)
	if color then
		self._text:set_color(color)
	end
end

LoadoutImageItem = LoadoutImageItem or class(LoadoutBaseItem)
function LoadoutImageItem:init(base_panel, owner, name, width, height, params)

	LoadoutImageItem.super.init(self, base_panel, owner, name, width, height, params)

	self._hide_name = params.hide_name
	self._font_size = params.font_size or tweak_data.menu.pd2_small_font_size
	self._default_color = params.color or Color.white
	self._loadout = ""

	self._text = self._panel:text({
		name = name .. "_title",
		text = params.text or "",
		color = self._default_color,
		alpha = params.alpha or 1,
		align = "left",
		vertical = "center",
		h = self._font_size,
		layer = 3,
		font_size = self._font_size * 0.95,
		font = tweak_data.menu.pd2_medium_font,
		blend_mode = params.blend_mode or "normal",
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
		color = self._default_color,
		alpha = params.alpha or 1,
		blend_mode = params.blend_mode or "normal",
		align = "right",
		vertical = "bottom",
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
	if self:enabled() then
		self._text:set_font_size(self._font_size * 0.95)
		local _, _, w, h = self._text:text_rect()
		while w > math.max(self._panel:w() - 2 * self._margin, 1) do
			if self._text:font_size() > 11 then
				self._text:set_font_size(self._text:font_size() - 0.1)
			else
				self._text:set_text(self._text:text():sub(1, self._text:text():len() - 1))
			end
			_, _, w, h = self._text:text_rect()
		end

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

		self._amount_text:set_font_size(tweak_data.menu.pd2_small_font_size * 0.9)
		local _, _, w, h = self._amount_text:text_rect()
		while w > ((self._panel:w() - 2 * self._margin) / 2) do
			if self._amount_text:font_size() > 10 then
				self._amount_text:set_font_size(self._amount_text:font_size() - 0.1)
			else
				break
			end
			_, _, w, h = self._amount_text:text_rect()
		end

		self._amount_text:set_right(self._panel:w() - self._margin)
		self._amount_text:set_bottom(self._panel:h() - self._margin)
	end
end

function LoadoutImageItem:set_text(text, color_range)
	if text and self._text:visible() then
		self._text:set_text(text)
		if color_range then
			local color, alpha = self._text:color(), self._text:alpha()
			for _, range in ipairs(color_range) do
				self._text:set_range_color(range[1], range[2], color:with_alpha(alpha * 0.75))
			end
		end
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

function LoadoutImageItem:set_amount(amount, color_range)
	if amount then
		local text = amount > 1 and string.format("x%d", amount) or ""
		self._amount_text:set_text(text)
		if color_range then
			local color, alpha = self._text:color(), self._text:alpha()
			for _, range in ipairs(color_range) do
				self._amount_text:set_range_color(range[1], range[2], color:with_alpha(alpha * 0.65))
			end
		end
	end
end

function LoadoutImageItem:set_outfit(outfit)
	if outfit[self._name] then
		self:set_enabled("outfit", true)
		if self._loadout ~= outfit[self._name] then
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
		player_style = tweak_data.blackmarket.player_styles,
		armor = tweak_data.blackmarket.armors,
		grenade = tweak_data.blackmarket.projectiles,
		deployables = tweak_data.blackmarket.deployables,
	}
	local texture_path = {
		weapon_skin = "weapon_skins/",
		weapon = "textures/pd2/blackmarket/icons/weapons/",
		melee_weapon = "textures/pd2/blackmarket/icons/melee_weapons/",
		mask = "textures/pd2/blackmarket/icons/masks/",
		player_style = "textures/pd2/blackmarket/icons/player_styles/",
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

LoadoutCSLevelItem = LoadoutCSLevelItem or class(LoadoutTextItem)

function LoadoutCSLevelItem:init(base_panel, owner, name, width, height, params)
	params.color = params.color or tweak_data.screen_colors.crime_spree_risk
	LoadoutCSLevelItem.super.init(base_panel, owner, name, width, height, params)
end

function LoadoutCSLevelItem:set_outfit(outfit)
	local peer_id = self._owner:get_peer_id()
	local level = -1
	if self._owner:local_peer() then
		level = managers.crime_spree:spree_level()
	else
		level = managers.crime_spree:get_peer_spree_level(peer_id)
	end
	if level >= 0 then
		self:set_enabled("cs_level", true)
		if tostring(level) ~= self._loadout then
			local level_str = managers.localization:text("menu_cs_level", { level = managers.experience:cash_string(level, "") })
			self:set_text(level_str or "")

			self._loadout = tostring(level)

			self:arrange()
		end
	else
		self:set_enabled("cs_level", false)
	end
end

LoadoutDetectionItem = LoadoutDetectionItem or class(LoadoutTextItem)

function LoadoutDetectionItem:set_outfit(outfit)
	local peer = self._owner:get_peer()
	if peer then
		self:set_enabled("peer", true)
		local detection = math.round(managers.blackmarket:get_suspicion_offset_of_peer(peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100)
		if tostring(detection) ~= self._loadout then
			self:set_text(utf8.char(57363) .. detection, detection < 50 and Color(1, 0, 0.8, 1) or Color(1, 1, 0.2, 0))

			self._loadout = tostring(detection)

			self:arrange()
		end
	else
		self:set_enabled("peer", false)
	end
end

LoadoutPingItem = LoadoutPingItem or class(LoadoutTextItem)

function LoadoutPingItem:init(base_panel, owner, name, width, height, params)

	LoadoutPingItem.super.init(self, base_panel, owner, name, width, height, params)

	self:set_enabled("distant_peer", not self._owner:local_peer())
end

function LoadoutPingItem:update(t, dt)
	if not self._owner:local_peer() then
		if (self._next_update_t or 0) <= t then
			local peer = self._owner:get_peer()
			if peer then
				local latency = Network:qos(peer:rpc()).ping or 0
				self:set_text(string.format("%.0fms", latency), latency < 75 and Color('C2FC97') or latency < 150 and Color('CEA168') or Color('E24E4E'))
			else
				self:set_text("---ms", Color('E24E4E'))
			end
			self._next_update_t = (t + 1)

			self:arrange()
		end
	end
end

function LoadoutPingItem:set_outfit(outfit)
	local peer = self._owner:get_peer()
	if peer then
		self:set_enabled("peer", true)
	else
		self:set_enabled("peer", false)
	end
end

function LoadoutPingItem:set_text(text, color)
	LoadoutPingItem.super.set_text(self, text)

	if alive(self._text) then
		self._text:set_color(color)
	end
end

LoadoutPlaytimeItem = LoadoutPlaytimeItem or class(LoadoutTextItem)

function LoadoutPlaytimeItem:set_outfit(outfit)
	local peer = self._owner:get_peer()
	local steam_id = peer and tostring(peer:user_id())
	if steam_id then
		self:set_enabled("peer", true)
		if steam_id ~= self._loadout then
			self._loadout = steam_id

			self:set_text("...")
			self:arrange()

			--local profile_url = string.format("http://steamcommunity.com/profiles/%s/?xml=1", tostring(steam_id))
			local all_games_url = string.format("http://steamcommunity.com/profiles/%s/games/?xml=1", tostring(steam_id))
			Steam:http_request(all_games_url, callback(self, self, "set_playtime_clbk"))
		end
	else
		self:set_enabled("peer", false)
	end
end

function LoadoutPlaytimeItem:set_playtime_clbk(success, page)
	local text = "No Data."
	if success then
		local _, gameStart = page:find("<appID>218620</appID>", 1, false)	--"/app/218620" (alt. for profile_url)
		if gameStart then
			local _, hoursStart = page:find("<hoursOnRecord>", gameStart, false)
			local hoursEnd, _ = page:find("</hoursOnRecord>", hoursStart, false)
			if hoursStart and hoursEnd and ((hoursEnd - hoursStart) > 2) then
				local playtime = page:sub(hoursStart + 1, hoursEnd - 1)
				text = managers.localization:text("wolfhud_loadout_hours_played", { HOURS = playtime })
			end
		else
			if page:find("This profile is private.", 1, false) then
				text = "Private."
			else
				text = "No Game."
			end
		end
	end
	self:set_text(text)
	self:arrange()
end

LoadoutCharacterItem = LoadoutCharacterItem or class(LoadoutTextItem)

function LoadoutCharacterItem:set_outfit(outfit)
	local peer = self._owner:get_peer()
	if peer then
		local character = peer:character()
		self:set_enabled("peer", true)
		if character ~= self._loadout then
			self._loadout = character
			self:set_text(managers.localization:text("menu_" .. CriminalsManager.convert_new_to_old_character_workname(character)))

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
	self._detailed = params.show_subtrees or false

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
		local skill_str = skill_data and table.concat(skill_data, "_")
		if skill_data and skill_str ~= self._loadout then
			self._loadout = skill_str
			local subtree_amt = math.floor(#skill_data / #self._tree_names)
			local text = ""
			local color_range = {}
			local points_total = 0

			for tree = 1, #self._tree_names, 1 do
				local tree_has_points = false
				local tree_name = (self._tree_names[tree] or "?")
				local tree_detailed = string.format("%s:", tree_name)
				local tree_sum = 0

				for sub_tree = 1, subtree_amt, 1 do
					local skills = skill_data[(tree-1) * subtree_amt + sub_tree] or 0
					if self._detailed and skills < 10 then
						local l = text:len() + tree_detailed:len()
						local l_end = l + (skills > 0 and 1 or 2)
						table.insert(color_range, {l, l_end})
					end
					tree_detailed = string.format("%s%02d ", tree_detailed, skills)
					tree_sum = tree_sum + skills
				end
				if self._detailed then
					text = string.format("%s%s", text, tree_detailed)
				else
					if tree_sum < 10 then
						local l = text:len() + tree_name:len() + 1
						local l_end = l + (tree_sum > 0 and 1 or 2)
						table.insert(color_range, {l, l_end})
					end
					text = string.format("%s%s:%02d ", text, tree_name, tree_sum)
				end
				points_total = points_total + tree_sum
			end

			local is_cheating = points_total > (self:get_max_skillpoints() or points_total)
			self:set_color(is_cheating and tweak_data.screen_colors.pro_color or self._default_color)
			self._owner:mark_cheater(is_cheating, is_cheating and "Too many skillpoints used." or "")

			self:set_text(text, color_range)

			self:arrange()
		end
	else
		self:set_enabled("outfit", false)
	end
end

LoadoutSkillsItem.POINTS_MAP = {
	{1, 1},
	{10, 2}
}
function LoadoutSkillsItem:get_max_skillpoints()
	local level = 100
	if managers.experience and self._owner:local_peer() then
		level = tonumber(managers.experience:current_level())
	elseif self._owner:get_peer() then
		level = tonumber(self._owner:get_peer():level())
	end

	if level then
		local max_points = 0
		for _, data in ipairs(self.POINTS_MAP) do
			max_points = max_points + math.floor(level / data[1]) * data[2]
		end
		return max_points
	end
end

LoadoutPerkItem = LoadoutPerkItem or class(LoadoutTextItem)

function LoadoutPerkItem:set_outfit(outfit)
	if outfit.skills and outfit.skills.specializations then
		self:set_enabled("outfit", true)
		local deck_index, deck_level = unpack(outfit.skills.specializations or {})
		local data = tweak_data.skilltree.specializations[tonumber(deck_index) or 0]
		local name_id = data and data.name_id
		local deck_id = string.format("%s_%s", name_id or "", tostring(deck_level))
		if name_id and self._loadout ~= deck_id then
			self._loadout = deck_id
			local text = managers.localization:text(name_id)
			local color_range = {}
			if (tonumber(deck_level) or 0) < 9 then
				local l = text:len()
				text = string.format("%s (%d/9)", text, deck_level or 0)
				table.insert(color_range, {l, text:len()})
			end
			self:set_text(text, color_range)

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
			local size = math.min(self._panel:h() / 4, self._panel:w() / #self._perks, 16)
			perk:set_w(size)
			perk:set_h(size)
			perk:set_rightbottom(math.round(self._panel:w() - self._margin - ((i-1) * (perk:w() + 1))), math.round(self._panel:h() - self._margin))
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
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(outfit[self._name].factory_id)
	if weapon_id then
		self:set_enabled("outfit", true)
		if self._loadout ~= weapon_id then
			self._loadout = weapon_id
			local skin_id = outfit[self._name].cosmetics and outfit[self._name].cosmetics.id
			local skin_tweak = tweak_data.blackmarket.weapon_skins[skin_id]
			local weapon_skin = skin_tweak and not skin_tweak.is_a_color_skin and (table.contains(skin_tweak.weapon_ids or {}, weapon_id) or (skin_tweak.weapon_id and skin_tweak.weapon_id == weapon_id) ~= (skin_tweak.use_blacklist or false)) or false
			local texture, name, rarity = self:get_outfit_data(weapon_skin and "weapon_skin" or "weapon", weapon_skin and skin_id or weapon_id)

			self:set_text(name)
			self:set_image(texture)
			self:set_rarity(rarity)

			return true
		end
	else
		self:set_enabled("outfit", false)
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
			has_team_boost = custom_stats and (custom_stats.exp_multiplier or custom_stats.money_multiplier) and true or false
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
		local perk_size = math.min(self._panel:h() / 4, self._panel:w() / #self._perks, 16)

		for perk in pairs(perks or {}) do
			if perk ~= "bonus" then
				local texture = "guis/textures/pd2/blackmarket/inv_mod_" .. perk
				if DB:has(Idstring("texture"), texture) then
					local perk_object = self._panel:bitmap({
						name = "perk_" .. tostring(perk),
						texture = texture,
						align = "center",
						valign = "scale",
						vertical = "center",
						w = perk_size,
						h = perk_size,
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
		self:set_enabled("outfit", true)
		if self._loadout ~= outfit.mask.mask_id then
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
	if outfit[self._name] and tostring(outfit[self._name]) ~= "nil" and (self._name ~= "secondary_deployable" or (outfit.skills and outfit.skills.skills and (tonumber(outfit.skills.skills[7]) or 0) >= 12)) then
		self:set_enabled("outfit", true)
		if self._loadout ~= outfit[self._name] then
			self._loadout = outfit[self._name]
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
			amount = math.ceil(amount / 2)
		end

		self:set_amount(amount)
	end
end
