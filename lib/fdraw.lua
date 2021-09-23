local mathb = import("mathb")
local Grid = import("grid")

local PixelSize = 10
local debugVer = true

local function densityToCol(D, LinMode)
    if D > 1 then
        if LinMode then
            return math.log(Grid.wallColor,2)
        else
            return Grid.wallColor
        end
    else
        LinMode = LinMode or false
        D = D * 15.99 
        D = math.floor(D)
        if LinMode then
            return D
        else
            return 2^D
        end
    end
end

local function drawFromArray1D(x, y, T, Grid)
    local P = {}
    local Pit = 0
    P.currDensity = nil
    ---@diagnostic disable-next-line: undefined-field
    for i=1,table.getn(T) do
        if densityToCol(T[i].density,true) == P.currDensity then
           if P[Pit][2] == nil then
               P[Pit][2] = 1
           end
           P[Pit][2] = P[Pit][2] + 1

        else
            Pit = Pit + 1 
            P.currDensity = densityToCol(T[i].density,true)
            P[Pit] = {}
            P[Pit][1] = i
            P[Pit][2] = 1
            P[Pit].col = P.currDensity
        end
    end
    P.currDensity = nil
    -- if y == 10 then
    --     local file = fs.open("1/home/debug/DFA.txt","w")
    --     file.write(textutils.serialise(P))
    --     file.close()
    -- end
---@diagnostic disable-next-line: undefined-field
    for i=1,table.getn(P) do --NOCH NICHT FERTIG
        term.drawPixels(
            (x+P[i][1])*PixelSize,
            y*PixelSize,
            2^P[i].col,
            PixelSize*(P[i][2]),
            PixelSize
        )
    end
    return P
end

local function drawFromArray2D(x, y, Grid) -- FIX THIS
    local oT = {} 
    ---@diagnostic disable-next-line: undefined-field
    for y1=1,table.getn(Grid.grid) do
        oT[y1] = drawFromArray1D(x-1,y+y1-1,Grid.grid[y1], Grid)
    end
    -- local file = fs.open("1/home/debug/DFA2D.txt","w")
    -- file.write(textutils.serialise(oT))
    -- file.close()
end

local function f(x)
    return x*255/15--math.floor((-480*(0.83^(x+3.08)))+271)
end

local function setPalette()
    for i=0,15 do
        term.setPaletteColor(2^i, colors.packRGB(f(i)/255,f(i)/255,f(i)/255))
    end
end

local function resetPalette()
    for i=0,15 do
        local r, g, b = term.nativePaletteColor(2^i)
        term.setPaletteColor(2^i, colors.packRGB(r,g,b))
    end
    term.setPaletteColor(colors.black,colors.packRGB(0,0,0))
    term.setPaletteColor(colors.red,colors.packRGB(1,0,0))
    term.setPaletteColor(colors.yellow,colors.packRGB(1,1,0))
    term.setPaletteColor(colors.green,colors.packRGB(0,1,0))    
end

return {
    densityToCol = densityToCol,
    PixelSize = PixelSize,
    drawFromArray1D = drawFromArray1D,
    drawFromArray2D = drawFromArray2D,
    resetPalette = resetPalette,
    setPalette = setPalette
}