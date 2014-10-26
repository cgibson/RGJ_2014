

HXM = require "HexaMoon.HexaMoon"
Vector = require "hump.vector"

local STATE_IDLE, STATE_MOVING, STATE_BUILDING, STATE_RETREATING = 0, 1, 2, 3


Shepherd = Class{
    init = function( self, pos )
        self.position =                 pos
        self.current_path =             {}
        self.speed =                    1           -- Speed (blocks/sec)
        self.time_since_last_action =   0           -- Time since last movement
                                                    -- TODO: we should replace this with a tween sooner or later
        self.width =                    32          -- Size of the shepherd
        self.height =                   32          -- Ditto on the size thing

        self.to_build =                 nil         -- If this is not-nil, the shepherd will place the entity
                                                    -- once it arrives at its destination

        self.state =                    STATE_IDLE  -- idle, building, moving, retreating
    end,


    setNewPath = function( self, path )
        self.time_since_last_move = love.timer.getTime()
        self.current_path = path
        self.state = STATE_MOVING
    end,


    update = function( self, dt )
        t = love.timer.getTime()
        -- TODO: Probably set up speed to be reverse-proportional to the time it takes to move
        if self.state == STATE_MOVING then
            if t - self.time_since_last_action > self.speed then
                -- Pop the next point along the path from the FiFo and move the shepherd
                self.position = table.remove(self.current_path, 1)

                -- Reset time last moved
                self.time_since_last_action = t

                if #self.current_path < 1 then
                    if self.to_build ~= nil then
                        self.time_since_last_action = love.timer.getTime()
                        -- Update state to BUILDING
                        self.state = STATE_BUILDING
                    else
                        self.state = STATE_IDLE
                    end
                end
            end
        elseif self.state == STATE_BUILDING then
            -- We are going to build something... figure out how much time it will take
            if t - self.time_since_last_action > self.to_build.build_time then
                self.state = STATE_IDLE
            end
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