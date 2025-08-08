local lawnMowerVehicle = nil
local currentLawnArea = 1
local lawnAreasCompleted = 0
local jobBlip = nil
local mowerBlip = nil
local markerActive = false
local isReturningMower = false
local parkingBlip = nil
local areaOrder = {}
local spawnedGrass = {}

local mowerParkingSpot = Config.LawnMower.spawnPoint

RegisterNetEvent('uwv_job:startLawnMower', function()
    ESX.Game.SpawnVehicle('mower', Config.LawnMower.spawnPoint, Config.LawnMower.spawnPoint.w, function(vehicle)
        lawnMowerVehicle = vehicle
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleEngineOn(vehicle, false, true, true)
        mowerBlip = AddBlipForEntity(vehicle)
        SetBlipSprite(mowerBlip, Config.Blips.lawnmower.sprite)
        SetBlipColour(mowerBlip, Config.Blips.lawnmower.color)
        SetBlipScale(mowerBlip, Config.Blips.lawnmower.scale)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blips.lawnmower.label)
        EndTextCommandSetBlipName(mowerBlip)
        ESX.ShowNotification('Grasmaaier gespawnt! Stap in het voertuig en begin met maaien.')
    end)
    areaOrder = {}
    for i = 1, #Config.LawnMower.lawnAreas do areaOrder[i] = i end
    shuffle(areaOrder)
    currentLawnArea = 1
    lawnAreasCompleted = 0
    markerActive = true
    isReturningMower = false
    SpawnGrassForCurrentArea()
end)

function CreateParkingBlip()
    RemoveParkingBlip()
    parkingBlip = AddBlipForCoord(mowerParkingSpot.x, mowerParkingSpot.y, mowerParkingSpot.z)
    SetBlipSprite(parkingBlip, 1)
    SetBlipColour(parkingBlip, 3)
    SetBlipScale(parkingBlip, 0.9)
    SetBlipAsShortRange(parkingBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Parkeer hier de grasmaaier en stap af om de job te voltooien')
    EndTextCommandSetBlipName(parkingBlip)
end

function RemoveParkingBlip()
    if parkingBlip and DoesBlipExist(parkingBlip) then
        RemoveBlip(parkingBlip)
        parkingBlip = nil
    end
end

function SpawnGrassForCurrentArea()
    for _, grass in ipairs(spawnedGrass) do
        if grass and DoesEntityExist(grass) then
            DeleteEntity(grass)
        end
    end
    spawnedGrass = {}

    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end

    local area = Config.LawnMower.lawnAreas[areaOrder[currentLawnArea]]
    if area and area.center then
        local grass = CreateObject(
            GetHashKey('prop_bush_med_03'), area.center.x, area.center.y, area.center.z - 2.5, true, true, true
        )
        table.insert(spawnedGrass, grass)

        jobBlip = AddBlipForCoord(area.center.x, area.center.y, area.center.z)
        SetBlipSprite(jobBlip, 1)
        SetBlipColour(jobBlip, 2)
        SetBlipScale(jobBlip, 0.8)
        SetBlipAsShortRange(jobBlip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Grasmaaien gebied')
        EndTextCommandSetBlipName(jobBlip)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if lawnMowerVehicle and DoesEntityExist(lawnMowerVehicle) then
            local playerPed = PlayerPedId()
            local mowerPos = GetEntityCoords(lawnMowerVehicle)
            if not isReturningMower and markerActive then
                for i, grass in ipairs(spawnedGrass) do
                    if grass and DoesEntityExist(grass) then
                        local grassPos = GetEntityCoords(grass)
                        DrawMarker(2, grassPos.x, grassPos.y, grassPos.z + 2.5, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 0, 255,
                            0, 100, false, true, 2, false, nil, nil, false)
                        if #(mowerPos - grassPos) < 2.0 then
                            DeleteEntity(grass)
                            spawnedGrass[i] = nil
                            lawnAreasCompleted = lawnAreasCompleted + 1
                            local allGone = true
                            for _, g in ipairs(spawnedGrass) do
                                if g and DoesEntityExist(g) then
                                    allGone = false
                                    break
                                end
                            end
                            if allGone then
                                CompleteLawnArea()
                            end
                        end
                    end
                end
            elseif isReturningMower then
                DrawMarker(2, mowerParkingSpot.x, mowerParkingSpot.y, mowerParkingSpot.z, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0,
                    0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                local playerCoords = GetEntityCoords(playerPed)
                local distanceToParking = #(playerCoords - vector3(mowerParkingSpot.x, mowerParkingSpot.y, mowerParkingSpot.z))
                if IsPedInVehicle(playerPed, lawnMowerVehicle, false) then
                    DrawText3D(mowerParkingSpot.x, mowerParkingSpot.y, mowerParkingSpot.z + 1.0,
                        'Parkeer hier de grasmaaier en stap af om de job te voltooien')
                elseif distanceToParking < 3.0 then
                    FinishLawnMowerJob()
                end
            end
        end
    end
end)

function CompleteLawnArea()
    lawnAreasCompleted = lawnAreasCompleted + 1
    currentLawnArea = currentLawnArea + 1
    ReportJobProgress()
    if currentLawnArea > #Config.LawnMower.lawnAreas then
        ESX.ShowNotification('Alles gemaaid lever nu de grasmaaier in')
        markerActive = false
        isReturningMower = true
        CreateParkingBlip()
    else
        ESX.ShowNotification('Maai het volgende gebied af!')
        SpawnGrassForCurrentArea()
    end
end

function CleanupLawnMowerJob()
    if lawnMowerVehicle and DoesEntityExist(lawnMowerVehicle) then
        ESX.Game.DeleteVehicle(lawnMowerVehicle)
        lawnMowerVehicle = nil
    end
    RemoveParkingBlip()
    if mowerBlip and DoesBlipExist(mowerBlip) then
        RemoveBlip(mowerBlip)
        mowerBlip = nil
    end
    if jobBlip and DoesBlipExist(jobBlip) then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    currentLawnArea = 1
    lawnAreasCompleted = 0
    markerActive = false
    isReturningMower = false
    areaOrder = {}
end

function FinishLawnMowerJob()
    CompleteJob()
    CleanupLawnMowerJob()
    ESX.ShowNotification('Taak voltooid!')
end

RegisterNetEvent('uwv_job:quitLawnMower', function()
    CleanupLawnMowerJob()
    ESX.ShowNotification('Grasmaaien afgerond.')
end)
