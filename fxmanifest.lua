fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'HRHostage'
author 'HRScripts Development'
description 'Take Hostage Script'
repository 'https://github.com/HRScripts/HRHostage'
version '1.0.2'

shared_script '@HRLib/import.lua'

client_script 'client.lua'

server_script 'server.lua'

files {
    'translation.lua',
    'config.lua'
}

dependency 'HRLib'