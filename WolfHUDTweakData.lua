WolfHUDTweakData = WolfHUDTweakData or class()
function WolfHUDTweakData:init()
	----------------------------------------------------------------------------------------------------------------------
	-- WolfHUD Tweak Data																								--
	----------------------------------------------------------------------------------------------------------------------
	-- This file enables access to advanced settings, or those I cannot really implement into ingame menus easily.		--
	-- If you want to save those changes, please copy this file to "Payday 2/mods/saves" and edit that copy instead.	--
	-- You will need to take care of that version beeing up to date on your own. 										--
	-- It will not get changed on updates automatically.																--
	-- If you encounter problems, make sure the contents of this file matches the contents of your customized version.	--
	----------------------------------------------------------------------------------------------------------------------

	-- Currency used ingame
	self.CASH_SIGN = "$"				-- Dollar
	--self.CASH_SIGN = "\194\128"		-- EUR

	-- Maximum amount of Plans, that can be saved per level/map.
	self.MAX_PRE_PLANS = 10
	-- Maximum Length of custom weapon names.
	self.MAX_WEAPON_NAME_LENGTH = 30
	-- Maximum Length of custom Skill set names.
	self.MAX_SKILLSET_NAME_LENGTH = 25
    -- Maximum Length of Profile names.
    self.MAX_PROFILE_NAME_LENGTH = 20

	-- Time within 2 presses of the nade button, to throw a nade in stealth.
	self.STEALTH_NADE_TIMEOUT = 0.25
	-- Time within 2 presses of the interact button, to deploy a shaped charge in stealth.
	self.STEALTH_SHAPED_CHARGE_TIMEOUT = 0.25
	-- Time within 2 presses of the interact button, to close a door using a keycard. (hoxton breakout day 2)
	self.KEYCARD_DOORS_TIMEOUT = 0.25
	-- Time between 2 automatical pickups, when the interaction button remains pressed.
	self.AUTO_PICKUP_DELAY = 0.2

	-- Component Layouts  for Lobby and briefing loadout panels.
	-- The total width and height of those panels are fixed, so adding too many components into a row or column will make them incredibly small.
	-- Available components:
--[[
		name 					-> The name (+ rank in lobby)
		level 					-> The level + infamy
		ping					-> The latency
		playtime 				-> The Steam playtime (in hours)
		character				-> The used character
		skills 					-> The equipped skill build
		perk 					-> The equipped perkdeck
		primary 				-> The primary weapon + used mods
		secondary 				-> The secondary weapon + used mods
		melee_weapon			-> The equipped melee weapon
		grenade 				-> The eqipped throwable
		mask					-> The mask worn
		armor 					-> The armor worn
		deployable 				-> The equipped deployable
		secondary_deployable 	-> The eqipped secondary deployable (in case of Jack of all trades)
--]]
	self.STD_LOBBY_LOADOUT_LAYOUT = {
										{ "playtime", "ping" },
										{ "name" },
										{ "character" },
										{ "skills" },
										{ "perk" },
										{ "primary" },
										{ "secondary" },
										{ "melee_weapon" },
										{ "grenade", "armor" },
										{ "deployable", "secondary_deployable" }
									}
	self.CS_LOBBY_LOADOUT_LAYOUT = {
										{ "playtime", "ping" },
										{ "name" },
										{ "skills" },
										{ "perk" },
										{ "primary", "secondary" },
										{ "grenade", "armor" },
										{ "deployable", "secondary_deployable" }
									}
	self.BRIEFING_LOADOUT_LAYOUT = 	{
										{ "perk" },
										{ "skills" },
										{ "primary" },
										{ "secondary" },
										{ "melee_weapon", "grenade" },
										{ "armor", "mask" },
										{ "deployable", "secondary_deployable" }
									}
	self.TAB_LOADOUT_LAYOUT = 		{
										{ "name", "ping" },
										{ "skills", "perk" },
									}

	-- Color table
	-- 		Add or remove any color you want
	--		'color' needs to be that colors hexadecimal code
	-- 		'name' will be the name it appears in the selection menus
	self.color_table = {
		{ color = 'FFFFFF', name = "white" 			},
		{ color = 'F2F250', name = "light_yellow" 	},
		{ color = 'F2C24E', name = "light_orange" 	},
		{ color = 'E55858', name = "light_red" 		},
		{ color = 'CC55CC', name = "light_purple" 	},
		{ color = '00FF00', name = "light_green" 	},
		{ color = '00FFFF', name = "light_blue" 	},
		{ color = 'BABABA', name = "light_gray" 	},
		{ color = 'FFFF00', name = "yellow" 		},
		{ color = 'FFA500', name = "orange" 		},
		{ color = 'FF0000', name = "red" 			},
		{ color = '800080', name = "purple" 		},
		{ color = '008000', name = "green" 			},
		{ color = '0000FF', name = "blue" 			},
		{ color = '808080', name = "gray" 			},
		{ color = '000000', name = "black" 			},
		{ color = nil, name = "rainbow" 			},
	}

	self:post_init()
end

----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! -----------------------------------------

function WolfHUDTweakData:post_init()
	for _, data in ipairs(self.color_table) do
		if data.name == "rainbow" then
			data.color_func = function(frequency)
				local r = Application:time() * 360 * (frequency or 1)
				local r, g, b = (1 + math.sin(r + 0)) / 2, (1 + math.sin(r + 120)) / 2, (1 + math.sin(r + 240)) / 2
				return Color(r, g, b)
			end
		end
	end
end