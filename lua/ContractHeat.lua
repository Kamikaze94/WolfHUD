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
	local heat_text       = ""
	local heat_color      = Color(1,0,1)
	local exp_multiplier  = managers.job:heat_to_experience_multiplier(managers.job:get_job_heat(job_id))
	local exp_percent     = ((1 - exp_multiplier)*-1)*100

	if exp_percent ~= 0 then
		local prefix  = exp_percent > 0 and "+" or ""
		heat_text = "("..prefix..exp_percent.."%)"
        heat_color = exp_percent > 0 and Color.yellow or Color('E55858')
    end

	return heat_text, heat_color
end