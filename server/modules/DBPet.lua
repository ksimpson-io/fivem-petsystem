---@class DBPet
---@field id number
---@field name string
---@field model string
---@field species string
---@field breed string
---@field food number
---@field health number
---@field color string
---@field collar number
---@field owner string
---@field dead boolean
local DBPet = {}
DBPet.__index = DBPet

---@param data table
function DBPet:new(data)
    local self = setmetatable({}, DBPet)

    self.id = data.id
    self.name = data.name
    self.model = data.model
    self.species = data.species
    self.breed = data.breed
    self.food = data.food or 100
    self.health = data.health or 100
    self.color = data.color
    self.collar = data.collar
    self.owner = data.owner
    self.dead = self.dead or (data.health <= Config.DeadHealth)

    return self
end

function DBPet:remove()
    self:save(true)
    self = nil
end

---@param name string
function DBPet:updateName(name)
    self.name = name
    self:save()
end

---@param amount number
function DBPet:updateHealth(amount)
    self.health = amount
    self:save()
end

function DBPet:decay()
    CreateThread(function()
        while true do
            if (not self) or (not next(self)) or (self.dead) or (not CurrentPets[self.id]) then break end

            self.food = math.max(0, self.food - 1)
            self.health = math.max(0, self.health - 1)

            Wait(60000 * Config.Decay)
        end
    end)
end

---@param removed boolean | nil
function DBPet:save(removed)
    MySQL.update.await([[
        UPDATE player_pets
        SET
            name = :name,
            model = :model,
            species = :species,
            breed = :breed,
            food = :food,
            health = :health,
            color = :color,
            collar = :collar
        WHERE id = :id
    ]], {
        id = self.id,
        name = self.name,
        model = self.model,
        species = self.species,
        breed = self.breed,
        food = self.food,
        health = self.health,
        color = self.color,
        collar = self.collar,
    })

    if removed then return end

    if PlayerPets[self.owner] and PlayerPets[self.owner][self.id] then
        PlayerPets[self.owner][self.id] = {
            id = self.id,
            owner = self.owner,
            name = self.name,
            model = self.model,
            species = self.species,
            breed = self.breed,
            food = self.food,
            health = self.health,
            color = self.color,
            collar = self.collar,
        }
    end

    TriggerClientEvent("frudy-pets:client:petSaved", -1, self.owner, self.id, PlayerPets[self.owner][self.id])
end

---@param petId number
---@return DBPet|nil
function DBPet.get(petId)
    if CurrentPets[petId] then
        return CurrentPets[petId]
    else
        local r = MySQL.query.await('SELECT * FROM player_pets WHERE id = ?', { petId })
        if r and r[1] then
            return DBPet:new(r[1])
        end
    end

    return nil
end

return DBPet
