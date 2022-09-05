local Grid = require("grid")

local PixelSize = 1 --KEEP AT 2
local debugVer = true

local function lightLevelToCol(D, LinMode)
    LinMode = LinMode or false
    D = D * 15.99 
    D = math.floor(D)
    if LinMode then
        return D
    else
        return 2^D
    end
end

local function drawFromArray1D(x, y, T, Grid)
    local P = {}
    local Pit = 0
    P.currLightLevel = nil
    ---@diagnostic disable-next-line: undefined-field
    for i,v in ipairs(T) do
        if lightLevelToCol(v.lightLevel,true) == P.currLightLevel then
           if P[Pit][2] == nil then
               P[Pit][2] = 1
           end
           P[Pit][2] = P[Pit][2] + 1

        else
            Pit = Pit + 1 
            P.currLightLevel = lightLevelToCol(v.lightLevel,true)
            P[Pit] = {}
            P[Pit][1] = i
            P[Pit][2] = 1
            P[Pit].col = P.currLightLevel
        end
    end
    P.currLightLevel = nil
---@diagnostic disable-next-line: undefined-field
    for i,v in ipairs(P) do --NOCH NICHT FERTIG
        term.drawPixels(
            (x+v[1])*PixelSize,
            y*PixelSize,
            2^v.col,
            PixelSize*(v[2]),
            PixelSize
        )
    end
    return P
end

local function drawFromArray2D(x, y, Grid) -- FIX THIS
    local oT = {} 
    ---@diagnostic disable-next-line: undefined-field
    for y1,v in ipairs(Grid.grid) do
        oT[y1] = drawFromArray1D(x-1,y+y1-1,v, Grid)
    end
end

local function setPalette()
    -- 0 - 253 plain gray
    for i=0,254 do
        term.setPaletteColor(i, colors.packRGB(i/255,i/255,i/255))
    end
    -- 254 creature
    term.setPaletteColor(254, colors.packRGB(0.75,0,0.75))
    -- 255 food
    term.setPaletteColor(255, colors.packRGB(0.5,0.5,0.5))
end

local function resetPalette()
    for i=0,15 do
        local r, g, b = term.nativePaletteColor(2^i)
        term.setPaletteColor(2^i, colors.packRGB(r,g,b))
    end
end

return {
    lightLevelToCol = lightLevelToCol,
    PixelSize = PixelSize,
    drawFromArray1D = drawFromArray1D,
    drawFromArray2D = drawFromArray2D,
    resetPalette = resetPalette,
    setPalette = setPalette
}