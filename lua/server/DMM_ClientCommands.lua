local ClientCommands = {}

ClientCommands.UpdateJsons = function(_, args)
    --print("DMM: received update json call")
    DMM_Core.jsonHandler:updateVehicles(_)
end


ClientCommands.TriggerEvent = function(_, args)
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

----------------

OnClientCommand = function(module, command, playerObj, args)
    print("Received client command: " .. command)
    if module == 'DMM' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
