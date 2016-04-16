local init_original = HUDAssaultCorner.init
 
function HUDAssaultCorner:init(...)
    init_original(self, ...)
               
    local assault_panel = self._hud_panel:child("assault_panel")
    assault_panel:set_x(self._hud_panel:w() / 2 - assault_panel:w() / 2)
    local buffs_panel = self._hud_panel:child("buffs_panel")
    buffs_panel:set_right(assault_panel:left() - 3)
               
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    point_of_no_return_panel:set_x(self._hud_panel:w() / 2 - point_of_no_return_panel:w() / 2)
               
    local casing_panel = self._hud_panel:child("casing_panel")
    casing_panel:set_x(self._hud_panel:w() / 2 - casing_panel:w() / 2)
end

function HUDAssaultCorner:show_point_of_no_return_timer()
	local delay_time = self._assault and 1.2 or 0
	self:_end_assault()
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	point_of_no_return_panel:stop()
	point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self._point_of_no_return = true
end

function HUDAssaultCorner:hide_point_of_no_return_timer()
	self._noreturn_bg_box:stop()
	self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
	self._point_of_no_return = false
end

function HUDAssaultCorner:set_control_info(...) end
function HUDAssaultCorner:show_casing(...) end
function HUDAssaultCorner:hide_casing(...) end


local HUDAssaultCorner_start_assault_orig = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
	
	local texts = {}
	if managers.job:current_difficulty_stars() > 0 then
		texts = {
			"hud_assault_assault",
			"hud_assault_end_line",
			Idstring("risk"),
			"hud_assault_end_line",
			"wolfhud_assault_phase",
			Idstring("phase"),
			"hud_assault_end_line",
			"wolfhud_assault_spawns_left",
			Idstring("spawns"),
			"hud_assault_end_line",
			"wolfhud_assault_time_left",
			Idstring("time"),
			"hud_assault_end_line"
		}
	else
		texts = {
		"hud_assault_assault",
			"hud_assault_end_line",
			"wolfhud_assault_phase",
			Idstring("phase"),
			"hud_assault_end_line",
			"wolfhud_assault_spawns_left",
			Idstring("spawns"),
			"hud_assault_end_line",
			"wolfhud_assault_time_left",
			Idstring("time"),
			"hud_assault_end_line"
		}
	end
	HUDAssaultCorner_start_assault_orig(self, text_list)
--[[	if managers.groupai and managers.groupai:state() and not managers.groupai:state():get_hunt_mode() then
		local box_text_panel = self._bg_box:child("text_panel")
		box_text_panel:stop()
		self:_set_text_list(texts)
		box_text_panel:animate(callback(self, self, "_animate_adv_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
	else
		local assault_panel = self._hud_panel:child("assault_panel")
		local icon_assaultbox = assault_panel:child("icon_assaultbox")
		local image = "guis/textures/pd2/hud_icon_padlockbox"
		icon_assaultbox:set_image(image)
	end]]
end

function HUDAssaultCorner:_animate_adv_text(text_panel, bg_box, color, color_function)
	local text_list = bg_box or self._bg_box:script().text_list
	local text_index = 0
	local texts = {}
	local padding = 10
	local function create_new_text(text_panel, text_list, text_index, texts)
		if texts[text_index] and texts[text_index].text then
			text_panel:remove(texts[text_index].text)
			texts[text_index] = nil
		end
		local text_id = text_list[text_index]
		local assault_data = managers.groupai.state()._task_data.assault
		local text_string = ""
		if type(text_id) == "string" then
			text_string = text_string .. managers.localization:to_upper_text(text_id)
		elseif text_id == Idstring("risk") then
			for i = 1, managers.job:current_difficulty_stars() do
				text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
			end
		elseif text_id == Idstring("phase") then
			text_string = text_string .. (assault_data and assault_data.phase or "Unkown")
		elseif text_id == Idstring("time") then
			text_string = text_string .. (assault_data and assault_data.phase or "Overtime")
		elseif text_id == Idstring("spawns") then
			if assault_data then
				local force_pool = self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.force_pool) * self:_get_balancing_multiplier(tweak_data.group_ai.street.assault.force_pool_balance_mul)
				local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or assault_data.force_spawned)
				text_string = text_string .. (task_spawn_allowance or "N/A")
			else
				text_string = text_string .. "N/A"
			end
		else
			text_string = text_string .. " " .. text_id .. " "
		end
		local mod_color = color_function and color_function() or color or self._assault_color
		local text = text_panel:text({
			text = text_string,
			layer = 1,
			align = "center",
			vertical = "center",
			blend_mode = "add",
			color = mod_color,
			font_size = tweak_data.hud_corner.assault_size,
			font = tweak_data.hud_corner.assault_font,
			w = 10,
			h = 10
		})
		local _, _, w, h = text:text_rect()
		text:set_size(w, h)
		texts[text_index] = {
			x = text_panel:w() + w * 0.5 + padding * 2,
			text = text
		}
	end
	while true do
		local dt = coroutine.yield()
		local last_text = texts[text_index]
		if last_text and last_text.text then
			if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
				text_index = text_index % #text_list + 1
				create_new_text(text_panel, text_list, text_index, texts)
			end
		else
			text_index = text_index % #text_list + 1
			create_new_text(text_panel, text_list, text_index, texts)
		end
		local speed = 90
		for i, data in pairs(texts) do
			if data.text then
				data.x = data.x - dt * speed
				data.text:set_center_x(data.x)
				data.text:set_center_y(text_panel:h() * 0.5)
				if 0 > data.x + data.text:w() * 0.5 then
					text_panel:remove(data.text)
					data.text = nil
				elseif color_function then
					data.text:set_color(color_function())
				end
			end
		end
		if managers.groupai and managers.groupai:state() and managers.groupai:state():get_hunt_mode() then
			local assault_panel = self._hud_panel:child("assault_panel")
			local icon_assaultbox = assault_panel:child("icon_assaultbox")
			local image = "guis/textures/pd2/hud_icon_padlockbox"
			icon_assaultbox:set_image(image)
		end
	end
end