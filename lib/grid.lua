--imports
vector = import("vector")
mathb = import("mathb")

--globals
local grid = {}
local wallColor = 2^7

--functions

local function init(X, Y)
    for y=1,Y do
        grid[y] = {}
        for x=1,X do
            grid[y][x] = {lightLevel=0, velocity=vector.new(0,0),wall=false}
            if y == 1 or y == Y or x == 1 or x == X then
                grid[y][x].wall = true
                grid[y][x].lightLevel = 2
            end
        end
    end
end

local function grabSection(X,Y,width,height)
    local Ot = {}
    if height == 1 then
        for i=1,width do
            Ot[i] = grid[Y][X+i-1]
        end
    else
        for y=1,height do
            Ot[y] = {}
            for x=1,width do
                Ot[y][x] = grid[y+Y-1][x+X-1]
            end
        end
    end
    return Ot
end

local function GetlightLevel(X,Y)
    return grid[Y][X].lightLevel
end

local function SetlightLevel(X,Y,Value)
    if Value == 2 then
        grid[Y][X].lightLevel = 2
        grid[Y][X].wall = true
    elseif grid[Y][X].wall then
        grid[Y][X].lightLevel = 2
        return false
    else
        grid[Y][X].lightLevel = Value
        return true
    end
end

local function GetVelocity(X,Y)
    return grid[Y][X].velocity
end

local function SetVelocity(X,Y,VectorInput)
    grid[Y][X].velocity = VectorInput
end

--unused in pipeline (for now)
local function spreadGlobal(res)
    local oldGrid = grid
    for y=2,res.y-1 do
        for x=2,res.x-1 do
            local nearDens = {}
            if y+1 ~= res.y then --up
                if oldGrid[y+1][x].lightLevel <= 1 then
                    nearDens.N = oldGrid[y+1][x].lightLevel
                end
            end
            if x-1 ~= 1 then --left
                if oldGrid[y][x-1].lightLevel <= 1 then
                    nearDens.E = oldGrid[y][x+1].lightLevel
                end
            end
            if y-1 ~= 1 then --down
                if oldGrid[y-1][x].lightLevel <= 1 then
                    nearDens.S = oldGrid[y-1][x].lightLevel
                end
            end
            if x-1 ~= 1 then --left
                if oldGrid[y][x-1].lightLevel <= 1 then
                    nearDens.W = oldGrid[y][x-1].lightLevel
                end
            end
            do-- COMMENTED FOR PERFORMANCE REASONS
                -- if x+1 ~= res.x or y+1 ~= res.y then
                --     if oldGrid[y+1][x+1].lightLevel <= 1 then
                --         table.insert(nearDens,oldGrid[y+1][x+1].lightLevel)
                --     end
                -- end
                -- if x-1 ~= 1 or y+1 ~= res.y  then
                --     if oldGrid[y+1][x-1].lightLevel <= 1 then
                --         table.insert(nearDens,oldGrid[y+1][x-1].lightLevel)
                --     end
                -- end
                -- if x+1 ~= res.x or y-1 ~= 1 then
                --     if oldGrid[y-1][x+1].lightLevel <= 1 then
                --         table.insert(nearDens,oldGrid[y-1][x+1].lightLevel)
                --     end
                -- end
                -- if x-1 ~= 0 or y-1 ~= 1 then
                --     if oldGrid[y-1][x-1].lightLevel <= 1 then
                --         table.insert(nearDens,oldGrid[y-1][x-1].lightLevel)
                --     end
                -- end
            end
            local vectorTemp = GetVelocity(x,y)
            --local file = fs.open("1/home/debug/vectors.txt","w")
            --file.write(textutils.serialise({y=y,x=x,den=oldGrid[y][x].lightLevel,nDen=nearDens}))
            --file.close()

            do --velocity thingy 
                -- if x-1 ~= 1 then --left
                --     if oldGrid[y][x-1].lightLevel <= 1 then
                --         vectorTemp.x = vectorTemp.x + math.abs(oldGrid[y][x].lightLevel-nearDens.E)
                --     end
                -- end
                -- if x-1 ~= 1 then --left
                --     if oldGrid[y][x-1].lightLevel <= 1 then
                --         vectorTemp.x = vectorTemp.x - math.abs(oldGrid[y][x].lightLevel-nearDens.W)
                --     end
                -- end
                -- if y+1 ~= res.y then --up
                --     if oldGrid[y+1][x].lightLevel <= 1 then
                --         vectorTemp.y = vectorTemp.y + math.abs(oldGrid[y][x].lightLevel-nearDens.N)
                --     end
                -- end
                -- if y-1 ~= 1 then --down
                --     if oldGrid[y-1][x].lightLevel <= 1 then
                --         vectorTemp.y = vectorTemp.y - math.abs(oldGrid[y][x].lightLevel-nearDens.S)
                --     end
                -- end
                --SetVelocity(x,y,vectorTemp)
            end
            SetlightLevel(x,y,mathb.average(nearDens))
        end
    end
end	

local function fill(X,Y,W,H,D)
    for y=1,H do
        for x=1,W do
            SetlightLevel(X+x-1,Y+y-1,D)
        end
    end
end



return {
    GetVelocity = GetVelocity,
    SetVelocity = SetVelocity,
    fill = fill,
    spreadGlobal = spreadGlobal,
    wallColor = wallColor,
    GetlightLevel = GetlightLevel,
    SetlightLevel = SetlightLevel,
    grabSection = grabSection,
    grid = grid,
    init = init
}
