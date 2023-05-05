EventsMod_Core = EventsMod_Core or {}

---Specific loop only for handling queued events
EventsMod_Core.EventLoop = function(_)
    if EventsMod_Core.event then
        local sq = EventsMod_Core.event:getSquare()

        if sq == nil then
            return
        end
        local playerInSquare = EventsMod_Core.CheckPlayerInSquare(sq)
        if playerInSquare then
            --print("EventsMod: Spawning the horde!!")
            local coordinates = EventsMod_Core.event:getCoordinates()
            print(coordinates.x)
            print(coordinates.y)
            EventsMod_Core.SpawnHorde(playerInSquare, EventsMod_Core.event:getZombieAmount(), coordinates)

            --print("EventsMod: Spawning vehicle")
            EventsMod_Core.SpawnVehicles(playerInSquare, EventsMod_Core.event:getVehiclesTable(), EventsMod_Core.event:getItemsTable(),
            coordinates, EventsMod_Core.event:getVehicle(), EventsMod_Core.event:getWeaponsNumber(), EventsMod_Core.event:getAmmoNumber(), EventsMod_Core.event:getMagNumber(), EventsMod_Core.event:getWeaponPartsNumber())

            local eventName = EventsMod_Core.event:getEventName()

            if eventName == "Medkits" then
                local lootCoords = { x = 12923, y = 2013, z = 2 }
                EventsMod_Core.SpawnSpecialItem(lootCoords, "EventsMod.ExperimentalSyringe", 3, 5)
                EventsMod_Core.SpawnSpecialItem(lootCoords, "FN_P90", 3, 1)
                EventsMod_Core.SpawnSpecialItem(lootCoords, "P90Clip", 3, 2)
                EventsMod_Core.SpawnSpecialItem(lootCoords, "Bullets57Box", 3, 4)
            end

            EventsMod_Core.event = nil
            EventsMod_Core.removeSavedEvent()
            Events.OnTick.Remove(EventsMod_Core.EventLoop)
        end
    end
end

---Main loop, every hour
EventsMod_Core.MainLoop = function()
    local chance = 1000 --SandboxVars.EventsMod.ChanceOfEvent
    print("EventsMod: Decidiendo Proximo evento 1")
    if ZombRand(1, 100) <= chance and EventsMod_Core.event == nil then
        EventsMod_Core.event = EventsMod_Event:new(EventsMod_Core.jsonHandler)
        print("EventsMod: Decidiendo Proximo evento 2")
        local chosenCoordinates = EventsMod_Core.event:getCoordinates()
        local baseAnnouncement = EventsMod_Core.event:getAnnouncement()
        local announcement = baseAnnouncement .. "X = " .. chosenCoordinates.x .. ", Y = " .. chosenCoordinates.y
        print(announcement)

        -- Guarda el evento en el archivo
        EventsMod_Core.SaveEvents(EventsMod_Core.event)
        -- Send the announcement in chat if we're on a server
        if isServer() then
            local firstPlayer = getPlayerByOnlineID(0)
            sendServerCommand(firstPlayer, "EventsMod", "SendChatAlarm", { message = announcement })
        end
        Events.OnTick.Add(EventsMod_Core.EventLoop)
    end
end


---Init for main loop and JSONs
EventsMod_Core.StartMainLoop = function()
    print("EventsMod: starting loop, instancing handler")
    EventsMod_Core.jsonHandler = EventsMod_Json:new()
    EventsMod_Core.jsonHandler:fetch("events")
    EventsMod_Core.jsonHandler:fetch("vehicles")
    EventsMod_Core.jsonHandler:fetch("items")
    EventsMod_Core.jsonHandler:fetch("spawns")

    -- Carga el evento guardado si existe
    local event = EventsMod_Core.LoadEvents()
    if event then
        print("Entra en añadir evento")
        EventsMod_Core.event = event
        Events.OnTick.Add(EventsMod_Core.EventLoop)
    end

    Events.EveryHours.Add(EventsMod_Core.MainLoop)
end

if not isClient() and not isServer() then
    Events.OnGameStart.Add(EventsMod_Core.StartMainLoop)
else
    Events.OnServerStarted.Add(EventsMod_Core.StartMainLoop)
end
