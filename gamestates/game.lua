
local Gamestate = require "hump.gamestate"
local Camera = require "hump.camera"

local World = require "world"
local c = require "constants"

-- Game gamestate object
local Game = {}


function Game:enter()
    self.world = World(10, 10)
    self.camera = Camera(0, 0)

    -- Mouse variables
    self.mouse_drag = false
    self.mouse_last_pos = nil

    -- Action/meta variables
    self.meta_key = false

    -- Action status
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
    if key == "lgui" then
        print("enabling meta key")
        self.meta_key = true
    end
end

function Game:keyreleased( key, isrepeat )
    if key == "lgui" then
        self.meta_key = false
    end
end


--
-- MOUSE functions
--
function Game:mousepressed( x, y, mouse )
    self.mouse_drag = true

    if mouse == c.MOUSE_BUTTON_LEFT then
        self.camera_moving = true
        self.mouse_last_pos = {x, y}
        self.camera_moved = false;
    elseif mouse == c.MOUSE_BUTTON_RIGHT then
    end
end

function Game:mousereleased( x, y, mouse )
    self.mouse_drag = false

    if mouse == c.MOUSE_BUTTON_LEFT then
        self.camera_moving = false

        if self.camera_moved == false then
            -- Convert screen coordinates to world coordinates
            wx, wy = self.camera:worldCoords(x, y)
            self.world:selectTile(wx, wy)
        end
    elseif mouse == c.MOUSE_BUTTON_RIGHT then
    end
end


function Game:update(dt)
    self.world:update(dt)

    -- view moving code
    if self.camera_moving then
        local mx, my = love.mouse.getPosition()

        local dx = self.mouse_last_pos[1] - mx
        local dy = self.mouse_last_pos[2] - my

        if math.abs(dx) + math.abs(dy) > 0 then
            self.camera_moved = true
        end
        
        self.mouse_last_pos = {mx, my}
        self.camera:move(dx,dy)
    end
end

return Game