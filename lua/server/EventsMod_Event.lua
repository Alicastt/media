-- Queue system.


EventsMod_Event = {}


local FindCoordinates = function(spawnsTable, eventName)
    local indexSpawn = ZombRand(1, #spawnsTable[eventName])
    return spawnsTable[eventName][indexSpawn]
end

local FindZombieAmount = function()
    local amount
    if SandboxVars.EventsMod.MinAmountZombie < SandboxVars.EventsMod.MaxAmountZombie then
        amount = ZombRand(SandboxVars.EventsMod.MinAmountZombie, SandboxVars.EventsMod.MaxAmountZombie)
    else
        amount = SandboxVars.EventsMod.MinAmountZombie
    end

    return amount
end


local FindEventTable = function(eventsJsonTable)
    local foundEvent = false
    while not foundEvent do
        for k, v in pairs(eventsJsonTable) do
            if v.chance >= ZombRand(1, 100) then
                --print("EventsMod: Event found => " .. k)
                return { k, v.announcement, v.hasVehicle, v.spawnCoords, v.weapons, v.ammo, v.gunMag, v.weaponPart }
            end
        end
    end
end



local FindItemsInVehicle = function(itemsJsonTable, eventName, hasVehicle)
    local itemsTable = {}
    local itemIndex = 1

    if hasVehicle then
        while #itemsTable == 0 do
            for k, eventItems in pairs(itemsJsonTable) do
                if k == eventName then
                    for i = 1, #eventItems do
                        local singleItemTable = eventItems[i]
                        if singleItemTable.chance >= ZombRand(1, 100) then
                            --print("EventsMod ITEM NAME: " .. singleItemTable.itemName)
                            itemsTable[itemIndex] = singleItemTable.itemName
                            itemIndex = itemIndex + 1
                        end
                    end
                end
            end
        end
        return itemsTable
    end
    return {}
end

function EventsMod_Event:toTable()
    return {
        zombieAmount = self.zombieAmount,
        eventTable = self.eventTable,
        vehiclesTable = self.vehiclesTable,
        itemsInVehicleTable = self.itemsInVehicleTable,
        coordinates = self.coordinates
    }
end

local FindVehicle = function(vehiclesJsonTable, eventType, hasVehicle)
    local chosenVehiclesTable = {}
    local foundVehicleCount = 0

    if hasVehicle then
        if #vehiclesJsonTable[eventType] == 0 then
            print("EventsMod: no specific vehicles for this event type, switching to Generic")
            eventType = "GenericEvent"
        end

        while foundVehicleCount < 2 do
            for i = 1, #vehiclesJsonTable[eventType] do
                local v = vehiclesJsonTable[eventType][i]
                local spawnChance = v.spawnChance

                if ZombRand(1, 100) <= spawnChance then
                    chosenVehiclesTable[foundVehicleCount + 1] = {}
                    chosenVehiclesTable[foundVehicleCount + 1].carName = v.carName

                    foundVehicleCount = foundVehicleCount + 1
                    if foundVehicleCount == 1 and ZombRand(1, 100) > 30 then
                        -- Si ya se encontró un vehículo y no se cumple el 30% de probabilidad, termina la búsqueda.
                        break
                    elseif foundVehicleCount == 2 then
                        -- Si se encontraron dos vehículos, termina la búsqueda.
                        break
                    end
                end
            end
            if foundVehicleCount > 0 then
                break
            end
        end
        return chosenVehiclesTable
    end

    return {}
end



-----------------------------------------


function EventsMod_Event:getSquare()
    local coordinates = self.coordinates

    local x = coordinates.x
    local y = coordinates.y
    local z = coordinates.z

    local square = getSquare(x, y, z)
    return square
end

function EventsMod_Event:getVehiclesTable()
    return self.vehiclesTable
end

function EventsMod_Event:getItemsTable()
    return self.itemsInVehicleTable
end

function EventsMod_Event:getAnnouncement()
    if self.eventTable[2] then
        return self.eventTable[2]
    end

    return "Generic Announcement, location: "
end

function EventsMod_Event:getVehicle()
    return self.eventTable[3]
end

function EventsMod_Event:getEventName()
    return self.eventTable[4]
end

function EventsMod_Event:getWeaponsNumber()
    return self.eventTable[5]
end

function EventsMod_Event:getAmmoNumber()
    return self.eventTable[6]
end

function EventsMod_Event:getMagNumber()
    return self.eventTable[7]
end

function EventsMod_Event:getWeaponPartsNumber()
    return self.eventTable[7]
end

function EventsMod_Event:getZombieAmount()
    return self.zombieAmount
end

function EventsMod_Event:getCoordinates()
    return self.coordinates
end

function EventsMod_Event:getEvent()
    return self.coordinates
end

function EventsMod_Event:new(jsonHandler)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.zombieAmount = FindZombieAmount()
    o.eventTable = FindEventTable(jsonHandler.events)
    o.vehiclesTable = FindVehicle(jsonHandler.vehicles, o.eventTable[1], o.eventTable[3])
    o.itemsInVehicleTable = FindItemsInVehicle(jsonHandler.items, o.eventTable[1], o.eventTable[3])
    o.coordinates = FindCoordinates(jsonHandler.spawns, o.eventTable[4])



    return o
end
