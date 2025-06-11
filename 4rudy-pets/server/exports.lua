exports("useWhistle", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:petsMenu', inventory.id)
end)

exports("useDogFood", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:feedPet', inventory.id, 'dog')
end)

exports("useCatFood", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:feedPet', inventory.id, 'cat')
end)

exports("useChickenFood", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:feedPet', inventory.id, 'chicken')
end)

exports("useCollarBrown", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.BrownLeather)
end)

exports("useCollarStudded", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.BlackStudded)
end)

exports("useCollarDiamond", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.PinkDiamonds)
end)

exports("useCollarYellow", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.Yellow)
end)

exports("useCollarPink", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.HotPink)
end)

exports("useCollarGreen", function(event, item, inventory, slot, data)
    if (inventory.type ~= "player") then return end
    TriggerClientEvent('frudy-pets:client:changeCollar', inventory.id, PetData.CollarColors.Green)
end)
