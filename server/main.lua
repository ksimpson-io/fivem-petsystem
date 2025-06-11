local DBPet = require "server.modules.DBPet"
QBCore = exports["qb-core"]:GetCoreObject()
CurrentPets = {}

local createLog = function(title, color, message, alert)
    local alertEveryone = alert or false
    TriggerEvent("qb-log:server:CreateLog", "pets", title, color, message, alertEveryone)
end

---@param owner table
---@param petCode string
---@param payment string
---@param price table
local addPlayerPet = function(owner, petCode, payment, price)
	local pet = PetData.Pets[petCode]
	if (not pet) or (not next(owner)) then return end
	local randomName = PetData.DefaultNames[math.random(#PetData.DefaultNames)]

	MySQL.query.await('INSERT INTO player_pets (owner, petid, model, species, food, health, name, breed, color, colorComponent, collar, collarComponent) VALUES (:owner, :petid, :model, :species, :food, :health, :name, :breed, :color, :colorComponent, :collar, :collarComponent)', {
		owner = owner.PlayerData.citizenid,
		petid = petCode,
		model = pet.model,
		species = pet.species,
		food = 100,
		health = 100,
		name = randomName,
		breed = pet.breed,
		color = pet.color,
		colorComponent = pet.colorComponent,
		collar = 0,
		collarComponent = pet.collarComponent,
	})

	createLog("Pet Purchased", "purple", string.format(
		"**Player**```Name: %s\nCitizen ID: %s\nLicense: %s```**Pet**```ID: %s\nName: %s\nSpawnname: %s\nType: %s```**Payment**```Method: %s\nAmount: %s```",
		owner.PlayerData.name, owner.PlayerData.citizenid, owner.PlayerData.license,
		petCode, pet.breed, pet.model, pet.species,
		payment, (payment == "tokens" and price.tokens or price.money)
	))
end

function UpdatePetPrice(petID, currencyType, price)
	if (not PetPrices[petID]) then
		return mc9.status.fail("Pet does not exist")
	end

	if (type(price) ~= "number") then
		return mc9.status.fail("Price must be a number")
	end

	if (price < 0) then
		return mc9.status.fail("Price cannot be negative")
	end

	PetPrices[petID][currencyType] = price

	return mc9.status.pass("Updated pet price")
end

exports("SetPetMoneyPrice", function(pet, price)
	return UpdatePetPrice(pet, "money", price)
end)

exports("SetPetTokenPrice", function(pet, price)
	return UpdatePetPrice(pet, "tokens", price)
end)

AddEventHandler('playerDropped', function()
    local cid = QBCore.Functions.GetPlayer(source)?.PlayerData?.citizenid
	local plyPets = PlayerPets[cid]

	if (not plyPets) or (not next(plyPets)) then return end

	for petId, _ in pairs(plyPets) do
		if CurrentPets[petId] then
			CurrentPets[petId]:remove()
		end
	end
	PlayerPets[cid] = nil
end)

---@param petId number
RegisterNetEvent("frudy-pets:server:petSpawned", function(petId)
	local src = source
	local owner = QBCore.Functions.GetPlayer(src)
	if (not owner) then return end
	local petCfg = PlayerPets[owner.PlayerData.citizenid][petId]
	if (not petCfg) then return end

	CurrentPets[petId] = DBPet:new(petCfg)
	CurrentPets[petId]:decay()

	TriggerClientEvent("frudy-pets:client:petSpawned", -1, petCfg)
end)

---@param petId number
RegisterNetEvent("frudy-pets:server:removePet", function(petId)
	CurrentPets[petId]:remove()
	CurrentPets[petId] = nil
end)

---@param petId number
---@param stats table
RegisterNetEvent("frudy-pets:server:updatePet", function(petId, stats)
	local pet = DBPet.get(petId)
	if (not pet) then return end

	for stat, value in pairs(stats) do
		pet[stat] = value
	end

	pet:save()
end)

---@param petId number
---@param name string
RegisterNetEvent('frudy-pets:server:renamePet', function(petId, name)
	local owner = QBCore.Functions.GetPlayer(source)
	local pet = DBPet.get(petId)
	if (not owner) or (not pet) then return end

	pet:updateName(name)
	owner.Functions.Notify("Pet renamed to "..name, "success")
	createLog("Pet Renamed", "purple", "**"..Player.PlayerData.name.."** renamed their pet to **"..name.."**")
end)

---@param petId number
---@param health number
RegisterNetEvent('frudy-pets:server:healPet', function(petId, health)
	local owner = QBCore.Functions.GetPlayer(source)
	local pet = DBPet.get(petId)
	if (not owner) or (not pet) then return end

	if (not owner.Functions.RemoveMoney('bank', Config.RevivePrice, 'Vet')) then
		return owner.Functions.Notify("Not enough money", 'error')
	end

	pet:updateHealth(health)
	owner.Functions.Notify("Pet healed", "success")
	createLog("Pet Healed", "purple", "**"..owner.PlayerData.name.."** healed their pet ("..petId..")")
end)

---@param payment string
---@param petCode string
RegisterNetEvent('frudy-pets:server:buyPet', function(payment, petCode)
	local src = source
	local buyer = QBCore.Functions.GetPlayer(src)
	if (not buyer) then return end

	local pet = PetData.Pets[petCode]
	local petPrice = PetPrices[petCode]

	if (not pet) then
		return buyer.Functions.Notify("Pet does not exist", "error", 7000)
	end

	if (payment == "tokens") then
		if (not buyer.Functions.RemoveTokens("premium", petPrice.tokens, "Purchased Pet")) then
			return buyer.Functions.Notify("Not enough tokens", 'error', 5000)
		end
	elseif (payment == "cash" or payment == "bank") then
		if not buyer.Functions.RemoveMoney(payment, petPrice.money, 'Pet') then
			return buyer.Functions.Notify("Not enough money", 'error', 5000)
		end
	else
		return buyer.Functions.Notify("Invalid payment method", "error", 7000)
	end

	addPlayerPet(buyer, petCode, payment, petPrice)
	buyer.Functions.Notify(pet.breed.." purchased. Make sure to buy a whistle", 'success', 5000)
end)

RegisterNetEvent('frudy-pets:server:syncFromServer', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if (not player) then return end

    for petId, petObj in pairs(CurrentPets) do
        local ownerCid = petObj.owner
        if (ownerCid) and (PlayerPets[ownerCid]) and (PlayerPets[ownerCid][petId]) then
            local petData = PlayerPets[ownerCid][petId]
            TriggerClientEvent("frudy-pets:client:petSpawned", src, petId, petData)
        end
    end
end)

lib.callback.register("frudy-pets:server:GetPetPrices", function()
	return PetPrices()
end)

lib.callback.register("frudy-pets:server:GetPets", function()
	return PetData.Pets
end)

lib.callback.register('frudy-pets:server:GetPlayerPets', function(source, cid)
	if (not PlayerPets[cid]) then
		local r = MySQL.query.await('SELECT * FROM player_pets WHERE owner = ?', {cid})
		local pets = {}

		for _, row in pairs(r) do
			pets[row.id] = row
		end

		PlayerPets[cid] = pets
	end

	return PlayerPets[cid]
end)

CreateThread(function()
    mc9.files.WriteIfResourceFileNotExists("shared/prices.lua", "return {}")

    PetPrices = mc9.synced(lib.load("shared/prices"))
    PetPrices.SetFile("shared/prices")
    PetPrices.SetSyncKey("pet_prices")
    PetPrices.WriteOnShutdown()

	exports["mc9-basicshops"]:RegisterShop("pet_shop", Config.PetStore.ItemShop)
end)


mc9.script.onStop(function()
	for petId, _ in pairs(CurrentPets) do
		CurrentPets[petId]:remove()
	end

	PlayerPets = {}
	CurrentPets = {}
end)
