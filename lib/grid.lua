local grid = {}

local function init(X, Y)
    for y=1,Y do
        grid[y] = {}
        for x=1,X do
            grid[y][x] = {lightLevel=0,depth=math.huge}
        end
    end
end

local function GetlightLevel(X,Y)
    return grid[Y][X].lightLevel
end

local function SetlightLevel(X,Y,Z,Value)
---@diagnostic disable-next-line: undefined-field
    X = math.floor( (X+1) * table.getn(grid[1]) / 2)
---@diagnostic disable-next-line: undefined-field
    Y = math.floor( (Y+1) * table.getn(grid) / 2)
    debugLog({X=X,Y=Y,Z=Z,V=Value},"setLL")
    if Z < grid[Y][X].depth then
        grid[Y][X].lightLevel = Value
        grid[Y][X].depth = Z
    end 
end

local function fill(X,Y,W,H,L,D)
    for y=1,H do
        for x=1,W do
            SetlightLevel(X+x-1,Y+y-1,D,L)
        end
    end
end

return {
    fill = fill,
    GetlightLevel = GetlightLevel,
    SetlightLevel = SetlightLevel,
    grid = grid,
    init = init
}
