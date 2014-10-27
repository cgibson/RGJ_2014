
local c = require "constants"
local Class = require "hump.class"
local HXM = require "HexaMoon.HexaMoon"

local STATE_IDLE, STATE_BUILDING, STATE_SHOOTING, STATE_PLACING = 1, 2, 3, 4

local PI = 3.14159
local TPI = PI / 3
local dir_angle = {
    NE = 5 * TPI,
    E  = 0 * TPI,
    SE = 1 * TPI,
    SW = 2 * TPI,
    W  = 3 * TPI,
    NW = 4 * TPI,
}

Relay = Class {
    init = function( self, world, owner, pos, direction )
        self.type =                     c.Entities.TYPE_RELAY
        self.id =                       c.getNewId()
        self.world =                    world       -- Copy of the world (for movement/placement)
        self.position =                 pos
        self.direction =                direction
        self.hp =                       c.Entities.RELAY_HP_MAX
        self.buffer =                   0           -- The amount of sheep the relay needs to expel
        self.out_buffer =                0           -- Sheeping and sending
        self.state =                    STATE_IDLE
        self.owner =                    owner
        self.enabled =                  true
        self.target =                   nil

        -- Cached data to help speed up the sheeping routes
        -- self.memoization = {can_send = nil, receiver = nil}
        -- TODO: implement "reserve sheep"
    end,


    update = function( self, dt )

        -- Remove the relay from the world if its HP is below 1
        if self.hp < 1 then
            world.player_data[owner].relays[self.id] = nil
            return
        end

        -- Only enable once the buffer holds enough sheep. Deduct the cost
        if self.state == STATE_BUILDING then
            if self.buffer >= c.Entities.RELAY_COST then
                self:changeState(STATE_IDLE)
                self.buffer = self.buffer - c.Entities.RELAY_COST
            end
            return
        end

        self:sendSheep()


        -- Reset buffer
        -- Move your sheeping receiving into the main buffer
        self.out_buffer = self.out_buffer + self.buffer
        self.buffer = 0
    end,


    sendSheep = function( self )

        print("Relay " .. self.id .. " attempting to send sheep")
        -- Skip the rest if the relay is not enabled
        if enabled == false then
            print(" disabled... ")
            return
        end

        -- Bail out if you have no target
        if self.target == nil then
            print(" No target... ")
            return
        end

        -- If we don't have anything in our buffer
        if self.out_buffer < 1 then
            print("Nothing in our buffer")
            return
        end


        if self.target:canReceiveSheep() == false then
            print("target " .. self.target.id .. " can't receive sheep")
            return
        end

        -- Scoop an amount of sheep off the planet you're next to (if such exists)
        -- TODO: this

        -- Send your buffer to your target
        self.target:receiveSheep(self.out_buffer)
        self.out_buffer = 0
    end,


    canReceiveSheep = function( self, prev )
        if prev == nil then
            prev = {}
        end

        if self.state == STATE_BUILDING then
            return true
        end

        -- Check to ensure we aren't in an infinite loop.
        -- If CRAZY CHAN is enabled, then... meh... let's do it
        for relayId, relay in pairs(prev) do
            if relayId == self.id then
                return c.CRAZY_CHAN_MODE
            end
        end
        -- Add ourselves to the list
        prev[self.id] = self

        if self.target == nil then
            return false
        end

        if self.target.type == c.Entities.TYPE_RELAY then

            if self.target.state == STATE_BUILDING then
                return true
            end

            return self.target:canReceiveSheep(prev)
        end

        return true

    end,


    receiveSheep = function( self, count, owner)
        -- TODO: handle teams
        self.buffer = self.buffer + count
    end,


    updateDirectionAngle = function( self, angle )
        angle = angle + PI

        if angle < (1 * TPI) then     dir = "SW"
        elseif angle < (2 * TPI) then dir = "W"
        elseif angle < (3 * TPI) then dir = "NW"
        elseif angle < (4 * TPI) then dir = "NE"
        elseif angle < (5 * TPI) then dir = "E"
        else                          dir = "SE"
        end

        self.direction = dir

    end,


    changeState = function( self, state)
        local state_str = "UNKNOWN"

        if state == STATE_BUILDING then state_str = "BUILDING"
        elseif state == STATE_IDLE then state_str = "IDLE"
        elseif state == STATE_PLACING then state_str = "PLACING"
        elseif state == STATE_SHOOTING then state_str = "SHOOTING"
        end

        print("Relay (" .. self.id .. ") changed state to " .. state_str)

        self.state = state
    end,


    updateTarget = function( self )
        print("UPDATING TARGET for relay " .. self.id)
        local coord = self.position
        local tile, obj
        for dist = 1, c.Entities.RELAY_DISTANCE_MAX do

            -- Move the coordinate one tile in the direction the relay is facing
            x, y = HXM.getHexCoordinate(self.direction, coord.x, coord.y)
            tile = self.world:getTile(Vector(x, y))
            coord = Vector(x, y)

            if tile ~= nil then
                -- We don't even care who's relay this is. If it exists, we point and shoot
                obj = tile:getRelay()
                if obj ~= nil then
                    print("Relay " .. self.id .. " targeting other relay " .. obj.id .. " on " .. coord.x .. "," .. coord.y)
                    self.target = obj
                    return
                end

                -- If it's a planet, then duh we send stuff there
                obj = tile:getPlanet()
                if obj ~= nil then
                    print("Relay " .. self.id .. " targeting planet on " .. coord.x .. "," .. coord.y)
                    self.target = obj
                    return
                end
            end
        end

        print("Relay " .. self.id .. " has no current target.")
    end,


    -- For each player, search through their receivers. If the receiver is WITHIN
    -- RELAY_DISTANCE_MAX, then it's worth updating its target
    notifyNearbyRelays = function( self )
        for playerId, data in pairs(self.world.player_data) do
            for relayId, relay in pairs(data.relays) do
                local dist = hexamath.VectorDistance( self.position, relay.position )
                if dist <= c.Entities.RELAY_DISTANCE_MAX then
                    relay:updateTarget()
                end
            end
        end
    end,


    draw = function( self )

        -- NOTE: must move from 1-indexed to 0-indexed because HexaMoon is stupid
        local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.position.x-1, self.position.y-1, 0, 0)

        if self.state == STATE_PLACING then
            love.graphics.setColor(255,255,255)
        elseif self.state == STATE_BUILDING then
            love.graphics.setColor(100,100,100)
        elseif self.target ~= nil then
            love.graphics.setColor(150,0,150)
        else
            love.graphics.setColor(100,40,100)
        end
        local vertexes = self:getDirectionVertexes(self.direction)
        love.graphics.polygon("fill", coord.x + vertexes[1].x, coord.y + vertexes[1].y,
                                      coord.x + vertexes[2].x, coord.y + vertexes[2].y,
                                      coord.x + vertexes[3].x, coord.y + vertexes[3].y)
        --love.graphics.rectangle("fill",
        --                        coord.x - 16,
        --                        coord.y - 16,
        --                        32,
        --                        32)


        love.graphics.setColor(255,255,255)
        love.graphics.print("B: " .. self.buffer, coord.x-8, coord.y+16)
        love.graphics.print("BO: " .. self.out_buffer, coord.x-8, coord.y+24)
    end,
    
    getDirectionVertexes = function(self, vertex)
        --[[
        if vertex == "NE" then return {-18,0 , 15,15 , 15,-15}
        elseif vertex == "E" then return {18,0 , -15,-15 , 15,15}
        elseif vertex == "SE" then return {-18,0 , 15,15 , 15,-15}
        elseif vertex == "SW" then return {18,0 , -15,-15 , 15,15}
        elseif vertex == "W" then return {-18,0 , 15,15 , 15,-15}
        elseif vertex == "NW" then return {18,0 , -15,-15 , 15,15}
        end
        ]]--


        local angle = dir_angle[self.direction]
        return {Vector(18,0):rotated(angle) , Vector(-15,15):rotated(angle) , Vector(-15,-15):rotated(angle) }

    end
    
    


}


function Relay.startPlacingRelay(world, playerId, pos, direction)

    -- Ensure the tile exists
    local tile = world:getTile( pos )
    if tile == nil then
        return {error="Cannot build there!"}
    end

    -- Make sure no other relay exists on that tile
    if tile:getRelay() ~= nil then
        return {error="Relay already on the tile"}
    end

    -- Cannot place on obstacles
    if tile:getObstacle() ~= nil then
        return {error="Tile is obstructed"}
    end

    -- Cannot place on planets
    if tile:getPlanet() ~= nil then
        return {error="Cannot place a rely on a planet"}
    end

    -- Must place on a tile that can receive sheep
    -- TODO: this.

    -- First, place the tile in the world
    local relay = Relay(world, playerId, pos, direction)

    -- Set its state to BUILDING. It hasn't been built yet
    relay:changeState(STATE_PLACING)

    -- Tell the world the player is trying to place this relay
    world.player_data[playerId].is_placing = true
    world.player_data[playerId].relay_to_build = relay

    -- We DON'T add it to the actual grid yet. We don't want it
    -- to screw up anyone's calculations

    -- Add to player data to receive updates and draws
    world.player_data[playerId].relays[#world.player_data[playerId].relays+1] = relay

    return {error=nil, obj=relay}
end


function Relay.buildPendingRelay( world, playerId, freeSheep )
    print("Building relay for player " .. playerId)

    -- Grab the relay from player data
    local relay = world.player_data[playerId].relay_to_build

    -- Give them free sheep. SPACE SHEEP LIVES
    if freeSheep ~= nil then
        relay.buffer = freeSheep
    end

    -- Insert the relay into the tile
    local tile = world:getTile( relay.position )
    tile:addEntity(relay)

    -- STEP 1: Check to see who is the 'target' for this relay
    --         This can be a relay or a planet.
    relay:updateTarget()

    -- STEP 2: Update any relays within distance to ensure their
    --         Receiver is up-to-date as well
    relay:notifyNearbyRelays()

    -- Set relay's state to STATE_BUILDING. It still needs to be
    -- built before it can be operational. Once its sheep reserve
    -- is full, it will be set into an operational state
    relay:changeState(STATE_BUILDING)

    -- Let the game know we are no longer placing the relay
    world.player_data[playerId].is_placing = false

    return {error=nil, obj=relay}
end

--[[
    updateSheepingCapability = function( self, prev )

        -- print("CHECKING (",self.id,") for sheeping capability")
        -- instantiate if not given
        if prev == nil then
            prev = {self}
        end

        -- Memoization!
        if self.memoization.can_send ~= nil then
            -- print(self.id, "    memoized (", self.memoization.can_send, ")")
            return self.memoization.can_send
        end

        -- First, just ignore disabled relays
        if self.enabled == false then
            -- print(self.id, "   disabled! (false)")
            self.memoization.can_send = false
            return false
        end

        -- Next, find out if there's something that this relay can send the sheep to
        local closest, isRelay = self:findClosestSheepReceiver(prev)

        -- Ensure that (if this is a relay) this relay isn't already on a list of previous relays.
        -- If it is,we are likely in an infinite loop. This could be either good or bad. Let's call
        -- this the CRAZY_CHAN_MODE option.
        if isRelay then
            for i = 1, #prev do
                if prev[i].id == closest.id then
                    if c.CRAZY_CHAN_MODE == false then
                        print(self.id, "   scary infinite loop... (false)")
                        self.memoization.can_send = false
                        return false
                    end
                end
            end
        end

        -- If we found something
        if closest ~= nil then
            -- Add closest to the list, and then check to see if it can actually ship sheep
            prev[#prev+1] = closest
            if isRelay then
                if closest:updateSheepingCapability(prev) then
                    -- print(self.id, "   touches a sheepable relay! (true)")
                    -- If so (or memoization tells us so) then here you go!
                    self.memoization.can_send = true
                    self.memoization.receiver = closest
                    return true
                end
            else
                -- print(self.id, "   touches a destination! (true)")
                self.memoization.can_send = true
                self.memoization.receiver = closest
                return true
            end
        end

        -- Otherwise, handle reserve sheep
        -- TODO: Handle reserve sheep

        -- print(self.id, "   no destination (false)")
        self.memoization.can_send = false
        return false

    end,


    findClosestSheepReceiver = function( self, prev )

        local coord = self.position
        local tile, obj
        for dist = 1, c.Entities.RELAY_DISTANCE_MAX do

            -- Move the coordinate one tile in the direction the relay is facing
            x, y = HXM.getHexCoordinate(self.direction, coord.x, coord.y)
            tile = self.world:getTile(Vector(x, y))
            coord = Vector(x, y)

            -- print("Anything in tile (" .. x .. "," .. y .. ")?")
            if tile == nil then
                return nil, false
            end
            -- Escape if we hit an obstacle
            --
            obj = tile:getObstacle()
            if obj ~= nil then
                -- print("  There is an obstacle!")
                return nil, false
            end

            -- print("  No obstacles")

            -- Grab a relay (we'll decide whether or not they're friendly later
            obj = tile:getRelay()
            if obj ~= nil then
                -- Ignore disabled relays. This allows for pass-through. SCIENCE.
                if obj.enabled then
                    if obj.owner ~= self.owner then
                        -- We can fight it! No need to see whether or not we can receive sheep.
                        -- By virtue of its very existence we can throw sheep at it to destroy it
                        -- print("  There is a relay!")
                        return obj, true
                    else
                        if obj.enabled then
                            -- Our receiver can take our sheeps

                            -- print("  There is a relay!")
                            return obj, true
                        else
                            -- Stop right there

                            -- print("  There is a relay, but it's enabled!")
                            return nil, false
                        end
                    end
                end
            end

            -- print("  No relays")

            -- Find out if we have any shepherds on the tile, ally or otherwise
            --
            -- This handles multiple situations. If there is at least one shepherd,
            -- we know we are returning one. If there are multiple, check to see if
            -- one belongs to the player. If not, return the first shepherd in the list
            obj = tile:getShepherds()
            if (obj ~= nil) and (#obj > 0) then
                -- Find our shepherd. If it isn't there, return the first shepherd
                for i = 1, #obj do
                    -- Only look at ships that can receive sheep
                    if obj[i]:canReceiveSheep(prev) then
                        if obj[i].owner == self.owner then

                            -- print("  There is a shepherd!")
                            return obj[i], false
                        end
                    end
                end
                -- print("  There is a shepherd!")
                return obj[1], false
            end

            -- print("  No shepherds")

            -- Find out if we're hitting a planet. It's like getting a healthy serving of freedom... except
            -- freedom in the form of fluffy white sheep
            obj = tile:getPlanet()
            if obj ~= nil then
                if obj:canReceiveSheep(prev) then
                    -- print("  There is a planet!")
                    -- TODO: Eventually, we want to be able to indicate whether or not to attack. For now it's automatic
                    return obj, false
                end
            end

            -- print("  No planets")

            --
            -- Otherwise, keep going...
        end
    end,


    clearMemoization = function( self )
        self.memoization = {can_send = nil, receiver = nil}
    end,


    draw = function( self )

        -- NOTE: must move from 1-indexed to 0-indexed because HexaMoon is stupid
        local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.position.x-1, self.position.y-1, 0, 0)

        if self.memoization.can_send then
            love.graphics.setColor(150,0,150)
        else
            love.graphics.setColor(150,0,150)
        end
        love.graphics.rectangle("fill",
                                coord.x - 16,
                                coord.y - 16,
                                32,
                                32)
    end

}


-- Static function to run across all relays
function Relay.updateSheepingRoutes(relays)

    -- print("------------------------- UPDATING SHEEPING ROUTES !")
    -- First, clean all memoization across all relays
    for i = 1, #relays do
        relays[i]:clearMemoization()
    end

    -- Next, check to see if each relay can receive sheep
    for i = 1, #relays do
        relays[i]:updateSheepingCapability()
    end

    -- Finally, send the sheep along, attacking/defending/repairing entities
    for i = 1, #relays do
        if relays[i].memoization.can_Send then
           -- print("CAN SEND FROM ", relays[i].id)
        end
    end

end
]]--

return Relay