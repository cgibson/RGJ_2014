
local Gamestate = require "hump.gamestate"
local World = require "world"
require "constants"

-- Game gamestate object
local Game = {}


function Game:enter()
    self.world = World(10, 10)
end


--
-- DRAW function
--
function Game:draw()
    self.world:draw()

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
    if mouse == MOUSE_BUTTON_LEFT then

    elseif mouse == MOUSE_BUTTON_RIGHT then

    end
    print("Mouse ", mouse, " pressed at location (", x, ", ", y, ")")
end

function Game:mousereleased( x, y, mouse )
    if mouse == MOUSE_BUTTON_LEFT then
        self.world:selectTile(x, y)
    elseif mouse == MOUSE_BUTTON_RIGHT then

    end
end

return Game