PlayerPets = {}
PetData = {}

PetData.DefaultNames = {
	"Smarty", "Garfield", "Paddy", "Calvin", "Porky", "Benson", "Reggie", "Mugsy", "Ginger", "Aldo", "Winston",
	"Persy", "Oreo", "Biggie", "Plato", "Houdini", "Clover", "Booker", "Cooper", "Lucky", "Wallace", "Earl", "Sumo",
	"Laddie", "Blackjack", "Pippy", "Faith", "Jenny", "Stanley", "Sherman", "Rocky", "Gidget", "Jasmine", "Biscuit",
}

PetData.CollarColors = {
    BrownLeather = 0,
	BlackStudded = 1,
	PinkDiamonds = 2,
	Yellow = 3,
	Green = 4,
	HotPink = 5
}

PetData.Base = {
    a_c_retriever = { -- model name of animal
        species = "dog", -- species of animal ex:dog, cat, bird, fish
        breed = "Retriever", -- type of breed ex: Retriever, Husky, Shepherd
        damage = 25, -- damage to player
        colors = { -- available colors: id, name
			[0] = "Golden",
			[1] = "Black",
			[2] = "White",
			[3] = "Red",
		},
        colorComponent = 0, -- default color
        collarComponent = 0, -- default collar
        animations = { -- available animations
			lay = { name = 'Lay Down', animDict = 'creatures@rottweiler@amb@sleep_in_kennel@', animName = 'sleep_in_kennel' },
			speak = { name = 'Bark', scenario = true, scenName = 'WORLD_DOG_BARKING_RETRIEVER' },
			sit = { name = 'Sit Down', animDict = 'creatures@rottweiler@amb@world_dog_sitting@base', animName = 'base' },
		}
    },
    a_c_husky = {
        species = "dog",
        breed = "Husky",
        damage = 30,
        colors = {
			[0] = "Gray",
			[1] = "Red",
			[2] = "Silver"
		},
        colorComponent = 0,
        collarComponent = nil,
        animations = {
			lay = { name = 'Lay Down', animDict = 'creatures@rottweiler@amb@sleep_in_kennel@', animName = 'sleep_in_kennel' },
			speak = { name = 'Bark', scenario = true, scenName = 'WORLD_DOG_BARKING_RETRIEVER' },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SHEPHERD' },
		}
    },
    a_c_pug = {
        species = "dog",
        breed = "Pug",
        damage = 15,
        colors = {
			[0] = "Fawn",
			[1] = "Silver",
			[2] = "Apricot",
			[3] = "Black"
		},
        colorComponent = 4,
        collarComponent = 3,
        animations = {
			lay = { name = 'Lay Down', animDict = 'misssnowie@little_doggy_lying_down', animName = 'base' },
			speak = { name = 'Bark', animDict = 'creatures@pug@amb@world_dog_barking@idle_a', animName = 'idle_a', },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SMALL' },
		}
    },
    a_c_poodle = {
        species = "dog",
        breed = "Poodle",
        damage = 10,
        colors = {
			[0] = "Poodle"
		},
        colorComponent = 4,
        collarComponent = nil,
        animations = {
			lay = { name = 'Lay Down', animDict = 'misssnowie@little_doggy_lying_down', animName = 'base', },
			speak = { name = 'Bark', animDict = 'creatures@pug@amb@world_dog_barking@idle_a', animName = 'idle_a', },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SMALL' },
		}
    },
    a_c_chop_02 = {
        species = "dog",
        breed = "Rottweiler",
        damage = 30,
        colors = {
			[0] = "Rottweiler"
		},
        colorComponent = 4,
        collarComponent = 3,
        animations = {
			lay = { name = 'Lay Down',  animDict = 'creatures@rottweiler@amb@sleep_in_kennel@', animName = 'sleep_in_kennel', },
			speak = { name = 'Bark', scenario = true, scenName = 'WORLD_DOG_BARKING_RETRIEVER' },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SHEPHERD' },
		}
    },
    a_c_westy = {
        species = "dog",
        breed = "Westy",
        damage = 15,
        colors = {
			[0] = "White",
			[1] = "Fawn",
			[2] = "Black"
		},
        colorComponent = 4,
        collarComponent = 3,
        animations = {
			lay = { name = 'Lay Down', animDict = 'misssnowie@little_doggy_lying_down', animName = 'base', },
			speak = { name = 'Bark', animDict = 'creatures@pug@amb@world_dog_barking@idle_a', animName = 'idle_a', },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SMALL' },
		}
    },
    a_c_shepherd = {
        species = "dog",
        breed = "Shepherd",
        damage = 25,
        colors = {
			[0] = "TriColor",
			[1] = "Piebald",
			[2] = "Sable & White"
		},
        colorComponent = 0,
        collarComponent = nil,
        animations = {
			lay = { name = 'Lay Down', animDict = 'creatures@rottweiler@amb@sleep_in_kennel@', animName = 'sleep_in_kennel', },
			speak = { name = 'Bark', scenario = true, scenName = 'WORLD_DOG_BARKING_RETRIEVER' },
			sit = { name = 'Sit Down', scenario = true, scenName = 'WORLD_DOG_SITTING_SHEPHERD' },
		}
    },
    a_c_cat_01 = {
        species = "cat",
        breed = "Cat",
        damage = 25,
        colors = {
			[0] = "Gray",
			[1] = "BnW",
			[2] = "Orange"
		},
        colorComponent = 0,
        collarComponent = nil,
        animations = {
			lay = { name = 'Lay Down', scenName = 'WORLD_CAT_SLEEPING_GROUND' },
		}
    },
    a_c_hen = {
        species = "chicken",
        breed = "Chicken",
        damage = 25,
        colors = {
			[0] = "Chicken",
		},
        colorComponent = 3,
        collarComponent = nil,
        animations = {
			lay = { name = 'Lay Down', animDict = 'creatures@hen@player_action@', animName = 'action_a', },
		}
    },
}

PetData.Pets = {}

for model, base in pairs(PetData.Base) do
    for colorIndex, colorName in pairs(base.colors) do
        local addColor = (colorName:lower() ~= base.breed:lower())
        local petcode = addColor and (colorName .. " " .. base.breed):lower():gsub("[%s&]+", "_") or base.breed:lower()

        PetData.Pets[petcode] = {
            id = petcode,
            label = (addColor and colorName .. " " .. base.breed) or base.breed,
            model = model,
            species = base.species,
            breed = base.breed,
            color = colorIndex,
            colorName = colorName,
            colorComponent = base.colorComponent or 0,
            collarComponent = base.collarComponent or 0,
            damage = base.damage,
            animations = base.animations,
        }
    end
end
