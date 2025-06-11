-- TODO: Maybe just swap this to a phone app?

OpenPetShop = function()
	local shopmenu = {
		{ title = "😺 Pets 🐶", onSelect = function() BuyPetMenu() end },
		{ title = "🧸 Pet Shop 🧸", onSelect = function() ToyShop() end },
		{ title = "📝 Rename a Pet 📝", onSelect = function() RenameMenu() end },
	}

    lib.registerContext({ id = "petsRenameMenu", title = "🐾 Pet Store 🐾", options = shopmenu })

	return lib.showContext("petsRenameMenu")
end

---@param petData table
local petEntry = function(petData)
	local icon = GetPetIcon(petData.species)
	local hunger = GetHunger(petData.food)
	local isDead = petData.health <= Config.DeadHealth
	local status = isDead and "At the vet" or "Status: " .. hunger

	local petOption = {
		title = icon.." | "..petData.name,
		description = petData.breed.." | "..status,
		onSelect = function() SpawnPet(petData) end,
		disabled = isDead
	}

	return petOption
end

OwnedPetsMenu = function()
	if MyPet then SendPetHome() return end

	local pets = GetOwnedPets(PlayerData.citizenid)
	if (not pets) then return end

	local ownedPets = {}
	for _, v in pairs(pets) do
		ownedPets[#ownedPets + 1] = petEntry(v)
	end

	lib.registerContext({ id = "ownedPetsMenu", title = "😺 Owned Pets 🐶", options = ownedPets, })
	TriggerEvent("animations:client:EmoteCommandStart", {"whistle"})
	Wait(1000)

	return lib.showContext("ownedPetsMenu")
end

RenameMenu = function()
	local pets = GetOwnedPets(PlayerData.citizenid)
	if (not pets) then return end

	local renamemenu = {}
	for petId, v in pairs(pets) do
		local icon = GetPetIcon(v.species)

		renamemenu[#renamemenu + 1] = {
			title = icon.." | "..v.name,
			description = v.breed,
			onSelect = function() RenameInput(petId) end
		}
	end

	renamemenu[#renamemenu + 1] = {
		title = "⬅️ Back",
		onSelect = function() OpenPetShop() end
	}

	lib.registerContext({ id = "petsRenameMenu", title = "📝 Rename a Pet 📝", options = renamemenu, })

	return lib.showContext("petsRenameMenu")
end


TricksMenu = function()
	if (not MyPet) then return end
	if (not MyPet.animations) or (not next(MyPet.animations)) then
		QBCore.Functions.Notify(MyPet.name .. "doesn't know any tricks", "error")
	return end

	local tricksMenu = {}
	for _, animation in pairs(MyPet.animations) do
		tricksMenu[#tricksMenu + 1] = {
			title = animation.name,
			onSelect = function() MyPet:startAnimation(animation) end
		}
	end
	tricksMenu[#tricksMenu + 1] = {
		title = "Relax",
		params = function() MyPet:clearTasks() end
	}

	lib.registerContext({ id = "petTricksMenu", title = "🎭 Tricks", options = tricksMenu, })

	return lib.showContext("petTricksMenu")
end

VetMenu = function()
	local pets = GetOwnedPets(PlayerData.citizenid)
	if (not pets) then return end

	local vetmenu = {}
	for petId, v in pairs(pets) do
		local icon = GetPetIcon(v.species)
		local health, price = GetHealth(v.health)

		vetmenu[#vetmenu + 1] = {
			title = icon.." | "..v.name,
			description = health .. " | $" .. FormatNumber(price),
			onSelect = function() TriggerServerEvent("frudy-pets:server:healPet", petId, 100) end,
		}
	end

	lib.registerContext({ id = "petsVetMenu", title = "🏥 Check In A Pet 🏥", options = vetmenu, })

	return lib.showContext("petsVetMenu")
end

BuyPetMenu = function()
	PlayerData = QBCore.Functions.GetPlayerData()
	local prices = mc9.callback.await("frudy-pets:server:GetPetPrices")
	local petmenu = {}

	petmenu[#petmenu+1] = {
		title = "🧍‍♂️ Your Information",
		description =
			"Tokens: "..FormatNumber(PlayerData.tokens.premium).." | "..
			"Cash: $"..FormatNumber(PlayerData.money.cash).." | "..
			"Bank: "..FormatNumber(PlayerData.money.bank),
		disabled = true,
	}

	for petCode, petCfg in pairs(PetData.Pets) do
		local cost = prices[petCode]
		local icon = GetPetIcon(petCfg.species)

		petmenu[#petmenu + 1] = {
			title = icon.." | "..petCfg.label,
			description =
				"Tokens: "..FormatNumber(cost["tokens"]).." | "..
				"Money: $"..FormatNumber(cost["money"]),
			onSelect = function() BuyPetInput(petCode) end
		}
	end

	petmenu[#petmenu + 1] = {
		title = "⬅️ Back",
		onSelect = function() OpenPetShop() end,
	}

	lib.registerContext({ id = "petsPetShopMenu", title = "🐶 Buy A Pet 😺", options = petmenu })

	return lib.showContext("petsPetShopMenu")
end

---@param payment table | nil
local validPayment = function(payment)
    if (not payment) or (not next(payment)) then return end

    local method = payment[1]
    if (not method) then return QBCore.Functions.Notify("Choose type of payment", "error") end

    return method
end

---@param petCode string
BuyPetInput = function(petCode)
	local payOptions = {
		{ value = "tokens", label = "Tokens" },
		{ value = "bank", label = "Card" },
		{ value = "cash", label = "Cash" },
	}

	local inputs = {
		{ type = "select", label = "Payment Method", description = "Choose how to pay", default = "bank", options = payOptions },
	}

	local menu = lib.inputDialog("Buy Pet", inputs)
    local payment = validPayment(menu)
    if (not payment) then return end

	TriggerServerEvent("frudy-pets:server:buyPet", payment, petCode)
end

---@param name table | nil
local validName = function(name)
    if (not name) or (not next(name)) then return end

	local newName = name[1]
    if type(newName) ~= "string" then
		QBCore.Functions.Notify("Invalid name", "error")
		return
	end

    return newName
end

---@param petId number
RenameInput = function(petId)
	local inputs = {
		{ label = "New Name", description = "New name for pet", type = "input" }
	}

	local menu = lib.inputDialog("Rename Pet", inputs)
	local newName = validName(menu)
	if (not newName) then return end

	TriggerServerEvent("frudy-pets:server:renamePet", petId, newName)
end

RegisterNetEvent("frudy-pets:client:petsMenu", function()
	OwnedPetsMenu()
end)
