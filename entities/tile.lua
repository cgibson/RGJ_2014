
--
-- TILES
--
-- Logic/Render code for every tile
--

Class = require "hump.class"
local c = require "constants"

--
-- TILE class
--
-- Will be inherited to different tile types (asteroids, voids, planets, etc)
--
Tile = Class{
    init = function( self )
        self.selected = false
		
		-- Black = Unexplored
		-- Grey = Explored
		-- Blue = Player-owned
		-- Yellow = Enemy player owned
		-- White = Impassable
        self.color = c.Colors.HEX_BLACK
		
		-- Space
		-- Planet
		-- Impassable
		self.type = c.Tiles.TYPE_SPACE
		
		-- Type of event on this tile
		self.event_type = c.Events.NONE
		
		-- Count of number of relays passing through this tile
		-- When a new relay is created, ++ to all tiles in range
		-- When a relay is destroyed, -- to all tiles in range
		-- If relayCount > 0, weight to travel through is 1
        --
        -- Indexed by player id
		self.relayCount = {0, 0, 0, 0}

		-- Has this tile been explored by the player?
		-- If yes, weight to travel through is 2
		-- If no, weight to travel through is 3
        --
        -- Indexed by player id
		self.explored = {false, false, false, false}
    end,
}

function Tile:draw(x, y)
    if self.type == c.Tiles.TYPE_PLANET then
        love.graphics.setColor(240, 240, 20)
        love.graphics.circle("fill", x, y, 32)
    end
end

function Tile:getWeight( playerId )
    if self.type == c.Tiles.TYPE_ASTEROID then
        return 9999
    elseif self.relayCount[playerId] > 0 then
        return 1
    elseif self.explored[playerId] == true then
        return 2
    else
        return 3
    end
end

return Tile