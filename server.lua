local ESX = nil
local time_out = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("fiesta-gps")
AddEventHandler("fiesta-gps", function(plate) 

    local igrac = ESX.GetPlayers()

    for i=1, #igrac, 1 do
        local xPlayer = ESX.GetPlayerFromId(igrac[i])


        if xPlayer.getJob().name == 'police' then
            TriggerClientEvent("fiesta-gps:plate", igrac[i], plate)

        end

    end
end)

RegisterServerEvent("fiesta-gps:setujAktivneTablice")
AddEventHandler("fiesta-gps:setujAktivneTablice", function(plate)
    time_out[plate] = false
end)

RegisterServerEvent("fiesta-gps:removeActivePlate")
AddEventHandler("fiesta-gps:removeActivePlate", function(plate)
    time_out[plate] = time_out[nil]
    local igrac = ESX.GetPlayers()

    for i=1, #igrac, 1 do
        local xPlayer = ESX.GetPlayerFromId(igrac[i])


        if xPlayer.getJob().name == 'police' then
            TriggerClientEvent("fiesta-gps:updateajAktivnePolicajce", igrac[i], plate)
        end

    end

end)

RegisterServerEvent("fiesta-gps:getajAktivneTablice")
AddEventHandler("fiesta-gps:getajAktivneTablice", function()
    TriggerClientEvent("fiesta-gps:getajAktivneTablice", source, time_out)
end)


RegisterServerEvent("fiesta-gps:triggerajTajmer")
AddEventHandler("fiesta-gps:triggerajTajmer", function(plate)
    local igrac = ESX.GetPlayers()
    local startTimer = os.time() + Config.gpsTajmer
    Citizen.CreateThread(function()
        while os.time() < startTimer and time_out[plate] ~= nil do 
            Citizen.Wait(5)
        end

        for i=1, #igrac, 1 do
            local xPlayer = ESX.GetPlayerFromId(igrac[i])
    
    
            if xPlayer.getJob().name == 'police' then
                TriggerClientEvent("fiesta-gps:updateajTajmer", igrac[i], plate)
            end
    
        end
    
    end)
end)

