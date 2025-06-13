fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"
name "frudy_pets"
version "2.0.0"
description "A modular pet companion system for FiveM"

shared_scripts {
	"@ox_lib/init.lua",
	"@mc9-lib/import.lua",
	"shared/config.lua",
	"shared/petdata.lua",
}

client_scripts {
    "@PolyZone/client.lua",
    "@PolyZone/BoxZone.lua",
    "@PolyZone/EntityZone.lua",
    "@PolyZone/CircleZone.lua",
    "@PolyZone/ComboZone.lua",

	"client/*.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
	"server/exports.lua",
	"server/sql.lua",
}

files {
	"shared/prices.lua",
	"client/modules/Pet.lua",
	"server/modules/DBPet.lua",
}
