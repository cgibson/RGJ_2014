
local Gamestate = require "hump.gamestate"
local Camera = require "hump.camera"
local Vector = require "hump.vector"
local Button = require "gui.button"
local Relay = require "entities.relay"

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
    self.relay_placing = false
    self.relay_placing_obj = nil
    self.relay_placing_pos = nil

    -- GUI
    self.gui = {}
    self.gui[c.Gui.BUTTON_BUILD_RELAY] = Button( Vector(love.window.getWidth() / 2,30), Vector(100,30), "Build Relay" )
end


--
-- DRAW function
--
function Game:draw()
    self.camera:attach()
    self.world:draw()
    self.camera:detach()
    love.graphics.setColor(255, 255, 255, 255)

    -- Draw GUI
    for k,v in pairs(self.gui) do
        v:draw()
    end
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

    if self.relay_placing then
        -- Handle placement of
        wx, wy = self.camera:worldCoords(x, y)

        -- From world coordinates to hex coordinates
        cx, cy = HXM.getHexFromPixel(wx, wy, c.Tiles.TILE_RADIUS, 0, 0)

        -- one indexed. ONE INDEXED
        cx = cx+1
        cy = cy+1

        pos = Vector(cx, cy)

        local ret = Relay.startPlacingRelay( self.world, c.PLAYER_1, pos, "SE")
        if ret.error ~= nil then
            print("ERROR: ", ret.error)
        end
        self.relay_placing_obj = ret.obj
        self.relay_placing_pos = Vector(x,y)

        return
    end

    -- Then normal hex interactions
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

            -- GUI first
            if self.gui[c.Gui.BUTTON_BUILD_RELAY]:isClicked( Vector(x,y) ) then
                self.relay_placing = true
                return
            end


            -- If the mouse was guaranteed to have moved AND we are placing a relay,
            -- then place the darn relay
            if self.relay_placing then
                -- TODO: Add direction information during the mouse drag

                ret = Relay.buildPendingRelay( self.world, c.PLAYER_1 )
                if ret.error ~= nil then
                    print("WARNING: " .. ret.error)
                end

                self.relay_placing = false
                self.relay_placing_obj = nil
                self.relay_placing_pos = nil

                return
            end


            -- Convert screen coordinates to world coordinates
            wx, wy = self.camera:worldCoords(x, y)
            self.world:selectTile(wx, wy)
        end

    elseif mouse == c.MOUSE_BUTTON_RIGHT then
        wx, wy = self.camera:worldCoords(x, y)
        self.world:rightSelectTile(wx, wy)
    end
end


function Game:update(dt)
    self.world:update(dt)

    local mx, my = love.mouse.getPosition()

    -- If we have already set the relay down, but are still holding down the button, this is to be expected
    if self.relay_placing and self.relay_placing_obj then
        --TODO: update direction of relay
        placing_delta = Vector(mx - self.relay_placing_pos.x, my - self.relay_placing_pos.y)

        self.relay_placing_obj:updateDirectionAngle(math.atan2(placing_delta.x, -placing_delta.y))

    -- Otherwise, move the camera
    elseif self.camera_moving then

        local dx = self.mouse_last_pos[1] - mx
        local dy = self.mouse_last_pos[2] - my

        -- Check to see if the mouse has moved
        if math.abs(dx) + math.abs(dy) > 0 then
            self.camera_moved = true
        end
        
        self.mouse_last_pos = {mx, my}
        self.camera:move(dx,dy)
    end
end

return Game