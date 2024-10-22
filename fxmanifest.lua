fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'HRHostage'
author 'HRScripts Development'
description 'Take Hostage Script'
version '1.0.0'

shared_script '@HRLib/import.lua'

client_script 'client.lua'

files {
    'translation.lua',
    'config.lua'
}

dependency 'HRLib'