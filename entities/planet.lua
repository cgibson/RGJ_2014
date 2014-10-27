
local c = require "constants"
local Class = require "hump.class"


Planet = Class {
    init = function( self, world, pos )
        self.id =                       c.getNewId()
        self.world = world
        self.position = pos
        self.owner = nil
        self.sheep = 0

    end,


    update = function( self, dt )
        if self.owner ~= nil then
            self.sheep = self.sheep + c.SHEEP_GEN_RATE
        end

    end,


    receiveSheep = function( self, count, owner)
        -- TODO: handle teams
        self.sheep = self.sheep + count
    end,


    draw = function( self )

        -- NOTE: must move from 1-indexed to 0-indexed because HexaMoon is stupid
        local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.position.x-1, self.position.y-1, 0, 0)

        love.graphics.setColor(240, 240, 20)
        love.graphics.circle("fill", coord.x, coord.y, 72)
        love.graphics.setColor(0,255,0)
        love.graphics.print("Sheep: " .. self.sheep, coord.x, coord.y)
    end


}

return Planet