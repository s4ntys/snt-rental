local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("snt-rental:vehiclelist", function()
    for i = 1, #Config.vehiclelist do
        if Config.setupMenu == 'snt-context' then
            TriggerEvent('snt-context:sendMenu', {
                {
                    id = Config.vehiclelist[i].model,
                    header = Config.vehiclelist[i].name,
                    txt = "$"..Config.vehiclelist[i].price..".00",
                    params = {
                        event = "snt-rental:attemptvehiclespawn",
                        args = {
                            id = Config.vehiclelist[i].model,
                            price = Config.vehiclelist[i].price,
                        }
                    }
                },
            })
        elseif Config.setupMenu == 'qb-menu' then
            local MenuOptions = {
                    {

                        header = "Auto požičovna", ------- You can change the name of the rental company here
                        isMenuHeader = true
                    },
            }
            for k, v in pairs(Config.vehiclelist) do


            MenuOptions[#MenuOptions+1] = {
                    header = "<h8>"..v.name.."</h>",
                    txt = "$"..v.price..".00",
                params = {
            event = "snt-rental:attemptvehiclespawn",
            args = {
                id = v.model,
                price = v.price
            }
                    }
             }
             end
            exports['qb-menu']:openMenu(MenuOptions)
        end
    end
end)

RegisterNetEvent("snt-rental:attemptvehiclespawn", function(vehicle)
    TriggerServerEvent("snt-rental:attemptPurchase",vehiclelist.id, vehiclelist.price)
end)

RegisterNetEvent("snt-rental:attemptvehiclespawnfail", function()
    QBCore.Functions.Notify("Nemaš peniaze.", "error")       ------- ## Translation : You have no money
end)

local PlayerName = nil

RegisterNetEvent("snt-rental:giverentalpaperClient", function(model, plate, name)

    local info = {
        data = "Model : "..tostring(model).." | Plate : "..tostring(plate).."" 
    }
    TriggerServerEvent('QBCore:Server:AddItem', "rentalpapers", 1, info)
end)

RegisterNetEvent("snt-rental:returnvehicle", function()
    local car = GetVehiclePedIsIn(PlayerPedId(),true)

    if car ~= 0 then
        local plate = GetVehicleNumberPlateText(car)
        local vehname = string.lower(GetDisplayNameFromVehicleModel(GetEntityMode(car)))
        if string.fing(tostring(plalte), "SNT") then
            QBCore.Functions.TriggerCallback('snt-rental:server:hasrentalpapers', function(HasItem)
                if HasItem then
                    TriggerServerEvent("QBCore:Server:RemoveItem", "rentalpapers", 1)
                    TriggerServerEvent('snt-rental:server:payreturn', vehname)
                    QBCore.Functions.DeleteVehicle(car)
                else
                    QBCore.Functions.Notify("Vozidlo bez dokladov nemôžem prevziať.", "error") --- I cannot take a vehicle without its papers.
                end
            end)
        else
          QBCore.Functions.Notify("Toto nie je prenajaté vozidlo.", "error") ---   This is not a rented vehicle.
        end
    else
        QBCore.Functions.Notify("Nevidím žiadne prenajaté vozidlo, uistite sa, že je nablízku.", "error") ---- I don't see any rented vehicle, make sure its nearby.
    end
end)

RegisterNetEvent("snt-rental:vehiclespawn", function(data,cb)
    local model = data
    local closestDist = 10000
    local closestSpawn = nil
    local pcoords = GetEntityCoords(PlayerPedId())

    for i, v in ipairs(Config.vehiclespawn) do
        local dist = #(v.workSpawn.coords - pcoords)

        if dist < closestDist then
            closestDist = dist
            closestSpawn = v.workSpawn
        end
    end

    RequestModel(model)
    while not HasModeLoaded(model) do
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(model)

    QBCore.Functions.SpawnVehicle(mode, function(veh)
        SetVehicleNumberPlateText(veh, "SNT"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, closestSpawn.heading)
        exports['LegacyFuel']:SetFuel(veh, 100.0) ---- This is LegacyFuel Basic QBCore Fuel System !!!  You can change it if you use something else
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = QBCore.Functions.GetPlate(veh)
    end, closestDist.coords, true)

    local plateText = GetVehicleNumberPlateText(veh)
    TriggerServerEvent("snt-rental:giverentalpaperServer",model ,plateText)

    local timeout = 10
    while not NetworkDoesEntityExistWithNetworkId(veh) and timeout > 0 do
        timeout = timeout - 1
        Wait(1000)
    end
end)

AddEventHandler("qb-inventory:itemUsed", function(item, info)
    if item == "rentalpapers" then

        local plyPed = PlayerPedId()
        local plyveh = GetVehiclePedIsIn(plyPed, false)
            data = json.decode(info)
            local vin = GetVehicleNumberPlateText(plyVeh)
            local isRental = vin ~= nil and string.sub(vin, 2, 3) == "SNT"
            if isRental then
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                QBCore.Functions.Notify("Dostal si kľúče od vozidla.", "success")         ------ You received the vehicle keys.
              else
                QBCore.Functions.Notify("Tento prenájom neexistuje", "success")         ------ This rental does not exist
              end
          end
    end)
    
    
-- BLIP MAPS FOR RENTAL !!!!
CreateThread(function()
    for _, rental in pairs(Config.Locations["rentalstations"]) do
        local blip = AddBlipForCoord(rental.coords.x, rental.coords.y, rental.coords.z)
        SetBlipSprite(blip, 326)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.5)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(rental.label)
        EndTextCommandSetBlipName(blip)
    end
  end)


-- Exports to Polyzone Box # Config could also work # MoneSuper
exports['qb-target']:AddBoxZone("NewRentalMenu4", vector3(1152.78, -373.01, 67.14), 1.4, 1.4, {
    name="NewRentalMenu4",
    heading=8,
    debugPoly=false,
    minZ = 64.34,
    maxZ = 68.34,
    }, {
        options = {
            {
                event = "snt-rental:vehiclelist",
                icon = "fas fa-circle",
                label = "Požičovna aut",  -----  Rent vehicle
            },
            {
                event = "snt-rental:returnvehicle",
                icon = "fas fa-circle",
                label = "Vrátit auto (Získajte späť 50% z pôvodnej ceny)",   ---- Return Vehicle (Receive Back 50% of original price)
            },
        },
       distance = 3.5
  })
  
  exports['qb-target']:AddBoxZone("NewRentalMenu5", vector3(463.51, -1676.57, 29.29), 2, 2, {
    name="NewRentalMenu5",
    heading=0,
    debugPoly=false,
    minZ = 26.89,
    maxZ = 30.89,
    }, {
        options = {
            {
                event = "snt-rental:vehiclelist",
                icon = "fas fa-circle",
                label = "Požičovna aut",
            },
            {
                event = "snt-rental:returnvehicle",
                icon = "fas fa-circle",
                label = "Vrátit auto (Získajte späť 50% z pôvodnej ceny)",
            },
        },
        distance = 3.5
  })
  
  exports['qb-target']:AddBoxZone("NewRentalMenu6", vector3(-1442.28, -674.07, 26.48), 2, 2, {
    name="NewRentalMenu6",
    heading=305,
    debugPoly=false,
    minZ = 24.48,
    maxZ = 28.48,
    }, {
        options = {
            {
                event = "snt-rental:vehiclelist",
                icon = "fas fa-circle",
                label = "Požičovna aut",
            },
            {
                event = "snt-rental:returnvehicle",
                icon = "fas fa-circle",
                label = "Vrátit auto (Získajte späť 50% z pôvodnej ceny)",
            },
        },
        job = {"all"},
        distance = 3.5
  })
