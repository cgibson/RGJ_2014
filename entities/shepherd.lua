

HXM = require "HexaMoon.HexaMoon"
Vector = require "hump.vector"


Shepherd = Class{
    init = function( self, pos )
        self.position =                 pos
        self.current_path =             {Vector(1,2), Vector(1,3), Vector(1,4)}
        self.speed =                    1       -- Speed (blocks/sec)
        self.time_since_last_move =     0       -- Time since last movement
                                                -- TODO: we should replace this with a tween sooner or later
        self.moving =                   false   -- Whether or not the Shepherd is moving to a new block
        self.width =                    32      -- Size of the shepherd
        self.height =                   32      -- Ditto on the size thing
    end,


    setNewPath = function( self )
        self.time_since_last_move = love.timer.getTime()
    end,


    update = function( self, dt )
        t = love.timer.getTime()

        -- TODO: Probably set up speed to be reverse-proportional to the time it takes to move
        if love.timer.getTime() - t > self.speed then

            -- Pop the next point along the path from the FiFo and move the shepherd
            self.position = table.remove(self.current_path, 1)

            -- Reset time last moved
            self.time_since_last_move = t
        end
    end,


    draw = function( self )
        local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.position.x, self.position.y, 0, 0)
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle("fill",
                                coord.x - (self.width / 2),
                                coord.y - (self.height / 2),
                                self.width,
                                self.height)

        self:drawPath()
    end,


    drawPath = function( self )
        love.graphics.setColor(0, 255, 0)
        for i = 1, #self.current_path do
            local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.current_path[i].x, self.current_path[i].y, 0, 0)
            love.graphics.rectangle("fill",
                                    coord.x - 10,
                                    coord.y - 10,
                                    20,
                                    20)
        end
    end
}

return Shepherd