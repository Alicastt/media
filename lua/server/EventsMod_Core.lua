EventsMod_Core = EventsMod_Core or {}

EventsMod_Core.square = nil
EventsMod_Core.event = nil
EventsMod_Core.savedEventsFile = "eventos_guardados.txt"
EventsMod_Core.savedEventsFilePath = "../../../eventos_guardados.txt"


EventsMod_Core.SpawnCrates = function()
    --It gets created but you cant interact with it for some reason. So commenting it for now
    -- print("Creating Object")
    -- local sq = getSquare(12491, 4277, 0)
    -- local crate = IsoObject.new(sq, "location_military_generic_01_0", nil)
    -- sq:AddTileObject(crate)
    -- crate.transmitCompleteItemToServer()
    -- print("Object Created")
end

EventsMod_Core.SpawnSpecialItem = function(coords, itemName, index, quantity)
    local sq = getSquare(coords.x, coords.y, coords.z)
    local container = sq:getObjects():get(index - 1):getContainer()
    if container then
        for i = 1, quantity do
            local item = InventoryItemFactory.CreateItem(itemName)
            print(item)
            container:addItem(item)
        end
        sendItemsInContainer(sq:getObjects():get(index - 1), container)
    end
end

EventsMod_Core.SpawnVehicles = function(playerInSquare, vehiclesTable, itemsTable, coordinates, hasVehicle,
                                        weaponItemCount,
                                        ammoItemCount, gunMagItemCount, weaponsPartNumber)
    if (hasVehicle) then
        local allItems = getScriptManager():getAllItems()
        local weaponItems = {}
        local ammoItems = {}
        local magItems = {}
        local weaponsPartItems = {}
        for i = 0, allItems:size() - 1 do
            local item = allItems:get(i)
            if not item:getObsolete() and not item:isHidden() then
                if item:isRanged() then
                    table.insert(weaponItems, item:getFullName())
                end
                if item:getDisplayCategory() == "Ammo" and string.find(item:getFullName(), "Box") then
                    table.insert(ammoItems, item:getFullName())
                end
                if item:getDisplayCategory() == "GunMag" then
                    table.insert(magItems, item:getFullName())
                end
                if item:getDisplayCategory() == "WeaponPart" then
                    table.insert(weaponsPartItems, item:getFullName())
                end
            end
        end

        for index, v in ipairs(vehiclesTable) do
            local spawnSquare = getSquare(coordinates.x, coordinates.y, coordinates.z)

            if index > 1 then
                local offsetX = ZombRand(-6, 7) 
                local offsetY = ZombRand(-6, 7)
                spawnSquare = getSquare(coordinates.x + offsetX, coordinates.y + offsetY, coordinates.z)
            end


            local currentVehicle = addVehicleDebug(v.carName, IsoDirections.E, -1, spawnSquare)
            currentVehicle:setGeneralPartCondition(0.5, 40)
            currentVehicle:setGeneralPartCondition(0.5, 40)

            -- Crear una lista de contenedores de objetos en el vehículo
            local containers = {}
            for partIndex = 1, currentVehicle:getPartCount() do
                local part = currentVehicle:getPartByIndex(partIndex - 1)
                if part:getItemContainer() then
                    table.insert(containers, part:getItemContainer())
                end
            end

            local containerCount = #containers

            -- Agregar objetos aleatorios de itemsTable en contenedores
            for _, itemTypeName in ipairs(itemsTable) do
                local item = InventoryItemFactory.CreateItem(itemTypeName)
                local containerIndex = ZombRand(1, containerCount + 1)
                containers[containerIndex]:addItem(item)
            end

            -- Agregar objetos aleatorios de las listas creadas previamente
            for i = 1, weaponItemCount do
                local randomIndex = ZombRand(1, #weaponItems + 1)
                local item = InventoryItemFactory.CreateItem(weaponItems[randomIndex])
                local containerIndex = ZombRand(1, containerCount + 1)
                containers[containerIndex]:addItem(item)
            end

            for i = 1, ammoItemCount do
                local randomIndex = ZombRand(1, #ammoItems + 1)
                local item = InventoryItemFactory.CreateItem(ammoItems[randomIndex])
                local containerIndex = ZombRand(1, containerCount + 1)
                containers[containerIndex]:addItem(item)
            end

            for i = 1, gunMagItemCount do
                local randomIndex = ZombRand(1, #magItems + 1)
                local item = InventoryItemFactory.CreateItem(magItems[randomIndex])
                local containerIndex = ZombRand(1, containerCount + 1)
                containers[containerIndex]:addItem(item)
            end
            for i = 1, weaponsPartNumber do
                local randomIndex = ZombRand(1, #weaponsPartItems + 1)
                local item = InventoryItemFactory.CreateItem(weaponsPartItems[randomIndex])
                local containerIndex = ZombRand(1, containerCount + 1)
                containers[containerIndex]:addItem(item)
            end

            for partIndex = 1, currentVehicle:getPartCount() do
                local part = currentVehicle:getPartByIndex(partIndex - 1)

                if part:getCategory() == "door" then
                    local door = part:getDoor()
                    if door then
                        currentVehicle:toggleLockedDoor(part, playerInSquare, false)
                    end
                elseif part:getId() == "GasTank" then
                    local gasAmount = ZombRand(2, 6)
                    part:setContainerContentAmount(gasAmount)
                end
            end

            if ZombRand(0, 1) == 0 then
                currentVehicle:cheatHotwire(true, false)
            else
                local vehicleKey = currentVehicle:createVehicleKey()
                currentVehicle:putKeyInIgnition(vehicleKey)
            end
            print("vehiculo completado")
        end
    end
end





EventsMod_Core.SpawnHorde = function(player, amount, coordinates)
    local health = 100
    local radius = SandboxVars.EventsMod.ZombieRadius
    print(SandboxVars.EventsMod.ZombieRadius);
    local femaleChance = 50

    local isCrawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local isKnockedDown = false
    local outfit = nil
    if isServer() then
        spawnHorde(coordinates.x - 10, coordinates.y - 10, coordinates.x + 10, coordinates.y + 10, coordinates.z, amount)
    else
        for i = 1, amount do
            local x = ZombRand(coordinates.x - radius, coordinates.x + radius + 1)
            local y = ZombRand(coordinates.y - radius, coordinates.y + radius + 1)
            addZombiesInOutfit(x, y, coordinates.z, 1, outfit, femaleChance, isCrawler, isFallOnFront, isFakeDead,
                isKnockedDown, health)
        end
    end
end

---Check distance between two squares
---@param square1 any
---@param square2 any
---@return boolean
local CheckDistanceBetweenSquares = function(square1, square2)
    local plX = math.floor(square1:getX())
    local plY = math.floor(square1:getY())

    local sqX = math.floor(square2:getX())
    local sqY = math.floor(square2:getY())

    local diffX = math.abs(plX - sqX)
    local diffY = math.abs(plY - sqY)

    if diffX < 100 and diffY < 100 then
        return true
    else
        return false
    end
end

---Guarda eventos en un archivo
EventsMod_Core.SaveEvents = function(event)
    local eventTable = event:toTable()
    local file = getModFileWriter("EventsMod", EventsMod_Core.savedEventsFile, true, false)
    if file then
        file:write(serialize(eventTable))
        file:close()
    end
end

---Carga eventos desde un archivo
EventsMod_Core.LoadEvents = function()
    if not fileExists(EventsMod_Core.savedEventsFile) then
        print("No existe archivo")
        return nil
    end

    local file = getModFileReader("EventsMod", EventsMod_Core.savedEventsFile, true)
    if file then
        local content = file:readLine()
        file:close()
        if content then
            local eventTable = deserialize(content)
            if eventTable then
                print("cargando evento")
                print(eventTable)
                local event = EventsMod_Event:new(EventsMod_Core.jsonHandler)
                print(eventTable.zombieAmount)
                event.zombieAmount = eventTable.zombieAmount
                print(eventTable.eventTable)
                event.eventTable = eventTable.eventTable
                print(eventTable.vehiclesTable)
                event.vehiclesTable = eventTable.vehiclesTable
                print(eventTable.itemsInVehicleTable)
                event.itemsInVehicleTable = eventTable.itemsInVehicleTable
                print(eventTable.coordinates)
                event.coordinates = eventTable.coordinates
                print(event)
                return event
            end
        end
    end
    return nil
end

EventsMod_Core.removeSavedEvent = function()
    local file = getModFileWriter("EventsMod", EventsMod_Core.savedEventsFile, true, false)
    if file then
        file:write('')
        file:close()
    end
end


---Check if there's a player inside the event square. If there is, starts spawning zombies and cars. Returns the IsoPlayer in case he's found
---@param square IsoPlayer
---@return unknown
EventsMod_Core.CheckPlayerInSquare = function(square)
    if not isClient() and not isServer() then
        local player = getPlayer()
        local playerSquare = player:getSquare()

        if CheckDistanceBetweenSquares(playerSquare, square) then
            return player
        end
    else
        local players
        players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            local cPlayer = players:get(i)

            if CheckDistanceBetweenSquares(cPlayer:getSquare(), square) then
                return cPlayer
            end
        end
    end

    return nil
end
