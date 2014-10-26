local hexamath = {}
local grid_path = nil

-- Gets the distance between two Hexagons in axial coordinates
function hexamath.Distance(h1_x, h1_y, h2_x, h2_y)
	return (math.abs(h1_x - h2_x) + math.abs(h1_y - h2_y) + math.abs(h1_x + h1_y - h2_x - h2_y)) / 2
end

function hexamath.CalculateRoute(grid, origin_x, origin_y, destination_x, destination_y)
    -- Make a copy of the world grid
    grid_path = grid
    
    
end

function hexamath.NextTile()
    if grid_path == nil then
        return nil
    else
        
    end
end

return hexamath