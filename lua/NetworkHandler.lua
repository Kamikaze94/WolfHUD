do return end	-- Disabled cause: WiP
WolfHUD.Sync = WolfHUD.Sync or {}
WolfHUD.Sync.peers = WolfHUD.Sync.peers or {}
WolfHUD.Sync.cache = WolfHUD.Sync.cache or {}

-- Functions to send stuff
function WolfHUD.Sync.send(id, data)
	if WolfHUD.Sync.peers and data then
		managers.chat:feed_system_message(ChatManager.GAME, string.format("[%s] Syncing event %s.", id, data.event or "N/A"))	--TEST
		local send_data = json.encode(data)
		for peer_id, enabled in pairs(WolfHUD.Sync.peers) do
			if enabled then
				LuaNetworking:SendToPeer(peer_id, id, send_data)
			end
		end
	end
	if id == "WolfHUD_Sync_Cache" then
		WolfHUD.Sync.receive_cache_event(data)
	end
end

function WolfHUD.Sync.gameinfo_ecm_event_sender(event, key, data)
	if WolfHUD.Sync then
		local send_data = {
			source = "ecm",
			event = event,
			key = key,
			data = {feedback_duration = data.feedback_duration, feedback_expire_t = data.feedback_expire_t}
		}
		WolfHUD.Sync.send("WolfHUD_Sync_GameInfo", send_data)
	end
end


--receive and apply data
function WolfHUD.Sync.receive_gameinfo_event(event_data)
	local source = data.source
	local event = event_data.event
	local key = event_data.key
	local data = event_data.data
	managers.chat:feed_system_message(ChatManager.GAME, string.format("[WolfHUD_GameInfo] Received data, source: %s, event: %s.", source or "N/A", event or "N/A"))	--TEST
	if managers.gameinfo and source and key and data then
		managers.gameinfo:event(source, event, key, data)
	end
end

function WolfHUD.Sync.receive_cache_event(event_data)
	local event = event_data.event
	local data = event_data.data
	managers.chat:feed_system_message(ChatManager.GAME, string.format("[WolfHUD_Cache] Received data, event: %s.", event or "N/A"))	--TEST
	if WolfHUD.Sync.cache and event and data then
		WolfHUD.Sync.cache[event] = data
	end
end

function WolfHUD.Sync.receive(event_data)
	local event = event_data.event
	local data = event_data.data
	managers.chat:feed_system_message(ChatManager.GAME, string.format("[WolfHUD] Received data, event: %s.", event or "N/A"))	--TEST
	if event == "assault_lock_state" then
		if managers.hud and managers.hud._locked_assault and event and data then
			managers.hud:_locked_assault(data)
		end
	end
end

function WolfHUD.Sync:getCache(id)
	if self.cache[id] then
		return self.cache[id]
	else
		return self.cache
	end
end


-- Manage Networking and list of peers to sync to...
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_WolfHUD", function(sender, messageType, data)
	if WolfHUD.Sync then
		if peer then
			if messageType == "Using_WolfHUD?" then
				LuaNetworking:SendToPeer(sender, "Using_WolfHUD!", "")
				WolfHUD.Sync.peers[sender] = true		--Sync to peer, IDs of other peers using WolfHUD?
				managers.chat:feed_system_message(ChatManager.GAME, "Host is using WolfHUD ;)")	--TEST
			elseif messageType == "Using_WolfHUD!" then
				WolfHUD.Sync.peers[sender] = true		--Sync other peers, that new peer is using WolfHUD?
				managers.chat:feed_system_message(ChatManager.GAME, "A Client is using WolfHUD ;)")	--TEST
			else
				local receive_data = json.decode(data)
				if messageType == "WolfHUD_Sync_GameInfo" then		-- receive and call gameinfo event
					managers.chat:feed_system_message(ChatManager.GAME, "Sync GameInfo event received!")	--TEST
					log("GameInfo event received!")
					WolfHUD.Sync.receive_gameinfo_event(receive_data)
				elseif messageType == "WolfHUD_Sync_Cache" then			-- Add data to cache
					managers.chat:feed_system_message(ChatManager.GAME, "Sync Cache event received!")	--TEST
					log("Sync Cache event received!")
					WolfHUD.Sync.receive_cache_event(receive_data)
				elseif messageType == "WolfHUD_Sync" then				-- Receive data that needs to be handled by data.event
					managers.chat:feed_system_message(ChatManager.GAME, "Sync event received!")	--TEST
					log("Sync event received!")
					WolfHUD.Sync.receive(receive_data)
				end
			end
		end
	end
end)

Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_WolfHUD", function(self, peer, peer_id, reason)
	if WolfHUD.Sync and WolfHUD.Sync.peers[peer_id] then
		WolfHUD.Sync.peers[peer_id] = nil
	end
end)

Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadComplete_WolfHUD", function(local_peer, id)
	if WolfHUD.Sync then
		if Network:is_client() then
			LuaNetworking:SendToPeer(managers.network:session():server_peer():id(), "Using_WolfHUD?", "")
		else
			if managers.gameinfo then
				managers.gameinfo:register_listener("ecm_feedback_duration_listener", "ecm", "set_feedback_duration", callback(nil, WolfHUD.Sync, "gameinfo_ecm_event_sender"))
			end
		end
	end
end)
