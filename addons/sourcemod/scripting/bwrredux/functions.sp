// Extras functions

enum struct GateManager
{
	bool available; // Gatebots are available
	int numgates; // Number of gates
	int gates[6]; // Array with gate entity refs
}

GateManager g_eGateManager;

/**
 * Returns either true or false based on random chance.
 *
 * @param chance        The chance to return true
 * @return				Boolean value
 */
stock bool Math_RandomChance(int chance)
{
	return Math_GetRandomInt(1, 100) <= chance;
}

/**
 * Gets the angle towards the given target
 * 
 * @param source     Source position
 * @param target     Target position
 * @param angles     Angles vector
 */
void GetAngleTorwardsPoint(const float source[3], const float target[3], float angles[3])
{
	float vec[3];
	SubtractVectors(target, source, vec);
	NormalizeVector(vec, vec);
	GetVectorAngles(vec, angles);
}

// Checks if the client is a valid client index
bool IsValidClient(int client)
{
	if(client < 1 || client > MaxClients) { return false; }
	return IsClientInGame(client);
}

// Checks if the current gamemode is MvM
bool IsPlayingMannVsMachine()
{
	return !!GameRules_GetProp("m_bPlayingMannVsMachine");
}

// Checks if the wave is in progress
bool IsMvMWaveRunning()
{
	return GameRules_GetRoundState() == RoundState_RoundRunning;
}

/**
 * Changes the client team and clears them of BWRR related stuff
 *
 * @param client			The client to be moved
 * @param team				The team to move the client to
 */
void TF2BWR_ChangeClientTeam(int client, TFTeam team)
{
	int flag = TF2_GetClientFlag(client);
	
	if(IsValidEntity(flag))
	{
		TF2_ResetFlag(flag);
	}

	RobotPlayer rp = RobotPlayer(client);
	rp.ResetData();
	TF2_ClearClient(client);

	if(team == TFTeam_Blue)
	{
		Director_AddClientToQueue(client);
	}
	else
	{
		Robots_ClearModel(client);
		Robots_ClearScale(client);
		TF2MvM_ChangeClientTeam(client, team);
	}
}

// Changes the client team and bypasses game restrictions.
void TF2MvM_ChangeClientTeam(int client, TFTeam team)
{
	int entityflags = GetEntityFlags(client);
	SetEntityFlags(client, entityflags | FL_FAKECLIENT); // Fake client flag is needed to bypass restrictions
	TF2_ChangeClientTeam(client, team);
	SetEntityFlags(client, entityflags);
}

/**
 * Removes all weapons and attributes from a client
 *
 * @param client			The client to clear weapons and attributes
 * @param removeweapons		Remove weapons?
 * @param removewearables	Remove wearables (cosmetics)?
 */
void TF2_ClearClient(int client, bool removeweapons = true, bool removewearables = true)
{
	if(!IsClientInGame(client) || IsFakeClient(client) || !IsPlayerAlive(client))
		return;

	int entity, owner;

	if(removeweapons)
	{
		entity = -1;
		while((entity = FindEntityByClassname(entity, "tf_wearable_demoshield")) > MaxClients)
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				TF2_RemoveWearable( client, entity );
				RemoveEntity(entity);
			}
		}
		
		entity = -1;
		while((entity = FindEntityByClassname(entity, "tf_wearable_razorback")) > MaxClients)
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				TF2_RemoveWearable(client, entity);
				RemoveEntity(entity);
			}
		}

		RemoveAllWeapons(client);
	}

	if(removewearables)
	{
		entity = -1;
		while((entity = FindEntityByClassname(entity, "tf_wearable")) > MaxClients)
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				TF2_RemoveWearable(client, entity);
				RemoveEntity(entity);
			}
		}

		entity = -1;
		while((entity = FindEntityByClassname(entity, "tf_powerup_bottle")) > MaxClients)
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client) 
			{
				RemoveEntity(entity);
			}
		}
		
		entity = -1;
		while((entity = FindEntityByClassname(entity, "tf_usableitem")) > MaxClients)
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client) 
			{
				RemoveEntity(entity);
			}
		}
	}

	TF2Attrib_RemoveAll(client);
	TF2Attrib_ClearCache(client);
}

void RemoveAllWeapons(int client)
{
	int entity;
	for(int i = 0; i <= TFWeaponSlot_Item2; i++)
	{
		entity = TF2Util_GetPlayerLoadoutEntity(client, i, true);
		if(entity != -1) 
		{
			if(TF2Util_IsEntityWearable(entity)) 
			{
				TF2_RemoveWearable(client, entity);
			}
			else 
			{
				RemovePlayerItem(client, entity);
			}

			RemoveEntity(entity);
		}
	}
}

/**
 * Forces a client to pick up a flag
 *
 * @param client	The client to give the flag to
 * @param flag		The flag entity to give to the client
 * @return     no return
 */
void TF2_PickUpFlag(int client, int flag)
{
	SDKCall(g_hSDKPickupFlag, flag, client, true);
}

/**
 * Forces a flag to reset
 *
 * @param flag		The flag entity index to reset
 * @return     no return
 */
void TF2_ResetFlag(int flag)
{
	if(IsValidEntity(flag))
	{
		AcceptEntityInput(flag, "ForceReset");
	}
}

/**
 * Gets the MvM bomb hatch world position
 *
 * @param update	Send true to update the cached value.
 * @return     origin vector
 */
stock float[] TF2_GetBombHatchPosition(bool update = false)
{
	static float origin[3];
	
	if(update)
	{
		int i = -1;
		while ((i = FindEntityByClassname(i, "func_capturezone")) != -1)
		{
			GetEntityWorldCenter(i, origin);
		}
		
		return origin;
	}
	else
	{
		return origin;
	}
}

// checks if a player is giant
bool TF2_IsGiant(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsMiniBoss"));
}

void CollectValidSpawnPoints(int client, ArrayList spawns)
{
	int entity;
	float origin[3];

	while((entity = FindEntityByClassname(entity, "info_player_teamspawn")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue) && GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
			// To-do: Add nav mesh validation
			if(IsSafeAreaToTeleport(client, origin))
			{
				spawns.Push(entity);
			}
		}
	}
}

/**
 * Performs a trace hull to check if it's safe to teleport (client won't get stuck)
 *
 * @param client			The client to get the bounds from
 * @param origin			The origin to test
 * @return					TRUE if the area is safe
 */
bool IsSafeAreaToTeleport(int client, float origin[3])
{
	Handle trace = null;
	float mins[3], maxs[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", mins);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", maxs);
	trace = TR_TraceHullFilterEx(origin, origin, mins, maxs, MASK_PLAYERSOLID, TraceFilter_IgnorePlayers);
	bool result = TR_DidHit(trace);
	delete trace;
	return !result;
}

// code from Pelipoika's bot control
// executes a fake command with a delay between executions
bool FakeClientCommandThrottled(int client, const char[] command)
{
	if(g_flNextCommand[client] > GetGameTime())
		return false;
	
	FakeClientCommand(client, command);
	
	g_flNextCommand[client] = GetGameTime() + 0.4;
	
	return true;
}

void TF2BWR_DeployBomb(int client)
{
	RobotPlayer rp = RobotPlayer(client);
	float time = FindConVar("tf_deploying_bomb_time").FloatValue + 0.5;
	float origin[3], hatch[3], result[3], angles[3];

	GetClientAbsOrigin(client, origin);
	hatch = TF2_GetBombHatchPosition(true);
	SubtractVectors(hatch, origin, result);
	NormalizeVector(result, result);
	GetVectorAngles(result, angles);
	angles[0] = 0.0;
	angles[2] = 0.0;
	TeleportEntity(client, NULL_VECTOR, angles, {0.0, 0.0, 0.0});
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
	TF2_PlaySequence(client, "primary_deploybomb");
	TF2_AddCondition(client, TFCond_FreezeInput, time);
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");	
	RequestFrame(Frame_DisableAnimation, GetClientSerial(client));

	switch(rp.type)
	{
		case BWRR_RobotType_Boss, BWRR_RobotType_Giant:
		{
			EmitGameSoundToAll("MVM.DeployBombSmall", client, SND_NOFLAGS, _, origin);
		}
		default:
		{
			EmitGameSoundToAll("MVM.DeployBombGiant", client, SND_NOFLAGS, _, origin);
		}
	}
}

void TF2BWR_CancelDeployBomb(int client)
{
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	TF2_RemoveCondition(client, TFCond_FreezeInput);
}

void TF2BWR_TriggerBombHatch(int client)
{
	int entity = FindEntityByClassname(-1, "func_capturezone");
	LogAction(client, -1, "\"%L\" deployed the bomb.", client);
	PrintToChatAll("%N deployed the bomb!", client);
	if(entity != -1)
	{
		FireEntityOutput(entity, "OnCapture", entity);
		FireEntityOutput(entity, "OnCapTeam2", entity);
	}
	else
	{
		ThrowError("Could not find func_capturezone");
	}
}

/*void CollectEngineerHints(int client, ArrayList hints)
{
	int entity;
	float origin[3];

	while((entity = FindEntityByClassname(entity, "bot_hint_engineer_nest")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
			if(IsSafeAreaToTeleport(client, origin))
			{
				hints.Push(entity);
			}
		}
	}	
}*/

/**
 * Gets a random client from the given team
 * 
 * @param team      The client team
 * @param alive     Exclude dead players
 * @param bots      Should bots be included
 * @param inspawn   Exlude players inside spawn
 * @return          Client index or 0 if not found
 */
int GetRandomClientFromTeam(int team, bool alive = false, bool bots = false, bool inspawn = false)
{
	int counter;
	int[] players = new int[MaxClients + 1];

	for(int i = 1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;

		if(GetClientTeam(i) != team)
			continue;

		if(!bots && IsFakeClient(i))
			continue;

		if(alive && !IsPlayerAlive(i))
			continue;

		if(inspawn)
		{
			float origin[3];
			GetClientAbsOrigin(i, origin);
			if(TF2Util_IsPointInRespawnRoom(origin, i, true)) {
				continue;
			}
				
		}
		
		players[counter] = i;
		counter++;
	}

	if(counter == 0) { return 0; }
	return players[Math_GetRandomInt(0, counter - 1)];
}

/**
 * Performs a simple Trace Ray between start and end positions
 * 
 * @param start     The start position
 * @param end       The end position
 * @return          TRUE if there is an obstruction between the start and end positions
 */
bool CheckLOSSimpleTrace(float start[3], float end[3])
{
	Handle trace = null;
	trace = TR_TraceRayFilterEx(start, end, MASK_SHOT, RayType_EndPoint, TraceFilter_LOS);
	bool hit = TR_DidHit(trace);
	delete trace;

	return hit;
}

/**
 * Collects nearby nav areas and place them by ID in an ArrayList
 * 
 * @param areas       ArrayList to store the NAV areas IDs
 * @param origin      The point to get the starting area
 * @param maxdist     Maximum distance to collect
 * @param maxup       Maximum step height
 * @param maxdown     Maximum drop down height limit
 * @return            TRUE if successfully collected
 */
bool CollectNavAreas(ArrayList areas, const float origin[3], float maxdist, float maxup, float maxdown)
{
	CNavArea start = TheNavMesh.GetNearestNavArea(origin, false, 512.0);

	if(start == NULL_AREA)
	{
		return false;
	}

	SurroundingAreasCollector collector = TheNavMesh.CollectSurroundingAreas(start, maxdist, maxup, maxdown);

	for(int i = 0;i < collector.Count(); i++)
	{
		CNavArea navarea = collector.Get(i);
		areas.Push(navarea.GetID());
	}

	delete collector;
	return true;
}

/**
 * Filters the NAV areas from the ArrayList using Trace Hull to check if the given client won't get stuck.
 * 
 * @param areas      ArrayList containing NAV areas ID
 * @param client     Client index
 */
void FilterNavAreasByTrace(ArrayList areas, int client)
{
	CNavArea navarea;
	float center[3];

	for(int i = 0;i < areas.Length;i++)
	{
		navarea = TheNavMesh.GetNavAreaByID(areas.Get(i));
		navarea.GetCenter(center);
		center[2] += 15.0; // add a bit of height

		if(!IsSafeAreaToTeleport(client, center))
		{
			areas.Erase(i);
		}
	}
}

void FilterNavAreasByLOS(ArrayList areas, TFTeam team)
{
	CNavArea navarea;
	float center[3], angles[3], origin[3], fwd[3], eyes[3];

	for(int i = 0;i < areas.Length;i++)
	{
		navarea = TheNavMesh.GetNavAreaByID(areas.Get(i));
		navarea.GetCenter(center);
		center[2] += 15.0; // add a bit of height

		for(int client = 1;client <= MaxClients;client++)
		{
			if(!IsClientInGame(client))
				continue;

			if(!IsPlayerAlive(client))
				continue;

			if(TF2_GetClientTeam(client) != team)
				continue;

			GetClientAbsOrigin(client, origin);
			GetClientEyeAngles(client, angles);
			GetClientEyePosition(client, eyes);
			GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);

			if(PointWithinViewAngle(origin, center, fwd, GetFOVDotProduct(140.0))) // Check if within view angles
			{
				if(!CheckLOSSimpleTrace(eyes, center)) // Check for obstruction
				{
					areas.Erase(i);
				}
			}
		}
	}
}

/**
 * Filters NAV area by distance
 * 
 * @param areas      ArrayList containing NAV areas ID
 * @param source     Position vector to compare distance
 * @param min        Minimum distance
 * @param max        Maximum distance
 */
void FilterNavAreasByDistance(ArrayList areas, const float source[3], const float min, const float max)
{
	CNavArea navarea;
	float center[3], distance;

	for(int i = 0;i < areas.Length;i++)
	{
		navarea = TheNavMesh.GetNavAreaByID(areas.Get(i));
		navarea.GetCenter(center);
		center[2] += 15.0; // add a bit of height

		distance = GetVectorDistance(center, source);

		if(distance < min)
		{
			areas.Erase(i);
		}
		else if(distance > max)
		{
			areas.Erase(i);
		}
	}
}

/**
 * Filters NAV areas inside spawn rooms
 * 
 * @param areas                   ArrayList containing NAV areas
 * @param entity                  An optional entity to check.
 * @param bRestrictToSameTeam     Whether or not the respawn room must either match the entity's
 *                                team, or not be assigned to a team.  Always treated as true if
 *                                the position is in an active spawn room.  Has no effect if no
 *                                entity is provided.
 */
void FilterNavAreasBySpawnRoom(ArrayList areas, const int entity = INVALID_ENT_REFERENCE, const bool bRestrictToSameTeam = false)
{
	CNavArea navarea;
	float center[3];
	float points[4][3];

	for(int i = 0;i < areas.Length;i++)
	{
		navarea = TheNavMesh.GetNavAreaByID(areas.Get(i));
		navarea.GetCenter(center);
		center[2] += 15.0; // add a bit of height

		navarea.GetCorner(NORTH_WEST, points[0]);
		navarea.GetCorner(NORTH_EAST, points[1]);
		navarea.GetCorner(SOUTH_WEST, points[2]);
		navarea.GetCorner(SOUTH_EAST, points[3]);

		for(int y = 0;y < sizeof(points);y++)
		{
			points[y][2] += 15.0; // add a bit of height
		}

		if(TF2Util_IsPointInRespawnRoom(center, entity, bRestrictToSameTeam))
		{
			areas.Erase(i);
			continue;
		}

		for(int y = 0;y < sizeof(points);y++)
		{
			if(TF2Util_IsPointInRespawnRoom(points[y], entity, bRestrictToSameTeam))
			{
				areas.Erase(i);
				break;
			}
		}
	}
}

int CollectBombs(ArrayList bombs, const int team)
{
	int entity = INVALID_ENT_REFERENCE;
	int counter = 0;

	while((entity = FindEntityByClassname(entity, "item_teamflag")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == team && GetEntProp(entity, Prop_Send, "m_bDisabled") == 0)
		{
			bombs.Push(EntIndexToEntRef(entity));
			counter++;
		}
	}

	return counter;
}

/**
 * Filters the bomb by distance to the bomb hatch
 * 
 * @param bombs        ArrayList containg a bomb list as entity references
 * @param distance     Distance between the closest bomb and the bomb hatch
 * @return             The closest bomb entity index
 */
int FilterBombClosestToHatch(ArrayList bombs, float &distance)
{
	int entity = INVALID_ENT_REFERENCE, best = INVALID_ENT_REFERENCE;
	float short = 999999.0, search;
	float hatch[3], origin[3];
	hatch = TF2_GetBombHatchPosition(true);

	for(int i = 0; i < bombs.Length;i++)
	{
		entity = EntRefToEntIndex(bombs.Get(i));

		if(entity == INVALID_ENT_REFERENCE)
			continue;

		TF2_GetFlagPosition(entity, origin);

		search = GetVectorDistance(origin, hatch);

		if(search < short)
		{
			short = search;
			distance = search;
			best = entity;
		}
	}

	return best;
}

/**
 * Checks if there are RED owned control points in the map.
 * 
 * @return     TRUE if there are RED owned control points
 */
bool CheckForREDOwnedControlPoints()
{
	int ent = -1;

	while((ent = FindEntityByClassname(ent, "team_control_point")) != -1)
	{
		if(IsValidEntity(ent))
		{
			if(GetEntProp(ent, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
			{
				return true;
			}
		}
	}

	return false;
}

void GateManager_Clear()
{
	g_eGateManager.available = false;
	g_eGateManager.numgates = 0;

	for(int i = 0; i < sizeof(g_eGateManager.gates);i++)
	{
		g_eGateManager.gates[i] = INVALID_ENT_REFERENCE;
	}
}

void GateManager_Update()
{
	g_eGateManager.available = CheckForREDOwnedControlPoints();

	int ent = INVALID_ENT_REFERENCE;

	while((ent = FindEntityByClassname(ent, "team_control_point")) != INVALID_ENT_REFERENCE)
	{
		g_eGateManager.gates[g_eGateManager.numgates] = EntIndexToEntRef(ent);
		g_eGateManager.numgates++;

		if(g_eGateManager.numgates == sizeof(g_eGateManager.gates))
			break;
	}
}

Action Timer_CheckGates(Handle timer)
{
	GateManager_Clear();
	GateManager_Update();
	return Plugin_Stop;
}

void RemoveAllObjectsFromClient(int client)
{
	int entity = INVALID_ENT_REFERENCE;
	while((entity = FindEntityByClassname(entity, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
		{
			RemoveSingleObjectFromClient(client, entity);
		}
	}

	entity = INVALID_ENT_REFERENCE;
	while((entity = FindEntityByClassname(entity, "obj_dispenser")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
		{
			RemoveSingleObjectFromClient(client, entity);
		}
	}

	entity = INVALID_ENT_REFERENCE;
	while((entity = FindEntityByClassname(entity, "obj_teleporter")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
		{
			RemoveSingleObjectFromClient(client, entity);
		}
	}
}

void RemoveSingleObjectFromClient(int client, int obj)
{
	SetEntityOwner(obj, INVALID_ENT_REFERENCE);
	TF2_SetBuilder(obj, INVALID_ENT_REFERENCE);
	TF2_RemoveObject(client, obj);
}

/*----------------------------------------------
-----------------TRACE FILTERS------------------
----------------------------------------------*/

// Trace filter that ignores all clients/players
bool TraceFilter_IgnorePlayers(int entity, int contentsMask)
{
	if(entity > 0 && entity <= MaxClients)
	{
		return false;
	}

	return true;
}

bool TraceFilter_LOS(int entity, int contentsMask)
{
	if(entity > 0 && entity <= MaxClients)
	{
		return false;
	}

	char classname[64];
	GetEntityClassname(entity, classname, sizeof(classname));

	if(StrContains("obj_", classname, false) != -1) { return false; }
	if(strcmp("tank_boss", classname, false) == 0) { return false; }

	return true;	
}

/*----------------------------------------------
------------REQUESTFRAME CALLBACKS--------------
----------------------------------------------*/

// code from Pelipoika's bot control
// Updates the bomb level show on the HUD
void Frame_UpdateBombHUD(int serial)
{
	int client = GetClientFromSerial(serial);

	if(client)
	{
		RobotPlayer rp = RobotPlayer(client);
		int entity = FindEntityByClassname(-1, "tf_objective_resource");
		SetEntProp(entity, Prop_Send, "m_nFlagCarrierUpgradeLevel", rp.bomblevel);
		SetEntPropFloat(entity, Prop_Send, "m_flMvMBaseBombUpgradeTime", rp.inspawn ? -1.0 : GetGameTime());
		SetEntPropFloat(entity, Prop_Send, "m_flMvMNextBombUpgradeTime", rp.inspawn ? -1.0 : rp.nextbombupgradetime);
	}
}

void Frame_RemoveReviveMaker(int entref)
{
	int ent = EntRefToEntIndex(entref);
	if(ent == INVALID_ENT_REFERENCE)
		return;
		
	int team = GetEntProp(ent, Prop_Send, "m_iTeamNum");
	if(team != 3)
		return;
		
	RemoveEntity(ent);
}

void Frame_RemoveAmmoPack(int entref)
{
	int ent = EntRefToEntIndex(entref);
	if(ent == INVALID_ENT_REFERENCE)
		return;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	
	if(IsValidClient(owner) && GetClientTeam(owner) == 3)
	{
		RemoveEntity(ent);
	}	
}

// code from Pelipoika's bot control
void Frame_DisableAnimation(int serial)
{
	static int count = 0;

	int client = GetClientFromSerial(serial);

	if(client)
	{
		if(count > 6)
		{
			float vecClientPos[3], vecTargetPos[3];
			GetClientAbsOrigin(client, vecClientPos);
			vecTargetPos = TF2_GetBombHatchPosition();
			float v[3], ang[3];
			SubtractVectors(vecTargetPos, vecClientPos, v);
			NormalizeVector(v, v);
			GetVectorAngles(v, ang);
			ang[0] = 0.0;
			SetVariantString("1");
			AcceptEntityInput(client, "SetCustomModelRotates");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
			char strVec[16];
			Format(strVec, sizeof(strVec), "0 %f 0", ang[1]);
			SetVariantString(strVec);
			AcceptEntityInput(client, "SetCustomModelRotation");
			count = 0;
		}
		else
		{
			TF2_PlaySequence(client, "primary_deploybomb");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
			RequestFrame(Frame_DisableAnimation, serial);
			count++;
		}
	}
	else
	{
		count = 0;
	}
}