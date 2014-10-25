
Gamestate = require "hump.gamestate"
Tile = require "tile"

-- Game gamestate object
local Game = {}


function Game:enter()
    tile = Tile()
end


--
-- DRAW function
--
function Game:draw()
    tile.draw( {0, 0}, "assets/images/test.png" )

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Drawing tiles!", 400, 300)
end


--
-- PRESSED functions
--
function Game:keypressed( key, isrepeat )
end

function Game:keyreleased( key, isrepeat )
end


--
-- MOUSE functions
--
function Game:mousepressed( x, y, mouse )
end

function Game:mousereleased( x, y, mouse )
end

return Game