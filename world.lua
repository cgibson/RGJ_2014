
--
--
--
Class = require "hump.class"
Vector = require "hump.vector"
HXM = require "HexaMoon.HexaMoon"
hexamath = require "HexaMath.HexaMath"
c = require "constants"

Tile = require "entities.tile"
Relay = require "entities.relay"
Shepherd = require "entities.shepherd"


local empty_tile = Tile()
empty_tile.color = {10,10,10}

--
-- WORLD class
--
-- Contains a grid of the tile objects
-- Handles all interactions with the world
--     - selection, movement
--     - effects
--     - relay placement/update
--
World = Class{
    init = function( self, width, height )
        self.width = width      -- Width of grid
        self.height = height    -- Height of grid
        self.numPlayers = 2     -- Hard coded for now

        self.time_since_last_tick = love.timer.getTime()

        self.bounds = self:getBounds()

	    self.hexGrid = HXM.createRectGrid(width, height, nil)
        hexamath.createMemo( width, height )

        -- Contains information about each player and the entities they control
        self.player_data = {}

        -- User
        self.player_data[c.PLAYER_1] = {
            relays = {},
            shepherd = nil,
            selection = nil,

            is_placing = false,
            relay_to_build = nil
        }

        -- Enemy (AI for now)
        self.player_data[c.PLAYER_2] = {
            relays = {},
            shepherd = nil,
            selection = nil,

            is_placing = false,
            relay_to_build = nil
        }

        -- TODO: Fancy generation things
        -- START FANCY DEBUG TIME

        for i = 1, 5 do
            for j = 1, 5 do
                self:setTile( i, j, Tile() )
            end
        end

        self.hexGrid.grid[1][1].type = c.Tiles.TYPE_PLANET
        
        for i = 3, 8 do
            self.hexGrid.grid[i][i] = nil
        end

        self.shepherd = Shepherd( self, Vector(1,1))

        -- Hard coded shepherd path
        --shepherd:setNewPath( {Vector(1,2), Vector(1,3), Vector(1,4)} )

        self.player_data[c.PLAYER_1].shepherd = self.shepherd



        -- RELAY 1
        local ret = Relay.startPlacingRelay( self, c.PLAYER_1, Vector(3,2), "W")
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end


        ret = Relay.buildPendingRelay( self, c.PLAYER_1, c.Entities.RELAY_COST * 4 )
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end



        -- RELAY 2
        ret = Relay.startPlacingRelay( self, c.PLAYER_1, Vector(1,2), "SE")
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end


        ret = Relay.buildPendingRelay( self, c.PLAYER_1 )
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end



        -- RELAY 3
        local ret = Relay.startPlacingRelay( self, c.PLAYER_1, Vector(1,4), "NE")
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end


        local ret = Relay.buildPendingRelay( self, c.PLAYER_1 )
        if ret.error ~= nil then
            print("WARNING: " .. ret.error)
        end



        -- END FANCY DEBUG TIME
    end,

    setTile = function( self, cx, cy, obj )
        self.hexGrid.grid[cy][cx] = obj
    end,


    getTile = function( self, pos )
        return self.hexGrid.grid[pos.y][pos.x]
    end,

    --
    -- DRAW function
    --
    -- Draws the board. The following is the order of render:
    --    1. Draw background and base hexagon outlines
    --    2. Draw boundary hexagons
    --    3. Draw selected hexagons
    --    4. Draw hexagon contents
    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)

        -- Draw base grid and backgrounds
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, c.Tiles.TILE_RADIUS, 0, 0, {mode=c.Tiles.HEX_DRAW_BASE})

        -- Draw boundary grid
        -- TODO

        -- Draw selected grids
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, c.Tiles.TILE_RADIUS, 0, 0, {mode=c.Tiles.HEX_DRAW_SELECTED})

        -- Draw contents
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, c.Tiles.TILE_RADIUS, 0, 0, {mode=c.Tiles.HEX_DRAW_CONTENTS})

        -- Draw entities
        for playerId, data in pairs(self.player_data) do
            -- Update entities
            for idx, relay in pairs(data.relays) do
                relay:draw()
            end

            if data.shepherd ~= nil then
                data.shepherd:draw()
            end
        end
    end,


    --
    -- DRAW HEXAGON function
    --
    -- Draw the given hexagon
    --
    -- This is a HORRIBLY overridden function that really should be cut into
    -- smaller pieces rather than passing a 'mode' as an arg
    -- TODO: Do this
    --
    drawHexagon = function(hexCoords, obj, args)

        -- Leave if we find an empty tile
        --
        if obj == 0 then
            obj = empty_tile
            --return
        end

        -- Draw the base hex grid
        --
        if args.mode == c.Tiles.HEX_DRAW_BASE then
            -- Draw the background
            local vertices = HXM.getHexVertices(c.Tiles.TILE_RADIUS, hexCoords.x, hexCoords.y)
            love.graphics.setColor(obj:getBackground())

            love.graphics.polygon("fill",    vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)

            -- Draw the border
            love.graphics.setColor(c.Colors.HEX_BORDER)
            love.graphics.setLineWidth(c.Lines.HEX_BORDER_WIDTH)

            love.graphics.polygon("line",    vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)

        -- Draw the selected hexagons
        --
        elseif args.mode == c.Tiles.HEX_DRAW_SELECTED then

            -- Draw only if we have the tile selected
            if obj.selected == true then

                local vertices = HXM.getHexVertices(c.Tiles.TILE_RADIUS, hexCoords.x, hexCoords.y)

                -- Draw the border
                love.graphics.setColor(c.Colors.HEX_BORDER_SELECTED)
                love.graphics.setLineWidth(c.Lines.HEX_BORDER_WIDTH_SELECTED)

                love.graphics.polygon("line",    vertices[1].x, vertices[1].y,
                                                 vertices[2].x, vertices[2].y,
                                                 vertices[3].x, vertices[3].y,
                                                 vertices[4].x, vertices[4].y,
                                                 vertices[5].x, vertices[5].y,
                                                 vertices[6].x, vertices[6].y)
            end

        -- Draw hexagon contents
        --
        -- Relies on Tile:draw(x,y)
        --
        elseif args.mode == c.Tiles.HEX_DRAW_CONTENTS then
            obj:draw(hexCoords.x, hexCoords.y)
        end
    end,


    --
    -- Internal movement function
    --
    moveEntity = function( self, obj, old_pos, new_pos )
        obj.position = new_pos

        local tile = self:getTile(old_pos)
        tile:removeEntity(self)

        tile = self:getTile(new_pos)
        tile:addEntity(self)
    end,


    --
    -- SELECT TILE function
    --
    -- Given a world x and y value, find the correct
    -- hexagon index in self.hexGrid and select it
    --
    selectTile = function(self, px, py)

        -- From world coordinates to hex coordinates
        cx, cy = HXM.getHexFromPixel(px, py, c.Tiles.TILE_RADIUS, 0, 0)

        -- one indexed. ONE INDEXED
        cx = cx+1
        cy = cy+1

        print("you selected tile (", cx, ", ", cy, ")")
		print("selected tile is ", hexamath.Distance(cx, cy, 0, 0), " from origin")

        -- avoid out-of-bounds
        if self:outOfBounds(cx, cy) then
            -- print("out of bounds")
            return
        end

        -- handle empty sections of the grid
        if self.hexGrid.grid[cy][cx] == nil then
            -- print("no data here")
            return
        end

        -- Non-tiles should be skipped
        if self.hexGrid.grid[cy][cx] == 0 then
            print("You selected an empty tile you doofus!")
            return
        end

        -- TODO: instead of toggling, we should only have one selected tile at once
        if Vector(cy, cx) == self.shepherd.position then
            self.shepherd.selected = true
        else
            self.hexGrid.grid[cy][cx].selected = (self.hexGrid.grid[cy][cx].selected == false)
        end
    end,
    
    rightSelectTile = function(self, px, py)

        -- From world coordinates to hex coordinates
        cx, cy = HXM.getHexFromPixel(px, py, c.Tiles.TILE_RADIUS, 0, 0)

        -- one indexed. ONE INDEXED
        cx = cx+1
        cy = cy+1

        print("you selected tile (", cx, ", ", cy, ")")
		print("selected tile is ", hexamath.Distance(cx, cy, 0, 0), " from origin")

        -- avoid out-of-bounds
        if self:outOfBounds(cx, cy) then
            -- print("out of bounds")
            return
        end

        -- handle empty sections of the grid
        if self.hexGrid.grid[cy][cx] == nil then
            -- print("no data here")
            return
        end

        -- Non-tiles should be skipped
        if self.hexGrid.grid[cy][cx] == 0 then
            print("You selected an empty tile you doofus!")
            return
        end

        -- If the shepherd is selected, the selected space is it's destination
        if self.shepherd.selected == true then
            print("I've selected the shepherd. Time to move")
            self.shepherd:move_action( Vector(cx, cy) )
        end
    end,

    --
    -- UPDATE function
    --
    -- Updates the entire world and everything in it. This is considered one "tick"
    --
    update = function(self, dt)
        t = love.timer.getTime()

        for playerId, data in pairs(self.player_data) do
            -- update Shepherds
            if data.shepherd ~= nil then
                data.shepherd:update(dt)
            end

        end


        if t - self.time_since_last_tick > c.TICK_LENGTH then
            self.time_since_last_tick = t
            for playerId, data in pairs(self.player_data) do
                for relayId, relay in pairs(data.relays) do
                    relay:update( dt )
                end
                --Relay.updateSheepingRoutes(data.relays)
            end
        end
    end,


    outOfBounds = function(self, cx, cy)
        -- print("input:  ", cx, ", ", cy)
        -- print("bounds: ", self.bounds.xmin, " -> ", self.bounds.xmax)
        -- print("        ", self.bounds.ymin, " -> ", self.bounds.ymax)
        return (cx < self.bounds.xmin) or
               (cx > self.bounds.xmax) or
               (cy < self.bounds.ymin) or
               (cy > self.bounds.ymax)
    end,


    getBounds = function(self)
        return {
            xmin = -((math.ceil((self.width-1)+(self.height-1)/2))-self.width),
            xmax = self.width,
            ymin = 1,
            ymax = self.height
        }
    end
}


-- Return the world object
return World