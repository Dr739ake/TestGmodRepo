freeway = freeway or {}
freeway.ServerStatus = freeway.ServerStatus or {}
freeway.ServerStatus.ServerId = freeway.ServerStatus.ServerId || "noid"
freeway.ServerStatus.UpdateTimeout = 10
freeway.ServerStatus.AlwaysUseSteamNames = true

freeway.ServerStatus.SteamNameCache = freeway.ServerStatus.SteamNameCache || {}
freeway.ServerStatus.BotIP = "http://88.99.104.34:18769/"

-- lua_run freeway.ServerStatus.SendStatus() 

function freeway.ServerStatus.SendStatus(ply)
    //print("------------")
    //PrintTable(freeway.ServerStatus)
    //print("------------")
    if ( freeway.ServerStatus.ServerId == "noid") then return end
    if ( freeway.ServerStatus.BotIP == nil || freeway.ServerStatus.BotIP == "" ) then return end

    local data = {
        name = GetHostName(),
        players = {},
        map = game.GetMap(),
        maxPlayers = game.MaxPlayers(),
        ip = game.GetIPAddress()
    }

    for _, ply in pairs(player.GetAll()) do
        //table.insert(data.players, ply:Name())
        local playerName = ""
        if (freeway.ServerStatus.AlwaysUseSteamNames) then
            playerName = freeway.ServerStatus.SteamNameCache[ply:SteamID64()] || ply:Name()
        else
            playerName = ply:Name()
        end
        table.insert(data.players, playerName)
    end
    
    //PrintTable(data)

    if (ply != nil) then
        //print("thats a disconnect, remove " .. ply:Nick())
        local playerName = ""
        if (freeway.ServerStatus.AlwaysUseSteamNames) then
            playerName = freeway.ServerStatus.SteamNameCache[ply:SteamID64()] || ply:Name()
        else
            playerName = ply:Name()
        end
        table.RemoveByValue(data.players, playerName)
    end

    local tbl = {
        failed  = function(str) /*print("[HTTP] failed: " .. str)*/ end,
        success = function(code, body, head) /*print("[HTTP] success")*/ end,
        method  = "POST",
        url     = freeway.ServerStatus.BotIP,
        headers = {
            serverid = freeway.ServerStatus.ServerId
        },
        body    = util.TableToJSON(data),
        timeout = 5,
    }
    HTTP(tbl)
    //print("[freeway.ServerStatus] Status updated")
end

hook.Add("Initialize", "ServerStatus_init", function()
    if (not file.Exists("freeway", "data")) then
        file.CreateDir("freeway", "data")
    end
    local n = nil
    if ( file.Exists("freeway/ServerStatus.txt", "data")) then
        n = file.Read("freeway/ServerStatus.txt", "data")
    end
    if n == nil then
        n = math.random(1, 100000000000)
        file.Write("freeway/ServerStatus.txt", n)
    end

    freeway.ServerStatus.ServerId = n
    freeway.ServerStatus.SendStatus() 
end)


hook.Add("PlayerInitialSpawn", "Freeway_ServerStatusUpdate_PlayerInitialSpawn", function(ply)
    freeway.ServerStatus.SendStatus()
    freeway.ServerStatus.SteamNameCache[ply:SteamID64()] = ply:Nick()
end)
hook.Add("PlayerDisconnected", "Freeway_ServerStatusUpdate_PlayerDisconnected", function(ply)
    freeway.ServerStatus.SendStatus(ply)
end)

timer.Create("Freeway_ServerStatusUpdate_scheduled_updates", freeway.ServerStatus.UpdateTimeout, 0, freeway.ServerStatus.SendStatus)