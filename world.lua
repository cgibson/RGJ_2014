
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"

World = Class{
    init = function( self, width, height )
        self.width = width
        self.height = height
	    self.hexGrid = HXM.createRectGrid(width, height, {color={30, 30, 30}})

        self.hexGrid["grid"][1][1] = {color ={100,100,100} }

        self.hexGrid["grid"][2][2] = {color ={80,40,40}}
        self.hexGrid["grid"][3][3] = {color ={80,40,40}}
        self.hexGrid["grid"][4][4] = {color ={80,40,40} }

        self.hexGrid["grid"][1][2] = {color ={40,80,40}}
        self.hexGrid["grid"][1][3] = {color ={40,80,40}}
        self.hexGrid["grid"][1][4] = {color ={40,80,40} }

        self.hexGrid["grid"][2][1] = {color ={40,40,80}}
        self.hexGrid["grid"][3][1] = {color ={40,40,80}}
        self.hexGrid["grid"][4][1] = {color ={40,40,80} }

        self.tile_radius = 48
        self.offset = {0, 0}
    end,

    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, self.tile_radius, self.offset[1], self.offset[2], {mode="fill"})
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, self.tile_radius, self.offset[1], self.offset[2], {mode="line"})
    end,

    drawHexagon = function(vertices, obj, args)

        if args.mode == "fill" then
            if obj["color"] ~= nil then
                love.graphics.setColor(obj["color"])
            else
                love.graphics.setColor(0,0,0,255)
            end

            love.graphics.polygon(args.mode, vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)
        else
            love.graphics.setColor(60, 60, 110)

            love.graphics.polygon(args.mode, vertices[1].x, vertices[1].y,
                                             vertices[2].x, vertices[2].y,
                                             vertices[3].x, vertices[3].y,
                                             vertices[4].x, vertices[4].y,
                                             vertices[5].x, vertices[5].y,
                                             vertices[6].x, vertices[6].y)
        end
    end,

    selectTile = function(self, px, py)
        print("searching for tile: (", px, ", ", py, ")")
        cx, cy = HXM.getHexFromPixel(px, py, self.tile_radius, self.offset[1], self.offset[2])
        print("you selected tile (", cx, ", ", cy, ")")
    end
}


return World