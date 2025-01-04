server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'WALKER'
description 'Walker Bike Rent Script'
version '1.0.0'

client_scripts {
    'client.lua',
    'config.lua'
}

server_scripts {
    'server.lua',
    'config.lua'
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}
