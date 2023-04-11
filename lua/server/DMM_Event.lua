-- Queue system.


DMM_Event = {}


local FindCoordinates = function(spawnsTable)
    local indexSpawn = ZombRand(1, #spawnsTable)
    return spawnsTable[indexSpawn]
end

local FindZombieAmount = function()

    local amount
    if SandboxVars.DMM.MinAmountZombie< SandboxVars.DMM.MaxAmountZombie then
        amount = ZombRand(SandboxVars.DMM.MinAmountZombie, SandboxVars.DMM.MaxAmountZombie)
    else
        amount = SandboxVars.DMM.MinAmountZombie
    end

    return amount
end


local FindEventTable = function(eventsJsonTable)
    local foundEvent = false
    while not foundEvent do
        for k,v in pairs(eventsJsonTable) do
            if v.chance >= ZombRand(1,100) then
                --print("DMM: Event found => " .. k)
                return {k, v.announcement}
            end

        end
    
    end


end



local FindItemsInVehicle = function(itemsJsonTable, eventName)

    local itemsTable = {}
    local itemIndex = 1

    while #itemsTable == 0 do

        for k, eventItems in pairs(itemsJsonTable) do
            if k == eventName then
                for i = 1, #eventItems do
                    local singleItemTable = eventItems[i]
                    if singleItemTable.chance >= ZombRand(1, 100) then
                        --print("DMM ITEM NAME: " .. singleItemTable.itemName)
                        itemsTable[itemIndex] = singleItemTable.itemName
                        itemIndex = itemIndex + 1
                    end
                end
            end
        end
    end

    return itemsTable
end


local FindVehicle = function(vehiclesJsonTable, eventType)

    -- TODO Right now it only gets a single vehicle, but we should get multiple
    local chosenVehiclesTable = {}
    local foundVehicle = false

    local indexChosen = 1

    if #vehiclesJsonTable[eventType] == 0 then
        print("DMM: no specific vehicles for this event type, switching to Generic")
        eventType = "GenericEvent"
    end

    
    while not foundVehicle do
        for i = 1, #vehiclesJsonTable[eventType] do
            
            local v = vehiclesJsonTable[eventType][i]
            local spawnChance = v.spawnChance

            -- if indexChosen >= SandboxVars.DMM.MaxAmountSpawnedCars then
            --     break
            -- end
            
            if ZombRand(1, 100) <= spawnChance then
                chosenVehiclesTable[indexChosen] = {}
                chosenVehiclesTable[indexChosen].carName = v.carName

                indexChosen = indexChosen + 1
                foundVehicle = true
                break
            end
        end

    end


    return chosenVehiclesTable

end


-----------------------------------------


function DMM_Event:getSquare()
    local coordinates = self.coordinates

    local x = coordinates.x
    local y = coordinates.y
    local z = coordinates.z

    local square = getSquare(x, y, z)
    return square
end

function DMM_Event:getVehiclesTable()
    return self.vehiclesTable
end

function DMM_Event:getItemsTable()
    return self.itemsInVehicleTable
end

function DMM_Event:getAnnouncement()
    if self.eventTable[2] then
        return self.eventTable[2]
    end

    return "Generic Announcement, location: "
end

function DMM_Event:getZombieAmount()

    return self.zombieAmount

end

function DMM_Event:getCoordinates()
    return self.coordinates
end

function DMM_Event:new(jsonHandler)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.zombieAmount = FindZombieAmount()
    o.eventTable = FindEventTable(jsonHandler.events)
    o.vehiclesTable = FindVehicle(jsonHandler.vehicles, o.eventTable[1])
    o.itemsInVehicleTable = FindItemsInVehicle(jsonHandler.items, o.eventTable[1])
    o.coordinates = FindCoordinates(jsonHandler.spawns)




    return o
end