-- Explorer by glitchdetector, Jun. 2020

-- Blips that are masked by the fog of war
-- These are automatically hidden if you've yet to discover an area
-- They will fade in when the player uncovers an area
-- https://docs.fivem.net/docs/game-references/blips/
BlipTypes = {
    404, -- fuel boat
    251, -- fuel plane
    401, -- fuel heli
    361, -- fuel
    72, -- lsc

    52, -- store

    -- 357, -- garage
    -- 359, -- aircraft garage
    -- 356, -- water garage

    375, -- business
    40, -- houses

    108, -- atm
    446, -- repair
    73, -- clothing store
    405, -- self storage

    118, -- car wash
    100, -- train wash
}

-- Remember what areas the player has discovered
-- If set to true, the client stored discovered areas
-- If set to false, the player needs to re-discover everything again after they disconnect
Persist = true

-- If Persist is true, this is used to prevent cross-server discovery
ServerCode = "E621"

-- Offsets to start from
MapOffsetX = -7500
MapOffsetY = -5000

-- Size of the map
MapWidth = 15000
MapHeight = 15000

-- How many cells the map contains
MapCellsWidth = 80
MapCellsHeight = 80

-- What area around the player should be discovered (rather than just their own cell)
-- # represents current block of cells's affected areas
-- Comment out from bottom to the top which parts you don't want
CoverArea = {
    -- Their current cell, do not comment out lol, the script won't work
    { 0,  0}, -- their current cell (P)
    -- + formation (5 cells)
    --  #
    -- #P#
    --  #
    {-1,  0}, -- cell to the west
    { 1,  0}, -- cell to the east
    { 0, -1}, -- cell north (could be inverse idk)
    { 0,  1}, -- cell south
    -- 3x3 formation (9 cells)
    -- #-#
    -- -P-
    -- #-#
    {-1, -1}, -- north west
    { 1, -1}, -- north east
    {-1,  1}, -- south west
    { 1,  1}, -- south east
    -- 5x5 circle formation (13 cells)
    --   #
    --  ---
    -- #-P-#
    --  ---
    --   #
    {-2,  0}, -- west
    { 2,  0}, -- east
    { 0, -2}, -- north
    { 0,  2}, -- south
}

-- Enable debugging
-- Shows a trail where you've discovered areas among other random stuff
-- You should probably not enable this unless you're modifying the script
Debug = false
