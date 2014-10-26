
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
		self.explored = {false, false, false, false }

        self.entities = {}
    end,


    getRelay = function( self )
        for i = 1, #self.entities do
            -- There should only ever be one rely on a space
            if self.entities[i].type == c.Entities.TYPE_RELAY then
                return self.entities[i]
            end
        end
    end,


    getShepherds = function( self )
        local shepherds = {}
        for i = 1, #self.entities do
            if self.entities[i].type == c.Entities.TYPE_SHEPHERD then
                shepherds[#sheperds+1] = self.entities[i]
            end
        end

        if #shepherds > 0 then
            return shepherds
        else
            return nil
        end
    end,


    getPlanet = function ( self )
        if self.type == c.Tiles.TYPE_PLANET then
            return self
        end
        return nil
    end,


    getObstacle = function (self)
        if self.type == c.Tiles.TYPE_OBSTACLE then
            return self
        end
        return nil
    end,


    getBackground = function( self )
        if #self.entities > 0 then
            return {80, 150, 80 }
        else
            return self.color
        end

    end,


    canReceiveSheep = function( self )

        if self.type == c.Tiles.TYPE_PLANET then
            return true
        elseif self.type == c.Tiles.TYPE_OBSTACLE then
            return false
        end
    end,


    addEntity = function( self, obj )
        if self.entities[obj.id] ~= nil then
            print("Warning: entity ", obj.id, " already exists in tile.")
        else
            self.entities[obj.id] = obj
        end
    end,


    removeEntity = function( self, obj )
        if self.entities[obj.id] ~= nil then
            self.entities[obj.id] = nil
        end
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