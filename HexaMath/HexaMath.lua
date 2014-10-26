local hexamath = {}
HXM = require "HexaMoon.HexaMoon"
local grid_memo = nil

function hexamath.createMemo (width, height)
    grid_memo = HXM.createRectGrid(width, height, 0)
end

-- Gets the distance between two Hexagons in axial coordinates
function hexamath.Distance(h1_x, h1_y, h2_x, h2_y)
	return (math.abs(h1_x - h2_x) + math.abs(h1_y - h2_y) + math.abs(h1_x + h1_y - h2_x - h2_y)) / 2
end

function hexamath.CalculatePath( grid, vector1, vector2 )
    return {Vector(1,2), Vector(1,3), Vector(1,4)}
end

return hexamath