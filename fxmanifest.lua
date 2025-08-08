fx_version 'cerulean'
game 'gta5'

author 'dollepepper'
description 'UWV Job Script'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/lawnmower.lua',
    'client/leafcollector.lua',
    'client/weedraker.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'es_extended',
}

ui_page 'html/weedrake.html'

files {
    'html/weedrake.html',
    'html/weedrake.js',
    'html/weedrake.css',
}
