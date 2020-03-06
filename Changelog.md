# WolfHUD v3.1


### Changelog Bugfix 3:
- General:
	- Updated README with new info on autoupdates
	- Fixed encoding of file mod.txt
- LoadoutPanel: 
	- Fixed wrong weapon skin icons

### Changelog Bugfix 2:
__Note:__
  
    For updates via the Downloadmanager: 
	- The WolfHUD insatll folder must be named 'WolfHUD-master'
	- The WolfHUD install folder cannot contain any files or folder names starting with a dot.

- General:
	- Got rid of all files and folders starting with a dot, to fix autoupdates

### Changelog Bugfix 1:

__Note:__
  
    - 'WolfHUDTweakData.lua' got updated this release.
	- If you use a customized one, please make sure, you update it.

- General:
	- Updated README.md with new details on autoupdate feature
- EnemyHealthbar:
	- Added 2 new NPC types
- HUDList:
	- Created custom name for egg + treasure loot trackers
- RichPresence:
	- Added name of new heist

### Changelog:

- General:
	- Enabled automatic updates via GitHUB
- HUDList:
	- Added Farbergee egg + Treasure loot types
	- Added security_mex + civilian_marachi units
- CustomHUD:
	- Fixed display of skins with new weapon_color system
- LoadoutPanel:
	- Fixed display of skins with new weapon_color system

# WolfHUD v3.0

__Note:__
  
    - This lists most changes since the last pushed update on paydaymods.com . 
    - No guarantees of this list being a complete rundown of changes. 
    - (Pretty sure quite some, mainly fixes, are missing here...sorry :S)
---
### Changelog:

- General:
    - Created TweakFile with additional settings
    - Moved some constants to new tweak file.
    - Complete rework of the settings system.
    - Completely redone ingame settings.
    - Added force start function (Only available after 90 seconds, or all players are on your friends list. Force-Start by clicking ready 3 times.)
    - Folder creation on Linux fixed, game no longer minimizing on folder creation in general. (_Thanks to BangL_)
    - Removed Shooting through bots, as it was an old leftover and people complained it beeing too hard to kill their jokers on purpose.
    - Fixed all json formats, so the BLTs new class doen't puke into the log anymore (_Thanks to NHellFire_)
- HUDList:
    - Added First Aid Kit counter
    - Fixed Safehouse NPCs appearing as Minions to clients
    - Fixed distance calculation as spectator
    - Added Prison Nightmare loot types, suppressed one of the timers
    - Added Increase/decrease animation to right list
    - Added Stealing Xmas loot, small loot, paycheck masks
    - Added Gage keys/cases
    - Added Yayo loot types
    - Added Kingpin buff
    - Added Scarface mension unit types
    - Added Frenzy Damage reduction buff
    - Fixed tape loop timer on reapply.
    - Added drill auto-repair indicator (host-only) (_Thanks to BangL_)
    - Added option to only show own minions (_Thanks to Seven_)
    - Added HeatStreet posters
    - Added Life Steal and Melee Invincible (gage Boosts) buffs
    - Fixeed cam count as client, as far as possible.
    - Added Green Bridge Hadcuffs item
    - Quite some additions and fixes to damage reducing skills.
    - Added composite damge reduction buff
    - Fixed Muscle, Hostage Taker buffs not running on full Frenzy health
    - Change to make buff setting changes apply on the fly.
    - Changed ECM Jammer and Feedback low battery handling.
    - Added progress bars to left and right list, to get a more standardized look.
    - Fixed PanelFrame class overlapping in the corners, added alpha setting, fixed color changing.
    - Implemented proper class structure for TimerItems, added Upgradable timer item class
    - Added item priorities changing on the fly, as well as changing the item order based on those priorities.
    - Added timers sorting by remaining time, Equipment by remaining amount in them.
    - Added indicator and hiding items, in case there isn't enough space to display them all. (looking at you, bomb dockyard drills...)
    - Added Special equipment groups (mission, loot, colectable) as well as settings to show/hide only specific groups.
    - Implemented proper on the fly rescaling and recoloring.
    - Added Sicario buff, sicario dodge chance (_Thanks to Seven_), Added Henchman inspire cooldown timer
    - Added Henchman throwable regen buff
    - Added Henchman health regen buff
    - Added passive health regen composite buff (_Thanks to Seven_)
    - Added total dodge chance composite buff
    - Added alpha slider for progress bars, allows to adjust their visibility
- CustomHUD:
    - Fixed interaction text display
    - Added Animation for last down number
    - Added support for Kingpin perk deck
    - Added option to truncate most clan tags from the player names (_Thanks to BangL_)
    - Vanilla hud now shows player ranks in front of the name and in white (_Thanks to BangL_)
    - New Option for custom bots color (_Thanks to BangL_)
    - hide stamina-meter, down-counter and detection-meter when a condition icon is shown (_Thanks to BangL_)
    - add option to colorize the condition icon (_Thanks to BangL_)
    - Fixed KillCounter overlap problems on high counts with vanilla HUD (_Thanks to BangL_)
    - Fixed Carry panel overlapping special equipment in Vanilla HUD. (_Thanks to BangL_)
    - Options for interaction time and text for Vanilla HUD (_Thanks to BangL_)
    - Added Detection item for waiting HUD.
    - Added button prompt for approving/denying/kicking waiting players.
    - Fixed Nulled ammo counts in waiting HUD (dispalys base ammo pool, not taking skills/weapon mods into account)
- PreplanningManager:
    - Added buttons to preplanning to safe/load/reset plans
    - Added InputDialog class to give the plans unique names
    - adding "<SKULL>" or "<GHOST>" in the plan name will display a skull or ghost icon next to it.
    - Fixed plans between all branchbanks beeing compatible, art gallery and Framing Frame 1 using the same plans, as well as branchbank and Firestarter 3
    - fixed loading routine, so you can load plans in crimespree as well.
- Interaction:
    - Fixed controller non-bag interaction text
    - Added pagers-only and pagers+lockpick interaction lock modes. (_Thanks to luky92_)
    - Added timer gradient start color (_Thanks to BangL_)
    - Added additional scaling option (_Thanks to BangL_)
    - Added text outline option (_Thanks to BangL_)
    - Press2Hold now works on exit vehicle interaction. (_Thanks to BangL_)
    - Fixed Interaction time problems and instant Interaction (_Thanks to BangL_)
- NumbericSuspicion:
    - Added text outline option. (_Thanks to BangL_)
- TabStats:
    - Fixed Mutators clipping with TabStats
    - Removed StatsisticsManager overwrites, as they got fixed officially
    - Added option for heist time instead of RL time.
    - Added level in crimespree instead of difficulty
    - Fixed money display for crimespree
- DamagePopup:
    - New mode to show popup for everyone, colored by the peer color or the one doing the damage
    - Jokers cause damage popups as well now
- EnemyHealthbar:
    - Hide healthbar on getting arrested.
    - Added decimal marks to health value.
    - capped Health values at a value that can be dispalyed without issues
    - Added support for level specific character names
    - Added Charon and Kazo.
- DrivingHUD:
    - Added decimal marks to health value.
    - capped Health values at a value that can be dispalyed without issues
- WeaponGadgets:
    - Replaced dated laser color code with Seven's new "GADGETS" code. (_Thanks to Seven_)
    - Added support for rotationg weapon for 45 deg red dot sight
    - Fixed BurstFire with the "Little Friend" (_Thanks to Seven_)
    - Added Akimbo flashlight brightness reduction.
	- Added Akimbo Shotgun compatability.
- CustomWaypoints:
    - Added option to colorize default waypoints. (_Thanks to BangL_)
    - new option for skull icon scale (_Thanks to BangL_)
    - new option for skull icon alignment (_Thanks to BangL_)
    - headshots will now be marked with an exclamation mark when using the "all" color option (_Thanks to BangL_)
    - Added loot waypoint options. (Show icon, offset, visible angle, ...) (_Thanks to BangL_)
- EnhancedCrewLoadout:
    - wrote new class to display loadouts
    - replaced briefing loadout with new class (can be disabled in options)
    - Added loadout panel to lobby menu
    - Added skill/perk/ping info to TabScreen
    - Added crew loadout to crimespree lobby
    - Different loadout boxes can be custoimized through Tweak file.
    - removed seperate MeleeItem class, as weapon stock in no longer a special case and got its own icon as well.
- ProfileMenu:
    - Simple list of your profiles, similar to the one for skillsets.
    - includes a little loadout preview.
    - Overwrites Overkills Profile Preview button.
- BuyAllAssets:
    - Complete rewrite of the old script.
    - Due to issues and accidental syncing at times, it is no longer a "fake asset"
    - Instead it became a button above the normal assets on the assets briefing tab.
- EquipmentTweak:
    - Added sharped charge suppression in stealth (_Thanks to BangL_)
    - Applied overkills changes to Sentry ammo sync functions.
- MenuTweaks:
    - Fixed weapon mod tabs using custom inventory names.
    - Added ping in lobby
    - Added additional endgame stats.
    - Added instant restart option.
    - Added auto EXP-Count speedup option
    - Custody and Down timer moved a little, to fix overlap with centered assault banner (_Thanks to BangL_)
    - Fixed Skill tier text overlapping for the first not unlocked tier that gets highlighted
    - Added saving of lobby settings. (_Made by BangL and me_)

---
  
  
### Changelogs of the previous Versions are available [here](http://paydaymods.com/mods/patchnotes/298/).
