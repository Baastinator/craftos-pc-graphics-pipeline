-- imports

local Grid = import("grid")
local draw = import("draw")
local Shader = import("shader")
local vec3 = import("vec3")
--local vec2 = import("vec2")

-- globals

local res = {}
local tres = {}
local key
local debugMode = false
local gameLoop = true
local FPS = 10

-- side functions

local function userInput()
    local event, is_held
    while true do
---@diagnostic disable-next-line: undefined-field
        event, key, is_held = os.pullEvent("key")
        if key == keys.right then
            gameLoop = false
        end
    end
end

local function setVertices()
    Shader.vertArray.list = {
        vec3.new(-0.5,-0.5,-0),
        vec3.new(0.5,-0.5,-0),
        vec3.new(-0.5,0.5,-0),
        vec3.new(0.5,0.5,-0)
    }
end

local function setIndices()
    Shader.indArray.list = {
        vec3.new(1,2,3),
        --vec3.new(2,3,4)
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
    Shader.renderVertices(Grid)
    Shader.renderPolygons(Grid)
    debugLog(res,"res")
    
end

local function Update()
    draw.drawFromArray2D(0,0,Grid)
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
