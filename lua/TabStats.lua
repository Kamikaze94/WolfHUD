if string.lower(RequiredScript) == "lib/managers/hud/hudstatsscreen" then
	local update_stats_screen_loot_original = HUDStatsScreen._update_stats_screen_loot
	local update_stats_screen_day_original = HUDStatsScreen._update_stats_screen_day
	local init_original = HUDStatsScreen.init
	local show_original = HUDStatsScreen.show
	local hide_original = HUDStatsScreen.hide
	HUDStatsScreen.CHARACTERS = {
		female_1 = {
			texture = "guis/dlcs/character_pack_clover/textures/pd2/blackmarket/icons/characters/female_1",
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
		},
		sydney = {
			texture = "guis/dlcs/opera/textures/pd2/blackmarket/icons/characters/sydney",
			color = Color(1, 0.80, 0.25, 0.35)
		},
		wild = {
			texture = "guis/dlcs/wild/textures/pd2/blackmarket/icons/characters/wild",
			color = Color(1, 0.80, 0.25, 0.35)
		},
		chico = {
			texture = "guis/dlcs/chico/textures/pd2/blackmarket/icons/characters/chico",
			color = Color(1, 0.65, 0.05, 0.02)
		},
	}
	
	HUDStatsScreen.STAT_ITEMS = {
		{ name = "accuracy", 			text_id = "victory_hit_accuracy", 				color = Color.white, 				update = {func = "session_hit_accuracy", 			func_alltime = "", 	params = {}, suffix = "%"	},		no_alltime = true		},
		{ name = "total_damage", 		text_id = "wolfhud_tabstats_total_damage", 		color = Color(1, 0.69, 0.19, 0.38), update = {func = "session_damage", 					func_alltime = "", 	params = {}					},		no_alltime = true		},
		{ name = "tanks_killed", 		text_id = "wolfhud_tabstats_tanks_killed", 		color = Color.red, 					update = {func = "session_total_tanks_killed", 		func_alltime = "total_tanks_killed", 	params = {}							}, 	},
		{ name = "cloakers_killed", 	text_id = "wolfhud_tabstats_cloakers_killed", 	color = Color.green,				update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"spooc", "count"}			}, 	},
		{ name = "shields_killed", 		text_id = "wolfhud_tabstats_shields_killed", 	color = Color.yellow,				update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"shield", "count"}		}, 	},
		{ name = "snipers_killed", 		text_id = "wolfhud_tabstats_snipers_killed", 	color = Color(1, 0.67, 0.84, 0.90),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"sniper", "count"}		}, 	},
		{ name = "tasers_killed", 		text_id = "wolfhud_tabstats_tasers_killed", 	color = Color(1, 0, 0.55, 0.55), 	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"taser", "count"}			}, 	},
		{ name = "medic_killed", 		text_id = "wolfhud_tabstats_medic_killed", 		color = Color(1, 1, 0.55, 0.24),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"medic", "count"}			}, 	},
		{ name = "gensec_killed", 		text_id = "wolfhud_tabstats_gensec_killed", 	color = Color(1, 0.75, 1, 0.24),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"gensec", "count"}		}, 	},
		{ name = "melee_killed", 		text_id = "wolfhud_tabstats_melee_kills", 		color = Color(1, 0.54, 0.02, 0.02),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"total", "melee"}			}, 	},
		{ name = "explosion_killed", 	text_id = "wolfhud_tabstats_explosion_kills", 	color = Color(1, 1, 0.5, 0),		update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"total", "explosion"}		}, 	},
		{ name = "total_killed", 		text_id = "wolfhud_tabstats_nonspecial_kills", 	color = Color(1, 0.78, 0.15, 0.21),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"non_special", "count"}	}, 	},
		{ name = "total_downs", 		text_id = "victory_total_downed", 				color = Color(1, 0.5, 0.5, 0.5),	update = {func = "total_downed", 					func_alltime = "total_downed_alltime", 	params = {}							}, 	},
		{ name = "total_revives", 		text_id = "wolfhud_tabstats_total_revives", 	color = Color(1, 1, 0, 0.4),		update = {func = "session_total_revives", 			func_alltime = "total_revives",			params = {}							}, 	},
	}
	
	function HUDStatsScreen.getMaskImage()
		local player = managers.player:player_unit()
		local char_data = player and managers.criminals:character_data_by_unit(player)
		local mask_id = char_data and char_data.mask_id
		local mask_icon = "guis/textures/pd2/blackmarket/icons/masks/alienware"
		if mask_id then
			local guis_catalog = "guis/"
			local bundle_folder = tweak_data.blackmarket.masks[mask_id] and tweak_data.blackmarket.masks[mask_id].texture_bundle_folder
			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end
			mask_icon = tweak_data.blackmarket.masks[mask_id].custom_texture or guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. mask_id
		end
		return mask_icon
	end
	
	function HUDStatsScreen:init()
		init_original(self)
		local right_panel = self._full_hud_panel:child("right_panel")
		local day_wrapper_panel = right_panel:child("day_wrapper_panel")
		local time_icon = right_panel:bitmap({
			name = "time_icon",
			texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
			x = 0,
			y = 0,
			alpha = 0.8,
			w = tweak_data.hud_stats.loot_size,
			h = tweak_data.hud_stats.loot_size,
		})
		local time_text = right_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "time_text",
			color = Color.white,
			alpha = 0.8,
			font_size = tweak_data.hud_stats.loot_size,
			font = tweak_data.hud_stats.objectives_font,
			text = "00:00:00",
			align = "right",
			vertical = "top",
			w = right_panel:w()/4,
			h = tweak_data.hud_stats.loot_size
		})
		time_text:set_y(math.round(right_panel:child("days_title"):y()))
		time_text:set_right(right_panel:w() - 20)
		time_icon:set_y(time_text:y())
		time_icon:set_right(time_text:left())
		
		if managers.job:is_current_job_professional() then
			day_wrapper_panel:child("day_title"):set_color(Color.red)
		end
		
		self._use_tab_stats = WolfHUD:getSetting({"TabStats", "ENABLED"}, true)
		if not self._use_tab_stats then return end
		
		local blank1 = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "blank1",
			color = Color.white,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = 2*(day_wrapper_panel:w()/3),
			h = 18
		})
		blank1:set_y(math.round(day_wrapper_panel:child("day_title"):bottom()))
		
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
			w = 2*(day_wrapper_panel:w()/3),
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
			text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
			align = "left",
			vertical = "top",
			w = 2*(day_wrapper_panel:w()/3),
			h = 18
		})
		local job_stars = managers.job:current_job_stars()
		local job_and_difficulty_stars = managers.job:current_job_and_difficulty_stars()
		local difficulty_stars = managers.job:current_difficulty_stars()
		local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
		local difficulty_string_id = tweak_data.difficulty_name_ids[difficulty]
		paygrade_text:set_text(managers.localization:to_upper_text(difficulty_string_id))
		paygrade_text:set_y(math.round(blank1:bottom()))
		paygrade_title:set_top(paygrade_text:top())
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
			w = 2*(day_wrapper_panel:w()/3),
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
			text = managers.localization:to_upper_text("hud_offshore_account") .. ":",
			align = "left",
			vertical = "top",
			w = 2*(day_wrapper_panel:w()/3),
			h = 18
		})
		offshore_payout_text:set_y(math.round(paygrade_text:bottom()))
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
			w = 2*(day_wrapper_panel:w()/3),
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
			text = managers.localization:to_upper_text("victory_civilians_killed_penalty"),
			align = "left",
			vertical = "top",
			w = 2*(day_wrapper_panel:w()/3),
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
			w = 2*(day_wrapper_panel:w()/3),
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
			text = managers.localization:to_upper_text("hud_instant_cash") .. ":",
			align = "left",
			vertical = "top",
			w = 2*(day_wrapper_panel:w()/3),
			h = 18
		})
		spending_cash_text:set_y(math.round(cleaner_costs_text:bottom()))
		spending_cash_title:set_top(spending_cash_text:top())

		local blank2 = day_wrapper_panel:text({
			layer = 0,
			x =  0,
			y = 0,
			name = "blank2",
			color = Color.white,
			font_size = font_size,
			font = tweak_data.menu.pd2_small_font,
			text = "",
			align = "right",
			vertical = "top",
			w = day_wrapper_panel:w()/2-5,
			h = 18
		})
		blank2:set_y(math.round(spending_cash_text:bottom()))
		
		local mask_icon = "guis/textures/pd2/blackmarket/icons/masks/grin"
		local mask_color = WolfHUD:getColorSetting({"TabStats", "COLOR"}, "red")
		local char_data = HUDStatsScreen.CHARACTERS[managers.criminals:local_character_name()]
		if char_data then
			mask_icon = char_data.texture or mask_icon
			mask_color = WolfHUD:getSetting({"TabStats", "COLOR"}, "rainbow") == "rainbow" and char_data.color or mask_color
		end
		self._actual_mask = WolfHUD:getSetting({"TabStats", "SHOW_MASK"}, true)
		if self._actual_mask then
			mask_icon = self.getMaskImage()
		end
		
		local logo = right_panel:bitmap({
			name = "character_icon",
			texture = mask_icon,
			w = day_wrapper_panel:w()/2-5,
			h = day_wrapper_panel:w()/2-5,
			blend_mode = "add",
			color = mask_color
		})
		logo:set_left(2.1*(day_wrapper_panel:w()/3))
		logo:set_top(day_wrapper_panel:child("paygrade_title"):top() + 20)
		
		local y = blank2:bottom()
		self._tabstats_font_size = WolfHUD:getSetting({"TabStats", "FONT_SIZE"}, 18)
		self._tabstats_color = WolfHUD:getSetting({"TabStats", "COLOR"}, "rainbow")
		local items_color = self._tabstats_color ~= "rainbow" and WolfHUD:getColorSetting({"TabStats", "COLOR"}, "red") or false
		for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
			local name = data.name
			local color = items_color or data.color
			local killed_text = day_wrapper_panel:text({
				layer = 0,
				x =  0,
				y = 0,
				name = name .. "_text",
				color = color,
				font_size = self._tabstats_font_size,
				font = tweak_data.menu.pd2_small_font,
				text = "",
				align = "right",
				vertical = "top",
				w = day_wrapper_panel:w()/2-5,
				h = self._tabstats_font_size
			})
			local killed_title = day_wrapper_panel:text({
				layer = 0,
				x = 0,
				y = 0,
				name = name .. "_title",
				color = color,
				font_size = self._tabstats_font_size,
				font = tweak_data.menu.pd2_small_font,
				text = managers.localization:to_upper_text(data.text_id or ""),
				align = "left",
				vertical = "top",
				w = day_wrapper_panel:w()/2-5,
				h = self._tabstats_font_size
			})
			killed_text:set_y(math.round(y))
			killed_title:set_top(killed_text:top())
			killed_title:set_left(0)
			
			if not data.no_alltime then
				local killed_alltime_text = day_wrapper_panel:text({
					layer = 0,
					x =  0,
					y = 0,
					name = name .. "_alltime_text",
					color = color,
					font_size = self._tabstats_font_size,
					font = tweak_data.menu.pd2_small_font,
					text = "",
					align = "right",
					vertical = "top",
					w = day_wrapper_panel:w()/2-5,
					h = self._tabstats_font_size
				})
				local killed_alltime_title = day_wrapper_panel:text({
					layer = 0,
					x =  0,
					y = 0,
					name = name .. "_alltime_title",
					color = color,
					font_size = self._tabstats_font_size,
					font = tweak_data.menu.pd2_small_font,
					text = managers.localization:to_upper_text("wolfhud_tabstats_alltime_stat"),
					align = "left",
					vertical = "top",
					w = day_wrapper_panel:w()/2-5,
					h = self._tabstats_font_size
				})
				killed_alltime_text:set_top(killed_text:top())
				killed_alltime_title:set_top(killed_text:top())
				killed_alltime_text:set_left(killed_text:right()+10)
				killed_alltime_title:set_left(killed_text:right()+10)
			end
			y = killed_text:bottom()
		end
		
		self:_update_stats_screen_day(right_panel)
	end
	
	function HUDStatsScreen:show(...)
		show_original(self, ...)
		if managers.hud then
			managers.hud:add_updator("WolfHUD_TabStats_Clock", callback(self, self, "update_time"))
		end
	end
	
	function HUDStatsScreen:hide(...)
		hide_original(self, ...)
		if managers.hud then
			managers.hud:remove_updator("WolfHUD_TabStats_Clock")
		end
	end
	
	function HUDStatsScreen:stats_visible()
		return self._showing_stats_screen or false
	end
	
	function HUDStatsScreen:update_stats(item)
		if self._use_tab_stats then
			local dwp = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel:child("right_panel"):child("day_wrapper_panel")
			if dwp then
				self:update(dwp, item)
			end
		end
	end
	
	function HUDStatsScreen:update_time(t, dt)
		if (self._last_update_t or 0) + 1 < t then
			local right_panel = self._full_hud_panel:child("right_panel")
			if right_panel then
				local text = ""
				local x = 0
				local mode = WolfHUD:getSetting({"TabStats", "CLOCK_MODE"}, 3)
				if mode == 4 then
					local time = math.floor(self._last_heist_time or 0)
					local hours = math.floor(time / 3600)
					time = time - hours * 3600
					local minutes = math.floor(time / 60)
					time = time - minutes * 60
					local seconds = math.round(time)

					text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
					x = 1.3 * right_panel:child("time_icon"):w()
				elseif mode == 3 then
					text = os.date("%X")
					x = right_panel:child("time_icon"):w()
				elseif mode == 2 then
					text = os.date("%I:%M:%S %p")
				end
				right_panel:child("time_text"):set_text(text)
				right_panel:child("time_icon"):set_center_x(right_panel:child("time_text"):left() + x)
				right_panel:child("time_text"):set_visible(mode > 1)
				right_panel:child("time_icon"):set_visible(mode > 1)
			end
			self._last_update_t = t
		end
	end
	
	function HUDStatsScreen:feed_heist_time(time)
		if (self._last_heist_time or 0) < math.floor(time) then
			self._last_heist_time = time
		end
	end

	function HUDStatsScreen:update(day_wrapper_panel, item)
		if not (self._use_tab_stats and day_wrapper_panel) then return end
		if managers.money and managers.statistics and managers.experience and not item then
			local money_current_stage 	= managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate 		= managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local civilian_kills 		= managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs			= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local offshore_money 		= money_current_stage - math.round(money_current_stage * offshore_rate)
			local spending_cash 		= money_current_stage * offshore_rate - cleaner_costs
			day_wrapper_panel:child("offshore_payout_text"):set_text(managers.experience:cash_string(offshore_money))
			day_wrapper_panel:child("spending_cash_text"):set_text(managers.experience:cash_string(spending_cash))
			if spending_cash >= 0 then
				day_wrapper_panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.friend_color)
			else
				day_wrapper_panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.heat_cold_color)
			end
			day_wrapper_panel:child("cleaner_costs_text"):set_text(managers.experience:cash_string(cleaner_costs) .. " (" .. tostring(civilian_kills) .. ")")
		end
		
		for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
			if not data.manual_update and (not item or item == data.name) then
				local update_data = data.update
				if update_data then
					local suffix_table = { func = "_text"}
					if not data.no_alltime then suffix_table.func_alltime = "_alltime_text" end
					for func, suffix in pairs(suffix_table) do 
						local item = day_wrapper_panel:child(data.name .. suffix)
						if item and update_data[func] and managers.statistics[update_data[func]] then
							local value = managers.statistics[update_data[func]](managers.statistics, unpack(update_data.params or {}))
							local value_str = ""
							if type(value) == "table" then
								for i, count in ipairs(value) do
									value_str = value_str .. managers.money:add_decimal_marks_to_string(tostring(count)) .. (value[i+1] and " / " or "")
								end
							else
								value_str = managers.money:add_decimal_marks_to_string(tostring(value))
							end
							item:set_text(value_str .. (update_data.suffix or ""))
						end
					end
				end
			end
		end
	end

	function HUDStatsScreen:clean_up(right_panel)
		local dwp = right_panel:child("day_wrapper_panel")
		if alive(dwp) then
			local panels = {"ghostable_text", "paygrade_title", "risk_text", "day_payout", "day_description", "bains_plan"}
			for i, p_name in ipairs(panels) do
				local item = dwp:child(p_name)
				if alive(item) then
					item:set_visible(false)
				end
			end
			
			if _G.LobbyPlayerInfo and LobbyPlayerInfo.settings.show_skills_in_stats_screen and alive(self._box_gui) then
				self._box_gui:close()
				self._box_gui = nil
			else
				local day_description = dwp:child("day_description")
				local last_stat_name = HUDStatsScreen.STAT_ITEMS[#HUDStatsScreen.STAT_ITEMS].name
				local last_stat_item = dwp:child(last_stat_name .. "_title")
				if day_description and last_stat_item then
					day_description:set_bottom(last_stat_item:bottom() + 15)
				end
			end
		end
	end

	function HUDStatsScreen:_update_stats_screen_day(right_panel)
		update_stats_screen_day_original(self, right_panel)
		
		if not self._use_tab_stats then return end
		
		self:clean_up(right_panel)
		local dwp = right_panel:child("day_wrapper_panel")
		if dwp then
			self:update(dwp)
		end
	end
	
	function HUDStatsScreen:update_setting(setting, value)
		if self._use_tab_stats then
			local font_size = (setting == "FONT_SIZE" and value) or self._tabstats_font_size
			local color_name = (setting == "COLOR" and value) or self._tabstats_color
			local actual_mask = (setting == "SHOW_MASK" and value) or setting ~= "SHOW_MASK" and self._actual_mask
			local dwp = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel:child("right_panel"):child("day_wrapper_panel")
			if self._tabstats_font_size ~= font_size then
				local last_item = dwp:child("blank2")
				local sub_items = {"_title", "_text", "_alltime_title", "_alltime_text"}
				for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
					for j, suffix in ipairs(sub_items) do
						local item = dwp:child(data.name .. suffix)
						if item then
							item:set_font_size(font_size)
							item:set_h(font_size)
							item:top(last_item:bottom())
							last_item = item
						end
					end
				end
			end
			if self._tabstats_color ~= color_name then
				local color = WolfHUD:getColor(color_name)
				local sub_items = {"_title", "_text", "_alltime_title", "_alltime_text"}
				for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
					for j, suffix in ipairs(sub_items) do
						local item = dwp:child(data.name .. suffix)
						if item then
							item:set_color(color or data.color or Color.white)
						end
					end
				end
				local item = dwp:parent():child("character_icon")
				if item then 
					local char_table = HUDStatsScreen.CHARACTERS[managers.criminals:local_character_name()]
					item:set_color(color or char_table.color or Color.white) 
				end
			end
			if actual_mask ~= self._actual_mask then
				local mask_icon = "guis/textures/pd2/blackmarket/icons/masks/grin"
				if not actual_mask then
					local char_table = HUDStatsScreen.CHARACTERS[managers.criminals:local_character_name()]
					mask_icon = char_table and char_table.texture or mask_icon
				else
					mask_icon = self.getMaskImage()
				end
				local item = dwp:parent():child("character_icon")
				if item then item:set_image(mask_icon) end
			end
			self._tabstats_font_size = font_size
			self._tabstats_color = color_name
			self._actual_mask = actual_mask
		end
	end
		
	Hooks:PostHook( HUDStatsScreen, "init", "WolfHUD_LPI_Compatability", function(self)
		if _G.LobbyPlayerInfo and LobbyPlayerInfo.settings.show_skills_in_stats_screen and self._use_tab_stats then
			local right_panel = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel:child("right_panel")
			local dwp = right_panel and right_panel:child("day_wrapper_panel")
			if not dwp then
				return
			end
			
			local y = math.round(dwp:child("total_revives_text"):bottom() + 10)
			for i = 1, 4 do
				local txt_name = "lpi_team_text_name" .. tostring(i)
				local name_text = dwp:child(txt_name) or dwp:text({
					name = txt_name,
					text = "",
					align = "left",
					vertical = "top",
					blend_mode = "add",
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					color = tweak_data.chat_colors[i],
					w = right_panel:w(),
					x = 0,
					y = y
				})
				
				txt_name = "lpi_team_text_skills" .. tostring(i)
				local skill_text = dwp:child(txt_name) or dwp:text({
					name = txt_name,
					text = "",
					align = "left",
					vertical = "top",
					blend_mode = "add",
					font_size = tweak_data.menu.pd2_small_font_size - 4,
					font = tweak_data.menu.pd2_small_font,
					color = tweak_data.screen_colors.text,
					w = right_panel:w(),
					x = 10,
					y = y + 20
				})

				txt_name = "lpi_team_text_perk" .. tostring(i)
				local perk_text = dwp:child(txt_name) or dwp:text({
					name = txt_name,
					text = "",
					align = "left",
					vertical = "top",
					blend_mode = "add",
					font_size = tweak_data.menu.pd2_small_font_size - 4,
					font = tweak_data.menu.pd2_small_font,
					color = tweak_data.screen_colors.text,
					w = right_panel:w(),
					x = 10,
					y = y + 38
				})
				y = math.round(name_text:top() + 60)
			end
		end
		--Hooks:RemovePostHook( "WolfHUD_LPI_Compatability" )
	end )
	
	Hooks:PostHook( HUDStatsScreen, "_create_stats_ext_inventory", "WolfHUD_LPI_Compatability", function(self, ext_inv_panel)
		local ext_inv_title = ext_inv_panel and ext_inv_panel:child("title")
		if ext_inv_title then
			ext_inv_title:hide()
		end
	end)
	
	function HUDStatsScreen:_update_stats_screen_loot(loot_wrapper_panel)
		update_stats_screen_loot_original(self, loot_wrapper_panel)
		if not WolfHUD:getSetting({"TabStats", "SHOW_LOOT_NUMBERS"}, true) then return end
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
				alpha = 0.75,
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
				font = tweak_data.menu.pd2_small_font
			})
			managers.hud:make_fine_text(bag_text)
			bag_text:set_left(bag:right())
			bag_text:set_center_y(math.round(bag:center_y()))
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/statisticsmanager" then
	local shot_fired_original = StatisticsManager.shot_fired
	local session_enemy_killed_by_type_original = StatisticsManager.session_enemy_killed_by_type
	
	function StatisticsManager:shot_fired(data, ...)
		local value = shot_fired_original(self, data, ...)
		if managers.hud and managers.hud.update_stats_screen then
			managers.hud:update_stats_screen("accuracy")
		end
		return value
	end
	
	function StatisticsManager:session_enemy_killed_by_type(enemy, type)
		if enemy == "non_special" then	--added new "enemy"
			return self:session_enemy_killed_by_type("total", type)
						- self:session_total_specials_kills()
		end
		return session_enemy_killed_by_type_original(self, enemy, type)
	end
	
	--New Functions
	function StatisticsManager:enemy_killed_by_type(enemy, type)
		if enemy == "non_special" then	--added new "enemy"
			return self:enemy_killed_by_type("total", type)
						- self:total_specials_kills()
		end
		return self._global.killed and self._global.killed[enemy] and self._global.killed[enemy][type] or 0
	end
	
	function StatisticsManager:total_specials_kills()
		local count = 0
		for _, id in ipairs(self.special_unit_ids) do
			count = count + self:enemy_killed_by_type(id, "count") 
		end
		return count
	end
	
	function StatisticsManager:session_total_tanks_killed()
		return self:session_enemy_killed_by_type("tank", "count") 
			+ self:session_enemy_killed_by_type("tank_green", "count")
			+ self:session_enemy_killed_by_type("tank_black", "count")
			+ self:session_enemy_killed_by_type("tank_skull", "count")
			+ self:session_enemy_killed_by_type("tank_hw", "count")
	end
	
	function StatisticsManager:total_tanks_killed()
		return self:enemy_killed_by_type("tank", "count") 
			+ self:enemy_killed_by_type("tank_green", "count")
			+ self:enemy_killed_by_type("tank_black", "count")
			+ self:enemy_killed_by_type("tank_skull", "count")
			+ self:enemy_killed_by_type("tank_hw", "count")
	end
	
	function StatisticsManager:total_downed_alltime()
		return self._global.downed.bleed_out + self._global.downed.incapacitated
	end
	
	function StatisticsManager:session_total_revives()
		return {self._global.session.revives.player_count , self._global.session.revives.npc_count}
	end
	
	function StatisticsManager:total_revives()
		return {self._global.revives.player_count , self._global.revives.npc_count}
	end
	
	function StatisticsManager:session_damage(peer_id)
		local peer = peer_id and managers.network:session():peer(peer_id)
		local peer_uid = peer and peer:user_id() or Steam:userid()
		self._session_damage = self._session_damage or {}
		return math.round(self._session_damage[peer_uid] or 0)
	end
	
	function StatisticsManager:session_damage_string(peer_id)
		local damage = self:session_damage(peer_id)
		return managers.money:add_decimal_marks_to_string(tostring(damage))
	end
	
	function StatisticsManager:add_session_damage(damage, peer_id)
		local peer = peer_id and managers.network:session():peer(peer_id)
		local peer_uid = peer and peer:user_id() or Steam:userid()
		self._session_damage = self._session_damage or {}
		self._session_damage[peer_uid] = (self._session_damage[peer_uid] or 0 ) + (damage * 10)
	end
	
	function StatisticsManager:reset_session_damage(peer_id)
		local peer = peer_id and managers.network:session():peer(peer_id)
		local peer_uid = peer and peer:user_id() or Steam:userid()
		self._session_damage = self._session_damage or {}
		self._session_damage[peer_uid] = 0
	end
	
	function StatisticsManager:most_session_damage() 
		local user_id, max_damage = nil, 0
		for peer_uid, damage in pairs(self._session_damage or {}) do
			damage = math.round(damage)
			if damage > max_damage then
				max_damage = damage
				user_id = peer_uid
			end
		end
		
		local peer_name = user_id and Steam:username(user_id) or managers.localization:text("debug_undecided")
		return string.format("%s (%s)", peer_name, managers.money:add_decimal_marks_to_string(tostring(max_damage)))
	end
elseif string.lower(RequiredScript) == "lib/units/enemies/cop/copdamage" then
	local _on_damage_received_original = CopDamage._on_damage_received

	function CopDamage:_on_damage_received(damage_info, ...)
		if damage_info and type(damage_info) == "table" then
			self:_process_damage(damage_info)
		end
		return _on_damage_received_original(self, damage_info, ...)
	end

	function CopDamage:_process_damage(damage_info)
		local attacker = alive(damage_info.attacker_unit) and damage_info.attacker_unit
		local damage = tonumber(damage_info.damage) or 0
		
		if attacker and damage >= 0.1 then
			local killer
			
			if attacker:in_slot(3) or attacker:in_slot(5) then	
				--Human team mate
				killer = attacker
			elseif attacker:in_slot(2) then
				--Player
				killer = attacker
			elseif attacker:in_slot(16) then
				--Bot/joker
				killer = attacker
			elseif attacker:in_slot(12) then
				--Enemy
			elseif attacker:in_slot(25)	then
				--Turret
				local owner = attacker:base():get_owner_id()
				if owner then 
					killer =  managers.criminals:character_unit_by_peer_id(owner)
				end
			elseif attacker:base().thrower_unit then
				killer = attacker:base():thrower_unit()
			end
			
			if alive(killer) then		
				if killer:in_slot(2) then
					managers.statistics:add_session_damage(damage)
					
					managers.hud:update_stats_screen()
				else
					local peer_id = managers.criminals:character_peer_id_by_unit(killer)
					if peer_id then
						managers.statistics:add_session_damage(damage, peer_id)
					end
				end
			end
		end
	end
elseif RequiredScript == "lib/units/civilians/civiliandamage" then
	local _on_damage_received_original = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(damage_info, ...)
		if damage_info and type(damage_info) == "table" then
			CivilianDamage.super._process_damage(self, damage_info)
		end
		return _on_damage_received_original(self, damage_info, ...)
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/stageendscreengui" then
	local set_stats_original = StatsTabItem.set_stats
	local feed_statistics_original = StageEndScreenGui.feed_statistics
	local feed_item_statistics_original = StatsTabItem.feed_statistics
	
	function StatsTabItem:set_stats(stats_data, ...)
		if table.contains(stats_data, "best_killer") then
			table.insert(stats_data, 6, "most_damage")
		elseif table.contains(stats_data, "favourite_weapon") then
			local total_objectives = managers.objectives:total_objectives(Global.level_data and Global.level_data.level_id)
			if total_objectives > 0 then
				table.insert(stats_data, 1, "completed_objectives")
			end
			table.insert(stats_data, 6, "session_damage")
		end
		
		set_stats_original(self, stats_data, ...)
	end
	
	function StageEndScreenGui:feed_statistics(data, ...)
		local new_data = clone(data) or {}
		new_data.most_damage = tostring(managers.statistics:most_session_damage())
		new_data.session_damage = tostring(managers.statistics:session_damage_string())
		
		feed_statistics_original(self, new_data, ...)
	end
	
	-- Make broken objective counter look less weird...
	function StatsTabItem:feed_statistics(stats_data, ...)
		local new_stats_data = clone(stats_data) or {}
		if managers.statistics:started_session_from_beginning() then
			new_stats_data.completed_objectives = managers.localization:text("menu_completed_objectives_of", {
				COMPLETED = stats_data.total_objectives,
				TOTAL = stats_data.total_objectives,
				PERCENT = stats_data.completed_ratio
			})
		end
		
		feed_item_statistics_original(self, new_stats_data, ...)
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanager" then
	local HUDManager_feed_heist_time_original = HUDManager.feed_heist_time
	
	function HUDManager:feed_heist_time(time, ...)
		HUDManager_feed_heist_time_original(self, time, ...)
		if self._hud_statsscreen then
			self._hud_statsscreen:feed_heist_time(time)
		end
	end
	
	function HUDManager:update_stats_screen(item)
		if self:showing_stats_screen() then
			self._hud_statsscreen:update_stats(item)
		end
	end
	
	function HUDManager:change_tabstats_setting(setting, value)
		if self._hud_statsscreen then
			self._hud_statsscreen:update_setting(setting, value)
		end
	end
end