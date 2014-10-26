
Class = require "hump.class"


Button = Class{
    init = function( self, pos, size, text )
        self.position = pos
        print("position ", self.position)
        self.size = size
        self.text = text
        self.color = {100,100,100}
        self.borderColor = {255,255,255}
        self.textColor = {255,255,255 }
        self.borderWidth = 3
        self.bounds = {0,0,0,0}
    end,


    draw = function( self )
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.position.x - (self.size.x / 2),
                                        self.position.y- (self.size.y / 2),
                                        self.size.x, self.size.y)

        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.position.x - (self.size.x / 2),
                                        self.position.y- (self.size.y / 2),
                                        self.size.x, self.size.y)

        self.bounds = {
           xmin = (self.position.x - (self.size.x / 2)),
           xmax = (self.position.x + (self.size.x / 2)),
           ymin = (self.position.y - (self.size.y / 2)),
           ymax = (self.position.y + (self.size.y / 2))
        }

        love.graphics.setColor(self.textColor)
        love.graphics.print(self.text, self.position.x - (3*#self.text), self.position.y-8)
    end,


    isClicked = function( self, point )
        if (point.x > self.bounds.xmin) and
           (point.x < self.bounds.xmax) and
           (point.y > self.bounds.ymin) and
           (point.y < self.bounds.ymax) then
            return true
        end

        return false
    end

}


return Button