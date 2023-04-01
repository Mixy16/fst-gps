ESX = nil
local isLoading = true
local display = false 
local blips_pos = {}
local prev_pos = {}
local time_out = {}

Citizen.CreateThread(function()
	while true do
		Wait(5)
		if ESX ~= nil then
		
		else
			ESX = nil
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		end
	end
end)



exports['qtarget']:Vehicle({
    options = {
        {
            event = "fst-gps:otvoriGps",
            icon = "fas fa-car",
            label = "Prikljuci GPS",
            item = 'gps',
            job = 'police',
        },
    },
    distance = 2.0
  }) 

AddEventHandler("fst-gps:otvoriGps", function()
            local playerData = ESX.GetPlayerData()

        --    if isInVehicle() then 
            if playerData.job.name == "police" then 
                SetNuiFocus(true, true)
                SendNUIMessage({type = 'ui', display = true})
            end 
end)


Citizen.CreateThread(function()
    while isLoading == true do 
        Citizen.Wait(20000)     -- Roughly takes around 20-30 secs to load everything including vehicles 
        local playerData = ESX.GetPlayerData()

        if ESX.IsPlayerLoaded(PlayerId) and playerData.job.name == "police" then 
            print("GPS ucitan.")
            TriggerServerEvent("fiesta-gps:getajAktivneTablice")
            isLoading = false
        end
    end 

end)

RegisterNetEvent("fiesta-gps:updateajTajmer")
AddEventHandler("fiesta-gps:updateajTajmer", function(plate)
    time_out[plate] = time_out[nil]
end)

RegisterNetEvent("fiesta-gps:updateajAktivnePolicajce")
AddEventHandler("fiesta-gps:updateajAktivnePolicajce", function(plate)

    for v,k in pairs(time_out) do 
        if time_out[v] == plate then 
            time_out[plate] = true 
        end
    end
   
end)



RegisterNetEvent("fiesta-gps:getajAktivneTablice")
AddEventHandler("fiesta-gps:getajAktivneTablice", function(plates)
    time_out = plates
    for v,k in pairs(time_out) do
        checkVehicle(v)
    end
end)

RegisterNetEvent('fiesta-gps:plate')
AddEventHandler('fiesta-gps:plate', function(plate)
    checkVehicle(plate)
end)

RegisterNUICallback('searchPlate', function(data, cb)
    local vehicle = ESX.Game.GetVehicles()
    local miss = 0

    for i=1, #vehicle, 1 do 
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle[i])
        
        if vehicleProps.plate == data.plate then 
            local nCheck = 0
            for _ in pairs(time_out) do 
                nCheck=nCheck + 1
            end

            if nCheck >= Config.gpsTajmer then 
                SendNUIMessage({type = "maxPlate"})
            else
                SendNUIMessage({
                    type = "ui",
                    display = false
                  })
            
                SetNuiFocus(false)
                TriggerServerEvent("fiesta-gps", data.plate)
            end
        else 
            miss = miss + 1 
        end 
    end

    if #vehicle == miss then 
        SendNUIMessage({type = "noPlate"})
    end
end)

RegisterNUICallback("removeSearch", function(data, cb)
    local vehicle = ESX.Game.GetVehicles()
    local miss = 0

    for i=1, #vehicle, 1 do 
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle[i])
        
        if vehicleProps.plate == data.plate then 
            TriggerServerEvent("fiesta-gps:removeActivePlate", data.plate)
            SendNUIMessage({
                type = "ui",
                display = false
              })
        
            SetNuiFocus(false)
        else 
            miss = miss + 1 
        end 
    end

    if #vehicle == miss then 
        SendNUIMessage({type = "noPlate"})
    end
end)


RegisterNUICallback("close", function(data, cb)
    SendNUIMessage({
        type = "ui",
        display = false
      })

    SetNuiFocus(false)
end)


function checkVehicle(plate)
    local vehicle = ESX.Game.GetVehicles()

    for i=1, #vehicle, 1 do 
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle[i])
        
        if vehicleProps.plate == plate then 
            TriggerServerEvent("fiesta-gps:setujAktivneTablice", plate)
            time_out[plate] = false
            createVehicleTracker(vehicle[i], plate) 
        end 
    end

end

function triggerajTajmer(plate)
    TriggerServerEvent("fiesta-gps:triggerajTajmer", plate)
end

--function isInVehicle()
--    if Config.uVozilu then 
--        return IsPedInAnyVehicle(PlayerPedId(), false)
--    else
--        return true 
--    end 
--end

function createVehicleTracker(vehicle, plate) 
    triggerajTajmer(plate)

        ESX.ShowNotification(_U('tracker_activated') .. plate)
        Citizen.CreateThread(function()
            while time_out[plate] == false do
                Wait(50)

                if DoesEntityExist(vehicle) then 
           

                    local x, y, z = table.unpack(GetEntityCoords(vehicle))
         

                    if prev_pos == table.unpack(GetEntityCoords(vehicle)) then 
                
                    else 


                        RemoveBlip(blips_pos[plate])
 
                        local new_pos_blip = AddBlipForCoord(x,y,z)
      
                        SetBlipSprite(new_pos_blip, 225)
                        SetBlipDisplay(new_pos_blip, 4)
                        SetBlipColour(new_pos_blip, 1)
                        SetBlipScale(new_pos_blip, 1.0)


                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(_U("blip_text"))
                        EndTextCommandSetBlipName(new_pos_blip)

    
                        blips_pos[plate] = new_pos_blip
                        prev_pos = table.unpack(GetEntityCoords(vehicle))
                    end

                else
                    time_out[plate] = time_out[nil]
                    TriggerServerEvent("fiesta-gps:removeActivePlate", plate)
                    ESX.ShowNotification(_U('tracker_lost') .. plate)
                end
            end 
            RemoveBlip(blips_pos[plate])
            time_out[plate] = time_out[nil]
            TriggerServerEvent("fiesta-gps:removeActivePlate", plate)
            ESX.ShowNotification(_U("tracker_lost") .. plate)
    
        end)
end 



