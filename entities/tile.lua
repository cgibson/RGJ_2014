
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
        self.type = c.Tiles.TYPE_SPACE
    end
}

function Tile:draw(x, y)
    if self.type == c.Tiles.TYPE_PLANET then
        love.graphics.setColor(240, 240, 20)
        love.graphics.circle("fill", x, y, 32)
    end
end


return Tile