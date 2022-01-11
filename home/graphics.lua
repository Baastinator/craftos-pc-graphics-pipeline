-- imports

local Grid = import("grid")
local draw = import("draw")
local Shader = import("shader")
local paint = import("paint")
import("shapes")
import("vec3")
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


local function setVertices()
    Shader.vertArray.list = tetrahedra.ver
end

local function setIndices()
    Shader.indArray.list = tetrahedra.ind
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
    setVertices()
    setIndices()
    Shader.model.sca = vec3(2,2,2)
    --paint.drawLine(vec3(30,30,30),vec3(60,60,60),1,Grid)
    --Shader.renderPolygons(Grid)
    -- debugLog(res,"res")
end

local function Update()
    Grid.init(res.x,res.y)
        Shader.model.rot = Shader.model.rot + vec3(
            10,
            10*math.cos(framesElapsed*math.pi/10),
            10*math.cos(framesElapsed*math.pi/10+math.pi/3)
        )
    Shader.renderVertices(Grid)
    draw.drawFromArray2D(0,0,Grid)
    Shader.renderWireframe(Grid)
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
        Update()
        sleep(1/FPS)
        framesElapsed = framesElapsed + 1;
    end
    Closing()
end

-- execution

parallel.waitForAny(main,userInput)
