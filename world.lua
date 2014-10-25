
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"

World = Class{
    init = function( self, width, height )
        self.width = width
        self.height = height
	    self.hexGrid = HXM.createRectGrid(width, height, {color={60, 60, 60}})

        self.hexGrid["grid"][4][4] = {color ={80,40,40}}
    end,

    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, 32, 80, 50, {mode="fill"})
    end,

    drawHexagon = function(vertices, obj, args)

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
    end
}


return World