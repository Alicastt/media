local ClientCommands = {}

ClientCommands.UpdateJsons = function(_, args)
    --print("EventsMod: received update json call")
    EventsMod_Core.jsonHandler:updateVehicles(_)
end


ClientCommands.TriggerEvent = function(_, args)
    EventsMod_Core.event = EventsMod_Event:new(EventsMod_Core.jsonHandler)

    local chosenCoordinates = EventsMod_Core.event:getCoordinates()
    local baseAnnouncement = EventsMod_Core.event:getAnnouncement()
    local announcement = baseAnnouncement .. "X = " .. chosenCoordinates.x .. ", Y = " .. chosenCoordinates.y
    print(announcement)

    -- Send the announcement in chat if we're on a server
    if isServer() then
        local firstPlayer = getPlayerByOnlineID(0)
        sendServerCommand(firstPlayer, "EventsMod", "SendChatAlarm", {message = announcement})
    end
    Events.OnTick.Add(EventsMod_Core.EventLoop)

end

----------------

OnClientCommand = function(module, command, playerObj, args)
    print("Received client command: " .. command)
    if module == 'EventsMod' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
