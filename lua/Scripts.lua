if string.lower(RequiredScript) == "lib/managers/hud/hudstatsscreen" then
	local update_stats_screen_loot_original = HUDStatsScreen._update_stats_screen_loot
	local update_stats_screen_day_original = HUDStatsScreen._update_stats_screen_day
	local init_original = HUDStatsScreen.init

	local TOTAL_DAMAGE = 0
	local characters = {
		female_1 = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/female_1",
			color = Color(1, 0.54, 0.17, 0.89)
		},
		jowi = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/jowi",
			color = Color(1, 0.43, 0.48, 0.55)
		},
		spanish = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/chains",
			color = Color(1, 0.6, 0.8, 0.2)
		},
		american = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/hoxton",
			color = Color(1, 1, 0.2, 0.7)
		},
		old_hoxton = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/old_hoxton",
			color = Color(1, 1, 0.43, 0.78)
		},
		russian = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/dallas",
			color = Color(1, 0, 0.6, 0.8)
		},
		german = {
			texture = "guis/textures/pd2/blackmarket/icons/characters/wolf",
			color = Color(1, 0.4, 0, 0)
		},
		bonnie = {
			texture = "guis/dlcs/character_pack_bonnie/textures/pd2/blackmarket/icons/characters/bonnie",
			color = Color(1, 0.91, 0.59, 0.48)
		},
		dragan = {
			texture = "guis/dlcs/character_pack_dragan/textures/pd2/blackmarket/icons/characters/dragan",
			color = Color(1, 1, 0.14, 0)
		},
		jacket = {
			texture = "guis/dlcs/hlm2/textures/pd2/blackmarket/icons/characters/jacket",
			color = Color(1, 0.9, 0.91, 0.98)
		},
		sokol = {
			texture = "guis/dlcs/character_pack_sokol/textures/pd2/blackmarket/icons/characters/sokol",
			color = Color(1, 0, 0.91, 0.98)
		},
		dragon = {
			texture = "guis/dlcs/dragon/textures/pd2/blackmarket/icons/characters/dragon",
			color = Color(1, 0.55, 0.55, 0)
		},
		bodhi = {
			texture = "guis/dlcs/rip/textures/pd2/blackmarket/icons/characters/bodhi",
			color = Color(1, 0.67, 0.49, 0.43)
		},
		jimmy = {
			texture = "guis/dlcs/coco/textures/pd2/blackmarket/icons/characters/jimmy",
			color = Color(1, 0.43, 0.48, 0.55)
		}
	}

	function HUDStatsScreen:init()
		init_original(self)
		local right_panel = self._full_hud_panel:child("right_panel")
		local day_wrapper_panel = right_panel:child("day_wrapper_panel")
		self:clean_up(right_panel)

		if managers.job:is_current_job_professional() then
			day_wrapper_panel:child("day_title"):set_color(Color.red)
		end

		local paygrade_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "paygrade_text",
			color = Color.yellow,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "0",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})
		
		local paygrade_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "paygrade_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "DIFFICULTY:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local job_stars = managers.job:current_job_stars()
		local job_and_difficulty_stars = managers.job:current_job_and_difficulty_stars()
		local difficulty_stars = managers.job:current_difficulty_stars()
		local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
		local difficulty_string_id = tweak_data.difficulty_name_ids[difficulty]
		paygrade_text:set_text(managers.localization:to_upper_text(difficulty_string_id))
		paygrade_text:set_y(math.round(day_wrapper_panel:child("day_title"):bottom()))
		paygrade_title:set_top(paygrade_text:top())

		local day_payout_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "day_payout_text",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "0",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local day_payout_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "day_payout_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "PAYOUT:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		day_payout_text:set_text(managers.experience:cash_string(0))
		day_payout_text:set_y(math.round(paygrade_text:bottom()))
		day_payout_title:set_top(day_payout_text:top())

		local offshore_payout_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "offshore_payout_text",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "0",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local offshore_payout_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "offshore_payout_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "OFFSHORE PAYOUT:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})


		offshore_payout_text:set_y(math.round(day_payout_text:bottom()))
		offshore_payout_title:set_top(offshore_payout_text:top())

		local cleaner_costs_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "cleaner_costs_text",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "0",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})	

		local cleaner_costs_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "cleaner_costs_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "CLEANER COSTS:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})


		cleaner_costs_text:set_y(math.round(offshore_payout_text:bottom()))
		cleaner_costs_title:set_top(cleaner_costs_text:top())

		local spending_cash_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "spending_cash_text",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "0",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local spending_cash_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "spending_cash_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "SPENDING CASH:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		spending_cash_text:set_y(math.round(cleaner_costs_text:bottom()))
		spending_cash_title:set_top(spending_cash_text:top())

		local blank = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "blank",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		blank:set_y(math.round(spending_cash_text:bottom()))
		
		local accuracy_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "accuracy_text",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local accuracy_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "accuracy_title",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ACCURACY:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		accuracy_text:set_y(math.round(blank:bottom()))
		accuracy_title:set_top(accuracy_text:top())

		local total_damage_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "total_damage_text",
			color = Color(1, 0.69, 0.19, 0.38),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_damage_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "total_damage_title",
			color = Color(1, 0.69, 0.19, 0.38),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "TOTAL DAMAGE:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		total_damage_text:set_y(math.round(accuracy_text:bottom()))
		total_damage_title:set_top(total_damage_text:top())

		local tanks_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "tanks_killed_text",
			color = Color.red,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tanks_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "tanks_killed_title",
			color = Color.red,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "BULLDOZERS KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tanks_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "tanks_killed_total_text",
			color = Color.red,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tanks_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "tanks_killed_total_title",
			color = Color.red,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		tanks_killed_text:set_y(math.round(total_damage_text:bottom()))
		tanks_killed_title:set_top(tanks_killed_text:top())
		tanks_killed_title:set_left(0)
		tanks_killed_total_text:set_top(tanks_killed_text:top())
		tanks_killed_total_title:set_top(tanks_killed_text:top())
		tanks_killed_total_text:set_left(tanks_killed_text:right()+10)
		tanks_killed_total_title:set_left(tanks_killed_text:right()+10)

		local cloakers_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "cloakers_killed_text",
			color = Color.green,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local cloakers_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "cloakers_killed_title",
			color = Color.green,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "CLOAKERS KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local cloakers_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "cloakers_killed_total_text",
			color = Color.green,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local cloakers_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "cloakers_killed_total_title",
			color = Color.green,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		cloakers_killed_text:set_y(math.round(tanks_killed_text:bottom()))
		cloakers_killed_title:set_top(cloakers_killed_text:top())
		cloakers_killed_title:set_left(0)
		cloakers_killed_total_text:set_top(cloakers_killed_text:top())
		cloakers_killed_total_title:set_top(cloakers_killed_text:top())
		cloakers_killed_total_text:set_left(cloakers_killed_text:right()+10)
		cloakers_killed_total_title:set_left(cloakers_killed_text:right()+10)

		local shields_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "shields_killed_text",
			color = Color.yellow,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local shields_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "shields_killed_title",
			color = Color.yellow,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "SHIELDS KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local shields_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "shields_killed_total_text",
			color = Color.yellow,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local shields_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "shields_killed_total_title",
			color = Color.yellow,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		shields_killed_text:set_y(math.round(cloakers_killed_text:bottom()))
		shields_killed_title:set_top(shields_killed_text:top())
		shields_killed_title:set_left(0)
		shields_killed_total_text:set_top(shields_killed_text:top())
		shields_killed_total_title:set_top(shields_killed_text:top())
		shields_killed_total_text:set_left(shields_killed_text:right()+10)
		shields_killed_total_title:set_left(shields_killed_text:right()+10)

		local snipers_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "snipers_killed_text",
			color = Color(1, 0.67, 0.84, 0.90),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local snipers_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "snipers_killed_title",
			color = Color(1, 0.67, 0.84, 0.90),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "SNIPERS KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local snipers_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "snipers_killed_total_text",
			color = Color(1, 0.67, 0.84, 0.90),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local snipers_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "snipers_killed_total_title",
			color = Color(1, 0.67, 0.84, 0.90),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		snipers_killed_text:set_y(math.round(shields_killed_text:bottom()))
		snipers_killed_title:set_top(snipers_killed_text:top())
		snipers_killed_title:set_left(0)
		snipers_killed_total_text:set_top(snipers_killed_text:top())
		snipers_killed_total_title:set_top(snipers_killed_text:top())
		snipers_killed_total_text:set_left(snipers_killed_text:right()+10)
		snipers_killed_total_title:set_left(snipers_killed_text:right()+10)
		
		local tasers_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "tasers_killed_text",
			color = Color(1, 0, 0.55, 0.55),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tasers_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "tasers_killed_title",
			color = Color(1, 0, 0.55, 0.55),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "TASERS KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tasers_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "tasers_killed_total_text",
			color = Color(1, 0, 0.55, 0.55),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local tasers_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "tasers_killed_total_title",
			color = Color(1, 0, 0.55, 0.55),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		tasers_killed_text:set_y(math.round(snipers_killed_text:bottom()))
		tasers_killed_title:set_top(tasers_killed_text:top())
		tasers_killed_title:set_left(0)
		tasers_killed_total_text:set_top(tasers_killed_text:top())
		tasers_killed_total_title:set_top(tasers_killed_text:top())
		tasers_killed_total_text:set_left(tasers_killed_text:right()+10)
		tasers_killed_total_title:set_left(tasers_killed_text:right()+10)

		local gensec_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "gensec_killed_text",
			color = Color(1, 0.75, 1, 0.24),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local gensec_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "gensec_killed_title",
			color = Color(1, 0.75, 1, 0.24),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "GENSEC KILLED:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})
		local gensec_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "gensec_killed_total_text",
			color = Color(1, 0.75, 1, 0.24),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local gensec_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "gensec_killed_total_title",
			color = Color(1, 0.75, 1, 0.24),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		gensec_killed_text:set_y(math.round(tasers_killed_text:bottom()))
		gensec_killed_title:set_top(gensec_killed_text:top())
		gensec_killed_title:set_left(0)
		gensec_killed_total_text:set_top(gensec_killed_text:top())
		gensec_killed_total_title:set_top(gensec_killed_text:top())
		gensec_killed_total_text:set_left(gensec_killed_text:right()+10)
		gensec_killed_total_title:set_left(gensec_killed_text:right()+10)

		local melee_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "melee_killed_text",
			color = Color(1, 0.54, 0.02, 0.02),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local melee_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "melee_killed_title",
			color = Color(1, 0.54, 0.02, 0.02),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "MELEE KILLS:",
			align = "left",
			vertical = "top",
			
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local melee_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "melee_killed_total_text",
			color = Color(1, 0.54, 0.02, 0.02),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local melee_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "melee_killed_total_title",
			color = Color(1, 0.54, 0.02, 0.02),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})
		melee_killed_text:set_y(math.round(gensec_killed_text:bottom()))
		melee_killed_title:set_top(melee_killed_text:top())
		melee_killed_title:set_left(0)
		melee_killed_total_text:set_top(melee_killed_text:top())
		melee_killed_total_title:set_top(melee_killed_text:top())
		melee_killed_total_text:set_left(melee_killed_text:right()+10)
		melee_killed_total_title:set_left(melee_killed_text:right()+10)

		local explosion_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "explosion_killed_text",
			color = Color(1, 1, 0.5, 0),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local explosion_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "explosion_killed_title",
			color = Color(1, 1, 0.5, 0),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "EXPLOSION KILLS:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local explosion_killed_total_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "explosion_killed_total_text",
			color = Color(1, 1, 0.5, 0),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local explosion_killed_total_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "explosion_killed_total_title",
			color = Color(1, 1, 0.5, 0),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})
		explosion_killed_text:set_y(math.round(melee_killed_text:bottom()))
		explosion_killed_title:set_top(explosion_killed_text:top())
		explosion_killed_title:set_left(0)
		explosion_killed_total_text:set_top(explosion_killed_text:top())
		explosion_killed_total_title:set_top(explosion_killed_text:top())
		explosion_killed_total_text:set_left(explosion_killed_text:right()+10)
		explosion_killed_total_title:set_left(explosion_killed_text:right()+10)

		local total_killed_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "total_killed_text",
			color = Color(1, 0.78, 0.15, 0.21),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_killed_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "total_killed_title",
			color = Color(1, 0.78, 0.15, 0.21),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "NON SPECIAL KILLS:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_killed_alltime_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "total_killed_alltime_text",
			color = Color(1, 0.78, 0.15, 0.21),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_killed_alltime_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "total_killed_alltime_title",
			color = Color(1, 0.78, 0.15, 0.21),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME KILLS:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		total_killed_text:set_y(math.round(explosion_killed_text:bottom()))
		total_killed_title:set_top(total_killed_text:top())
		total_killed_title:set_left(0)
		total_killed_alltime_text:set_top(total_killed_text:top())
		total_killed_alltime_title:set_top(total_killed_text:top())
		total_killed_alltime_text:set_left(total_killed_text:right()+10)
		total_killed_alltime_title:set_left(total_killed_text:right()+10)

		local total_revives_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "total_revives_text",
			color = Color(1, 1, 0, 0.4),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_revives_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "total_revives_title",
			color = Color(1, 1, 0, 0.4),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "TOTAL REVIVES (P/AI):",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_revives_alltime_text = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "total_revives_alltime_text",
			color = Color(1, 1, 0, 0.4),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		local total_revives_alltime_title = day_wrapper_panel:text({
			layer = 0,
			x = 0,
			y = 0,
			name = "total_revives_alltime_title",
			color = Color(1, 1, 0, 0.4),
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "ALL TIME REVIVES:",
			align = "left",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})

		total_revives_text:set_y(math.round(total_killed_text:bottom()))
		total_revives_title:set_top(total_revives_text:top())
		total_revives_title:set_left(0)
		total_revives_alltime_text:set_top(total_revives_text:top())
		total_revives_alltime_title:set_top(total_revives_text:top())
		total_revives_alltime_text:set_left(total_revives_text:right()+10)
		total_revives_alltime_title:set_left(total_revives_text:right()+10)

		local mask_icon
		local mask_color
		if characters[managers.criminals:local_character_name()] == nil then
			mask_icon = "guis/textures/pd2/blackmarket/icons/masks/grin"
			mask_color = Color(1, 0.8, 0.5, 0.2)
		else
			mask_icon = characters[managers.criminals:local_character_name()].texture
			mask_color = characters[managers.criminals:local_character_name()].color
		end
		local logo = right_panel:bitmap({
				name = "ghost_icon",
				texture = mask_icon,
				w = day_wrapper_panel:w()/2-5,
				h = day_wrapper_panel:w()/2-5,
				blend_mode = "add",
				color = mask_color
			})

		logo:set_left(day_wrapper_panel:w()/2+40)
		logo:set_top(30)
		
		self:update(day_wrapper_panel)
	end

	function HUDStatsScreen:add_damage(amount)
		TOTAL_DAMAGE = TOTAL_DAMAGE + (amount*10)
	end

	function HUDStatsScreen:reset_damage()
		TOTAL_DAMAGE = 0
	end

	function HUDStatsScreen:update(day_wrapper_panel)
		--log(tostring(managers.localization:text('menu_jukebox_' .. )))
		day_wrapper_panel:child("cleaner_costs_text"):set_text(managers.experience:cash_string(managers.money:get_civilian_deduction() * (managers.statistics:session_total_civilian_kills() or 0)) .. " (" .. (managers.statistics:session_total_civilian_kills() or 0) .. ")")
		day_wrapper_panel:child("offshore_payout_text"):set_text(managers.experience:cash_string(managers.money:get_potential_payout_from_current_stage() - math.round(managers.money:get_potential_payout_from_current_stage() * managers.money:get_tweak_value("money_manager", "offshore_rate"))))
		day_wrapper_panel:child("spending_cash_text"):set_text(managers.experience:cash_string(math.round(managers.money:get_potential_payout_from_current_stage() * managers.money:get_tweak_value("money_manager", "offshore_rate")) - managers.money:get_civilian_deduction() * (managers.statistics:session_total_civilian_kills() or 0)))
		day_wrapper_panel:child("accuracy_text"):set_text(managers.statistics:session_hit_accuracy() .. "%")
		day_wrapper_panel:child("tanks_killed_text"):set_text(managers.statistics._global.session.killed.tank_green.count + managers.statistics._global.session.killed.tank_black.count + managers.statistics._global.session.killed.tank_skull.count + managers.statistics._global.session.killed.tank_hw.count)
		day_wrapper_panel:child("tanks_killed_total_text"):set_text(managers.statistics._global.killed.tank_green.count + managers.statistics._global.killed.tank_black.count + managers.statistics._global.killed.tank_skull.count + managers.statistics._global.killed.tank_hw.count)
		day_wrapper_panel:child("cloakers_killed_text"):set_text(managers.statistics._global.session.killed.spooc.count)
		day_wrapper_panel:child("cloakers_killed_total_text"):set_text(managers.statistics._global.killed.spooc.count)
		day_wrapper_panel:child("shields_killed_text"):set_text(managers.statistics._global.session.killed.shield.count)
		day_wrapper_panel:child("shields_killed_total_text"):set_text(managers.statistics._global.killed.shield.count)
		day_wrapper_panel:child("snipers_killed_text"):set_text(managers.statistics._global.session.killed.sniper.count)
		day_wrapper_panel:child("snipers_killed_total_text"):set_text(managers.statistics._global.killed.sniper.count)
		day_wrapper_panel:child("tasers_killed_text"):set_text(managers.statistics._global.session.killed.taser.count)
		day_wrapper_panel:child("tasers_killed_total_text"):set_text(managers.statistics._global.killed.taser.count)
		day_wrapper_panel:child("melee_killed_text"):set_text(managers.statistics._global.session.killed.total.melee)
		day_wrapper_panel:child("melee_killed_total_text"):set_text(managers.statistics._global.killed.total.melee)
		if 0 <= math.round(managers.money:get_potential_payout_from_current_stage() * managers.money:get_tweak_value("money_manager", "offshore_rate")) - managers.money:get_civilian_deduction() * (managers.statistics:session_total_civilian_kills() or 0) then
			day_wrapper_panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.friend_color)
		else
			day_wrapper_panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.heat_cold_color)
		end
		day_wrapper_panel:child("explosion_killed_text"):set_text(managers.statistics._global.session.killed.total.explosion)
		day_wrapper_panel:child("explosion_killed_total_text"):set_text(managers.statistics._global.killed.total.explosion)
		day_wrapper_panel:child("gensec_killed_text"):set_text(managers.statistics._global.session.killed.gensec.count)
		day_wrapper_panel:child("gensec_killed_total_text"):set_text(managers.statistics._global.killed.gensec.count)
		day_wrapper_panel:child("total_killed_text"):set_text(managers.statistics._global.session.killed.total.count -
																managers.statistics:session_total_specials_kills() -
																managers.statistics._global.session.killed.mobster_boss.count -
																managers.statistics._global.session.killed.hector_boss.count -
																managers.statistics._global.session.killed.hector_boss_no_armor.count)
		day_wrapper_panel:child("total_killed_alltime_text"):set_text(managers.statistics._global.killed.total.count)
		day_wrapper_panel:child("total_damage_text"):set_text(math.round(TOTAL_DAMAGE))
		day_wrapper_panel:child("total_revives_text"):set_text(managers.statistics._global.session.revives.player_count .. "/" .. managers.statistics._global.session.revives.npc_count)
		day_wrapper_panel:child("total_revives_alltime_text"):set_text(managers.statistics._global.revives.player_count .. "/" .. managers.statistics._global.revives.npc_count)
	end

	function HUDStatsScreen:clean_up(right_panel)
		--right_panel:child("ghost_icon"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("ghostable_text"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("paygrade_title"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("risk_text"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("day_payout"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("day_description"):set_visible(false)
		right_panel:child("day_wrapper_panel"):child("bains_plan"):set_visible(false)
	end

	function HUDStatsScreen:_update_stats_screen_day(right_panel)
		update_stats_screen_day_original(self, right_panel)
		self:clean_up(right_panel)
		self:update(right_panel:child("day_wrapper_panel"))
	end
	
	function HUDStatsScreen:_update_stats_screen_loot(loot_wrapper_panel)
		update_stats_screen_loot_original(self, loot_wrapper_panel)
		local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
		local mission_amount = managers.loot:get_secured_mandatory_bags_amount()
		local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
		
		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local mission_bags_panel = loot_wrapper_panel:child("mission_bags_panel")
		local bonus_bags_panel = loot_wrapper_panel:child("bonus_bags_panel")
		mission_bags_panel:clear()
		bonus_bags_panel:clear()
		if mandatory_bags_data and mandatory_bags_data.amount then
			local bag = mission_bags_panel:bitmap({
				name = "bag1",
				texture = bag_texture,
				texture_rect = bag_rect,
				x = 0,
				alpha = 0.25
			})
			local bag_text = mission_bags_panel:text({
				name = "bag_amount",
				text = " x" .. tostring(mandatory_bags_data.amount - mission_amount),
				font = tweak_data.menu.pd2_small_font,
				font = tweak_data.menu.pd2_small_font
			})
			managers.hud:make_fine_text(bag_text)
			bag_text:set_left(bag:right())
			bag_text:set_center_y(math.round(bag:center_y()))
			if mission_amount > 0 then
				local bag_gotten = mission_bags_panel:bitmap({
					name = "bag1",
					texture = bag_texture,
					texture_rect = bag_rect,
					x = 0
				})
				local bag_text_gotten = mission_bags_panel:text({
					name = "bag_amount",
					text = " x" .. tostring(mission_amount),
					font = tweak_data.menu.pd2_small_font,
					font = tweak_data.menu.pd2_small_font
				})
				managers.hud:make_fine_text(bag_text_gotten)
				bag_gotten:set_left(bag_text:right() + 10)
				bag_text_gotten:set_left(bag_gotten:right())
				bag_text_gotten:set_center_y(math.round(bag_gotten:center_y()))
			end
		end
		if bonus_amount > 0 then
			local bag = bonus_bags_panel:bitmap({
				name = "bag1",
				texture = bag_texture,
				texture_rect = bag_rect,
				x = 0
			})
			local bag_text = bonus_bags_panel:text({
				name = "bag_amount",
				text = " x" .. tostring(bonus_amount),
				font = tweak_data.menu.pd2_small_font,
				font = tweak_data.menu.pd2_small_font
			})
			managers.hud:make_fine_text(bag_text)
			bag_text:set_left(bag:right())
			bag_text:set_center_y(math.round(bag:center_y()))
		end
	end
	
	Hooks:PostHook( HUDStatsScreen, "show", "WolfHUD_LPI_Compatability", function(self)
		if _G.LobbyPlayerInfo and LobbyPlayerInfo.settings.show_skills_in_stats_screen then
			local right_panel = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel:child("right_panel")
			if not right_panel then return end
			local day_wrapper_panel = right_panel:child("day_wrapper_panel")
			if not day_wrapper_panel then return end
			if day_wrapper_panel:child("lpi_team_text_name1") then
				local y = day_wrapper_panel:child("total_revives_text"):bottom() + 15
				for i = 1, 4 do
					local labels = { "lpi_team_text_name" .. tostring(i), "lpi_team_text_skills" .. tostring(i), "lpi_team_text_perk" .. tostring(i) }
					for j, lbl in ipairs(labels) do
						local lpi_panel = day_wrapper_panel:child(lbl)
						if lpi_panel then
							lpi_panel:set_y(y)
						else
							log("[ERROR] Hook 'WolfHUD_LPI_Compatability' (Scripts.lua:1161), panel not found: " .. lbl )
						end
						y = y + 20
					end
				end
				Hooks:RemovePostHook( "WolfHUD_LPI_Compatability" )
			end
		end
	end )
elseif string.lower(RequiredScript) == "lib/managers/hud/hudsuspicion" then
	local hudsuspicion_init_original = HUDSuspicion.init
	local hudsuspicions_animate_eye_original = HUDSuspicion.animate_eye
	local hudsuspicion_hide_original = HUDSuspicion.hide
	 
	function HUDSuspicion:init(hud, sound_source)
			hudsuspicion_init_original(self, hud, sound_source)
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
	 
	function HUDSuspicion:_animate_detection_text(_suspicion_panel, param_2)
			while self._animating_text do
					local t = 0
					while t <= 0.01 do
							t = t + coroutine.yield()
							if -1 ~= self._suspicion_value then
									local r,g,b = self:ColorGradient(math.round(self._suspicion_value*100)/100, 0, 0.71, 1, 0.99, 0.08, 0)
									_suspicion_panel:child("suspicion_text"):set_color(Color(1, r, g, b))
									_suspicion_panel:child("suspicion_text"):set_text(math.round(self._suspicion_value*100) .. "%")
							end
					end
			end
	end
	 
	function HUDSuspicion:animate_eye()
			hudsuspicions_animate_eye_original(self)
			self._animating_text = true
			self._text_animation = self._suspicion_panel:child("suspicion_text_panel"):animate(callback(self, self, "_animate_detection_text"))
	end
	 
	function HUDSuspicion:hide()
			hudsuspicion_hide_original(self)
			if (self._text_animation) then
					self._animating_text = false
					self._text_animation = nil
			end
	end

elseif string.lower(RequiredScript) == "lib/managers/group_ai_states/groupaistatebase" then
	local _upd_criminal_suspicion_progress_original = GroupAIStateBase._upd_criminal_suspicion_progress
	function GroupAIStateBase:_upd_criminal_suspicion_progress(...)
		if self._ai_enabled then
			for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
				local unit = obs_susp_data.u_observer
				
				if managers.enemy:is_civilian(unit) then
					local waypoint = managers.hud._hud.waypoints["susp1" .. tostring(obs_key)]
					
					if waypoint then
						local color, arrow_color
						
						if unit:anim_data().drop then
							if not obs_susp_data._subdued_civ then
								obs_susp_data._alerted_civ = nil
								obs_susp_data._subdued_civ = true
								color = Color(0, 0.71, 1)
								arrow_color = Color(0, 0.35, 0.5)
								waypoint.bitmap:set_image("guis/textures/menu_singletick")
							end
						elseif obs_susp_data.alerted then
							if not obs_susp_data._alerted_civ then
								obs_susp_data._subdued_civ = nil
								obs_susp_data._alerted_civ = true
								color = Color.white
								arrow_color = tweak_data.hud.detected_color
								waypoint.bitmap:set_image("guis/textures/hud_icons")
								waypoint.bitmap:set_texture_rect(479, 433, 32, 32, color)
							end
						end
						
						if color then
							waypoint.bitmap:set_color(color)
							waypoint.arrow:set_color(arrow_color:with_alpha(0.75))
						end
					end
				end
			end
		end
		
		return _upd_criminal_suspicion_progress_original(self, ...)
	end
elseif string.lower(RequiredScript) == "lib/units/weapons/raycastweaponbase" then
	local init_original = RaycastWeaponBase.init
	local setup_original = RaycastWeaponBase.setup

	function RaycastWeaponBase:init(...)
		init_original(self, ...)
		self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
	end

	function RaycastWeaponBase:setup(...)
		setup_original(self, ...)
		self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
	end
elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
	local HUDTeammate_set_ammo_amount_by_type = HUDTeammate.set_ammo_amount_by_type
	function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
		if WolfHUD.settings.use_realammo then
			local total_left = current_left - current_clip
			if total_left < 0 then total_left = current_left end
			current_left = total_left
		end
		HUDTeammate_set_ammo_amount_by_type(self, type, max_clip, current_clip, current_left, max)
	end
elseif string.lower(RequiredScript) == "lib/tweak_data/timespeedeffecttweakdata" then
	function TimeSpeedEffectTweakData:_init_base_effects()
		self.mask_on = {
			speed = 1,
			fade_in_delay = 0,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = "pausable"
		}
		self.mask_on_player = {
			speed = 1,
			fade_in_delay = 0,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = 0,
			affect_timer = "player"
		}
		self.downed = {
			speed = 1,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = "pausable"
		}
		self.downed_player = {
			speed = 1,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = 0,
			affect_timer = "player"
		}
	end

	function TimeSpeedEffectTweakData:_init_mission_effects()
		self.mission_effects = {}
		self.mission_effects.quickdraw = {
			speed = 1,
			fade_in_delay = 0,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = "pausable",
			sync = true
		}
		self.mission_effects.quickdraw_player = {
			speed = 1,
			fade_in_delay = 0,
			fade_in = 0,
			sustain = 0,
			fade_out = 0,
			timer = "pausable",
			affect_timer = "player",
			sync = true
		}
	end
end