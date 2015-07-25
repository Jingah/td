--[[
	Author: Jingah
	Date: 20.02.2015.
	Sells the unit by removing entity and opening squares in BH
]]
function SellBuilding( keys )
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local pID = hero:GetPlayerID()
	local player = PlayerResource:GetPlayer(pID)
	
	local name = caster:GetUnitName()
	local unit_table = GameRules.UnitKV[name]
	local sellBounty = unit_table.SellBounty
	
	for i, v in ipairs(GameRules.buildingEntities[pID+1]) do 
		if v == caster then
			print("Deleted building from table")
			--table.remove(player.buildingEntities, i)
		end
		--PrintTable( player.buildingEntities )
	end

	caster:RemoveBuilding(true)

	if sellBounty ~= 0 then
		--player.lumber = player.lumber + sellBounty
		GameRules.lumbersList[pID+1] = GameRules.lumbersList[pID+1] + sellBounty
		--print("Lumber Gained. " .. hero:GetUnitName() .. " is currently at " .. player.lumber)
		FireGameEvent('cgm_player_lumber_changed', { player_ID = pID, lumber = GameRules.lumbersList[pID+1] })
		PopupLumber(player, caster, sellBounty)
	end
end

function UpgradeBuilding( keys )
	local caster = keys.caster
	local pID = caster:GetPlayerOwnerID()
	local player = PlayerResource:GetPlayer(pID)
	local pos = caster:GetAbsOrigin()
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local squares = caster.squaresOccupied
	
	--caster:RemoveBuilding(true)
	caster:RemoveSelf()
	
	unit = CreateUnitByName(keys.Building, pos, false, hero, nil, hero:GetTeamNumber())
	unit:SetOwner(hero)
	unit:SetControllableByPlayer(pID, true)
	unit:SetAbsOrigin(pos)
	unit.squaresOccupied = squares
	
	--player.lumber = player.lumber - keys.LumberCost
	GameRules.lumbersList[pID+1] = GameRules.lumbersList[pID+1] - keys.LumberCost
	--print("Lumber Spend. " .. hero:GetUnitName() .. " is currently at " .. player.lumber)
	FireGameEvent('cgm_player_lumber_changed', { player_ID = pID, lumber = GameRules.lumbersList[pID+1] })
end