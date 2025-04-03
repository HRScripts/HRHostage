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

config.animations = {
    aimAtPed = {
        anim = 'perp_idle',
        dict = 'anim@gangops@hostage@'
    },
    hostagedPedAnim = {
        anim = 'handsup_base',
        dict = 'missminuteman_1ig_2'
    }
}

config.hostageWithNoAmmo = true

return config --[[@as HRHostageConfig]]