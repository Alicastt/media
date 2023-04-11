DMM_Core = DMM_Core or {}

DMM_Core.square = nil
DMM_Core.event = nil







DMM_Core.SpawnVehicles = function(playerInSquare, vehiclesTable, itemsTable, coordinates)

    -- TODO add random vehicles turned on

    for _, v in pairs(vehiclesTable) do
        --print("DMM: spawning " .. v.carName)

        local currentVehicle = addVehicleDebug(v.carName, IsoDirections.E, -1, getSquare(coordinates.x, coordinates.y, coordinates.z))
        currentVehicle:setGeneralPartCondition(0.5, 40)

        for partIndex=1,currentVehicle:getPartCount() do
            local part = currentVehicle:getPartByIndex(partIndex - 1)
            local partCategory = part:getCategory()
            
            print(partCategory)


            if part:getCategory() == "door" then
                local door = part:getDoor()
                -- Force unlock everything
                if door then
                    print("DMM: found door")
                    currentVehicle:toggleLockedDoor(part, playerInSquare, false)
                end
                --door:setLocked(false)
            elseif part:getId() == "GasTank" then
                local gasAmount = ZombRand(2,6)       -- TODO Make it customizable
                part:setContainerContentAmount(gasAmount)
                
            end
            
            local itemContainer = part:getItemContainer()

            if itemContainer then
                local item = InventoryItemFactory.CreateItem(itemsTable[ZombRand(1, #itemsTable)])
                itemContainer:addItem(item)
            end


        
        end
        if ZombRand(0,1) == 0 then
            currentVehicle:cheatHotwire(true, false)
        else
            local vehicleKey = currentVehicle:createVehicleKey()
            currentVehicle:putKeyInIgnition(vehicleKey)
        end





    end



end


DMM_Core.SpawnHorde = function(player, amount, coordinates)

    local health = 100
    local radius = SandboxVars.DMM.ZombieRadius

    local femaleChance = 50

    local isCrawler = false
    local isFallOnFront = false
    local isFakeDead = false
    local isKnockedDown = false
    local outfit = nil
    if isServer() then

        sendServerCommand(player, "DMM", "SpawnZombies", {coordinates = coordinates, amount = amount, radius = radius})
	
	else
        for i=1, amount do
            local x = ZombRand(coordinates.x -radius, coordinates.x + radius + 1)
            local y = ZombRand(coordinates.y - radius, coordinates.y + radius + 1)
            addZombiesInOutfit(x, y, coordinates.z, 1, outfit, femaleChance, isCrawler, isFallOnFront, isFakeDead, isKnockedDown, health)
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

---Check if there's a player inside the event square. If there is, starts spawning zombies and cars. Returns the IsoPlayer in case he's found
---@param square IsoPlayer
---@return unknown
DMM_Core.CheckPlayerInSquare = function(square)
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
