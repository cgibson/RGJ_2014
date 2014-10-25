--
-- Mostly just a bootstrap to send the user to the 'menu' gamestate
--

Gamestate = require "hump.gamestate"
local Intro = require "gamestates.intro"

function love.load()
    -- Override normal love'ly behavior (render, keys, etc)
    Gamestate.registerEvents()
    -- Change to menu gamestate
    Gamestate.switch(Intro)
end