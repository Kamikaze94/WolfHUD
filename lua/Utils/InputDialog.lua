--Dialog working fine, GUI not present...?

local requiresScript = RequiredScript:lower()
if requiresScript == "lib/managers/systemmenumanager" then

	core:module("SystemMenuManager")
	require("lib/managers/dialogs/SpecializationDialog")

	GenericSystemMenuManager.GENERIC_INPUT_DIALOG_CLASS = TextInputDialog
	GenericSystemMenuManager.INPUT_DIALOG_CLASS = TextInputDialog

	function GenericSystemMenuManager:show_input( data )
		local success = self:_show_class(data, self.GENERIC_INPUT_DIALOG_CLASS, self.INPUT_DIALOG_CLASS, data.force)
		self:_show_result(success, data)
	end
elseif requiresScript == "lib/managers/dialogs/specializationdialog" then

	core:module("SystemMenuManager")
	require("lib/managers/dialogs/GenericDialog")

	TextInputDialog = TextInputDialog or class(GenericDialog)
	TextInputDialog.KEY_INIT_DELAY = 0.6
	TextInputDialog.KEY_DELAY = 0.03

	function TextInputDialog:init(manager, data, ...)
		Dialog.init(self, manager, data)

		if not self._data.focus_button then
			if #self._button_text_list > 0 then
				self._data.focus_button = #self._button_text_list
			else
				self._data.focus_button = 1
			end
		end
		self._ws = self._data.ws or manager:_get_ws()
		local text_config = {
			title_font = data.title_font,
			title_font_size = data.title_font_size,
			font = data.font or _G.tweak_data.menu.pd2_medium_font,
			font_size = data.font_size or _G.tweak_data.menu.pd2_medium_font_size,
			w = data.w or 500,
			h = data.h or 400,
			no_close_legend = true,
			no_scroll_legend = true,
			use_indicator = data.indicator or data.no_buttons or false,
			is_title_outside = is_title_outside or false,
			use_text_formating = data.use_text_formating,
			text_formating_color = data.text_formating_color,
			text_formating_color_table = data.text_formating_color_table,
			text_blend_mode = data.text_blend_mode or "add"
		}
		self._panel_script = _G.TextInputBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data.user_text or "", self._data, text_config)
		self._panel_script:add_background()
		self._panel_script:set_layer(_G.tweak_data.gui.DIALOG_LAYER)
		self._panel_script:set_centered()
		self._panel_script:set_fade(0)
		self._controller = self._data.controller or manager:_get_controller()
		self._confirm_func = callback(self, self, "button_pressed_callback")
		self._cancel_func = callback(self, self, "dialog_cancel_callback")
		self._resolution_changed_callback = callback(self, self, "resolution_changed_callback")
		managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)
		if data.counter then
			self._counter = data.counter
			self._counter_time = self._counter[1]
		end
		self._sound_event = data.sound_event

		self._last_key_pressed = nil
		self._next_key_send_t = 0
	end

	function TextInputDialog:set_input_enabled(enabled)
		TextInputDialog.super.set_input_enabled(self, enabled)

		if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
			self._controller:remove_trigger("confirm", self._confirm_func)
			self._controller:remove_trigger("toggle_menu", self._cancel_func)
			self._controller:remove_trigger("cancel", self._cancel_func)
		end

		if enabled then
			local dialog_panel = self._panel_script and self._panel_script._panel
			if not self._kb_connected and self._ws and dialog_panel then
				local kb = Input:keyboard()
				self._ws:connect_keyboard(kb)

				dialog_panel:enter_text(function(that, char) self:on_enter_text(char) end)
				dialog_panel:key_press(function(that, key) self:on_key_press(key) end)
				dialog_panel:key_release(function(that, key) self:on_key_release(key) end)

				self._kb_connected  = true
			end
		else
			local dialog_panel = self._panel_script and self._panel_script._panel
			if self._kb_connected and self._ws and dialog_panel then
				self._ws:disconnect_keyboard()
				dialog_panel:enter_text(nil)
				dialog_panel:key_press(nil)
				dialog_panel:key_release(nil)
				self._kb_connected  = nil
			end
		end
	end

	function TextInputDialog:mouse_moved(o, x, y)
		if self._panel_script and alive(self._panel_script._text_input_panel) then
			local x, y = managers.mouse_pointer:convert_1280_mouse_pos(x, y)
			local status = self._panel_script._text_input_panel:inside(x, y)
			self._panel_script:set_textinput_highlight(status)
			self._data.text_input_highlight = status
			if status then
				return true, "link"
			end
		end
		return TextInputDialog.super.mouse_moved(self, o, x, y)
	end

	function TextInputDialog:mouse_pressed(o, button, x, y)
		if button == Idstring("0") then
			if self._panel_script and alive(self._panel_script._text_input_panel) then
				local x, y = managers.mouse_pointer:convert_1280_mouse_pos(x, y)
				local status = self._panel_script._text_input_panel:inside(x, y)
				self._panel_script:set_textinput_selected(status)
				self._data.text_input_focus = status
				if status then
					self:chk_mouse_pointer_status()
					return true, "link"
				end
			end
		end
		return TextInputDialog.super.mouse_pressed(self, o, button, x, y)
	end

	function TextInputDialog:on_enter_text(char)
		if self._data.text_input_focus then
			local text = self._data.user_text
			local n = utf8.len(text)
			local m = self._data.max_len or n + 1
			if n < m then
				local key = self._data.to_upper and utf8.to_upper(char) or char
				text = string.format("%s%s", text, key)
				self._panel_script:update_user_text(text)
				self._data.user_text = text
			end
		end
	end

	function TextInputDialog:on_key_press(key)
		local text = self._data.user_text
		local n = utf8.len(text)
		if key == Idstring("backspace") then
			if self._data.text_input_focus then
				text = utf8.sub(text, 0, math.max(n - 1, 0))
				self._panel_script:update_user_text(text)
				self._last_key_pressed = key
				self._next_key_send_t = Application:time() + TextInputDialog.KEY_INIT_DELAY
			end
		elseif key == Idstring("enter") then
			if self._data.text_input_focus then
				self._panel_script:set_textinput_selected(false)
				self._data.text_input_focus = false
				self._data.text_input_highlight = false
				self:chk_mouse_pointer_status()
			elseif self._data.text_input_highlight then
				self._panel_script:set_textinput_selected(true)
				self._data.text_input_focus = true
				self:chk_mouse_pointer_status()
			else
				self:button_pressed_callback()
			end
		elseif key == Idstring("esc") then
			if self._data.text_input_focus then
				self._panel_script:set_textinput_selected(false)
				self._data.text_input_focus = false
				self:chk_mouse_pointer_status()
			else
				self:dialog_cancel_callback()
			end
		end
		self._data.user_text = text
	end

	function TextInputDialog:on_key_release(key)
		self._last_key_pressed = nil
	end

	function TextInputDialog:update_input(t, dt)
		if self._data.text_input_focus then
			if self._last_key_pressed and self._next_key_send_t < t then
				local text = self._data.user_text
				local n = utf8.len(text)

				if self._last_key_pressed == Idstring("backspace") then
					text = utf8.sub(text, 0, math.max(n - 1, 0))
				else
					text = string.format("%s%s", text, self._last_key_pressed)
				end
				self._panel_script:update_user_text(text)
				self._next_key_send_t = self._next_key_send_t + TextInputDialog.KEY_DELAY

				self._data.user_text = text
			end

			local scroll = self._controller:get_input_axis("menu_scroll")
			if scroll.y > self.MOVE_AXIS_LIMIT or scroll.y < -self.MOVE_AXIS_LIMIT then
				self._panel_script:set_textinput_selected(false)
				self._data.text_input_focus = false
			end
		end
		return TextInputDialog.super.update_input(self, t, dt)
	end

	function TextInputDialog:chk_mouse_pointer_status()
		if self._text_box_focus then
			managers.mouse_pointer:disable()
		elseif managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
			managers.mouse_pointer:enable()
		end
	end

	function TextInputDialog:button_pressed(button_index)
		local button_list = self._data.button_list
		self:fade_out_close()
		if button_list then
			local button = button_list[button_index]
			if button and button.callback_func then
				button.callback_func(button_index, button, self._data.user_text)
			end
		end
		local callback_func = self._data.callback_func
		if callback_func then
			callback_func(button_index, self._data)
		end
	end
elseif requiresScript == "lib/managers/menu/specializationboxgui" then
	TextInputBoxGui = TextInputBoxGui or class(TextBoxGui)
	TextInputBoxGui.TEXT = ""

	function TextInputBoxGui:init(...)

		TextInputBoxGui.super.init(self, ...)

		self._text_box_highlight = false
		self._text_box_focus = false
		self._cursor_animation = false
	end

	function TextInputBoxGui:_create_text_box(ws, title, text, user_text, content_data, config, ...)
		text = text .. "\n\n."

		local panel = TextInputBoxGui.super._create_text_box(self, ws, title, text, content_data, config, ...)

		local text_input_panel = self._scroll_panel:panel({
			name = "text_input_panel",
			x = 10,
			h = tweak_data.menu.pd2_medium_font_size * 1.1,
			w = panel:w() - 20,
			layer = self._scroll_panel:layer() + 1,
		})

		local scroll_text = self._scroll_panel:child("text")
		if alive(scroll_text) then
			scroll_text:set_h(scroll_text:h() - 10)
			text_input_panel:set_bottom(scroll_text:bottom() - 5)
		end

		local input_text = text_input_panel:text({
			x = 5,
			y = 0,
			w = text_input_panel:w(),
			h = text_input_panel:h(),
			name = "input_text",
			text = user_text or "",
			color = tweak_data.screen_colors.button_stage_3,
			font = config.font or tweak_data.menu.pd2_medium_font,
			font_size = config.font_size or tweak_data.menu.pd2_medium_font_size,
			align = "left",
			vertical = "center",
			blend_mode = config.text_blend_mode or "add",
			layer = 2,
		})
		local _, _, w, _ = input_text:text_rect()
		input_text:set_w(w)

		local input_text_bg = text_input_panel:rect({
			name = "text_input_bg",
			h = text_input_panel:h(),
			w = text_input_panel:w(),
			color = tweak_data.screen_colors.button_stage_1,
			alpha = 0.4,
			layer = 1
		})

		local cursor = text_input_panel:rect({
			name = "cursor",
			x = input_text:right(),
			w = 4,
			h = text_input_panel:h(),
			color = Color.white,
			alpha = 0.8,
			layer = 2,
			blend_mode = config.text_blend_mode or "add",
			visible = false,
		})

		self._text_input_panel = text_input_panel
	end

	function TextInputBoxGui:scroll_up(y)

		TextInputBoxGui.super.scroll_up(self, y)

		local scroll_text = self._scroll_panel:child("text")
		if alive(self._text_input_panel) and alive(scroll_text) then
			self._text_input_panel:set_bottom(scroll_text:bottom() - 5)
		end
	end

	function TextInputBoxGui:scroll_down(y)

		TextInputBoxGui.super.scroll_down(self, y)

		local scroll_text = self._scroll_panel:child("text")
		if alive(self._text_input_panel) and alive(scroll_text) then
			self._text_input_panel:set_bottom(scroll_text:bottom() - 5)
		end
	end

	function TextInputBoxGui:update_user_text(text)
		local text_box = self._text_input_panel:child("input_text")
		if text_box then
			text_box:set_text(text)
			local _, _, w, _ = text_box:text_rect()
			text_box:set_w(w)

			local cursor = self._text_input_panel:child("cursor")
			if cursor then
				cursor:set_x(text_box:right())
			end
		end
	end

	function TextInputBoxGui:set_textinput_highlight(status)
		if status ~= self._text_box_highlight and alive(self._text_input_panel) then
			self._text_box_highlight = status

			local text_input_bg = self._text_input_panel:child("text_input_bg")
			local text_input = self._text_input_panel:child("input_text")
			if not self._text_box_focus then
				local color, color_bg
				if status then
					color = tweak_data.screen_colors.button_stage_2
					color_bg = tweak_data.screen_colors.button_stage_3
				else
					color = tweak_data.screen_colors.button_stage_3
					color_bg = tweak_data.screen_colors.button_stage_1
					self._cursor_animation = false
				end
				if alive(text_input) then
					text_input:set_color(color)
				end
				if alive(text_input_bg) then
					text_input_bg:set_color(color_bg)
				end
				managers.menu_component:post_event("highlight")
			end
		end
	end

	function TextInputBoxGui:set_textinput_selected(status)
		if status ~= self._text_box_focus and alive(self._text_input_panel) then
			self._text_box_focus = status

			local text_input_bg = self._text_input_panel:child("text_input_bg")
			local text_input = self._text_input_panel:child("input_text")
			if alive(text_input_bg) and alive(text_input) then
				local color, color_bg
				if status then
					color = tweak_data.screen_colors.button_stage_2
					color_bg = tweak_data.screen_colors.button_stage_2
				else
					if self._text_box_highlight then
						color = tweak_data.screen_colors.button_stage_2
						color_bg = tweak_data.screen_colors.button_stage_3
					else
						color = tweak_data.screen_colors.button_stage_3
						color_bg = tweak_data.screen_colors.button_stage_1
					end
				end
				text_input:set_color(color)
				text_input_bg:set_color(color_bg)
			end

			local cursor = self._text_input_panel:child("cursor")
			if alive(cursor) and self._cursor_animation ~= status then
				self._cursor_animation = status
				if status then
					cursor:animate(callback(self, self, "_animate_cursor"))
				end
			end
		end
	end

	function TextInputBoxGui:_animate_cursor(o)
		local t = Application:time()
		o:set_visible(true)
		while self._cursor_animation do
			t = t + coroutine.yield()
			o:set_alpha(math.sin(t * 540) * 0.5 + 0.5)
		end
		o:set_visible(false)
	end
end