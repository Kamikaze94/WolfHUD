if string.lower(RequiredScript) == "lib/managers/hud/huddriving" then
	local main_table = {
		["Longfellow"] = {
			["driver"] = { offset_x = 50, offset_y = 50, binding = "left top", seat = true},
			["passenger_front"] = { offset_x = -50, offset_y = 50, binding = "right top", seat = true},
			["passenger_back_left"] = { offset_x = 50, offset_y = -45, binding = "left bottom", seat = true},
			["passenger_back_right"] = { offset_x = -50, offset_y = -45, binding = "right bottom", seat = true},
			texture_rect = { 1024, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Falcogini"] = {
			["driver"] = { offset_x = 50, offset_y = 70, binding = "left top", seat = true},
			["passenger_front"] = { offset_x = -50, offset_y = 70, binding = "right top", seat = true},
			texture_rect = { 0, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Forklift"] = {
			["driver"] = { offset_x = "center_x", offset_y = 105, binding = "top", seat = true},
			["passenger_front"] = { offset_x = "center_x", offset_y = 5, binding = "bottom", seat = true},
			texture_rect = { 512, 0, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Truck"] = {
			["driver"] = { offset_x = 50, offset_y = 30, binding = "left top", seat = true},
			["passenger_front"] = { offset_x = -45, offset_y = 30, binding = "right top", seat = true},
			["passenger_back_left"] = { offset_x = 50, offset_y = 0, binding = "left bottom", seat = true},
			["passenger_back_right"] = { offset_x = -45, offset_y = 0, binding = "right bottom", seat = true},
			texture_rect = { 0, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Rib Boat"] = {
			["driver"] = { offset_x = "center_x", offset_y = -20, binding = "left bottom", seat = true},
			["passenger_front"] = { offset_x = -55, offset_y = 15, binding = "right top", seat = true},
			["passenger_back_left"] = { offset_x = 45, offset_y = 80, binding = "left top", seat = true},
			["passenger_back_right"] = { offset_x = -45, offset_y = 100, binding = "right top", seat = true},
			texture_rect = { 512, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Blackhawk"] = {
			["driver"] = { offset_x = 45, offset_y = 55, binding = "left top", seat = true},
			["passenger_front"] = { offset_x = -45, offset_y = 55, binding = "right top", seat = true},
			["passenger_back_left"] = { offset_x = 45, offset_y = -55, binding = "left bottom", seat = true},
			["passenger_back_right"] = { offset_x = -45, offset_y = -55, binding = "right bottom", seat = true},
			texture_rect = { 1024, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		},
		["Bike"] = {
			["driver"] = { offset_x = "center_x", offset_y = 105, binding = "top", seat = true},
			texture_rect = { 1536, 512, 512, 512},
			texture = "guis/textures/contact_vlad"
		}
	}
	
	main_table["Rust's bike"] = deep_clone(main_table["Bike"])

	function HUDDriving:init(hud)
		if not hud then
			hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		end
		self._hud_panel = hud.panel
		self._name = ""
		self._markers = {}
		local x_pos, y_pos
		if pdth_hud then
			y_pos = -90
			x_pos = 500
		elseif mod_collection then
			y_pos = -230
			x_pos = 540
		else
			y_pos = -140
			x_pos = 540
		end
		self._people = 0
		self.drivingpanel = self._hud_panel:panel({
			w = self._hud_panel:w(),
			h = self._hud_panel:h(),
			name = "drivingpanel",
			visible = false
		})
		
		local legend_rect_bg = self.drivingpanel:rect({
			name = "legend_rect_bg",
			color = Color.black,
			visible = false,
			layer = 0,
			h = 100,
			w = self._hud_panel:w() - 10,
			x = 1100,
			y = 460,
			valign = "bottom"
		})
		
		self.drivingpanel:text({
			name = "value_speed",
			text = "100 kmph",
			x = x_pos,
			y = y_pos,
			font_size = 32,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		
		self.drivingpanel:text({
			name = "value_RPM",
			text = "7200",
			x = x_pos,
			y = y_pos + 30,
			font_size = 32,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		
		self.drivingpanel:text({
			name = "value_gear",
			text = "N",
			x = x_pos,
			y = y_pos + -30,
			font_size = 32,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		
		local seats = self.drivingpanel:text({
			name = "seats",
			text = "2/4",
			x = x_pos,
			y = y_pos + -60,
			font_size = 32,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		
		local seats_texture_rect = {1920, 256, 128, 130}
		local seats_bitmap = self.drivingpanel:bitmap({
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			name = "seats_bitmap",
			visible = true,
			layer = 1,
			texture = "guis/textures/contact_vlad",
			texture_rect = seats_texture_rect,
			x = self.drivingpanel:w() - (x_pos),
			y = self.drivingpanel:h() + (y_pos + -110),
			w = seats_texture_rect[3] / 4,
			h = seats_texture_rect[4] / 4
		})
		seats_bitmap:set_left(self.drivingpanel:center_x() + ((x_pos + -15) + (seats_bitmap:w())))
		seats_bitmap:set_y(self.drivingpanel:h() + ((y_pos + -105) + (seats_bitmap:h() / 2)))
		
		local loot = self.drivingpanel:text({
			name = "loot",
			text = "2/4",
			x = x_pos,
			y = y_pos + -90,
			font_size = 32,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		local loot_texture_rect = {1840, 63, 160, 137}
		local loot_bitmap = self.drivingpanel:bitmap({
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			name = "loot_bitmap",
			visible = true,
			layer = 1,
			texture = "guis/textures/contact_vlad",
			texture_rect = loot_texture_rect,
			x = self.drivingpanel:w() - (x_pos),
			y = self.drivingpanel:h() + (y_pos + -120),
			w = loot_texture_rect[3] / 8,
			h = loot_texture_rect[4] / 8
		})
		loot_bitmap:set_left(self.drivingpanel:center_x() + (x_pos + loot_bitmap:w()))
		loot_bitmap:set_y(self.drivingpanel:h() + ((y_pos + -120) + (loot_bitmap:h() / 2)))
		
		local vis = WolfHUD:getSetting("show_car_healthbar", "boolean")
		self._health_texture_rect = { 2, 18, 232,	11 }
		self._health_text = self.drivingpanel:text({
			name = "health",
			text = "100000 HP",
			x = x_pos,
			y = y_pos + -120,
			font_size = 24,
			--font = tweak_data.hud.medium_font,
			font = "fonts/font_medium_shadow_mf",
			color = Color.white,
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			layer = 1,
			visible = vis,
			wrap = false,
			word_wrap = false
		})
		self._health_bar = self.drivingpanel:bitmap({
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			name 			= "health_bar",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= self._health_texture_rect,
			blend_mode 		= "normal",
			visible = vis
		})
		self._health_shield = self.drivingpanel:bitmap({
			align = "center",
			vertical = "bottom",
			valign = "bottom",
			name 			= "unit_shield",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 1, 1, 236, 13 },
			blend_mode 		= "normal",
			visible = vis
		})
		self._health_bar:set_left(self.drivingpanel:center_x() + (x_pos + loot_bitmap:w() - 74))
		self._health_bar:set_y(self.drivingpanel:h() + ((y_pos + -154) + (loot_bitmap:h() / 2)))
		self._health_bar:set_w(self._health_bar:w()/2 - 12)
		self._health_bar:set_h(self._health_bar:h() + 15)
		self._health_shield:set_left(self.drivingpanel:center_x() + (x_pos + loot_bitmap:w() - 75))
		self._health_shield:set_y(self.drivingpanel:h() + ((y_pos + -155) + (loot_bitmap:h() / 2)))
		self._health_shield:set_w(self._health_shield:w()/2 - 10)
		self._health_shield:set_h(self._health_shield:h() + 15)
		self._health_text:set_left(self.drivingpanel:center_x() + (x_pos + loot_bitmap:w() - 75))
		self._health_text:set_y(self._health_shield:y())
		self._health_text:set_w(self._health_shield:w())
		self._health_text:set_h(self._health_shield:h() - 3)
		
		local car_texture_rect = { 1024, 0, 512, 512}
		local car_texture = "guis/textures/contact_vlad"
		
		local vis = WolfHUD:getSetting("show_vehicle", "boolean")
		local vehicle_bitmap = self.drivingpanel:bitmap({
			vertical = "bottom",
			align = "left",
			valign = "bottom",
			name = "icon_vehicle",
			visible = vis,
			layer = 1,
			texture = car_texture,
			texture_rect = car_texture_rect,
			x = x_pos + 420,
			y = y_pos + 530,
			w = 180,
			h = 180
		})
		--vehicle_bitmap:set_bottom(seats:top())
		self:update_images()
	end
	function HUDDriving:start()
		self._active = true
		self._people = 0
		self.drivingpanel:set_visible(WolfHUD:getSetting("use_drivinghud", "boolean"))
	end
	function HUDDriving:stop()
		self._active = false
		self.drivingpanel:set_visible(false)
	end
	function HUDDriving:set_vehicle_state(speed, rpm, gear, people, people_total, name, seats_table, loot_current, loot_total, health_current, health_total)
		if WolfHUD:getSetting("speed_in_mph", "boolean") then 
			self.drivingpanel:child("value_speed"):set_text(string.format("%d", speed) .. " mph")
		else
			self.drivingpanel:child("value_speed"):set_text(string.format("%d", speed) .. " km/h")
		end
		self.drivingpanel:child("value_RPM"):set_text(rpm .. " rpm")
		self.drivingpanel:child("value_gear"):set_text(gear)
		self.drivingpanel:child("seats"):set_text(people .. "/" .. people_total)
		self.drivingpanel:child("loot"):set_text(loot_current .. "/" .. loot_total)
		local health_vis = WolfHUD:getSetting("show_car_healthbar", "boolean")
		if health_vis ~= self._health_text then
			self._health_bar:set_visible(health_vis)
			self._health_shield:set_visible(health_vis)
			self._health_text:set_visible(health_vis)
		end
		local health_perc = health_current / health_total
		self._health_text:set_text(math.round(health_current) .. " HP")
		if health_perc < 0.05 then 
			self._health_text:set_color(Color.red) 
		elseif health_perc < 0.15 then 
			self._health_text:set_color(Color.yellow) 
		else
			self._health_text:set_color(Color.white) 
		end
		self._health_bar:set_w(health_perc * (self._health_shield:w() - 2))
		self._health_bar:set_texture_rect(self._health_texture_rect[1], self._health_texture_rect[2], self._health_texture_rect[3] * health_perc, self._health_texture_rect[4])

		if self._name ~= name then
			self._name = name
			self._people = 0
			self:update_images()
		end
		
		if self._people ~= people then
			self._people = people
			for i, seat in pairs(seats_table) do
				
				if alive(seat.occupant) then
					if self.drivingpanel:child(seat.name) then
						local icon = self.drivingpanel:child(seat.name)
						icon:set_visible(WolfHUD:getSetting("show_vehicle", "boolean"))
						
						--local peer = managers.network:session():peer_by_unit(seat.occupant)
						local color_id = managers.criminals:character_color_id_by_unit(seat.occupant)
						local character_data = managers.criminals:character_data_by_unit(seat.occupant)
						if tweak_data.chat_colors[color_id] then
							icon:set_color(tweak_data.chat_colors[color_id])
						end
						if character_data then
							local mask_id = character_data.mask_id
							if tweak_data.blackmarket.masks[mask_id].inaccessible then mask_id = string.match(mask_id, "%w+")
							end

							
							local guis_catalog = "guis/"
							local bundle_folder = tweak_data.blackmarket.masks[mask_id] and tweak_data.blackmarket.masks[mask_id].texture_bundle_folder
							if bundle_folder then
								guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
							end
							local mask_texture = tweak_data.blackmarket.masks[mask_id].custom_texture or guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. mask_id
							
							icon:set_image(mask_texture)
						end
					end
				elseif self.drivingpanel:child(seat.name) then
					self.drivingpanel:child(seat.name):set_visible(false)
				end
			end
		end
	end

	function HUDDriving:update_images()
		if main_table[self._name] then
			local car_table = main_table[self._name]
			local vehicle_bitmap = self.drivingpanel:child("icon_vehicle")
			
			vehicle_bitmap:set_image(car_table.texture, car_table.texture_rect[1], car_table.texture_rect[2], car_table.texture_rect[3], car_table.texture_rect[4])
			vehicle_bitmap:set_visible(WolfHUD:getSetting("show_vehicle", "boolean"))
			for _, child in pairs(self.drivingpanel:children()) do
				if child:layer() == 2 then
					self.drivingpanel:remove(child)
				end
			end
			
			for name, data in pairs(main_table[self._name]) do
				if type(data) == "table" and data.seat then
					local mask_bitmap = self.drivingpanel:bitmap({
						name = name,
						visible = false,
						layer = 2,
						texture = "guis/textures/pd2/blackmarket/icons/masks/alienware",
						x = 0,
						y = 0,
						w = 50,
						h = 30
					})
					local bindings = string.split(data.binding, " ")
					local set_function = "managers.hud._hud_driving.drivingpanel:child(" .. "'" .. name .. "'" .. ")" .. ":set_" .. string.gsub(data.binding, " ", "") .. "("
					local single = #bindings == 1 and true or false
					local first_set = "managers.hud._hud_driving.drivingpanel:child('icon_vehicle'):" .. bindings[1] .. "()" .. " + " .. (type(data.offset_x) == "string" and data.offset_y or data.offset_x)
					local second_set 
					if bindings[2] then
						second_set = ", managers.hud._hud_driving.drivingpanel:child('icon_vehicle'):" .. bindings[2] .. "()" .. " + " .. data.offset_y
					else
						second_set = ""
					end
					local set_pos = loadstring(set_function .. first_set .. second_set .. ")")
					set_pos()
					
					local set_string
					if type(data.offset_x) == "string" then
						set_string = data.offset_x
					elseif type(data.offset_y) == "string" then
						set_string = data.offset_y
					end
					if set_string then
						local set_string_function = "managers.hud._hud_driving.drivingpanel:child(" .. "'" .. name .. "'" .. ")" .. ":set_" .. set_string .. "("
						local first_string_set = "managers.hud._hud_driving.drivingpanel:child('icon_vehicle'):" .. set_string .. "()"
						local set_string_pos = loadstring(set_string_function .. first_string_set .. ")")
						set_string_pos()
					end
				end
			end
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
end