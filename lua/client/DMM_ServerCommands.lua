
local ServerCommands = {}

ServerCommands.SpawnZombies = function(args)
    print("RECEIVE SPAWN HORDE")
    local coordinates = args.coordinates
    local amount = args.amount
    local radius = args.radius

	SendCommandToServer(string.format("/createhorde2 -x %d -y %d -z %d -count %d -radius %d -crawler %s -isFallOnFront %s -isFakeDead %s -knockedDown %s -health %s ", 
        coordinates.x, coordinates.y, coordinates.z, amount, radius, tostring(false), tostring(false), tostring(false), tostring(false), tostring(100)))
		

end

ServerCommands.SendChatAlarm = function(args)
    -- FIXME This doesn't work in SP
    local message = args.message
	SendCommandToServer(string.format('/servermsg "%s" ', message))
		
end
----------------------------------------------

local function OnServerCommand(module, command, args)
    if module == 'DMM' then
        if ServerCommands[command] then
            args = args or {}
            ServerCommands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)