fx_version 'cerulean'
game 'gta5'

description "Policijski GPS sa NUI-em"
author "m1xy"
version "1.2.0"

ui_page "html/index.html"

client_scripts {
     '@es_extended/locale.lua',
     'locales/en.lua',
     'config.lua',
     'client.lua'
    }

server_scripts {
    'config.lua',
    'server.lua' 
}

files { 
    'html/index.html', 
    'html/police.ttf',
    'html/Oswald-Light.ttf',
    'html/Oswald-Regular.ttf',
    'html/style.css',
    'html/handler.js'
}
