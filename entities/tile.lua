
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
        if math.random(1,5) == 1 then
            self.type = c.Tiles.TYPE_ASTEROID
        else
            self.type = c.Tiles.TYPE_SPACE
        end
		
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
        
        -- Indexed by player id
        self.owner = 0
        
        self.sheep = 0

        self.entities = {}
    end,

    update = function( self )
        if self.owner == 1 then self.color = c.Colors.HEX_BLUE
        elseif self.explored[1] == false then self.color = c.Colors.HEX_BLACK
        elseif self.explored[1] == true then
            if self.type == c.Tiles.TYPE_ASTEROID then self.color = c.Colors.HEX_WHITE
            elseif self.owner ~= 0 then self.color = c.Colors.HEX_YELLOW
            else self.color = c.Colors.HEX_GREY
            end
        end
        if self.type == c.Tiles.TYPE_PLANET then
            self.sheep = self.sheep + 6
        end
    end,
    
    explore = function( self, playerId )
        self.explored[playerId] = true
        self:update()
    end,

    getRelay = function( self )

        for id, obj in pairs(self.entities) do
            -- There should only ever be one rely on a space
            if obj.type == c.Entities.TYPE_RELAY then
                return obj
            end
        end
        return nil
    end,


    getShepherds = function( self )
        local shepherds = {}
        for id, obj in pairs(self.entities) do
            if obj.type == c.Entities.TYPE_SHEPHERD then
                shepherds[#shepherds+1] = obj
            end
        end

        if #shepherds > 0 then
            return shepherds
        else
            return nil
        end
    end,


    getPlanet = function ( self )
        for id, obj in pairs(self.entities) do
            if obj.type == c.Entities.TYPE_PLANET then
                return obj
            end
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
        if self.type == c.Tiles.TYPE_PLANET or self.type == c.Tiles.TYPE_PLANET_OUTER then
            return {0, 255, 255}
        end
        if #self.entities > 0 then
            return {20, 70, 20 }
        else
            return self.color
        end

    end,


    canReceiveSheep = function( self )

        if self.type == c.Tiles.TYPE_PLANET then
            return true
        else --if self.type == c.Tiles.TYPE_OBSTACLE then
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

end

function Tile:getWeight( playerId , retreat)
    if self.explored[playerId] == false then
        if retreat then
            return 9999
        end
        return 3
    elseif self.type == c.Tiles.TYPE_ASTEROID then
        return 9999
    elseif self.relayCount[playerId] > 0 then
        return 1
    else
        return 2
    end
end

return Tile