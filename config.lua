local config <const> = {}

config.language = 'en'

config.radius = 2.0 -- Radius for searching a player

config.controls = {
    release = 'E',
    kill = 'K'
}

config.access = {
    command = {
        enable = true,
        commandName = 'takehostage'
    },
    key = {
        enable = true,
        control = 'F9'
    }
}

config.weapons = {
    'WEAPON_PISTOL',
    'WEAPON_COMBATPISTOL',
    'WEAPON_MINISMG'
}

return config --[[@as HRHostageConfig]]