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

	-- Time within 2 presses of the nade button, to throw a nade in stealth.
	self.STEALTH_NADE_TIMEOUT = 0.25
	-- Time between 2 automatical pickups, when the interaction button remains pressed.
<<<<<<< HEAD
	self.AUTO_PICKUP_DELAY = 0.2
	
=======
	self.AUTO_PICKUP_DELAY = 0.1

>>>>>>> aaeee76... whitespace cleanup
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
		{ color = nil, 		name = "rainbow" 		},
	}

	self:post_init()
end

----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! -----------------------------------------

function WolfHUDTweakData:post_init()
end