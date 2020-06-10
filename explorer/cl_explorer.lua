-- Explorer by glitchdetector, Jun. 2020
local Regions = {}

local UncoverPercentage = 0
local UncoverProgress = 0
local UncoverTarget = 0

local BlipState = {}

exports("progress", function()
    return {UncoverPercentage, UncoverProgress, UncoverTarget}
end)

CreateThread(function()
    -- Individual cell sizes
    local CellWidth = MapWidth / MapCellsWidth
    local CellHeight = MapHeight / MapCellsHeight

    if Debug then
        -- hide the entire map, might need script restart to apply
        RegisterCommand("explorer_reset", function()
            print("explorer", "starting reset")
            for xx = 0, MapCellsWidth - 1 do
                for yy = 0, MapCellsHeight - 1 do
                    if Persist then DeleteResourceKvp(("%s_%s_%s"):format(ServerCode, xx, yy)) end
                    Regions[xx][yy][2] = true
                end
                Wait(0)
            end
            print("explorer", "reset complete")
        end)
        -- uncover the entire map, might need script restart to apply
        -- takes a few seconds, game will lag badly or even freeze
        RegisterCommand("explorer_fill", function()
            print("explorer", "starting fill", "client may lag or freeze")
            for xx = 0, MapCellsWidth - 1 do
                for yy = 0, MapCellsHeight - 1 do
                    if Persist then SetResourceKvpInt(("%s_%s_%s"):format(ServerCode, xx, yy), 1) end
                    Regions[xx][yy][2] = false
                end
                Wait(0)
            end
            print("explorer", "fill complete")
        end)
    end

    -- create the regions
    for xx = 0, MapCellsWidth - 1 do
        for yy = 0, MapCellsHeight - 1 do
            if Persist then
                -- load discovered regions from client storage
                if GetResourceKvpInt(("%s_%s_%s"):format(ServerCode, xx, yy)) == 1 then
                    if not Regions[xx] then Regions[xx] = {} end
                    Regions[xx][yy] = {nil, false}
                    if Debug then
                        -- Add a blip for testing and debugging i guess
                        local blip = AddBlipForArea(MapOffsetX + CellWidth * xx, MapOffsetY + CellHeight * yy, 0.0, CellWidth, CellHeight)
                        SetBlipRotation(blip, 0)
                        SetBlipSprite(blip, 0)
                        SetBlipColour(blip, 0xFF000055)
                        Regions[xx][yy][1] = blip
                    end
                end
            end
            -- create undiscovered region if one was not loaded
            if not Regions[xx] then Regions[xx] = {} end
            if not Regions[xx][yy] then
                Regions[xx][yy] = {nil, true}
            end
        end
    end
    -- blip update logic
    CreateThread(function()
        while true do
            -- Iterate all blip types that are affected
            for _, blipSprite in next, BlipTypes do
                local blip = GetFirstBlipInfoId(blipSprite)
                local c = 1
                while DoesBlipExist(blip) do
                    -- Calculate the cell the blip occupies
                    local pos = GetBlipInfoIdCoord(blip)
                    local cellX = math.floor(((pos.x - MapOffsetX) / CellWidth) + 0.5)
                    local cellY = math.floor(((pos.y - MapOffsetY) / CellHeight) + 0.5)
                    if Regions[cellX] and Regions[cellX][cellY] then
                        local currentBlip = blip
                        if Regions[cellX][cellY][2] then
                            -- Hide the blip if it wasn't already hidden
                            if BlipState[blip] ~= true then
                                BlipState[blip] = true
                                SetBlipAlpha(currentBlip, 0)
                            end
                        else
                            -- Show the blip if it's hidden
                            if BlipState[blip] ~= false then
                                BlipState[blip] = false
                                -- Fade the blip in over the course of 255 frames (lazy)
                                CreateThread(function()
                                    local alpha = GetBlipAlpha(currentBlip)
                                    if alpha < 20 then
                                        if FlashDiscovered then SetBlipFlashes(currentBlip, true) end
                                        while alpha < 255 do
                                            alpha = alpha + 1
                                            SetBlipAlpha(currentBlip, alpha)
                                            Wait(0)
                                        end
                                        if FlashDiscovered then SetBlipFlashes(currentBlip, false) end
                                    end
                                end)
                            end
                        end
                    end
                    blip = GetNextBlipInfoId(blipSprite)
                    -- Yield frequently, the script doesn't need to do all actions at once anyways
                    c = c + 1
                    if c % 10 then
                        Wait(0)
                    end
                end
                Wait(0)
            end

            -- Calculate discovery percentage and update region states
            local total = 0
            local uncovered = 0
            local updated = 0
            for xx = 0, MapCellsWidth - 1 do
                for yy = 0, MapCellsHeight - 1 do
                    -- if Regions[xx][yy][4] ~= Regions[xx][yy][3] then
                        -- Regions[xx][yy][3] = Regions[xx][yy][4]
                        updated = true
                    -- end
                    total = total + 1
                    if not Regions[xx][yy][2] then
                        uncovered = uncovered + 1
                    end
                end
            end
            if updated then
                local percentage = (uncovered / total) * 100
                UncoverPercentage = percentage
                UncoverProgress = uncovered
                UncoverTarget = total
            end
        end
    end)
    -- player update loop
    CreateThread(function()
        -- Uncovers a cell, safely spammed since it doesn't update already uncovered cells
        local function UncoverCell(x, y)
            if Regions[x] and Regions[x][y] then
                local region = Regions[x][y]
                if region[2] then
                    -- RemoveBlip(region[1])
                    if Debug then
                        local blip = AddBlipForArea(MapOffsetX + CellWidth * x, MapOffsetY + CellHeight * y, 0.0, CellWidth, CellHeight)
                        SetBlipRotation(blip, 0)
                        SetBlipSprite(blip, 0)
                        SetBlipColour(blip, 0xFF000055)
                        region[1] = blip
                    end
                    region[2] = false
                    if Persist then SetResourceKvpInt(("%s_%s_%s"):format(ServerCode, x, y), 1) end
                end
            end
        end
        -- current player cell logic
        while true do
            local pos = GetEntityCoords(PlayerPedId())
            local cellX = math.floor(((pos.x - MapOffsetX) / CellWidth) + 0.5)
            local cellY = math.floor(((pos.y - MapOffsetY) / CellHeight) + 0.5)
            -- update cells around the player based on offsets in the config
            for _, offsets in next, CoverArea do
                UncoverCell(cellX + offsets[1], cellY + offsets[2])
            end
            Wait(1000)
        end
    end)
end)
