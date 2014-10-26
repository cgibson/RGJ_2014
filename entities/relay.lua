
local c = require "constants"
local Class = require "hump.class"
local HXM = require "HexaMoon.HexaMoon"

local STATE_IDLE, STATE_SHOOTING = 1, 2

Relay = Class {
    init = function( self, world, pos, direction )
        self.id =                       c.getNewId()
        self.world =                    world       -- Copy of the world (for movement/placement)
        self.position =                 pos
        self.direction =                direction
        self.hp =                       c.Entities.RELAY_HP_MAX
        self.state =                    STATE_IDLE
    end,


    update = function( dt )

        -- Identify closest object along the line that can accept sheep
        local closest = self:findClosestSheepReceiver()
        -- Check to ensure the object can continue to accept sheep

        -- Turn off if sheep cannot be accepted
    end,


    findClosestSheepReceiver = function( self )

        local coord = self.position
        local tile, obj
        for dist = 1, c.Entities.RELAY_DISTANCE_MAX do
            coord = hxm.getHexCoordinate(self.direction, coord.x, coord.y)
            tile = world.getTile(coord.x, coord.y)

            -- Escape if we hit an obstacle
            --
            obj = tile.getObstacle()
            if obj ~= nil then
                return nil
            end

            -- Grab a relay (we'll decide whether or not they're friendly later
            obj = tile.getRelay()
            if obj ~= nil then
            end

            -- Find out if we have any shepherds on the tile, ally or otherwise
            obj = tile.getShepherds()
            if #obj > 0 then
            end

            obj = tile.getPlanet()
            if obj ~= nil then
            end


        end
    end

}

return Relay