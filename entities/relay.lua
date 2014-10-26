
local c = require "constants"
local Class = require "hump.class"
local HXM = require "HexaMoon.HexaMoon"

local STATE_IDLE, STATE_SHOOTING = 1, 2

Relay = Class {
    init = function( self, world, owner, pos, direction )
        self.type =                     c.Entities.TYPE_RELAY
        self.id =                       c.getNewId()
        self.world =                    world       -- Copy of the world (for movement/placement)
        self.position =                 pos
        self.direction =                direction
        self.hp =                       c.Entities.RELAY_HP_MAX
        self.state =                    STATE_IDLE
        self.owner =                    owner
        self.enabled =                  true

        -- Auto-add this relay to the right tile
        tile = self.world:getTile( pos )
        if tile == nil then
            error("Tile at (" .. self.position.x .. ", " .. self.position.y .. ") is not instantiated")
        end

        tile:addEntity(self)

        -- Cached data to help speed up the sheeping routes
        self.memoization = {can_send = nil, receiver = nil}
        -- TODO: implement "reserve sheep"
    end,


    update = function( dt )

        -- Identify closest object along the line that can accept sheep
        local closest = self:findClosestSheepReceiver()
        -- Check to ensure the object can continue to accept sheep

        -- Turn off if sheep cannot be accepted
    end,


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
        love.graphics.setColor(255,0,255)
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


return Relay