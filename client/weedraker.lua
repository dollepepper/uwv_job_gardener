local weedPilesRaked = 0
local isRakingWeeds = false
local jobBlip = nil
local awaitingMinigame = false
local isWeedJobActive = false
local rakedPiles = {}
local pileOrder = {}
local currentPileIndex = 1

RegisterNetEvent('uwv_job:startWeedRaker', function()
    isLeafJobActive = false
    isWeedJobActive = true
    weedPilesRaked = 0
    isRakingWeeds = false
    awaitingMinigame = false
    rakedPiles = {}
    pileOrder = {}
    for i = 1, #Config.WeedRaker.weedPiles do pileOrder[i] = i end
    shuffle(pileOrder)
    currentPileIndex = 1
    CreateCurrentWeedPileBlip()
    ESX.ShowNotification('Start met het plukken van het onkruid op de aangegeven locatie!')
end)

function CreateCurrentWeedPileBlip()
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
    end
    local i = pileOrder[currentPileIndex]
    local pile = Config.WeedRaker.weedPiles[i]
    jobBlip = AddBlipForCoord(pile.x, pile.y, pile.z)
    SetBlipSprite(jobBlip, Config.Blips.weedraker.sprite)
    SetBlipColour(jobBlip, Config.Blips.weedraker.color)
    SetBlipScale(jobBlip, Config.Blips.weedraker.scale)
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Weed Pile')
    EndTextCommandSetBlipName(jobBlip)
end

CreateThread(function()
    while true do
        Wait(0)
        if not isWeedJobActive then
            Wait(1000)
            goto continue
        end
        if currentPileIndex > #pileOrder then goto continue end
        local i = pileOrder[currentPileIndex]
        if not rakedPiles[i] then
            local pile = Config.WeedRaker.weedPiles[i]
            DrawMarker(2, pile.x, pile.y, pile.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, true, 2, false,
                nil, nil, false)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distanceToPile = #(playerCoords - pile)
            if distanceToPile < 2.0 then
                if not isRakingWeeds then
                    isRakingWeeds = true
                end
                DrawText3D(pile.x, pile.y, pile.z + 0.5, 'Druk op E om het onkruid te verwijderen')
                if IsControlJustReleased(0, 38) and not awaitingMinigame then
                    awaitingMinigame = true
                    rakedPiles._current = i
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'show' })
                end
            else
                if isRakingWeeds then
                    isRakingWeeds = false
                end
            end
        end
        ::continue::
    end
end)

function RakeWeedPile()
    local i = rakedPiles._current
    if not i or rakedPiles[i] then return end
    rakedPiles[i] = true
    -- Animation
    local playerPed = PlayerPedId()
    local startTime = GetGameTimer()
    local taskTime = Config.TaskTime.weedraker

    
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)

    ESX.ShowNotification('Onkruid verwijderen...')

    while GetGameTimer() - startTime < taskTime do
        Wait(100)
        if not IsPedUsingScenario(playerPed, 'WORLD_HUMAN_GARDENER_PLANT') then
            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
        end
    end

    ClearPedTasks(playerPed)
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    weedPilesRaked = weedPilesRaked + 1
    ESX.ShowNotification('Onkruid verwijderd! (' .. weedPilesRaked .. '/' .. #Config.WeedRaker.weedPiles .. ')')
    ReportJobProgress()
    currentPileIndex = currentPileIndex + 1
    if currentPileIndex <= #pileOrder then
        CreateCurrentWeedPileBlip()
    end
    if weedPilesRaked >= #Config.WeedRaker.weedPiles then
        CompleteJob()
        ESX.ShowNotification('Al het onkruid is verwijderd!')
        TriggerEvent('uwv_job:jobCompleted')
    end
    rakedPiles._current = nil
end

RegisterNetEvent('uwv_job:quitWeedRaker', function()
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
    end
    jobBlip = nil
    weedPilesRaked = 0
    isRakingWeeds = false
    awaitingMinigame = false
    isWeedJobActive = false
    rakedPiles = {}
    pileOrder = {}
    currentPileIndex = 1
    ESX.ShowNotification('Weed raker job afgerond.')
end)

RegisterNUICallback('weedrakeResult', function(data, cb)
    SetNuiFocus(false, false)
    if data and data.success then
        RakeWeedPile()
    else
        ESX.ShowNotification('Mislukt! Probeer het opnieuw.')
    end
    awaitingMinigame = false
    cb('ok')
end)
