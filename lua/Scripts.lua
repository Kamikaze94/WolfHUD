if string.lower(RequiredScript) == "lib/units/weapons/raycastweaponbase" then
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
elseif string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local set_teammate_ammo_amount_orig = HUDManager.set_teammate_ammo_amount
	local set_slot_ready_orig = HUDManager.set_slot_ready
	
	function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max)
		if WolfHUD:getSetting("use_realammo", "boolean") then
			local total_left = current_left - current_clip
			if total_left >= 0 then 
				current_left = total_left
				max = max - current_clip
			end
		end
		return set_teammate_ammo_amount_orig(self, id, selection_index, max_clip, current_clip, current_left, max)
	end
	
	
	local FORCE_READY_CLICKS = 3
	local FORCE_READY_TIME = 2
	local FORCE_READY_ACTIVE_T = 90
		
	local force_ready_start_t = 0
	local force_ready_clicked = 0
	
	function HUDManager:set_slot_ready(peer, peer_id)
		set_slot_ready_orig(self, peer, peer_id)
		
		if Network:is_server() and not Global.game_settings.single_player then
			local session = managers.network and managers.network:session()
			local local_peer = session and session:local_peer()
			local time_elapsed = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0
			if local_peer and local_peer:id() == peer_id and time_elapsed > FORCE_READY_ACTIVE_T then
				local t = Application:time()
				if (force_ready_start_t + FORCE_READY_TIME) > t then
					force_ready_clicked = force_ready_clicked + 1
					if force_ready_clicked >= FORCE_READY_CLICKS then
						local abort = false --session:chk_all_handshakes_complete()
						for i, peer in ipairs(session:peers()) do
							if not (peer:synced() or peer:id() == local_peer:id()) then
								abort = true
								break
							end
						end
						if game_state_machine and not abort then
							local menu_options = {
								[1] = {
									text = managers.localization:text("dialog_yes"),
									callback = function(self, item)
										managers.chat:send_message(ChatManager.GAME, local_peer, "The Game was forced to start.")
										game_state_machine:current_state():start_game_intro()
									end,
								},
								[2] = {
									text = managers.localization:text("dialog_no"),
									is_cancel_button = true,
								}
							}
							QuickMenu:new( managers.localization:text("wolfhud_dialog_force_start_title"), managers.localization:text("wolfhud_dialog_force_start_desc"), menu_options, true )
						end
					end
				else
					force_ready_clicked = 1
					force_ready_start_t = t
				end
			end
		end
	end
elseif string.lower(RequiredScript) == "lib/tweak_data/timespeedeffecttweakdata" then
	local init_original = TimeSpeedEffectTweakData.init
	function TimeSpeedEffectTweakData:init()
		init_original(self)
		if WolfHUD:getSetting("no_slowmotion", "boolean") then
			local function disable_effect(table)
				for name, data in pairs(table) do
					if data.speed and data.sustain then
						data.speed = 1
						data.fade_in_delay = 0
						data.fade_in = 0
						data.sustain = 0
						data.fade_out = 0
					elseif type(data) == "table" then
						disable_effect(data)
					end
				end
			end
			
			disable_effect(self)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/experiencemanager" then
	local cash_string_original = ExperienceManager.cash_string
	
	function ExperienceManager:cash_string(...)
		local val = cash_string_original(self, ...)
		if self._cash_sign == "\194\128" and val:find(self._cash_sign) then
			val = val:gsub(self._cash_sign, "") .. self._cash_sign
		end
		return val
	end
elseif string.lower(RequiredScript) == "lib/managers/moneymanager" then
	local total_string_original = MoneyManager.total_string
	local total_collected_string_original = MoneyManager.total_collected_string
	
	function MoneyManager:total_string()
		local total = math.round(self:total())
		return managers.experience:cash_string(total)
	end
	function MoneyManager:total_collected_string()
		local total = math.round(self:total_collected())
		return managers.experience:cash_string(total)
	end
elseif string.lower(RequiredScript) == "lib/setups/menusetup" then
	------------
	-- Purpose: Hooks MenuSetup:init_game() to force the game to skip the intro videos and go straight to the attract screen (as though -skip_intro had been specified on the command line)
	------------
	local SKIP_TO_MAIN_MENU = WolfHUD:getSetting("skip_to_main_menu", "boolean")
	local init_game_actual = MenuSetup.init_game
	function MenuSetup:init_game(...)
			local result = init_game_actual(self, ...)
		if SKIP_TO_MAIN_MENU then
			game_state_machine:set_boot_intro_done(true)
			-- WARNING: Do not go straight to "menu_main" as that bypasses loading of the savefile and is likely to cause data loss (not extensively tested)
			game_state_machine:change_state_by_name("menu_titlescreen")
		end

			return result
		end

elseif string.lower(RequiredScript) == "lib/states/menutitlescreenstate" then
	------------
	-- Purpose: Hooks MenuTitlescreenState:get_start_pressed_controller_index() to trigger the game to proceed straight to the main menu with keyboard input instead of waiting on the attract screen, and also hooks MenuTitlescreenState:_load_savegames_done() to suppress the menu entry sound that is played when the main menu is entered (but only for automatic entries)
	------------

	local silenced = false

	local SKIP_TO_MAIN_MENU = WolfHUD:getSetting("skip_to_main_menu", "boolean")
	local get_start_pressed_controller_index_actual = MenuTitlescreenState.get_start_pressed_controller_index
	function MenuTitlescreenState:get_start_pressed_controller_index(...)

		if SKIP_TO_MAIN_MENU then

			local num_connected = 0
			local keyboard_index = nil

			for index, controller in ipairs(self._controller_list) do
				if controller._was_connected then
					num_connected = num_connected + 1
				end
				if controller._default_controller_id == "keyboard" then
					keyboard_index = index
				end
			end

			if num_connected == 1 and keyboard_index ~= nil then
				silenced = true
				return keyboard_index
			else
				return get_start_pressed_controller_index_actual(self, ...)
			end
		else
			return get_start_pressed_controller_index_actual(self, ...)
		end
	end

	local _load_savegames_done_actual = MenuTitlescreenState._load_savegames_done
	function MenuTitlescreenState:_load_savegames_done(...)
			if silenced and SKIP_TO_MAIN_SCREEN then
				-- Shush. Don't play that sound if this is an automatic entry
				self:gsm():change_state_by_name("menu_main")
			else
				_load_savegames_done_actual(self, ...)
			end
		end

elseif string.lower(RequiredScript) == "lib/managers/challengemanager" then
	local sjil_original_challengemanager_ongivereward = ChallengeManager.on_give_reward
	function ChallengeManager:on_give_reward(id, key, reward_index)
		local reward = sjil_original_challengemanager_ongivereward(self, id, key, reward_index)
		self.sjil_reward_in_progress = reward and reward.choose_weapon_reward and reward or nil
		return reward
	end

	local sjil_original_challengemanager_givereward = ChallengeManager._give_reward
	function ChallengeManager:_give_reward(challenge, reward)
		local result = sjil_original_challengemanager_givereward(self, challenge, reward)

		if result.choose_weapon_reward then
			-- No! It's not done yet!
			result.rewarded = false
		end

		return result
	end

	function ChallengeManager:sjil_finalize_all_challenges()
		if not self._global.validated then
			return
		end

		for _, challenge in pairs(self:get_all_active_challenges() or {}) do
			local all_rewarded = true
			for _, reward in pairs(challenge.rewards) do
				if not reward.rewarded then
					all_rewarded = false
				end
			end
			if all_rewarded then
				challenge.rewarded = all_rewarded
				self._any_challenge_rewarded = true
			end
		end
	end
end
