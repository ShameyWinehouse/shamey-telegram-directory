fx_version "adamant"
games {"rdr3"}
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

lua54 "yes"

client_scripts {
	"client/*.lua"
}
server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/*.lua"
}
shared_script "config.lua"

files {
	'ui/dist/*',
    'ui/dist/**/*',
}

ui_page 'ui/dist/index.html'

dependencies {
	"vorp_core",
	"oxmysql",
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'