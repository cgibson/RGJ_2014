
--
-- TILES
--
-- Logic/Render code for every tile
--

Class = require "hump.class"

local TILE_CLEAR, TILE_BLOCKED


tile_size = 128

--
-- Finds out where the upper left point of the image will
-- be with respect to the tile position, camera position
-- and camera zoom
--
function tilePosToScreen( tile_pos, camera )

end


--
-- TILE class
--
-- Will be inherited to different tile types (asteroids, voids, planets, etc)
--
Tile = Class{
    init = function( self, pos, img )
        self.pos = pos
        self.img = img
    end
}

function Tile:draw()
    love.graphics.setColor( 255, 0, 0, 255 )
    love.graphics.rectangle( "fill", 100, 100, 200, 200 )
end


return Tile