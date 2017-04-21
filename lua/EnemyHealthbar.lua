if string.lower(RequiredScript) == "lib/managers/hudmanager" then
	HUDManager.CharacterData = {
		[ "civilian" ] 						= { default = "wolfhud_enemy_civilian" },
		[ "civilian_female" ] 				= { default = "wolfhud_enemy_civilian" },
		[ "gangster" ] 						= { default = "wolfhud_enemy_gangster" },
		[ "biker" ] 						= { default = "wolfhud_enemy_biker" },
		[ "biker_escape" ] 					= { default = "wolfhud_enemy_biker" },
		[ "bolivian_indoors" ]				= { default = "wolfhud_enemy_bolivian_security" },
		[ "bolivian" ]						= { default = "wolfhud_enemy_bolivian_thug" },
		[ "mobster" ] 						= { default = "wolfhud_enemy_mobster" },
		[ "security" ] 						= { default = "wolfhud_enemy_security" },
		[ "security_undominatable" ] 		= { default = "wolfhud_enemy_security" },
		[ "gensec" ] 						= { default = "wolfhud_enemy_gensec" },
		[ "cop" ] 							= { default = "wolfhud_enemy_cop" },
		[ "cop_female" ]					= { default = "wolfhud_enemy_cop" },
		[ "cop_scared" ]					= { default = "wolfhud_enemy_cop" },
		[ "fbi" ] 							= { default = "wolfhud_enemy_fbi" },
		[ "swat" ] 							= { default = "wolfhud_enemy_swat" },
		[ "heavy_swat" ] 					= { default = "wolfhud_enemy_heavy_swat" },
		[ "fbi_swat" ] 						= { default = "wolfhud_enemy_swat" },
		[ "fbi_heavy_swat" ] 				= { default = "wolfhud_enemy_heavy_swat" },
		[ "city_swat" ] 					= { default = "wolfhud_enemy_city_swat" },
		[ "shield" ] 						= { default = "wolfhud_enemy_shield" },
		[ "spooc" ] 						= { default = "wolfhud_enemy_spook" },
		[ "taser" ] 						= { default = "wolfhud_enemy_taser" },
		[ "sniper" ] 						= { default = "wolfhud_enemy_sniper" },
		[ "medic" ]							= { default = "wolfhud_enemy_medic" },
		[ "tank" ] 							= { default = "wolfhud_enemy_tank" },
		[ "tank_hw" ]						= { default = "wolfhud_enemy_tank_hw" },
		[ "phalanx_minion" ] 				= { default = "wolfhud_enemy_phalanx_minion" },
		[ "phalanx_vip" ] 					= { default = "wolfhud_enemy_phalanx_vip" },
		[ "swat_van_turret_module" ] 		= { default = "wolfhud_enemy_swat_van" },
		[ "ceiling_turret_module" ] 		= { default = "wolfhud_enemy_ceiling_turret" },
		[ "ceiling_turret_module_no_idle" ] = { default = "wolfhud_enemy_ceiling_turret" },
		[ "sentry_gun" ]					= { default = "wolfhud_enemy_sentry_gun" },
		[ "mobster_boss" ] 					= { default = "wolfhud_enemy_mobster_boss" },
		[ "chavez_boss" ]					= { default = "wolfhud_enemy_chavez_boss" },
		[ "drug_lord_boss" ]				= { default = "wolfhud_enemy_druglord_boss" },
		[ "drug_lord_boss_stealth" ]		= { default = "wolfhud_enemy_druglord_boss_stealth" },
		[ "biker_boss" ] 					= { default = "wolfhud_enemy_biker_boss" },
		[ "bank_manager" ] 					= { default = "wolfhud_enemy_bank_manager" },
		[ "inside_man" ] 					= { default = "wolfhud_enemy_inside_man" },
		[ "escort_undercover" ] 			= { default = "wolfhud_enemy_escort_undercover", run = "wolfhud_enemy_escort_heatstreet" },
		[ "escort_chinese_prisoner" ]		= { default = "wolfhud_enemy_escort_chinese_prisoner" },
		[ "drunk_pilot" ] 					= { default = "wolfhud_enemy_drunk_pilot" },
		[ "escort" ] 						= { default = "wolfhud_enemy_escort" },
		[ "boris" ]							= { default = "wolfhud_enemy_boris" },
		[ "spa_vip" ]						= { default = "wolfhud_enemy_spa_vip" },
		[ "spa_vip_hurt" ]					= { default = "wolfhud_enemy_spa_vip_hurt" },
		[ "old_hoxton_mission" ] 			= { default = "wolfhud_enemy_locke_mission", hox_1 = "wolfhud_enemy_old_hoxton_mission", hox_2 = "wolfhud_enemy_old_hoxton_mission" },
		[ "hector_boss" ] 					= { default = "wolfhud_enemy_hector_boss" },
		[ "hector_boss_no_armor" ] 			= { default = "wolfhud_enemy_hector_boss_no_armor" },
		[ "robbers_safehouse" ]				= { default = "wolfhud_enemy_crew" },
		[ "butler" ]						= { default = "wolfhud_enemy_butler" },
		[ "vlad" ]							= { default = "wolfhud_enemy_vlad" },
		[ "russian" ] 						= { default = "menu_russian" },
		[ "german" ] 						= { default = "menu_german" },
		[ "spanish" ] 						= { default = "menu_spanish" },
		[ "american" ] 						= { default = "menu_american" },
		[ "jowi" ] 							= { default = "menu_jowi" },
		[ "old_hoxton" ] 					= { default = "menu_old_hoxton" },
		[ "female_1" ] 						= { default = "menu_female_1" },
		[ "clover" ] 						= { default = "menu_female_1" },
		[ "dragan" ] 						= { default = "menu_dragan" },
		[ "jacket" ] 						= { default = "menu_jacket" },
		[ "bonnie" ] 						= { default = "menu_bonnie" },
		[ "sokol" ] 						= { default = "menu_sokol" },
		[ "dragon" ] 						= { default = "menu_dragon" },
		[ "bodhi" ] 						= { default = "menu_bodhi" },
		[ "jimmy" ] 						= { default = "menu_jimmy" },
		[ "sydney" ] 						= { default = "menu_sydney" },
		[ "wild" ]							= { default = "menu_wild" },
		[ "chico" ]							= { default = "menu_chico" },
		[ "terry" ]							= { default = "menu_chico" },
	}

	Hooks:PostHook( HUDManager , "_player_hud_layout" , "WolfHUDPostHUDManagerPlayerInfoHUDLayout" , function( self )
		self._health_text_rect = { 2 , 18 , 232 , 11 } --Green Bar
		self._shield_text_rect = { 2 , 34 , 232 , 11 } --Blue Bar
		self._bar_text_rect = self._health_text_rect
		self._shield = false

		local unit_health_main = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:panel({
			name 	= "unit_health_main",
			halign 	= "grow",
			valign 	= "grow"
		})

		self._unit_health_panel = unit_health_main:panel({
			name 	= "unit_health_panel",
			visible = false
		})

		self._unit_bar = self._unit_health_panel:bitmap({
			name 			= "unit_health",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 2, 18, 232,	11 },
			blend_mode 		= "normal"
		})

		self._unit_bar_bg = self._unit_health_panel:bitmap({
			name 			= "unit_shield",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 1, 1, 234, 13 },
			blend_mode 		= "normal"
		})

		self._unit_health_text = self._unit_health_panel:text({
			name 		= "unit_health_text",
			text 		= "250000/250000",
			blend_mode 	= "normal",
			alpha 		= 1,
			halign 		= "right",
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 20,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})

		self._unit_health_enemy_text = self._unit_health_panel:text({
			name 		= "unit_health_enemy_text",
			text 		= "SWAT VAN TURRET",
			blend_mode 	= "normal",
			alpha 		= 1,
			halign 		= "left",
			font 		= "fonts/font_medium_mf",
			font_size 	= 22,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})

		self._unit_health_enemy_location = self._unit_health_panel:text({
			name 		= "unit_health_enemy_location",
			text 		= "^",
			blend_mode 	= "normal",
			visible 	= WolfHUD:getSetting({"EnemyHealthbar", "SHOW_POINTER"}, false),
			alpha 		= 0.75,
			halign 		= "center",
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 20,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})

		local _ ,_ ,hw ,hh = self._unit_health_text:text_rect()
		local _ ,_ ,ew ,eh = self._unit_health_enemy_text:text_rect()
		local _ ,_ ,lw ,lh = self._unit_health_enemy_location:text_rect()

		self._unit_health_text:set_size( hw , hh )
		self._unit_health_enemy_text:set_size( ew , eh )
		self._unit_health_enemy_location:set_size( lw , lh )

		self._unit_bar:set_w( self._unit_bar:w() - 2 )

		self._unit_bar:set_center( self._unit_health_panel:center_x() , self._unit_health_panel:center_y() - 190 )
		self._unit_bar_bg:set_center( self._unit_health_panel:center_x() , self._unit_health_panel:center_y() - 190 )

		self._unit_health_text:set_right( self._unit_bar_bg:right() )
		self._unit_health_text:set_bottom( self._unit_bar_bg:top() )

		self._unit_health_enemy_text:set_left( self._unit_bar_bg:left() )
		self._unit_health_enemy_text:set_bottom( self._unit_bar_bg:top() )

		self._unit_health_enemy_location:set_center_x( self._unit_bar_bg:center_x() )
		self._unit_health_enemy_location:set_top( self._unit_bar_bg:bottom() )

	end )

	function HUDManager:set_unit_health_visible( visible, shield )
		if visible and self._shield ~= shield then
			self._shield = shield or false
			self._bar_text_rect = self._shield and self._shield_text_rect or self._health_text_rect
		end

		if visible == true and not self._unit_health_visible and WolfHUD:getSetting({"EnemyHealthbar", "ENABLED"}, true) then

			self._unit_health_visible = true
			self._unit_health_enemy_location:set_visible(WolfHUD:getSetting({"EnemyHealthbar", "SHOW_POINTER"}, false))
			self._unit_health_panel:stop()
			self._unit_health_panel:animate( function( p )
				self._unit_health_panel:set_visible( true )

				over( 0.25 , function( o )
					self._unit_health_panel:set_alpha( math.lerp( self._unit_health_panel:alpha() , 1 , o ) )
				end )
			end )

		elseif visible == false and self._unit_health_visible then

			self._unit_health_visible = nil
			self._unit_health_panel:stop()

			self._unit_health_panel:animate( function( p )
				if self._unit_health_panel:alpha() >= 0.9 then
					over( 0.5 , function( o ) end )
				end

				over( 1.5 , function( o )
					self._unit_health_panel:set_alpha( math.lerp( self._unit_health_panel:alpha() , 0 , o ) )
				end )

				self._unit_health_panel:set_visible( false )
			end )
		end
	end

	function HUDManager:set_unit_health( current , total , tweak_table )

		if not current or not total then return end

		local enemy 
		local NameTable = self.CharacterData[ tweak_table ]
		if NameTable then
			local level_id = managers.job:current_level_id()
			enemy = managers.localization:to_upper_text(NameTable[level_id] or NameTable.default)
		else
			enemy = tweak_table or "UNKNOWN"
		end

		total = math.min(total, 999999999)
		current = math.clamp(current, 0, total)
		local _r = current / total

		local r = self._unit_bar:width()
		local rn = ( self._unit_bar_bg:w() - 4 ) * _r

		self._unit_health_enemy_text:set_text( enemy )
		if total > 0 then
			self._unit_health_text:set_text( string.format( "%s/%s" , managers.money:add_decimal_marks_to_string(tostring(current)) , managers.money:add_decimal_marks_to_string(tostring(total)) ) )
		else
			self._unit_health_text:set_text( string.format( "%s" , managers.money:add_decimal_marks_to_string(tostring(current)) ) )
		end

		local _ ,_ ,hw ,hh = self._unit_health_text:text_rect()
		local _ ,_ ,ew ,eh = self._unit_health_enemy_text:text_rect()

		self._unit_health_text:set_size( hw , hh )
		self._unit_health_enemy_text:set_size( ew , eh )

		self._unit_health_text:set_right( self._unit_bar_bg:right() )
		self._unit_health_text:set_bottom( self._unit_bar_bg:top() )
		self._unit_health_enemy_text:set_left( self._unit_bar_bg:left() )
		self._unit_health_enemy_text:set_bottom( self._unit_bar_bg:top() )

		self._unit_health_text:set_color( _r <= 0.1 and Color.red or _r <= 0.25 and Color.yellow or Color.white )

		self._unit_bar:stop()

		self._bar_text_rect = self._shield and self._shield_text_rect or self._health_text_rect

		self._unit_bar:animate( function( p )
			if rn < r then
				over( 0.2 , function( o )
					self._unit_bar:set_w( math.lerp( r , rn , o ) )
					self._unit_bar:set_texture_rect( self._bar_text_rect[1] , self._bar_text_rect[2] , math.lerp( r , rn , o ) , self._bar_text_rect[4] )
				end )
			end

			self._unit_bar:set_w( _r * ( self._bar_text_rect[3] - 2 ) )
			self._unit_bar:set_texture_rect( self._bar_text_rect[1] , self._bar_text_rect[2] , self._bar_text_rect[3] * _r , self._bar_text_rect[4] )
		end )
	end

	function HUDManager:set_unit_health_rotation( angle )

		self._unit_health_enemy_location:set_rotation( angle )

	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
	Hooks:PostHook( PlayerStandard , "_update_fwd_ray" , "WolfHUDPostPlayerStandardUpdate" , function( self , t , dt )
		if self._fwd_ray and self._fwd_ray.unit and type(self._fwd_ray.unit) == "userdata" then
			local unit = self._fwd_ray.unit
			if unit:in_slot( 8 ) and alive(unit:parent()) then -- Fix when aiming at shields shield.
				unit = unit:parent()
			end

			local visible, name, name_id, health, max_health, shield
			if alive( unit ) then
				if unit:in_slot( 25 ) and not unit:character_damage():dead() and (table.contains(managers.groupai:state():turrets() or {}, unit) or WolfHUD:getSetting({"EnemyHealthbar", "SHOW_CIVILIAN"}, true) and Network:is_server()) then
					self._last_unit = nil
					visible = true
					name_id = unit:base():get_name_id() or "TURRET"
					if not unit:character_damage():needs_repair() then
						shield = true
						health = unit:character_damage()._shield_health * 10 or 0
						max_health = unit:character_damage()._SHIELD_HEALTH_INIT * 10 or 0
					else
						health = unit:character_damage()._health * 10 or 0
						max_health = unit:character_damage()._HEALTH_INIT * 10 or 0
					end
				elseif alive( unit ) and ( unit:in_slot( 12 ) or WolfHUD:getSetting({"EnemyHealthbar", "SHOW_CIVILIAN"}, false) and ( unit:in_slot( 21 ) or unit:in_slot( 22 ) ) or unit:in_slot( 16 ) and Network:is_server()) and not unit:character_damage():dead() then
					self._last_unit = unit
					visible = true
					health = unit:character_damage()._health * 10 or 0
					max_health = unit:character_damage()._HEALTH_INIT * 10 or 0
					name_id = unit:base()._tweak_table or "ENEMY"

					if name_id == "robbers_safehouse" and unit:interaction() then
						name_id = CriminalsManager.convert_new_to_old_character_workname(unit:interaction().character or name_id)
					end
				elseif alive( unit ) and unit:in_slot( 39 ) and WolfHUD:getSetting({"EnemyHealthbar", "SHOW_VEHICLE"}, true) and unit:vehicle_driving() and not self._seat then
					self._last_unit = nil
					visible = true
					health = unit:character_damage()._health or 0
					max_health = unit:character_damage()._current_max_health or 0
					name = unit:vehicle_driving()._tweak_data.name or "VEHICLE"
				else
					visible = false
				end
			end
			
			if not visible and self._last_unit and alive( self._last_unit ) then
				health = self._last_unit:character_damage()._health * 10 or 0
				max_health = self._last_unit:character_damage()._HEALTH_INIT * 10 or 0
				name_id = self._last_unit:base()._tweak_table or "ENEMY"

				if name_id == "robbers_safehouse" and self._last_unit:interaction() then
					name_id = CriminalsManager.convert_new_to_old_character_workname(self._last_unit:interaction().character or name_id)
				end

				local angle = (self:getUnitRotation(self._last_unit) + 360) % 360
				if self._last_unit:character_damage():dead() or (angle < 350 and angle > 10) then
					visible = false
					self._last_unit = nil
				else
					visible = true
				end

				managers.hud:set_unit_health_rotation( 360 - angle )
			else
				managers.hud:set_unit_health_rotation(0)
			end

			managers.hud:set_unit_health_visible( visible, shield )
			if health and (name or name_id) then
				managers.hud:set_unit_health( math.floor(health or 0) , math.floor(max_health or 0) , name_id or string.upper(name or "UNKNOWN"))
			end
		else
			managers.hud:set_unit_health_visible( false )
		end

	end )

	function PlayerStandard:getUnitRotation( unit )

		if not unit or not alive( unit ) then return 360 end

		local unit_position = unit:position()
		local vector = unit_position - self._camera_unit:position()
		local forward = self._camera_unit:rotation():y()
		local rotation = math.floor( vector:to_polar_with_reference( forward , math.UP ).spin )

		return rotation

	end
elseif string.lower(RequiredScript) == "lib/states/ingamearrested" then
	Hooks:PostHook( IngameArrestedState , "at_enter" , "WolfHUDPostIngameArrestedAtEnter" , function( self )
		if managers.hud then
			managers.hud:set_unit_health_visible( false, false )
		end
	end )
end