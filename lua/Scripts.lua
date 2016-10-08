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
end