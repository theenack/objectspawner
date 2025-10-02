fx_version 'cerulean'
games { 'gta5' }

author 'Enack'
description 'objectspawner '
version '1.0.0'

shared_scripts {
}

client_scripts {
    -- '@PolyZone/client.lua',
    -- '@PolyZone/BoxZone.lua',
    'config.lua',
    'client/client.lua',
    'client/spawnableobjs.lua',
}

server_scripts {
    'config.lua',
    'server/server.lua',
}

ui_page 'ui/index.html'
files {
	'ui/index.html',
	'ui/*.css',
	'ui/*.js',
	'ui/*.png',
}