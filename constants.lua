--
--
--

CURRENT_ENTITY_ID = 1

Constants = {
    --
    -- Basic shortcuts
    --
    MOUSE_BUTTON_LEFT = "l",
    MOUSE_BUTTON_RIGHT = "r",
    MOUSE_BUTTON_MIDDLE = "m", -- we shouldn't use this one. doesn't work on laptops
    MOUSE_WHEEL_UP = "wu",
    MOUSE_WHEEL_DOWN = "wd",

    --
    -- Colors
    --
    Colors = {
        HEX_BLACK           = {30, 30, 30 },
        HEX_BORDER          = {60, 60, 110 },
        HEX_BORDER_SELECTED = {100, 100, 150 }
    },

    Lines = {
        HEX_BORDER_WIDTH           = 1,
        HEX_BORDER_WIDTH_SELECTED = 3
    },

    Tiles = {
        TYPE_SPACE = 0,
        TYPE_PLANET = 1,
		TYPE_ASTEROID = 2,
        HEX_DRAW_BASE, HEX_DRAW_SELECTED, HEX_DRAW_CONTENTS = 1, 2, 3,
        TILE_RADIUS = 48
    },
	
	Events = {
		NONE = 0,
		GOOD_EVENT = 1,
		BAD_EVENT = 2
    }


}

function Constants.getNewId()
    id = CURRENT_ENTITY_ID
    CURRENT_ENTITY_ID = CURRENT_ENTITY_ID + 1
    return id
end

--
-- Command inputs (TODO)
--
-- TODO: Allow for changes to the above via config? maybe?

return Constants