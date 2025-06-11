---@param pet number
PetAnimal = function(pet)
	local plyPed = PlayerPedId()
	local pos, h = GetEntityCoords(plyPed), GetEntityHeading(plyPed)
	local forwardVector = GetEntityForwardVector(plyPed)
	local forwardPos = vector3(pos["x"] + forwardVector["x"], pos["y"] + forwardVector["y"], pos["z"] - 1.0)

	SetEntityCoords(pet, forwardPos)
	SetEntityHeading(pet, h - 180)

	lib.requestAnimDict('creatures@rottweiler@tricks@')
	TaskPlayAnim(plyPed, 'creatures@rottweiler@tricks@', "petting_franklin", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
	TaskPlayAnim(pet, 'creatures@rottweiler@tricks@', "petting_chop", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
	Wait(3500)
	ClearPedTasksImmediately(plyPed)
end

---@param citizenid string
GetOwnedPets = function(citizenid)
    if not PlayerPets[citizenid] then
        PlayerPets[citizenid] = lib.callback.await("frudy-pets:server:GetPlayerPets", false, citizenid)
    end

    return PlayerPets[citizenid]
end

---@param food number
GetHunger = function(food)
	local txt = "Full"

	if (food >= 0 and food < 25) then
		txt = "Starving"
	elseif (food >= 25 and food < 50) then
		txt = "Hungry"
	elseif (food >= 50 and food < 75) then
		txt = "Satisfied"
	end

	return txt
end

---@param health number
GetHealth = function(health)
    local txt = "Healthy"
    local maxPrice = Config.RevivePrice

    if (health >= 0 and health < 15) then
        txt = "Critical Condition"
    elseif (health >= 15 and health < 35) then
        txt = "Severely Injured"
    elseif (health >= 35 and health < 55) then
        txt = "Hurting"
    elseif (health >= 55 and health < 75) then
        txt = "Scratched Up"
    elseif (health >= 75 and health < 95) then
        txt = "Minor Bruises"
    end

    local severity = 1 - (health / 100)
    local price = math.floor(maxPrice * severity)

    return txt, price
end

---@param species string
GetPetIcon = function(species)
	local icons = {
		['dog'] = '🐶',
		['cat'] = '😺',
		['chicken'] = '🐔'
	}

	return icons[species] or icons["dog"]
end

---@param number number
FormatNumber = function(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

ToyShop = function()
	exports["mc9-basicshops"]:OpenShopMenu("pet_shop")
end

CreateBlip = function()
    local blipCfg = Config.PetStore.Blip
    if (blipCfg) or (not blipCfg.enabled) then return end

    local shopBlip = AddBlipForCoord(blipCfg.coords.x, blipCfg.coords.y, blipCfg.coords.z)
    SetBlipSprite(shopBlip, blipCfg.icon or 273)
    SetBlipDisplay(shopBlip, 4)
    SetBlipScale(shopBlip, blipCfg.scale or 0.6)
    SetBlipAsShortRange(shopBlip, true)
    SetBlipColour(shopBlip, blipCfg.color or 24)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(blipCfg.label)
    EndTextCommandSetBlipName(shopBlip)
end

CreateVetPeds = function()
    local pedsCfg = Config.PetStore.Peds
    if (not pedsCfg) then return end

    for _, pedCfg in pairs(pedsCfg) do
        if (not pedCfg.model) or (not pedCfg.usePed) then goto skip end

        local pedModel = pedCfg.model
        lib.requestModel(pedModel)

        if (IsModelAPed(pedModel)) then
            local shopPed = CreatePed(4, pedModel, pedCfg.pos.x, pedCfg.pos.y, pedCfg.pos.z - 1.03, pedCfg.pos.w or 0, false, true)

            SetEntityHeading(shopPed, pedCfg.pos.w)
            FreezeEntityPosition(shopPed, true)
            TaskStartScenarioInPlace(shopPed, "WORLD_HUMAN_STAND_IMPATIENT", -1, true)
            SetBlockingOfNonTemporaryEvents(shopPed, true)
            SetEntityNoCollisionEntity(shopPed, PlayerPedId(), false)
            SetEntityInvincible(shopPed, true)
            SetModelAsNoLongerNeeded(pedModel)

            Peds[#Peds + 1] = shopPed
        end
        ::skip::
    end
end

RemoveVetPeds = function()
    for _, ped in pairs(Peds) do
        DeleteEntity(ped)
    end

    Peds = {}
end

---@param ped string
---@param shopKey string
local getInteraction = function(ped, shopKey)
    local target = (Config.UseTarget and "target") or "interact"
    local interactions = {
        target = {
            vet = {
                name = shopKey,
                icon = "fas fa-certificate",
                label = "Vet",
                onSelect = function() VetMenu() end,
            },
            cashier = {
                name = shopKey,
                icon = "fas fa-certificate",
                label = "Pet Store",
                onSelect = function() OpenPetShop() end,
            }
        },
        interact = {
            vet = {
                label = "Vet",
                action = function() VetMenu() end,
            },
            cashier = {
                label = "Pet Store",
                action = function() OpenPetShop() end,
            }
        }
    }

    return {interactions[target][ped]}
end

CreateVetInteractions = function()
    local storeCfg = Config.PetStore.Peds
    if (not storeCfg) then return end

    for ped, cfg in pairs(storeCfg) do
        if (not cfg.pos) then goto skip end

        local shopKey = "mc9Pets::Vet"..ped
        local options = getInteraction(ped, shopKey)

        if Config.UseTarget then
            exports.ox_target:addBoxZone({
                coords = vec3(cfg.pos.x, cfg.pos.y, cfg.pos.z),
                size = vec3(1, 1, 2),
                rotation = cfg.pos.w,
                debug = Config.Debug,
                options = options
            })
        else
            exports["mc9-interact"]:AddInteraction({
                coords = vec3(cfg.pos.x, cfg.pos.y, cfg.pos.z),
                distance = 5.0,
                interactDst = 2.0,
                id = shopKey,
                options = options
            })
        end

        ::skip::
    end
end

CreateStoreZone = function()
    local storeCoords = (Config.PetStore.Location) or (Config.PetStore.Peds.cashier.pos) or (Config.PetStore.Peds.vet.pos)
    if (not storeCoords) then
        lib.print.debug("frudy-pets::CreateStoreZone - No coords set for store zone")
        return
    end

    local zoneId = "mc9Pets::shopZone"
    local shopZone = BoxZone:Create(vec3(storeCoords.x, storeCoords.y, storeCoords.z), 15.0, 15.0, {
        name = zoneId,
        offset = {0.0, 0.0, 0.0},
        scale = {1.0, 1.0, 1.0},
        debugPoly = false,
    })

    shopZone:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            if (not Interactions[zoneId]) then
                Interactions[zoneId] = true

                CreateVetPeds()
            end
        else
            if (Interactions[zoneId]) then
                Interactions[zoneId] = nil

                RemoveVetPeds()
            end
        end
    end)
end
