ClientPets = {}

--- @class Pet
---@field id number
---@field name string
---@field model string
---@field species string
---@field breed string
---@field food number
---@field health number
---@field color number
---@field collar number
---@field colorComponent number
---@field collarComponent number
---@field animations table
---@field damage number
---@field fetching boolean
---@field trackingBall boolean
---@field entity number
---@field owner string
local Pet = {}
Pet.__index = Pet

local sitTypes = {
	basic = "WORLD_CAT_SLEEPING_LEDGE",
	a_c_retriever = "WORLD_DOG_SITTING_SHEPHERD",
	a_c_husky = "WORLD_DOG_SITTING_SHEPHERD",
	a_c_chop_02 = "WORLD_DOG_SITTING_SHEPHERD",
	a_c_shepherd = "WORLD_DOG_SITTING_SHEPHERD",
	a_c_pug = "WORLD_DOG_SITTING_SMALL",
	a_c_poodle = "WORLD_DOG_SITTING_SMALL",
	a_c_westy = "WORLD_DOG_SITTING_SMALL",
	a_c_cat = "WORLD_CAT_SLEEPING_LEDGE",
}

local vehicleSeatData = {
    [0] = { door = "door_pside_f", seat = "seat_pside_f", doorToggle = 1 }, -- passenger
    [1] = { door = "door_dside_r", seat = "seat_dside_r", doorToggle = 2 }, -- rear
    [2] = { door = "door_pside_r", seat = "seat_pside_r", doorToggle = 3 }, -- rear
}

local entities = {}

local RemoveEnt = function(ent)
    if (DoesEntityExist(ent)) then
        DeleteEntity(ent)
    end
    entities[ent] = nil
end

---@param data table
function Pet:new(data)
    local self = setmetatable({}, Pet)

    self.name = data.name
    self.model = data.model
    self.species = data.species
    self.breed = data.breed
    self.health = data.health
    self.food = data.food
    self.color = data.color
    self.collar = data.collar
    self.colorComponent = PetData.Base[data.model].colorComponent or 0
    self.collarComponent = PetData.Base[data.model].collarComponent or 0
    self.animations = PetData.Base[data.model].animations
    self.damage = PetData.Base[data.model].damage
    self.id = data.id
    self.owner = data.owner
    self.entity = nil
    self.curVehicle = nil
    self.following = false
    -- self.attacking = false
    self.fetching = false
    self.trackingBall = false

    return self
end

function Pet:spawn()
    if (self.health <= 0) then
        QBCore.Functions.Notify(self.name .. " " .. " is in critical condition. Take them to the vet", "error")
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
	local hash = GetHashKey(self.model)
	local spawnX = math.random(-1.0, 1.0)
	local spawnY = math.random(-1.0, 1.0)
	local spawnLoc = vector3(coords.x + spawnX, coords.y + spawnY, coords.z - 1.0)

    lib.requestModel(hash)
    self.entity = CreatePed(28, hash, spawnLoc.x, spawnLoc.y, spawnLoc.z, 0.0, true, true)
    self.netId = NetworkGetNetworkIdFromEntity(self.entity)
    ClientPets[self.id] = self

    SetBlockingOfNonTemporaryEvents(self.entity, true)
    SetPedComponentVariation(self.entity, self.colorComponent, 0, self.color, 0)
    if (self.collar > 0) then
        SetPedComponentVariation(self.entity, self.collarComponent, 0, self.collar, 0)
    end
    SetModelAsNoLongerNeeded(self.model)

    if (self.health <= Config.DeadHealth) then
        QBCore.Functions.Notify(self.name .. " " .. " is dying! Feed or bandage them", "primary")
    end

    self:follow()

    TriggerServerEvent("frudy-pets:server:petSpawned", self.id)
end

function Pet:delete()
    if (self.entity) then
        DeleteEntity(self.entity)
    end
    for ent, _ in pairs(entities) do
        DeleteEntity(ent)
    end
    entities = {}
    self.entity = nil
end

function Pet:sendHome()
	if (not self.entity) then return end

    self:clearTasks()
	QBCore.Functions.Notify("Go home!", "success")
	TriggerEvent('animations:client:EmoteCommandStart', { "blowkiss2" })
	TriggerServerEvent("frudy-pets:server:removePet", self.id)
	self:delete()
end

function Pet:follow()
    local player = PlayerPedId()
	local pos = GetEntityCoords(player)
    local petPos = GetEntityCoords(self.entity)
    local dist = #(petPos - pos)
    local moving = false

    self:clearTasks()
    self:addTarget()
    self.following = true

	CreateThread(function()
		while true do
            if (not self.following) or (self.curVehicle) then return end

            if (dist > 1.5) then
                if not moving then
                    moving = true
                    TaskGoToEntity(self.entity, player, -1, 1.5, 3.0, 0, 0)
                end
            else
                moving = false
                ClearPedTasks(self.entity)
            end

            if IsEntityDead(self.entity) or IsEntityDead(player) then
                self:clearTasks()
                self:delete()

                local msg = (IsEntityDead(self.entity) and self.name .. " " .. "has died") or self.name .. " " .. " went home"
                QBCore.Functions.Notify(msg, "error")
                return
            end

            pos = GetEntityCoords(player)
            petPos = GetEntityCoords(self.entity)
            dist = #(petPos - pos)

            Wait(500)
        end
	end)
end

function Pet:stay()
    self:clearTasks()
    self:startAnimation(self.animations.sit)
    QBCore.Functions.Notify("Stay " .. self.name .. " " .. "!", "error")
end

function Pet:toggleFollow(forceFollow)
    if (not self.entity) then return end

    if forceFollow or (not self.following) then
        QBCore.Functions.Notify("Follow me " .. self.name .. " " .. "!", "success")
        self:follow()
    else
        self:stay()
    end
end

function Pet:sitInVehicle()
    if (not self.following) then return end

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if (not vehicle) then return end
	if (GetVehicleNumberOfWheels(vehicle) < 4) then QBCore.Functions.Notify("Not enough seats", "error") return end

	local sitType = sitTypes[self.model] or sitTypes.basic
	self:clearTasks()

    for seatIndex, seatData in pairs(vehicleSeatData) do
        if IsVehicleSeatFree(vehicle, seatIndex) then
            self.curVehicle = vehicle
            local seatcoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, seatData.door))

            TaskGoToCoordAnyMeans(self.entity, seatcoords.x, seatcoords.y, seatcoords.z, 1.5, false, false, 1.0, 1.0)
            SetVehicleDoorOpen(vehicle, seatData.doorToggle, false, false)
            Wait(1500)
            AttachEntityToEntity(self.entity, vehicle, GetEntityBoneIndexByName(vehicle, seatData.seat), 0.0, -0.3, 0.35, 0, 0, 0, false, false, false, false, 0, false)
            TaskStartScenarioInPlace(self.entity, sitType)
            SetPedKeepTask(self.entity, true)
            SetVehicleDoorShut(vehicle, seatData.doorToggle, false)

            return
        end
    end

    QBCore.Functions.Notify("All seats are taken ".. self.name .. " left behind", "error")
end

function Pet:leaveVehicle()
    if (not self.curVehicle) then return end

    TaskLeaveVehicle(self.entity, self.curVehicle, 131072)
    self.curVehicle = nil
    self:follow()
end

function Pet:startAnimation(animData)
	self:clearTasks()
	Wait(500)

	if (animData.scenario) then
		TaskStartScenarioInPlace(self.entity, animData.scenName)
		SetPedKeepTask(self.entity, true)
    elseif (animData.animDict) and (animData.animName) then
		lib.requestAnimDict(animData.animDict)
		TaskPlayAnim(self.entity, animData.animDict, animData.animName, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
	end

    self:addTarget()
end

function Pet:clearTasks()
	self.following = false
	self.attacking = false
    self:removeTarget()
	ClearPedTasks(self.entity)
end

---@param foodtype string
function Pet:feed(foodtype)
    if (not self.entity) or (self.species ~= foodtype) then return end
    self:clearTasks()

	local player = PlayerPedId()
	local pos = GetEntityCoords(player)
	local forward = GetEntityForwardVector(player)
	local x, y, z = table.unpack(pos + forward * 0.75)
    local bowlHash = `prop_peanut_bowl_01`

    lib.requestModel(bowlHash)
	local foodBowl = CreateObject(bowlHash, x, y, z, true, false, true)

    PlaceObjectOnGroundProperly(foodBowl)
    TaskGoToEntity(self.entity, foodBowl, -1, 0.5, 1.0, 1073741824, 0)
    TaskLookAtEntity(self.entity, foodBowl, 15000, 2048, 3)
    entities[foodBowl] = true

    self:startAnimation(self.animations.speak) -- TODO: find eating animations
    Wait(5000)
    RemoveEnt(foodBowl)
    QBCore.Functions.Notify(self.name .. " " .. " fed", "success")

    self:follow()
    TriggerServerEvent('frudy-pets:server:updatePet', self.id, { hunger = 100, health = math.min(self.health + 25, 100) })
end

function Pet:startFetch()
    if (not self.entity) or (self.fetching) then return end

    QBCore.Functions.Notify("Throw the ball", "primary")
    self.fetching = true
    CreateThread(function()
        while true do
            if (not self.fetching) or (not self.entity) then return end

            if (IsControlJustReleased(0, 24)) then
                self.trackingBall = true
                self:fetchBall()
                break
            end
            Wait(1)
        end
    end)
end

function Pet:endFetch()
    if (not self.entity) or (not self.fetching) or (self.trackingBall) then return end

    self.trackingBall = false
    self.fetching = false
    QBCore.Functions.Notify("Playing fetch cancelled", "error")
    self:follow()
end

function Pet:fetchBall()
    local plyPed = PlayerPedId()
    local coords, forward = GetEntityCoords(plyPed), GetEntityForwardVector(plyPed)
    local ballHash = `w_am_baseball`

    QBCore.Functions.Notify("Go get the ball!", "success")
    self:clearTasks()
    Wait(500)

    local fakeBall = CreateObject(ballHash, coords.x + forward.x * 1.0, coords.y + forward.y * 1.0, coords.z + 0.25, true, true, true)
    SetEntityVelocity(fakeBall, forward.x * 5.0, forward.y * 5.0, 5.0)
    SetEntityDynamic(fakeBall, true)
    SetEntityCoordsNoOffset(fakeBall, coords.x + forward.x * 1.0, coords.y + forward.y * 1.0, coords.z + 0.5, false, false, false)
    SetEntityAsMissionEntity(fakeBall, true, true)
    entities[fakeBall] = true

    Wait(1000)

    TaskGoToEntity(self.entity, fakeBall, 5000, 0.5, 3.0, 0, 0)
    Wait(5000)
    TaskLookAtEntity(self.entity, fakeBall, 15000, 2048, 3)
    self:startAnimation(self.animations.sit)

    local boneIndex = GetPedBoneIndex(self.entity, 17188)
    AttachEntityToEntity(fakeBall, self.entity, boneIndex, 0.120, 0.010, 0.010, 5.0, 150.0, 0.0, true, true, false, true, 1, true)
    TaskGoToEntity(self.entity, plyPed, 5000, 0.5, 3.0, 1073741824, 0)
    Wait(5000)
    DetachEntity(fakeBall, false, false)
    SetEntityAsMissionEntity(fakeBall)
    RemoveEnt(fakeBall)

    QBCore.Functions.Notify(self.name .. " " .. " got the ball!", "success")
    self.fetching = false
    self.trackingBall = false
    self:follow()
end

function Pet:inflictDamage()
    if (not self.entity) or (self.species == "cat") then return end
    local playerPed = PlayerPedId()

    self:clearTasks()
    self.attacking = true
    self:startAnimation(self.animations.attack)
    Wait(5000)

    ApplyDamageToPed(playerPed, self.damage, true)
	if IsEntityDead(playerPed) then
		self:follow()
	end
end

function Pet:toggleAttack()
    if (not self.entity) or (not self.damage) then return end

    if self.attacking then
        QBCore.Functions.Notify("Follow me!", "success")
        self:follow()
        return
    end

	local _, enemy = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if (not enemy) or (enemy == PlayerPedId()) or (enemy == 0) then return end

    self:clearTasks()
    self.attacking = true
    QBCore.Functions.Notify("Attack!", "error")
    TaskPutPedDirectlyIntoMelee(self.entity, enemy, 0.0, -1.0, 0.0, 0)
end

---@param color number
function Pet:changeCollar(color)
    if (not self.entity) then return end
    SetPedComponentVariation(self.entity, self.collarComponent, 0, color, 0)
    TriggerServerEvent('frudy-pets:server:updatePet', self.id, {collar = color})
end

function Pet.get(petId)
    return ClientPets[petId]
end

function Pet.getFromNetId(petId)
    for _, pet in pairs(ClientPets) do
        if pet.netId == petId then
            return pet
        end
    end

    return nil
end

function Pet:addTarget()
    if (not self.entity) then return end

    if Config.UseTarget then
        exports.ox_target:addEntity(self.entity, {
            {
                icon = "fas fa-paw",
                label = "Pet " .. self.name,
                onSelect = function() PetAnimal(self.entity) end,
                distance = 2.0
            },
            {
                icon = "fas fa-paw",
                label = "Send Home",
                onSelect = function() SendPetHome() end,
                distance = 2.0,
                canInteract = function() return (self.owner == PlayerData?.citizenid) end
            },
            {
                icon = "fas fa-wand-magic-sparkles",
                label = "Tricks",
                onSelect = function() TricksMenu() end,
                distance = 2.0,
                canInteract = function() return (self.owner == PlayerData?.citizenid) end
            }
        })
    else
        exports["mc9-interact"]:AddEntityInteraction({
            netId = NetworkGetNetworkIdFromEntity(self.entity),
            id = "frudy-pets::petActions",
            distance = 2.0,
            interactDst = 1.5,
            offset = vec3(0.0, 0.0, 0.3),
            options = {
                {
                    label = "Pet " .. self.name,
                    action = function() PetAnimal(self.entity) end,
                },
                {
                    label = "Send Home",
                    action = function() SendPetHome() end,
                    canInteract = function() return (self.owner == PlayerData?.citizenid) end
                },
                {
                    label = "Tricks",
                    action = function() TricksMenu() end,
                    canInteract = function() return( self.owner == PlayerData?.citizenid) end
                },
            }
        })
    end
end

function Pet:removeTarget()
    if (not self.entity) then return end

    if Config.UseTarget then
        exports.ox_target:removeEntity(self.entity)
    else
        exports["mc9-interact"]:RemoveEntityInteraction(NetworkGetNetworkIdFromEntity(self.entity),"frudy-pets::petActions")
    end
end

return Pet
