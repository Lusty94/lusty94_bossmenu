local QBCore = exports['qb-core']:GetCoreObject()
local TargetType = Config.CoreSettings.Target.Type
local NotifyType = Config.CoreSettings.Notify.Type
local InvType = Config.CoreSettings.Inventory.Type
local PlayerJob, SpawnedZones, JobBlips  = {}, {}, {}
local busy = false


--sends a client debug print
function CLDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--sends a client notification
function CLNotify(msg,type,time,title)
    if NotifyType == nil then print('^1| Lusty94_BossMenu | DEBUG | ERROR: NotifyType is nil!') return end
    if not msg then print('Notification Sent With No Message!') return end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
    if NotifyType == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif NotifyType == 'qs' then
        exports['qs-interface']:AddNotify(msg, title, time, 'fa-solid fa-clipboard')
    elseif NotifyType == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, true)
    elseif NotifyType == 'mythic' then
        exports['mythic_notify']:DoHudText(type, msg)
    elseif NotifyType == 'ox' then
        lib.notify({ title = title, description = msg, position = 'top', type = type, duration = time})
    elseif NotifyType == 'custom' then
        --insert your custom notification function here
    else
        print('^1| Lusty94_BossMenu | DEBUG | ERROR: Unknown Notify Type Set In Config.CoreSettings.Notify.Type!^7'..NotifyType)
    end
end


--get job logos
function getJobLogo(jobName)
    if not jobName then CLDebug('^1| Lusty94_BossMenu | DEBUG | ERROR: No jobName data received to obtain logo') return end
    return Config.Locations[jobName].image or 'https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png'
end


--change clothes
function ChangeClothes(jobName)
    local ClothingType = Config.CoreSettings.Clothing.Type
    if PlayerJob.name ~= jobName then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
    if ClothingType == 'qb' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    elseif ClothingType == 'illenium' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')   
    elseif ClothingType == 'custom' then
        -- insert your own custom code for opening outfit menu in your clothing script
    end
end


--set busy status
function setBusy(toggle)
    busy = toggle
    CLDebug('^3| Lusty94_BossMenu | DEBUG | Info: Toggling Busy Status ^7')
end


--open boss menu
function OpenBossMenu(jobName)
    if PlayerJob.name ~= jobName then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
    local members = lib.callback.await('lusty94_bossmenu:server:getJobMembers', false, jobName)
    local jobLabel = QBCore.Shared.Jobs[jobName].label
    local jobImage = getJobLogo(jobName)
    local jobBank = PlayerJob.isboss and lib.callback.await('lusty94_bossmenu:server:getJobBank', false, jobName) or nil
    local options = {}
    local desc = string.format('Total Employees: %s', members and #members or 0)
    if jobBank then desc = desc..string.format('\nCurrent Bank Balance: $%s', jobBank) end
    options[#options+1] = {
        title = 'Job Title: '..jobLabel,
        description = desc,
        icon = jobImage,
        image = jobImage,
    }
    if PlayerJob.isboss then
        options[#options+1] = {
            title = 'View Employees',
            event = 'lusty94_bossmenu:client:ViewEmployees',
            icon = 'fa-solid fa-magnifying-glass',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'Hire Employee',
            event = 'lusty94_bossmenu:client:HireEmployee',
            icon = 'fa-solid fa-users',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'Promote / Demote Employee',
            event = 'lusty94_bossmenu:client:PromoDemoEmployee',
            icon = 'fa-solid fa-arrows-up-down',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'Fire Employee',
            event = 'lusty94_bossmenu:client:FireEmployee',
            icon = 'fa-solid fa-user-xmark',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'Send Announcement',
            icon = 'fa-solid fa-bullhorn',
            onSelect = function()
                local input = lib.inputDialog('Send Announcement', {
                    { type = 'textarea', label = 'Announcement Message', required = true, icon = 'fa-solid fa-message' }
                })
                if input and input[1] and input[1]:len() > 2 then
                    TriggerServerEvent('lusty94_bossmenu:server:SendJobAnnouncement', jobName, input[1])
                else
                    CLNotify(Config.Language.Notifications.Cancelled, 'error')
                end
            end
        }
        if Config.Locations[jobName].stash and Config.Locations[jobName].stash.enabled then
            options[#options+1] = {
                title = 'Access Storage',
                icon = 'fa-solid fa-box-archive',
                onSelect = function()
                    TriggerEvent('lusty94_bossmenu:client:OpenBossStash', jobName)
                end,
            }
        end
        options[#options+1] = {
            title = 'Deposit Cash',
            event = 'lusty94_bossmenu:client:DepositMoney',
            icon = 'fa-solid fa-money-bill',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'Read Employee Messages',
            icon = 'fa-solid fa-envelope-open-text',
            onSelect = function()
                TriggerServerEvent('lusty94_bossmenu:server:GetMessages', jobName)
            end
        }
    end
    if not PlayerJob.isboss then
        options[#options+1] = {
            title = 'Send Message to Boss',
            event = 'lusty94_bossmenu:client:SendMessage',
            icon = 'fa-solid fa-paper-plane',
            args = { job = jobName },
        }
        options[#options+1] = {
            title = 'View Boss Replies',
            event = 'lusty94_bossmenu:client:RequestReplies',
            icon = 'fa-solid fa-inbox',
            args = { job = jobName },
        }
    end
    options[#options+1] = {
        title = 'Toggle Duty Status',
        event = 'lusty94_bossmenu:client:ToggleDuty',
        icon = 'fa-solid fa-user-clock',
    }
    options[#options+1] = {
        title = 'Change Clothing',
        icon = 'fa-solid fa-shirt',
        onSelect = function()
            ChangeClothes(jobName)
        end,
    }
    lib.registerContext({
        id = 'boss_menu_main',
        title = 'Management Menu',
        options = options,
    })
    lib.showContext('boss_menu_main')
end


--get max job grade
function getMaxJobGrade(jobName)
    local job = QBCore.Shared.Jobs[jobName]
    if not job or not job.grades then return nil end
    local maxGrade = 0
    for k, v in pairs(job.grades) do
        local grade = tonumber(k)
        if grade and grade > maxGrade then
            maxGrade = grade
        end
    end
    return maxGrade
end


--refresh blips
function SetBlips()
    for jobName, blip in pairs(JobBlips) do if blip then RemoveBlip(blip) end end
    JobBlips = {}
    for jobName, coords in pairs(Config.Locations) do
        local blipData = Config.Locations[jobName].blip
        if blipData and blipData.enabled and PlayerJob.name == jobName then
            local blip = AddBlipForCoord(coords.coords.x, coords.coords.y, coords.coords.z)
            SetBlipSprite(blip, blipData.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, blipData.scale)
            SetBlipColour(blip, blipData.colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(blipData.title or 'Job Management')
            EndTextCommandSetBlipName(blip)
            JobBlips[jobName] = blip
            CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Adding management blips for job: '..jobName..' At coords: '.. json.encode(coords.coords.x, coords.coords.y, coords.coords.z)'^7')
        end
    end
end


--create zones
CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end
    PlayerJob = QBCore.Functions.GetPlayerData().job
    for jobName, coords in pairs(Config.Locations) do
        CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Creating target zone for job: '..jobName..' At coords: '.. json.encode(coords.coords)'^7')
        if TargetType == 'qb' then
            exports['qb-target']:AddCircleZone('bossMenu_'..jobName, coords.coords, 1.5, {
                name = 'bossMenu_'..jobName,
                debugPoly = Config.CoreSettings.Debug.Zones,
            }, {
                options = {
                    {
                        icon = 'fas fa-clipboard',
                        label = 'Job Management',
                        canInteract = function()
                            return not busy
                        end,
                        action = function()
                            OpenBossMenu(jobName)
                        end,
                    }
                },
                distance = 2.0
            })
            SpawnedZones[#SpawnedZones + 1] = { type = 'qb', name = 'bossMenu_'..jobName }
        elseif TargetType == 'ox' then
            local zoneId = exports.ox_target:addSphereZone({
                coords = coords.coords,
                radius = 1.5,
                debug = Config.CoreSettings.Debug.Zones,
                options = {
                    {
                        icon = 'fas fa-clipboard',
                        label = 'Job Management',
                        canInteract = function()
                            return not busy
                        end,
                        onSelect = function()
                            if busy then CLNotify(Config.Language.Notifications.Busy, 'error') return end
                            OpenBossMenu(jobName)
                        end,
                        distance = 2.0,
                    }
                }
            })
            SpawnedZones[#SpawnedZones + 1] = { type = 'ox', id = zoneId }
        end
    end
    SetBlips()
end)


--view employees
RegisterNetEvent('lusty94_bossmenu:client:ViewEmployees', function(data)
    local jobName = data.job
    if not PlayerJob.isboss then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
    local members = lib.callback.await('lusty94_bossmenu:server:getJobMembers', false, jobName)
    if not members then return end
    local options = {}
    for _, member in pairs(members) do
        options[#options+1] = { title = member.name, description = 'Rank: '..member.grade.name..'\n Citizen ID: '..member.citizenid..'\n Phone number: '..member.phone  }
        CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Employees information for job: '..jobName..' Name: '..member.name..' Rank: '..member.grade.name..' Citizen ID: '..member.citizenid..' Phone number: '..member.phone..'^7')
    end
    table.insert(options, {
        title = 'Return to main menu',
        icon = 'fa-solid fa-arrow-left',
        onSelect = function()
            OpenBossMenu(jobName)
        end,
    })
    lib.registerContext({
        id = 'employees_menu',
        title = 'Current Employees',
        options = options,
    })
    lib.showContext('employees_menu')
end)


--hire employee
RegisterNetEvent('lusty94_bossmenu:client:HireEmployee', function(data)
    setBusy(true)
    local job = data.job
    local players = lib.callback.await('lusty94_bossmenu:server:getNearbyPlayers', false)
    if not players or #players == 0 then setBusy(false) CLNotify(Config.Language.Notifications.NoOneNear, 'error') CLDebug('^1| Lusty94_BossMenu | DEBUG | ERROR: No players found nearby^7') return end
    local playerChoices = {}
    for _, p in pairs(players) do
        playerChoices[#playerChoices+1] = { label = p.name..' | ID: '..p.source, value = p.source, playerName = p.name, }
        CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Nearby players to hire for job: '..job..' Name: '..p.name..' Server ID: '..p.source..'^7')
    end
    local playerInput = lib.inputDialog('Hire Employee', {
        {
            type = 'select',
            label = 'Select Player',
            options = playerChoices
        }
    })
    if not playerInput then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local targetId = playerInput[1]
    if not targetId then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local selectedName
    for _, option in pairs(playerChoices) do
        if option.value == targetId then
            selectedName = option.playerName
            break
        end
    end
    local targetJob = lib.callback.await('lusty94_bossmenu:server:getPlayerJob', false, targetId)
    if targetJob == job then setBusy(false) CLNotify(Config.Language.Notifications.AlreadyEmployed, 'error') CLDebug('^1| Lusty94_BossMenu | DEBUG | ERROR: Person already employed here^7') return end
    local gradeChoices = {}
    for grade, data in pairs(QBCore.Shared.Jobs[job].grades) do
        gradeChoices[#gradeChoices+1] = { label = data.name or ('Rank '..grade), value = tonumber(grade) }
        CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Player selected to be hired for job: '..job..' Name: '..selectedName..' Rank: '..data.name..'^7')
    end
    table.sort(gradeChoices, function(a, b) return a.value < b.value end)
    local rankInput = lib.inputDialog('Select Rank', {
        {
            type = 'select',
            label = 'Select Rank',
            options = gradeChoices
        }
    })
    if not rankInput then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local selectedGrade = tonumber(rankInput[1])
    local gradeLabel = QBCore.Shared.Jobs[job].grades[tostring(selectedGrade)]?.name or ('Rank '..selectedGrade)
    local confirm = lib.alertDialog({
        header = 'Confirm Hire',
        content = 'Are you sure you want to hire '..selectedName..' to rank: '..gradeLabel..'?',
        centered = true,
        cancel = true
    })
    if confirm ~= 'confirm' then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    TriggerServerEvent('lusty94_bossmenu:server:HirePlayer', targetId, job, selectedGrade)
    setBusy(false)
end)


--promote or demote employee
RegisterNetEvent('lusty94_bossmenu:client:PromoDemoEmployee', function(data)
    setBusy(true)
    local job = data.job
    local members = lib.callback.await('lusty94_bossmenu:server:getJobMembers', false, job)
    if not members then return end
    local employeeChoices = {}
    for _, v in pairs(members) do
        if v.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
            employeeChoices[#employeeChoices+1] = {
                label = v.name,
                value = v.citizenid,
                playerName = v.name
            }
        end
    end
    local employeeInput = lib.inputDialog('Promote / Demote Employee', {
        { type = 'select', label = 'Select Employee', options = employeeChoices }
    })
    if not employeeInput then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local targetCitizenId = employeeInput[1]
    local selectedName = employeeChoices[1].playerName
    local gradeChoices = {}
    for grade, data in pairs(QBCore.Shared.Jobs[job].grades) do
        gradeChoices[#gradeChoices+1] = { label = data.name or ('Rank '..grade), value = tonumber(grade) }
        CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Player selected to be promoted or demoted for job: '..job..' Name: '..selectedName..' Rank: '..data.name..'^7')
    end    
    table.sort(gradeChoices, function(a, b) return a.value < b.value end)
    local rankInput = lib.inputDialog('Select New Rank', {
        { type = 'select', label = 'Select New Rank', options = gradeChoices }
    })
    if not rankInput then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local newGrade = tonumber(rankInput[1])
    local gradeLabel = QBCore.Shared.Jobs[job].grades[tostring(newGrade)]?.name or ('Rank '..newGrade)
    local confirm = lib.alertDialog({
        header = 'Confirm Promotion',
        content = 'Are you sure you want to set '..selectedName..' to rank: '..gradeLabel..'?',
        centered = true, cancel = true
    })
    if confirm == 'confirm' then
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('lusty94_bossmenu:server:PromoteEmployee', targetCitizenId, job, newGrade, coords)
    end
    setBusy(false)
end)


--fire employee
RegisterNetEvent('lusty94_bossmenu:client:FireEmployee', function(data)
    setBusy(true)
    local members = lib.callback.await('lusty94_bossmenu:server:getJobMembers', false, data.job)
    if not members then return end
    local employees = {}
    for _, m in pairs(members) do
        if m.citizenid ~= QBCore.Functions.GetPlayerData().citizenid then
            employees[#employees+1] = {
                label = m.name,
                value = m.citizenid,
                playerName = m.name
            }
        end
    end
    local input = lib.inputDialog('Fire Employee', {
        { type = 'select', label = 'Select Employee', options = employees }
    })
    if not input then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local targetCitizenId = input[1]
    local selectedName = employees[1].playerName
    CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Player selected to be fired from job: '..data.job..' Name: '..selectedName..' Citizen ID: '..targetCitizenId..'^7')
    local confirm = lib.alertDialog({
        header = 'Confirm Fire',
        content = 'Are you sure you want to fire '..selectedName..'?',
        centered = true, cancel = true
    })
    if confirm == 'confirm' then
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('lusty94_bossmenu:server:FirePlayer', targetCitizenId, coords)
    end
    setBusy(false)
end)


--confirm job hire
RegisterNetEvent('lusty94_bossmenu:client:ConfirmHire', function(bossId, job, grade, jobLabel, gradeLabel)
    setBusy(true)
    CLNotify(Config.Language.Notifications.OfferReceived, 'success')
    local confirm = lib.alertDialog({
        header = 'Job Offer',
        content = 'You are being offered a job as '..jobLabel..' '..gradeLabel..'\n Do you accept?',
        centered = true,
        cancel = true
    })
    if confirm == 'confirm' then
        setBusy(false)
        TriggerServerEvent('lusty94_bossmenu:server:AcceptHire', bossId, job, grade)
    else
        setBusy(false)
        TriggerServerEvent('lusty94_bossmenu:server:DeclineHire', bossId)
        CLNotify(Config.Language.Notifications.DeclinedOffer, 'error')
    end
end)


--refresh employee list
RegisterNetEvent('lusty94_bossmenu:client:RefreshEmployeeList', function(job)
    TriggerEvent('lusty94_bossmenu:client:ViewEmployees', { job = job })
end)


--deposit cash
RegisterNetEvent('lusty94_bossmenu:client:DepositMoney', function(data)
    if PlayerJob.name ~= data.job or not PlayerJob.isboss then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
    setBusy(true)
    local cash = lib.callback.await('lusty94_bossmenu:server:getPlayerCash', false)
    if cash <= 0 then setBusy(false) CLNotify(Config.Language.Notifications.NoCash, 'error') return end
    local cashSymbol = Config.CoreSettings.Banking.CashSymbol
    local input = lib.inputDialog('Deposit Cash', {
        {
            type = 'input',
            placeholder = 'Cash: \n'..cashSymbol..math.floor(cash),
            disabled = true,
        },
        {
            type = 'number',
            label = 'How much to deposit?',
            min = 1,
            max = cash,
            default = 1,
        }
    })
    if not input then setBusy(false) CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
    local amount = tonumber(input[2])
    CLDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Player chose to deposit: '..amount..' to job: '..data.job..'^7')
    if amount and amount > 0 then
        setBusy(false)
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('lusty94_bossmenu:server:DepositMoney', data.job, amount, coords)
    end
    setBusy(false)
end)


--open boss stash
RegisterNetEvent('lusty94_bossmenu:client:OpenBossStash', function(jobName)
    if not jobName or not Config.Locations[jobName] or not Config.Locations[jobName].stash then return end
    local stashID = jobName .. '_Management_Stash'
    local stashData = Config.Locations[jobName].stash
    local coords = GetEntityCoords(PlayerPedId())
    if InvType == 'qb' then
        TriggerServerEvent('lusty94_bossmenu:server:OpenBossStash',jobName, stashID, stashData, coords)
    elseif InvType == 'ox' then
        exports.ox_inventory:openInventory('stash', stashID)
    end
end)


--send a message
RegisterNetEvent('lusty94_bossmenu:client:SendMessage', function(data)
    local input = lib.inputDialog('Send Message to Boss', {
        { type = 'textarea', label = 'Your Message', required = true, icon = 'fa-solid fa-pen-to-sqaure',  }
    })
    if not input or not input[1] or input[1]:len() < 3 then CLNotify(Config.Language.Notifications.InvalidMessage, 'error')  return end
    local char = QBCore.Functions.GetPlayerData().charinfo
    local senderName = ("%s %s"):format(char.firstname, char.lastname)
    TriggerServerEvent('lusty94_bossmenu:server:SaveMessage', data.job, senderName, input[1])
end)


--read messages
RegisterNetEvent('lusty94_bossmenu:client:ReadMessages', function(messages)
    if not messages or #messages == 0 then CLNotify('No messages found.', 'error') return end
    local options = {}
    for _, msg in ipairs(messages) do
        options[#options+1] = {
            title = msg.sender_name,
            description = msg.message .. (msg.boss_reply and ("\n\nBoss Reply: " .. msg.boss_reply) or ""),
            icon = 'fa-solid fa-comment-dots',
            onSelect = function()
                local contextOptions = {}
                if not msg.boss_reply then
                    contextOptions[#contextOptions+1] = {
                        title = 'Reply to Message',
                        icon = 'fa-solid fa-reply',
                        onSelect = function()
                            local reply = lib.inputDialog('Reply to '..msg.sender_name, {
                                { type = 'textarea', label = 'Reply Message', required = true }
                            })
                            if reply and reply[1] then
                                TriggerServerEvent('lusty94_bossmenu:server:ReplyToMessage', msg.id, reply[1])
                            end
                        end
                    }
                end
                contextOptions[#contextOptions+1] = {
                    title = 'Delete Message',
                    icon = 'fa-solid fa-trash',
                    onSelect = function()
                        local confirm = lib.alertDialog({
                            header = 'Delete Message',
                            content = 'Are you sure you want to delete this message?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            TriggerServerEvent('lusty94_bossmenu:server:DeleteReply', msg.id)
                        end
                    end
                }
                lib.registerContext({
                    id = 'boss_message_action_' .. msg.id,
                    title = 'Message Options',
                    options = contextOptions
                })
                lib.showContext('boss_message_action_' .. msg.id)
            end
        }
    end
    table.insert(options, {
        title = 'Clear All Messages',
        icon = 'fa-solid fa-trash',
        onSelect = function()
            TriggerServerEvent('lusty94_bossmenu:server:ClearMessages', PlayerJob.name)
        end
    })
    lib.registerContext({
        id = 'boss_message_menu',
        title = 'Employee Messages',
        options = options,
    })
    lib.showContext('boss_message_menu')
end)


--get replies
RegisterNetEvent('lusty94_bossmenu:client:RequestReplies', function(data)
    TriggerServerEvent('lusty94_bossmenu:server:RequestReplies', data.job)
end)


--view replies
RegisterNetEvent('lusty94_bossmenu:client:ViewReplies', function(messages)
    if not messages or #messages == 0 then CLNotify(Config.Language.Notifications.NoReplies, 'error') return end
    local options = {}
    for _, msg in pairs(messages) do
        options[#options+1] = {
            title = msg.sender_name,
            description = "You said:\n" .. msg.message .. "\n\nBoss replied:\n" .. msg.boss_reply,
            icon = 'fa-solid fa-envelope-open-text',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Delete Reply?',
                    content = 'Are you sure you want to delete this reply?',
                    centered = true,
                    cancel = true
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('lusty94_bossmenu:server:DeleteReply', msg.id)
                end
            end
        }
    end
    lib.registerContext({
        id = 'boss_reply_menu',
        title = 'Replies from Boss',
        options = options,
    })
    lib.showContext('boss_reply_menu')
end)


--toggle duty
RegisterNetEvent('lusty94_bossmenu:client:ToggleDuty', function()
    if PlayerJob.onduty then
        TriggerServerEvent('QBCore:ToggleDuty')
    else
        TriggerServerEvent('QBCore:ToggleDuty')
    end
    CLNotify('Duty Status Toggled', 'success')
end)



RegisterNetEvent('lusty94_bossmenu:client:notify', function(msg, type, time)
    CLNotify(msg, type, time)
end)


--job update
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
    SetBlips()
end)


--player loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    SetBlips()
end)


--clean up
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, blip in ipairs(JobBlips) do RemoveBlip(blip) end
        JobBlips = {}
        for _, zone in pairs(SpawnedZones) do
            if zone.type == 'qb' then
                exports['qb-target']:RemoveZone(zone.name)
            elseif zone.type == 'ox' then
                exports['ox_target']:removeZone(zone.id)
            elseif zone.type == 'custom' then
                --insert your own logic here to remove target zones
            end
        end
        SpawnedZones = {}
    end
end)