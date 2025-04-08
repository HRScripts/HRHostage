local HRLib <const>, Translation <const> = HRLib, Translation --[[@as HRHostageTranslation]]
local config <const> = HRLib.require(('@%s/config.lua'):format(GetCurrentResourceName())) --[[@as HRHostageConfig]]

-- Functions

local onEvent = function(status, targetNetId, netId, killTarget)
    TriggerServerEvent('HRHostage:on', status, targetNetId, netId, killTarget, GetPlayerServerId(NetworkGetPlayerIndexFromPed(NetworkGetEntityFromNetworkId(targetNetId))))
end

local cmdFun = function(_, _, IPlayer)
    local closestPed <const> = HRLib.ClosestPed()
    if closestPed then
        local targetPed <const>, distance <const>, hostaged = closestPed.ped, closestPed.distance, nil
        if not IsEntityPositionFrozen(targetPed) and distance <= 2.0 then
            if IsEntityDead(targetPed) and not IsPedInAnyVehicle(targetPed, false) then
                HRLib.Notify(Translation.fail_dead_ped, 'error')

                hostaged = false
            elseif IsEntityDead(targetPed) and IsPedInAnyVehicle(targetPed, false) then
                HRLib.Notify(Translation.fail_dead_ped_in_veh, 'error')

                hostaged = false
            elseif IsPedInAnyVehicle(targetPed, false) and not IsEntityDead(targetPed) then
                HRLib.Notify(Translation.fail_ped_in_vehicle, 'error')

                hostaged = false
            else
                for i=1, #config.weapons do
                    if GetSelectedPedWeapon(IPlayer.ped) == joaat(config.weapons[i]) and HasPedGotWeapon(IPlayer.ped, joaat(config.weapons[i]), false) then
                        onEvent(true, NetworkGetNetworkIdFromEntity(targetPed), NetworkGetNetworkIdFromEntity(IPlayer.ped))

                        hostaged = true

                        break
                    else
                        if i == #config.weapons then
                            HRLib.Notify(Translation.fail_no_weapon)

                            hostaged = false

                            break
                        end
                    end
                end
            end

            while hostaged == nil do
                Wait(10)
            end

            if hostaged == true then
                HRLib.showTextUI(Translation.controlsDescription:format(config.controls.release, config.controls.kill))

                if IsEntityDead(IPlayer.ped) then
                    onEvent(false)
                else
                    while hostaged do
                        if IsEntityDead(IPlayer.ped) or IsEntityDead(targetPed) then
                            onEvent(false, NetworkGetNetworkIdFromEntity(targetPed), NetworkGetNetworkIdFromEntity(IPlayer.ped))

                            hostaged = false

                            return
                        end

                        if IsControlJustPressed(0, HRLib.Keys[config.controls.release]) then
                            onEvent(false, NetworkGetNetworkIdFromEntity(targetPed), NetworkGetNetworkIdFromEntity(IPlayer.ped))

                            hostaged = false

                            return
                        elseif IsControlJustPressed(0, HRLib.Keys[config.controls.kill]) then
                            if GetPedAmmoByType(IPlayer.ped, GetPedAmmoTypeFromWeapon(IPlayer.ped, GetSelectedPedWeapon(IPlayer.ped))) >= 1 then
                                SetPedShootsAtCoord(IPlayer.ped, 0.0, 0.0, 0.0, false)
                                onEvent(false, NetworkGetNetworkIdFromEntity(targetPed), NetworkGetNetworkIdFromEntity(IPlayer.ped), true)

                                hostaged = false

                                return
                            else
                                HRLib.Notify(Translation.noWeaponAmmo, 'error')
                            end
                        end

                        if not IsEntityAttached(targetPed) and hostaged then
                            TriggerServerEvent('HRHostage:attachPed', PedToNet(targetPed), PedToNet(IPlayer.ped))
                        end

                        Wait(4)
                    end
                end
            end
        else
            HRLib.Notify(Translation.fail_no_ped_around, 'error')
        end
    else
        HRLib.Notify(Translation.fail_no_ped_around, 'error')
    end
end

-- Events

RegisterNetEvent('HRHostage:on', function(status, targetNetId, netId, killTarget)
    local targetPed <const>, ped <const> = NetworkGetEntityFromNetworkId(targetNetId), NetworkGetEntityFromNetworkId(netId)

    if status then
        HRLib.RequestAnimDict({ config.animations.aimAtPed.dict, config.animations.hostagedPedAnim.dict })
        AttachEntityToEntity(targetPed, ped, 0, -0.24, 0.11, 0.0, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
        TaskPlayAnim(ped, config.animations.aimAtPed.dict, config.animations.aimAtPed.anim, 8.0, 8.0, -1, 63, 0, false, false, false)
        TaskPlayAnim(targetPed, config.animations.hostagedPedAnim.dict, config.animations.hostagedPedAnim.anim, 8.0, 8.0, -1, 2, 0, false, false, false)

        if IsPedAPlayer(targetPed) then
            SetPlayerControl(NetworkGetPlayerIndexFromPed(targetPed), false, 1 << 8)
        end
    else
        DetachEntity(targetPed, true, false)
        ClearPedTasks(targetPed)
        ClearPedTasks(ped)

        if config.animations.releasePed.kidnapperPed.enable then
            HRLib.RequestAnimDict(config.animations.releasePed.kidnapperPed.dict)
            TaskPlayAnim(ped, config.animations.releasePed.kidnapperPed.dict, config.animations.releasePed.kidnapperPed.anim, 8.0, 8.0, -1, 4, 0, false, false, false)
        end

        if config.animations.releasePed.hostagedPed.enable then
            HRLib.RequestAnimDict(config.animations.releasePed.hostagedPed.dict)
            TaskPlayAnim(targetPed, config.animations.releasePed.hostagedPed.dict, config.animations.releasePed.hostagedPed.anim, 8.0, 8.0, -1, 4, 0, false, false, false)
        end

        if IsPedAPlayer(targetPed) then
            SetPlayerControl(NetworkGetPlayerIndexFromPed(targetPed), true, 1 << 8)
        end

        HRLib.hideTextUI()
    end

    if killTarget then
        SetEntityHealth(targetPed, 0)
    end
end)

RegisterNetEvent('HRHostage:kill', function(netId)
    SetEntityHealth(NetworkGetEntityFromNetworkId(netId), 0)
end)

RegisterNetEvent('HRHostage:attachPed', function(targetNetId, netId)
    AttachEntityToEntity(NetworkGetEntityFromNetworkId(targetNetId), NetworkGetEntityFromNetworkId(netId), 0, -0.24, 0.11, 0.0, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
end)

-- Commands

if config.access.command.enable then
    HRLib.RegCommand(config.access.command.commandName, cmdFun)
end

if config.access.key.enable then
    HRLib.RegCommand('+takeAHostage', cmdFun)
    RegisterKeyMapping('+takeAHostage', Translation.controlDescription, 'keyboard', config.access.key.control)
end