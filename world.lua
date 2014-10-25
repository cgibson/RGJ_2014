
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"

Tile = require "tile"

local HEX_DRAW_BASE, HEX_DRAW_SELECTED = 1, 2

local HEX_COLOR_BLACK = {30, 30, 30 }
local HEX_BORDER = {60, 60, 110 }
local HEX_BORDER_SELECTED = {100, 100, 150 }

local HEX_BORDER_WIDTH = 1
local HEX_BORDER_WIDTH_SELECTED = 3

World = Class{
    init = function( self, width, height )
        self.width = width
        self.height = height
	    self.hexGrid = HXM.createRectGrid(width, height, 0)

        self.hexGrid["grid"][1][1] = {color=HEX_COLOR_BLACK, selected = true }

        -- FANCY DEBUG TIME
        self:setTile( 1, 1, Tile() )
        self:setTile( 2, 1, Tile() )
        self:setTile( 3, 1, Tile() )
        self:setTile( 4, 1, Tile() )
        self:setTile( 1, 2, Tile() )
        self:setTile( 1, 3, Tile() )
        self:setTile( 1, 4, Tile() )

        self.tile_radius = 48
        self.offset = {0, 0}
    end,

    setTile = function( self, cx, cy, obj )
        self.hexGrid.grid[cy][cx] = obj
    end,

    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)

        -- Draw base grid and backgrounds
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, self.tile_radius, self.offset[1], self.offset[2], {mode=HEX_DRAW_BASE})

        -- Draw selected grids
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, self.tile_radius, self.offset[1], self.offset[2], {mode=HEX_DRAW_SELECTED})

        -- Draw contents (TODO)
    end,

    drawHexagon = function(vertices, obj, args)

        if obj == 0 then
            return
        end

        if args.mode == HEX_DRAW_BASE then
            -- Draw the background
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

            --
            if obj.selected == true then

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
        end
    end,

    selectTile = function(self, px, py)
        cx, cy = HXM.getHexFromPixel(px, py, self.tile_radius, self.offset[1], self.offset[2])
        print("you selected tile (", cx, ", ", cy, ")")

        cx = cx+1
        cy = cy+1

        if self.hexGrid.grid[cy][cx] == 0 then
            print("You selected an empty tile you doofus!")
            return
        end

        self.hexGrid.grid[cy][cx].selected = (self.hexGrid.grid[cy][cx].selected == false)
    end
}


return World