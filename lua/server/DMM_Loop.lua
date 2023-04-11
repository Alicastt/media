DMM_Core = DMM_Core or {}

---Specific loop only for handling queued events
DMM_Core.EventLoop = function(_)
    if DMM_Core.event then

        local sq = DMM_Core.event:getSquare()
        
        if sq == nil then
            return
        end
        local playerInSquare = DMM_Core.CheckPlayerInSquare(sq)
        if playerInSquare then

            --print("DMM: Spawning the horde!!")
            local coordinates = DMM_Core.event:getCoordinates()
            DMM_Core.SpawnHorde(playerInSquare, DMM_Core.event:getZombieAmount(), coordinates)

            --print("DMM: Spawning vehicle")
            DMM_Core.SpawnVehicles(playerInSquare, DMM_Core.event:getVehiclesTable(),DMM_Core.event:getItemsTable(), coordinates)

            DMM_Core.event = nil
            Events.OnTick.Remove(DMM_Core.EventLoop)

        end
    end
end

---Main loop, every hour
DMM_Core.MainLoop = function()
    local chance = 1000 --SandboxVars.DMM.ChanceOfEvent
    if ZombRand(1,100) <= chance and DMM_Core.event == nil then
        DMM_Core.event = DMM_Event:new(DMM_Core.jsonHandler)

        local chosenCoordinates = DMM_Core.event:getCoordinates()
        local baseAnnouncement = DMM_Core.event:getAnnouncement()
        local announcement = baseAnnouncement .. "X = " .. chosenCoordinates.x .. ", Y = " .. chosenCoordinates.y
        print(announcement)

        -- Send the announcement in chat if we're on a server
        if isServer() then
            local firstPlayer = getPlayerByOnlineID(0)
            sendServerCommand(firstPlayer, "DMM", "SendChatAlarm", {message = announcement})
        end
        Events.OnTick.Add(DMM_Core.EventLoop)
    end


end

---Init for main loop and JSONs
DMM_Core.StartMainLoop = function()
    print("DMM: starting loop, instancing handler")
    DMM_Core.jsonHandler = DMM_Json:new()
    DMM_Core.jsonHandler:fetch("events")
    DMM_Core.jsonHandler:fetch("vehicles")
    DMM_Core.jsonHandler:fetch("items")
    DMM_Core.jsonHandler:fetch("spawns")





    Events.EveryHours.Add(DMM_Core.MainLoop)
end

if not isClient() and not isServer() then
    Events.OnGameStart.Add(DMM_Core.StartMainLoop)
else
    Events.OnServerStarted.Add(DMM_Core.StartMainLoop)
end
