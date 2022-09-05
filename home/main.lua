-- imports

package.path = "/?.lua;/lib/?.lua"

local Grid = require"grid"
local draw = require"draw"
local Shader = require"shader"
local mathb = require"mathb"
local paint = require"paint"
local la = require"linalg"
require"meshes"
require"perlin"
require"body"
require"List"
require"tblclean"
--import("vec2")

-- globals

debug = {}

local res = {}
local tres = {}
local key
local debugMode = false
local gameLoop = true
local FPS = 60
local framesElapsed = 0

local Time
local time = {}

-- side functions

local mesh = function(size)
    local rand = {}
    for i=1,7 do 
        rand[i] = 10*math.random();
    end 
    local function Noise(x,z)
        
        return 
        -- 10*math.sin(x*math.pi/60)
        -- 20*math.exp(-((x/50)^2+(z/50)^2))
        -- math.max(
            100*perlin:noise(x/500,z/500,rand[7]) +
            50*perlin:noise(x/250,z/250,rand[6]) +
            20*perlin:noise(x/100,z/100,rand[5]) +
            10*perlin:noise(x/50,z/50,rand[4]) +
            5*perlin:noise(x/25,z/25,rand[3]) +
            2*perlin:noise(x/10,z/10,rand[2]) +
            1*perlin:noise(x/5,z/5,rand[1])
        --     ,0
        -- ) 
    end
    local mesh = makeFloorMesh(100,size,function(x,z) return -Noise(x,z) end)
    return mesh
end

local function userInput()
    local event, is_held
    while true do
---@diagnostic disable-next-line: undefined-field
        event, key, is_held = os.pullEvent("key")
        if key == keys.space then
            gameLoop = false 
        end
    end
end

local function MakeDiamond(count)
    local ver = diamond.ver(count)
    local ind = diamond.ind(count)
    return Body(ver, ind)
end

-- main functions

local function Init()
    Time =  ccemux.milliTime()
    tres.x, tres.y = term.getSize(1)
    res.x = math.floor(tres.x / draw.PixelSize)
    res.y = math.floor(tres.y / draw.PixelSize)
    Shader.setRes(res)
    Grid.init(res.x,res.y)
    term.clear()
    term.setGraphicsMode(2)
    draw.setPalette()
    term.drawPixels(0,0,1,tres.x,tres.y)
    if (debugMode) then
        time.Init = (ccemux.milliTime() - Time)/1000
        Time = ccemux.milliTime()
    end
end

local function Start()
    Shader.cameraTransport.rot = la.vec{0,0,0}
    Shader.cameraTransport.tra = la.vec{0,0,-100}
    local lBodies = {
        MakeDiamond(4)
    }
    Shader.insertBodies(lBodies)
    Shader.SetBodyTransform(1,"sca",la.vec{1,1,1})
    Shader.SetBodyTransform(1,"tra",la.vec{0,0,0})
    Shader.SetBodyTransform(1,"rot",la.vec{-30})


    if (debugMode) then
        time.PreUpdate = {}
        time.Update = {}
        time.Render = {}
        time.Start = (ccemux.milliTime() - Time)/1000
        Time = ccemux.milliTime()
    end
end 
    
    
local function PreUpdate()
    Grid.init(res.x,res.y)
    if (debugMode) then
        time.PreUpdate[framesElapsed+1] = (ccemux.milliTime() - Time)/1000
        Time = ccemux.milliTime()
    end
end

local function Update()
    if (debugMode) then
        time.Update[framesElapsed+1] = (ccemux.milliTime() - Time)/1000
        Time = ccemux.milliTime()
        if (framesElapsed >= 20) then
            gameLoop = false
        end
    end
end

local function Render()
    -- Shader.renderVertices(Grid)
    Shader.renderWireframe(Grid, 1)
    -- Shader.renderPolygons(Grid, 1)
    draw.drawFromArray2D(0,0,Grid)
    --Shader.renderPolygons(Grid)
    if (debugMode) then
        time.Render[framesElapsed+1] = (ccemux.milliTime() - Time)/1000
        Time = ccemux.milliTime()
    end
end

local function Closing()
    term.clear()
    term.setGraphicsMode(0)
    draw.resetPalette()
    if debugMode then
    else
        term.clear()
        term.setCursorPos(1,1)
    end

    if (debugMode) then

        time.preUpdateSum = 0    
        for i,v in ipairs(time.PreUpdate) do
            time.preUpdateSum = time.preUpdateSum + v
        end
        time.preUpdateAverage = mathb.round(time.preUpdateSum / #time.PreUpdate,3)
        time.RenderSum = 0    
        for i,v in ipairs(time.Render) do
            time.RenderSum = time.RenderSum + v
        end
        time.RenderAverage = mathb.round(time.RenderSum / #time.Render,3)
        time.UpdateSum = 0    
        for i,v in ipairs(time.Update) do
            time.UpdateSum = time.UpdateSum + v
        end
        time.UpdateAverage = mathb.round(time.UpdateSum / #time.Update,3)
        time.UpdateSum, time.RenderSum, time.preUpdateSum = nil, nil, nil
        time.Update, time.Render, time.PreUpdate = nil, nil, nil
    end
end

-- main structure

local function main() 
    Init()
    Start()
    while gameLoop do
        PreUpdate()
        Update()
        Render()
        sleep(0)
        framesElapsed = framesElapsed + 1;
    end
    Closing()
end

-- execution
local ok, err = pcall(parallel.waitForAny,main,userInput)
if not ok then 
    Closing()
    printError((function()
        local string = ""
        for i = 1,15 do string = string.."\n" end
        return string
    end)()..textutils.serialize(clean(debug)).."\n"..err)
end