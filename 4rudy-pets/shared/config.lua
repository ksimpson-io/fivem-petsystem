Config = {}

Config.Buttons = {
	attack = "E",
	follow = "Q",
	home = "Z",
}

Config.UseTarget = false -- Use qb-target to interact with your pet / store
Config.Decay = 30 --Time in minutes update stats (health, food)
Config.EatTime = 10 -- Time in seconds for how long eating takes
Config.RevivePrice = 1500 --Price to revive your pet
Config.DeadHealth = 10 -- Health when your pet is considered dead

-- TODO: If you know what these hashes are, put the string and wrap them in ` ` so its easily readable and will get auto converted to the hash.
Config.DamageHashes = { -1148198339, -440934790, -100946242 }

Config.PetStore = {
	Location = vector3(-503.55, -1041.34, 24.29),
	Peds = {
		vet = { pos = vector4(-1113.14, -324.09, 36.82, 7.07), model = 's_m_y_autopsy_01', usePed = true },
		cashier = { pos = vector4(-1115.18, -323.95, 36.82, 358.61), model = 'a_f_y_eastsa_03', usePed = true },
	},
	Blip = {
		enabled = true,
		coords = vector3(-503.55, -1041.34, 24.29),
		icon = 273,
		color = 24,
		label = "Pet Shop",
	},
	ItemShop = {
		label = "Pet Shop",
		items = {
			{ name = "whistle", price = 50, amount = 500 },
			{ name = "catfood", price = 50, amount = 500 },
			{ name = "dogfood", price = 50, amount = 500 },
			{ name = "chickenfood", price = 50, amount = 500 },
			{ name = "weapon_ball", price = 50, amount = 500 },
			{ name = "collar_diamond", price = 1500, amount = 500 },
			{ name = "collar_brown", price = 500, amount = 500 },
			{ name = "collar_studded", price = 800, amount = 500 },
			{ name = "collar_pink", price = 800, amount = 500 },
			{ name = "collar_yellow", price = 750, amount = 500 },
			{ name = "collar_green", price = 750, amount = 500 },
		},
	},
}
