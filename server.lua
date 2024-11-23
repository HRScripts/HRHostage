-- Events

RegisterNetEvent('HRHostage:on', function(status, targetNetId, netId, killTarget, targetId)
    TriggerClientEvent('HRHostage:on', -1, status, targetNetId, netId, killTarget)

    Player(targetId).state.invBusy = status
end)

RegisterNetEvent('HRHostage:kill', function(netId)
    TriggerClientEvent('HRHostage:kill', -1, netId)
end)

RegisterNetEvent('HRHostage:attachPed', function(targetNetId, netId)
    TriggerClientEvent('HRHostage:attachPed', -1, targetNetId, netId)
end)