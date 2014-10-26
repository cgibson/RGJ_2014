

HXM = require "HexaMoon.HexaMoon"
local c = require "constants"
hexamath = require "HexaMath.HexaMath"

local STATE_IDLE, STATE_MOVING, STATE_BUILDING, STATE_RETREATING = 0, 1, 2, 3


Shepherd = Class {
    init = function( self, world, pos )
        self.id =                       c.getNewId()
        self.type =                     c.Entities.TYPE_SHEPHERD
        self.hp =                       20
        self.world =                    world       -- Copy of the world (for movement/placement)
        self.position =                 pos
        self.current_path =             {}
        self.destination =              pos
        self.speed =                    1           -- Speed (blocks/sec)
        self.time_since_last_action =   0           -- Time since last movement
                                                    -- TODO: we should replace this with a tween sooner or later
        self.width =                    32          -- Size of the shepherd
        self.height =                   32          -- Ditto on the size thing

        self.to_build =                 nil         -- If this is not-nil, the shepherd will place the entity
                                                    -- once it arrives at its destination

        self.state =                    STATE_IDLE  -- idle, building, moving, retreating
        self.selected =                 false
        self:scanTiles( self.hp, self.position )
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
                if self:do_move(self.position, table.remove(self.current_path, 1)) == false then
                    self:emergency_stop()
                else
                    -- Reset time last moved
                    self.time_since_last_action = t

                    -- If we currently are at the end of our current path, then we're dun
                    --
                    if #self.current_path < 1 then

                        -- If we have something to build, then start building it
                        --
                        if self.to_build ~= nil then
                            self.time_since_last_action = love.timer.getTime()
                            -- Update state to BUILDING
                            self.state = STATE_BUILDING
                        else
                            -- Otherwise, we're idle
                            self.state = STATE_IDLE
                        end
                    end
                end
            end

        -- If we are building, check to see how long it will take to build whatever it is
        -- TODO: We will need to wait for resources to come to us. There is no logic for receiving sheep yet
        --
        elseif self.state == STATE_BUILDING then
            -- We are going to build something... figure out how much time it will take
            if t - self.time_since_last_action > self.to_build.build_time then
                self.state = STATE_IDLE
            end
        end
    end,
    
    emergency_stop = function (self, pos )
        self.current_path = {}
        self.state = STATE_IDLE
    end,
    
    is_on_path = function( self, pos)
        for _,v in pairs(self.current_path) do
            if v == pos then
                return true
            end
        end
        return false
    end,

    --
    -- Internal movement function
    --
    do_move = function( self, old_pos, new_pos )
        local oldTile = self.world:getTile(old_pos)
        local newTile = self.world:getTile(new_pos)
        if self.hp < 10 and newTile.explored[c.PLAYER_1] == false then
            return false
        end
        if newTile.type == c.Tiles.TYPE_ASTEROID then
            newTile:explore(c.PLAYER_1)
            return false
        end
        self.hp = self.hp - 1
        self.position = new_pos
        oldTile:removeEntity(self)
        newTile:addEntity(self)
        
        self:scanTiles(self.hp, new_pos)
        return true
    end,

    scanTiles = function( self, hp, pos )
        scanTile = self.world:getTile(pos)
        if scanTile ~= nil then
            scanTile:explore(c.PLAYER_1)
        end
        for k,v in pairs(c.DIRECTIONS) do
            sensor_x = pos.x
            sensor_y = pos.y
            for i=1, hp/10 do
                x, y = HXM.getHexCoordinate(v, sensor_x, sensor_y)
                newVector = Vector(x, y)
                scanTile = self.world:getTile(newVector)
                if scanTile ~= nil then
                    scanTile:explore(c.PLAYER_1)
                    if scanTile.type == c.Tiles.TYPE_ASTEROID and self:is_on_path( newVector ) then
                        self:move_action( self.destination )
                    end
                end
                sensor_x = x
                sensor_y = y
            end
        end
    end,
    
    move_action = function( self, move_to )
        if self.position ~= move_to then
            self.state = STATE_MOVING
            self.destination = move_to
            self.time_since_last_move = love.timer.getTime()
            self.to_build = nil -- We no longer want to build whatever we might have been assigned to build

            -- Build path to the destination
            -- Set it to current_path

            self.current_path = hexamath.CalculatePath( self.world, self.position, move_to, self.hp < 10) 
            print("path length: ", #self.current_path)
            for key,value in pairs(self.current_path) do print("   ", key,value) end
        end
    end,


    draw = function( self )
        -- NOTE: must move from 1-indexed to 0-indexed because HexaMoon is stupid
        local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.position.x-1, self.position.y-1, 0, 0)
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
            -- NOTE: must move from 1-indexed to 0-indexed because HexaMoon is stupid
            local coord = HXM.getCoordinates(c.Tiles.TILE_RADIUS, self.current_path[i].x-1, self.current_path[i].y-1, 0, 0)
            love.graphics.rectangle("fill",
                                    coord.x - 10,
                                    coord.y - 10,
                                    20,
                                    20)
        end
    end,


    canReceiveSheep = function( self )
        -- Yea, sure... why not?
        return true
    end
}

return Shepherd