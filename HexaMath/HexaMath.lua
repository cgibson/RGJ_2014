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
-- Gets the distance between two Hexagons in axial coordinates
function hexamath.VectorDistance(h1, h2)
    local h1_x = h1.x
    local h1_y = h1.y
    local h2_x = h2.x
    local h2_y = h2.y
	return (math.abs(h1_x - h2_x) + math.abs(h1_y - h2_y) + math.abs(h1_x + h1_y - h2_x - h2_y)) / 2
end

function hexamath.CalculatePath( world, vector1, vector2 )
    -- return {Vector(1,2), Vector(1,3), Vector(1,4)}
    frontier = {}
    grid_memo = {}
    grid_cost = {}
    max_frontier_size = 1
    max_frontier_count = 0
    table.insert(frontier, vector1)
    grid_memo[vector1.x .. "," .. vector1.y] = vector1
    grid_cost[vector1.x .. "," .. vector1.y] = 0
    frontier_i = table.remove(frontier, 1)
    while frontier_i ~= nil do
        for k,v in pairs(directions) do
            x, y = HXM.getHexCoordinate(v, frontier_i.x, frontier_i.y)
            newVector = Vector(x, y)
            newVectorId = x .. "," .. y
            if world:outOfBounds(newVector.x, newVector.y) == false and grid_memo[newVectorId] == nil and world:getTile(newVector) ~= nil then
                print("Adding to frontier", newVectorId, "->", frontier_i)
                grid_memo[newVectorId] = frontier_i
                newTile = world:getTile(newVector)
                if newTile ~= nil then
                    newTile.selected = true
                end
                grid_cost[newVectorId] = grid_cost[frontier_i.x .. "," .. frontier_i.y]
                grid_cost[newVectorId] = grid_cost[newVectorId] + newTile:getWeight(1)
                if newVector == vector2 then
                    --print("OH DEAR GOD I FOUND IT")
                    --for k2,v2 in pairs(grid_memo) do
                    --   print(k2, v2)
                    --end
                    returnPath = {}
                    while newVector ~= vector1 do
                        print("Backtracking", newVector, "to", grid_memo[newVectorId])
                        table.insert(returnPath, 1, newVector)
                        newVector = grid_memo[newVectorId]
                        newVectorId = newVector.x .. "," .. newVector.y
                    end
                    print("Frontier Max Size", max_frontier_size)
                    print("Frontier Max Calcs", max_frontier_count)
                    return returnPath
                end
                i = 1
                while frontier[i] ~= nil and grid_cost[frontier[i].x .. "," .. frontier[i].y] + hexamath.VectorDistance(frontier[i], vector2) <= grid_cost[newVectorId] + hexamath.VectorDistance(newVector, vector2) do
                    i = i + 1
                end
                table.insert(frontier, i, newVector)
            end
        end
        if #frontier > max_frontier_size then
            max_frontier_size = #frontier 
        end
        max_frontier_count = max_frontier_count + 1
        frontier_i = table.remove(frontier, 1)
    end
    return nil
end

return hexamath