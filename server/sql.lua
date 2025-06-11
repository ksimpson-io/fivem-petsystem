-- took this from chatgpt idc
CreateThread(function()
    -- Map of expected columns and their definitions
    local expectedColumns = {
        owner = "VARCHAR(50)",
        petid = "VARCHAR(50)",
        model = "VARCHAR(50)",
        name = "TINYTEXT",
        species = "VARCHAR(50)",
        food = "INT(3)",
        health = "INT(3)",
        color = "INT(3)",
        collar = "INT(3)",
        breed = "VARCHAR(50)",
        colorComponent = "INT(11)",
        collarComponent = "INT(11)"
    }

    -- Rename legacy columns to new names
    local renameMap = {
        spawnname = { new = "model", type = "VARCHAR(50)" },
        type = { new = "species", type = "VARCHAR(50)" },
        petname = { new = "breed", type = "VARCHAR(50)" },
        citizenid = { new = "owner", type = "VARCHAR(50)" },
    }

    -- Rename legacy columns if they still exist
    for old, data in pairs(renameMap) do
        local exists = MySQL.scalar.await([[
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = "player_pets" AND COLUMN_NAME = ?
        ]], { old })

        if exists then
            MySQL.query.await(("ALTER TABLE player_pets CHANGE `%s` `%s` %s"):format(old, data.new, data.type))
            print(("[frudy-pets] Renamed column `%s` to `%s`"):format(old, data.new))
        end
    end

    -- Validate required columns exist and match the expected type
    for col, colType in pairs(expectedColumns) do
        local result = MySQL.single.await([[
            SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = "player_pets" AND COLUMN_NAME = ?
        ]], { col })

        if not result then
            -- Column is missing
            MySQL.query.await(("ALTER TABLE player_pets ADD `%s` %s"):format(col, colType))
            print(("[frudy-pets] Added missing column `%s`"):format(col))
        elseif not result.COLUMN_TYPE:upper():find(colType:match("^%w+"):upper()) then
            -- Column exists but has wrong type
            MySQL.query.await(("ALTER TABLE player_pets MODIFY `%s` %s"):format(col, colType))
            print(("[frudy-pets] Updated type of column `%s` to `%s`"):format(col, colType))
        end
    end

    -- Fill in missing models using PetData
    local petsMissingModel = MySQL.query.await([[
        SELECT id, petid FROM player_pets
        WHERE model IS NULL OR model = ''
    ]])

    for _, pet in pairs(petsMissingModel) do
        local petData = PetData.Pets[(pet.petid or ""):lower()]
        local fallbackModel = petData and petData.model or "a_c_retriever" -- fallback

        MySQL.query.await("UPDATE player_pets SET model = ? WHERE id = ?", {
            fallbackModel, pet.id
        })

        print(("[frudy-pets] Set model '%s' for pet id %s (petid: %s)"):format(
            fallbackModel, pet.id, pet.petid or "N/A"
        ))
    end

    print("[frudy-pets] Migration complete")
end)
