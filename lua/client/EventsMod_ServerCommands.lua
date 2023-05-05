
local ServerCommands = {}

ServerCommands.SendChatAlarm = function(args)
    -- FIXME This doesn't work in SP
    local message = args.message
	SendCommandToServer(string.format('/servermsg "%s" ', message))
		
end
----------------------------------------------

local function OnServerCommand(module, command, args)
    if module == 'EventsMod' then
        if ServerCommands[command] then
            args = args or {}
            ServerCommands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)