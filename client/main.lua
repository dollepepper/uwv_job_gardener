local isOnJob = false

ESX = exports['es_extended']:getSharedObject()

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

CreateThread(function()
    local blipCoords = Config.Locations.jobStart.coords
    local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
    SetBlipSprite(blip, Config.Locations.jobStart.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Locations.jobStart.blip.scale)
    SetBlipColour(blip, Config.Locations.jobStart.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Locations.jobStart.blip.label)
    EndTextCommandSetBlipName(blip)
end)

CreateThread(function()
    Wait(2000)

    local modelHash = GetHashKey('a_m_m_hillbilly_01')
    RequestModel(modelHash)
    repeat Wait(0) until HasModelLoaded(modelHash)

    local coords = Config.Locations.jobStart.coords
    local npc = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, 111.0, false, true)

    if DoesEntityExist(npc) then
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'uwv_job_start',
                icon = 'fas fa-seedling',
                label = 'Start UWV Gardener Job',
                canInteract = function()
                    return not isOnJob
                end,
                onSelect = function()
                    RequestJob()
                end
            },
            {
                name = 'uwv_job_quit',
                icon = 'fas fa-times',
                label = 'Quit Current Job',
                canInteract = function()
                    return isOnJob
                end,
                onSelect = function()
                    TriggerServerEvent('uwv_job:quitJob')
                end
            }
        })
    end

    SetModelAsNoLongerNeeded(modelHash)
end)

function RequestJob()
    if isOnJob then
        ESX.ShowNotification('Je bent al aan het werken!')
        return
    end
    TriggerServerEvent('uwv_job:requestJob')
end

RegisterNetEvent('uwv_job:assignJob', function(jobType)
    currentJob = jobType
    lastJob = jobType
    isOnJob = true
    if jobType == 'lawnmower' then
        TriggerEvent('uwv_job:startLawnMower')
    elseif jobType == 'leafcollector' then
        TriggerEvent('uwv_job:startLeafCollector')
    elseif jobType == 'weedraker' then
        TriggerEvent('uwv_job:startWeedRaker')
    end
    ESX.ShowNotification('Started ' .. jobType .. ' job! Type /quitjob om de job te stoppen.')
end)



RegisterCommand('quitjob', function()
    TriggerServerEvent('uwv_job:quitJob')
end)

function ReportJobProgress()
    if isOnJob then
        TriggerServerEvent('uwv_job:updateProgress')
    end
end

function CompleteJob()
    if isOnJob then
        TriggerServerEvent('uwv_job:completeJob')
    end
end


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

function IsPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool('CVehicle')
    local closestVehicle = nil
    local closestDistance = 999.0
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(playerCoords - vehicleCoords)
        if distance < closestDistance then
            closestDistance = distance
            closestVehicle = vehicles[i]
        end
    end
    return closestVehicle, closestDistance
end

RegisterNetEvent('uwv_job:clientQuitJob', function(jobType)
    if not isOnJob then
        ESX.ShowNotification('Je bent niet aan het werken!')
        return
    end
    if jobType == 'lawnmower' then
        TriggerEvent('uwv_job:quitLawnMower')
    elseif jobType == 'leafcollector' then
        TriggerEvent('uwv_job:quitLeafCollector')
    elseif jobType == 'weedraker' then
        TriggerEvent('uwv_job:quitWeedRaker')
    end
    currentJob = nil
    isOnJob = false
end)
