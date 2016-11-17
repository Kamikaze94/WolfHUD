-- Old version:
--[[
if RequiredScript == "lib/managers/missionassetsmanager" then
	
	local _setup_mission_assets_original = MissionAssetsManager._setup_mission_assets
	local unlock_asset_original = MissionAssetsManager.unlock_asset
	local sync_unlock_asset_original = MissionAssetsManager.sync_unlock_asset
	local get_unlocked_asset_ids_original = MissionAssetsManager.get_unlocked_asset_ids
	local is_unlock_asset_allowed_original = MissionAssetsManager.is_unlock_asset_allowed
	local sync_save_original = MissionAssetsManager.sync_save
	local sync_load_original = MissionAssetsManager.sync_load
	

	function MissionAssetsManager._setup_mission_assets(self, ...)
		_setup_mission_assets_original(self, ...)
		if not self:mission_has_preplanning() then
			self:insert_buy_all_assets_asset()
			self:check_all_assets()
		end
	end
	
	function MissionAssetsManager.sync_unlock_asset(self, ...)
		sync_unlock_asset_original(self, ...)
		if not self:mission_has_preplanning() then
			self:update_buy_all_assets_asset_cost()
			self:check_all_assets()
		end
	end

	function MissionAssetsManager.unlock_asset(self, asset_id)
		if asset_id ~= "buy_all_assets" or not game_state_machine or not self:is_unlock_asset_allowed() then
			return unlock_asset_original(self, asset_id)
		end
		for _, asset in ipairs(self._global.assets) do
			if self:asset_is_buyable(asset) then
				unlock_asset_original(self, asset.id)
			end
		end
		self:check_all_assets()
	end
	
	function MissionAssetsManager:get_unlocked_asset_ids(...)
		local asset_ids = get_unlocked_asset_ids_original(self, ...)
		-- Remove 'Buy all' ID from unlocked table, so its state doesn't get restored after Profile switch.
		if table.contains(asset_ids, "buy_all_assets") then
			for i, id in ipairs(asset_ids) do
				if id == "buy_all_assets" then
					table.remove(asset_ids, i)
					break
				end
			end
		end
		
		return asset_ids
	end
	
	function MissionAssetsManager:is_unlock_asset_allowed(...)
		if game_state_machine then	-- original function can crash, if this doesn't exists (yet?) for some reason...
			return is_unlock_asset_allowed_original(self, ...)
		end
		return false
	end

	function MissionAssetsManager.sync_save(self, data)
		if self:mission_has_preplanning() then
			return sync_save_original(self, data)
		end
		local _global = clone(self._global)
		_global.assets = clone(_global.assets)
		for id, asset in ipairs(_global.assets) do
			if asset.id == "buy_all_assets" then
				_global.assets[id] = self._gage_saved
				self._tweak_data.gage_assignment = self._gage_saved_tweak
				break
			end
		end
		self._tweak_data.buy_all_assets = nil
		data.MissionAssetsManager = _global
	end

	function MissionAssetsManager.sync_load(self, data, ...)
		if not self:mission_has_preplanning() then
			self._global = data.MissionAssetsManager
			self:insert_buy_all_assets_asset()
			self:check_all_assets()
		end
		sync_load_original(self, data, ...)
	end

	function MissionAssetsManager.insert_buy_all_assets_asset(self)
		if self._tweak_data.gage_assignment then
			self._tweak_data.buy_all_assets = clone(self._tweak_data.gage_assignment)
			self._tweak_data.buy_all_assets.name_id = "wolfhud_buy_all_assets"
			self._tweak_data.buy_all_assets.unlock_desc_id = "wolfhud_buy_all_assets_desc"
			self._tweak_data.buy_all_assets.visible_if_locked = true
			self._tweak_data.buy_all_assets.no_mystery = true
			for _, asset in ipairs(self._global.assets) do
				if asset.id == "gage_assignment" then
					self._gage_saved = deep_clone(asset)
					self._gage_saved_tweak = deep_clone(self._tweak_data.gage_assignment)
					self._tweak_data.gage_assignment = nil
					asset.id = "buy_all_assets"
					asset.unlocked = false
					asset.can_unlock = true
					asset.no_mystery = true
					break
				end
			end
		end
			table.sort(self._global.assets, function(a, b)
				if a.id == "buy_all_assets" then
					return true
				elseif a.local_only ~= b.local_only then
					return a.local_only
				elseif a.show ~= b.show then
					return a.show
				elseif a.unlocked ~= b.unlocked then
					return a.unlocked
				elseif a.can_unlock ~= b.can_unlock then
					return a.can_unlock
				elseif a.no_mystery ~= b.no_mystery then
					return a.no_mystery
				else
					local money_lock_a = a.id and self._tweak_data[a.id].money_lock or 0
					local money_lock_b = b.id and self._tweak_data[b.id].money_lock or 0
					if money_lock_a and money_lock_b then
						return money_lock_a < money_lock_b
					end
				end
				return false
			end)
		self:update_buy_all_assets_asset_cost()
		self:check_all_assets()
	end

	function MissionAssetsManager.update_buy_all_assets_asset_cost(self)
		if not self:mission_has_preplanning() and self._tweak_data.buy_all_assets then
			self._tweak_data.buy_all_assets.money_lock = 0
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					self._tweak_data.buy_all_assets.money_lock = self._tweak_data.buy_all_assets.money_lock + (self._tweak_data[asset.id].money_lock or 0)
				end
			end
		end
	end

	function MissionAssetsManager.check_all_assets(self)
		if game_state_machine then
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					return
				end
			end
			if not self._all_assets_bought then
				self._tweak_data.buy_all_assets.money_lock = 0
				self._all_assets_bought = true
				unlock_asset_original(self, "buy_all_assets")
			end
		end
	end
	
	function MissionAssetsManager:mission_has_preplanning()
		if not self._has_locked_asset then
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					self._has_locked_asset = true
					break
				end
			end
		end
		return tweak_data.preplanning.locations[Global.game_settings and Global.game_settings.level_id] ~= nil and not self._has_locked_asset
	end

	function MissionAssetsManager:asset_is_buyable(asset)
		return asset.id ~= "buy_all_assets" and asset.show and not asset.unlocked and ((Network:is_server() and asset.can_unlock) or (Network:is_client() and self:get_asset_can_unlock_by_id(asset.id)))
	end
end
--]]

-- New Script:

if RequiredScript == "lib/managers/missionassetsmanager" then
	
	local _setup_mission_assets_original = MissionAssetsManager._setup_mission_assets
	local sync_unlock_asset_original = MissionAssetsManager.sync_unlock_asset
	local unlock_asset_original = MissionAssetsManager.unlock_asset
	local get_unlocked_asset_ids_original = MissionAssetsManager.get_unlocked_asset_ids
	local is_unlock_asset_allowed_original = MissionAssetsManager.is_unlock_asset_allowed
	local sync_save_original = MissionAssetsManager.sync_save
	local sync_load_original = MissionAssetsManager.sync_load
	
	function MissionAssetsManager:_setup_mission_assets(...)
		local is_host = Network:is_server() or Global.game_settings.single_player
		local insert_buy_all = is_host and self:mission_has_assets()
		if not insert_buy_all then
			self:remove_buy_all()
			self:remove_buy_all_tweak()
		end
		
		_setup_mission_assets_original(self, ...)
		
		if insert_buy_all then
			self:create_buy_all_asset()
			self:update_buy_all_asset_cost()
		end
	end
	
	function MissionAssetsManager:sync_unlock_asset(...)
		sync_unlock_asset_original(self, ...)
		if self:mission_has_assets() then
			self:update_buy_all_asset_cost()
		end
	end

	function MissionAssetsManager:unlock_asset(asset_id, ...)
		if asset_id == "wolfhud_buy_all_assets" and self:is_unlock_asset_allowed() then
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					unlock_asset_original(self, asset.id)
				end
			end
			if not self:check_all_assets_bought(true) then
				self:update_buy_all_asset_cost()
			end
		else
			unlock_asset_original(self, asset_id, ...)
			self:update_buy_all_asset_cost()
		end
	end
	
	function MissionAssetsManager:get_unlocked_asset_ids(...)
		local asset_ids = get_unlocked_asset_ids_original(self, ...)
		-- Remove 'Buy all' ID from unlocked table, so its state doesn't get restored after Profile switch.
		if table.contains(asset_ids, "wolfhud_buy_all_assets") then
			for i, id in ipairs(asset_ids) do
				if id == "wolfhud_buy_all_assets" then
					table.remove(asset_ids, i)
					break
				end
			end
		end
		
		return asset_ids
	end
	
	function MissionAssetsManager:is_unlock_asset_allowed(...)
		if game_state_machine then	-- original function can crash, if this doesn't exists (yet?) for some reason...
			return is_unlock_asset_allowed_original(self, ...)
		end
		return false
	end
	
	function MissionAssetsManager:sync_save(...)
		-- If we do not remove the buy all here it will be sent to clients and they may not know how to handle it.
		self:remove_buy_all()
		
		sync_save_original(self, ...)
	end
	
	function MissionAssetsManager:sync_load(data, ...)
		--local has_assets = self:mission_has_assets()
		if self:mission_has_assets() then
			self._global = data.MissionAssetsManager
			self:create_buy_all_asset()
			self:update_buy_all_asset_cost()
		else
--			self:remove_buy_all(data.MissionAssetsManager.assets)
			self:remove_buy_all_tweak()
		end
		
		sync_load_original(self, data, ...)
		
		if self:mission_has_assets() then
--			if not self:_get_asset_by_id("wolfhud_buy_all_assets") then
--				self:create_buy_all_asset()
--				self:update_buy_all_asset_cost()
--			end
			self:check_all_assets_bought()
		end
	end

	-- Custom functions
	
	function MissionAssetsManager:create_buy_all_asset(insert_table)
		insert_table = insert_table or self._global.assets
		local asset_id = "wolfhud_buy_all_assets"
		local asset_tweak = self._tweak_data[asset_id]
		
		local asset = self:_get_asset_by_id(asset_id)

		if asset then
			table.sort(insert_table, function(a, b)
				if not a then
					return true
				elseif not b then
					return false
				else
					if a.id == asset_id then
						return true
					elseif a.local_only ~= b.local_only then
						return a.local_only
					elseif a.show ~= b.show then
						return a.show
					elseif a.unlocked ~= b.unlocked then
						return a.unlocked
					elseif a.can_unlock ~= b.can_unlock then
						return a.can_unlock
					elseif a.no_mystery ~= b.no_mystery then
						return a.no_mystery
					else
						local money_lock_a = a.id and self._tweak_data[a.id].money_lock or 0
						local money_lock_b = b.id and self._tweak_data[b.id].money_lock or 0
						if money_lock_a and money_lock_b then
							return money_lock_a < money_lock_b
						end
					end
				end
				return false
			end)
		elseif asset_tweak then
			self:remove_buy_all(insert_table)
			
			asset = {
				id = asset_id,
				unlocked = self:check_all_assets_bought(nil),
				can_unlock = true,
				show = asset_tweak.visible_if_locked,
				no_mystery = asset_tweak.no_mystery,
				local_only = asset_tweak.local_only
			}
			
			table.insert(insert_table, 1, asset)
		end
	end
	
	function MissionAssetsManager:remove_buy_all(remove_table)
		remove_table = remove_table or self._global.assets
		local asset_id = "wolfhud_buy_all_assets"
		
		for i, asset in ipairs(remove_table) do
			if asset_id == asset.id then
				table.remove(remove_table, i)
			end
		end
	end
	
	function MissionAssetsManager:remove_buy_all_tweak()
		self._tweak_data.wolfhud_buy_all_assets = nil
	end

	function MissionAssetsManager:update_buy_all_asset_cost()
		if self._tweak_data.wolfhud_buy_all_assets then
			local value = 0
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					local asset_tweak = asset.id and self._tweak_data[asset.id]
					value = value + (asset_tweak and asset_tweak.money_lock or 0)
				end
			end
			
			self._tweak_data.wolfhud_buy_all_assets.money_lock = value
			return self:check_all_assets_bought(true)
		end
	end

	function MissionAssetsManager:check_all_assets_bought(auto_unlock)
		if game_state_machine then
			for _, asset in ipairs(self._global.assets) do
				if self:asset_is_buyable(asset) then
					return false
				end
			end
			
			if auto_unlock then
				self:unlock_buy_all_asset()
			end
			
			return true
		end
	end
	
	function MissionAssetsManager:unlock_buy_all_asset()
		local asset = self:_get_asset_by_id("wolfhud_buy_all_assets")
		if asset and not asset.unlocked and self._tweak_data.wolfhud_buy_all_assets then
			self._tweak_data.wolfhud_buy_all_assets.money_lock = 0
			sync_unlock_asset_original(self, "wolfhud_buy_all_assets")
		end
	end
	
	function MissionAssetsManager:mission_has_assets()
		if self._tweak_data.wolfhud_buy_all_assets then
			local current_stage = managers.job:current_level_id() or ""
			local stages = self._tweak_data.wolfhud_buy_all_assets.stages
			local exclude_stages = self._tweak_data.wolfhud_buy_all_assets.exclude_stages
			if type(stages) == "table" and table.contains(stages, current_stage) or stages == "all" and not (exclude_stages and table.contains(exclude_stages, current_stage)) then
				local preplanning_with_assets = self._tweak_data.wolfhud_buy_all_assets.preplanning_with_assets
				return not (tweak_data.preplanning and tweak_data.preplanning.locations and tweak_data.preplanning.locations[current_stage]) or table.contains(preplanning_with_assets, current_stage)
			end
		end
		return false
	end

	function MissionAssetsManager:asset_is_buyable(asset)
		return asset.id ~= "wolfhud_buy_all_assets" and asset.show and not asset.unlocked and (Network:is_server() and asset.can_unlock or Network:is_client() and self:get_asset_can_unlock_by_id(asset.id))
	end
elseif string.lower(RequiredScript) == "lib/tweak_data/assetstweakdata" then
	local _init_original = AssetsTweakData.init
	function AssetsTweakData:init(...)
		_init_original(self, ...)
		
		self.wolfhud_buy_all_assets = self.wolfhud_buy_all_assets or {
			name_id = "wolfhud_buy_all_assets",
			unlock_desc_id = "wolfhud_buy_all_assets_desc",
			texture = "guis/textures/pd2/feature_crimenet_heat",
			money_lock = 0,
			visible_if_locked = true,
			no_mystery = true,
			local_only = false,
			stages = "all",
			exclude_stages = {
				"safehouse",
				"alex_2",
				"escape_cafe",
				"escape_park",
				"escape_cafe_day",
				"escape_park_day",
				"escape_street",
				"escape_overpass",
				"escape_garage",
				"haunted",
				"hox_1",
				"hox_2",
				"pines",
				"crojob1",
				"short1_stage1",
				"short1_stage2",
				"short2_stage1",
				"short2_stage2b",
				"chill",
				"chill_combat",
			},
			preplanning_with_assets = {
				"firestarter_3",
			},
		}
	end
end