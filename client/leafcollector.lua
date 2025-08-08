local leafPilesCollected = 0
local isCollectingLeaves = false
local isLeafJobActive = false
local jobBlip = nil
local pileOrder = {}
local currentPileIndex = 1

RegisterNetEvent('uwv_job:startLeafCollector', function()
    isLeafJobActive = true
    leafPilesCollected = 0
    isCollectingLeaves = false
    pileOrder = {}
    for i = 1, #Config.LeafCollector.leafPiles do pileOrder[i] = i end
    shuffle(pileOrder)
    currentPileIndex = 1
    CreateCurrentLeafPileBlip()
end)

function CreateCurrentLeafPileBlip()
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
    end
    local i = pileOrder[currentPileIndex]
    local pile = Config.LeafCollector.leafPiles[i]
    jobBlip = AddBlipForCoord(pile.x, pile.y, pile.z)
    SetBlipSprite(jobBlip, Config.Blips.leafcollector.sprite)
    SetBlipColour(jobBlip, Config.Blips.leafcollector.color)
    SetBlipScale(jobBlip, Config.Blips.leafcollector.scale)
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Leaf Pile')
    EndTextCommandSetBlipName(jobBlip)
end

CreateThread(function()
    while true do
        Wait(0)
        if not isLeafJobActive then
            Wait(1000)
            goto continue
        end
        if currentPileIndex > #pileOrder then goto continue end
        local i = pileOrder[currentPileIndex]
        local pile = Config.LeafCollector.leafPiles[i]
        DrawMarker(2, pile.x, pile.y, pile.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, true, 2, false, nil,
            nil, false)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distanceToPile = #(playerCoords - pile)
        if distanceToPile < 2.0 then
            if not isCollectingLeaves then
                isCollectingLeaves = true
            end
            DrawText3D(pile.x, pile.y, pile.z + 0.5, 'Druk op E om de bladeren van deze stapel te verzamelen')
            if IsControlJustReleased(0, 38) then
                CollectLeafPile()
            end
        else
            if isCollectingLeaves then
                isCollectingLeaves = false
            end
        end
        ::continue::
    end
end)

function CollectLeafPile()
    local playerPed = PlayerPedId()
    local startTime = GetGameTimer()
    local taskTime = Config.TaskTime.leafcollector

    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_LEAF_BLOWER', 0, true)

    ESX.ShowNotification('Bladeren verzamelen...')

    while GetGameTimer() - startTime < taskTime do
        Wait(100)
        if not IsPedUsingScenario(playerPed, 'WORLD_HUMAN_GARDENER_LEAF_BLOWER') then
            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_LEAF_BLOWER', 0, true)
        end
    end

    ClearPedTasks(playerPed)
    ClearAreaOfObjects(GetEntityCoords(PlayerPedId()), 2.0, 0)
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    leafPilesCollected = leafPilesCollected + 1
    ESX.ShowNotification('Bladeren verzameld! (' .. leafPilesCollected .. '/' .. #Config.LeafCollector.leafPiles .. ')')
    ReportJobProgress()
    currentPileIndex = currentPileIndex + 1
    if currentPileIndex <= #pileOrder then
        CreateCurrentLeafPileBlip()
    end
    if leafPilesCollected >= #Config.LeafCollector.leafPiles then
        CompleteJob()
        ESX.ShowNotification('Alle bladeren zijn verzameld!')
    end
end

RegisterNetEvent('uwv_job:quitLeafCollector', function()
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
    end
    jobBlip = nil
    leafPilesCollected = 0
    isCollectingLeaves = false
    isLeafJobActive = false
    pileOrder = {}
    currentPileIndex = 1
    ESX.ShowNotification('Bladeren verzamelaar job afgerond.')
end)
