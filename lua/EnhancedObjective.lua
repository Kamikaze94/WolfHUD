if string.lower(RequiredScript) == "lib/managers/hud/hudobjectives" then
	
	HUDObjectives._TEXT_MARGIN = 8
	HUDObjectives._MAX_WIDTH = 300
	HUDObjectives._BOUNCE = 12

	function HUDObjectives:init(hud)
		if hud.panel:child("objectives_panel") then
			hud.panel:remove(self._panel:child("objectives_panel"))
		end

		self._panel = hud.panel:panel({
			visible = false,
			name = "objectives_panel",
			h = 100,
			w = 400,
			x = 80,
			valign = "top"
		})
			
		self._bg_box = HUDBGBox_create(self._panel, {
			w = 400,
			h = 38,
		})
		
		self._objective_text = self._bg_box:text({
			name = "objective_text",
			visible = false,
			layer = 2,
			color = Color.white,
			text = "",
			font_size = tweak_data.hud.active_objective_title_font_size,
			font = tweak_data.hud.medium_font_noshadow,
			align = "left",
			vertical = "center",
			w = self._bg_box:w(),
			x = HUDObjectives._TEXT_MARGIN,
			y = HUDObjectives._TEXT_MARGIN,
			wrap = true,
			word_wrap = true
		})
		
		self._amount_text = self._bg_box:text({
			name = "amount_text",
			visible = false,
			layer = 2,
			color = Color.white,
			text = "",
			font_size = tweak_data.hud.active_objective_title_font_size,
			font = tweak_data.hud.medium_font_noshadow,
			align = "left",
			vertical = "center",
			w = self._bg_box:w(),
			h = tweak_data.hud.active_objective_title_font_size,
			x = HUDObjectives._TEXT_MARGIN,
			y = HUDObjectives._TEXT_MARGIN
		})
	end
	
	function HUDObjectives:activate_objective(data)
		self._active_objective_id = data.id
		self._panel:set_visible(true)
		self._objective_text:set_visible(true)
		self._amount_text:set_visible(false)
		
		local width, height = self:_get_wrapped_text_dimensions(utf8.to_upper(data.text))
		
		self._objective_text:set_text(utf8.to_upper(data.text))
		self._objective_text:set_w(width)
		self._objective_text:set_h(height)
		self._bg_box:set_h(HUDObjectives._TEXT_MARGIN * 2 + height)
		
		if data.amount then
			self:update_amount_objective(data, true)
		else
			self._amount_text:set_text("")
			self._bg_box:set_w(HUDObjectives._TEXT_MARGIN * 2 + width)
		end
		self._bg_box:stop()
		self._bg_box:animate(callback(self, self, "_animate_update_objective"))
		
		if managers.hud and HUDListManager then 
			managers.hud:change_list_setting("left_list_height_offset", self._bg_box:bottom() + HUDObjectives._BOUNCE + HUDObjectives._TEXT_MARGIN) 
		end
	end

	function HUDObjectives:update_amount_objective(data, hide_animation)
		if data.id ~= self._active_objective_id then
			return
		end
		local amount = (data.current_amount or 0)
		self._amount_text:set_text(amount .. "/" .. data.amount)
		self._amount_text:set_left(self._objective_text:right() + HUDObjectives._TEXT_MARGIN)
		self._amount_text:set_bottom(self._objective_text:h() + HUDObjectives._TEXT_MARGIN)
		self._bg_box:set_w(HUDObjectives._TEXT_MARGIN * 3 + self._objective_text:w() + self:_get_text_dimensions(self._amount_text:text()).w)
		self._amount_text:set_visible(true)
		self._amount_text:stop()
		if not hide_animation and amount > 0 then
			self._amount_text:animate(callback(self, self, "_animate_new_amount"))
		else
			self._amount_text:set_color(Color(1, 1, 1, 1))
		end
	end

	function HUDObjectives:remind_objective(id)
		if id ~= self._active_objective_id then
			return
		end
		
		self._bg_box:stop()
		self._bg_box:animate(callback(self, self, "_animate_update_objective"))
	end

	function HUDObjectives:complete_objective(data)
		if data.id ~= self._active_objective_id then
			return
		end
		
		self._active_objective_id = ""
		self._amount_text:set_visible(false)
		self._objective_text:set_visible(false)
		self._panel:set_visible(false)
		self._bg_box:set_w(0)
	end

	function HUDObjectives:_animate_new_amount(object)
		local TOTAL_T = 2
		local t = TOTAL_T
		object:set_color(Color(1, 1, 1, 1))
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			object:set_color(Color(1, 1 , 1, 1 - (0.5 * math.sin(t * 360 * 2) + 0.5)))
		end
		object:set_color(Color(1, 1, 1, 1))
	end

	function HUDObjectives:_animate_update_objective(object)
		local TOTAL_T = 2
		local t = TOTAL_T
		object:set_y(0)
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			object:set_y(math.round((1 + math.sin((TOTAL_T - t) * 450 * 2)) * (HUDObjectives._BOUNCE * (t / TOTAL_T))))
		end
		object:set_y(0)
	end

	function HUDObjectives:_get_text_dimensions(text_string)
		local string_width_measure_text_field = self._panel:child("string_dimensions") or self._panel:text({
			name = "string_dimensions",
			visible = false,
			font_size = tweak_data.hud.active_objective_title_font_size,
			font = tweak_data.hud.medium_font_noshadow,
			align = "left",
			vertical = "center",
			wrap = false
		})
		string_width_measure_text_field:set_text(text_string)
		local x, y, w, h = string_width_measure_text_field:text_rect()
		return {x = x, y = y, w = w, h = h}
	end
	
	function HUDObjectives:_get_wrapped_text_dimensions(text_string)
		local layout_text_field = self._panel:child("layout") or self._panel:text({
			name = "layout",
			width = self._MAX_WIDTH,
			visible = false,
			font_size = tweak_data.hud.active_objective_title_font_size,
			font = tweak_data.hud.medium_font_noshadow,
			align = "left",
			vertical = "center",
			wrap = true,
			word_wrap = true
		})
		layout_text_field:set_text(text_string)
		local line_breaks = table.collect(layout_text_field:line_breaks(), function(index)
			return index + 1
		end)
		local wrapped_lines = {}
		for line = 1, #line_breaks do
			local range_start = line_breaks[line]
			local range_end = line_breaks[line + 1]
			local string_range = utf8.sub(text_string, range_start, (range_end or 0) - 1)
			table.insert(wrapped_lines, string.trim(string_range))
		end
		local w, h = 0, layout_text_field:font_size() * math.max(#wrapped_lines or 1)
		for i, line in ipairs(wrapped_lines) do
			w = math.max(w, self:_get_text_dimensions(line).w)
		end
		return math.ceil(w), math.ceil(h)
	end	
	
	
elseif string.lower(RequiredScript) == "lib/managers/hud/hudheisttimer" then
	
	function HUDHeistTimer:init(hud)
		self._hud_panel = hud.panel
		if self._hud_panel:child("heist_timer_panel") then
			self._hud_panel:remove(self._hud_panel:child("heist_timer_panel"))
		end
		
		self._heist_timer_panel = self._hud_panel:panel({
			visible = true,
			name = "heist_timer_panel",
			h = 40,
			w = 80,
			valign = "top",
			layer = 0
		})
		self._timer_text = self._heist_timer_panel:text({
			name = "timer_text",
			text = "00:00:00",
			font_size = 28,
			font = tweak_data.hud.medium_font_noshadow,
			color = Color.white,
			align = "center",
			vertical = "center",
			layer = 1,
			wrap = false,
			word_wrap = false
		})
		self._last_time = 0
	end
elseif string.lower(RequiredScript) == "core/lib/managers/subtitle/coresubtitlepresenter" then
	core:module("CoreSubtitlePresenter")
	local _on_resolution_changed_original = OverlayPresenter._on_resolution_changed
	function OverlayPresenter:_on_resolution_changed(...)
		_on_resolution_changed_original(self, ...)
		self:apply_bottom_offset()
	end
	
	function OverlayPresenter:set_bottom(offset)
		if self._bottom_off ~= offset then
			self._bottom_off = offset
			self:apply_bottom_offset()
		end
	end
	
	function OverlayPresenter:apply_bottom_offset()
		if self.__subtitle_panel and self._bottom_off then
			self.__subtitle_panel:set_height(self._bottom_off or self.__subtitle_panel:h())
			local label = self.__subtitle_panel:child("label")
			if label then
				label:set_h(self.__subtitle_panel:h())
				label:set_w(self.__subtitle_panel:w())
			end
			local shadow = self.__subtitle_panel:child("shadow")
			if shadow then
				shadow:set_h(self.__subtitle_panel:h())
				shadow:set_w(self.__subtitle_panel:w())
			end
		end
	end
end