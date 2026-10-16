ESX = exports['es_extended']:getSharedObject()

local bills = {}

RegisterServerEvent('burgershot:makeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and item then
        xPlayer.addInventoryItem(item, 1)
    end
end)

RegisterServerEvent('burgershot:giveItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and item then
        xPlayer.addInventoryItem(item, 1)
    end
end)

RegisterServerEvent('burgershot:removeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and item then
        xPlayer.removeInventoryItem(item, 1)
    end
end)

ESX.RegisterServerCallback('burgershot:hasItem', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local count = xPlayer.getInventoryItem(item).count
        cb( count > 0)
    else
        cb(false)
    end
end)

RegisterServerEvent('burgershot:billPlayer', function(targetId, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if xPlayer and xTarget and amount and  amount > 0 then
        bills[targetId] = {amount = amount, sender = src}
        TriggerClientEvent('burgershot:payBill', targetId, amount)
    end
end)

RegisterServerEvent('burgershot:payBillConfirm')
AddEventHandler('burgershot:payBillConfirm', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not bills[src] or bills[src].amount ~= amount then
        TriggerClientEvent('esx:showNotification', src, 'Nie znaleziono rachunku lub nieprawidłowa kwota')
        return
    end

    local target = ESX.GetPlayerFromId(bills[src].sender)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        if target then
            target.addMoney(amount)
            TriggerClientEvent('esx:showNotification', target.source, 'Otrzymałeś $' .. amount ..' za sprzedaż')
        end
        bills[src] = nil
        TriggerClientEvent('esx:showNotification', src, 'Zapłacono rachunek $' ..amount)
    else
        TriggerClientEvent('esx:showNotofication', src, 'Nie masz wystarczająco gotówki')
    end
end)