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
		{ color = '000000', name = "rainbow" 		},
	}
	
	-- Inventory names
	-- 		Change the name of your Inventory Tabs. 
	--		You can also enter more, if you have mods that allow for more pages.
	--		'<skull>' will be replaced by the skull icon. (without quotations)
	-- 		'<ghost>' will be replaced by the ghost icon. (without quotations)
	self.inventory_names = {	
		primaries = {
			"Page 1",
			"Page 2",
			"Page 3",
			"Page 4",
			"Page 5",
			"Page 6",
			"Page 7",
			"Page 8",
			"Page 9",
			"Page 10",
		},
		secondaries = {
			"Page 1",
			"Page 2",
			"Page 3",
			"Page 4",
			"Page 5",
			"Page 6",
			"Page 7",
			"Page 8",
			"Page 9",
			"Page 10",
		},
		masks = {
			"Page 1",
			"Page 2",
			"Page 3",
			"Page 4",
			"Page 5",
			"Page 6",
			"Page 7",
			"Page 8",
			"Page 9",
			"Page 10",
		},
		melee_weapons = {
			"Page 1",
			"Page 2",
			"Page 3",
			"Page 4",
			"Page 5"
		},
	}
	
	self:post_init()
end

----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! ----------------------------------------- DONT EDIT BELOW THIS LINE!!! -----------------------------------------

function WolfHUDTweakData:post_init()
	local SUB_TABLE = {
		["<ghost>"] = utf8.char(57363),
		["<skull>"] = utf8.char(57364),
	}
	for category, names in pairs(self.inventory_names) do
		for i, _ in ipairs(names) do
			for key, subst in pairs(SUB_TABLE) do
				self.inventory_names[category][i] = self.inventory_names[category][i]:gsub(key, subst)
			end
		end
	end
end