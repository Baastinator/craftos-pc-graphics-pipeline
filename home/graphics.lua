-- imports

local Grid = import("grid")
local draw = import("draw")
local Shader = import("shader")
import("vec3")
--import("vec2")

-- globals

local res = {}
local tres = {}
local key
local debugMode = false
local gameLoop = true
local FPS = 60

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
    Shader.vertArray.list = {
        vec3(-30,-30,-30),
        vec3(30,-30,-30),
        vec3(-30,30,-30),
        vec3(30,30,-30),
        vec3(-30,-30,30),
        vec3(30,-30,30),
        vec3(-30,30,30),
        vec3(30,30,30)
    }
end

local function setIndices()
    Shader.indArray.list = {
        vec3(1,2,3),
        vec3(2,4,3),

        vec3(2,4,6),
        vec3(6,8,4),
        
        vec3(4,3,8),
        vec3(3,8,7),
        
        vec3(1,2,6),
        vec3(6,5,1),
        
        vec3(5,7,1),
        vec3(1,3,7),

        vec3(6,5,8),
        vec3(8,5,7),
    }
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
    --Shader.renderPolygons(Grid)
    -- debugLog(res,"res")
end

local function Update()
    Grid.init(res.x,res.y)
    -- Shader.renderVertices(Grid)
    draw.drawFromArray2D(0,0,Grid)
    Shader.renderWireframe(Grid)
    Shader.model.rot = Shader.model.rot + vec3(1,1,1)
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
    end
    Closing()
end

-- execution

parallel.waitForAny(main,userInput)
