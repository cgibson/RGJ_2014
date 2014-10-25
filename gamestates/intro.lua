
--
-- We need to show off our mascot
-- WE NEED TO OKAY?
--
Gamestate = require "hump.gamestate"
local Menu = require "gamestates.menu"
local Game = require "gamestates.game"

-- Gamestate object
local Intro = {}


--
-- INIT function
--
-- This runs at the beginning of the game (or whenever this module is required)
-- but is guaranteed to run before we enter the gamestate
--
function Intro:init()
    self.wait_time = 1      -- show screen for 5 seconds
    self.do_intro = false   -- whether or not to skip the intro
end


--
-- ENTER function
--
-- Guaranteed to run as soon as we enter the state
-- This is why we grab the initial time now
--
function Intro:enter( previous )
    self.init_time = love.timer.getTime()
end


--
-- DRAW function
--
-- Draw the awesomeness that is the space sheep
--
function Intro:draw()
    love.graphics.print("This is the intro sequence!", 400, 300)
end


--
-- UPDATE function
--
-- Check to see if we need to leave the intro screen yet
--
function Intro:update(dt)
    if love.timer.getTime() - self.init_time > self.wait_time
    then
        if do_intro then
            Gamestate.switch(Intro)
        else
            Gamestate.switch(Game)
        end
    end
end

return Intro