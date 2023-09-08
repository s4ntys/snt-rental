local QBCore = exports['qb-core']:GetCoreObject()

egisterServerEvent('snt-rental:attemptPurchase', function(car,price)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local cash = Player.PlayerData.money.cash
    if cash >= price then
        Player.Functions.RemoveMoney("cash",price,"rentals")
        TriggerClientEvent('snt-rental:vehiclespawn', source, car)
        TriggerClientEvent('QBCore:Notify', src, car .. " bola prenajatá za $" .. price .. ", vrátiť, aby ste získali 50 % celkových nákladov.", "success")             ------has been rented for $ return it in order to receive 50% of the total costs. 
    else
        TriggerClientEvent('snt-rental:attemptvehiclespawnfail', source)
    end
end)

RegisterServerEvent('snt-rental:giverentalpaperServer', function(model, plateText)
    local src = source
    local PlayerData = QBCore.Functions.GetPlayer(src)
    local info = {
        label = plateText
    }
    PlayerData.Functions.AddItem('rentalpapers', 1, false, info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rentalpapers'], "add")
end)

RegisterServerEvent('snt-rental:server:payreturn', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    for k, v in pairs(Config.vehiclelist) do
        if string.lower(v.model) == model then
            local payment = v.price / 2
            Player.Functions.AddMoney("cash",payment,"rental-return")
            TriggerClientEvent('QBCore:Notify', src, "Vrátil si prenajaté vozidlo a dostal si $" .. payment .. " späť!", "success") -----You have returned your rented vehicle and received $ in return.
        end
    end
end)

QBCore.Functions.CreateCallback('snt-rental:server:hasrentalpapers', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Item = Playre.Functions.GetItemByName("rentalpapers")
    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)