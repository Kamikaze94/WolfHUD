if string.lower(RequiredScript) == "lib/managers/hudmanager" then
	local CharacterData = {
		[ "civilian" ] 				= "wolfhud_enemy_civilian",
		[ "civilian_female" ] 		= "wolfhud_enemy_civilian",
		[ "gangster" ] 				= "wolfhud_enemy_gangster",
		[ "biker" ] 				= "wolfhud_enemy_biker",
		[ "biker_escape" ] 			= "wolfhud_enemy_biker",
		[ "mobster" ] 				= "wolfhud_enemy_mobster",
		[ "security" ] 				= "wolfhud_enemy_security",
		[ "gensec" ] 				= "wolfhud_enemy_gensec",
		[ "cop" ] 					= "wolfhud_enemy_cop",
		[ "fbi" ] 					= "wolfhud_enemy_fbi",
		[ "swat" ] 					= "wolfhud_enemy_swat",
		[ "heavy_swat" ] 			= "wolfhud_enemy_heavy_swat",
		[ "fbi_swat" ] 				= "wolfhud_enemy_swat",
		[ "fbi_heavy_swat" ] 		= "wolfhud_enemy_heavy_swat",
		[ "city_swat" ] 			= "wolfhud_enemy_city_swat",
		[ "shield" ] 				= "wolfhud_enemy_shield",
		[ "spooc" ] 				= "wolfhud_enemy_spook",
		[ "taser" ] 				= "wolfhud_enemy_taser",
		[ "sniper" ] 				= "wolfhud_enemy_sniper",
		[ "tank" ] 					= "wolfhud_enemy_tank",
		[ "tank_hw" ]				= "wolfhud_enemy_tank_hw",
		[ "phalanx_minion" ] 		= "wolfhud_enemy_phalanx_minion",
		[ "phalanx_vip" ] 			= "wolfhud_enemy_phalanx_vip",
		[ "mobster_boss" ] 			= "wolfhud_enemy_mobster_boss",
		[ "bank_manager" ] 			= "wolfhud_enemy_bank_manager",
		[ "inside_man" ] 			= "wolfhud_enemy_inside_man",
		[ "escort_undercover" ] 	= "wolfhud_enemy_escort_undercover",
		[ "drunk_pilot" ] 			= "wolfhud_enemy_drunk_pilot",
		[ "escort" ] 				= "wolfhud_enemy_escort",
		[ "boris" ]					= "wolfhud_enemy_boris",
		[ "old_hoxton_mission" ] 	= "wolfhud_enemy_old_hoxton_mission",
		[ "hector_boss" ] 			= "wolfhud_enemy_hector_boss",
		[ "hector_boss_no_armor" ] 	= "wolfhud_enemy_hector_boss_no_armor",
		[ "russian" ] 				= "menu_russian",
		[ "german" ] 				= "menu_german",
		[ "spanish" ] 				= "menu_spanish",
		[ "american" ] 				= "menu_american",
		[ "jowi" ] 					= "menu_jowi",
		[ "old_hoxton" ] 			= "menu_old_hoxton",
		[ "female_1" ] 				= "menu_female_1",
		[ "dragan" ] 				= "menu_dragan",
		[ "jacket" ] 				= "menu_jacket",
		[ "bonnie" ] 				= "menu_bonnie",
		[ "sokol" ] 				= "menu_sokol",
		[ "dragon" ] 				= "menu_dragon",
		[ "bodhi" ] 				= "menu_bodhi",
		[ "jimmy" ] 				= "menu_jimmy",
		[ "sydney" ] 				= "menu_sydney"
	}

	Hooks:PostHook( HUDManager , "_player_hud_layout" , "WolfHUDPostHUDManagerPlayerInfoHUDLayout" , function( self )

		local unit_health_main = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:panel({
			name 	= "unit_health_main",
			halign 	= "grow",
			valign 	= "grow"
		})
		
		self._unit_health_panel = unit_health_main:panel({
			name 	= "unit_health_panel",
			visible = false
		})
		
		self._unit_health = self._unit_health_panel:bitmap({
			name 			= "unit_health",
			texture 		= "guis/textures/pd2/healthshield",
			texture_rect 	= { 2, 18, 232,	11 },
			blend_mode 		= "normal"
		})
		
		self._health_text_rect = { 2 , 18 , 232 , 11 }
		
		self._unit_shield = self._unit_health_panel:bitmap({
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
			visible 	= WolfHUD:getSetting("show_healthbar_pointer", "boolean"),
			alpha 		= 0.75,
			halign 		= "center",
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 20,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})
		
		local hx , hy , hw , hh = self._unit_health_text:text_rect()
		local ex , ey , ew , eh = self._unit_health_enemy_text:text_rect()
		local lx , ly , lw , lh = self._unit_health_enemy_location:text_rect()
		
		self._unit_health_text:set_size( hw , hh )
		self._unit_health_enemy_text:set_size( ew , eh )
		self._unit_health_enemy_location:set_size( lw , lh )
		
		self._unit_health:set_w( self._unit_health:w() - 2 )
		
		self._unit_health:set_center( self._unit_health_panel:center_x() , self._unit_health_panel:center_y() - 190 )
		self._unit_shield:set_center( self._unit_health_panel:center_x() , self._unit_health_panel:center_y() - 190 )
		
		self._unit_health_text:set_right( self._unit_shield:right() )
		self._unit_health_text:set_bottom( self._unit_shield:top() )
		
		self._unit_health_enemy_text:set_left( self._unit_shield:left() )
		self._unit_health_enemy_text:set_bottom( self._unit_shield:top() )
		
		self._unit_health_enemy_location:set_center_x( self._unit_shield:center_x() )
		self._unit_health_enemy_location:set_top( self._unit_shield:bottom() )

	end )

	function HUDManager:set_unit_health_visible( visible )		
		if visible == true and not self._unit_health_visible and WolfHUD:getSetting("show_enemy_healthbar", "boolean") then
		
			self._unit_health_visible = true
			self._unit_health_enemy_location:set_visible(WolfHUD:getSetting("show_healthbar_pointer", "boolean"))
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
		
		local enemy = CharacterData[ tweak_table ]
		if enemy then
			enemy = managers.localization:to_upper_text(enemy)
		else
			enemy = tweak_table
		end
		
		current = math.max(current, 0)
		local _r = current / total
		
		local r = self._unit_health:width()
		local rn = ( self._health_text_rect[ 3 ] - 2 ) * _r

		self._unit_health_enemy_text:set_text( enemy )
		self._unit_health_text:set_text( string.format( "%d/%d" , current , total ) )
		
		local hx , hy , hw , hh = self._unit_health_text:text_rect()
		local ex , ey , ew , eh = self._unit_health_enemy_text:text_rect()
		
		self._unit_health_text:set_size( hw , hh )
		self._unit_health_enemy_text:set_size( ew , eh )
		
		self._unit_health_text:set_right( self._unit_shield:right() )
		self._unit_health_text:set_bottom( self._unit_shield:top() )
		self._unit_health_enemy_text:set_left( self._unit_shield:left() )
		self._unit_health_enemy_text:set_bottom( self._unit_shield:top() )
		
		self._unit_health_text:set_color( _r <= 0.1 and Color.red or _r <= 0.25 and Color.yellow or Color.white )
		
		self._unit_health:stop()
		
		if rn < r then
			self._unit_health:animate( function( p )
				over( 0.2 , function( o )
					self._unit_health:set_w( math.lerp( r , rn , o ) )
					self._unit_health:set_texture_rect( self._health_text_rect[ 1 ] , self._health_text_rect[ 2 ] , math.lerp( r , rn , o ) , self._health_text_rect[ 4 ] )
				end )
			end )
		end
		
		self._unit_health:set_w( _r * ( self._health_text_rect[ 3 ] - 2 ) )
		self._unit_health:set_texture_rect( self._health_text_rect[ 1 ] , self._health_text_rect[ 2 ] , self._health_text_rect[ 3 ] * _r , self._health_text_rect[ 4 ] )

	end

	function HUDManager:set_unit_health_rotation( angle )

		self._unit_health_enemy_location:set_rotation( angle )

	end
elseif string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
	Hooks:PostHook( PlayerStandard , "_update_fwd_ray" , "WolfHUDPostPlayerStandardUpdate" , function( self , t , dt )
		if self._last_unit then
			local angle = self:getUnitRotation( self._last_unit )
			managers.hud:set_unit_health_rotation( 360 - angle )
		end
		
		if self._fwd_ray and self._fwd_ray.unit and type(self._fwd_ray.unit) == "userdata" then
			local unit = self._fwd_ray.unit
			if unit:in_slot( 8 ) and alive(unit:parent()) then unit = unit:parent() end
			if managers.groupai:state():turrets() then	--in_slot(25, 26)
				for _ , t_unit in pairs( managers.groupai:state():turrets() ) do
					if alive( t_unit ) and t_unit:movement():team().foes[ managers.player:player_unit():movement():team().id ] and unit == t_unit then
						unit = t_unit
						log("Turret found")
--[[					for id, data in pairs(t_unit) do
							if type(data) ~= "function" and type(data) ~= "table" then
								log(tostring(id) .. " = " .. tostring(data))
							end
						end]]
					end
				end
			end
			
			if alive( unit ) and unit:character_damage() and not unit:character_damage()._dead and unit:base() and unit:base()._tweak_table and ((not managers.enemy:is_civilian( unit ) and managers.enemy:is_enemy( unit )) or WolfHUD:getSetting("show_civilian_healthbar", "boolean")) then
				self._last_unit = unit
				managers.hud:set_unit_health_visible( true )
				managers.hud:set_unit_health( unit:character_damage()._health * 10 or 0 , unit:character_damage()._HEALTH_INIT * 10 or 0 , unit:base()._tweak_table or "ENEMY" )
			elseif alive( unit ) and unit:vehicle() and unit:vehicle_driving() and unit:character_damage() and not self._seat and WolfHUD:getSetting("show_car_healthbar", "boolean") then
				self._last_unit = nil
				managers.hud:set_unit_health_visible( true )
				managers.hud:set_unit_health( unit:character_damage()._health or 0 , unit:character_damage()._current_max_health or 0 , string.upper(unit:vehicle_driving()._tweak_data.name) or "VEHICLE" )
			else
				if self._last_unit and alive( self._last_unit ) then
					managers.hud:set_unit_health( self._last_unit:character_damage()._health * 10 or 0 , self._last_unit:character_damage()._HEALTH_INIT * 10 or 0 , self._last_unit:base()._tweak_table or "ENEMY" )
					local angle = self:getUnitRotation(self._last_unit)
					if angle < 0 then angle = angle + 360 end
					if self._last_unit:character_damage()._dead or (angle < 350 and angle > 10) then managers.hud:set_unit_health_visible( false ) end
				else
					managers.hud:set_unit_health_visible( false )
				end
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
end