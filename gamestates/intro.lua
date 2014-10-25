
--
-- We need to show off our mascot
-- WE NEED TO OKAY?
--
Gamestate = require "hump.gamestate"
local Menu = require "gamestates.menu"

local Intro = {}


function Intro:init()
    self.wait_time = 5   -- show screen for 5 seconds
end

function Intro:enter( previous )
    self.init_time = love.timer.getTime()
end


function Intro:draw()
    love.graphics.print("This is the intro sequence!", 400, 300)
end


function Intro:update(dt)
    if love.timer.getTime() - self.init_time > self.wait_time
    then
        Gamestate.switch(Menu)
    end
end

return Intro