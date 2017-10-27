if string.lower(RequiredScript) == "lib/managers/hud/newhudstatsscreen" then
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local tiny_font = tweak_data.menu.pd2_tiny_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

	local update_original = HUDStatsScreen.update
	local recreate_left_original = HUDStatsScreen.recreate_left
	local recreate_right_original = HUDStatsScreen.recreate_right
	local _create_mutators_list_original = HUDStatsScreen._create_mutators_list
	local _create_tracked_list_original = HUDStatsScreen._create_tracked_list
	local loot_value_updated_original = HUDStatsScreen.loot_value_updated

	function HUDStatsScreen:recreate_left(...)
		recreate_left_original(self, ...)

		if WolfHUD:getSetting({"TabStats", "ENABLED"}, true) then
			self._use_tab_stats = true
			self._left:clear()
			self._left:bitmap({
				texture = "guis/textures/test_blur_df",
				layer = -1,
				render_template = "VertexColorTexturedBlur3D",
				valign = "grow",
				w = self._left:w(),
				h = self._left:h()
			})

			local l_bg = HUDBGBox_create(self._left, {}, {
				blend_mode = "normal",
				color = Color.white,
				bg_color = Color.black:with_alpha(0.75)
			})
			if l_bg:child("bg") then
				l_bg:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
				l_bg:child("bg"):set_alpha(1)
			end

			local placer = UiPlacer:new(10, 10, 0, 8)
			local row_w = self._left:w() - placer:current_left() * 2
			local y = 0

			for i, data in pairs(managers.objectives:get_active_objectives()) do
				placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					align = "left",
					text = utf8.to_upper(data.text),
					font = tweak_data.hud.medium_font,
					font_size = tweak_data.hud.active_objective_title_font_size,
					w = row_w
				}))
				placer:new_row(8)
				local item = placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					font_size = tweak_data.hud.active_objective_title_font_size * 0.9,
					align = "left",
					text = data.description,
					font = tweak_data.hud_stats.objective_desc_font,
					w = row_w
				}), 0)
				y = math.max(y, item:bottom())
			end

			local list_panel = ExtendedPanel:new(self._left, {
				y = y + self._leftpos[2],
				w = self._left:w(),
				h = self._left:h() * 0.6
			})
			y = list_panel:bottom()

			if managers.mutators:are_mutators_active() then
				self:_create_mutators_list(list_panel)
			elseif table.size(managers.achievment:get_tracked_fill()) > 0 then
				self:_create_tracked_list(list_panel)
			end

			self:_create_sidejobs_list(ExtendedPanel:new(self._left, {
				y = y + self._leftpos[2],
				w = self._left:w(),
				h = self._left:h() * 0.3
			}))

			local placer = UiPlacer:new(0, 0)
			local ext_inv_panel = ExtendedPanel:new(self._left, {
				x = self._leftpos[2],
				y = self._left:h() - self._leftpos[2] - medium_font_size * 2 - 10,
				w = self._left:w() - 2 * self._leftpos[2],
				h = medium_font_size * 2 + 10
			})

			local body_text = placer:add_row(ext_inv_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("hud_body_bags"),
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local body_texture, body_rect = tweak_data.hud_icons:get_icon_data("equipment_body_bag")
			local body_icon = placer:add_left(ext_inv_panel:fit_bitmap({
				w = 17,
				h = 17,
				texture = body_texture,
				texture_rect = body_rect
			}))
			body_icon:set_center_y(body_text:center_y())

			placer:add_left(ext_inv_panel:fine_text({
				text = tostring(managers.player:get_body_bags_amount()),
				font = medium_font,
				font_size = medium_font_size
			}), 7)

			placer:new_row(0, 8)

			local track_text = placer:add_bottom(ext_inv_panel:fine_text({
				text = managers.localization:to_upper_text("menu_es_playing_track") .. " " .. managers.music:current_track_string(),
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text,
				align = "right",
				keep_w = true
			}))
		end
	end



	function HUDStatsScreen:recreate_right(...)
		recreate_right_original(self, ...)

		if WolfHUD:getSetting({"TabStats", "ENABLED"}, true) then
			self._use_tab_stats = true
			self._right:clear()
			self._right:bitmap({
				texture = "guis/textures/test_blur_df",
				layer = -1,
				render_template = "VertexColorTexturedBlur3D",
				valign = "grow",
				w = self._right:w(),
				h = self._right:h()
			})

			local r_bg = HUDBGBox_create(self._right, {}, {
				blend_mode = "normal",
				color = Color.white,
			})
			if r_bg:child("bg") then
				r_bg:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
				r_bg:child("bg"):set_alpha(1)
			end

			local stats_panel = ExtendedPanel:new(self._right, { w = self._right:w(), h = self._right:h() })
			self:_create_stat_list(stats_panel)
			self:_update_stats_list(stats_panel)
		end

		local clock_panel = self:_create_clock(self._right)
		clock_panel:set_right(self._right:w() - self._rightpos[2])
		clock_panel:set_y(self._rightpos[2])
	end

	function HUDStatsScreen:_create_tracked_list(panel, ...)
		local right_panel = self._right
		self._right = panel
		_create_tracked_list_original(self, panel)
		self._right = right_panel
	end

	function HUDStatsScreen:_create_mutators_list(panel, ...)
		local right_panel = self._right
		self._right = panel
		_create_mutators_list_original(self, panel)
		self._right = right_panel
	end

	function HUDStatsScreen:update(t, ...)
		update_original(self, t, ...)

		if self._clock_panel and (self._last_clock_update_t or 0) + 1 < t then
			local text = ""
			local mode = WolfHUD:getSetting({"TabStats", "CLOCK_MODE"}, 3)
			if mode == 4 then
				local time = math.floor(self._last_heist_time or 0)
				local hours = math.floor(time / 3600)
				time = time - hours * 3600
				local minutes = math.floor(time / 60)
				time = time - minutes * 60
				local seconds = math.round(time)
				text = hours > 0 and string.format("%02d:%02d:%02d", hours, minutes, seconds) or string.format("%02d:%02d", minutes, seconds)
			elseif mode == 3 then
				text = os.date("%X")
			elseif mode == 2 then
				text = os.date("%I:%M:%S %p")
			end
			self._clock_panel:child("time_text"):set_text(text)
			self._clock_panel:set_visible(mode > 1)
		end
		self._last_update_t = t
	end

	--OVERRIDE!!!
	function HUDStatsScreen:loot_value_updated(...)
		--loot_value_updated_original(self, ...)
		self:update_stats()
	end

	function HUDStatsScreen:_create_clock(panel)
		local clock_panel = ExtendedPanel:new(panel, { w = panel:w() * 0.5, h = tweak_data.hud_stats.objectives_font })
		local placer = UiPlacer:new(0, 0)

		placer:add_row(clock_panel:fine_text({
			name = "time_text",
			color = Color.white,
			alpha = 0.8,
			font_size = tweak_data.hud_stats.loot_size,
			font = tweak_data.hud_stats.objectives_font,
			text = "00:00:00",
			align = "right",
			w = clock_panel:w() - tweak_data.hud_stats.loot_size - 5,
			keep_w = true
		}))
		placer:add_right(clock_panel:fit_bitmap({
			name = "time_icon",
			texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
			alpha = 0.8,
			w = tweak_data.hud_stats.loot_size,
			h = tweak_data.hud_stats.loot_size,
		}), 5)

		self._clock_panel = clock_panel
		self._last_clock_update_t = 0
		return clock_panel
	end

	function HUDStatsScreen:_create_sidejobs_list(panel, ...)

	end


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
		max = {
			texture = "guis/dlcs/max/textures/pd2/blackmarket/icons/characters/max",
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
		local outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
		local mask_id = outfit and outfit.mask and outfit.mask.mask_id or "alienware"

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

	function HUDStatsScreen:_create_stat_list(panel, ...)
		self._tabstats_settings = {
			FONT_SIZE = WolfHUD:getSetting({"TabStats", "FONT_SIZE"}, 18),
			COLOR = WolfHUD:getSetting({"TabStats", "COLOR"}, "rainbow"),
			SHOW_MASK = WolfHUD:getSetting({"TabStats", "SHOW_MASK"}, true)
		}

		local placer = UiPlacer:new(10, 10, 0, 0)
		local difficulty_text, difficulty_color = "", Color.white
		local is_crime_spree = managers.crime_spree:is_active()

		if is_crime_spree then
			local level_data = managers.job:current_level_data()
			local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())

			if mission then
				local level_str = managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""

				placer:add_row(panel:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = level_str,
				}))
			end

			difficulty_text = managers.localization:text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
			difficulty_color = tweak_data.screen_colors.crime_spree_risk
		else
			local job_chain = managers.job:current_job_chain_data()
			local is_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id())
			local day = managers.job:current_stage()
			local days = job_chain and #job_chain or 0
			local day_title = placer:add_bottom(panel:fine_text({
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = managers.localization:to_upper_text("hud_days_title", {
					DAY = day,
					DAYS = days
				})
			}))

			if managers.job:is_level_ghostable(managers.job:current_level_id()) then
				local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
				local ghost_color = is_whisper_mode and Color.white or tweak_data.screen_colors.important_1
				local ghost = placer:add_right(panel:bitmap({
					texture = "guis/textures/pd2/cn_minighost",
					name = "ghost_icon",
					h = 16,
					blend_mode = "add",
					w = 16,
					color = ghost_color,
				}))

				ghost:set_center_y(day_title:center_y())
			end

			placer:new_row(8)

			local level_data = managers.job:current_level_data()

			if level_data then
				placer:add_bottom(panel:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = managers.localization:to_upper_text(tostring(level_data.name_id)) or "Unknown",
					color = (managers.job:is_current_job_professional() and tweak_data.screen_colors.important_1 or tweak_data.screen_colors.text)
				}))
			end

			local difficulty_stars = managers.job:current_difficulty_stars()
			local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
			local difficulty_string_id = tweak_data.difficulty_name_ids[difficulty]
			difficulty_text = managers.localization:to_upper_text(difficulty_string_id)
			difficulty_color = difficulty_stars > 0 and tweak_data.screen_colors.risk or tweak_data.screen_colors.text
		end

		local mask_icon = "guis/textures/pd2/blackmarket/icons/masks/grin"
		local mask_color = WolfHUD:getColorSetting({"TabStats", "COLOR"}, "red")
		if self._tabstats_settings.SHOW_MASK then
			mask_icon = self.getMaskImage()
		else
			local char_data = HUDStatsScreen.CHARACTERS[managers.criminals:local_character_name()]
			if char_data then
				mask_icon = char_data.texture or mask_icon
				mask_color = WolfHUD:getSetting({"TabStats", "COLOR"}, "rainbow") == "rainbow" and char_data.color or mask_color
			end
		end


		local padding = 10
		local list_w = panel:w() - 4 * self._rightpos[2]
		local small_list_w = list_w * 0.6
		placer:new_row(0, 12)
		local paygrade_title = self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "paygrade", managers.localization:to_upper_text("menu_lobby_difficulty_title"), difficulty_text, nil, self._tabstats_settings.FONT_SIZE or 18, nil, difficulty_color, nil)
		placer:new_row()
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "offshore_payout", managers.localization:to_upper_text("hud_offshore_account") .. ":", "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
		placer:new_row()
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "spending_cash", managers.localization:to_upper_text("menu_cash_spending"), "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
		placer:new_row()
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "cleaner_costs", managers.localization:to_upper_text("victory_civilians_killed_penalty"), "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
		placer:new_row(0, 12)
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "bag_amount", managers.localization:to_upper_text("hud_stats_bags_secured") .. ":", "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
		if not is_crime_spree then
			placer:new_row()
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "bag_cash", utf8.to_upper("Secured Bags value:"), "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
			placer:new_row()
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], small_list_w, "instant_cash", managers.localization:to_upper_text("hud_instant_cash") .. ":", "0", nil, self._tabstats_settings.FONT_SIZE or 18, nil, nil, nil)
		end
		placer:new_row(0, 12)

		if paygrade_title then
			panel:bitmap({
				name = "character_icon",
				texture = mask_icon,
				x = paygrade_title:right() + padding,
				y = paygrade_title:top(),
				w = list_w - small_list_w,
				h = list_w - small_list_w,
				blend_mode = "add",
				color = mask_color,
				align = "center",
				vertical = "center",
				valign = "center",
				--keep_w = true
			})
		end


		local items_color = self._tabstats_settings.COLOR ~= "rainbow" and WolfHUD:getColor(self._tabstats_settings.COLOR or "red") or false
		for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
			local name = data.name
			local color = items_color or data.color
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], (data.no_alltime and small_list_w or list_w), name, managers.localization:to_upper_text(data.text_id or ""), "0", not data.no_alltime and "0" or nil, self._tabstats_settings.FONT_SIZE or 18, color, color, false)
			placer:new_row()
		end

		self._stats_panel = panel
	end

	local add_bg = false
	function HUDStatsScreen:_create_stat_list_entry(placer, panel, offset, w, name, title, text, alltime_text, font_size, title_color, text_color, skip_toggle_bg)
		if placer and panel then
			local value_w = w * 0.4
			local title = placer:add_right(panel:text({
				name = name and string.format("%s_title", name) or nil,
				color = title_color or tweak_data.screen_colors.text,
				font_size = font_size or 18,
				font = tweak_data.menu.pd2_small_font,
				text = title,
				w = w,
				h = font_size or 18,
				keep_w = true
			}), offset)
			placer:add_right(nil, 0)
			if alltime_text then
				local text = placer:add_left(panel:text({
					name = name and string.format("%s_alltime_text", name) or nil,
					color = text_color or tweak_data.screen_colors.text,
					font_size = font_size or 18,
					font = tweak_data.menu.pd2_small_font,
					text = alltime_text,
					align = "right",
					vertical = "top",
					w = value_w,
					h = font_size or 18
				}))
			end
			local text = placer:add_left(panel:text({
				name = name and string.format("%s_text", name) or nil,
				color = text_color or tweak_data.screen_colors.text,
				font_size = font_size or 18,
				font = tweak_data.menu.pd2_small_font,
				text = text,
				align = "right",
				vertical = "top",
				w = value_w,
				h = font_size or 18
			}))

			if not alltime_text then
				placer:add_left(nil, value_w)
			end

			local bg
			if add_bg then
				placer:add_left(nil, w - (2 * value_w) + (offset * 0.5))
				bg = placer:add_right(panel:rect({
					name = name and string.format("%s_bg", name) or nil,
					w = w + offset,
					h = font_size or 18,
					color = Color.white:with_alpha(0.1),
					layer = -1
				}))
				placer:add_right(nil, -offset * 0.5)
			end

			if not skip_toggle_bg then
				add_bg = not add_bg
			end

			return title, text, bg
		end
	end

	function HUDStatsScreen:update_stats(item_list)
		if self._use_tab_stats then
			if type(item_list) == "string" then
				item_list = { item_list }
			end

			self:_update_stats_list(self._stats_panel, item)
		end
	end

	function HUDStatsScreen:feed_heist_time(time)
		if (self._last_heist_time or 0) < math.floor(time) then
			self._last_heist_time = time
		end
	end

	function HUDStatsScreen:_update_stats_list(panel, item)
		if not (self._use_tab_stats and panel) then return end
		if managers.money and managers.statistics and managers.experience and not item then
			local money_current_stage 	= managers.crime_spree:is_active() and managers.crime_spree:get_potential_payout_from_current_stage("cash") or managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate 		= managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local civilian_kills 		= managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs			= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local offshore_money 		= money_current_stage - math.round(money_current_stage * offshore_rate)
			local spending_cash 		= money_current_stage * offshore_rate - cleaner_costs
			panel:child("offshore_payout_text"):set_text(managers.experience:cash_string(offshore_money))
			panel:child("spending_cash_text"):set_text(managers.experience:cash_string(spending_cash))
			if spending_cash >= 0 then
				panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.friend_color)
			else
				panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.heat_cold_color)
			end
			panel:child("cleaner_costs_text"):set_text(managers.experience:cash_string(cleaner_costs) .. " (" .. tostring(civilian_kills) .. ")")

			local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
			local mandatory_amount = mandatory_bags_data and mandatory_bags_data.amount or 0
			local secured_amount = managers.loot:get_secured_mandatory_bags_amount() or 0
			local bonus_amount = managers.loot:get_secured_bonus_bags_amount() or 0
			local bags_amount_str = tostring(bonus_amount or 0)
			if mandatory_amount > 0 then
				bags_amount_str = string.format("%i / %i%s", secured_amount, mandatory_amount, bonus_amount > 0 and string.format(" + %i", bonus_amount) or "")
			end
			panel:child("bag_amount_text"):set_text(bags_amount_str)
			if panel:child("bag_cash_text") and panel:child("instant_cash_text") then
				panel:child("bag_cash_text"):set_text(managers.experience:cash_string((managers.money:get_secured_mandatory_bags_money() or 0) + (managers.money:get_secured_bonus_bags_money() or 0)))
				panel:child("instant_cash_text"):set_text(managers.experience:cash_string(managers.loot:get_real_total_small_loot_value() or 0))
			end
		end

		for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
			if not data.manual_update and (not item or item == data.name) then
				local update_data = data.update
				if update_data then
					local suffix_table = { func = "_text"}
					if not data.no_alltime then suffix_table.func_alltime = "_alltime_text" end
					for func, suffix in pairs(suffix_table) do
						local item = panel:child(data.name .. suffix)
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

	function HUDStatsScreen:update_setting(setting, value)
		if self._tabstats_settings[setting] ~= value then
			self._tabstats_settings[setting] = value
			if self._stats_panel then
			--	self._stats_panel:clear()
			--	self:_create_stat_list(self._stats_panel)
			end
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
				+ self:session_enemy_killed_by_type("tank_medic", "count")
				+ self:session_enemy_killed_by_type("tank_mini", "count")
				+ self:session_enemy_killed_by_type("tank_hw", "count")
	end

	function StatisticsManager:total_tanks_killed()
		return self:enemy_killed_by_type("tank", "count")
				+ self:enemy_killed_by_type("tank_green", "count")
				+ self:enemy_killed_by_type("tank_black", "count")
				+ self:enemy_killed_by_type("tank_skull", "count")
				+ self:enemy_killed_by_type("tank_medic", "count")
				+ self:enemy_killed_by_type("tank_mini", "count")
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
elseif string.lower(RequiredScript) == "lib/managers/crimespreemanager" then
	function CrimeSpreeManager:get_potential_payout_from_current_stage(reward_id)
		local multi = self:get_current_reward_multiplier()
		local rewards_table = {}
		for _, reward in ipairs(tweak_data.crime_spree.rewards) do
			if not reward_id then
				rewards_table[reward.id] = reward.amount * multi
			elseif reward.id == reward_id then
				return reward.amount * multi
			end
		end

		return rewards_table
	end

	function CrimeSpreeManager:get_current_reward_multiplier()
		if self:has_failed() then
			return 0
		end

		local mission_id = self:current_mission()
		local mission_data = mission_id and self:get_mission(mission_id)
		local reward_add = mission_data and mission_data.add or 0

		if not self:_is_host() and reward_add > 0 then
			if self:server_spree_level() > self:spree_level() then
				local diff = self:server_spree_level() - self:spree_level()
				local catch_up = math.floor(diff * tweak_data.crime_spree.catchup_bonus)
				reward_add = reward_add + catch_up
			elseif self:server_spree_level() < self:spree_level() then
				local diff = self:spree_level() - self:server_spree_level()
				reward_add = reward_add - diff
			end
		end
		reward_add = math.max(math.floor(reward_add), 0)

		if self:server_spree_level() >= self:spree_level() and reward_add > 0 then
			local streak_bonus = (self._global.winning_streak or 1) + reward_add * tweak_data.crime_spree.winning_streak
			if 1 > streak_bonus then
				streak_bonus = streak_bonus + 1
			end
			reward_add = math.max(math.floor(reward_add * streak_bonus), 0)
		end

		return reward_add
	end
elseif string.lower(RequiredScript) == "lib/managers/hudmanager" then
	local HUDManager_feed_heist_time_original = HUDManager.feed_heist_time

	function HUDManager:feed_heist_time(time, ...)
		HUDManager_feed_heist_time_original(self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.feed_heist_time then
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
