-- CONFIG **********************************************************************

-- OVERRIDES *******************************************************************
local init_original = ContractBrokerHeistItem.init
function ContractBrokerHeistItem:init(...) -- parent_panel, job_data, idx

	init_original(self, ...)

	if WolfHUD:getSetting({"INVENTORY", "SHOW_CONTRACTOR_JOB_HEAT"}, true) then
		local heat_text, heat_color = self:get_job_heat_text(self._job_data.job_id)
		
		local heat = self._panel:text({
			alpha = 1,
			vertical = "top",
			layer = 1,
			align = "right",
			halign = "right",
			valign = "top",
			text = heat_text,
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.menu.pd2_medium_font_size * 0.8,
			color = heat_color
		})
		self:make_fine_text(heat)
		heat:set_right(self._panel:right() - 10)
		heat:set_top(10)
	end
end

-- FUNCTION LIB ****************************************************************
function ContractBrokerHeistItem:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function ContractBrokerHeistItem:get_job_heat_text(job_id)
	local heat_text = ""
	local heat_color = Color(1,0,1)
	local multiplier = managers.job:get_job_heat(job_id)
	local exp_multi  = managers.job:heat_to_experience_multiplier(multiplier)*20-20

    if exp_multi ~= 0 then
        heat_text = (exp_multi>0 and ("+"):rep(math.ceil(exp_multi)) or ("-"):rep(-math.floor(exp_multi)))
        heat_color = (exp_multi > 0 and Color.yellow) or Color('E55858')
    end

	return heat_text, heat_color
end