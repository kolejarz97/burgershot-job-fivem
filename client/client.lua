local ESX = exports['es_extended']:getSharedObject()
local lib = exports.ox_lib

local burgershotItems = {
    {label = 'Zrób burgera', item = 'bs_burger', anim = 'PROP_HUMAN_BBQ'},
    {label = 'Nalej Coli', item = 'bs_cola', anim = 'PROP_HUMAN_BBQ'},
    {label = 'Weź pusty kubek', item = 'empty_cup'}
}

local function makeItem(item, anim)
    TaskStartScenarioInPlace(PlayerPedId(), anim, 0, true)
    Wait(1000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('burgershot:makeItem', item)
end

local function giveItem(item, anim)
    TaskStartScenarioInPlace(PlayerPedId(), anim, 0, true)
    Wait(500)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('burgershot:giveItem', item)
end

local function removeItem(item, anim)
    TaskStartScenarioInPlace(PlayerPedId(), anim, 0, true)
    Wait(10)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('burgershot:removeItem', item)
end

CreateThread(function()
    exports.ox_target:addSphereZone({
        coords = vec3(0,0,0),
        radius = 1.3,
        debug = false,
        options = (function()
            local options = {}
            for _, v in pairs(burgershotItems) do
                table.insert(options, {
                    icon = "fa-solid fa-mug-hot",
                    label = v.label,
                    onSelect = function()
                        makeItem(v.item, v.anim)
                    end
                })
            end
            return options
        end)()
    })

    exports.ox_target:addSphereZone({
        name = 'burgershot_bill_customer',
        coords = vec3(-1195.3649, -893.2260, 13.8862),
        radius = 1.3,
        debug = false,
        options = {
            {
                name = 'bill_customer',
                icon = 'fa-solid fa-cash-register',
                label = 'Wystaw rachunek',
                onSelect = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bill_dialog', {
                            title = 'Kwota do zapłaty',
                        }, function(data, menu)
                            local amount = tonumber(data.value)
                            if amount then
                                TriggerServerEvent('burgershot:billPlayer', GetPlayerServerId(closestPlayer), amount)
                            else
                                ESX.ShowNotification('Wprowadź poprawną kwotę')
                            end
                            menu.close()
                        end, function(data, menu)
                            menu.close()
                        end)
                    else
                        ESX.ShowNotification('Brak gracza w pobliżu')
                    end
                end,
            }
        }
    })
end)

RegisterNetEvent('burgershot:payBill', function(amount)
    if type(amount) ~= "number" or amount <= 0 then
        ESX.ShowNotification('Niepoprawna kwota')
        return
    end

    lib.registerContext({
        id = 'pay_bill_ctx',
        title = 'Otrzymałeś rachunek',
        options = {
            {
                title = ('Zapłać $%d'):format(amount),
                onSelect = function()
                    TriggerServerEvent('starbucks:payBillConfirm', amount)
                    ESX.ShowNotification('Zapłaciłeś $' .. amount)
                end
            },
            {
                title = 'Anuluj',
                onSelect = function()
                    lib.hideContext()
                end
            }
        }
    })

    lib.showContext('pay_bill_ctx')
end)

CreateThread(function()
    exports.ox_target:addSphereZone({
    name = 'burgershot_make_cola',
    coords = vec3(-1193.0073, -896.8557, 13.8862),
    radius = 1.3,
    debug = false,
    options = {
        {
            name = 'make_cola',
            icon = 'fa-solid fa-drink',
            label = 'Nalej Coli',
            onSelect = function()
                local playerData = ESX.GetPlayerData()
                if playerData and playerData.job and playerData.job.name == 'burgershot' then
                    -- zapytanie do serwera, czy gracz ma pusty kubek
                    ESX.TriggerServerCallback('burgershot:hasItem', function(hasItem)
                        if hasItem then
                            removeItem('empty_cup')
                            makeItem('bs_cola', 'PROP_HUMAN_BBQ')
                        else
                            ESX.ShowNotification('Potrzebujesz pustego kubka, aby zrobić kawę')
                        end
                    end, 'empty_cup')
                else
                    ESX.ShowNotification('Nie jesteś zatrudniony w tej pracy')
                end
            end   
        }
    }
})

     exports.ox_target:addSphereZone({
        name = 'burgershot_take_cup',
        coords = vec3(-1190.6249, -899.3013, 13.8862),
        radius = 1.3,
        debug = false,
        options = {
            {
                name = 'take_cup',
                label = 'Weź pusty kubek',
                onSelect = function()
                    local playerData = ESX.GetPlayerData()
                    if playerData and playerData.job and playerData.job.name == 'burgershot' then
                        giveItem('empty_cup')
                    else
                        ESX.ShowNotification('Nie jesteś zatrudniony w tej pracy')
                    end
                end
            }
        }
    })

    exports.ox_target:addSphereZone({
        name = 'burgershot_make_burger',
        coords = vec3(-1195.4578, -897.4442, 13.8862),
        radius = 1.3,
        debug = false,
        options = {
            {
                name = 'make_burger',
                icon = 'fa-solid fa-burger',
                label = 'Zrób burgera',
                onSelect = function()
                    local playerData = ESX.GetPlayerData()
                    if playerData and playerData.job and playerData.job.name == 'burgershot' then
                        makeItem('bs_burger', 'PROP_HUMAN_BBQ')
                    else
                        ESX.ShowNotification('Nie jesteś zatrudniony w tej pracy')
                    end
                end
            }
        }
    })
end)

CreateThread(function()
    local blipData = Config.Burgershot.Burgershot.Blip
    local blip = AddBlipForCoord(blipData.coords)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipScale(blip, blipData.scale)
    SetBlipColour(blip, blipData.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Burgershot")
    EndTextCommandSetBlipName(blip)
end)