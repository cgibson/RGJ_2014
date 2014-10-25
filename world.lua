
--
--
--
Class = require "hump.class"
HXM = require "HexaMoon.HexaMoon"

World = Class{
    init = function( self, width, height )
        self.width = width
        self.height = height
	    self.hexGrid = HXM.createRectGrid(width, height, {color={255, 255, 255}})
    end,

    draw = function( self )
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(2)
        HXM.drawRectGrid(self.hexGrid, self.drawHexagon, 64, 50, 50, {mode="line"})
    end,

    drawHexagon = function(vertices, obj, args)
        love.graphics.polygon(args.mode, vertices[1].x, vertices[1].y,
                                         vertices[2].x, vertices[2].y,
                                         vertices[3].x, vertices[3].y,
                                         vertices[4].x, vertices[4].y,
                                         vertices[5].x, vertices[5].y,
                                         vertices[6].x, vertices[6].y)
    end
}


return World