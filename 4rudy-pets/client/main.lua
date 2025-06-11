

local Pet = require "client.modules.Pet"
QBCore = exports["qb-core"]:GetCoreObject()
MyPet = nil
PlayerData = {}
Peds = {}
Interactions = {}
Inventory = exports.ox_inventory

---@param data table
SpawnPet = function(data)
	if MyPet or (data.health == 0) then return end

    MyPet = Pet:new(data)
    MyPet:spawn()
end

SendPetHome = function()
	if (not MyPet) then return end

    MyPet:sendHome()
    MyPet = nil
end

AddEventHandler("entityDamaged", function(victim, culprit, weapon, damage)
    local playerPed = PlayerPedId()
    if (not culprit) or (victim ~= playerPed) then return end

    local cupritNetId = NetworkGetNetworkIdFromEntity(culprit)
    local pet = Pet.getFromNetId(cupritNetId)
    if (not pet) then return end

    ApplyDamageToPed(playerPed, pet.damage, true)
end)

-- AddEventHandler("entityDamaged", function(victim, culprit, weapon, damage)
--     local playerPed = PlayerPedId()
--     local victimPed = GetEntityModel(victim)
--     if (victim ~= companion) or (culprit ~= playerPed) or (QBCore.Functions.GetPlayerData().citizenid == ownerID) then return end
-- 	petName = GetPedModel(victimPed)
--     if (not petName) then return end
-- 	attacking = true
-- 	while true do
-- 		Wait(1)
-- 		if attacking then TaskCombatPed(companion, playerPed, 0, 16) else return end
-- 	end
-- end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if (not MyPet) then return end

	MyPet:delete()
	TriggerServerEvent("frudy-pets:server:removePet", MyPet.id)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	PlayerData = QBCore.Functions.GetPlayerData()
	TriggerServerEvent("frudy-pets:server:syncFromServer")
end)

RegisterNetEvent('QBCore:Client:EnteredVehicle', function()
	if (not MyPet) then return end

    MyPet:sitInVehicle()
end)

RegisterNetEvent('QBCore:Client:LeftVehicle', function()
	if (not MyPet) then return end

    MyPet:leaveVehicle()
end)

---@param color string
RegisterNetEvent('frudy-pets:client:changeCollar', function(color)
	if (not MyPet) then return end

	PetAnimal(MyPet.entity)
	MyPet:changeCollar(color)
end)

---@param food number
RegisterNetEvent('frudy-pets:client:feedPet', function(food)
	if (not MyPet) then return end

	MyPet:feed(food)
end)

---@param petOwner string
---@param petId number
---@param petData table
RegisterNetEvent('frudy-pets:client:petSaved', function(petOwner, petId, petData)
	PlayerPets[petOwner][petId] = petData
end)

---@param petId number
RegisterNetEvent('frudy-pets:client:petSpawned', function(petId, petCfg)
	if (not petId) or (not petCfg) or (not next(petCfg)) or(CurrentPets[petId]) then return end

	CurrentPets[petId] = Pet:new(petCfg)
	CurrentPets[petId]:addTarget()
end)

RegisterNetEvent('ox_inventory:currentWeapon', function(newWeap, shootbool)
	if (not MyPet) then return end
    local newWeapon = (newWeap and string.lower(newWeap.name)) or nil

	if (newWeapon == "weapon_ball") then
		MyPet:startFetch()
	elseif (not newWeapon) then
		MyPet:endFetch()
	end
end)

RegisterKeyMapping("++petattack", "Send your pet to attack", "keyboard", Config.Buttons.attack)
RegisterCommand('++petattack', function()
	if (not MyPet) then return end

    MyPet:toggleAttack()
end, false)

RegisterKeyMapping("++petfollow", "Make your pet follow you or stay", "keyboard", Config.Buttons.follow)
RegisterCommand('++petfollow', function()
	if (not MyPet) then return end

    MyPet:toggleFollow()
end, false)

RegisterKeyMapping("++petGoHome", "Make your pet follow you or stay", "keyboard", Config.Buttons.home)
RegisterCommand('++petGoHome', function()
	if (not MyPet) then return end

    SendPetHome()
end, false)

CreateThread(function()
	CreateBlip()
	CreateStoreZone()
	CreateVetInteractions()

	PlayerData = (next(PlayerData) and PlayerData) or QBCore.Functions.GetPlayerData()

	for _,v in pairs(Config.DamageHashes) do
		SetWeaponDamageModifier(v, 0.001)
	end
end)

mc9.script.onStop(function()
	if MyPet then MyPet:delete() end

	PlayerPets = {}
	ClientPets = {}
end)
