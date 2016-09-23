-- TODO: Update Seat offset scales...

if string.lower(RequiredScript) == "lib/managers/hud/huddriving" then
	HUDDriving.VEHICLES = {
		["Longfellow"] = {
			["driver"] = 				{ scale_x = -0.2, 	scale_y = -0.15, 	is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.15, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.2, 	scale_y = 0.25, 	is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 0.25, 	is_seat = true },
			texture_rect = { 1024, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Falcogini"] = {
			["driver"] = 				{ scale_x = -0.2, 	scale_y = 0, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = 0, 		is_seat = true },
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Forklift"] = {
			["driver"] = 				{ scale_x = 0, 		scale_y = 0.4, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0, 		scale_y = 0.9, 		is_seat = true },
			texture_rect = { 512, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Truck"] = {
			["driver"] = 				{ scale_x = -0.15, 	scale_y = -0.4,		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.4,		is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.15, 	scale_y = 1, 		is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 1, 		is_seat = true },
			texture_rect = { 0, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Rib Boat"] = {
			["driver"] = 				{ scale_x = 0, 		scale_y = 1, 		is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.6, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.2, 	scale_y = -0.1, 	is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 0.3, 		is_seat = true },
			texture_rect = { 512, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Blackhawk"] = {
			["driver"] = 				{ scale_x = -0.2, 	scale_y = -0.2, 	is_seat = true },
			["passenger_front"] = 		{ scale_x = 0.2, 	scale_y = -0.2, 	is_seat = true },
			["passenger_back_left"] = 	{ scale_x = -0.2, 	scale_y = 0.2, 		is_seat = true },
			["passenger_back_right"] = 	{ scale_x = 0.2, 	scale_y = 0.2, 		is_seat = true },
			texture_rect = { 1024, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Bike"] = {
			["driver"] = 				{ scale_x = -0.02, 	scale_y = 0.35, 	is_seat = true },
			texture_rect = { 1536, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		}
	}
	
	HUDDriving.VEHICLES["Rust's bike"] = deep_clone(HUDDriving.VEHICLES["Bike"])
	
	HUDDriving._FONT_SIZE = 24
	HUDDriving._MARGIN = 10
	HUDDriving._WIDTH = 300

	function HUDDriving:init(hud)
		if not hud then
			hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		end
		self._hud_panel = hud.panel
		self._name = ""
		self._people = 0
		self._align = "right"
		
		self._panel = self._hud_panel:panel({
			w = HUDDriving._WIDTH,
			h = 180,
			name = "drivingpanel",
			visible = false
		})
		
		self._panel:set_right(self._hud_panel:right())
		self._panel:set_top(self._hud_panel:center_y())
		
		self._bg_box = HUDBGBox_create(self._panel, {
			name = "bg_box",
			halign = "grow",
			valign = "grow",
		})
		
		self._vehicle_name 		= HUDDriving.LegendItem:new(self._panel, self, "vehicle_name", self._panel:w(), HUDDriving._FONT_SIZE, { value = "Bobbycar"})
		self._vehicle_image 	= HUDDriving.VehicleImageItem:new(self._panel, self, "vehicle_image", self._panel:h() - HUDDriving._FONT_SIZE, self._panel:h() - HUDDriving._FONT_SIZE, {})
		
		self._vehicle_image:panel():set_top(self._vehicle_name:panel():bottom())
		self._vehicle_image:panel():set_left(HUDDriving._MARGIN)
		
		self._legend = self._panel:panel({
			name = "legend",
			x = self._vehicle_image:panel():right(),
			y = self._vehicle_name:panel():bottom() + HUDDriving._MARGIN,
			w = self._panel:w() - self._vehicle_image:panel():w() - 2 * HUDDriving._MARGIN,
			h = self._vehicle_image:panel():h()
		})
		
		self._legend_health 	= HUDDriving.LegendHealthItem:new(self._legend, self, "legend_health", self._legend:w(), HUDDriving._FONT_SIZE, {})
		self._legend_loot 		= HUDDriving.LegendImageItem:new(self._legend, self, "legend_loot", self._legend:w(), HUDDriving._FONT_SIZE, { texture = "guis/textures/contact_vlad", text_rect = {1840, 63, 160, 137}, show_max = true })
		self._legend_passengers = HUDDriving.LegendImageItem:new(self._legend, self, "legend_passengers", self._legend:w(), HUDDriving._FONT_SIZE, { texture = "guis/textures/contact_vlad", text_rect = {1920, 256, 128, 130}, show_max = true })
		self._legend_gear 		= HUDDriving.LegendItem:new(self._legend, self, "legend_gear", self._legend:w(), HUDDriving._FONT_SIZE, {})
		self._legend_speed 		= HUDDriving.LegendItem:new(self._legend, self, "legend_speed", self._legend:w(), HUDDriving._FONT_SIZE, { suffix = "km/h"})
		self._legend_rpm 		= HUDDriving.LegendItem:new(self._legend, self, "legend_rpm", self._legend:w(), HUDDriving._FONT_SIZE, { suffix = "rpm"})
		
		self._legend_components = { self._legend_health, self._legend_loot, self._legend_passengers, self._legend_gear, self._legend_speed, self._legend_rpm }
		
		
		self:apply_settings()
		self:arrange()
	end

	function HUDDriving:start()
		self._active = true
		self._people = 0
		self._panel:set_visible(WolfHUD:getSetting("use_drivinghud", "boolean"))
		if managers.hud and managers.hud.arrange_teammate_panels then
			managers.hud:arrange_teammate_panels()
		end
	end
	
	function HUDDriving:stop()
		self._active = false
		self._panel:set_visible(false)
		if managers.hud and managers.hud.arrange_teammate_panels then
			managers.hud:arrange_teammate_panels()
		end
	end
	
	function HUDDriving:arrange()
		local y = 0
		for id, component in ipairs(self._legend_components) do
			if component:enabled() then
				component:panel():set_y(y)
				y = y + component:panel():h()
			end
		end	
		self._legend:set_h(y)
		
		if self._vehicle_image:enabled() then
			self._panel:set_w(HUDDriving._WIDTH)
			self._panel:set_h(self._vehicle_image:panel():h() + HUDDriving._FONT_SIZE + 2 * HUDDriving._MARGIN)
			self._legend:set_left(self._vehicle_image:panel():right())
			y = math.max(y + HUDDriving._MARGIN, self._vehicle_image:panel():h())
		else
			self._panel:set_w(HUDDriving._WIDTH - self._vehicle_image:panel():w())
			self._panel:set_h(y + HUDDriving._FONT_SIZE + 2 * HUDDriving._MARGIN)
			self._legend:set_left(HUDDriving._MARGIN)
		end
		self._vehicle_name:panel():set_w(self._panel:w())
		self._vehicle_name:arrange()
	end
	
	function HUDDriving:apply_settings()
		if WolfHUD:getSetting("use_drivinghud", "boolean") and self:active() and not self:panel():visible() then
			self:start()
		elseif not WolfHUD:getSetting("use_drivinghud", "boolean") and self:active() and self:panel():visible() then
			self:stop()
			self._active = true
		end
		self._legend_speed:set_text_suffix(WolfHUD:getSetting("speed_in_mph", "boolean") and "mph" or "km/h")
		local healthbar_changed	= self._legend_health:set_enabled(WolfHUD:getSetting("show_car_healthbar", "boolean"))
		local image_changed		= self._vehicle_image:set_enabled(WolfHUD:getSetting("show_vehicle", "boolean"))
		if healthbar_changed or	image_changed then
			self:arrange()
		end
		if self._align then
			if self._align == "left" then
				self._panel:set_left(0)
			else
				self._panel:set_right(self._hud_panel:w())
			end
		end
	end
	
	function HUDDriving:set_offset(offset, align)
		self._panel:set_bottom(self._hud_panel:h() - offset)
		if align and self._align ~= align then
			if align == "left" then
				self._panel:set_left(0)
			else
				self._panel:set_right(self._hud_panel:w())
			end
			self._align = align
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
		
		self._legend_health:set_value(health_current)
		self._legend_loot:set_value(loot_current)
		self._legend_passengers:set_value(people)
		self._legend_gear:set_value(gear)
		self._legend_speed:set_value(math.round(speed))
		self._legend_rpm:set_value(rpm)
		
		if self._name ~= name then
			self._name = name
			self._vehicle_name:set_value(string.upper(self._name))
			
			local car_table = HUDDriving.VEHICLES[self._name]
			if self._vehicle_image:enabled() then
				if self._vehicle_image:set_enabled(car_table and true or false) then
					self:arrange()
				end
			end
			self._vehicle_image:set_vehicle_name(self._name)
			self._people = 0
		end
		if self._people ~= people then
			self._people = people
			
			self._vehicle_image:set_passengers(seats_table)
		end
	end
	
	
	HUDDriving.BasicItem = HUDDriving.BasicItem or class()
	function HUDDriving.BasicItem:init(base_panel, owner, name, width, height, params)
		self._name = name
		self._owner_panel = base_panel
		self._owner = owner
		self._enabled = true
		
		self._panel = self._owner_panel:panel({
			name = name,
			h = height or 0,
			w = width or 0,
		})
	end
		
	function HUDDriving.BasicItem:panel()
		return self._panel
	end
	
	function HUDDriving.BasicItem:enabled()
		return self._enabled
	end
	
	function HUDDriving.BasicItem:set_enabled(status)
		if self._enabled ~= status then
			self._panel:set_visible(status)
			self._enabled = status
			return true
		end
	end
	
	function HUDDriving.BasicItem:arrange()
	
	end
	
	
	HUDDriving.VehicleImageItem = HUDDriving.VehicleImageItem or class(HUDDriving.BasicItem)
	function HUDDriving.VehicleImageItem:init(base_panel, owner, name, width, height, params)
		
		HUDDriving.VehicleImageItem.super.init(self, base_panel, owner, name, width, height, params)
		
		self._passengers = {}
		self._texture = params.texture or "guis/textures/contact_vlad"
		self._texture_rect = params.text_rect or { 1024, 0, 512, 512}
		
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
			self._texture = self._vehicle_table and self._vehicle_table.texture
			self._texture_rect = self._vehicle_table and self._vehicle_table.texture_rect
			if self._texture and self._texture_rect then
				self:_set_image(self._texture, self._texture_rect)
			end
			self:create_seats()
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
		for name, passenger in pairs(self._passengers) do
			passenger:set_enabled(false)
		end
		for seat_name, seat in pairs(self._vehicle_table) do
			if seat.is_seat then
				self._passengers[seat_name] = self._passengers[seat_name] or HUDDriving.VehiclePassengerItem:new(self._panel, self, seat_name, 50, 30, {})
				local passenger = self._passengers[seat_name]
				local panel_center_x, panel_center_y = self._panel:w() / 2, self._panel:h() / 2
				local scale_x = math.clamp(seat.scale_x, -1, 1)
				local scale_y = math.clamp(seat.scale_y, -1, 1)
				passenger:set_position(panel_center_x * (scale_x + 1), panel_center_y * (scale_y + 1))
			end
		end
	end
	
	function HUDDriving.VehicleImageItem:set_passengers(passengers)
		for i, seat in pairs(passengers) do
			local passenger_item = self._passengers[seat.name]
			if passenger_item then
				if alive(seat.occupant) then
					local color_id = managers.criminals:character_color_id_by_unit(seat.occupant) or 1
					local character_data = managers.criminals:character_data_by_unit(seat.occupant)
					local mask_id = character_data and character_data.mask_id or "guis/textures/pd2/blackmarket/icons/masks/alienware"
					passenger_item:set_passenger(mask_id, tweak_data.chat_colors[color_id])
					passenger_item:set_enabled(true)
				else
					passenger_item:set_enabled(false)
				end
			end
		end
	end
	
	HUDDriving.VehiclePassengerItem = HUDDriving.VehiclePassengerItem or class(HUDDriving.BasicItem)
	function HUDDriving.VehiclePassengerItem:init(base_panel, owner, name, width, height, params)
		
		HUDDriving.VehiclePassengerItem.super.init(self, base_panel, owner, name, width, height, params)
		
		self._mask_id = params.mask_id or "guis/textures/pd2/blackmarket/icons/masks/alienware"
		self._color = params.color or tweak_data.chat_colors[5]
				
		self._image = self._panel:bitmap({
			name 			= "vehicle_image",
			blend_mode 		= "normal",
			layer			= 3,
			w 				= self._panel:w(),
			h 				= self._panel:h()
		})
		self._image:set_center(self._panel:center())
		
		self:_set_passenger(self._mask_id, self._color)
	end
	
	function HUDDriving.VehiclePassengerItem:set_passenger(mask_id, color)
		local changed = false
		if mask_id ~= self._mask_id then
			self._mask_id = mask_id
			changed = true
		end
		if color ~= self._color then
			self._color = color
			changed = true
		end
		if changed then
			self:_set_passenger()
		end
	end
	
	function HUDDriving.VehiclePassengerItem:_set_passenger()
		local tweak_entry = tweak_data.blackmarket.masks
		local bundle_folder = tweak_entry[self._mask_id] and tweak_entry[self._mask_id].texture_bundle_folder
		local guis_catalog = string.format("guis/%s", bundle_folder and string.format("dlcs/%s/", tostring(bundle_folder)) or "")
		local texture_name = tweak_entry[self._mask_id] and tweak_entry[self._mask_id].texture_name or tostring(self._mask_id)
		local texture = string.format("%s%s%s", guis_catalog, "textures/pd2/blackmarket/icons/masks/", texture_name)
		self._image:set_image(texture)
		self._image:set_color(self._color)
	end
	
	function HUDDriving.VehiclePassengerItem:set_position(x, y)
		local parent_w, parent_h = self._owner_panel:w(), self._owner_panel:h()
		local w2, h2 = self._panel:w() / 2, self._panel:h() / 2
		self._panel:set_center(math.min(math.max(w2, x), parent_w - w2), math.min(math.max(h2, y), parent_h - h2))
	end
	
	
	HUDDriving.LegendItem = HUDDriving.LegendItem or class(HUDDriving.BasicItem)
	function HUDDriving.LegendItem:init(base_panel, owner, name, width, height, params)
		
		HUDDriving.LegendItem.super.init(self, base_panel, owner, name, width, height, params)
		
		self._text_suffix = params.suffix and (" " .. tostring(params.suffix)) or ""
		self._show_max_value = params.show_max or false
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
		
		HUDDriving.LegendItem._set_value(self)
	end
	
	function HUDDriving.LegendItem:set_enabled(status)
		if HUDDriving.LegendItem.super.set_enabled(self, status) then
			self._text:set_visible(status)
		end
	end
	
	function HUDDriving.LegendItem:set_value(value)
		if value and value ~= self._value then
			self._value = value
			self:_set_value()
		end
	end
	
	function HUDDriving.LegendItem:_set_value()
		if self._value then
			local text = tostring(self._value)
			if self._max_value then
				if self._show_max_value then
					text = text .. "/" .. self._max_value
				end
			end
			
			self._text:set_text(string.format("%s%s", text, self._text_suffix))
		end
	end
	
	function HUDDriving.LegendItem:set_max_value(value)
		if value and value ~= self._max_value then
			self._max_value = value
		end
	end
	
	function HUDDriving.LegendItem:set_text_suffix(suffix)
		if suffix then
			self._text_suffix = string.format(" %s", suffix)
			self:_set_value()
		end
	end
	
	function HUDDriving.LegendItem:arrange()
		self._text:set_w(self._panel:w())
		self._text:set_h(self._panel:h())
	end
	
	
	HUDDriving.LegendHealthItem = HUDDriving.LegendHealthItem or class(HUDDriving.LegendItem)
	function HUDDriving.LegendHealthItem:init(base_panel, owner, name, width, height, params)
		HUDDriving.LegendHealthItem.super.init(self, base_panel, owner, name, width, height, { suffix = "HP" })
		
		self._health_texture_rect = { 2, 18, 232,	11 }
		
		self._health_bar = self._panel:bitmap({
			name 			= "health_bar",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= self._health_texture_rect,
			blend_mode 		= "normal",
			layer			= 1,
			x 				= 0 + 1,
			y				= 0 + 1,
			w 				= self._panel:w() * 0.95 - 2,
			h 				= self._panel:h() * 0.95 - 2
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
	
	function HUDDriving.LegendHealthItem:set_enabled(status)
		if HUDDriving.LegendHealthItem.super.set_enabled(self, status) then
			self._health_bar:set_visible(status)
			self._health_shield:set_visible(status)
		end
	end
	
	function HUDDriving.LegendHealthItem:_set_value(value)
		HUDDriving.LegendHealthItem.super._set_value(self, value)
		if self._value and self._max_value then
			self._value_ratio = self._value / self._max_value
			self._health_bar:set_w(self._value_ratio * (self._health_shield:w() - 2))
			self._health_bar:set_texture_rect(self._health_texture_rect[1], self._health_texture_rect[2], self._health_texture_rect[3] * self._value_ratio, self._health_texture_rect[4])
			
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
		
		local texture, texture_rect = params.texture or "", params.text_rect or ""
		
		self._icon = self._panel:bitmap({
			name 			= "icon",
			align 			= "right",
			vertical		= "center",
			texture 		= texture,
			texture_rect 	= texture_rect,
			blend_mode 		= "normal",
			w				= height * 0.75,
			h 				= height * 0.75,
		})
		
		self._icon:set_right(self._panel:right())
	end
	
	function HUDDriving.LegendImageItem:set_enabled(status)
		if HUDDriving.LegendImageItem.super.set_enabled(self, status) then
			self._icon:set_visible(status)
		end
	end
	
elseif string.lower(RequiredScript) == "lib/states/ingamedriving" then
	CloneClass(IngameDriving)

	function IngameDriving:_number_in_the_vehicle(vehicle_driving, total)
		local count = 0
		for _, seat in pairs(vehicle_driving._seats) do
			
			if alive(seat.occupant) or total then
				count = count + 1
			end
		end
		return count
	end

	function IngameDriving:_update_driving_hud()
		if managers.player and managers.player:get_vehicle() and managers.player:get_vehicle().vehicle_unit and managers.player:get_vehicle().vehicle_unit:vehicle() then
			local vehicle_unit = managers.player:get_vehicle().vehicle_unit
			local vehicle = vehicle_unit:vehicle()
			local vehicle_state = vehicle:get_state()
			local speed = vehicle_state:get_speed() * 3.6
			local rpm = vehicle_state:get_rpm()
			local gear = vehicle_state:get_gear() - 1
			local vehicle_driving = vehicle_unit:vehicle_driving()
			local no_used_seats = self:_number_in_the_vehicle(vehicle_driving, false)
			local no_total_seats = self:_number_in_the_vehicle(vehicle_driving, true)
			local vehicle_name = vehicle_driving._tweak_data.name
			local seats_table = vehicle_driving._seats
			local health_current = vehicle_unit:character_damage()._health
			local health_total = vehicle_unit:character_damage()._current_max_health
			local loot_current = #vehicle_driving._loot
			local loot_total = vehicle_driving._tweak_data.max_loot_bags
			
			
			if gear == 0 then
				gear = "N"
			elseif gear < 0 then
				gear = "R"
				speed = -speed
			end
			
			if WolfHUD:getSetting("speed_in_mph", "boolean") then
				speed = speed / 1.60934
			end
			managers.hud:set_driving_vehicle_state(speed, rpm, gear, no_used_seats, no_total_seats, vehicle_name, seats_table, loot_current, loot_total, health_current, health_total)
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