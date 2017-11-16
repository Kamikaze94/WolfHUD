OutlinedText = OutlinedText or class()

function OutlinedText:init(panel, params)
	self._name = params.name
	self._parent = panel
	self._outlines_disabled = false

	self._text = panel:text(params)
	self._bgs = {}

	local bg_params = deep_clone(params)
	bg_params.name = nil
	bg_params.color = Color.black:with_alpha(0.5)
	bg_params.layer = self._text:layer() - 1
	for i = 1, 4 do
		bg_params.name = string.format("bg_%d", i)
		self._bgs[i] = panel:text(bg_params)
	end

	self:_update_positions()
end

function OutlinedText:set_outlines_visible(status)
	if self._outlines_disabled ~= not status then
		self._outlines_disabled = not status
		self:_update_visibility()
	end
end

function OutlinedText:set_outlines_color(color)
	if color then
		self:_call_func_bgs("set_color", color:with_alpha(0.5))
	end
end

function OutlinedText:remove()
	self._parent:remove(self._text)
	for _, bg in pairs(self._bgs) do
		self._parent:remove(bg)
	end
end

function OutlinedText:x() return self._text:x() end
function OutlinedText:y() return self._text:y() end
function OutlinedText:w() return self._text:w() end
function OutlinedText:h() return self._text:h() end
function OutlinedText:center() return self._text:center() end
function OutlinedText:center_x() return self._text:center_x() end
function OutlinedText:center_y() return self._text:center_y() end
function OutlinedText:text() return self._text:text() end
function OutlinedText:font() return self._text:font() end
function OutlinedText:font_size() return self._text:font_size() end
function OutlinedText:visible() return self._text:visible() end
function OutlinedText:color() return self._text:color() end
function OutlinedText:alpha() return self._text:alpha() end

function OutlinedText:set_x(...) return self:_call_func_text("set_x", ...) end
function OutlinedText:set_y(...) return self:_call_func_text("set_y", ...) end
function OutlinedText:set_w(...) return self:_call_func_text("set_w", ...) end
function OutlinedText:set_h(...) return self:_call_func_text("set_h", ...) end
function OutlinedText:set_center(...) return self:_call_func_text("set_center", ...) end
function OutlinedText:set_center_x(...) return self:_call_func_text("set_center_x", ...) end
function OutlinedText:set_center_y(...) return self:_call_func_text("set_center_y", ...) end
function OutlinedText:set_text(...) return self:_call_func_all("set_text", ...) end
function OutlinedText:set_font(...) return self:_call_func_all("set_font", ...) end
function OutlinedText:set_font_size(...) return self:_call_func_all("set_font_size", ...) end
function OutlinedText:set_visible(...) return self:_call_func_text("set_visible", ...) end
function OutlinedText:show(...) return self:_call_func_text("show", ...) end
function OutlinedText:hide(...) return self:_call_func_text("hide", ...) end
function OutlinedText:set_color(...) return self:_call_func_text("set_color", ...) end
function OutlinedText:set_alpha(...) return self:_call_func_all("set_alpha", ...) end
function OutlinedText:animate(...) return self:_call_func_text("animate", ...) end
function OutlinedText:stop(...) return self:_call_func_text("stop", ...) end

function OutlinedText:_call_func_all(func, ...)
	local results
	if self._text[func] then
		results = { self._text[func](self._text, ...) }
	end

	self:_call_func_bgs(func, ...)

	return unpack(results or {})
end

function OutlinedText:_call_func_text(func, ...)
	local results
	if self._text[func] then
		results = { self._text[func](self._text, ...) }
	end

	self:_update_visibility()
	self:_update_positions()

	return unpack(results or {})
end

function OutlinedText:_call_func_bgs(func, ...)
	for _, bg in ipairs(self._bgs) do
		if bg[func] then
			bg[func](bg, ...)
		end
	end

	self:_update_visibility()
	self:_update_positions()
end

function OutlinedText:_update_positions()
	local x, y = self._text:x(), self._text:y()
	self._bgs[1]:set_x(x - 1)
	self._bgs[1]:set_y(y - 1)
	self._bgs[2]:set_x(x + 1)
	self._bgs[2]:set_y(y - 1)
	self._bgs[3]:set_x(x - 1)
	self._bgs[3]:set_y(y + 1)
	self._bgs[4]:set_x(x + 1)
	self._bgs[4]:set_y(y + 1)
end

function OutlinedText:_update_visibility()
	for _, bg in pairs(self._bgs) do
		bg:set_visible(not self._outlines_disabled and self._text:visible())
	end
end
