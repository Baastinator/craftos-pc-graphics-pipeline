-- imports

local Grid = import("grid")
local draw = import("draw")
local Shader = import("shader")
local paint = import("paint")
import("meshes")
import("vec3")
import("body")
--import("vec2")

-- globals

local res = {}
local tres = {}
local key
local debugMode = false
local gameLoop = true
local FPS = 200
local framesElapsed = 0

local sigma = 10
local beta = 8/3
local ro = 10

local yAngle = 0

-- side functions

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
    tres.x, tres.y = term.getSize(1)
    res.x = math.floor(tres.x / draw.PixelSize)
    res.y = math.floor(tres.y / draw.PixelSize)
    Shader.setRes(res)
    Grid.init(res.x,res.y)
    term.clear()
    term.setGraphicsMode(1)
    draw.setPalette()
    term.drawPixels(0,0,1,tres.x,tres.y)
end

local function Start()
    Shader.cameraTransport.rot = vec3(-20)
    Shader.cameraTransport.tra = vec3(0,60,-200)
    Shader.insertBodies({Body(nil,nil,{tra=vec3(0,0,0)}),MakeDiamond(10)})
    Shader.SetBodyTransform(1,"sca",vec3(4,4,4))
    Shader.SetBodyTransform(2,"sca",vec3(2,2,2))
    --paint.drawLine(vec3(30,30,30),vec3(60,60,60),1,Grid)
    -- debugLog(res,"res")
end

local function PreUpdate()
    Grid.init(res.x,res.y)
end

local function Update()
    Shader.SetBodyTransform(2,"sca",vec3(2,2,2))
    -- for i=-24,70 do
    --     paint.drawLine(vec3(200,200+i,0),vec3(600,200+i,0),0.5,Grid)
    -- end
end

local function Render()
    -- Shader.renderVertices(Grid)
    Shader.renderWireframe(Grid, 1)
    draw.drawFromArray2D(0,0,Grid)
    --Shader.renderPolygons(Grid)
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
end

-- main structure

local function main()
    Init()
    Start()
    while gameLoop do
        PreUpdate()
        Update()
        Render()
        sleep(1/FPS)
        framesElapsed = framesElapsed + 1;
    end
    Closing()
end

-- execution

parallel.waitForAny(main,userInput)
