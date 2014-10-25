
Gamestate = require "hump.gamestate"

-- Menu gamestate object
local Menu = {}


--
-- DRAW function
--
-- Draw the menu in all its glory
--
function Menu:draw()
    love.graphics.print("This is the menu!", 400, 300)
end


--
-- PRESSED functions
--
-- Change menu selection based on the key we've presed
--
function Menu:keypressed( key, isrepeat )
end

function Menu:keyreleased( key, isrepeat )
end


--
-- MOUSE functions
--
-- Will also change the menu selection
--
function Menu:mousepressed( x, y, mouse )
end

function Menu:mousereleased( x, y, mouse )
end

return Menu