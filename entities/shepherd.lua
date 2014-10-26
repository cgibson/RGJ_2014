



Shepherd = Class{
    init = function( self )
        self.position = nil
        self.current_path = {}
        self.speed = 1
        self.time_since_last_move = 0
        self.moving = false
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
    end
}

return Shepherd