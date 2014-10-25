
local Gamestate = require "hump.gamestate"
local Camera = require "hump.camera"

local World = require "world"
require "constants"

-- Game gamestate object
local Game = {}


function Game:enter()
    self.world = World(50, 50)
    self.camera = Camera(0, 0)

    -- Mouse variables
    self.mouse_drag = false
    self.mouse_last_pos = nil

    self.camera_moving = false
end


--
-- DRAW function
--
function Game:draw()
    self.camera:attach()
    self.world:draw()
    self.camera:detach()
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
    self.mouse_drag = true

    if mouse == MOUSE_BUTTON_LEFT then

    elseif mouse == MOUSE_BUTTON_RIGHT then
        self.camera_moving = true
        self.mouse_last_pos = {x, y}
    end
    print("Mouse ", mouse, " pressed at location (", x, ", ", y, ")")
end

function Game:mousereleased( x, y, mouse )
    self.mouse_drag = false

    if mouse == MOUSE_BUTTON_LEFT then
        self.world:selectTile(x, y)
    elseif mouse == MOUSE_BUTTON_RIGHT then
        self.camera_moving = false
    end
end


function Game:update(dt)

    -- view moving code
    if self.camera_moving then
        local mx, my = love.mouse.getPosition()

        local dx = self.mouse_last_pos[1] - mx
        local dy = self.mouse_last_pos[2] - my

        self.mouse_last_pos = {mx, my}
        self.camera:move(dx,dy)
    end
end

return Game