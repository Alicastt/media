
EventsMod_Json = {}


local function ReadJson(name)

    local fullString = ""
    local file =  getModFileReader('EventsMod', 'media/data/' .. name .. ".json", false)
    local line = file:readLine()
    local count = 1
    while line ~= nil do
        fullString = fullString .. line .. "\n"
        line = file:readLine()
        count = count + 1
    end
    file:close()
    return fullString
end



function EventsMod_Json:write(name, elements)
    local encodedJson = self.handler.stringify(elements)
    local writer = getModFileWriter('EventsMod', 'media/data/' .. name .. ".json", true, false)
    writer:write(encodedJson)
    writer:close()

end




function EventsMod_Json:fetch(jsonName)
    local string = ReadJson(jsonName)
    self[jsonName] = self.handler.parse(string)[jsonName]

end



function EventsMod_Json:updateVehicles()
    print("EventsMod: updating vehicles json")
	local vehicleList = getScriptManager():getAllVehicleScripts()

    local vehiclesTemp = {}
    vehiclesTemp.vehicles = {}
    vehiclesTemp.vehicles.GenericEvent = {}

    local tempTableIndex = 1

    for i = 1, vehicleList:size() do

        local name = vehicleList:get(i - 1):getName()
		if not string.contains(name, "Burnt") and not string.contains(name, "Smashed") and not string.contains(name, "Trailer") then

            vehiclesTemp.vehicles.GenericEvent[tempTableIndex] = {}
            vehiclesTemp.vehicles.GenericEvent[tempTableIndex].carName = name
        
            -- Fetch rarity from the old table and reapplies it to the new one
            for _, v in pairs(self.vehicles) do
                if name == v.carName then
                    vehiclesTemp.vehicles.GenericEvent[tempTableIndex].spawnChance = v.spawnChance
                    break
                end

            end

            if vehiclesTemp.vehicles.GenericEvent[tempTableIndex].spawnChance == nil then
                vehiclesTemp.vehicles.GenericEvent[tempTableIndex].spawnChance = ZombRand(1,25)     
            end

            tempTableIndex = tempTableIndex + 1
        end
    end

    self:write("vehicles", vehiclesTemp)
    -- Reread it
    self:fetch("vehicles")

end

function EventsMod_Json:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.handler = require("JSON")
    return o
end
