local hudsuspicion_init_original = HUDSuspicion.init
local hudsuspicions_animate_eye_original = HUDSuspicion.animate_eye
local hudsuspicion_hide_original = HUDSuspicion.hide

function HUDSuspicion:init(...)
	hudsuspicion_init_original(self, ...)
	self._scale = 1
	self._suspicion_text_panel = self._suspicion_panel:panel({
		name = "suspicion_text_panel",
		visible = true,
		x = 0,
		y = 0,
		h = self._suspicion_panel:h(),
		w = self._suspicion_panel:w(),
		layer = 1
	})

	self._suspicion_text = OutlinedText:new(self._suspicion_text_panel, {
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
	self._suspicion_text:set_y((math.round(self._suspicion_text_panel:h() / 4)))

	-- hide the faulty half-sized background shade
	self._misc_panel:child("hud_stealthmeter_bg"):set_visible(false)
end

function HUDSuspicion:_is_detected()
	local detected_text = self._suspicion_panel and self._suspicion_panel:child("suspicion_detected")
	return self._discovered or self._suspicion_value and self._suspicion_value >= 1 or detected_text and detected_text:visible() and detected_text:alpha() > 0
end

function HUDSuspicion:set_detection(text_item, detection)
	detection = math.clamp(detection, 0, 1)
	local color = math.lerp(Color(0, 0.71, 1), Color(0.99, 0.08, 0), detection)
	text_item:set_color(color)
	text_item:set_text(string.format("%d%%", detection*100))
end

function HUDSuspicion:_animate_text(suspicion_panel, suspicion_text)
	while true do
		local detection = self:_is_detected() and 1 or self._suspicion_value or 0
		self:set_detection(suspicion_text, detection)
		coroutine.yield()
	end
end

function HUDSuspicion:animate_eye(...)
	local was_animating = self._eye_animation and true or false
	hudsuspicions_animate_eye_original(self, ...)

	if not was_animating and self._eye_animation then
		self:rescale()

		local visible = WolfHUD:getSetting({"HUDSuspicion", "SHOW_BARS"}, true)
		self._suspicion_panel:child("suspicion_left"):set_visible(visible)
		self._suspicion_panel:child("suspicion_right"):set_visible(visible)
		--self._misc_panel:child("hud_stealthmeter_bg"):set_visible(visible)
		self._misc_panel:child("hud_stealth_eye"):set_visible(visible)
		self._misc_panel:child("hud_stealth_exclam"):set_visible(visible)

		if WolfHUD:getSetting({"HUDSuspicion", "SHOW_PERCENTAGE"}, true) and not self._text_animation then
			self._suspicion_text:set_outlines_visible(WolfHUD:getSetting({"HUDSuspicion", "SHOW_PERCENTAGE_OUTLINE"}, true))
			self._text_animation = self._suspicion_text_panel:animate(callback(self, self, "_animate_text"), self._suspicion_text)
		end
	end
end

function HUDSuspicion:hide(...)
	if self._text_animation then
		self._suspicion_text_panel:stop()
		self._text_animation = nil
	end

	if self._suspicion_panel then
		self._suspicion_panel:set_visible(false)
	end

	return hudsuspicion_hide_original(self, ...)
end

function HUDSuspicion:rescale()
	local scale = WolfHUD:getSetting({"HUDSuspicion", "SCALE"}, 0.8)
	if self._scale ~= scale then
		local suspicion_left = self._suspicion_panel:child("suspicion_left")
		local suspicion_right = self._suspicion_panel:child("suspicion_right")
		--local hud_stealthmeter_bg = self._misc_panel:child("hud_stealthmeter_bg")
		local suspicion_detected = self._suspicion_panel:child("suspicion_detected")
		local hud_stealth_eye = self._misc_panel:child("hud_stealth_eye")
		local hud_stealth_exclam = self._misc_panel:child("hud_stealth_exclam")
		suspicion_left:set_size((suspicion_left:w() / self._scale) * scale, (suspicion_left:h() / self._scale) * scale)
		suspicion_right:set_size((suspicion_right:w() / self._scale) * scale, (suspicion_right:h() / self._scale) * scale)
		--hud_stealthmeter_bg:set_size((hud_stealthmeter_bg:w() / self._scale) * scale, (hud_stealthmeter_bg:h() / self._scale) * scale)
		suspicion_detected:set_font_size((suspicion_detected:font_size() / self._scale) * scale)
		local fontSize = (self._suspicion_text:font_size() / self._scale) * scale
		self._suspicion_text:set_font_size(fontSize)
		hud_stealth_eye:set_size((hud_stealth_eye:w() / self._scale) * scale, (hud_stealth_eye:h() / self._scale) * scale)
		hud_stealth_exclam:set_size((hud_stealth_exclam:w() / self._scale) * scale, (hud_stealth_exclam:h() / self._scale) * scale)
		suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
		suspicion_left:set_center_y(self._suspicion_panel:h() / 2)
		suspicion_right:set_center(suspicion_left:center())
		--hud_stealthmeter_bg:set_center(suspicion_left:center())
		hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)
		hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)
		self._suspicion_text:set_y(suspicion_left:top() + (suspicion_left:center_y() - suspicion_left:top()) / 2 - self._suspicion_text:font_size() / 2)
		self._scale = scale
	end
end
