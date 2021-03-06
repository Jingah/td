--[[
	Author: Jingah
	Date: 16.02.2015
	
	Credits to MNoya for Lumber UI
	Credits to Myll & MNoya for BuildingHelper
]]

print ('[BAYUSTD] bayustd.lua' )


----------------

ENABLE_HERO_RESPAWN = false              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 30.0                  -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 30.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 1.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                   	-- How much gold should players get per tick?
GOLD_TICK_TIME = 5                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1600       -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 100                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

STARTING_LUMBER = 300

BAYUSTD_VERSION = "Alpha Version"
DEBUG = false

OutOfWorldVector = Vector(9000,9000,-100)

-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')
if not DEBUG then
  statcollection.addStats({
	modID = 'ee0861abca4ad04ca3f273586e0f453b' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
  })
end

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[1] = 0
for i=2,MAX_LEVEL do
	XP_PER_LEVEL_TABLE[i] = i * (i-1) * 500 /2
end

-- Generated from template
if bayustd == nil then
	print ( '[BAYUSTD] creating bayustd game mode' )
	bayustd = class({})
end


--[[
This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
If this occurs it causes the client to never precache things configured in that block.
In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
defined on the unit.
This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
time, you can call the functions individually (for example if you want to precache units in a new wave of
holdout).
]]
function bayustd:PostLoadPrecache()
		print("[BAYUSTD] Performing Post-Load precache")
		--PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
It can be used to initialize state that isn't initializeable in Initbayustd() but needs to be done before everyone loads in.
]]
function bayustd:OnFirstPlayerLoaded()
	print("[BAYUSTD] First Player has loaded")
	CreateUnitByName("npc_dota_fountain", Vector(-6784,4352,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
	AppendToLogFile("log/bayustd.txt", "First player loaded\n")
end

--[[
This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)

function bayustd:OnAllPlayersLoaded()
	print("[BAYUSTD] All Players have loaded into the game")
	-- Reassign all the players to the Radiant Team
	AppendToLogFile("log/bayustd.txt", "All Players loaded (" .. GameRules.TOTAL_PLAYERS .. " Players)\n")
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer(nPlayerID) and not PlayerResource:IsBroadcaster(nPlayerID) then
			if PlayerResource:GetTeam(nPlayerID) ~= DOTA_TEAM_GOODGUYS then
				PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS )
			end
		end
	end
end]]

-- An NPC has spawned somewhere in game.  This includes heroes
function bayustd:OnNPCSpawned(keys)
	--print("[bayustd] NPC Spawned")
	--PrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:GetUnitName() == "npc_boss2_add" then
		npc:SetRenderColor(0,255,0)
	elseif npc:GetUnitName() == "npc_boss2_buffer" then
		npc:SetRenderColor(0,0,255)
	elseif npc:GetUnitName() == "npc_dota_ghost" then
		bayustd:giveUnitDataDrivenModifier(npc, npc, "modifier_phased", -1)
	end
	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		return
	end
	
	local name = npc:GetUnitName()
	local unit_table = GameRules.UnitKV[name]
	if unit_table ~= nil then
		isHeroBuilding = unit_table.isHeroBuilding
	else
		isHeroBuilding = 0
	end

	if isHeroBuilding ~= nil and isHeroBuilding == 1 then
		bayustd:giveUnitDataDrivenModifier(npc, npc, "modifier_hero_building", -1)
	end
end

-- The overall game state has changed
function bayustd:OnPlayerPickHero(keys)
	print("Player picked hero")
	--DeepPrintTable(keys)
	
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()

	if GameRules.builders[playerID+1] ~= 0 then
		return
	end

	local point =  Entities:FindByName( nil, "builder_spawns" .. playerID):GetAbsOrigin()
	
	--ShowGenericPopupToPlayer(player, "#popup_title", "#popup_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	
	-- This line for example will set the starting gold of every hero to 500 unreliable gold
	hero:SetGold(500, false)
	
	GameRules.PLAYERS_PICKED = GameRules.PLAYERS_PICKED + 1

	if GameRules.PLAYERS_PICKED == GameRules.TOTAL_PLAYERS then 
		self:OnEveryonePicked()
	end
	
	--TODO: Ensure correct Builder
	local number = RandomInt(1, 3)
	local builder = CreateUnitByName("npc_dota_builder" .. number, point, true, nil, nil, DOTA_TEAM_GOODGUYS)
	builder:SetOwner(hero)
	builder:SetControllableByPlayer(playerID, true)
	bayustd:giveUnitDataDrivenModifier(builder, builder, "modifier_protect_builder", -1)
	GameRules.builders[playerID+1] = builder
	CheckAbilityRequirements( builder, player )
end

function bayustd:OnEveryonePicked()
    GameRules:SendCustomMessage("Welcome to <font color='#2EFE2E'>Bayus TD!</font>", 0, 0)
    GameRules:SendCustomMessage("Created by <font color='#2EFE2E'>Jingah</font>", 0, 0)
	GameRules:SendCustomMessage("Idea from original Warcraft 3 Map",0,0)
    GameRules:SendCustomMessage("Version: " .. BAYUSTD_VERSION, 0, 0)
    GameRules:SendCustomMessage("Please report bugs and leave feedback on our workshop page", 0, 0)
	GameRules:SendCustomMessage("Creeps spawning in " .. PRE_GAME_TIME .. " seconds!" , 0, 0)
	bayustd:StartCountdownQuest(PRE_GAME_TIME)
end

mode = nil

-- This function is called as the first player loads and sets up the bayustd parameters
function bayustd:CaptureBayusTD()
	if mode == nil then
		-- Set bayustd parameters
		mode = GameRules:GetGameModeEntity()
		mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
		mode:SetLoseGoldOnDeath(false)
		GameRules:SetStrategyTime(0)
		GameRules:SetShowcaseTime(0)

		--mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

		self:OnFirstPlayerLoaded()
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function bayustd:OnConnectFull(keys)
	--print ('[bayustd] OnConnectFull')
	--PrintTable(keys)
	bayustd:CaptureBayusTD()
	
	GameRules.TOTAL_PLAYERS = GameRules.TOTAL_PLAYERS + 1

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	-- Update the user ID table with this user
	self.vUserIds[keys.userid] = ply

	-- Update the Steam ID table
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		self.vBroadcasters[keys.userid] = 1
		return
	end
end

-- A player leveled up an ability
function bayustd:OnPlayerLearnedAbility( keys)
	--print ('[BAYUSTD] OnPlayerLearnedAbility')
	--PrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- An ability was used by a player
function bayustd:OnAbilityUsed(keys)
	--print('[BAYUSTD] AbilityUsed')
	--PrintTable(keys)

	local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname
	
	AppendToLogFile("log/bayustd.txt", "Player " .. PlayerResource:GetPlayerName(keys.PlayerID) .. " used an ability: " .. abilityname .. "\n")

	-- Cancel the ghost if the player casts another active ability.
	-- Start of BH Snippet:
	if player.cursorStream ~= nil then
		if not (string.len(abilityname) > 14 and string.sub(abilityname,1,14) == "move_to_point_") then
			if not DontCancelBuildingGhostAbils[abilityname] then
				player:CancelGhost()
			else
				print(abilityname .. " did not cancel building ghost.")
 			end
 		end
 	end
	-- End of BH Snippet
end

-- Cleanup a player when they leave
function bayustd:OnDisconnect(keys)
	print('[bayustd] Player Disconnected ' .. tostring(keys.userid))
	--PrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
	AppendToLogFile("log/bayustd.txt", "Playerid " .. userid .. " disconnected. Reason: " .. reason .. "\n")
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function bayustd:OnPlayerReconnect(keys)
	local plyID = keys.PlayerID
	local player = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " reconnected.")
	local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
	if GameRules.lumbersList[plyID+1] ~= nil then
		CustomGameEventManager:Send_ServerToPlayer(player, "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[plyID+1] })
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[plyID+1] })
	end
end

-- An item was picked up off the ground
--[[function bayustd:OnItemPickedUp(keys)
	print ( '[DOTACRAFT] OnItemPickedUp' )
	--DeepPrintTable(keys)

	local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local hero = player:GetAssignedHero()
	local itemname = keys.itemname
end]]

-- An item was purchased by a player
function bayustd:OnItemPurchased( keys )
	print ( '[DOTACRAFT] OnItemPurchased' )
	--DeepPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	local player = PlayerResource:GetPlayer(plyID)
	
	-- The name of the item purchased
	local itemName = keys.itemname 

	-- The cost of the item purchased
	local itemcost = keys.itemcost
	
	local hero = player:GetAssignedHero()
	
	AppendToLogFile("log/bayustd.txt", "Player " .. PlayerResource:GetPlayerName(plyID) .. " purchased a new Item: " .. itemName .. " for " .. itemcost .. " gold\n")
end


-- The overall game state has changed
function bayustd:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		GameRules.lumbersList = {}
		GameRules.deadList = {}
		GameRules.ghostsList = {}
		GameRules.buildings = {}
		GameRules.builders = {}
		GameRules.buildingEntities = {}
		for nPlayerID = 0, 9 do
			if DEBUG then
				table.insert(GameRules.lumbersList, 90000)
			else
				table.insert(GameRules.lumbersList, STARTING_LUMBER)
			end
			table.insert(GameRules.deadList, 0)
			table.insert(GameRules.ghostsList, 0)
			table.insert(GameRules.buildings, {})
			table.insert(GameRules.builders, 0)
			table.insert(GameRules.buildingEntities, {})
		end
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer({
	    	endTime = 2,
	    	callback = function()
	    		for nPlayerID = 0, 9 do
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID), "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[nPlayerID+1] })
				end
	    	end
	 	})
	end
end

creepsCount = 0
wave = 1

-- An entity died
function bayustd:OnEntityKilled( keys )
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	
	if killedUnit:IsSummoned() then
		return
	end
	
	local killerEntity = nil
	
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	if killedUnit:IsOwnedByAnyPlayer() then
		pID = killedUnit:GetPlayerOwnerID()
	else
		pID = killerEntity:GetPlayerOwnerID()
	end
	local player = PlayerResource:GetPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	if hero == nil then
		hero = player:GetAssignedHero()
	end
	
	if killedUnit:IsRealHero() then
		if(killedUnit:IsReincarnating()) then
			Timers:CreateTimer(3.0, function()
				killedUnit:RespawnHero(false, false, false)
			end
			)
		else
			GameRules.DEAD_PLAYER_COUNT = GameRules.DEAD_PLAYER_COUNT + 1
			if GameRules.DEAD_PLAYER_COUNT == GameRules.TOTAL_PLAYERS then
				local messageinfo = { message = "YOU FAILED", duration = 5}
				FireGameEvent("show_center_message",messageinfo)
				bayustd:Endgame(false)
				return
			end
			GameRules:SendCustomMessage("<font color='#58ACFA'>" .. PlayerResource:GetPlayerName(pID) .. "</font> just died. He will be punished by sending to the graveyard for 2 rounds. DON'T DIE!", 0, 0)
			GameRules.deadList[pID+1] = 1
			local point = Entities:FindByName( nil, "graveyard_pos0" ):GetAbsOrigin()
			GameRules.ghostsList[pID+1] = CreateUnitByName("npc_dota_ghost", point, true, nil, nil, DOTA_TEAM_GOODGUYS)
			GameRules.ghostsList[pID+1]:SetOwner(hero)
			GameRules.ghostsList[pID+1]:SetControllableByPlayer(pID, true)
			bayustd:giveUnitDataDrivenModifier(GameRules.ghostsList[pID+1], GameRules.ghostsList[pID+1], "modifier_protect_builder", -1)
			AppendToLogFile("log/bayustd.txt", "Player " .. PlayerResource:GetPlayerName(pID) .. " died.\n")
		end
	end
	
	if killedUnit:GetUnitName() == "npc_dota_wave20" then
		ScreenShake(killerEntity:GetAbsOrigin(), 50.0, 50.0, 5.0, 9000, 0, true)
		PlayerResource:SetCameraTarget(killerEntity:GetPlayerOwnerID(), killedUnit)
		EmitGlobalSound("diretide_roshdeath_Stinger")
		GameRules:SendCustomMessage("<br>BEHOLD HEROES!!<br>You defeated your town.",0,0)
		local messageinfo = { message = "YOU DEFEATED", duration = 5}
		FireGameEvent("show_center_message",messageinfo)
		bayustd:Endgame(true)
		return
	end
	
	if killedUnit:GetTeam() == DOTA_TEAM_NEUTRALS then
		local name = killedUnit:GetUnitName()
		local unit_table = GameRules.UnitKV[name]
		local bountyLumber = unit_table.BountyLumber
		local playerKills = PlayerResource:GetKills(pID)
		
		AppendToLogFile("log/bayustd.txt", "Player " .. PlayerResource:GetPlayerName(pID) .. " killed a unit: " .. name .. ". His hero has now " .. hero:GetLastHits() .. " lasthits.\n")
		
		if bountyLumber > 0 then
			--player.lumber = player.lumber + bountyLumber
			GameRules.lumbersList[pID+1] = GameRules.lumbersList[pID+1] + bountyLumber
			--print("Lumber Gained. " .. hero:GetUnitName() .. " is currently at " .. player.lumber)
			CustomGameEventManager:Send_ServerToPlayer(player, "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[pID+1] })
			PopupLumber(player, killedUnit, bountyLumber)
		end
		
		if name == "npc_dota_wave10" then
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:HasSelectedHero(nPlayerID) then
					local goldBounty = PlayerResource:GetReliableGold(nPlayerID) + 2500				
					PlayerResource:SetGold(nPlayerID, goldBounty, true)
					PlayerResource:IncrementKills(pID, playerKills + 1)
				end
			end
		elseif name == "npc_dota_wave20" then
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:HasSelectedHero(nPlayerID) then
					local goldBounty = PlayerResource:GetReliableGold(nPlayerID) + 4500
					PlayerResource:SetGold(nPlayerID, goldBounty, true)
					PlayerResource:IncrementKills(pID, playerKills + 1)
				end
			end
		elseif name == "npc_dota_wave30" then -- not implemented yet
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:HasSelectedHero(nPlayerID) then
					local goldBounty = PlayerResource:GetReliableGold(nPlayerID) + 6500
					PlayerResource:SetGold(nPlayerID, goldBounty, true)
					PlayerResource:IncrementKills(pID, playerKills + 1)
				end
			end
		end
		
		creepsCount = creepsCount - 1
	
		if bayustd:getRemovedCreeps() == bayustd:getCreeps() then
			print("all creeps teleproted")
			for d = 1, bayustd:getRemovedCreeps(), 1 do
				if bayustd:getWave() % 10 ~= 0 then
					CreateUnitByName(name, bayustd:RandomSpawnPosition(), true, nil, nil, DOTA_TEAM_NEUTRALS)
				end
			end
			GameRules:SendCustomMessage("<font color='#FF0000'>" .. bayustd:getRemovedCreeps() .. "</font> creeps entered the town!", 0, 0)
		end
		
		if creepsCount == 0 then
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:IsValidPlayerID(nPlayerID) then
					if GameRules.deadList[nPlayerID+1] ~= 0 then
						if GameRules.deadList[nPlayerID+1] == 3 then
							GameRules.ghostsList[nPlayerID+1]:RemoveSelf()
							GameRules.ghostsList[nPlayerID+1] = 0
							PlayerResource:GetSelectedHeroEntity(nPlayerID):RespawnHero(false, false, false)
							GameRules.deadList[nPlayerID+1] = 0
							GameRules.DEAD_PLAYER_COUNT = GameRules.DEAD_PLAYER_COUNT - 1
						else
							GameRules.deadList[nPlayerID+1] = GameRules.deadList[nPlayerID+1] + 1
						end
					end
					GameRules.lumbersList[nPlayerID+1] = GameRules.lumbersList[nPlayerID+1] + 100
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID), "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[nPlayerID+1] })
					
					local goldBounty = PlayerResource:GetReliableGold(nPlayerID) + 100
					PlayerResource:SetGold(nPlayerID, goldBounty, true)
				end
			end
			AppendToLogFile("log/bayustd.txt", "Wave " .. wave .. " finished\n")
			wave = wave + 1
			print("All creeps are dead")
			bayustd:setRemovedCreeps(0)
			GameRules:SendCustomMessage("Creeps spawning in 20 seconds!" , 0, 0)

			bayustd:StartCountdownQuest(20)
		end
	end
end

function bayustd:StartCountdownQuest(totalTime) 
	Timers:CreateTimer({
    	endTime = totalTime,
    	callback = function()
			bayustd:SpawnCreeps()
    	end
 	})
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function bayustd:Initbayustd()
	bayustd = self
	print('[BAYUSTD] Starting to load bayustd gamemode...')

	-- Setup rules
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetPreGameTime( PRE_GAME_TIME)
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled(true)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	
	print('[BAYUSTD] GameRules set')
	
	GameRules.PLAYERS_PICKED = 0
	GameRules.TOTAL_PLAYERS = 0
	GameRules.DEAD_PLAYER_COUNT = 0
	
	InitLogFile("log/bayustd.txt", "")
	AppendToLogFile("log/bayustd.txt", "BayusTD starting ...\n")


	---------------------------------------------------------------------------
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( bayustd, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(bayustd, 'OnDisconnect'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(bayustd, 'OnPlayerPickHero'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(bayustd, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(bayustd, 'OnAbilityUsed'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(bayustd, 'OnNPCSpawned'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(bayustd, 'OnConnectFull'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(bayustd, 'OnEntityKilled'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(bayustd, 'OnItemPurchased'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(bayustd, 'OnPlayerReconnect'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(bayustd, 'OnPlayerSay'), self)
	
	GameRules:GetGameModeEntity():SetThink("OnGraveyardThink", self, 60)
	GameRules:GetGameModeEntity():SetThink("SetPermanentDaytime", self)

	-- Full units file to get the custom values
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	GameRules.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")
	GameRules.Roundinfo = LoadKeyValues("scripts/kv/round_info.kv")
	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	
	GameRules.item = CreateItem( "item_apply_modifiers", nil, nil)

	-- Initialized tables for tracking state
	self.vUserIds = {}
	self.vSteamIds = {}
	self.vBots = {}
	self.vBroadcasters = {}

	self.nRadiantKills = 0
	self.nDireKills = 0	
	print('[BAYUSTD] Done loading bayusTD gamemode!\n\n')
end

-- Disables night
function bayustd:SetPermanentDaytime()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:SetTimeOfDay( 0.3 )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		    		
        -- Delete the thinker
        return
	end
	return 10
end

-- Spawn gold and lumber on the graveyard (every 10 sec)
function bayustd:OnGraveyardThink()
	if GameRules.DEAD_PLAYER_COUNT > 0 then
		gold = CreateItem("item_gold", nil, nil)
		lumber = CreateItem("item_lumber", nil, nil)
		
		CreateItemOnPositionSync(self:RandomGraveyardPosition(), lumber)
		CreateItemOnPositionSync(self:RandomGraveyardPosition(), gold)
		return 35
	end
	return 10
end

function bayustd:giveUnitDataDrivenModifier(source, target, modifier, dur)
    GameRules.item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end

---------------------------------------------------------------------------
-- Get correct Builder for every Hero
---------------------------------------------------------------------------
function bayustd:EnsureCorrectBuilder(hero)
	--TODO
end

---------------------------------------------------------------------------
-- Spawn Creepwaves
---------------------------------------------------------------------------
function bayustd:SpawnCreeps()
	AppendToLogFile("log/bayustd.txt", "Starting round " .. wave .. ", creeps spawning ...\n")
	local waveName = "npc_dota_wave" .. wave
	local info = GameRules.Roundinfo
	if info[waveName] then
		--PrintTable(info[waveName])
		for k,v in pairs(info[waveName]) do
			if k and v then
				GameRules:SendCustomMessage("<font color='#ff0000'>" .. k ..":</font> " .. v, 0, 0)
			end
		end
	end
	print( "Spawning creeps ..." )
	if wave % 10 ~= 0 then
		for i = 0, 6, 1 do
			local moveLocation = Entities:FindByName( nil, "path_corner_" .. i)
			local spawnLocation = Entities:FindByName( nil, "creep_spawner" .. i):GetAbsOrigin()
			local units = 10
			if(i == 0) then
				units = 20
			end
			for d = 1, units, 1 do
				local unit = CreateUnitByName(waveName, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
				creepsCount = creepsCount + 1
				Timers:CreateTimer(1.0, function()
					unit:SetInitialGoalEntity(moveLocation)
					--ExecuteOrderFromTable({ UnitIndex = unit:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = moveLocation, Queue = false})
					return
				end
				)
			end
		end
	else
		local moveLocation = Entities:FindByName( nil, "path_corner_0")
		local spawnLocation = Entities:FindByName( nil, "creep_spawner0"):GetAbsOrigin()
		local unit = CreateUnitByName(waveName, spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)
		creepsCount = creepsCount + 1
		Timers:CreateTimer(1.0, function()
			unit:SetInitialGoalEntity(moveLocation)
			return
		end
		)
	end
	
	-- Air system workaround
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:HasSelectedHero(nPlayerID) then					
			--local player = PlayerResource:GetPlayer(nPlayerID)
			--PrintTable( player.buildingEntities )
			for i, v in ipairs(GameRules.buildingEntities[nPlayerID+1]) do
				if IsValidEntity(v) then
					if wave % 3 == 0 then 	--air levels. Stop ground towers from attacking
						if v.buildingTable.AttackType ~= 0 then
							v:RemoveModifierByName("modifier_disable_building")
							bayustd:giveUnitDataDrivenModifier(v, v, "modifier_enable_building", -1)
						else
							v:RemoveModifierByName("modifier_enable_building")
							bayustd:giveUnitDataDrivenModifier(v, v, "modifier_disable_building", -1)
						end
					else
						if v.buildingTable.AttackType ~= 1 then
							v:RemoveModifierByName("modifier_disable_building")
							bayustd:giveUnitDataDrivenModifier(v, v, "modifier_enable_building", -1)
						else
							v:RemoveModifierByName("modifier_enable_building")
							bayustd:giveUnitDataDrivenModifier(v, v, "modifier_disable_building", -1)
						end
					end
				end
			end
		end
	end
	return 1 -- Check again later in case more players spawn
end

-- Go through every ability and item and check if the requirements are met
function CheckAbilityRequirements( unit, player )

	local requirements = GameRules.Requirements
	local hero = unit:GetOwner()
	local pID = hero:GetPlayerID()
	--local buildings = player.buildings
	local buildings = GameRules.buildings[pID+1]
	local requirement_failed = false

	-- The disabled abilities end with this affix
	local len = string.len("_disabled")

	for abilitySlot=0,6 do
		local ability = unit:GetAbilityByIndex(abilitySlot)

		-- If the ability exists, check its requirements
		if ability then
			local disabled_ability_name = ability:GetAbilityName()

			-- Check the table of requirements in the KV file
			if requirements[disabled_ability_name] then
				local requirement_count = #requirements[disabled_ability_name]
						
				-- Go through each requirement line and check if the player has that building on its list
				for k,v in pairs(requirements[disabled_ability_name]) do

					-- Look for the building and update counter
					if buildings[k] and buildings[k] > 0 then
						--print("Found at least one "..k)
					else
						requirement_failed = true
						break
					end
				end

				if not requirement_failed then
					-- Cut the _disabled to learn the new ability 
					local ability_len = string.len(disabled_ability_name)
					local ability_name = string.sub(disabled_ability_name, 1 , ability_len - len)

					unit:AddAbility(ability_name)
					unit:SwapAbilities(disabled_ability_name, ability_name, false, true)
					unit:RemoveAbility(disabled_ability_name)

					-- Set the new ability level
					local ability = unit:FindAbilityByName(ability_name)
					ability:SetLevel(ability:GetMaxLevel())
					FireGameEvent( 'ability_values_force_check', { player_ID = pID })
				end				
			end
		end	
	end
	for itemSlot=0,5 do
		local item = unit:GetItemInSlot(itemSlot)
		
		-- If the ability exists, check its requirements
		if item ~= nil then
			local disabled_item_name = item:GetName()
			-- Check the table of requirements in the KV file
			if requirements[disabled_item_name] then
				local requirement_count = #requirements[disabled_item_name]
						
				-- Go through each requirement line and check if the player has that building on its list
				for k,v in pairs(requirements[disabled_item_name]) do
					-- Look for the building and update counter
					if buildings[k] and buildings[k] > 0 then
						--print("Found at least one "..k)
					else
						requirement_failed = true
						break
					end
				end

				if not requirement_failed then
					-- Cut the _disabled to learn the new ability 
					local item_len = string.len(disabled_item_name)
					local item_name = string.sub(disabled_item_name, 1 , item_len - len)

					unit:RemoveItem(item)
					newItem = CreateItem(item_name, player, player)
					unit:AddItem(newItem)
					FireGameEvent( 'ability_values_force_check', { player_ID = pID })
				end				
			end
		end	
	end
end


function bayustd:OnPlayerSay(keys)
	PrintTable(keys)

	local plyID = keys.playerid
	local ply = PlayerResource:GetPlayer(plyID)
	local hero = ply:GetAssignedHero()
	local txt = keys.text

	if txt == nil or txt == "" then
		return
	end

	if DEBUG and string.find(keys.text, "^-gold") then
		print("Giving gold to playerID " .. plyID)
		hero:SetGold(50000, false)
	end
	
	if DEBUG and string.find(keys.text, "^-lumber") then
		print("Giving lumber to playerID " .. plyID)
		GameRules.lumbersList[plyID+1] = GameRules.lumbersList[plyID+1] + 50000
		CustomGameEventManager:Send_ServerToPlayer(ply, "cgm_player_lumber_changed", { lumber = GameRules.lumbersList[plyID+1] })
	end
	
	if DEBUG and string.find(keys.text, "^-lvl") then
		print("Adding level to playerID " .. plyID)
		local lvlxp = XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] - XP_PER_LEVEL_TABLE[hero:GetLevel()]
		hero:AddExperience(lvlxp, false, false)
	end
	
	if DEBUG and string.find(keys.text, "^-wave") then
		print("\"" .. keys.text .. "\"")
		local number = string.sub (keys.text, 7)
		local newWave = tonumber(number)
		wave = newWave
		GameRules:SendCustomMessage("Wave is now on wave " .. wave, 0, 0)
	end
	
	-- Player commands
	if string.find(keys.text, "^-air") then
		GameRules:SendCustomMessage("Air rounds: <font color='#eedd44'>3, 6, 9, 12, 15, 18</font>", 0, 0)
	end	
	
	if string.find(keys.text, "^-magic") then
		GameRules:SendCustomMessage("Magic Immune rounds: <font color='#eedd44'>7, 10, 13, 18. 19, 20</font>", 0, 0)
	end	
	
	if string.find(keys.text, "^-boss") then
		GameRules:SendCustomMessage("Boss rounds: <font color='#eedd44'>10, 20</font>", 0, 0)
	end
end

-- Return a random position inside the graveyard zone
function bayustd:RandomGraveyardPosition()
	x1 = 5500
	x2 = 7800
	y1 = 2400
	y2 = 7800
	z  = 136

	local randomPos = Vector( RandomInt(x1, x2), RandomInt(y1, y2), z)

	return randomPos
end

-- Return a random position inside the creep spawn zone
function bayustd:RandomSpawnPosition()
	x1 = 1100
	x2 = 3900
	y1 = 4000
	y2 = 7300
	z  = 128

	local randomPos = Vector( RandomInt(x1, x2), RandomInt(y1, y2), z)

	return randomPos
end

---------------------------------------------------------------------------
-- Needed for trigger, so we disable modifiers for our heroes
---------------------------------------------------------------------------
countRemovedCreeps = 0

function bayustd:getWave()
	return wave
end

function bayustd:getCreeps()
	return creepsCount
end

function bayustd:getRemovedCreeps()
	return countRemovedCreeps
end

function bayustd:incrementRemovedCreeps()
	countRemovedCreeps = countRemovedCreeps + 1
end

function bayustd:setRemovedCreeps(val)
	countRemovedCreeps = val
end

function bayustd:Endgame(goodguys)
	GameRules:SendCustomMessage("<font color='#DBA901'>Please leave your feedback at our workshop page</font>",0,0)
	if goodguys then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
        GameRules:Defeated()
	else
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
        GameRules:Defeated()
	end
end