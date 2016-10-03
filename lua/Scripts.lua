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
	
	function ExperienceManager:cash_string(cash)
		local val = cash_string_original(self, cash)
		if self._cash_sign == "\194\128" then
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
end
