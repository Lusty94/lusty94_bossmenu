local QBCore = exports['qb-core']:GetCoreObject()
local NotifyType = Config.CoreSettings.Notify.Type or 'qb'
local InvType = Config.CoreSettings.Inventory.Type or 'qb'
local Banking = Config.CoreSettings.Banking.Type or 'qb'
local CashSymbol = Config.CoreSettings.Banking.CashSymbol or '£'
local maxDist = Config.CoreSettings.Security.MaxDistance or 10.0


--server debug print
function SVDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--get character name
function getCharacterName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        return (info.firstname or 'Unknown')..' '..(info.lastname or 'Unknown')
    end
    return 'Unknown'
end


--send logs
function sendLog(source, logType, message, level)
    local src = source
    local name = getCharacterName(src)
    local logsEnabled = Config.CoreSettings.Security.Logs.Enabled
    if not logsEnabled then return end
    local logging = Config.CoreSettings.Security.Logs.Type
    if logging == 'discord' then
        local webhookURL = '' -- set your discord webhook URL here
        if webhookURL == '' then print('^1| Lusty94_BossMenu | DEBUG | ERROR | Logging method is set to Discord but WebhookURL is missing!') return end
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "Lusty94_BossMenu Logs",
            avatar_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png",
            embeds = {{
                title = "**"..(logType or "BossMenu Log").."**",
                description = message or ("Log triggered by **%s** (ID: %s)"):format(name, source),
                color = level == "warning" and 16776960 or level == "error" and 16711680 or 65280,
                footer = {
                    text = "Lusty94_BossMenu Logs • "..os.date("%Y-%m-%d %H:%M:%S"),
                    icon_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                thumbnail = {
                    url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                author = {
                    name = 'Lusty94_BossMenu Logs'
                }
            }}
        }), { ['Content-Type'] = 'application/json' })
    elseif logging == 'fm-logs' then
        if not GetResourceState('fm-logs') or GetResourceState('fm-logs') ~= 'started' then
            print('^1| Lusty94_BossMenu | DEBUG | ERROR | Unable to send log | fm-logs is not started!')
            return
        end
        exports['fm-logs']:createLog({
            LogType = logType or "Player",
            Message = message or 'Check Resource',
            Level = level or "info",
            Resource = GetCurrentResourceName(),
            Source = source,
        }, { Screenshot = true })
    end
end



-- server notification
function SVNotify(src, msg, type, time, title)
    if NotifyType == nil then print('^1| Lusty94_BossMenu | DEBUG | ERROR | NotifyType is nil!') return end
     if not msg then msg = 'Notification sent with no message!' end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
     if NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, type, time)
    elseif NotifyType == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, title, msg, time, type, Config.CoreSettings.Notify.Sound)
    elseif NotifyType == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = type, text = msg, style = { ['background-color'] = '#00FF00', ['color'] = '#FFFFFF' } })
    elseif NotifyType == 'ox' then 
        TriggerClientEvent('ox_lib:notify', src, ({ title = title, description = msg, position = 'top', length = time, type = type, style = 'default'}))
    elseif NotifyType == 'lation' then 
         TriggerClientEvent('lusty94_bossmenu:client:notify', src, msg, type, time)
    elseif NotifyType == 'wasabi' then 
        TriggerClientEvent('wasabi_notify:notify', src, title, msg, time, type)
    elseif NotifyType == 'custom' then
        -- Insert your own notify function here
    else
        print('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown notify type: ' .. tostring(NotifyType))
    end
end


--add item
function addItem(src, item, amount, slot, info)
    sendLog(src, "Security", ('Giving %sx%s to %s with info %s'):format(item, amount, getCharacterName(src), json.encode(info) or 'N/A'), "warning")
    SVDebug('^2| Lusty94_BossMenu | DEBUG | Adding '..amount..'x '..item..' to '..getCharacterName(src))
    if InvType == 'qb' then
        local canCarry = exports['qb-inventory']:CanAddItem(src, item, amount, slot, info)
        if not canCarry then SVNotify(src, Config.Language.Notifications.CantGive, 'error') TriggerClientEvent('lusty94_bossmenu:client:toggleStatus', src) return end
        exports['qb-inventory']:AddItem(src, item, amount, slot, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif InvType == 'ox' then
        local canCarry = exports.ox_inventory:CanCarryItem(src, item, amount, info)
        if not canCarry then SVNotify(src, Config.Language.Notifications.CantGive, 'error') TriggerClientEvent('lusty94_bossmenu:client:toggleStatus', src) return end
        exports.ox_inventory:AddItem(src, item, amount, info)
    elseif InvType == 'custom' then
        --insert your own logic for adding items here
    else
        print('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--add money
function addCash(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    sendLog(src, "Security", ('Adding %s%s cash to %s'):format(CashSymbol, amount, getCharacterName(src)), "warning")
    SVDebug('^3| Lusty94_Restaurants | DEBUG | INFO | Giving '..CashSymbol..amount..' to '..getCharacterName(src))
    if InvType == 'qb' then
        Player.Functions.AddMoney('cash', amount)
    elseif InvType == 'ox' then
        addItem(src, 'money', amount)
    elseif InvType == 'custom' then
        --insert your own logic here for adding money to players 
    else
        print('^1| Lusty94_Restaurants | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type! ' ..tostring(InvType))
    end
end


--remove cash
function removeCash(src, amount)
    local name = getCharacterName(src)
    sendLog(src, "Security", ('Removing %s%s cash from %s'):format(CashSymbol, amount, name), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | Removing %s%s cash from %s'):format(CashSymbol, amount, name))
    if InvType == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.RemoveMoney('cash', amount) then
            return true
        else
            return false
        end
    elseif InvType == 'ox' then
        if exports.ox_inventory:Search(src, 'count', 'money') >= amount then
            exports.ox_inventory:RemoveItem(src, 'money', amount)
            return true
        else
            return false
        end
    elseif InvType == 'custom' then
        -- Insert your custom logic for removing money (or cash item) here
        return true
    else
        print('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type! '..tostring(InvType))
        return false
    end
end


--check player distance
function nearPlayer(src, targetId, maxDistance)
    local srcPed = GetPlayerPed(src)
    local srcName = getCharacterName(src)
    local targetName = getCharacterName(targetId)
    local targetPed = GetPlayerPed(targetId)
    if not DoesEntityExist(srcPed) or not DoesEntityExist(targetPed) then return false end
    local srcCoords = GetEntityCoords(srcPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(srcCoords - targetCoords)
    sendLog(src, "Security", ('Checking distance for %s to %s | %s'):format(srcName, targetName, distance), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | Checking distance for %s to %s | %s'):format(srcName, targetName, distance))
    return distance <= (maxDistance or maxDist)
end


--check near zone
function nearZone(src, jobName, coords)
    local name = getCharacterName(src)
    local zoneCoords = Config.Locations[jobName]?.coords
    if not zoneCoords then SVDebug('^1| Lusty94_BossMenu | DEBUG | ERROR | No zone coords receieved') return false end
    local distance = #(coords - zoneCoords)
    sendLog(src, "Security", ('Checking %s is near job zone %s | Coords %s'):format(name, jobName, coords), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | Checking %s is near job zone %s | Coords %s'):format(name, jobName, coords))
    if distance > maxDist then return false end
    return true
end


--update job info
function updateJobInfo(jobName, grade)
    local jobData = QBCore.Shared.Jobs[jobName]
    local gradeData = jobData and jobData.grades[tostring(grade)]
    sendLog(src, "Security", ('Updating job info | Job Name %s | Grade %s'):format(jobName, grade), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | Updating job info | Job Name %s | Grade %s'):format(jobName, grade))
    if not jobData or not gradeData then return nil end
    return {
        name = jobName,
        label = jobData.label,
        payment = gradeData.payment or 0,
        isboss = gradeData.isboss or false,
        grade = {
            name = gradeData.name,
            level = tonumber(grade),
            payment = gradeData.payment or 0,
            isboss = gradeData.isboss or false
        }
    }
end



--get players job
lib.callback.register('lusty94_bossmenu:server:getPlayerJob', function(source, targetId)
    local Player = QBCore.Functions.GetPlayer(targetId)
    if Player then return Player.PlayerData.job.name end
    return nil
end)


--get job members
lib.callback.register('lusty94_bossmenu:server:getJobMembers', function(source, jobname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return {} end
    local employees = {}
    local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE ?", { '%' .. jobname .. '%' })
    if players and players[1] then
        for _, info in pairs(players) do
            local Target = QBCore.Functions.GetPlayerByCitizenId(info.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(info.citizenid)
            if Target and Target.PlayerData.job.name == jobname then
                local isOnline = Target.PlayerData.source and true or false
                local grade = Target.PlayerData.job.grade
                local charinfo = Target.PlayerData.charinfo
                employees[#employees + 1] = {
                    name = (isOnline and ' ✅ ' or ' ❌ ')..charinfo.firstname..' '..charinfo.lastname,
                    citizenid = Target.PlayerData.citizenid,
                    phone = charinfo.phone or 'Unknown',
                    grade = { level = grade, name = grade.name, },
                    source = Target.PlayerData.source or nil,
                    isOnline = isOnline
                }
            end
        end
    end
    for _, data in ipairs(employees) do SVDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Getting job data \nEmployee: '.. data.name..' \nData: '..json.encode(data.grade.level)) end
    table.sort(employees, function(a, b)
        local aLevel = tonumber(a.grade.level) or 0
        local bLevel = tonumber(b.grade.level) or 0
        return aLevel > bLevel
    end)
    return employees
end)


--get nearby players
lib.callback.register('lusty94_bossmenu:server:getNearbyPlayers', function(source)
    local src = source
    local players = {}
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.source ~= src then
            local targetCoords = GetEntityCoords(GetPlayerPed(v.PlayerData.source))
            if #(pCoords - targetCoords) <= 10.0 then
                SVDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Getting nearby player data | Name: '..v.PlayerData.charinfo.firstname..' '..v.PlayerData.charinfo.lastname..' | Server ID:: '..v.PlayerData.source)
                players[#players+1] = {
                    name = v.PlayerData.charinfo.firstname..' '..v.PlayerData.charinfo.lastname,
                    source = v.PlayerData.source
                }
            end
        end
    end
    return players
end)


--get players cash
lib.callback.register('lusty94_bossmenu:server:getPlayerCash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.money.cash or 0
    end
    return 0
end)


--get job bank balance
lib.callback.register('lusty94_bossmenu:server:getJobBank', function(source, jobName)
    local result = 0
    if Banking == 'qb' then
        result = exports['qb-banking']:GetAccountBalance(jobName) or 0
    elseif Banking == 'okok' then
        result = exports['okokBanking']:GetAccount(jobName) or 0
    elseif Banking == 'renewed' then
        result = exports['Renewed-Banking']:getAccountMoney(jobName) or 0
    elseif Banking == 'wasabi' then
        result = exports['wasabi_banking']:GetAccountBalance(jobName, 'society') or 0
    elseif Banking == 'tgg' then
        result = exports['tgg-banking']:GetSocietyAccountMoney(jobName) or 0
    elseif Banking == 'fd' then
        result = exports.fd_banking:GetAccount(jobName) or 0
    elseif Banking == 'custom' then
        --insert your own logic for adding society funds here
    else
        SVDebug('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown banking type set in Config.CoreSettings.Banking.Type | '..tostring(Banking))
    end
    return result
end)


--hire selected player
RegisterNetEvent('lusty94_bossmenu:server:HirePlayer', function(targetId, job, grade)
    local src = source
    local Boss = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayer(targetId)
    if not Boss or not Employee then return end
    if Boss.PlayerData.job.name ~= job or not Boss.PlayerData.job.isboss then return end
    if not nearPlayer(src, targetId, maxDist) then SVNotify(src, Config.Language.Notifications.TooFar, 'error') return end
    local jobLabel = QBCore.Shared.Jobs[job]?.label or 'Unknown'
    local gradeLabel = QBCore.Shared.Jobs[job]?.grades[tostring(grade)]?.name or ('Rank '..grade)
    SVNotify(src, Config.Language.Notifications.OfferSent, 'success')
    TriggerClientEvent('lusty94_bossmenu:client:ConfirmHire', targetId, src, job, grade, jobLabel, gradeLabel)
    sendLog(src, "Security", ('%s Hired %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetId), job, grade), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | %s Hired %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetId), job, grade))
end)


--accept hire request
RegisterNetEvent('lusty94_bossmenu:server:AcceptHire', function(bossId, job, grade)
    local src = source
    local Employee = QBCore.Functions.GetPlayer(src)
    if not Employee then return end
    Employee.Functions.SetJob(job, grade)
    local jobLabel = QBCore.Shared.Jobs[job]?.label or 'Unknown'
    local gradeLabel = QBCore.Shared.Jobs[job]?.grades[tostring(grade)]?.name or ('Rank '..grade)
    SVNotify(src, Config.Language.Notifications.OfferAccepted..jobLabel..' '..gradeLabel..'!', 'success')
    SVNotify(bossId, Config.Language.Notifications.OfferAcceptedHirer, 'success')
    SetTimeout(1000, function()
        TriggerClientEvent('lusty94_bossmenu:client:RefreshEmployeeList', bossId, job)
    end)
end)


--deline hire request
RegisterNetEvent('lusty94_bossmenu:server:DeclineHire', function(bossId)
    SVNotify(bossId, Config.Language.Notifications.OfferDeclined, 'error')
end)


--promote or demote employee
RegisterNetEvent('lusty94_bossmenu:server:PromoteEmployee', function(targetCitizenId, jobName, newGrade, coords)
    local src = source
    local Boss = QBCore.Functions.GetPlayer(src)
    if not Boss or not Boss.PlayerData.job.isboss or Boss.PlayerData.job.name ~= jobName then return end
    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    if Target then
        if not nearPlayer(src, Target.PlayerData.source, maxDist) then return end
        Target.Functions.SetJob(jobName, newGrade)
        SVNotify(Target.PlayerData.source, Config.Language.Notifications.RankChanged, 'success', 30000)
        SVNotify(src, Config.Language.Notifications.RankChangedHirer, 'success')
        sendLog(src, "Security", ('%s Promoted %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetCitizenId), jobName, newGrade), "warning")
        SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | %s Promoted %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetCitizenId), jobName, newGrade))
    else
        local jobInfo = updateJobInfo(jobName, newGrade)
        if jobInfo then
            MySQL.update.await("UPDATE players SET job = ? WHERE citizenid = ?", { json.encode(jobInfo), targetCitizenId })
            SVNotify(src, Config.Language.Notifications.RankChangedHirer, 'success')
        else
            SVNotify(Config.Language.Notifications.InvalidGrade, 'error')
            return
        end
    end
    SetTimeout(1000, function()
        TriggerClientEvent('lusty94_bossmenu:client:RefreshEmployeeList', src, jobName)
    end)
end)


--fire employee
RegisterNetEvent('lusty94_bossmenu:server:FirePlayer', function(targetCitizenId, coords)
    local src = source
    local Boss = QBCore.Functions.GetPlayer(src)
    if not Boss or not Boss.PlayerData.job.isboss then return end
    local jobName = Boss.PlayerData.job.name
    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    if Target then
        if not nearPlayer(src, Target.PlayerData.source, maxDist) then return end
        Target.Functions.SetJob(Config.CoreSettings.Unemployed.Name, 0)
        SVNotify(Target.PlayerData.source, Config.Language.Notifications.Fired, 'error')
        SVNotify(src, Config.Language.Notifications.FiredHirer, 'success')
        sendLog(src, "Security", ('%s Fired %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetCitizenId), jobName, newGrade), "warning")
        SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | %s Fired %s at %s Rank %s'):format(getCharacterName(src), getCharacterName(targetCitizenId), jobName, newGrade))
    else
        local jobInfo = updateJobInfo(Config.CoreSettings.Unemployed.Name, 0)
        if jobInfo then
            MySQL.update.await("UPDATE players SET job = ? WHERE citizenid = ?", { json.encode(jobInfo), targetCitizenId })
            SVNotify(src, Config.Language.Notifications.FiredHirer, 'success')
        else
            SVDebug('^1| Lusty94_BossMenu | DEBUG | ERROR | Invalid unemployed job configuration')
            return
        end
    end
    SetTimeout(1000, function()
        TriggerClientEvent('lusty94_bossmenu:client:RefreshEmployeeList', src, jobName)
    end)
end)


--send announcement
RegisterNetEvent('lusty94_bossmenu:server:SendJobAnnouncement', function(jobName, message)
    local src = source
    local boss = QBCore.Functions.GetPlayer(src)
    if not boss or boss.PlayerData.job.name ~= jobName or not boss.PlayerData.job.isboss then return end
    for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
        if player.PlayerData.job.name == jobName then
            SVNotify(player.PlayerData.source, message, 'success', 10000, 'Management Announcement')
        end
    end
end)


--open stash for qb-inv
RegisterNetEvent('lusty94_bossmenu:server:OpenBossStash', function(jobName, stashID, stashData, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not nearZone(src, jobName, coords) then return end
    exports['qb-inventory']:OpenInventory(src, stashID, {
        maxweight = stashData.weight,
        slots = stashData.slots,
    })
    SVDebug('^3| Lusty94_BossMenu | DEBUG | INFO | Server ID: '..src..' opened: '..stashID..'\nStash data: '..json.encode(stashData))
end)


--register stash for ox_inventory
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if InvType == 'ox' then
            for job, data in pairs(Config.Locations) do
                if data.stash and data.stash.enabled then
                    local stashID = job..'_Management_Stash'
                    exports.ox_inventory:RegisterStash( stashID, job..' Management Stash', data.stash.slots or 64, data.stash.weight or 1000000, false, { [job] = 0 } )
                    print('^3| Lusty94_BossMenu | DEBUG | INFO | Registered ox_inventory stash: '..stashID..' Slots: '..data.stash.slots..' Weight: '..data.stash.weight)
                end
            end
        end
    end
end)


--deposit cash into job bank account
RegisterNetEvent('lusty94_bossmenu:server:DepositMoney', function(jobName, amount, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashSymbol = Config.CoreSettings.Banking.CashSymbol
    if not Player then return end
    if not nearZone(src, jobName, coords) then return end
    if amount <= 0 then SVNotify(src, Config.Language.Notifications.InvalidAmount, 'error') return end
    if not removeCash(src, amount) then SVNotify(src, Config.Language.Notifications.NoCash, 'error') return end
    sendLog(src, "Security", ('%s deposited %s%s to society account %s'):format(getCharacterName(src), CashSymbol, amount, jobName), "warning")
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | %s deposited %s%s to society account %s'):format(getCharacterName(src), CashSymbol, amount, jobName))
    local reason = 'Deposited by '..getCharacterName(src)
    if Banking == 'qb' then
        exports['qb-banking']:AddMoney(jobName, amount, reason)
    elseif Banking == 'okok' then
        exports['okokBanking']:AddMoney(jobName, amount)
    elseif Banking == 'renewed' then
        exports['Renewed-Banking']:addAccountMoney(jobName, amount)
    elseif Banking == 'wasabi' then
        exports['wasabi_banking']:AddMoney('society', jobName, amount)
    elseif Banking == 'tgg' then
        exports['tgg-banking']:AddSocietyMoney(jobName, amount)
    elseif Banking == 'fd' then
        exports.fd_banking:AddMoney(jobName, amount, reason)
    elseif Banking == 'custom' then
        -- custom logic here
    else
        SVDebug('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown banking type!'..tostring(Banking))
    end
    SVNotify(src, Config.Language.Notifications.Deposit..cashSymbol..amount, 'success')
end)


--give employee bonus
RegisterNetEvent('lusty94_bossmenu:server:GiveBonus', function(jobName, amount, who, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(who))
    if not Player then return end
    if not nearZone(src, jobName, coords) then return end
    if not Target then SVNotify(src, Config.Language.Notifications.InvalidID, 'error') return end
    if src == Target.PlayerData.source then SVNotify(src, Config.Language.Notifications.NoSelfBonus, 'error') return end
    if not nearPlayer(src, Target.PlayerData.source, maxDist) then SVNotify(src, Config.Language.Notifications.TargetTooFar, 'error') return end
    if amount <= 0 then SVNotify(src, Config.Language.Notifications.InvalidAmount, 'error') return end
    local removed = false
    local reason ='Bonus given'
    if Banking == 'qb' then
        exports['qb-banking']:RemoveMoney(jobName, amount, reason)
        removed = true
    elseif Banking == 'okok' then
        exports['okokBanking']:RemoveMoney(jobName, amount)
        removed = true
    elseif Banking == 'renewed' then
        exports['Renewed-Banking']:removeAccountMoney(jobName, amount)
        removed = true
    elseif Banking == 'wasabi' then
        exports['wasabi_banking']:RemoveMoney('society', jobName, amount)
        removed = true
    elseif Banking == 'tgg' then
        exports['tgg-banking']:RemoveSocietyMoney(jobName, amount)
        removed = true
    elseif Banking == 'fd' then
        exports.fd_banking:RemoveMoney(jobName, amount, reason)
        removed = true
    elseif Banking == 'custom' then
        -- custom logic here
    else
        SVDebug('^1| Lusty94_BossMenu | DEBUG | ERROR | Unknown banking type!'..tostring(Banking))
    end
    if not removed then SVNotify(src, 'Society does not have the funds to cover that!', 'error') return end
    if removed then addCash(Target.PlayerData.source, amount) end
    SVNotify(Target.PlayerData.source, ('You received a bonus of %s%s from your employer!'):format(CashSymbol, amount), 'success')
    SVNotify(src, ('You gave %s%s to %s as a bonus.'):format(CashSymbol, amount, getCharacterName(Target.PlayerData.source)), 'success')
    sendLog(src, 'Security', ('%s gave a bonus of %s%s to %s'):format(getCharacterName(src), CashSymbol, amount, getCharacterName(Target.PlayerData.source)), 'info')
    SVDebug(('^3| Lusty94_BossMenu | DEBUG | INFO | %s gave a bonus of %s%s to %s'):format(getCharacterName(src), CashSymbol, amount, getCharacterName(Target.PlayerData.source)))
end)


--get messages
RegisterNetEvent('lusty94_bossmenu:server:GetMessages', function(job)
    local src = source
    local boss = QBCore.Functions.GetPlayer(src)
    if not boss or boss.PlayerData.job.name ~= job or not boss.PlayerData.job.isboss then return end
    local messages = MySQL.query.await('SELECT id, sender_name, message, boss_reply FROM employee_messages WHERE job = ?', { job }) or {}
    TriggerClientEvent('lusty94_bossmenu:client:ReadMessages', src, messages)
end)


--get replies
RegisterNetEvent('lusty94_bossmenu:server:RequestReplies', function(job)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local name = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    local message = MySQL.query.await([[ SELECT id, sender_name, message, boss_reply FROM employee_messages WHERE job = ? AND sender_name = ? AND boss_reply IS NOT NULL ]], { job, name })
    TriggerClientEvent('lusty94_bossmenu:client:ViewReplies', src, message)
end)


--save message
RegisterNetEvent('lusty94_bossmenu:server:SaveMessage', function(job, senderName, message)
    MySQL.insert('INSERT INTO employee_messages (job, sender_name, message) VALUES (?, ?, ?)', { job, senderName, message })
    SVNotify(source, Config.Language.Notifications.MessageSent, 'success')
end)


--reply to message
RegisterNetEvent('lusty94_bossmenu:server:ReplyToMessage', function(id, replyText)
    local src = source
    local boss = QBCore.Functions.GetPlayer(src)
    if not boss or not boss.PlayerData.job.isboss then return end
    MySQL.update('UPDATE employee_messages SET boss_reply = ?, replied_at = NOW() WHERE id = ?', { replyText, id })
    SVNotify(source, Config.Language.Notifications.ReplySent, 'success')
end)


--delete messages
RegisterNetEvent('lusty94_bossmenu:server:ClearMessages', function(job)
    local src = source
    local boss = QBCore.Functions.GetPlayer(src)
    if not boss or boss.PlayerData.job.name ~= job or not boss.PlayerData.job.isboss then return end
    MySQL.query('DELETE FROM employee_messages WHERE job = ?', { job })
    SVNotify(source, Config.Language.Notifications.MessagesCleared, 'success')
end)


--delete reply
RegisterNetEvent('lusty94_bossmenu:server:DeleteReply', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local jobName = Player.PlayerData.job.name
    local char = Player.PlayerData.charinfo
    local senderName = ("%s %s"):format(char.firstname, char.lastname)
    if Player.PlayerData.job.isboss then
        local messageJob = MySQL.scalar.await('SELECT job FROM employee_messages WHERE id = ?', { id })
        if messageJob ~= jobName then return end
        MySQL.update('DELETE FROM employee_messages WHERE id = ?', { id })
        SVNotify(src, Config.Language.Notifications.MessageCleared, 'success')
        return
    end
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM employee_messages WHERE id = ? AND sender_name = ?', { id, senderName })
    if result > 0 then
        MySQL.update('DELETE FROM employee_messages WHERE id = ?', { id })
        SVNotify(src, Config.Language.Notifications.ReplyCleared, 'success')
    else
        SVNotify(src, Config.Language.Notifications.DeleteError, 'error')
    end
end)


---------------< MISC >---------------

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Lusty94/UpdatedVersions/main/BossMenu/version.txt', function(err, newestVersion, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not newestVersion then print('^1[Lusty94_BossMenu]^7: Unable to fetch the latest version.') return end
        newestVersion = newestVersion:gsub('%s+', '')
        currentVersion = currentVersion and currentVersion:gsub('%s+', '') or 'Unknown'
        if newestVersion == currentVersion then
            print(string.format('^2[Lusty94_BossMenu]^7: ^6You are running the latest version.^7 (^2v%s^7)', currentVersion))
        else
            print(string.format('^2[Lusty94_BossMenu]^7: ^3Your version: ^1v%s^7 | ^2Latest version: ^2v%s^7\n^1Please update to the latest version | Changelogs can be found in the support discord.^7', currentVersion, newestVersion))
        end
    end)
end

CheckVersion()