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
        HEX_BLUE            = {0, 0, 60},
        HEX_WHITE           = {200, 200, 200},
        HEX_YELLOW          = {200, 200, 0},
        HEX_GREY            = {150, 150, 150},
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
        TYPE_OBSTACLE = 3,
        HEX_DRAW_BASE, HEX_DRAW_SELECTED, HEX_DRAW_CONTENTS = 1, 2, 3,
        TILE_RADIUS = 48
    },
	
	Events = {
		NONE = 0,
		GOOD_EVENT = 1,
		BAD_EVENT = 2
    },

    Entities = {
        RELAY_HP_MAX = 10,
        RELAY_DISTANCE_MAX = 5,

        RELAY_COST = 100,

        TYPE_SHEPHERD = 0,
        TYPE_RELAY = 1
    },

    CRAZY_CHAN_MODE = true,

    PLAYER_1 = 1,
    PLAYER_2 = 2,

    TICK_LENGTH = 1,

    DIRECTIONS = {"NE", "E", "SE", "SW", "W", "NW"}
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