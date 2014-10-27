
local c = require "constants"
local Class = require "hump.class"


Planet = Class {
    init = function( self, world, pos, player )
        self.id =                       c.getNewId()
        self.world = world
        self.position = pos
        self.owner = player
        self.sheep = 0

    end,


    update = function( self, dt )
        if self.owner ~= nil then
            self.sheep = self.sheep + c.SHEEP_GEN_RATE
        end
        
        local tiles = self.world:getNeighboringTiles(self.position)
        for idx, tile_inner in pairs(tiles) do
            if tile_inner:getRelay() ~= nil and tile_inner:getRelay():canReceiveSheep() then
                tile_inner:getRelay():receiveSheep(1, self.owner)
                self.sheep = self.sheep - 1
            end
            print(tile_inner)
            print(tile_inner:getShepherds())
            if tile_inner:getShepherds() ~= nil and tile_inner:getShepherds()[1]:canReceiveSheep() then
                tile_inner:getShepherds()[1]:receiveSheep(1, self.owner)
                self.sheep = self.sheep - 1
            end
        end

    end,


    canReceiveSheep = function( self )
        return true
    end,


    receiveSheep = function( self, count, owner)
        -- TODO: handle teams
        print("Planet receiving", count, "from", owner)
        if self.owner ~= owner then
            if self.sheep - count < 0 then self.owner = owner end
        else
            self.sheep = self.sheep + count
        end
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