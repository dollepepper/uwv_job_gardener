local ESX = nil
local activeJobs = {}
local jobCooldowns = {}

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('uwv_job:checkCooldown', function(jobName)
    local src = source

    local currentTime = os.time()
    if jobCooldowns[src] and jobCooldowns[src] > currentTime then
        local remainingTime = jobCooldowns[src] - currentTime
        local minutes = math.ceil(remainingTime / 60)
        local message = string.format(Config.Locales['cooldown_active_notify'], minutes)
        Functions.Notify(src, message, 'error')
        return
    end
end)

local jobTypes = { 'lawnmower', 'leafcollector', 'weedraker' }

RegisterNetEvent('uwv_job:requestJob', function()
    local src = source
    if activeJobs[src] then
        TriggerClientEvent('esx:showNotification', src, 'Je bent al aan het werken!')
        return
    end
    local currentTime = os.time()
    if jobCooldowns[src] and jobCooldowns[src] > currentTime then
        local remainingTime = jobCooldowns[src] - currentTime
        print(('[UWV_job] Player %s is on cooldown: %s seconds (%s minutes) left.'):format(
            src, remainingTime, math.ceil(remainingTime / 60))
        )
        TriggerClientEvent('esx:showNotification', src,
            ('Je moet %s minuten wachten voordat je een nieuwe job kunt starten.'):format(math.ceil(remainingTime / 60))
        )
        return
    end
    local jobType = jobTypes[math.random(#jobTypes)]
    TriggerEvent('uwv_job:assignJob', src, jobType)
end)

RegisterNetEvent('uwv_job:updateProgress', function()
    local src = source
    if not activeJobs[src] then return end
    
    local jobType = activeJobs[src].job
    local currentProgress = activeJobs[src].progress or 0
    local maxLocations = 0
    
    if jobType == 'lawnmower' then
        maxLocations = #Config.LawnMower.lawnAreas
    elseif jobType == 'leafcollector' then
        maxLocations = #Config.LeafCollector.leafPiles
    elseif jobType == 'weedraker' then
        maxLocations = #Config.WeedRaker.weedPiles
    end
    
    if currentProgress >= maxLocations then
        print(('[UWV_job] Player %s attempted to exceed maximum progress for job %s (current: %s, max: %s)'):format(
            src, jobType, currentProgress, maxLocations
        ))
        return
    end
    
    activeJobs[src].progress = currentProgress + 1
end)

RegisterNetEvent('uwv_job:completeJob', function()
    local src = source
    local jobData = activeJobs[src]
    if not jobData then
        TriggerClientEvent('esx:showNotification', src, 'Geen actieve job om te voltooien!')
        return
    end
    local jobType = jobData.job
    local progress = jobData.progress or 0
    local payment = 0
    if jobType == 'lawnmower' then
        payment = progress * Config.Payment.lawnmower
    elseif jobType == 'leafcollector' then
        payment = progress * Config.Payment.leafcollector
    elseif jobType == 'weedraker' then
        payment = progress * Config.Payment.weedraker
    end
    if payment > 0 then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addMoney(payment)
        TriggerClientEvent('esx:showNotification', src,
            ('Je hebt €%s verdiend voor het voltooien van de job!'):format(payment)
        )
    end
    activeJobs[src] = nil
    if Config.Cooldowns[jobType] then
        local now = os.time()
        local cooldownEnd = jobCooldowns[src] or now
        local remaining = cooldownEnd - now
        if remaining <= 0 then
            local newJobType = jobTypes[math.random(#jobTypes)]
            TriggerEvent('uwv_job:assignJob', src, newJobType)
            print(('[UWV_job] Player %s assigned new job \'%s\' after cooldown (immediate).'):format(src, newJobType))
        else
            SetTimeout(remaining * 1000, function()
                if GetPlayerPing(src) > 0 and not activeJobs[src] then
                    local newJobType = jobTypes[math.random(#jobTypes)]
                    TriggerEvent('uwv_job:assignJob', src, newJobType)
                    print(('[UWV_job] Player %s assigned new job \'%s\' after cooldown (delayed).'):format(
                        src, newJobType
                    ))
                end
            end)
        end
    end
end)

RegisterNetEvent('uwv_job:quitJob', function()
    local src = source
    local jobData = activeJobs[src]
    if jobData then
        local jobType = jobData.job
        if Config.Cooldowns[jobType] then
            jobCooldowns[src] = os.time() + Config.Cooldowns[jobType]
        end
        activeJobs[src] = nil
        TriggerClientEvent('uwv_job:clientQuitJob', src, jobType)
        TriggerClientEvent('esx:showNotification', src, 'Je hebt je job afgerond.')
    else
        TriggerClientEvent('esx:showNotification', src, 'Je bent niet aan het werken!')
    end
end)

RegisterNetEvent('uwv_job:assignJob', function(src, jobType)
    if Config.Cooldowns[jobType] then
        jobCooldowns[src] = os.time() + Config.Cooldowns[jobType]
    end
    activeJobs[src] = { job = jobType, progress = 0 }
    TriggerClientEvent('uwv_job:assignJob', src, jobType)
    print(('[UWV_job] Player %s assigned job \'%s\' and cooldown started.'):format(src, jobType))
end)
