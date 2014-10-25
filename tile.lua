
--
-- TILES
--
-- Logic/Render code for every tile
--

Class = require "hump.class"
local c = require "constants"


--
-- TILE class
--
-- Will be inherited to different tile types (asteroids, voids, planets, etc)
--
Tile = Class{
    init = function( self )
        self.selected = false
        self.color = c.Colors.HEX_BLACK
    end
}

function Tile:draw()
    love.graphics.setColor( 255, 0, 0, 255 )
    love.graphics.rectangle( "fill", 100, 100, 200, 200 )
end


return Tile