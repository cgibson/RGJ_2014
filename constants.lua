--
--
--

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
        HEX_BORDER           = 1,
        HEX_BORDER_SELECTED = 3
    }
}

--
-- Command inputs (TODO)
--
-- TODO: Allow for changes to the above via config? maybe?

return Constants