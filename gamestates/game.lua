
Gamestate = require "hump.gamestate"
World = require "world"

-- Game gamestate object
local Game = {}


function Game:enter()
    world = World(10, 10)
end


--
-- DRAW function
--
function Game:draw()
    world:draw()

    love.graphics.setColor(255, 255, 255, 255)
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
    print("Mouse ", mouse, " pressed at location (", x, ", ", y, ")")
end

function Game:mousereleased( x, y, mouse )
end

return Game