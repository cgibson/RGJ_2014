
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"
hexmath = require "HexaMath.HexaMath"
c = require "constants"

Tile = require "tile"

local HEX_DRAW_BASE, HEX_DRAW_SELECTED, HEX_DRAW_CONTENTS = 1, 2, 3

local HEX_COLOR_BLACK = {30, 30, 30 }
local HEX_BORDER = {60, 60, 110 }
local HEX_BORDER_SELECTED = {100, 100, 150 }

local HEX_BORDER_WIDTH = 1
local HEX_BORDER_WIDTH_SELECTED = 3

local TILE_RADIUS = 48

World = Class{
    init = function( self, width, height )
        self.width = width
        self.height = height
	    self.hexGrid = HXM.createRectGrid(width, height, 0)

        self.hexGrid["grid"][1][1] = {color=HEX_COLOR_BLACK, selected = true }

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

    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)

        -- Draw base grid and backgrounds
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_BASE})

        -- Draw selected grids
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_SELECTED})

        -- Draw contents (TODO)
        HXM.drawRectGridX(self.hexGrid, self.drawHexagon, TILE_RADIUS, self.offset[1], self.offset[2], {mode=HEX_DRAW_CONTENTS})

    end,

    drawHexagon = function(hexCoords, obj, args)

        if obj == 0 then
            return
        end

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
        elseif args.mode == HEX_DRAW_CONTENTS then
            obj:draw(hexCoords.x, hexCoords.y)
        end
    end,

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


return World