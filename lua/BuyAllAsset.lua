if RequiredScript == "lib/managers/missionassetsmanager" then

	local _setup_mission_assets_original = MissionAssetsManager._setup_mission_assets
	local sync_unlock_asset_original = MissionAssetsManager.sync_unlock_asset
	local unlock_asset_original = MissionAssetsManager.unlock_asset
	local get_unlocked_asset_ids_original = MissionAssetsManager.get_unlocked_asset_ids
	local is_unlock_asset_allowed_original = MissionAssetsManager.is_unlock_asset_allowed
	local sync_save_original = MissionAssetsManager.sync_save
	local sync_load_original = MissionAssetsManager.sync_load

	function MissionAssetsManager:_setup_mission_assets(...)
		_setup_mission_assets_original(self, ...)

		if self:mission_has_assets() then
			self:create_buy_all_asset()
			self:update_buy_all_asset_cost()
		else
			self:remove_buy_all_asset()
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

	function MissionAssetsManager:sync_save(data, ...)
		-- If we do not remove the buy all here it will be sent to clients and they may not know how to handle it.
		self:remove_buy_all_asset()

		sync_save_original(self, data, ...)

		--self:remove_buy_all_asset(data.MissionAssetsManager.assets)
	end

	function MissionAssetsManager:sync_load(data, ...)
		sync_load_original(self, data, ...)

		if self:mission_has_assets() then
			self:create_buy_all_asset()

			self:create_asset_textures()

			self:update_buy_all_asset_cost()
			self:check_all_assets_bought(true)
		end
	end

	-- Custom functions

	function MissionAssetsManager:create_buy_all_asset(insert_table)
		insert_table = insert_table or self._global.assets
		local asset_id = "wolfhud_buy_all_assets"
		local asset_tweak = self._tweak_data[asset_id]

		local asset = self:_get_asset_by_id(asset_id)

		if not asset then
			for i, data in ipairs(insert_table) do
				if data.id == asset_id then
					asset = data
					break
				end
			end
		end

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
						local money_lock_a = a.id and self._tweak_data[a.id].money_lock
						local money_lock_b = b.id and self._tweak_data[b.id].money_lock
						if money_lock_a and money_lock_b then
							return money_lock_a < money_lock_b
						else
							return money_lock_a and true or false
						end
					end
				end
				return false
			end)
		elseif asset_tweak then
			self:remove_buy_all_asset(insert_table)

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

	function MissionAssetsManager:remove_buy_all_asset(remove_table)
		remove_table = remove_table or self._global.assets
		local asset_id = "wolfhud_buy_all_assets"

		for i, asset in ipairs(remove_table) do
			if asset_id == asset.id then
				table.remove(remove_table, i)
				break
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
			--unlock_asset_original(self, "wolfhud_buy_all_assets")
		end
	end

	function MissionAssetsManager:mission_has_assets()
		if self._tweak_data.wolfhud_buy_all_assets then
			local current_stage = managers.job:current_level_id() or ""
			local stages = self._tweak_data.wolfhud_buy_all_assets.stages or "all"
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