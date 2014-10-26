local hexamath = {}
HXM = require "HexaMoon.HexaMoon"
local grid_memo = {}
local grid_cost = {}
local directions = {"NE", "E", "SE", "SW", "W", "NW"}

function hexamath.createMemo (width, height)
    grid_memo = HXM.createRectGrid(width, height, 0)
end

-- Gets the distance between two Hexagons in axial coordinates
function hexamath.Distance(h1_x, h1_y, h2_x, h2_y)
	return (math.abs(h1_x - h2_x) + math.abs(h1_y - h2_y) + math.abs(h1_x + h1_y - h2_x - h2_y)) / 2
end

function hexamath.CalculatePath( world, vector1, vector2 )
    -- return {Vector(1,2), Vector(1,3), Vector(1,4)}
    frontier = {}
    grid_memo = {}
    grid_cost = {}
    
    table.insert(frontier, vector1)
    grid_memo[vector1] = vector1
    grid_cost[vector1] = 0
    frontier_i = table.remove(frontier, 1)
    while frontier_i ~= nil do
        for k,v in pairs(directions) do
            print(v, frontier_i.x, frontier_i.y)
            x, y = HXM.getHexCoordinate(v, frontier_i.x, frontier_i.y)
            newVector = Vector(x, y)
            if world:outOfBounds(newVector.x, newVector.y) == false and grid_memo[newVector] == nil then
                print("New vector is good", newVector)
                grid_memo[newVector] = frontier_i
                newTile = world:getTile(newVector)
                grid_cost[newVector] = grid_cost[frontier_i]
                grid_cost[newVector] = grid_cost[newVector]-- + newTile:getWeight(1)
                if newVector == vector2 then
                    print("OH DEAR GOD I FOUND IT")
                    returnPath = {}
                    while newVector ~= vector1 do
                        table.insert(returnPath, 1, newVector)
                        newVector = grid_memo[newVector]
                    end
                    return returnPath
                end
                i = 1
                while frontier[i] ~= nil and grid_cost[frontier[i]] <= grid_cost[newVector] do
                    i = i + 1
                end
                table.insert(frontier, i, newVector)
            end
        end
        frontier_i = table.remove(frontier, 1)
    end
    return nil
end

return hexamath