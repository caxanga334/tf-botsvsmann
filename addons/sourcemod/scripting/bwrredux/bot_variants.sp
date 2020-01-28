// pootis robots here

// remove items from the player
void StripItems( int client, bool RemoveWeapons = true )
{	
	if( !IsClientInGame(client) || IsFakeClient( client ) || !IsPlayerAlive( client ) )
		return;
		
	int iEntity;
	int iOwner;
	
	if(RemoveWeapons)
	{
		iEntity = -1;
		while( ( iEntity = FindEntityByClassname( iEntity, "tf_wearable_demoshield" ) ) > MaxClients )
		{
			iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
			if( iOwner == client )
			{
				TF2_RemoveWearable( client, iEntity );
				AcceptEntityInput( iEntity, "Kill" );
			}
		}
		
		iEntity = -1;
		while( ( iEntity = FindEntityByClassname( iEntity, "tf_wearable_razorback" ) ) > MaxClients )
		{
			iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
			if( iOwner == client )
			{
				TF2_RemoveWearable( client, iEntity );
				AcceptEntityInput( iEntity, "Kill" );
			}
		}
		
		TF2_RemoveAllWeapons(client);
		// bug: sappers and toolboxes aren't removed however this shouldn't be a problem.
	}
	
	if( !OR_IsHalloweenMission() ) // Allow players to have wearables on wave 666
	{
		iEntity = -1;
		while( ( iEntity = FindEntityByClassname( iEntity, "tf_wearable" ) ) > MaxClients )
		{
			iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
			if( iOwner == client )
			{
				TF2_RemoveWearable( client, iEntity );
				AcceptEntityInput( iEntity, "Kill" );
			}
		}
	}
	
	iEntity = -1;
	while( ( iEntity = FindEntityByClassname( iEntity, "tf_powerup_bottle" ) ) > MaxClients )
	{
		iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
		if( iOwner == client )
			AcceptEntityInput( iEntity, "Kill" );
	}
	iEntity = -1;
	while( ( iEntity = FindEntityByClassname( iEntity, "tf_usableitem" ) ) > MaxClients )
	{
		iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
		if( iOwner == client )
			AcceptEntityInput( iEntity, "Kill" );
	}
}

// remove items from the player
void StripWeapons( int client )
{	
	if( !IsClientInGame(client) || IsFakeClient( client ) || !IsPlayerAlive( client ) )
		return;
		
	int iEntity;
	int iOwner;
	
	iEntity = -1;
	while( ( iEntity = FindEntityByClassname( iEntity, "tf_wearable_demoshield" ) ) > MaxClients )
	{
		iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
		if( iOwner == client )
		{
			TF2_RemoveWearable( client, iEntity );
			AcceptEntityInput( iEntity, "Kill" );
		}
	}
	
	iEntity = -1;
	while( ( iEntity = FindEntityByClassname( iEntity, "tf_wearable_razorback" ) ) > MaxClients )
	{
		iOwner = GetEntPropEnt( iEntity, Prop_Send, "m_hOwnerEntity" );
		if( iOwner == client )
		{
			TF2_RemoveWearable( client, iEntity );
			AcceptEntityInput( iEntity, "Kill" );
		}
	}
	
	TF2_RemoveAllWeapons(client);
	// bug: sappers and toolboxes aren't removed however this shouldn't be a problem.
}


// use TF2Items for giving weapons
int SpawnWeapon(int client,char[] name,int index,int level,int qual,bool bWearable = false)
{
	if( IsFakeClient(client) )
		return -1;

	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION|PRESERVE_ATTRIBUTES);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	
	if (hWeapon==null)
		return -1;
		
	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	if( IsValidEdict( entity ) )
	{
		if( bWearable )
		{
			TF2_EquipPlayerWearable(client, entity);
		}
		else
			EquipPlayerWeapon( client, entity );
	}
	return entity;
}

void GiveNormalInventory(int client ,int botvariant)
{
	if( IsFakeClient(client) )
		return;

	TFClassType TFClass = TF2_GetPlayerClass(client);
	int iWeapon;
	
	switch( TFClass )
	{
		case TFClass_Scout:
		{
			switch( botvariant )
			{
				case 0: // standard scout
				{
					SpawnWeapon( client, "tf_weapon_scattergun", 13, 1, 6, false ); // client, classname, item index, level, quality, Is Wearable?
					return;					
				}
				case 1: // bat scout
				{
					SpawnWeapon( client, "tf_weapon_bat", 0, 1, 6, false );
					return;					
				}
				case 2: // bonk scout
				{
					SpawnWeapon( client, "tf_weapon_lunchbox_drink", 46, 1, 6, false);
					SpawnWeapon( client, "tf_weapon_bat", 0, 1, 6, false );
					return;					
				}
				case 3: // Minor League Scout
				{
					SpawnWeapon( client, "tf_weapon_bat_wood", 44, 1, 6, false );
					return;					
				}
				case 4: // Hyper League Scout
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_bat_wood", 44, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "effect bar recharge rate increased", 0.25);
					return;					
				}
				case 5: // Force-A-Nature Scout
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_scattergun", 45, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 1.6);
					TF2Attrib_SetByName(iWeapon, "scattergun knockback mult", 1.5);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 0.65);
					return;					
				}
				case 6: // Shortstop Scout
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_handgun_scout_primary", 220, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "head scale", 0.7);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 1.25);
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 525.0);
					return;					
				}
			}
		}
		case TFClass_Soldier:
		{
			switch( botvariant )
			{
				case 0: // standard soldier
				{
					SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_shovel", 6, 1, 6, false );
					return;					
				}
				case 1: // direct hit soldier
				{
					SpawnWeapon( client, "tf_weapon_rocketlauncher_directhit", 127, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_shovel", 6, 1, 6, false );
					return;						
				}
				case 2: // extended buff soldier
				{
					SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_buff_item", 129, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "increase buff duration", 9.0);
					return;						
				}
				case 3: // extended battalions soldier
				{
					SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_buff_item", 226, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "increase buff duration", 9.0);
					return;						
				}
				case 4: // extended concheror soldier
				{
					SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_buff_item", 354, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "increase buff duration", 9.0);
					return;						
				}
				case 5: // blast soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 414, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "damage causes airblast", 1.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 0.45);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.001);
					TF2Attrib_SetByName(iWeapon, "clip size upgrade atomic", -2.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 1.5);
					TF2Attrib_SetByName(iWeapon, "Blast radius decreased", 1.2);
					TF2Attrib_SetByName(iWeapon, "projectile spread angle penalty", 2.0);
					SpawnWeapon( client, "tf_weapon_shovel", 6, 1, 6, false );
					return;						
				}
				case 6: // black box soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 228, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "heal on hit for rapidfire", 60.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 0.33);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.001);
					TF2Attrib_SetByName(iWeapon, "clip size upgrade atomic", 0.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 0.9);
					TF2Attrib_SetByName(iWeapon, "blast radius increased", 1.25);
					TF2Attrib_SetByName(iWeapon, "projectile spread angle penalty", 2.0);
					SpawnWeapon( client, "tf_weapon_shovel", 6, 1, 6, false );
					return;						
				}
			}
		}
		case TFClass_Pyro:
		{
			switch( botvariant )
			{
				case 0: // standard pyro
				{
					SpawnWeapon( client, "tf_weapon_flamethrower", 21, 1, 6, false ); // client, classname, item index, level, quality, Is Wearable?
					SpawnWeapon( client, "tf_weapon_fireaxe", 2, 1, 6, false ); // Fire Axe
					return;					
				}
				case 1: // flare pyro
				{
					SpawnWeapon( client, "tf_weapon_flaregun", 39, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_fireaxe", 2, 1, 6, false ); // Fire Axe
					return;					
				}
				case 2: // Pyro Pusher
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_flaregun", 740, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.75);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 1.25);
					TF2Attrib_SetByName(iWeapon, "Projectile speed increased", 0.35);
					SpawnWeapon( client, "tf_weapon_fireaxe", 2, 1, 6, false ); // Fire Axe
					return;					
				}
				case 3: // Fast Scorch Shot
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_flaregun", 740, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.75);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 1.0);
					TF2Attrib_SetByName(iWeapon, "Projectile speed increased", 1.30);
					SpawnWeapon( client, "tf_weapon_fireaxe", 2, 1, 6, false ); // Fire Axe
					return;					
				}
			}			
		}
		case TFClass_DemoMan:
		{
			switch( botvariant )
			{
				case 0: // standard demo
				{
					SpawnWeapon( client, "tf_weapon_grenadelauncher", 19, 1, 6, false );
					return;			
				}
				case 1: // burst fire demo
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_grenadelauncher", 19, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 1.75);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.05);
					TF2Attrib_SetByName(iWeapon, "clip size penalty", 0.5);
					TF2Attrib_SetByName(iWeapon, "projectile spread angle penalty", 3.0);
					return;					
				}
				case 2: // Demoknight
				{
					SpawnWeapon( client, "tf_wearable_demoshield", 131, 1, 6, true ); // set true for wearable weapons.
					iWeapon = SpawnWeapon( client, "tf_weapon_sword", 132, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "critboost on kill", 3.0);
					return;			
				}
				case 3: // Demo Samurai
				{
					SpawnWeapon( client, "tf_wearable_demoshield", 406, 1, 6, true ); // set true for wearable weapons.
					iWeapon = SpawnWeapon( client, "tf_weapon_katana", 357, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "increased jump height", 2.3);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 1.5);
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 475.0);
					return;			
				}
			}
		}
		case TFClass_Heavy:
		{
			switch( botvariant )
			{
				case 0: // standard heavy
				{
					SpawnWeapon( client, "tf_weapon_minigun", 15, 1, 6, false );
					return;
				}
				case 1: // Heavyweight Champ
				{
					SpawnWeapon( client, "tf_weapon_fists", 43, 1, 6, false );
					return;					
				}
				case 2: // Heater Heavy
				{
					SpawnWeapon( client, "tf_weapon_minigun", 811, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_fists", 5, 1, 6, false );
					return;
				}
				case 3: // Shotgun Heavy
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_shotgun_hwg", 11, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 0.1);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 2.5);
					TF2Attrib_SetByName(iWeapon, "bullets per shot bonus", 3.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 0.33);
					SpawnWeapon( client, "tf_weapon_fists", 5, 1, 6, false );
					return;
				}
				case 4: // Steel Gauntlet Pusher
				{
					TF2Attrib_SetByName(client, "hidden maxhealth non buffed", 600.0);
					iWeapon = SpawnWeapon( client, "tf_weapon_fists", 331, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "damage causes airblast", 1.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 1.50);
					return;
				}
				case 5: // Stun Heavy
				{
					TF2Attrib_SetByName(client, "hidden maxhealth non buffed", 80.0);
					iWeapon = SpawnWeapon( client, "tf_weapon_minigun", 15, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "damage causes airblast", 1.0);
					TF2Attrib_SetByName(iWeapon, "damage penalty", 0.15);
					TF2Attrib_SetByName(iWeapon, "fire rate penalty", 1.4);
					TF2Attrib_SetByName(iWeapon, "mod stun waist high airborne", 1.0);
					TF2Attrib_SetByName(iWeapon, "minigun spinup time increased", 1.8);
					return;
				}
			}			
		}
		case TFClass_Engineer:
		{
			switch( botvariant )
			{
				case 0: // standard engineer (275 HP)
				{
					SpawnWeapon( client, "tf_weapon_shotgun_primary", 9, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_wrench", 7, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_pda_engineer_build", 25, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 150.0);
					TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
					SpawnWeapon( client, "tf_weapon_pda_engineer_destroy", 26, 1, 6, false );
					return;
				}
				case 1: // standard engineer (500 HP)
				{
					SpawnWeapon( client, "tf_weapon_shotgun_primary", 9, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_wrench", 7, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_pda_engineer_build", 25, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 375.0);
					TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
					SpawnWeapon( client, "tf_weapon_pda_engineer_destroy", 26, 1, 6, false );
					return;				
				}
				case 2: // battle engineer (275 HP)
				{
					SpawnWeapon( client, "tf_weapon_shotgun_primary", 9, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_wrench", 7, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_pda_engineer_build", 25, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 150.0);
					TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
					SpawnWeapon( client, "tf_weapon_pda_engineer_destroy", 26, 1, 6, false );
					return;
				}
				case 3: // battle engineer (275 HP)
				{
					SpawnWeapon( client, "tf_weapon_shotgun_primary", 9, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_wrench", 7, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_pda_engineer_build", 25, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 150.0);
					TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
					SpawnWeapon( client, "tf_weapon_pda_engineer_destroy", 26, 1, 6, false );
					return;
				}
			}		
		}
		case TFClass_Medic:
		{
			switch( botvariant )
			{
				case 0: // uber medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_medigun", 29, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_bonesaw", 8, 1, 6, false );
					return;
				}
				case 1: // Kritzkrieg medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_medigun", 35, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_bonesaw", 8, 1, 6, false );
					return;				
				}
				case 2: // Quick-fix Mega Heal Medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_medigun", 411, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "heal rate bonus", 10.0);
					SpawnWeapon( client, "tf_weapon_bonesaw", 8, 1, 6, false );
					return;				
				}
				case 3: // Shield Medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_medigun", 411, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "generate rage on heal", 2.0);
					TF2Attrib_SetByName(iWeapon, "increase buff duration", 1.2);
					SpawnWeapon( client, "tf_weapon_bonesaw", 8, 1, 6, false );
					return;				
				}
			}	
		}
		case TFClass_Sniper:
		{
			switch( botvariant )
			{
				case 0: // standard sniper
				{
					SpawnWeapon( client, "tf_weapon_sniperrifle", 14, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_club", 3, 1, 6, false );
					if(GetRandomInt(0,10) > 3)
						SpawnWeapon( client, "tf_wearable_razorback", 57, 1, 6, true );
					return;
				}
				case 1: // bowman
				{
					SpawnWeapon( client, "tf_weapon_compound_bow", 56, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_club", 3, 1, 6, false );
					if(GetRandomInt(0,10) > 5)
						SpawnWeapon( client, "tf_wearable_razorback", 57, 1, 6, true );
					return;			
				}
				case 2: // Sydney Sniper
				{
					SpawnWeapon( client, "tf_weapon_sniperrifle", 230, 1, 6, false ); // The Sydney Sleeper
					SpawnWeapon( client, "tf_weapon_club", 3, 1, 6, false );
					if(GetRandomInt(0,10) > 1)
						SpawnWeapon( client, "tf_wearable_razorback", 57, 1, 6, true );
					return;
				}
			}
		}
		case TFClass_Spy:
		{
			switch( botvariant )
			{
				case 0: // standard spy
				{
					SpawnWeapon( client, "tf_weapon_revolver", 24, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_builder", 735, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_knife", 4, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_pda_spy", 27, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_invis", 30, 1, 6, false );
					return;
				}
				case 1: // dead ringer spy
				{
					SpawnWeapon( client, "tf_weapon_revolver", 24, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_builder", 735, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_knife", 4, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_pda_spy", 27, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_invis", 59, 1, 6, false );
					return;			
				}
				case 2: // gentle spy
				{
					SpawnWeapon( client, "tf_weapon_revolver", 61, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_builder", 735, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "kill eater score type", 24.0);
					TF2Attrib_SetByName(iWeapon, "sapper damage penalty", 0.0);
					TF2Attrib_SetByName(iWeapon, "sapper degenerates buildings", 0.9);
					iWeapon = SpawnWeapon( client, "tf_weapon_knife", 727, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 375.0);
					SpawnWeapon( client, "tf_weapon_pda_spy", 27, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_invis", 59, 1, 6, false );
					return;			
				}
				case 3: // ninja spy
				{
					SpawnWeapon( client, "tf_weapon_revolver", 24, 1, 6, false );
					SpawnWeapon( client, "tf_weapon_builder", 735, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_knife", 356, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 1.30);
					TF2Attrib_SetByName(iWeapon, "health regen", 4.0);
					SpawnWeapon( client, "tf_weapon_pda_spy", 27, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_invis", 59, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "SET BONUS: quiet unstealth", 1.0);
					TF2Attrib_SetByName(iWeapon, "mult cloak meter regen rate", 24.0);
					TF2Attrib_SetByName(iWeapon, "cloak consume rate decreased", 0.01);
					TF2Attrib_RemoveByName(iWeapon, "cloak_consume_on_feign_death_activate"); // test
					return;			
				}
			}
		}
	}
}

// giant inventory
void GiveGiantInventory(int client ,int botvariant)
{
	if( IsFakeClient(client) )
		return;

	TFClassType TFClass = TF2_GetPlayerClass(client);
	int iWeapon;
	
	switch( TFClass )
	{
		case TFClass_Scout:
		{
			switch( botvariant )
			{
				case 0: // giant scout
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_scattergun", 13, 1, 6, false ); // client, classname, item index, level, quality, Is Wearable?
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1475.0);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.7);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.7);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 5.0);
					return;
				}
				case 1: // super scout
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_bat_fish", 221, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1075.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 2.0);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.7);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.7);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 5.0);
					return;				
				}
			}	
		}
		case TFClass_Soldier:
		{
			switch( botvariant )
			{
				case 0: // giant soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 3600.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 3.0);
					return;
				}
				case 1: // Giant Charged Soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 513, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 3600.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 3.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 0.2);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 2.0);
					TF2Attrib_SetByName(iWeapon, "Projectile speed increased", 0.5);
					return;			
				}
				case 2: // Giant Rapid Fire Soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					TF2Attrib_SetByName(client, "hidden maxhealth non buffed", 3600.0);
					TF2Attrib_SetByName(client, "move speed bonus", 0.5);
					TF2Attrib_SetByName(client, "damage force reduction", 0.4);
					TF2Attrib_SetByName(client, "airblast vulnerability multiplier", 0.4);
					TF2Attrib_SetByName(client, "override footstep sound set", 3.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", -0.8);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "Projectile speed increased", 0.65);
					return;
				}
				case 3: // Giant Burst Fire Soldier
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_rocketlauncher", 18, 1, 6, false );
					TF2Attrib_SetByName(client, "hidden maxhealth non buffed", 3600.0);
					TF2Attrib_SetByName(client, "move speed bonus", 0.5);
					TF2Attrib_SetByName(client, "damage force reduction", 0.4);
					TF2Attrib_SetByName(client, "airblast vulnerability multiplier", 0.4);
					TF2Attrib_SetByName(client, "override footstep sound set", 3.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", 0.6);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.1);
					TF2Attrib_SetByName(iWeapon, "Projectile speed increased", 0.65);
					TF2Attrib_SetByName(iWeapon, "clip size upgrade atomic", 5.0);
					return;
				}
			}	
		}
		case TFClass_Pyro:
		{
			switch( botvariant )
			{
				case 0: // giant pyro
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_flamethrower", 21, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 2825.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 6.0);
					return;
				}
				case 1: // Giant Airblast Pyro
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_flamethrower", 215, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 2825.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 6.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 0.05);
					TF2Attrib_SetByName(iWeapon, "airblast pushback scale", 5.0);
					return;			
				}
			}			
		}
		case TFClass_DemoMan:
		{
			switch( botvariant )
			{
				case 0: // giant rapid fire demoman
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_grenadelauncher", 19, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 3125.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.5);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.5);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
					TF2Attrib_SetByName(iWeapon, "faster reload rate", -0.4);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.75);
					return;
				}
				case 1: // giant rapid fire demoman
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_grenadelauncher", 19, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 2825.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.5);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.5);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
					TF2Attrib_SetByName(iWeapon, "fire rate bonus", 0.5);
					return;			
				}
			}			
		}
		case TFClass_Heavy:
		{
			switch( botvariant )
			{
				case 0: // giant heavy
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_minigun", 15, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4700.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.3);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.3);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 2.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 1.5);
					return;
				}
				case 1: // Giant Deflector Heavy
				{
					iWeapon = SpawnWeapon( client, "tf_weapon_minigun", 850, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4700.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.3);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.3);
					TF2Attrib_SetByName(iWeapon, "override footstep sound set", 2.0);
					TF2Attrib_SetByName(iWeapon, "damage bonus", 1.5);
					TF2Attrib_SetByName(iWeapon, "attack projectiles", 1.0);
					return;			
				}
			}		
		}
/* 		case TFClass_Engineer:
		{
			switch( botvariant )
			{
				case -1: // own giant engineer
				{

				}
			}		
		} */
		case TFClass_Medic:
		{
			switch( botvariant )
			{
				case 0: // giant medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_medigun", 411, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4350.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
					TF2Attrib_SetByName(iWeapon, "heal rate bonus", 200.0);
					return;
				}
				case 1: // giant Kritzkrieg medic
				{
					SpawnWeapon( client, "tf_weapon_syringegun_medic", 17, 1, 6, false );
					iWeapon = SpawnWeapon( client, "tf_weapon_medigun", 35, 1, 6, false );
					TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4350.0);
					TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
					TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
					TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
					TF2Attrib_SetByName(iWeapon, "ubercharge rate bonus", 2.0);
					TF2Attrib_SetByName(iWeapon, "uber duration bonus", 9.0);
					return;			
				}
			}		
		}
/* 		case TFClass_Sniper:
		{
			switch( botvariant )
			{
				case 0: // own giant sniper
				{

				}
			}
		}
		case TFClass_Spy:
		{
			switch( botvariant )
			{
				case 0: // own giant spy
				{

				}
			}
		} */
	}
}

// returns the variant name
// TODO: set names
char GetNormalVariantName(TFClassType TFClass, int botvariant)
{
	char strBotName[128]
	
	switch( TFClass )
	{
		case TFClass_Scout:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Scout" );
				case 0: strcopy( strBotName, 128, "Standard Scout" );
				case 1: strcopy( strBotName, 128, "Bat Scout" );
				case 2: strcopy( strBotName, 128, "Bonk Scout" );
				case 3: strcopy( strBotName, 128, "Minor League Scout" );
				case 4: strcopy( strBotName, 128, "Hyper League Scout" );
				case 5: strcopy( strBotName, 128, "Force-A-Nature Scout" );
				case 6: strcopy( strBotName, 128, "Shortstop Scout" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
		case TFClass_Soldier:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Soldier" );
				case 0: strcopy( strBotName, 128, "Standard Soldier" );
				case 1: strcopy( strBotName, 128, "Direct Hit Soldier" );
				case 2: strcopy( strBotName, 128, "Extended Buff Soldier" );
				case 3: strcopy( strBotName, 128, "Extended Battalions Soldier" );
				case 4: strcopy( strBotName, 128, "Extended Concheror Soldier" );
				case 5: strcopy( strBotName, 128, "Blast Soldier" );
				case 6: strcopy( strBotName, 128, "Black Box Soldier" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Pyro:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Pyro" );
				case 0: strcopy( strBotName, 128, "Standard Pyro" );
				case 1: strcopy( strBotName, 128, "Flare Pyro" );
				case 2: strcopy( strBotName, 128, "Pyro Pusher" );
				case 3: strcopy( strBotName, 128, "Fast Scorch Shot" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_DemoMan:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Demoman" );
				case 0: strcopy( strBotName, 128, "Standard Demoman" );
				case 1: strcopy( strBotName, 128, "Burst Fire Demoman" );
				case 2: strcopy( strBotName, 128, "Demoknight" );
				case 3: strcopy( strBotName, 128, "Demo Samurai" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_Heavy:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Heavy" );
				case 0: strcopy( strBotName, 128, "Standard Heavy" );
				case 1: strcopy( strBotName, 128, "Heavyweight Champ" );
				case 2: strcopy( strBotName, 128, "Heater Heavy" );
				case 3: strcopy( strBotName, 128, "Shotgun Heavy" );
				case 4: strcopy( strBotName, 128, "Steel Gauntlet Pusher" );
				case 5: strcopy( strBotName, 128, "Stun Heavy" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_Engineer:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Engineer" );
				case 0: strcopy( strBotName, 128, "Standard Engineer" );
				case 1: strcopy( strBotName, 128, "Standard Engineer" );
				case 2: strcopy( strBotName, 128, "Battle Engineer" );
				case 3: strcopy( strBotName, 128, "Battle Engineer" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Medic:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Medic" );
				case 0: strcopy( strBotName, 128, "Uber Medic" );
				case 1: strcopy( strBotName, 128, "Kritzkrieg Medic" );
				case 2: strcopy( strBotName, 128, "Mega Heal Medic" );
				case 3: strcopy( strBotName, 128, "Shield Medic" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Sniper:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Sniper" );
				case 0: strcopy( strBotName, 128, "Standard Sniper" );
				case 1: strcopy( strBotName, 128, "Bowman" );
				case 2: strcopy( strBotName, 128, "Sydney Sniper" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
		case TFClass_Spy:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Spy" );
				case 0: strcopy( strBotName, 128, "Standard Spy" );
				case 1: strcopy( strBotName, 128, "Dead Ringer Spy" );
				case 2: strcopy( strBotName, 128, "Gentle Spy" );
				case 3: strcopy( strBotName, 128, "Ninja Spy" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
	}
	return strBotName;
}

char GetGiantVariantName(TFClassType TFClass, int botvariant)
{
	char strBotName[128]
	
	switch( TFClass )
	{
		case TFClass_Scout:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Scout" );
				case 0: strcopy( strBotName, 128, "Giant Scout" );
				case 1: strcopy( strBotName, 128, "Super Scout" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
		case TFClass_Soldier:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Soldier" );
				case 0: strcopy( strBotName, 128, "Giant Soldier" );
				case 1: strcopy( strBotName, 128, "Giant Charged Soldier" );
				case 2: strcopy( strBotName, 128, "Giant Rapid Fire Soldier" );
				case 3: strcopy( strBotName, 128, "Giant Burst Fire Soldier" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Pyro:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Pyro" );
				case 0: strcopy( strBotName, 128, "Giant Pyro" );
				case 1: strcopy( strBotName, 128, "Giant Airblast Pyro" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_DemoMan:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Demoman" );
				case 0: strcopy( strBotName, 128, "Giant Rapid Fire Demoman" );
				case 1: strcopy( strBotName, 128, "Giant Rapid Fire Demoman" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_Heavy:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Heavy" );
				case 0: strcopy( strBotName, 128, "Giant Heavy" );
				case 1: strcopy( strBotName, 128, "Giant Deflector Heavy" );
				default: strcopy( strBotName, 128, "Undefined" );
			}		
		}
		case TFClass_Engineer:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Engineer" );
				case 0: strcopy( strBotName, 128, "Standard Engineer" );
				case 1: strcopy( strBotName, 128, "Batsaber Scout" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Medic:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Medic" );
				case 0: strcopy( strBotName, 128, "Giant Medic" );
				case 1: strcopy( strBotName, 128, "Giant Kritzkrieg Medic" );
				default: strcopy( strBotName, 128, "Undefined" );
			}			
		}
		case TFClass_Sniper:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Sniper" );
				case 0: strcopy( strBotName, 128, "Standard Sniper" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
		case TFClass_Spy:
		{
			switch( botvariant )
			{
				case -1: strcopy( strBotName, 128, "Your own Giant Spy" );
				case 0: strcopy( strBotName, 128, "Standard Spy" );
				default: strcopy( strBotName, 128, "Undefined" );
			}
		}
	}
	
	return strBotName;
}

// add attributes to own variants
void SetOwnAttributes(int client , bool bGiant)
{
	if( IsFakeClient(client) )
		return;

	TFClassType TFClass = TF2_GetPlayerClass(client);
	int iWeapon;
	
	if( bGiant )
	{
		switch( TFClass )
		{
			case TFClass_Scout:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1475.0);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.7);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.7);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 5.0);
				return;
			}
			case TFClass_Soldier:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 3600.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 3.0);
				return;
			}
			case TFClass_Pyro:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 2825.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 6.0);
				return;
			}
			case TFClass_DemoMan:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 3125.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.5);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.5);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
				return;
			}
			case TFClass_Heavy:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4700.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.3);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.3);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 2.0);
				return;
			}
			case TFClass_Engineer:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1775.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
				TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
				return;
			}
			case TFClass_Medic:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 4350.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.6);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.6);
				return;
			}
			case TFClass_Sniper:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1275.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
				return;
			}
			case TFClass_Spy:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 1175.0);
				TF2Attrib_SetByName(iWeapon, "move speed bonus", 0.5);
				TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.4);
				TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.4);
				TF2Attrib_SetByName(iWeapon, "override footstep sound set", 4.0);
				return;
			}
		}
	}
	else
	{
		switch( TFClass )
		{
/* 			case TFClass_Scout:
			{
			}
			case TFClass_Soldier:
			{
						
			}
			case TFClass_Pyro:
			{
			
			}
			case TFClass_DemoMan:
			{

			}
			case TFClass_Heavy:
			{
		
			} */
			case TFClass_Engineer:
			{
				iWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 375.0);
				TF2Attrib_SetByName(iWeapon, "cannot pick up buildings", 1.0);
				return;
			}
/* 			case TFClass_Medic:
			{

			}
			case TFClass_Sniper:
			{

			} */
			case TFClass_Spy:
			{
				iWeapon = GetPlayerWeaponSlot(client, 4); // spy invis watch
				TF2Attrib_SetByName(iWeapon, "mult cloak meter regen rate", 4.0); // own spy doesn't have inf cloak
			}
		}
	}
}

void GiveBusterInventory(int client)
{
	if( IsFakeClient(client) )
		return;

	int iWeapon = -1;
	iWeapon = SpawnWeapon( client, "tf_weapon_stickbomb", 307, 1, 6, false );
	TF2Attrib_SetByName(iWeapon, "hidden maxhealth non buffed", 2325.0);
	TF2Attrib_SetByName(iWeapon, "move speed bonus", 1.34);
	TF2Attrib_SetByName(iWeapon, "damage force reduction", 0.5);
	TF2Attrib_SetByName(iWeapon, "airblast vulnerability multiplier", 0.5);
	TF2Attrib_SetByName(iWeapon, "override footstep sound set", 7.0);
	TF2Attrib_SetByName(iWeapon, "cannot be backstabbed", 1.0);
}