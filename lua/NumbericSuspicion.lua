local hudsuspicion_init_original = HUDSuspicion.init
local hudsuspicions_animate_eye_original = HUDSuspicion.animate_eye
local hudsuspicion_hide_original = HUDSuspicion.hide

function HUDSuspicion:init(...)
	hudsuspicion_init_original(self, ...)
	self._scale = 1
	local _suspicion_text_panel = self._suspicion_panel:panel({
		name = "suspicion_text_panel",
		visible = true,
		x = 0,
		y = 0,
		h = self._suspicion_panel:h(),
		w = self._suspicion_panel:w(),
		layer = 1
	})

	local _suspicion_text = _suspicion_text_panel:text({
		name = "suspicion_text",
		visible = true,
		text = "",
		valign = "center",
		align = "center",
		layer = 2,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
		font_size = 28,
		h = 64
	})
	_suspicion_text:set_y((math.round(_suspicion_text_panel:h() / 4)))

	self._suspicion_text_bgs = WolfHUD:makeOutlineText(_suspicion_text_panel, {
		visible = true,
		text = "",
		valign = "center",
		align = "center",
		layer = 1,
		color = Color.black,
		font = tweak_data.menu.pd2_large_font,
		font_size = 28,
		h = 64
	}, _suspicion_text)
end

function HUDSuspicion:_is_detected()
	local detected_text = self._suspicion_panel and self._suspicion_panel:child("suspicion_detected")
	return self._discovered or self._suspicion_value and self._suspicion_value >= 1 or detected_text and detected_text:alpha() > 0
end

function HUDSuspicion:_animate_detection_text(_suspicion_panel)
	local suspicion_text = _suspicion_panel:child("suspicion_text")
	local t = Application:time()
	local dt = 0
	while self._animating_text do
		dt = dt + coroutine.yield()
		if dt > 0.01 then
			t = t + dt
			local detection = self:_is_detected() and 1 or math.clamp(math.round(self._suspicion_value*100)/100, 0, 1)
			local color = math.lerp(Color(0, 0.71, 1), Color(0.99, 0.08, 0), detection)
			suspicion_text:set_color(color)
			local text = math.round(detection*100) .. "%"
			suspicion_text:set_text(text)
			WolfHUD:setOutlineText(self._suspicion_text_bgs, text, WolfHUD:getSetting({"HUDSuspicion", "SHOW_PERCENTAGE_OUTLINE"}, true))
			dt = 0
		end
	end
end

function HUDSuspicion:animate_eye(...)
	hudsuspicions_animate_eye_original(self, ...)
	self:rescale()
	local visibile = WolfHUD:getSetting({"HUDSuspicion", "SHOW_BARS"}, true)
	self._suspicion_panel:child("suspicion_left"):set_visible(visibile)
	self._suspicion_panel:child("suspicion_right"):set_visible(visibile)
	self._misc_panel:child("hud_stealthmeter_bg"):set_visible(visibile)
	self._misc_panel:child("hud_stealth_eye"):set_visible(visibile)
	self._misc_panel:child("hud_stealth_exclam"):set_visible(visibile)
	self._animating_text = true
	if WolfHUD:getSetting({"HUDSuspicion", "SHOW_PERCENTAGE"}, true) then
		self._text_animation = self._suspicion_panel:child("suspicion_text_panel"):animate(callback(self, self, "_animate_detection_text"))
	end
end

function HUDSuspicion:hide(...)
	if self._suspicion_panel then
		self._suspicion_panel:set_visible(false)
	end
	self._animating_text = false
	hudsuspicion_hide_original(self, ...)
	if self._text_animation then
		self._text_animation = nil
	end
end

function HUDSuspicion:rescale()
	local scale = WolfHUD:getSetting({"HUDSuspicion", "SCALE"}, 0.8)
	if self._scale ~= scale then
		local suspicion_left = self._suspicion_panel:child("suspicion_left")
		local suspicion_right = self._suspicion_panel:child("suspicion_right")
		local hud_stealthmeter_bg = self._misc_panel:child("hud_stealthmeter_bg")
		local suspicion_detected = self._suspicion_panel:child("suspicion_detected")
		local hud_stealth_eye = self._misc_panel:child("hud_stealth_eye")
		local hud_stealth_exclam = self._misc_panel:child("hud_stealth_exclam")
		local suspicion_text_panel = self._suspicion_panel:child("suspicion_text_panel")
		local suspicion_text = suspicion_text_panel:child("suspicion_text")
		suspicion_left:set_size((suspicion_left:w() / self._scale) * scale, (suspicion_left:h() / self._scale) * scale)
		suspicion_right:set_size((suspicion_right:w() / self._scale) * scale, (suspicion_right:h() / self._scale) * scale)
		hud_stealthmeter_bg:set_size((hud_stealthmeter_bg:w() / self._scale) * scale, (hud_stealthmeter_bg:h() / self._scale) * scale)
		suspicion_detected:set_font_size((suspicion_detected:font_size() / self._scale) * scale)
		local fontSize = (suspicion_text:font_size() / self._scale) * scale
		suspicion_text:set_font_size(fontSize)
		WolfHUD:setOutlineFontSize(self._suspicion_text_bgs, fontSize)
		hud_stealth_eye:set_size((hud_stealth_eye:w() / self._scale) * scale, (hud_stealth_eye:h() / self._scale) * scale)
		hud_stealth_exclam:set_size((hud_stealth_exclam:w() / self._scale) * scale, (hud_stealth_exclam:h() / self._scale) * scale)
		suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
		suspicion_left:set_center_y(self._suspicion_panel:h() / 2)
		suspicion_right:set_center(suspicion_left:center())
		hud_stealthmeter_bg:set_center(suspicion_left:center())
		hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)
		hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)
		suspicion_text:set_y(suspicion_left:top() + (suspicion_left:center_y() - suspicion_left:top()) / 2 - suspicion_text:font_size() / 2)
		WolfHUD:refreshOutlinePos(self._suspicion_text_bgs, suspicion_text)
		self._scale = scale
	end
	if WolfHUD:getSetting({"HUDSuspicion", "SHOW_PERCENTAGE"}, true) and self._animating_text and not self._text_animation then
		self._text_animation = self._suspicion_panel:child("suspicion_text_panel"):animate(callback(self, self, "_animate_detection_text"))
	end
end