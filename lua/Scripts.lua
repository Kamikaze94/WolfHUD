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
elseif string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
	local HUDTeammate_set_ammo_amount_by_type = HUDTeammate.set_ammo_amount_by_type
	function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
		if WolfHUD:getSetting("use_realammo", "boolean") then
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
elseif string.lower(RequiredScript) == "lib/managers/experiencemanager" then
	local cash_string_original = ExperienceManager.cash_string
	
	function ExperienceManager:cash_string(cash)
		local val = cash_string_original(self, cash)
		if self._cash_sign == "\194\128" then
			val = val:gsub(self._cash_sign, "") .. self._cash_sign
		end
		return val
	end
end