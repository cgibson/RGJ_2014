
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"
hexmath = require "HexaMath.HexaMath"
c = require "constants"

Tile = require "entities.tile"

-- TODO: Decide if these should be
--       A. In the World class itself, or
--       B. A constant (in 'constants')
--
local HEX_DRAW_BASE, HEX_DRAW_SELECTED, HEX_DRAW_CONTENTS = 1, 2, 3

local HEX_COLOR_BLACK = {30, 30, 30 }
local HEX_BORDER = {60, 60, 110 }
local HEX_BORDER_SELECTED = {100, 100, 150 }

local HEX_BORDER_WIDTH = 1
local HEX_BORDER_WIDTH_SELECTED = 3

local TILE_RADIUS = 48


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
	    self.hexGrid = HXM.createRectGrid(width, height, 0)

        -- TODO: Fancy generation things
        -- START FANCY DEBUG TIME
        self:setTile( 1, 1, Tile() )
        self:setTile( 2, 1, Tile() )
        self:setTile( 3, 1, Tile() )
        self:setTile( 4, 1, Tile() )
        self:setTile( 1, 2, Tile() )
        self:setTile( 1, 3, Tile() )
        self:setTile( 1, 4, Tile() )

        self.hexGrid.grid[1][1].type = c.Tiles.TYPE_PLANET
        -- END FANCY DEBUG TIME

        self.offset = {0, 0}
    end,

    setTile = function( self, cx, cy, obj )
        self.hexGrid.grid[cy][cx] = obj
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
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_BASE})

        -- Draw boundary grid
        -- TODO

        -- Draw selected grids
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_SELECTED})

        -- Draw contents
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_CONTENTS})

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
            return
        end

        -- Draw the base hex grid
        --
        if args.mode == HEX_DRAW_BASE then
            -- Draw the background
            local vertices = HXM.getHexVertices(TILE_RADIUS, hexCoords.x, hexCoords.y)
            love.graphics.setColor(obj.color)

            love.graphics.polygon("fill",    vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)

            -- Draw the border
            love.graphics.setColor(HEX_BORDER)
            love.graphics.setLineWidth(HEX_BORDER_WIDTH)

            love.graphics.polygon("line",    vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)

        -- Draw the selected hexagons
        --
        elseif args.mode == HEX_DRAW_SELECTED then

            -- Draw only if we have the tile selected
            if obj.selected == true then

                local vertices = HXM.getHexVertices(TILE_RADIUS, hexCoords.x, hexCoords.y)

                -- Draw the border
                love.graphics.setColor(HEX_BORDER_SELECTED)
                love.graphics.setLineWidth(HEX_BORDER_WIDTH_SELECTED)

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
        elseif args.mode == HEX_DRAW_CONTENTS then
            obj:draw(hexCoords.x, hexCoords.y)
        end
    end,


    --
    -- SELECT TILE function
    --
    -- Given a world x and y value, find the correct
    -- hexagon index in self.hexGrid and select it
    --
    selectTile = function(self, px, py)

        -- From world coordinates to hex coordinates
        cx, cy = HXM.getHexFromPixel(px, py, TILE_RADIUS, self.offset[1], self.offset[2])
        print("you selected tile (", cx, ", ", cy, ")")
		print("selected tile is ", hexmath.Distance(cx, cy, 0, 0), " from origin")

        -- one indexed. ONE INDEXED
        cx = cx+1
        cy = cy+1

        -- TODO: avoid out-of-bounds

        -- Non-tiles should be skipped
        if self.hexGrid.grid[cy][cx] == 0 then
            print("You selected an empty tile you doofus!")
            return
        end

        -- TODO: instead of toggling, we should only have one selected tile at once
        self.hexGrid.grid[cy][cx].selected = (self.hexGrid.grid[cy][cx].selected == false)
    end
}


-- Return the world object
return World