Config = {}


--
--██╗░░░░░██╗░░░██╗░██████╗████████╗██╗░░░██╗░█████╗░░░██╗██╗
--██║░░░░░██║░░░██║██╔════╝╚══██╔══╝╚██╗░██╔╝██╔══██╗░██╔╝██║
--██║░░░░░██║░░░██║╚█████╗░░░░██║░░░░╚████╔╝░╚██████║██╔╝░██║
--██║░░░░░██║░░░██║░╚═══██╗░░░██║░░░░░╚██╔╝░░░╚═══██║███████║
--███████╗╚██████╔╝██████╔╝░░░██║░░░░░░██║░░░░█████╔╝╚════██║
--╚══════╝░╚═════╝░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░░░░░░╚═╝


-- Thank you for downloading this script!

-- Below you can change multiple options to suit your server needs.

-- Extensive documentation detailing this script and how to confiure it correclty can be found here: https://lusty94-scripts.gitbook.io/documentation/free/boss-menu

Config.CoreSettings = {
    Debug = {
        Prints = true, -- sends debug prints to f8 console and txadmin server console
        Zones = false, -- debug circle zones for menu locations
    },
    Target = { -- target type - support for qb-target and ox_target  
        Type = 'qb',      
        --EDIT CLIENT/BOSSMENU_CLIENT.LUA TO ADD YOUR OWN TARGET SUPPORT
        --use 'qb' for qb-target
        --use 'ox' for ox_target
        --use 'custom' for custom target
    },
    Notify = { -- notification type - support for qb-core notify okokNotify, mythic_notify, ox_lib notify and qs-notify (experimental not tested)
        --EDIT CLIENT/BOSSMENU_CLIENT.LUA & SERVER/BOSSMENU_SERVER.LUA TO ADD YOUR OWN NOTIFY SUPPORT
        Type = 'qb',
        --use 'qb' for default qb-core notify
        --use 'okok' for okokNotify
        --use 'mythic' for mythic_notify
        --use 'ox' for ox_lib notify
        --use 'qs' for qs-notify (experimental not tested) (qs-interface)  -- some logic might need adjusting
        --use 'custom' for custom notifications
    },
    Inventory = { -- inventory type - support for qb-inventory ox_inventory - (THIS IS ONLY USED FOR THE CASH DEPOSIT)
        --EDIT CLIENT/BOSSMENU_CLIENT.LUA & SERVER/BOSSMENU_SERVER.LUA TO ADD YOUR OWN INVENTORY SUPPORT
        Type = 'qb',
        --use 'qb' for qb-inventory
        --use 'ox' for ox_inventory
        --use 'custom' for custom inventory
    },
    Clothing = {
        Type = 'qb' -- clothing type, support for qb-clothing and illenium-appearance
        -- EDIT CLIENT/BOSSMENU_CLIENT.LUA TO ADD YOUR OWN CLOTHING SUPPORT
        --use 'qb' for qb-clothing
        --use 'illenium' for illenium-appearance
        --use 'custom' for your own clothing script
    },
    Banking = { -- support for qb-banking, okokBanking and renewed-banking
        -- EDIT SERVER/BOSSMENU_SERVER.LUA TO ADD YOUR OWN BANKING SUPPORT
        CashSymbol = '£', -- cash symbol used in your server
        Type = 'qb',
        --use 'qb' for qb-banking
        --use 'okok' for okokBanking
        --use 'renewed' for renewed-banking
        -- use 'custom' for custom banking
    },
    Unemployed = { -- when firing an employee what is their default unemployed job name and rank this must be in your jobs.lua
        Name = 'unemployed', -- job name in jobs.lua
    },
}


--define boss menu locations
Config.Locations = {
    ['police'] = { -- the key is the job name
        coords = vector3(440.66, -975.71, 30.69), -- target zone coords
        image = 'https://files.fivemerr.com/images/d4e20c2d-9020-4c26-83f1-afe3de6c92b0.png', -- job image url
        blip = {
            enabled = true, -- enable blip for management menu
            id = 60, -- blip id
            colour = 3, -- blip colour
            scale = 0.7, -- blip scale
            title = 'Job Management', -- blip title
        },
        stash = {
            enabled = true, -- enable boss stash for this job
            slots = 64, -- stash slots
            weight = 10000000, -- stash weight
        },
    },
    ['ambulance'] = { -- the key is the job name
        coords = vector3(301.25, -600.54, 43.29), -- target zone coords
        image = 'https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png', -- job image url
        blip = {
            enabled = true, -- enable blip for management menu
            id = 61, -- blip id
            colour = 2, -- blip colour
            scale = 0.7, -- blip scale
            title = 'Job Management', -- blip title
        },
        stash = {
            enabled = true, -- enable boss stash for this job
            slots = 64, -- stash slots
            weight = 10000000, -- stash weight
        },
    },
    ['mechanic'] = { -- the key is the job name
        coords = vector3(-345.56, -123.13, 39.01), -- target zone coords
        image = 'https://files.fivemerr.com/images/efea0272-aa3e-4e54-a09f-652a0d7a5ce3.png', -- job image url
        blip = {
            enabled = true, -- enable blip for management menu
            id = 72, -- blip id
            colour = 5, -- blip colour
            scale = 0.7, -- blip scale
            title = 'Job Management', -- blip title
        },
        stash = {
            enabled = true, -- enable boss stash for this job
            slots = 64, -- stash slots
            weight = 10000000, -- stash weight
        },
    },
    ['realestate'] = { -- the key is the job name
        coords = vector3(-698.71, 271.0, 83.11), -- target zone coords
        image = 'https://files.fivemerr.com/images/b2b531fb-b83f-49a0-a7df-8d160cf500bb.png', -- job image url
        blip = {
            enabled = true, -- enable blip for management menu
            id = 40, -- blip id
            colour = 5, -- blip colour
            scale = 0.7, -- blip scale
            title = 'Job Management', -- blip title
        },
    },
    ['cardealer'] = { -- the key is the job name
        coords = vector3(-31.05, -1106.59, 26.42), -- target zone coords
        image = 'https://files.fivemerr.com/images/3a891fcf-b2c7-40f1-b2f7-67dfcd364780.png', -- job image url
        blip = {
            enabled = true, -- enable blip for management menu
            id = 40, -- blip id
            colour = 5, -- blip colour
            scale = 0.7, -- blip scale
            title = 'Job Management', -- blip title
        },
        stash = {
            enabled = true, -- enable boss stash for this job
            slots = 64, -- stash slots
            weight = 10000000, -- stash weight
        },
    },
    --add more jobs as required
}



Config.Language = {
    Notifications = {
        Busy = 'You are already doing something!',
        Cancelled = 'Action cancelled!',
        NoAccess = 'You dont have access to this!',
        TooFar = 'You are too far away to do that!',
        OnlyEmployee = 'No other employees are online!',
        NoOneOnline = 'There are no online employees for you to do that!',
        NoOneNear = 'There is no one nearby!',
        AlreadyEmployed = 'The person you are trying to employ already works here!',
        OfferReceived = 'You have received a job offer!',
        OfferSent = 'Job offer sent!',
        OfferAccepted = 'You accepted the job offer for: ',
        OfferAcceptedHirer = 'They accepted the job offer!',
        OfferDeclined = 'The offer was declined!',
        RankChanged = 'Your rank has changed!',
        RankChangedHirer = 'Rank changed successfully!',
        Fired = 'You have been fired!',
        FiredHirer = 'Employee has been fired!',
        InvalidAmount = 'You have entered an invalid amount!',
        NoCash = 'You dont have any cash to deposit!',
        Deposit = 'You have successfully deposited: ',
        NotEmployedHere = 'This person is not employed here!',
        DeclinedOffer = 'You declined the job offer!',
        InvalidMessage = 'Invalid message',
        AlreadyReplied = 'You have already replied to this message!',
        NoReplies = 'You dont have any replies!',
        InvalidGrade = 'You have selected an invalid grade for this job!',
        MessageSent = 'Your message has been sent!',
        ReplySent = 'Your reply has been sent!',
        MessageCleared = 'This message has been deleted!',
        MessagesCleared = 'All messages have been deleted!',
        ReplyCleared = 'This reply has been deleted!',
        RepliesCleared = 'Replies have been deleted!',
        DeleteError = 'You can only delete your own messages!',
    }
}