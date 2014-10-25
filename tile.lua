
--
-- TILES
--
-- Logic/Render code for every tile
--

Class = require "hump.class"


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