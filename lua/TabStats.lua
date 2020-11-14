if string.lower(RequiredScript) == "lib/managers/hud/newhudstatsscreen" then
	local large_font = tweak_data.menu.pd2_large_font
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font = tweak_data.menu.pd2_medium_font
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font = tweak_data.menu.pd2_small_font
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local tiny_font = tweak_data.menu.pd2_tiny_font
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
	local objective_font = tweak_data.hud_stats.objective_desc_font
	local objective_font_size = tweak_data.hud.active_objective_title_font_size


	local update_original = HUDStatsScreen.update
	local recreate_left_original = HUDStatsScreen.recreate_left
	local recreate_right_original = HUDStatsScreen.recreate_right
	local _create_mutators_list_original = HUDStatsScreen._create_mutators_list
	local _create_tracked_list_original = HUDStatsScreen._create_tracked_list
	local loot_value_updated_original = HUDStatsScreen.loot_value_updated

	function HUDStatsScreen:recreate_left(...)
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
				color = Color.white
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
					font = medium_font,
					font_size = tweak_data.hud.objectives_title_size,
					w = row_w
				}))
				placer:new_row(8)
				local item = placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					font_size = objective_font_size * 0.9,
					align = "left",
					text = data.description,
					font = objective_font,
					w = row_w
				}), 0)
				y = math.max(y, item:bottom())
			end

			local placer = UiPlacer:new(0, 0)
			local ext_inv_panel = ExtendedPanel:new(self._left, {
				x = self._leftpos[2],
				y = self._left:h() - self._leftpos[2] - medium_font_size * 2 - 10,
				w = self._left:w() - 2 * self._leftpos[2],
				h = medium_font_size * 2 + 5
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
				font_size = small_font_size,
				font = small_font,
				color = tweak_data.screen_colors.text,
				align = "right",
				keep_w = true
			}))

			local list_panel = ExtendedPanel:new(self._left, {
				y = y + self._leftpos[2],
				w = self._left:w(),
				h = self._left:h() - y - ext_inv_panel:h() - 2 * self._leftpos[2]
			})

			if managers.mutators:are_mutators_active() then
				self:_create_mutators_list(list_panel)
			elseif table.size(managers.achievment:get_tracked_fill()) > 0 then
				self:_create_tracked_list(list_panel)
			elseif managers.challenge:can_progress_challenges() then
				self:_create_sidejobs_list(list_panel)
			end
		else
			recreate_left_original(self, ...)
		end
	end



	function HUDStatsScreen:recreate_right(...)
		if WolfHUD:getSetting({"TabStats", "ENABLED"}, true) then
			self._use_tab_stats = true

			if self._destroy_player_info then -- Enhanced Crew Loadout compatability
				self:_destroy_player_info()
			end

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

			if self._create_player_info then -- Enhanced Crew Loadout compatability
				self:_create_player_info()
			end
		else
			recreate_right_original(self, ...)
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

		if self._clock_panel and (self._next_clock_update_t or 0) < t then
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

			for _, sidejob in ipairs(self._sidejobs or {}) do
				sidejob:update(t, dt)
			end

			self._next_clock_update_t = t + 1
		end
	end

	function HUDStatsScreen:loot_value_updated(...)
		if self._use_tab_stats then
			self:update_stats()
		else
			loot_value_updated_original(self, ...)
		end
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
		local challenges, categories = self:get_active_challenges()
		local placer = UiPlacer:new(10, 10, 0, 8)
		placer:add_bottom(panel:fine_text({
			text_id = "menu_challenges",
			font = large_font,
			font_size = tweak_data.hud_stats.objectives_title_size
		}))

		self._sidejobs = {}
		local placer = UiPlacer:new(0, placer:most().bottom, 0, 0)
		for _, category in pairs(categories) do
			local challenges = challenges[category]
			if challenges and table.size(challenges or {}) > (challenges.category_id and 1 or 0) then
				placer:new_row(10, 8)
				local t = placer:add_bottom(panel:fine_text({
					wrap = true,
					word_wrap = true,
					text_id = challenges.category_id or string.format("menu_challenge_div_cat_%s", category),
					text = challenges.category_id == nil and "N/A",
					font = medium_font,
					font_size = medium_font_size,
					w = panel:w() - placer:current_left() * 2,
					x = 10,
				}))
				placer:add_left(nil, 10)
				if t:bottom() > panel:h() * 0.85 then
					return
				end

				local with_bg = true
				for _, challenge in pairs(challenges) do
					if type(challenge) == "table" and self:is_challenge_completable(challenge) then
						local s = placer:add_row(HudSidejob:new(panel, challenge.data, with_bg), 0, 0)
						table.insert(self._sidejobs, s)
						with_bg = not with_bg

						if s:bottom() > panel:h() * 0.85 then
							return
						end
					end
				end
			end
		end
	end

	function HUDStatsScreen:get_active_challenges()
		local categories = {
			"safehouse_daily",
			"daily",
			"weekly",
			"monthly"
		}

		local challenges = { safehouse_daily = { category_id = "menu_cs_div_safehouse_daily" } }
		local current_daily = managers.custom_safehouse:get_daily_challenge()
		if not managers.custom_safehouse:has_rewarded_daily(current_daily.id) then
			local daily_data = deep_clone(tweak_data.safehouse:get_daily_data(current_daily.id))
			daily_data.name_id = daily_data.id
			daily_data.category = "safehouse_daily"
			daily_data.completed = managers.custom_safehouse:has_completed_daily(current_daily.id)
			daily_data.rewarded = false
			daily_data.timestamp = current_daily.timestamp
			daily_data.interval = managers.custom_safehouse:interval_til_new_daily()
			if current_daily.trophy and current_daily.trophy.objectives then
				daily_data.objectives = deep_clone(current_daily.trophy.objectives) -- Fix missing objective progress for safehouse daily
			end

			local safehouse_challenge = {
				id = current_daily.id,
				data = daily_data
			}

			if self:is_challenge_completable(safehouse_challenge) then
				table.insert(challenges.safehouse_daily, safehouse_challenge)
			end
		end

		if managers.dlc:has_dlc("tango") then
			table.insert(categories, "tango")
			challenges.tango = {category_id = "menu_tango"}

			for _, tango_data in ipairs(managers.tango:challenges() or {}) do
				if not tango_data.rewarded then
					local data = deep_clone(tango_data)
					data.name_id = tango_data.name_id
					data.category = "tango"
					local tango_challenge = {
						id = tango_data.id,
						data = data
					}

					if self:is_challenge_completable(tango_challenge) then
						table.insert(challenges.tango, tango_challenge)
					end
				end
			end
		end

		for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
			if side_job_dlc.manager:can_progress() then
				local category = side_job_dlc.manager.category
				if category and not table.contains(categories, category) then
					table.insert(categories, category)
				end

				if category then
					for _, challenge_data in ipairs(side_job_dlc.manager:challenges()) do
						if not challenge_data.rewarded then
							local data = deep_clone(challenge_data)
							data.name_id = challenge_data.name_id
							data.category = category
							local challenge = { id = challenge_data.id, data = data }

							if self:is_challenge_completable(challenge) then
								challenges[category] = challenges[category] or {}
								table.insert(challenges[category], challenge)
							end
						end
					end
				end
			end
		end

		for _, challenge in pairs(managers.challenge:get_all_active_challenges()) do
			local category = challenge.category or "daily"
			local chall = {id = challenge.id, data = deep_clone(challenge)}
			chall.data.category = category

			if self:is_challenge_completable(chall) then
				challenges[category] = challenges[category] or {}
				table.insert(challenges[category], chall)
			end
		end

		return challenges, categories
	end

	function HUDStatsScreen:is_challenge_completable(challenge)
		if not (challenge and challenge.data) or challenge.data.completed then
			return not challenge.data.rewarded
		end

		local objectives = challenge.data and challenge.data.objectives
		for _, obj_data in ipairs(objectives or {}) do
			if obj_data and not obj_data.completed then
				local requirements = {}
				local is_completeable = true
				if (obj_data.achievement_id or obj_data.progress_id) and managers.custom_safehouse:can_progress_trophies(obj_data.achievement_id or obj_data.progress_id) then
					-- Try to find requirements for objective
					for category, data in pairs(tweak_data.achievement) do
						if type(data) == "table" and category ~= "visual" and data[obj_data.achievement_id or obj_data.progress_id] then
							requirements = data[obj_data.achievement_id or obj_data.progress_id]
							break
						end
					end
				end

				if requirements and table.size(requirements) > 0 then
					-- Check given requirements
					--log(json.encode(requirements))
					if (requirements.need_full_job or not requirements.is_dropin) and managers.statistics:is_dropin()then
						is_completeable = false
					end
					if is_completeable and requirements.crime_spree and managers.crime_spree and not managers.crime_spree:is_active() then
						if type(requirements.crime_spree) ~= "number" or requirements.crime_spree > managers.crime_spree:spree_level() then
							is_completeable = false
						end
					end
					if is_completeable and requirements.difficulty then
						local difficulty_stars = managers.job:current_difficulty_stars()
						local difficulty = tweak_data.difficulties[difficulty_stars + 2] or "unknown"
						if not table.contains(requirements.difficulty, difficulty) then
							is_completeable = false
						end
					end
					if is_completeable and (requirements.job or requirements.jobs) then
						local job_id = managers.job:current_job_id()
						if type(requirements.job) == "string" and job_id ~= requirements.job or not table.contains(requirements.jobs or {}, job_id) then
							is_completeable = false
						end
					end

					if is_completeable and not (managers.challenge:check_equipped_team(requirements) and managers.challenge:check_equipped(requirements)) then
						is_completeable = false
					end
				end

				if is_completeable then	-- At least one of the sidejobs objectives is completeable
					return true
				end
			end
		end
		-- All sidejob objectives cannot be completed.
		return false
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
		myh = {
			texture = "guis/dlcs/myh/textures/pd2/blackmarket/icons/characters/myh",
			color = Color(1, 0.05, 0.65, 0.02)
		},
		ecp_male = {
			texture = "guis/dlcs/ecp/textures/pd2/blackmarket/icons/characters/ecp_male",
			color = Color(1, 0.02, 0.05, 0.65)
		},
		ecp_female = {
			texture = "guis/dlcs/ecp/textures/pd2/blackmarket/icons/characters/ecp_female",
			color = Color(1, 0.65, 0.02, 0.05)
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
		{ name = "nonspecials_killed", 	text_id = "wolfhud_tabstats_nonspecial_kills", 	color = Color(1, 0.78, 0.15, 0.21),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"non_special", "count"}	}, 	},
		{ name = "total_killed", 		text_id = "wolfhud_tabstats_total_kills", 		color = Color(1, 0.5, 0.5, 0.21),	update = {func = "session_enemy_killed_by_type", 	func_alltime = "enemy_killed_by_type", 	params = {"total", "count"}	}, 	},
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
		local is_skirmish = managers.skirmish:is_skirmish()

		if is_crime_spree then
			local level_data = managers.job:current_level_data()
			local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())

			if mission then
				local level_str = managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""
				local difficulty_increase = mission and mission.add or 0

				placer:add_row(panel:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = level_str,
				}))
				placer:add_right(panel:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = string.format("+%s", managers.localization:text("menu_cs_level", {level = difficulty_increase})),
					color = tweak_data.screen_colors.crime_spree_risk,
				}))
			end

			difficulty_text = managers.localization:text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
			difficulty_color = tweak_data.screen_colors.crime_spree_risk
		elseif is_skirmish then
			local day_title = placer:add_bottom(panel:fine_text({
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = managers.localization:to_upper_text(managers.skirmish:is_weekly_skirmish() and "hud_weekly_skirmish" or "hud_skirmish"),
				color = tweak_data.screen_colors.skirmish_color
			}))

			placer:new_row(8)

			local level_data = managers.job:current_level_data()

			if level_data then
				placer:add_bottom(panel:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = managers.localization:to_upper_text(tostring(level_data.name_id)) or "Unknown"
				}))
			end

			difficulty_text = managers.localization:to_upper_text("hud_assault_waves", {current = managers.skirmish:current_wave_number(), max = #tweak_data.skirmish.ransom_amounts})
			difficulty_color = tweak_data.screen_colors.skirmish_color
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
			difficulty_color = Global.game_settings.one_down and tweak_data.screen_colors.one_down or difficulty_stars > 0 and tweak_data.screen_colors.risk or tweak_data.screen_colors.text
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
		local list_w = panel:w() - 3 * self._rightpos[2]
		local small_list_w = list_w --* 0.6
		placer:new_row(0, 12)
		local _, paygrade_text = self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "paygrade",
			{ text = managers.localization:to_upper_text("menu_lobby_difficulty_title"), font_size = self._tabstats_settings.FONT_SIZE or 18 },
			{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18, color = difficulty_color }, nil, false)
		placer:new_row()
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "offshore_payout",
			{ text = managers.localization:to_upper_text("hud_offshore_account") .. ":", font_size = self._tabstats_settings.FONT_SIZE or 18 },
			{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
		placer:new_row()
		self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "spending_cash",
			{ text = managers.localization:to_upper_text("menu_cash_spending"), font_size = self._tabstats_settings.FONT_SIZE or 18 },
			{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
		if not is_skirmish then
			placer:new_row()
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "cleaner_costs",
				{ text = managers.localization:to_upper_text("victory_civilians_killed_penalty"), font_size = self._tabstats_settings.FONT_SIZE or 18 },
				{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
			placer:new_row(0, 12)
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "bag_amount",
				{ text = managers.localization:to_upper_text("hud_stats_bags_secured") .. ":", font_size = self._tabstats_settings.FONT_SIZE or 18 },
				{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
		end
		if not (is_crime_spree or is_skirmish) then
			placer:new_row()
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "bag_cash",
			{ text = utf8.to_upper("Secured Bags value:"), font_size = self._tabstats_settings.FONT_SIZE or 18 },
			{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
			placer:new_row()
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], list_w, "instant_cash",
			{ text = managers.localization:to_upper_text("hud_instant_cash") .. ":", font_size = self._tabstats_settings.FONT_SIZE or 18 },
			{ text = difficulty_text, font_size = self._tabstats_settings.FONT_SIZE or 18 }, nil, nil)
		end

		local size = list_w - placer:current_right()
		local most = placer:most()
		local cy = most.top + (most.bottom - most.top) / 2 + 36
		panel:bitmap({
			name = "character_icon",
			texture = mask_icon,
			x = paygrade_text:right() + padding,
			y = paygrade_text:bottom(),
			w = size,
			h = size,
			blend_mode = "add",
			color = mask_color,
			align = "center",
			vertical = "center",
			valign = "center",
			--keep_w = true
		}):set_center_y(cy)

		placer:new_row(0, 12)

		local items_color = self._tabstats_settings.COLOR ~= "rainbow" and WolfHUD:getColor(self._tabstats_settings.COLOR or "red") or false
		for i, data in ipairs(HUDStatsScreen.STAT_ITEMS) do
			local name = data.name
			local color = items_color or data.color
			local title_params = { color = color, font_size = self._tabstats_settings.FONT_SIZE or 18, text = managers.localization:to_upper_text(data.text_id or "") }
			local text_params = { color = color, font_size = self._tabstats_settings.FONT_SIZE or 18, text = string.format("0%s", data.suffix or "") }
			self:_create_stat_list_entry(placer, panel, self._rightpos[2], (data.no_alltime and small_list_w or list_w), name, title_params, text_params, not data.no_alltime and text_params or nil, nil)
			placer:new_row()
		end

		self._stats_panel = panel
	end

	local add_bg = false
	function HUDStatsScreen:_create_stat_list_entry(placer, panel, offset, w, name, title_params, text_params, alltime_params, force_bg_state)
		if placer and panel then
			local session_w = w * 0.6
			local alltime_w = w - session_w
			local total_w = session_w
			if force_bg_state ~= nil then
				add_bg = force_bg_state
			end

			local title = placer:add_right(panel:text({
				name = name and string.format("%s_title", name) or nil,
				color = title_params.color or tweak_data.screen_colors.text,
				font_size = title_params.font_size or 18,
				font = small_font,
				text = title_params.text,
				w = session_w - offset,
				h = font_size or 18,
				keep_w = true
			}), offset)

			placer:add_right(nil, 0)

			local text = placer:add_left(panel:text({
				name = name and string.format("%s_text", name) or nil,
				color = text_params.color or tweak_data.screen_colors.text,
				font_size = text_params.font_size or 18,
				font = small_font,
				text = text_params.text,
				align = "right",
				vertical = "top",
				w = session_w,
				h = text_params.font_size or 18,
				keep_w = true
			}))

			if alltime_params then
				local text = placer:add_right(panel:text({
					name = name and string.format("%s_alltime_text", name) or nil,
					color = alltime_params.color or tweak_data.screen_colors.text,
					font_size = alltime_params.font_size or 18,
					font = small_font,
					text = alltime_params.text,
					align = "right",
					vertical = "top",
					w = alltime_w,
					h = alltime_params.font_size or 18,
					keep_w = true
				}))
				total_w = total_w + alltime_w
			end


			local bg
			if add_bg then
				placer:add_right(nil, offset * 0.5)
				bg = placer:add_left(panel:rect({
					name = name and string.format("%s_bg", name) or nil,
					w = total_w,
					h = font_size or 18,
					color = Color.white:with_alpha(0.1),
					layer = -1
				}))
				--placer:add_right(nil, -offset * 0.5)
			end

			add_bg = not add_bg

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
		if (self._last_heist_time or 0) < math.floor(time) or time < 0 then
			self._last_heist_time = math.abs(time)
		end
	end

	function HUDStatsScreen:modify_heist_time(time)
		if time and time ~= 0 then
			self._last_heist_time = (self._last_heist_time or 0) + time
		end
	end

	function HUDStatsScreen:_update_stats_list(panel, item)
		if not (self._use_tab_stats and panel) then return end
		if managers.money and managers.statistics and managers.experience and not item then
			local money_current_stage 	= managers.crime_spree:is_active() and managers.crime_spree:get_potential_payout_from_current_stage("cash") or managers.skirmish:is_skirmish() and managers.skirmish:current_ransom_amount() or managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate 		= managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local civilian_kills 		= managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs			= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local offshore_money 		= money_current_stage - math.round(money_current_stage * offshore_rate)
			local spending_cash 		= money_current_stage * offshore_rate - cleaner_costs
			panel:child("offshore_payout_text"):set_text(managers.experience:cash_string(offshore_money))
			panel:child("spending_cash_text"):set_text(managers.experience:cash_string(spending_cash))

			if panel:child("cleaner_costs_text") then
				if spending_cash > 0 then
					panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.friend_color)
				elseif spending_cash == 0 then
					panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.text)
				else
					panel:child("spending_cash_text"):set_color(tweak_data.screen_colors.heat_cold_color)
				end
				panel:child("cleaner_costs_text"):set_text(managers.experience:cash_string(cleaner_costs) .. " (" .. tostring(civilian_kills) .. ")")
			end

			if panel:child("bag_amount_text") then
				local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
				local mandatory_amount = mandatory_bags_data and mandatory_bags_data.amount or 0
				local secured_amount = managers.loot:get_secured_mandatory_bags_amount() or 0
				local bonus_amount = managers.loot:get_secured_bonus_bags_amount() or 0
				local bags_amount_str = tostring(bonus_amount or 0)
				if mandatory_amount > 0 then
					bags_amount_str = string.format("%i / %i%s", secured_amount, mandatory_amount, bonus_amount > 0 and string.format(" + %i", bonus_amount) or "")
				end
				panel:child("bag_amount_text"):set_text(bags_amount_str)
			end

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

	HudSidejob = HudSidejob or class(GrowPanel)
	function HudSidejob:init(parent, data, black_bg)
		HudSidejob.super.init(self, parent, {
			border = 10,
			padding = 4,
			fixed_w = parent:w()
		})

		self._id = data.id
		self._info = data
		self._objectives = data.objectives
		self._progress_ids = {}
		local completed = self._info.completed
		local placer = self:placer()
		placer:new_row(0, 0)

		local title = placer:add_bottom(self:fine_text({
			text_id = self._info.name_id or "N/A",
			font = medium_font,
			font_size = medium_font_size,
			color = completed and tweak_data.screen_colors.challenge_completed_color or tweak_data.screen_colors.text,
			w = parent:w(),
			keep_w = true
		}))

		if not completed and self._info.timestamp then
			placer:add_right(nil, 0)
			self._timer = placer:add_left(self:text({
				font = tiny_font,
				font_size = tiny_font_size,
				color = tweak_data.screen_colors.important_2:with_alpha(0.6),
				align = "right",
				vertical = "center",
				h = medium_font_size,
			}))
			self._timer:set_rightbottom(self:right() - 10, title:bottom() - 5)
		end

		local rewards = self._info.rewards
		local texture = rewards and rewards[#rewards].texture_path or "guis/textures/pd2/feature_crimenet_heat"
		local bitmap = placer:add_row(self:bitmap({
			w = 50,
			h = 50,
			texture = texture
		}))

		if not completed then
			bitmap:set_color(Color.white:with_alpha(0.1))
			self._panel:bitmap({
				texture = "guis/dlcs/trk/textures/pd2/lock",
				w = bitmap:w(),
				h = bitmap:h(),
				x = bitmap:x(),
				y = bitmap:y()
			})
		end
		placer:add_right(nil, 0)

		if self._objectives then
			for i, objective in ipairs(self._objectives or {}) do
				if objective.display ~= false then
					local desc = self:text({
						wrap = true,
						word_wrap = true,
						text = managers.localization:text(objective.desc_id or self._info.objective_id or self._info.desc_id or "N/A", {max_progress = objective.max_progress or "?", progress = objective.progress or "?"}),
						font = tiny_font,
						font_size = tiny_font_size,
						color = tweak_data.screen_colors.achievement_grey,
						w = self:row_w() - placer:current_left(),
					})
					self.limit_text_rows(desc, 4)
					placer:add_bottom(self.make_fine_text(desc), 0)
				end
				if objective.max_progress > 1 and objective.show_progress ~= false then
					local bar = placer:add_bottom(TextProgressBar:new(self, {
						w = 300,
						h = 10,
						back_color = Color(255, 60, 60, 65) / 255,
						max = objective.max_progress
					}, {
						font_size = 12,
						font = tiny_font
					}, objective.progress))
				end
			end
		end

		if black_bg then
			self:rect({
				layer = -1,
				color = Color.black:with_alpha(0.6)
			})
		end
	end

	function HudSidejob:update(t, dt)
		if self._timer then
			local current_timestamp = managers.challenge:get_timestamp()
			local timestamp = self._info.timestamp or current_timestamp
			local expire_timestamp = timestamp + (self._info.interval or 0)
			local expire_time = expire_timestamp - current_timestamp

			if expire_time then
				local remaining_str = self:_create_time_string(expire_time)
				self._timer:set_text(remaining_str)
			end
		end
	end

	function HudSidejob:_create_time_string(timestamp)
		if timestamp >= 0 then
			local minutes = 59 - tonumber(Application:date("%M"))
			local seconds = 59 - tonumber(Application:date("%S"))
			local expire_string = ""
			if timestamp > 24 then
				expire_string = managers.localization:text("cn_menu_contract_length", {stages = math.floor(timestamp/24)})
			end
			expire_string = string.format("%s %02d:%02d:%02d", expire_string, timestamp % 24, minutes, seconds)
			return expire_string
		else
			return managers.localization:text("menu_challenge_about_to_expire_extended")
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

	local TANK_IDs = { "tank", "tank_green", "tank_black", "tank_skull", "tank_medic", "tank_mini", "tank_hw" }

	function StatisticsManager:session_total_tanks_killed()
		local count = 0
		for _, unit_id in ipairs(TANK_IDs) do
			count = count + self:session_enemy_killed_by_type(unit_id, "count")
		end
		return count
	end

	function StatisticsManager:total_tanks_killed()
		local count = 0
		for _, unit_id in ipairs(TANK_IDs) do
			count = count + self:enemy_killed_by_type(unit_id, "count")
		end
		return count
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
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local HUDManager_feed_heist_time_original = HUDManager.feed_heist_time
	local HUDManager_modify_heist_time_original = HUDManager.modify_heist_time

	function HUDManager:feed_heist_time(time, ...)
		HUDManager_feed_heist_time_original(self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.feed_heist_time then
			self._hud_statsscreen:feed_heist_time(time)
		end
	end

	function HUDManager:modify_heist_time(time)
		HUDManager_modify_heist_time_original(self, time)
		if self._hud_statsscreen and self._hud_statsscreen.modify_heist_time then
			self._hud_statsscreen:modify_heist_time(time)
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

	function HUDManager:_setup_stats_screen()	-- Tmp: Currently not much useful on left skirmish stats screen...
		if not self:alive(self.STATS_SCREEN_FULLSCREEN) then
			return
		end

		self._hud_statsscreen = HUDStatsScreen:new()
	end
end
