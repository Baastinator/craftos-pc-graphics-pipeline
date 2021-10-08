local grid = {}

local function init(X, Y)
    for y=1,Y do
        grid[y] = {}
        for x=1,X do
            grid[y][x] = {lightLevel=0,Depth=math.huge}
        end
    end
end

local function GetlightLevel(X,Y)
    return grid[Y][X].lightLevel
end

local function SetlightLevel(X,Y,Z,Value)
    if Z < grid[Y][X].Depth then
        grid[Y][X].lightLevel = Value
        grid[Y][X].Depth = Z
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
