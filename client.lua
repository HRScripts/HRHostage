local HRLib <const>, Translation <const> = HRLib --[[@as HRLibClientFunctions]], Translation
local config <const> = HRLib.require(('@%s/config.lua'):format(GetCurrentResourceName()))

-- Functions

local on = function(status, killTarget, playerId)
    local targetPed <const>, ped <const> = HRLib.ClosestPed(playerId).ped --[[@as integer]], GetPlayerPed(GetPlayerFromServerId(playerId))

    if status == 'start' then
        HRLib.RequestAnimDict('anim@gangops@hostage@')

        AttachEntityToEntity(targetPed, ped, 0, -0.24, 0.11, 0.0, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
        TaskPlayAnim(ped, 'anim@gangops@hostage@', 'perp_idle', 8.0, -8.0, -1, 120, 0, false, false, false)
        TaskPlayAnim(targetPed, 'anim@gangops@hostage@', 'victim_fail', 8.0, -8.0, -1, 120, 0, false, false, false)

        if IsPedAPlayer(targetPed) then
            SetPlayerControl(ped, false, 0)
        end
    elseif status == 'stop' then
        DetachEntity(targetPed, true, false)
        ClearPedTasks(targetPed)
        ClearPedTasks(ped)

        if IsPedAPlayer(targetPed) then
            SetPlayerControl(ped, true, 0)
        end

        HRLib.hideTextUI()
    end

    if killTarget then
        SetEntityHealth(targetPed, 0)
    end
end

-- Commands

HRLib.RegCommand(config.commandName, function(_, _, IPlayer)
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
                        on('start', nil, IPlayer.source)

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
                    on('stop')
                else
                    while hostaged do
                        if IsEntityDead(IPlayer.ped) or IsEntityDead(targetPed) then
                            on('stop')

                            hostaged = false

                            return
                        end

                        if IsControlJustPressed(0, HRLib.Keys[config.controls.release]) then
                            on('stop')

                            hostaged = false

                            return
                        elseif IsControlJustPressed(0, HRLib.Keys[config.controls.kill]) then
                            SetPedShootsAtCoord(IPlayer.ped, 0.0, 0.0, 0.0, false)
                            on('stop', true)

                            hostaged = false

                            return
                        end

                        if not IsEntityAttached(targetPed) and hostaged then
                            AttachEntityToEntity(targetPed, IPlayer.ped, 0, -0.24, 0.11, 0.0, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
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
end)