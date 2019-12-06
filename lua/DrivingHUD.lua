if string.lower(RequiredScript) == "lib/managers/hud/huddriving" then
	HUDDriving.VEHICLES = {
		["Longfellow"] = {
			["driver"] = 				{ scale_x = -0.2, 	scale_y = -0.15, 	is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.15, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.2, 	scale_y = 0.25, 	is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 0.25, 	is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/longfellow"
		},
		["Falcogini"] = {
			["driver"] = 				{ scale_x = -0.2, 	scale_y = 0, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = 0, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/falcogini"
		},
		["Forklift"] = {
			["driver"] = 				{ scale_x = 0, 		scale_y = 0.3, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0, 		scale_y = 0.9, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/forklift"
		},
		["Truck"] = {
			["driver"] = 				{ scale_x = -0.15, 	scale_y = -0.4,		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.4,		is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.15, 	scale_y = 1, 		is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 1, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/truck"
		},
		["Rib Boat"] = {
			["driver"] = 				{ scale_x = 0, 		scale_y = 1, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.6, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.2, 	scale_y = -0.1, 	is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 0.3, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/boat"
		},
		["Blackhawk"] = {
			["driver"] = 				{ scale_x = -0.25, 	scale_y = -0.2, 	is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.25, 	scale_y = -0.2, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.25, 	scale_y = 0.2, 		is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.25, 	scale_y = 0.2, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/blackhawk"
		},
		["Bike"] = {
			["driver"] = 				{ scale_x = -0.02, 	scale_y = 0.35, 	is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/wolfhud/drivinghud/bike"
		}
	}


	HUDDriving.VEHICLES["Rust's bike"] = deep_clone(HUDDriving.VEHICLES["Bike"])

	HUDDriving._FONT_SIZE = 24
	HUDDriving._MARGIN = 5
	HUDDriving._WIDTH = 300
	HUDDriving._SCALE = 1

	function HUDDriving:init(hud)
		if not hud then
			hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		end
		self._hud_panel = hud.panel
		self._name = ""
		self._people = 0
		self._align = "right"

		self._panel 			= HUDDriving.VerticalListItem:new(self._hud_panel, self, "base_panel", HUDDriving._WIDTH, HUDDriving._FONT_SIZE, { margin = HUDDriving._MARGIN })

		self._vehicle_name 		= HUDDriving.LegendItem:new(self._panel:panel(), self._panel, "vehicle_name", HUDDriving._WIDTH, HUDDriving._FONT_SIZE, { value = "Bobbycar", resizable_w = true })
		self._data 				= HUDDriving.HorizontalListItem:new(self._panel:panel(), self._panel, "data_panel", HUDDriving._WIDTH, HUDDriving.WIDTH, {})

		self._vehicle_image 	= HUDDriving.VehicleImageItem:new(self._data:panel(), self._data, "vehicle_image", HUDDriving._WIDTH / 2, HUDDriving._WIDTH / 2, {})
		self._legend 			= HUDDriving.VerticalListItem:new(self._data:panel(), self._data, "legend_panel", HUDDriving._WIDTH / 2, HUDDriving._WIDTH / 2, {})

		self._legend_health 	= HUDDriving.LegendHealthItem:new(self._legend:panel(), self._legend, "legend_health", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, { suffix = "HP", show_decimal_marks = true })
		self._legend_loot 		= HUDDriving.LegendImageItem:new(self._legend:panel(), self._legend, "legend_loot", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, { texture = "guis/textures/wolfhud/drivinghud/legend", text_rect = {0, 0, 128, 128}, show_max = true })
		self._legend_passengers = HUDDriving.LegendImageItem:new(self._legend:panel(), self._legend, "legend_passengers", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, { texture = "guis/textures/wolfhud/drivinghud/legend", text_rect = {128, 0, 128, 128}, show_max = true })
		self._legend_gear 		= HUDDriving.LegendItem:new(self._legend:panel(), self._legend, "legend_gear", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, {})
		self._legend_speed 		= HUDDriving.LegendItem:new(self._legend:panel(), self._legend, "legend_speed", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, { suffix = "km/h"})
		self._legend_rpm 		= HUDDriving.LegendItem:new(self._legend:panel(), self._legend, "legend_rpm", HUDDriving._WIDTH / 2, HUDDriving._FONT_SIZE, { suffix = "rpm"})

		self._legend:addComponents({ self._legend_health, self._legend_loot, self._legend_passengers, self._legend_gear, self._legend_speed, self._legend_rpm })
		self._data:addComponents({ self._vehicle_image, self._legend })
		self._panel:addComponents({ self._vehicle_name, self._data })

		self:apply_settings()

		self._bg_box = HUDBGBox_create(self._panel:panel(), {
			name = "bg_box",
			halign = "grow",
			valign = "grow",
		})

		if not HUDManager.CUSTOM_TEAMMATE_PANELS then	-- Arrange the position for non-CustomHUD
			local player_hud = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]
			local player_panel = player_hud and player_hud:panel()
			if player_panel then
				self:set_offset(player_panel:h(), "right")
			end
		end

		self._panel:set_enabled("in_vehicle", managers.player:get_vehicle())
	end

	function HUDDriving:start()
		self._active = true
		self._people = 0
		if self._panel:set_enabled("in_vehicle", true) and managers.hud then
			if HUDManager.CUSTOM_TEAMMATE_PANELS then	-- CustomHUD
				managers.hud:arrange_teammate_panels()
			end
		end
	end

	function HUDDriving:stop()
		self._active = false
		if self._panel:set_enabled("in_vehicle", managers.player:get_vehicle()) and managers.hud then
			if HUDManager.CUSTOM_TEAMMATE_PANELS then	-- CustomHUD
				managers.hud:arrange_teammate_panels()
			end
		end
	end

	function HUDDriving:arrange()
		if self._panel then
			if self._align == "left" then
				self._panel:set_left(0)
			else
				self._panel:set_right(self._hud_panel:w())
			end
			self._panel:set_bottom(self._bottom_pos)
		end
	end

	function HUDDriving:apply_settings()
		local settings = WolfHUD:getSetting({"DrivingHUD"}, {})
		self._panel:set_enabled("setting", settings.ENABLED ~= false)
		self._legend_speed:set_text_suffix(settings.SPEED_IN_MPH and "mph" or "km/h")
		self._vehicle_image:set_enabled("setting", settings.SHOW_VEHICLE ~= false)
		self._legend_health:set_enabled("setting", settings.SHOW_HEALTH ~= false)
		self._legend_loot:set_enabled("setting", settings.SHOW_LOOT ~= false)
		self._legend_passengers:set_enabled("setting", settings.SHOW_PASSENGERS ~= false)
		self._legend_gear:set_enabled("setting", settings.SHOW_GEAR ~= false)
		self._legend_speed:set_enabled("setting", settings.SHOW_SPEED ~= false)
		self._legend_rpm:set_enabled("setting", settings.SHOW_RPM ~= false)

		local scale = settings.SCALE or 1
		if scale ~= HUDDriving._SCALE then
			self._panel:rescale(scale / HUDDriving._SCALE)
			HUDDriving._SCALE = scale
		end
	end

	function HUDDriving:set_offset(offset, align)
		self._bottom_pos = self._hud_panel:h() - offset
		if align and self._align ~= align then
			self._panel:set_align(align)
		end
		if self._panel:bottom() ~= self._bottom_pos or self._align ~= align then
			self._align = align
			self:arrange()
		end
	end

	function HUDDriving:panel()
		return self._panel
	end

	function HUDDriving:active()
		return self._active
	end

	function HUDDriving:set_vehicle_state(speed, rpm, gear, people, people_total, name, seats_table, loot_current, loot_total, health_current, health_total)
		self._legend_passengers:set_max_value(people_total)
		self._legend_loot:set_max_value(loot_total)
		self._legend_health:set_max_value(health_total)

		self._legend_health:set_value(math.round(health_current))
		self._legend_loot:set_value(loot_current)
		self._legend_passengers:set_value(people)
		self._legend_gear:set_value(gear)
		self._legend_speed:set_value(math.round(speed))
		self._legend_rpm:set_value(rpm)

		if self._name ~= name then
			self._name = name
			self._vehicle_name:set_value(self._name and string.upper(tostring(self._name)))

			self._vehicle_image:set_vehicle_name(self._name or "Unknown")
			self._people = 0
		end
		if self._people ~= people then
			self._people = people

			self._vehicle_image:set_passengers(seats_table)
		end
	end

	local function ReverseTable(tbl)
		for i=1, math.floor(#tbl / 2) do
			local tmp = tbl[i]
			tbl[i] = tbl[#tbl - i + 1]
			tbl[#tbl - i + 1] = tmp
		end
	end

	HUDDriving.BasicItem = HUDDriving.BasicItem or class()
	function HUDDriving.BasicItem:init(base_panel, owner, name, width, height, params)
		self._name = name
		self._owner_panel = base_panel
		self._owner = owner
		self._disable_reason = {}
		self._align = "right"
		self._margin = params.margin or 0
		self._resizable_w = params.resizable_w or params.resizable or false
		self._resizable_h = params.resizable_h or params.resizable or false

		self._panel = self._owner_panel:panel({
			name = name,
			h = (height or 0) + 2 * self._margin,
			w = (width or 0) + 2 * self._margin,
		})
	end

	function HUDDriving.BasicItem:destroy()
		self._panel:stop()
		self._owner_panel:remove(self._panel)
	end

	function HUDDriving.BasicItem:resizable_w()
		return self._resizable_w
	end

	function HUDDriving.BasicItem:resizable_h()
		return self._resizable_h
	end

	function HUDDriving.BasicItem:set_resizable(resizable_w, resizable_h)
		if self._resizable_w ~= resizable_w or self._resizable_h ~= resizable_h then
			self._resizable_w = resizable_w
			self._resizable_h = resizable_h
			self._owner:arrange()
		end
	end

	function HUDDriving.BasicItem:enabled()
		return next(self._disable_reason) == nil
	end

	function HUDDriving.BasicItem:set_enabled(reason, status)
		self._disable_reason[reason] = (not status) and true or nil

		local visible = next(self._disable_reason) == nil
		if self._panel:visible() ~= visible then
			self._panel:set_visible(visible)
			self._owner:arrange()
			return true
		end
	end

	function HUDDriving.BasicItem:set_align(align)
		if self._align ~= align then
			self._align = align
			return true
		end
	end

	function HUDDriving.BasicItem:set_size(w, h)
		w = w and (w + 2 * self._margin) or self._panel:w()
		h = h and (h + 2 * self._margin) or self._panel:h()

		if self._panel:w() ~= w or self._panel:h() ~= h then
			self._panel:set_size(w, h)
			return true
		end
	end

	function HUDDriving.BasicItem:arrange()

	end

	function HUDDriving.BasicItem:rescale(factor)
		if factor and factor ~= 1 then
			self:set_size(self:w() * factor, self:h() * factor)
			return true
		end
	end

	function HUDDriving.BasicItem:panel() return self._panel end
	function HUDDriving.BasicItem:alpha() return self._panel:alpha() end
	function HUDDriving.BasicItem:w() return self._panel:w() end
	function HUDDriving.BasicItem:h() return self._panel:h() end
	function HUDDriving.BasicItem:x() return self._panel:x() end
	function HUDDriving.BasicItem:y() return self._panel:y() end
	function HUDDriving.BasicItem:left() return self._panel:left() end
	function HUDDriving.BasicItem:right() return self._panel:right() end
	function HUDDriving.BasicItem:top() return self._panel:top() end
	function HUDDriving.BasicItem:bottom() return self._panel:bottom() end
	function HUDDriving.BasicItem:center() return self._panel:center() end
	function HUDDriving.BasicItem:center_x() return self._panel:center_x() end
	function HUDDriving.BasicItem:center_y() return self._panel:center_y() end
	function HUDDriving.BasicItem:visible() return self._panel:visible() end
	function HUDDriving.BasicItem:layer() return self._panel:layer() end
	function HUDDriving.BasicItem:text_rect() return self:x(), self:y(), self:w(), self:h() end

	function HUDDriving.BasicItem:set_alpha(v) self._panel:set_alpha(v) end
	function HUDDriving.BasicItem:set_x(v) self._panel:set_x(v) end
	function HUDDriving.BasicItem:set_y(v) self._panel:set_y(v) end
	function HUDDriving.BasicItem:set_left(v) self._panel:set_left(v) end
	function HUDDriving.BasicItem:set_right(v) self._panel:set_right(v) end
	function HUDDriving.BasicItem:set_top(v) self._panel:set_top(v) end
	function HUDDriving.BasicItem:set_bottom(v) self._panel:set_bottom(v) end
	function HUDDriving.BasicItem:set_center(x, y) self._panel:set_center(x, y) end
	function HUDDriving.BasicItem:set_center_x(v) self._panel:set_center_x(v) end
	function HUDDriving.BasicItem:set_center_y(v) self._panel:set_center_y(v) end
	function HUDDriving.BasicItem:set_layer(v) self._panel:set_layer(v) end

	HUDDriving.HorizontalListItem = HUDDriving.HorizontalListItem or class(HUDDriving.BasicItem)
	function HUDDriving.HorizontalListItem:init(base_panel, owner, name, width, height, params)
		HUDDriving.HorizontalListItem.super.init(self, base_panel, owner, name, width, height, params)

		self._components = params.components or {}

		if next(self._components) ~= nil then
			self:arrange()
		end
	end

	function HUDDriving.HorizontalListItem:add(component, position)
		if component then
			local pos = position or #self._components + 1
			table.insert(self._components, pos, component)
			self:arrange()
		end
	end

	function HUDDriving.HorizontalListItem:addComponents(components)
		if components and type(components) == "table" then
			local component_offset = table.size(self._components) or 0
			for i, component in ipairs(components) do
				table.insert(self._components, i + component_offset, component)
			end
			self:arrange()
		end
	end

	function HUDDriving.HorizontalListItem:set_align(align)
		if HUDDriving.HorizontalListItem.super.set_align(self, align) then
			ReverseTable(self._components)
			for i, component in ipairs(self._components) do
				component:set_align(align)
			end
			self:arrange()
		end
	end

	function HUDDriving.HorizontalListItem:arrange()
		local w = self._margin
		local h = self._margin
		local resize_components = {}
		for i, component in ipairs(self._components) do
			if component:enabled() then
				component:set_x(w)
				component:set_y(self._margin)
				if component:resizable_h() then
					table.insert(resize_components, component)
					local _, _, comp_w, comp_h = component:text_rect()
					h = math.max(h, comp_h or 0)
				else
					h = math.max(h, component:h())
				end
				w = w + component:w()
			end
		end
		for i, component in ipairs(resize_components) do
			component:set_size(nil, h)
		end
		if self:set_size(w - self._margin, h) then
			self._owner:arrange()
		end
	end

	function HUDDriving.HorizontalListItem:rescale(factor)
		if HUDDriving.HorizontalListItem.super.rescale(self, factor) then
			for i, component in ipairs(self._components) do
				component:rescale(factor)
			end
			self:arrange()
		end
	end

	HUDDriving.VerticalListItem = HUDDriving.VerticalListItem or class(HUDDriving.BasicItem)
	function HUDDriving.VerticalListItem:init(base_panel, owner, name, width, height, params)
		HUDDriving.VerticalListItem.super.init(self, base_panel, owner, name, width, height, params)

		self._components = params.components or {}

		if next(self._components) ~= nil then
			self:arrange()
		end
	end

	function HUDDriving.VerticalListItem:add(component, position)
		if component then
			local pos = position or #self._components + 1
			table.insert(self._components, pos, component)
			self:arrange()
		end
	end

	function HUDDriving.VerticalListItem:addComponents(components)
		if components and type(components) == "table" then
			local component_offset = table.size(self._components) or 0
			for i, component in ipairs(components) do
				table.insert(self._components, i + component_offset, component)
			end
			self:arrange()
		end
	end

	function HUDDriving.VerticalListItem:set_align(align)
		if HUDDriving.VerticalListItem.super.set_align(self, align) then
			for i, component in ipairs(self._components) do
				component:set_align(align)
			end
			self:arrange()
		end
	end

	function HUDDriving.VerticalListItem:arrange()
		local w = self._margin
		local h = self._margin
		local resize_components = {}
		for i, component in ipairs(self._components) do
			if component:enabled() then
				component:set_x(self._margin)
				component:set_y(h)
				if component:resizable_w() then
					table.insert(resize_components, component)
					local _, _, comp_w, comp_h = component:text_rect()
					w = math.max(w, comp_w or 0)
				else
					w = math.max(w, component:w())
				end
				h = h + component:h()
			end
		end
		for i, component in ipairs(resize_components) do
			component:set_size(w, nil)
		end
		if self:set_size(w, h - self._margin) then
			self._owner:arrange()
		end
	end

	function HUDDriving.VerticalListItem:rescale(factor)
		if HUDDriving.VerticalListItem.super.rescale(self, factor) then
			for i, component in ipairs(self._components) do
				component:rescale(factor)
			end
			self:arrange()
		end
	end

	HUDDriving.VehicleImageItem = HUDDriving.VehicleImageItem or class(HUDDriving.BasicItem)
	function HUDDriving.VehicleImageItem:init(base_panel, owner, name, width, height, params)

		HUDDriving.VehicleImageItem.super.init(self, base_panel, owner, name, width, height, params)

		self._passengers = {}
		self._texture = params.texture or "guis/textures/wolfhud/drivinghud/longfellow"
		self._texture_rect = params.text_rect or { 0, 0, 512, 512}

		self._image = self._panel:bitmap({
			name 			= "vehicle_image",
			blend_mode 		= "normal",
			layer			= 2,
			w 				= self._panel:w(),
			h 				= self._panel:h()
		})
		self._image:set_center(self._panel:center())

		self:_set_image(self._texture, self._texture_rect)
	end

	function HUDDriving.VehicleImageItem:set_vehicle_name(name)
		if self._image and self._vehicle_name ~= name then
			self._vehicle_name = name
			self._vehicle_table = HUDDriving.VEHICLES[self._vehicle_name]
			if self._vehicle_table then
				self._texture = self._vehicle_table and self._vehicle_table.texture
				self._texture_rect = self._vehicle_table and self._vehicle_table.texture_rect
				if self._texture and self._texture_rect then
					self:_set_image(self._texture, self._texture_rect)
				end
				self:create_seats()
			else
				self:set_enabled("vehicle_table", false)
			end
		end
	end

	function HUDDriving.VehicleImageItem:_set_image(texture, text_rect)
		if self._image then
			self._texture = texture or self._texture
			self._texture_rect = text_rect or self._texture_rect
			self._image:set_image(self._texture, unpack(self._texture_rect))
		end
	end

	function HUDDriving.VehicleImageItem:set_color(color)
		if self._image then
			self._image:set_color(color)
		end
	end

	function HUDDriving.VehicleImageItem:create_seats()
		if self._vehicle_table then
			self:set_enabled("vehicle_table", true)
			for seat_name, seat in pairs(self._vehicle_table) do
				if seat.is_seat then
					self._passengers[seat_name] = self._passengers[seat_name] or HUDDriving.VehiclePassengerItem:new(self._panel, self, seat_name, 35 * HUDDriving._SCALE, 35 * HUDDriving._SCALE, {})
					local passenger = self._passengers[seat_name]
					local scale_x = math.clamp(seat.scale_x, -1, 1)
					local scale_y = math.clamp(seat.scale_y, -1, 1)
					passenger:set_position(scale_x, scale_y)
				end
			end
			for name, passenger in pairs(self._passengers) do
				passenger:set_enabled("occupant", false)
			end
		else
			self:set_enabled("vehicle_table", false)
		end
	end

	function HUDDriving.VehicleImageItem:set_passengers(passengers)
		for i, seat in pairs(passengers) do
			local passenger_item = self._passengers[seat.name]
			if passenger_item then
				if alive(seat.occupant) then
					passenger_item:set_passenger(seat.occupant)
					passenger_item:set_enabled("occupant", true)
				else
					passenger_item:set_enabled("occupant", false)
				end
			end
		end
	end

	function HUDDriving.VehicleImageItem:set_size(w, h)
		if HUDDriving.VehicleImageItem.super.set_size(self, w, h) then
			self._image:set_w(self:w())
			self._image:set_h(self:h())

			self:arrange()
		end
	end

	function HUDDriving.VehicleImageItem:rescale(factor)
		if HUDDriving.VehicleImageItem.super.rescale(self, factor) then
			for name, passenger in pairs(self._passengers) do
				if passenger then
					passenger:rescale(factor)
				end
			end
		end
	end

	HUDDriving.VehiclePassengerItem = HUDDriving.VehiclePassengerItem or class(HUDDriving.BasicItem)
	function HUDDriving.VehiclePassengerItem:init(base_panel, owner, name, width, height, params)

		HUDDriving.VehiclePassengerItem.super.init(self, base_panel, owner, name, width, height, params)

		self._unit = params.unit or nil
		self._mask_id = params.mask_id or "alienware"
		self._color = params.color or tweak_data.chat_colors[5]
		self._scale_x = 0
		self._scale_y = 0

		self._image = self._panel:bitmap({
			name 			= "vehicle_image",
			blend_mode 		= "normal",
			layer			= 3,
			w 				= self._panel:w(),
			h 				= self._panel:h()
		})
		self._image:set_center(self._panel:center())

		self:_set_passenger()
		self:arrange()
	end

	function HUDDriving.VehiclePassengerItem:set_passenger(unit)
		if unit and (not self._unit or self._unit:key() ~= unit:key()) then
			local peer = managers.network:session():peer_by_unit(unit)
			local outfit = peer and peer:blackmarket_outfit()
			local character_data = managers.criminals:character_static_data_by_unit(unit)
			local mask_id = outfit and outfit.mask and outfit.mask.mask_id or character_data and character_data.ai_mask_id or "alienware"
			local color_id = managers.criminals:character_color_id_by_unit(unit) or 5
			local color = tweak_data.chat_colors[color_id]

			if mask_id ~= self._mask_id or self._color ~= color then
				self._mask_id = mask_id
				self._color = color
				self:_set_passenger()
			end
			self._unit = unit
		end
	end

	function HUDDriving.VehiclePassengerItem:_set_passenger()
		if self._mask_id then
			local tweak_entry = tweak_data.blackmarket.masks
			local texture = tweak_entry and tweak_entry[self._mask_id].custom_texture
			if tweak_entry and not texture then
				local bundle_folder = tweak_entry[self._mask_id] and tweak_entry[self._mask_id].texture_bundle_folder
				local guis_catalog = string.format("guis/%s", bundle_folder and string.format("dlcs/%s/", tostring(bundle_folder)) or "")
				local texture_name = tweak_entry[self._mask_id] and tweak_entry[self._mask_id].texture_name or tostring(self._mask_id)
				texture = string.format("%s%s%s", guis_catalog, "textures/pd2/blackmarket/icons/masks/", texture_name)
			end
			self._image:set_image(texture)
		end
		if self._color then
			self._image:set_color(self._color)
		end
	end

	function HUDDriving.VehiclePassengerItem:set_position(scale_x, scale_y)
		self._scale_x = scale_x
		self._scale_y = scale_y
		self:arrange()
	end

	function HUDDriving.VehiclePassengerItem:set_size(w, h)
		if HUDDriving.VehiclePassengerItem.super.set_size(self, w, h) then
			self._image:set_w(w)
			self._image:set_h(h)
			self._image:set_center(w / 2, h / 2)

			self:arrange()
		end
	end

	function HUDDriving.VehiclePassengerItem:arrange()
		local parent_w, parent_h = self._owner:w(), self._owner:h()
		local w2, h2 = self:w() / 2, self:h() / 2
		local x, y = (parent_w / 2) * (self._scale_x + 1), (parent_h / 2) * (self._scale_y + 1)

		self._panel:set_center(math.min(math.max(w2, x), parent_w - w2), math.min(math.max(h2, y), parent_h - h2))
	end

	HUDDriving.LegendItem = HUDDriving.LegendItem or class(HUDDriving.BasicItem)
	function HUDDriving.LegendItem:init(base_panel, owner, name, width, height, params)

		HUDDriving.LegendItem.super.init(self, base_panel, owner, name, width, height, params)

		self._text_suffix = params.suffix and tostring(params.suffix) or ""
		self._show_max_value = params.show_max or false
		self._show_decimal_marks = params.show_decimal_marks or false
		self._max_value = params.max_value or 1
		self._value = params.value or 0

		self._text = self._panel:text({
			name = name,
			color = Color.white,
			align = "center",
			vertical = "center",
			layer = 2,
			font_size = height * 0.95,
			font = "fonts/font_medium_shadow_mf",
		})

		self:_set_value()
	end

	function HUDDriving.LegendItem:text_rect() return self._text:text_rect() end

	function HUDDriving.LegendItem:set_value(value)
		if value ~= self._value then
			self._value = value
			self:_set_value()
		end
	end

	function HUDDriving.LegendItem:_set_value()
		if self._value and tostring(self._value):len() > 0 then
			self:set_enabled("valid_value", true)
			local text = tostring(self._value)

			if self._show_decimal_marks then
				text = managers.money:add_decimal_marks_to_string(text)
			end

			if self._max_value then
				if self._show_max_value then
					local max_str = tostring(self._max_value)
					if self._show_decimal_marks then
						max_str = managers.money:add_decimal_marks_to_string(max_str)
					end
					text = string.format("%s/%s", text, max_str)
				end
			end
			if self._text_suffix then
				text = string.format("%s %s", text, self._text_suffix)
			end

			self._text:set_text(text)
		else
			self:set_enabled("valid_value", false)
		end
	end

	function HUDDriving.LegendItem:set_max_value(value)
		if value and value ~= self._max_value then
			self._max_value = value
			self:_set_value()
		end
	end

	function HUDDriving.LegendItem:set_text_suffix(suffix)
		if suffix then
			self._text_suffix = suffix and tostring(suffix) or ""
			self:_set_value()
		end
	end

	function HUDDriving.LegendItem:set_size(w, h)
		if HUDDriving.LegendItem.super.set_size(self, w, h) then
			self._text:set_w(w or self._text:w())
			self._text:set_h(h or self._text:h())
			self._text:set_font_size((h or self._text:h()) * 0.95)
			self:arrange()
			return true
		end
	end

	HUDDriving.LegendHealthItem = HUDDriving.LegendHealthItem or class(HUDDriving.LegendItem)
	function HUDDriving.LegendHealthItem:init(base_panel, owner, name, width, height, params)
		HUDDriving.LegendHealthItem.super.init(self, base_panel, owner, name, width, height, params)

		self._health_texture_rect = { 2, 18, 232,	11 }
		self._value = 1
		self._value_ratio = 1
		self._health_offset = 1

		self._health_bar = self._panel:bitmap({
			name 			= "health_bar",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= self._health_texture_rect,
			blend_mode 		= "normal",
			layer			= 1,
			x 				= self._health_offset,
			y				= self._health_offset,
			w 				= self._panel:w() * 0.95 - (2 * self._health_offset),
			h 				= self._panel:h() * 0.95 - (2 * self._health_offset)
		})
		self._health_shield = self._panel:bitmap({
			name 			= "unit_shield",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 1, 1, 236, 13 },
			blend_mode 		= "normal",
			layer			= 1,
			x 				= 0,
			y				= 0,
			w 				= self._panel:w() * 0.95,
			h 				= self._panel:h() * 0.95
		})

		self._health_bar:set_center(self._panel:center())
		self._health_shield:set_center(self._panel:center())

		self:_set_value()
	end

	function HUDDriving.LegendHealthItem:set_size(w, h)
		if HUDDriving.LegendHealthItem.super.set_size(self, w, h) then
			self._health_shield:set_w(self:w() * 0.95)
			self._health_shield:set_h(self:h() * 0.95)

			self._health_bar:set_w((self._health_shield:w() - (2 * self._health_offset)) * math.clamp(self._value_ratio, 0, 1))
			self._health_bar:set_h(self._health_shield:h() - (2 * self._health_offset))

			self:arrange()
		end
	end

	function HUDDriving.LegendHealthItem:arrange()
		HUDDriving.LegendHealthItem.super.arrange(self)
		if alive(self._health_bar) and alive(self._health_shield) then
			self._health_shield:set_center(self._panel:center())
			self._health_bar:set_left(self._health_shield:left() + self._health_offset)
			self._health_bar:set_center_y(self._health_shield:center_y())
		end
	end

	function HUDDriving.LegendHealthItem:rescale(factor)
		if factor and factor ~= 1 then
			self._health_offset = self._health_offset * factor
		end

		HUDDriving.LegendHealthItem.super.rescale(self, factor)
	end

	function HUDDriving.LegendHealthItem:_set_value()
		HUDDriving.LegendHealthItem.super._set_value(self)
		if self._value and self._max_value then
			self._value_ratio = math.clamp(self._value / self._max_value, 0, 1)
			if alive(self._health_bar) then
				self._health_bar:set_w(self._value_ratio * (self._health_shield:w() - (2 * self._health_offset)))
				self._health_bar:set_texture_rect(self._health_texture_rect[1], self._health_texture_rect[2], self._health_texture_rect[3] * self._value_ratio, self._health_texture_rect[4])
			end

			local color
			if self._value_ratio < 0.05 then
				color = Color.red
			elseif self._value_ratio < 0.15 then
				color = Color.yellow
			else
				color = Color.white
			end
			self._text:set_color(color)
		end
	end

	HUDDriving.LegendImageItem = HUDDriving.LegendImageItem or class(HUDDriving.LegendItem)
	function HUDDriving.LegendImageItem:init(base_panel, owner, name, width, height, params)
		HUDDriving.LegendImageItem.super.init(self, base_panel, owner, name, width, height, params)

		local texture, texture_rect = params.texture , params.text_rect

		self._icon = self._panel:bitmap({
			name 			= "icon",
			align 			= "center",
			vertical		= "center",
			texture 		= texture,
			texture_rect 	= texture_rect,
			blend_mode 		= "normal",
			w				= height * 0.75,
			h 				= height * 0.75,
		})

		self._icon:set_right(self._panel:right())
		self._icon:set_center_y(self._panel:center_y())
	end

	function HUDDriving.LegendImageItem:set_size(w, h)
		if HUDDriving.LegendImageItem.super.set_size(self, w, h) then
			self._icon:set_size(self:h() * 0.75, self:h() * 0.75)

			self:arrange()
		end
	end

	function HUDDriving.LegendImageItem:set_align(align)
		if HUDDriving.LegendImageItem.super.set_align(self, align) then
			self:arrange()
		end
	end

	function HUDDriving.LegendImageItem:arrange()
		HUDDriving.LegendImageItem.super.arrange(self)
		if alive(self._icon) then
			if self._align == "left" then
				self._icon:set_left(0)
			else
				self._icon:set_right(self:w())
			end
			if alive(self._text) then
				self._icon:set_center_y(self:h() / 2)
			end
		end
	end

elseif string.lower(RequiredScript) == "lib/states/ingamedriving" then
	CloneClass(IngameDriving)

	function IngameDriving:_number_in_the_vehicle(vehicle_driving)
		local used, total = 0, 0
		for _, seat in pairs(vehicle_driving._seats) do
			total = total + 1
			if alive(seat.occupant) then
				used = used + 1
			end
		end
		return used, total
	end

	function IngameDriving:_update_driving_hud()
		local pm_vehicle = managers.player and managers.player:get_vehicle()
		local vehicle_unit = pm_vehicle and pm_vehicle.vehicle_unit
		local vehicle = vehicle_unit and vehicle_unit:vehicle()
		if vehicle and vehicle_unit then
			local vehicle_state = vehicle:get_state()
			local speed = vehicle_state:get_speed() * 3.6
			local rpm = vehicle_state:get_rpm()
			local gear = vehicle_state:get_gear() - 1
			local vehicle_driving = vehicle_unit:vehicle_driving()
			local no_used_seats, no_total_seats = self:_number_in_the_vehicle(vehicle_driving)
			local vehicle_name = vehicle_driving._tweak_data.name
			local seats_table = vehicle_driving._seats
			local health_total = math.min(vehicle_unit:character_damage()._current_max_health, 999999999)
			local health_current = math.clamp(vehicle_unit:character_damage()._health, 0, health_total)
			local loot_current = #vehicle_driving._loot
			local loot_total = vehicle_driving._tweak_data.max_loot_bags

			if gear == 0 or rpm == 0 then
				gear = "N"
			elseif gear < 0 then
				gear = "R"
				speed = -speed
			end

			if WolfHUD:getSetting({"DrivingHUD", "SPEED_IN_MPH"}, false) then
				speed = speed / 1.60934
			end

			managers.hud:set_driving_vehicle_state(speed, rpm, gear, no_used_seats, no_total_seats, vehicle_name, seats_table, loot_current, loot_total, math.max(0, health_current), health_total)
		end
	end

	function IngameDriving:update(t, dt)
		self:_update_driving_hud()
		self.orig.update(self, t, dt)
	end

	function IngameDriving.at_enter(self, old_state, ...)
		self.orig.at_enter(self, old_state, ...)
		managers.hud:start_driving()
	end

	function IngameDriving:at_exit()
		managers.hud:stop_driving()
		self.orig.at_exit(self)
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2

	function HUDManager:_setup_player_info_hud_pd2()
		_setup_player_info_hud_pd2_original(self)
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		self:create_driving_hud(hud)
	end

	function HUDManager:create_driving_hud(hud)
		print("HUDManager:create_driving_hud()")
		self._hud_driving = HUDDriving:new(hud)
	end

	function HUDManager:set_driving_vehicle_state(speed, rpm, gear, people, people_total, name, seats_table, loot_current, loot_total, health_current, health_total)
		self._hud_driving:set_vehicle_state(speed, rpm, gear, people, people_total, name, seats_table, loot_current, loot_total, health_current, health_total)
	end

	function HUDManager:change_drivinghud_setting(setting, value)
		if self._hud_driving and self._hud_driving.apply_settings then
			self._hud_driving:apply_settings()
		end
	end
end