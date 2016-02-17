if string.lower(RequiredScript) == "lib/managers/hudmanager" then
	local CharacterData = {
		[ "security" ] 				= "SECURITY GUARD",
		[ "gensec" ] 				= "GENSEC UNIT",
		[ "cop" ] 					= "POLICE OFFICER",
		[ "inside_man" ] 			= "INSIDE MAN",
		[ "fbi" ] 					= "FBI UNIT",
		[ "swat" ] 					= "SWAT UNIT",
		[ "heavy_swat" ] 			= "HEAVY SWAT",
		[ "fbi_swat" ] 				= "FBI SWAT",
		[ "fbi_heavy_swat" ] 		= "FBI HEAVY SWAT",
		[ "city_swat" ] 			= "CITY SWAT/MURKYWATER",
		[ "sniper" ] 				= "SNIPER",
		[ "gangster" ] 				= "GANGSTER",
		[ "biker" ] 				= "BIKER",
		[ "biker_escape" ] 			= "BIKER",
		[ "mobster" ] 				= "RUSSIAN MOBSTER",
		[ "mobster_boss" ] 			= "THE COMMISSAR",
		[ "hector_boss" ] 			= "ARMOURED HECTOR",
		[ "hector_boss_no_armor" ] 	= "HECTOR",
		[ "tank" ] 					= "BULLDOZER",
		[ "spooc" ] 				= "CLOAKER",
		[ "shield" ] 				= "SHIELD",
		[ "phalanx_minion" ] 		= "WINTERS SHIELD",
		[ "phalanx_vip" ] 			= "CAPTAIN WINTERS",
		[ "taser" ] 				= "TASER",
		[ "civilian" ] 				= "CIVILIAN",
		[ "civilian_female" ] 		= "CIVILIAN",
		[ "bank_manager" ] 			= "BANK MANAGER",
		[ "escort_undercover" ] 	= "TAXMAN",
		[ "drunk_pilot" ] 			= "DRUNK PILOT",
		[ "escort" ] 				= "ESCORT",
		[ "boris" ]					= "BORIS",
		[ "russian" ] 				= "DALLAS",
		[ "german" ] 				= "WOLF",
		[ "spanish" ] 				= "CHAINS",
		[ "american" ] 				= "HOUSTON",
		[ "jowi" ] 					= "WICK",
		[ "old_hoxton" ] 			= "HOXTON",
		[ "clover" ] 				= "CLOVER",
		[ "female_1" ] 				= "CLOVER",
		[ "dragan" ] 				= "DRAGAN",
		[ "jacket" ] 				= "JACKET",
		[ "bonnie" ] 				= "BONNIE",
		[ "sokol" ] 				= "SOKOL",
		[ "dragon" ] 				= "JIRO",
		[ "bodhi" ] 				= "BODHI",
		[ "old_hoxton_mission" ] 	= "HOXTON/LOCKE"
	}

	Hooks:PostHook( HUDManager , "_player_hud_layout" , "uHUDPostHUDManagerPlayerInfoHUDLayout" , function( self )

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
			font 		= "fonts/font_medium_shadow_mf",
			font_size 	= 22,
			color 		= Color.white,
			align 		= "center",
			layer 		= 1
		})
		
		self._unit_health_enemy_location = self._unit_health_panel:text({
			name 		= "unit_health_enemy_location",
			text 		= "^",
			blend_mode 	= "normal",
			visible 	= false,
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
		if not WolfHUD.settings.show_enemy_healthbar then return end
		
		if visible == true and not self._unit_health_visible then
		
			self._unit_health_visible = true
			self._unit_health_panel:stop()
			
			self._unit_health_panel:animate( function( p )
				self._unit_health_panel:set_visible( true )
				self._unit_health_panel:set_alpha( 0 )
				self._unit_health_enemy_location:set_visible( WolfHUD.settings.show_healthbar_pointer or false )
				self._unit_health_enemy_location:set_alpha( 0 )
				
				over( 0.5 , function( o )
					self._unit_health_panel:set_alpha( math.lerp( 0 , 1 , o ) )
					self._unit_health_enemy_location:set_alpha( math.lerp( 0 , 1 , o ) )
				end )
			end )
		
		elseif visible == false and self._unit_health_visible then
			
			self._unit_health_visible = nil
			self._unit_health_panel:stop()
			
			self._unit_health_panel:animate( function( p )
				self._unit_health_panel:set_alpha( 1 )
				self._unit_health_enemy_location:set_alpha( 1 )
				
				over( 1.5 , function( o )
					self._unit_health_panel:set_alpha( math.lerp( 1 , 0 , o ) )
					self._unit_health_enemy_location:set_alpha( math.lerp( 1 , 0 , o ) )
				end )
				
				self._unit_health_panel:set_visible( false )
				self._unit_health_enemy_location:set_visible( false )
			end )
		
		end

	end

	function HUDManager:set_unit_health( current , total , tweak_table )

		if not current or not total then return end
		
		local enemy = CharacterData[ tweak_table ] or tweak_table
		
		local _r = current / total
		
		local r = self._unit_health:width()
		local rn = ( self._health_text_rect[ 3 ] - 2 ) * _r

		self._unit_health_enemy_text:set_text( enemy )
		self._unit_health_text:set_text( string.format( "%d/%d" , current * 10 , total * 10 ) )
		
		local hx , hy , hw , hh = self._unit_health_text:text_rect()
		local ex , ey , ew , eh = self._unit_health_enemy_text:text_rect()
		
		self._unit_health_text:set_size( hw , hh )
		self._unit_health_enemy_text:set_size( ew , eh )
		
		self._unit_health_text:set_right( self._unit_shield:right() )
		self._unit_health_text:set_bottom( self._unit_shield:top() )
		self._unit_health_enemy_text:set_left( self._unit_shield:left() )
		self._unit_health_enemy_text:set_bottom( self._unit_shield:top() )
		
		self._unit_health_text:set_color( current == 0 and Color.red or Color.white )
		
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
	Hooks:PostHook( PlayerStandard , "update" , "uHUDPostPlayerStandardUpdate" , function( self , t , dt )
		if self._last_unit then
		
			local iAngle = 360
			local cAngle = 360
			
			iAngle = self:getUnitRotation( self._last_unit )
			
			if iAngle then
				
				cAngle = cAngle + ( iAngle - cAngle )
				
				if cAngle == 0 then cAngle = 360 end
			
				managers.hud:set_unit_health_rotation( cAngle )
			end
		end
		
		if self._fwd_ray and self._fwd_ray.unit then
		
			local unit = self._fwd_ray.unit
			if unit:parent() then unit = unit:parent() end
			
			if alive( unit ) and unit:character_damage() and not unit:character_damage()._dead and unit:base() and unit:base()._tweak_table 
				and ((not managers.enemy:is_civilian( unit ) and managers.enemy:is_enemy( unit )) or WolfHUD.settings.show_civilians_health) then 
					--[[if not unit:character_damage()._gui and unit:character_damage()._create_debug_ws then
						unit:character_damage():_create_debug_ws()
					end]]
					self._last_unit = unit
					managers.hud:set_unit_health_visible( true )
					managers.hud:set_unit_health( unit:character_damage()._health or 0 , unit:character_damage()._HEALTH_INIT or 0 , unit:base()._tweak_table or "cop" )
				--end
			else
				if self._last_unit and alive( self._last_unit ) then
					managers.hud:set_unit_health( self._last_unit:character_damage()._health or 0 , self._last_unit:character_damage()._HEALTH_INIT or 0 , self._last_unit:base()._tweak_table or "cop" )
					local angle = self:getUnitRotation(unit)
					if angle < 0 then angle = angle + 360 end
					if self._last_unit:character_damage()._dead or (angle < 340 and angle > 20) then managers.hud:set_unit_health_visible( false ) else return end
				end
				
			end
			
		else
			managers.hud:set_unit_health_visible( false )
		end

	end )

	function PlayerStandard:getUnitRotation( unit )

		if not unit or not alive( unit ) then return 360 end
		
		local unit_position = unit:position()
		local vector = self._camera_unit:position() - unit_position
		local forward = self._camera_unit:rotation():y()
		local rotation = math.floor( vector:to_polar_with_reference( forward , math.UP ).spin )
		
		return -( rotation + 180 )

	end
end