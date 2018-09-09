if RequiredScript == "lib/managers/platformmanager" then
	core:module("PlatformManager")

	local set_rich_presence_original = WinPlatformManager.set_rich_presence
	function WinPlatformManager:set_rich_presence(name, ...)
		set_rich_presence_original(self, name or self._current_rich_presence, ...)
		
		if SystemInfo:distribution() == Idstring("STEAM") then
			-- Default config
			local display = "#DisplayMe"
			local group_key = ""
			local group_count = ""

			local game_state = "menu"
			local game_mode = ""
			local game_heist = ""
			local game_heistday = ""
			local game_difficulty = ""

			if self._current_rich_presence ~= "Idle" then
				if Global.game_settings.permission == "private" then
					game_state = "private"
				else
					-- Handle Steam RP Grouping
					group_key = tostring(Steam:userid())
					group_count = "1"
					if not Global.game_settings.single_player then
						local session = managers.network:session()
						if not Network:is_server() then
							local peer = session and session:server_peer()
							group_key = tostring(peer and peer:user_id() or group_key)
						end
						group_count = tostring(session and #session:all_peers() or 1)
					end

					-- Determine game state
					if _G.game_state_machine and (_G.game_state_machine:current_state_name() == "menu_main" or _G.game_state_machine:current_state_name() == "ingame_lobby_menu") then
						game_state = "lobby"
					elseif self._current_rich_presence == "SPEnd" or self._current_rich_presence == "MPEnd" then
						game_state = "payday"
					else
						game_state = "playing"
					end

					-- Popululate gamemode, heist and difficulty
					if managers.crime_spree and managers.crime_spree:is_active() then		-- Crime Spree
						game_mode = "crime_spree"
						game_heist = self:get_current_level_name()
						game_difficulty = managers.experience:cash_string(managers.crime_spree:server_spree_level())
					elseif managers.skirmish and managers.skirmish:is_skirmish() then		-- Holdout
						game_mode = "skirmish"
						game_heist = self:get_current_level_name()
						game_difficulty = string.format("%i/%i", managers.skirmish:current_wave_number(), tweak_data and #tweak_data.skirmish.ransom_amounts or 9)
					elseif managers.job:has_active_job() then								-- Heists
						game_heist = self:get_current_job_name()

						if #(managers.job:current_job_chain_data() or {}) > 1 then
							game_mode = "heist_chain"
							game_heistday = tostring(managers.job:current_stage() or "")
						else
							game_mode = "heist"
						end

						local difficulty_stars = managers.job:current_difficulty_stars()
						game_difficulty = tweak_data and tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or "normal"
					else
						-- Overwrite game state if nothing is selected
						game_state = "lobby_no_job"
					end
				end
			end
			
			-- Send our data to Steam
			Steam:set_rich_presence("steam_display", display)		-- Currently not usable, only Overkill can setup required localized strings here...
			Steam:set_rich_presence("steam_player_group", group_key)
			Steam:set_rich_presence("steam_player_group_size", group_count)

			Steam:set_rich_presence("game:state", game_state)
			Steam:set_rich_presence("game:mode", game_mode)
			Steam:set_rich_presence("game:heist", game_heist)
			Steam:set_rich_presence("game:heist_day", game_heistday)
			Steam:set_rich_presence("game:difficulty", game_difficulty)
		end
	end

	function WinPlatformManager:get_current_job_name()
		local job_data = managers.job:current_job_data()
		return job_data and managers.localization:text(job_data.name_id) or "no heist"
	end

	function WinPlatformManager:get_current_level_name()
		local level_name
		local level_id = Global.game_settings.level_id
		local name_id = level_id and tweak_data and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id

		if name_id then
			level_name = managers.localization:text(name_id)
		end
		
		return level_name or self:get_current_job_name()
	end
elseif RequiredScript == "lib/managers/skirmishmanager" then
	local update_matchmake_attributes_original = SkirmishManager.update_matchmake_attributes
	function SkirmishManager:update_matchmake_attributes(...)
		update_matchmake_attributes_original(self, ...)
		
		local game_difficulty = string.format("%i/%i", self:current_wave_number(), tweak_data and #tweak_data.skirmish.ransom_amounts or 9)
		Steam:set_rich_presence("game:difficulty", game_difficulty)
	end
end

if Hooks then	-- Basegame doesn't update RP on peer count changes...
	Hooks:Add("BaseNetworkSessionOnPeerEnteredLobby", "BaseNetworkSessionOnPeerEnteredLobby_RichPresencePP", function(session, peer, peer_id)
		local session = managers.network:session()
		if session then
			local group_count = tostring(session and #session:all_peers() or 1)
			Steam:set_rich_presence("steam_player_group_size", group_count)
		end
	end)
	
	Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_RichPresencePP", function(session, peer, peer_id, reason)
		local session = managers.network:session()
		if session then
			local group_count = tostring(session and #session:all_peers() or 1)
			Steam:set_rich_presence("steam_player_group_size", group_count)
		end
	end)
end

--[[ Example of localized strings:	(Heist names could be send as job-/level-ids to steam and get localized similar to difficulties)

"lang"{
	"english"{
		"tokens"{
			"#DisplayMe"				"{#State_%game:state%}"

			"#State_menu"				"At the main menu"
			"#State_private"			"In a private lobby"
			"#State_lobby_no_job"		"In a lobby"
			"#State_lobby"				"Lobby: {#Mode_%game:mode%}"
			"#State_playing"			"Playing:  {#Mode_%game:mode%}"
			"#State_payday"				"Payday:  {#Mode_%game:mode%}"

			"#Mode_crime_spree"			"[CS] %game:heist% (Lvl. %game:difficulty%)"
			"#Mode_skirmish"			"[HO] %game:heist% (Wave %game:difficulty%)"
			"#Mode_heist"				"%game:heist% ({#Difficulty_%game:difficulty%})"
			"#Mode_heist_chain"			"%game:heist%, Day %game:heist_day% ({#Difficulty_%game:difficulty%})"

			"#Difficulty_easy"			"EASY"
			"#Difficulty_normal"		"NORMAL"
			"#Difficulty_hard"			"HARD"
			"#Difficulty_overkill"		"VERY HARD"
			"#Difficulty_overkill_145"	"OVERKILL"
			"#Difficulty_easy_wish"		"MAYHAM"
			"#Difficulty_overkill_290"	"DEATHWISH"
			"#Difficulty_sm_wish"		"DEATH SENTENCE"
		}
	}
}

]]