local hexmath = {}

-- Gets the distance between two Hexagons in axial coordinates
function hexmath.Distance(h1_x, h1_y, h2_x, h2_y)
	return (math.abs(h1_x - h2_x) + math.abs(h1_y - h2_y) + math.abs(h1_x + h1_y - h2_x - h2_y)) / 2
end

return hexmath