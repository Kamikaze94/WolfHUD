if RequiredScript == "lib/managers/hudmanagerpd2" then

	local setup_endscreen_hud_original = HUDManager.setup_endscreen_hud

	function HUDManager:setup_endscreen_hud(...)
		if HUDChat.MOUSE_SUPPORT then
			self._hud_chat_ingame:disconnect_mouse()
		end
		return setup_endscreen_hud_original(self, ...)
	end

end

if RequiredScript == "lib/managers/hud/hudchat" then

	HUDChat.LINE_HEIGHT = WolfHUD:getSetting({"HUDChat", "LINE_HEIGHT"}, 15)			--Size of each line in chat (and hence the text size)
	HUDChat.WIDTH = WolfHUD:getSetting({"HUDChat", "WIDTH"}, 380)						--Width of the chat window
	HUDChat.MAX_OUTPUT_LINES = WolfHUD:getSetting({"HUDChat", "MAX_OUTPUT_LINES"}, 8)	--Number of chat lines to show
	HUDChat.MAX_INPUT_LINES = WolfHUD:getSetting({"HUDChat", "MAX_INPUT_LINES"}, 5)		--Number of lines of text you can type
	HUDChat.MOUSE_SUPPORT = false														--For scolling and stuff. Experimental, you have been warned
	HUDChat.COLORED_BG = WolfHUD:getSetting({"HUDChat", "COLORED_BG"}, true)			--Colorize the line bg based on the message source
	HUDChat.SCROLLBAR_ALIGN = WolfHUD:getSetting({"HUDChat", "SCROLLBAR_ALIGN"}, 2)		--Alignment of the scroll bar (1 = left, 2 = right)

	local enter_key_callback_original = HUDChat.enter_key_callback
	local esc_key_callback_original = HUDChat.esc_key_callback
	local _on_focus_original = HUDChat._on_focus
	local _loose_focus_original = HUDChat._loose_focus

	function HUDChat:init(ws, hud)
		local fullscreen = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

		self._hud_panel = fullscreen.panel
		self._x_offset = (fullscreen.panel:w() - hud.panel:w()) / 2
		self._y_offset = (fullscreen.panel:h() - hud.panel:h()) / 2
		self._esc_callback = callback(self, self, "esc_key_callback")
		self._enter_callback = callback(self, self, "enter_key_callback")
		self._typing_callback = 0
		self._skip_first = false
		self._messages = {}
		self._current_line_offset = 0
		self._total_message_lines = 0
		self._current_input_lines = 1
		self._ws = ws
		self._parent = hud.panel
		self:set_channel_id(ChatManager.GAME)
		self._align = "right"

		self._panel = self._parent:panel({
			name = "chat_panel",
			h = HUDChat.LINE_HEIGHT * (HUDChat.MAX_OUTPUT_LINES + 1),
			w = HUDChat.WIDTH,
		})

		if HUDManager.CUSTOM_TEAMMATE_PANELS or HUDManager.CUSTOM_TEAMMATE_PANEL then
			--Custom chat box position
			self._panel:set_right(self._parent:w())
			self._panel:set_bottom(self._parent:h())

			if HUDManager.HAS_MINIMAP then
				self._panel:move(0, -HUDMiniMap.SIZE[2])
			end
		else
			--Default chat box position
			self._panel:set_left(0)
			self._panel:set_bottom(self._parent:h() - 112)
		end

		self:_create_output_panel()
		self:_create_input_panel()
		self:_layout_output_panel()
	end

	function HUDChat:_create_input_panel()
		self._input_panel = self._panel:panel({
			name = "input_panel",
			alpha = 0,
			h = HUDChat.LINE_HEIGHT,
			w = self._panel:w(),
			layer = 1,
		})
		local focus_indicator = self._input_panel:rect({
			name = "focus_indicator",
			visible = false,
			color = Color.white:with_alpha(0.2),
			layer = 0
		})
		local gradient = self._input_panel:gradient({	--TODO: Why won't this POS behave?
			name = "input_bg",
			visible = false,	--TODO: Remove
			alpha = 0,	--TODO: Remove
			gradient_points = { 0, Color.white:with_alpha(0), 0.2, Color.white:with_alpha(0.25), 1, Color.white:with_alpha(0) },
			layer = -1,
			valign = "grow",
			blend_mode = "sub",
		})
		local bg_simple = self._input_panel:rect({
			name = "input_bg_simple",
			alpha = 0.5,
			color = Color.black,
			layer = -1,
			h = HUDChat.MAX_INPUT_LINES * HUDChat.LINE_HEIGHT,--self._input_panel:h(),
			w = self._input_panel:w(),
		})

		local input_prompt = self._input_panel:text({
			name = "input_prompt",
			text = utf8.to_upper(managers.localization:text("debug_chat_say")),
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			h = HUDChat.LINE_HEIGHT,
			align = "left",
			halign = "left",
			vertical = "center",
			hvertical = "center",
			blend_mode = "normal",
			color = Color.white,
			layer = 1
		})
		local _, _, w, h = input_prompt:text_rect()
		input_prompt:set_w(w)
		input_prompt:set_left(0)

		local input_text = self._input_panel:text({
			name = "input_text",
			text = "",
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			h = HUDChat.LINE_HEIGHT,
			w = self._input_panel:w() - input_prompt:w() - 4,
			align = "left",
			halign = "left",
			vertical = "center",
			hvertical = "center",
			blend_mode = "normal",
			color = Color.white,
			layer = 1,
			wrap = true,
			word_wrap = false
		})
		input_text:set_right(self._input_panel:w())

		local caret = self._input_panel:rect({
			name = "caret",
			layer = 2,
			color = Color(0.05, 1, 1, 1)
		})

		focus_indicator:set_shape(input_text:shape())
		self._input_panel:set_bottom(self._panel:h())
	end

	function HUDChat:_create_output_panel()
		local output_panel = self._panel:panel({
			name = "output_panel",
			h = 0,
			w = self._panel:w(),
			layer = 1,
		})

		local scroll_bar_bg = output_panel:rect({
			name = "scroll_bar_bg",
			color = Color.black,
			layer = -1,
			alpha = 0.35,
			visible = false,
			blend_mode = "normal",
			w = 8,
			h = HUDChat.LINE_HEIGHT * HUDChat.MAX_OUTPUT_LINES,
		})
		local scroll_bar_up = output_panel:bitmap({
			name = "scroll_bar_up",
			texture = "guis/textures/pd2/scrollbar_arrows",
			texture_rect = { 1, 1, 9, 10 },
			w = scroll_bar_bg:w(),
			h = scroll_bar_bg:w(),
			visible = false,
			blend_mode = "add",
			color = Color.white,
		})
		local scroll_bar_down = output_panel:bitmap({
			name = "scroll_bar_down",
			texture = "guis/textures/pd2/scrollbar_arrows",
			texture_rect = { 1, 1, 9, 10 },
			w = scroll_bar_bg:w(),
			h = scroll_bar_bg:w(),
			visible = false,
			blend_mode = "add",
			color = Color.white,
			rotation = 180,
		})
		if HUDChat.SCROLLBAR_ALIGN == 2 then
			scroll_bar_bg:set_right(output_panel:w())
			scroll_bar_up:set_right(output_panel:w())
			scroll_bar_down:set_right(output_panel:w())
		end
		scroll_bar_down:set_bottom(output_panel:h())

		local scroll_bar_position = output_panel:rect({
			name = "scroll_bar_position",
			color = Color.white,
			alpha = 0.8,
			visible = false,
			blend_mode = "normal",
			w = scroll_bar_bg:w() * 0.6,
			h = 3,
		})
		scroll_bar_position:set_center_x(scroll_bar_bg:center_x())

		if HUDChat.COLORED_BG then
			output_panel:gradient({
				name = "output_bg",
				--gradient_points = { 0, Color.white:with_alpha(0), 0.2, Color.white:with_alpha(0.25), 1, Color.white:with_alpha(0) },
				--gradient_points = { 0, Color.white:with_alpha(0.4), 0.2, Color.white:with_alpha(0.3), 1, Color.white:with_alpha(0.2) },
				gradient_points = { 0, Color.white:with_alpha(0.3), 0.3, Color.white:with_alpha(0.1), 0.5, Color.white:with_alpha(0.2) , 0.7, Color.white:with_alpha(0.1), 1, Color.white:with_alpha(0.3) },
				layer = -1,
				valign = "grow",
				blend_mode = "sub",
				w = output_panel:w() - scroll_bar_bg:w() ,
			})
			if HUDChat.SCROLLBAR_ALIGN == 1 then
				output_panel:set_left(scroll_bar_bg:w())
			end
		end

		output_panel:set_bottom(self._panel:h())
	end

	function HUDChat:_layout_output_panel()
		local output_panel = self._panel:child("output_panel")

		output_panel:set_h(HUDChat.LINE_HEIGHT * math.min(HUDChat.MAX_OUTPUT_LINES, self._total_message_lines))
		if self._total_message_lines > HUDChat.MAX_OUTPUT_LINES then
			local scroll_bar_bg = output_panel:child("scroll_bar_bg")
			local scroll_bar_up = output_panel:child("scroll_bar_up")
			local scroll_bar_down = output_panel:child("scroll_bar_down")
			local scroll_bar_position = output_panel:child("scroll_bar_position")

			scroll_bar_bg:show()
			scroll_bar_up:show()
			scroll_bar_down:show()
			scroll_bar_position:show()
			scroll_bar_down:set_bottom(output_panel:h())

			local positon_height_area = scroll_bar_bg:h() - scroll_bar_up:h() - scroll_bar_down:h() - 4
			scroll_bar_position:set_h(math.max((HUDChat.MAX_OUTPUT_LINES / self._total_message_lines) * positon_height_area, 3))
			scroll_bar_position:set_center_y((1 - self._current_line_offset / self._total_message_lines) * positon_height_area + scroll_bar_up:h() + 2 - scroll_bar_position:h() / 2)
		end
		output_panel:set_bottom(self._input_panel:top())

		local y = -self._current_line_offset * HUDChat.LINE_HEIGHT
		for i = #self._messages, 1, -1 do
			local msg = self._messages[i]
			msg.panel:set_bottom(output_panel:h() - y)
			y = y + msg.panel:h()
		end
	end

	function HUDChat:receive_message(name, message, color, icon)
		local output_panel = self._panel:child("output_panel")
		local scroll_bar_bg = output_panel and output_panel:child("scroll_bar_bg")
		local x_offset = HUDChat.COLORED_BG and 2 or 0

		local msg_panel = output_panel:panel({
			name = "msg_" .. tostring(#self._messages),
			w = output_panel:w() - scroll_bar_bg:w(),
		})
		if HUDChat.SCROLLBAR_ALIGN == 1 then
			msg_panel:set_left(scroll_bar_bg:w())
		end
		local msg_panel_bg
		if HUDChat.COLORED_BG then
			msg_panel_bg = msg_panel:rect({
				name = "bg",
				alpha = 0.25,
				color = color,
				w = msg_panel:w(),
			})
		else
			msg_panel_bg = msg_panel:bitmap({
				name = "bg",
				alpha = 1,
				color = Color.white / 3,
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {84, 0, 44, 32},
			})
		end

		local heisttime = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0
		local hours = math.floor(heisttime / (60*60))
		local minutes = math.floor(heisttime / 60) % 60
		local seconds = math.floor(heisttime % 60)
		local time_format_text
		if hours > 0 then
			time_format_text = string.format("%d:%02d:%02d", hours, minutes, seconds)
		else
			time_format_text = string.format("%02d:%02d", minutes, seconds)
		end

		local time_text = msg_panel:text({
			name = "time",
			text = time_format_text,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			h = HUDChat.LINE_HEIGHT,
			w = msg_panel:w(),
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local _, _, w, _ = time_text:text_rect()
		x_offset = x_offset + w + 2

		if icon then
			local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
			local icon_bitmap = msg_panel:bitmap({
				name = "icon",
				texture = icon_texture,
				texture_rect = icon_texture_rect,
				color = color,
				h = HUDChat.LINE_HEIGHT * 0.85,
				w = HUDChat.LINE_HEIGHT * 0.85,
				x = x_offset,
				layer = 1,
			})
			icon_bitmap:set_center_y(HUDChat.LINE_HEIGHT / 2)
			x_offset = x_offset + icon_bitmap:w() + 1
		end

		local message_text = msg_panel:text({
			name = "msg",
			text = name .. ": " .. message,
			font = tweak_data.menu.pd2_small_font,
			font_size = HUDChat.LINE_HEIGHT * 0.95,
			w = msg_panel:w() - x_offset,
			x = x_offset,
			align = "left",
			halign = "left",
			vertical = "top",
			hvertical = "top",
			blend_mode = "normal",
			wrap = true,
			word_wrap = true,
			color = Color.white,
			layer = 1
		})
		local no_lines = message_text:number_of_lines()

		message_text:set_range_color(0, utf8.len(name) + 1, color)
		message_text:set_h(HUDChat.LINE_HEIGHT * no_lines)
		message_text:set_kern(message_text:kern())
		msg_panel:set_h(HUDChat.LINE_HEIGHT * no_lines)
		msg_panel_bg:set_h(HUDChat.LINE_HEIGHT * no_lines)
		if not HUDChat.COLORED_BG then
			local _, _, msg_w, _ = message_text:text_rect()
			msg_panel_bg:set_width(x_offset + msg_w + 2)
		end

		self._total_message_lines = self._total_message_lines + no_lines
		table.insert(self._messages, { panel = msg_panel, name = name, lines = no_lines })

		self:_layout_output_panel()
		if not self._focus then
			local output_panel = self._panel:child("output_panel")
			output_panel:stop()
			output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
			output_panel:animate(callback(self, self, "_animate_fade_output"))
		end
	end

	function HUDChat:_animate_fade_output()
		local wait_t = WolfHUD:getSetting({"HUDChat", "CHAT_WAIT_TIME"}, 10)
		if wait_t <= 0 then return end
		local fade_t = 1
		local t = 0
		while wait_t > t do
			local dt = coroutine.yield()
			t = t + dt
		end
		local t = 0
		while fade_t > t do
			local dt = coroutine.yield()
			t = t + dt
			self:set_output_alpha(1 - (t / fade_t))
		end
		self:set_output_alpha(0)
	end

	function HUDChat:enter_text(o, s)
		if managers.hud and managers.hud:showing_stats_screen() then
			return
		end
		if self._skip_first then
			self._skip_first = false
			return
		end
		local text = self._input_panel:child("input_text")
		if type(self._typing_callback) ~= "number" then
			self._typing_callback()
		end
		text:replace_text(s)

		local lbs = text:line_breaks()
		if #lbs <= HUDChat.MAX_INPUT_LINES then
			self:_set_input_lines(#lbs)
		else
			local s = lbs[HUDChat.MAX_INPUT_LINES + 1]
			local e = utf8.len(text:text())
			text:set_selection(s, e)
			text:replace_text("")
		end
		self:update_caret()
	end

	function HUDChat:enter_key_callback(...)
		enter_key_callback_original(self, ...)
		self:_set_input_lines(1)
		self:_set_line_offset(0)
	end

	function HUDChat:esc_key_callback(...)
		esc_key_callback_original(self, ...)
		self:_set_input_lines(1)
		self:_set_line_offset(0)
	end

	function HUDChat:_set_input_lines(no_lines)
		if no_lines ~= self._current_input_lines then
			no_lines = math.max(no_lines, 1)
			self._current_input_lines = no_lines
			self._input_panel:set_h(no_lines * HUDChat.LINE_HEIGHT)
			self._input_panel:child("input_text"):set_h(no_lines * HUDChat.LINE_HEIGHT)
			self._input_panel:set_bottom(self._panel:h())
			self._panel:child("output_panel"):set_bottom(self._input_panel:top())
		end
	end

	function HUDChat:set_offset(offset, align)
		self._panel:set_bottom(self._parent:h() - offset)
		if align and self._align ~= align then
			if align == "left" then
				self._panel:set_left(0)
			else
				self._panel:set_right(self._parent:w())
			end
			self._align = align
		end
	end

	function HUDChat:update_key_down(o, k)
		local first_wait_done = false
		local text = self._input_panel:child("input_text")
		repeat
			local s, e = text:selection()
			local n = utf8.len(text:text())
			local d = math.abs(e - s)
			if self._key_pressed == Idstring("backspace") then
				if s == e and s > 0 then
					text:set_selection(s - 1, e)
				end
				text:replace_text("")
				self:_set_input_lines(#(text:line_breaks()))
				if not (utf8.len(text:text()) < 1) or type(self._esc_callback) ~= "number" then
				end
			elseif self._key_pressed == Idstring("delete") then
				if s == e and s < n then
					text:set_selection(s, e + 1)
				end
				text:replace_text("")
				self:_set_input_lines(#(text:line_breaks()))
				if not (utf8.len(text:text()) < 1) or type(self._esc_callback) ~= "number" then
				end
			elseif self._key_pressed == Idstring("left") then
				if s < e then
					text:set_selection(s, s)
				elseif s > 0 then
					text:set_selection(s - 1, s - 1)
				end
			elseif self._key_pressed == Idstring("right") then
				if s < e then
					text:set_selection(e, e)
				elseif s < n then
					text:set_selection(s + 1, s + 1)
				end
			elseif self._key_pressed == Idstring("up") then
				self:_change_line_offset(1)
			elseif self._key_pressed == Idstring("down") then
				self:_change_line_offset(-1)
			elseif self._key_pressed == Idstring("page up") then
				self:_change_line_offset(HUDChat.MAX_OUTPUT_LINES - self._current_input_lines)
			elseif self._key_pressed == Idstring("page down") then
				self:_change_line_offset(-(HUDChat.MAX_OUTPUT_LINES - self._current_input_lines))
			else
				self._key_pressed = false
			end
			self:update_caret()
			wait(first_wait_done and 0.03 or 0.6)
			first_wait_done = true
		until (self._key_pressed ~= k)
	end

	function HUDChat:key_press(o, k)
		if self._skip_first then
			self._skip_first = false
			return
		end
		if not self._enter_text_set then
			self._input_panel:enter_text(callback(self, self, "enter_text"))
			self._enter_text_set = true
		end
		local text = self._input_panel:child("input_text")
		self._key_pressed = k
		text:stop()
		if self._key_pressed == Idstring("end") then
			local n = utf8.len(text:text())
			text:set_selection(n, n)
		elseif self._key_pressed == Idstring("home") then
			text:set_selection(0, 0)
		elseif k == Idstring("enter") then
			if type(self._enter_callback) ~= "number" then
				self._enter_callback()
			end
		elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
			text:set_text("")
			text:set_selection(0, 0)
			self._esc_callback()
		else
			text:animate(callback(self, self, "update_key_down"), k)
		end
		self:update_caret()
	end

	function HUDChat:_change_line_offset(diff)
		if diff ~= 0 then
			self:_set_line_offset(math.clamp(self._current_line_offset + diff, 0, math.max(self._total_message_lines - HUDChat.MAX_OUTPUT_LINES + self._current_input_lines - 1, 0)))
		end
	end

	function HUDChat:_set_line_offset(offset)
		if self._current_line_offset ~= offset then
			self._current_line_offset = offset
			self:_layout_output_panel()
		end
	end

	function HUDChat:_on_focus(...)
		if HUDChat.MOUSE_SUPPORT then
			self:connect_mouse()
		end

		return _on_focus_original(self, ...)
	end

	function HUDChat:_loose_focus(...)
		if HUDChat.MOUSE_SUPPORT then
			self:disconnect_mouse()
		end

		return _loose_focus_original(self, ...)
	end

	function HUDChat:connect_mouse()
		if not self._mouse_connected then
			self._mouse_connected = true

			managers.mouse_pointer:use_mouse({
				mouse_move = callback(self, self, "_mouse_move"),
				mouse_press = callback(self, self, "_mouse_press"),
				mouse_release = callback(self, self, "_mouse_release"),
				mouse_click = callback(self, self, "_mouse_click"),
				id = "ingame_chat_mouse",
			})
		end
	end

	function HUDChat:disconnect_mouse()
		if self._mouse_connected then
			managers.mouse_pointer:remove_mouse("ingame_chat_mouse")
			self._mouse_connected = nil
		end
	end

	function HUDChat:_mouse_move(o, x, y)
		if self._mouse_state then
			x = x - self._x_offset
			y = y - self._y_offset

			--TODO: Move relative to initial click position, change y based on y move difference instead (or fuck it and leave it as it is, it works)
			local output_panel = self._panel:child("output_panel")
			self:_move_scroll_bar_position_center(y - self._panel:y() - output_panel:y())
			self._mouse_state = y
		end
	end

	function HUDChat:_mouse_press(o, button, x, y)
		x = x - self._x_offset
		y = y - self._y_offset

		if button == Idstring("mouse wheel up") then
			self:_change_line_offset(1)
		elseif button == Idstring("mouse wheel down") then
			self:_change_line_offset(-1)
		elseif button == Idstring("0") then
			local scroll_bar_position = self._panel:child("output_panel"):child("scroll_bar_position")
			if scroll_bar_position:inside(x, y) then
				self._mouse_state = y
			end
		end
	end

	function HUDChat:_mouse_release(o, button, x, y)
		x = x - self._x_offset
		y = y - self._y_offset

		if button == Idstring("0") then
			self._mouse_state = nil
		end
	end

	function HUDChat:_mouse_click(o, button, x, y)
		x = x - self._x_offset
		y = y - self._y_offset

		local output_panel = self._panel:child("output_panel")
		local scroll_bar_bg = output_panel:child("scroll_bar_bg")
		local scroll_bar_up = output_panel:child("scroll_bar_up")
		local scroll_bar_down = output_panel:child("scroll_bar_down")
		local scroll_bar_position = output_panel:child("scroll_bar_position")

		if scroll_bar_up:inside(x, y) then
			self:_change_line_offset(1)
		elseif scroll_bar_down:inside(x, y) then
			self:_change_line_offset(-1)
		elseif scroll_bar_position:inside(x, y) then

		elseif scroll_bar_bg:inside(x, y) then
			self:_move_scroll_bar_position_center(y - self._panel:y() - output_panel:y())
		end
	end

	function HUDChat:_move_scroll_bar_position_center(y)
		local output_panel = self._panel:child("output_panel")
		local scroll_bar_bg = output_panel:child("scroll_bar_bg")
		local scroll_bar_up = output_panel:child("scroll_bar_up")
		local scroll_bar_down = output_panel:child("scroll_bar_down")
		local scroll_bar_position = output_panel:child("scroll_bar_position")

		y = y + scroll_bar_position:h() / 2
		local positon_height_area = scroll_bar_bg:h() - scroll_bar_up:h() - scroll_bar_down:h() - 4
		local new_line_offset = math.round((1 - ((y - scroll_bar_up:h() - 2) / positon_height_area)) * self._total_message_lines)
		self:_change_line_offset(new_line_offset - self._current_line_offset)
	end

end
