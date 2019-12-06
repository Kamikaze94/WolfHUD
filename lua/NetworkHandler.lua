--do return end	-- Disabled cause: WiP
if WolfHUD and not WolfHUD.Sync then
	WolfHUD.Sync = {
		msg_id = "WolfHUD_Sync",
		peers = { false, false, false, false },
		events = {
			discover_wolfhud 		= "Using_WolfHUD?",
			confirm_wolfhud 		= "Using_WolfHUD!",
			peer_disconnect 		= "Leaving_Game",
			locked_assault_status 	= "locked_assault_status",
		},
	}

	local Net = _G.LuaNetworking

	function WolfHUD.Sync.table_to_string(tbl)
		return Net:TableToString(tbl) or ""
	end

	function WolfHUD.Sync.string_to_table(str)
		local tbl = Net:StringToTable(str) or ""

		for k, v in pairs(tbl) do
			tbl[k] = self.to_original_type(v)
		end

		return tbl
	end
	
	function WolfHUD.Sync.to_original_type(s)
		local v = s
		if type(s) == "string" then
			if s == "nil" then
				v = nil
			elseif s == "true" or s == "false" then
				v = (s == "true")
			else
				v = tonumber(s) or s
			end
		end
		return v
	end

	function WolfHUD.Sync:send_to_peer(peer_id, messageType, data)
		if peer_id and peer_id ~= Net:LocalPeerID() and messageType then
			local tags = {
				id = self.msg_id,
				event = messageType
			}

			if type(data) == "table" then
				data = self.table_to_string(data)
				tags["table"] = true
			end

			Net:SendToPeer(peer_id, self.table_to_string(tags), data or "")
		end
	end

	function WolfHUD.Sync:send_to_host(messageType, data)
		self:send_to_peer(managers.network:session():server_peer():id(), messageType, data)
	end

	function WolfHUD.Sync:send_to_all_peers( messageType, data)
		for peer_id, enabled in ipairs(self.peers) do
			self:send_to_peer(peer_id, messageType, data)
		end
	end

	function WolfHUD.Sync:send_to_all_discovered_peers( messageType, data)
		for peer_id, enabled in ipairs(self.peers) do
			if enabled then
				self:send_to_peer(peer_id, messageType, data)
			end
		end
	end

	function WolfHUD.Sync:send_to_all_undiscovered_peers( messageType, data)
		for peer_id, enabled in ipairs(self.peers) do
			if not enabled then
				self:send_to_peer(peer_id, messageType, data)
			end
		end
	end

	function WolfHUD.Sync:receive_message(peer_id, event, data)
		if peer_id and event then
			local events = WolfHUD.Sync.events

			if event == events.discover_wolfhud then
				WolfHUD.Sync:send_to_peer(peer_id, events.confirm_wolfhud)
				WolfHUD.Sync.peers[peer_id] = true
				managers.chat:feed_system_message(ChatManager.GAME, "Client " .. tostring(peer_id) .. " is using WolfHUD ;)")	--TEST
			elseif event == events.confirm_wolfhud then
				WolfHUD.Sync.peers[peer_id] = true
				managers.chat:feed_system_message(ChatManager.GAME, "The Host is using WolfHUD ;)")	--TEST
			elseif event == events.peer_disconnect then
				WolfHUD.Sync.peers[peer_id] = false
			elseif event == events.locked_assault_status then
				managers.hud:_locked_assault(data)
			end
		end
	end

	-- Manage Networking and list of peers to sync to...
	Hooks:Add("NetworkReceivedData", "NetworkReceivedData_WolfHUDSync", function(sender, messageType, data)
		sender = tonumber(sender)
		if sender then
			local tags = WolfHUD.Sync.string_to_table(messageType)
			if WolfHUD.Sync and tags.id and tags.id == WolfHUD.Sync.msg_id and not string.is_nil_or_empty(tags.event) then
				if tags.table then
					data = WolfHUD.Sync.string_to_table(data)
				else
					data = WolfHUD.Sync.to_original_type(data)
				end

				WolfHUD.Sync:receive_message(sender, tags.event, data)
			end
		end
	end)

	Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_WolfHUDSync", function(self, peer, peer_id, reason)
		WolfHUD.Sync:receive_message(peer_id, WolfHUD.Sync.events.peer_disconnect, "")
	end)

	Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadComplete_WolfHUDSync", function(local_peer, id)
		if WolfHUD.Sync and Net:IsMultiplayer() and Network:is_client() then
			WolfHUD.Sync:send_to_host(WolfHUD.Sync.events.discover_wolfhud)
		end
	end)


	-- Data Sync functions:

	function WolfHUD.Sync:endless_assault_status(status)
		if Network:is_server() then
			self:send_to_all_discovered_peers(WolfHUD.Sync.events.locked_assault_status, tostring(status))
		end
	end
end