local hudsuspicion_init_original = HUDSuspicion.init
local hudsuspicions_animate_eye_original = HUDSuspicion.animate_eye
local hudsuspicion_hide_original = HUDSuspicion.hide
local feed_value_original = HUDSuspicion.feed_value
 
function HUDSuspicion:init(hud, sound_source)
	hudsuspicion_init_original(self, hud, sound_source)
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
		font = tweak_data.menu.default_font,
		font_size = 28,
		h = 64
	})
	_suspicion_text:set_y((math.round(_suspicion_text_panel:h() / 4)))
end
	 
function HUDSuspicion:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	  
	local num = select('#', ...) / 3
 
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	local r_ret = r1 + (r2-r1)*relperc
	local g_ret = g1 + (g2-g1)*relperc
	local b_ret = b1 + (b2-b1)*relperc
	return math.round(r_ret*100)/100, math.round(g_ret*100)/100, math.round(b_ret*100)/100
end
 
function HUDSuspicion:_animate_detection_text(_suspicion_panel)
	while self._animating_text do
		local t = 0
		while t <= 0.01 do
			t = t + coroutine.yield()
			if -1 ~= self._suspicion_value then
				local r,g,b = self:ColorGradient(math.round(self._suspicion_value*100)/100, 0, 0.71, 1, 0.99, 0.08, 0)
				local alpha = WolfHUD:getSetting("numberic_suspicion", "boolean") and 1 or 0
				_suspicion_panel:child("suspicion_text"):set_color(Color(alpha, r, g, b))
				_suspicion_panel:child("suspicion_text"):set_text(math.round(self._suspicion_value*100) .. "%")
			end
		end
		if not self._discovered and self._suspicion_value > 0 and self._last_value_feed + 2.5 < TimerManager:game():time() then
			self:hide()
		end
	end
end
 
function HUDSuspicion:animate_eye()
	hudsuspicions_animate_eye_original(self)
	self:rescale()
	local visibile = WolfHUD:getSetting("show_susp_eye", "boolean")
	self._suspicion_panel:child("suspicion_left"):set_visible(visibile)
	self._suspicion_panel:child("suspicion_right"):set_visible(visibile)
	self._misc_panel:child("hud_stealthmeter_bg"):set_visible(visibile)
	self._misc_panel:child("hud_stealth_eye"):set_visible(visibile)
	self._misc_panel:child("hud_stealth_exclam"):set_visible(visibile)
	self._animating_text = true
	self._text_animation = self._suspicion_panel:child("suspicion_text_panel"):animate(callback(self, self, "_animate_detection_text"))
end
 
function HUDSuspicion:hide()
	if self._suspicion_panel then
		self._suspicion_panel:set_visible(false)
	end
	self._animating_text = false
	hudsuspicion_hide_original(self)
	if self._text_animation then
		self._text_animation = nil
	end
end

function HUDSuspicion:feed_value(value)
	if self._suspicion_value ~= math.min(value, 1) then
		self._last_value_feed = TimerManager:game():time()
	end
	feed_value_original(self, value)
end

function HUDSuspicion:rescale()
	local scale = WolfHUD:getSetting("suspicion_scale", "number")
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
		suspicion_text:set_font_size((suspicion_text:font_size() / self._scale) * scale)
		hud_stealth_eye:set_size((hud_stealth_eye:w() / self._scale) * scale, (hud_stealth_eye:h() / self._scale) * scale)
		hud_stealth_exclam:set_size((hud_stealth_exclam:w() / self._scale) * scale, (hud_stealth_exclam:h() / self._scale) * scale)
		suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
		suspicion_left:set_center_y(self._suspicion_panel:h() / 2)
		suspicion_right:set_center(suspicion_left:center())
		hud_stealthmeter_bg:set_center(suspicion_left:center())
		hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)
		hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)
		suspicion_text:set_y(suspicion_left:top() + (suspicion_left:center_y() - suspicion_left:top()) / 2 - suspicion_text:font_size() / 2)
		self._scale = scale
	end
end