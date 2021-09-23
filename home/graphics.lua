-- imports

local Grid = import("grid")
local draw = import("draw")

-- globals

local res = {}
local key
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

-- main functions

local function Init()
    res.t = {}
    res.t.x, res.t.y = term.getSize(1)
    res.x = math.floor(res.t.x / draw.PixelSize)
    res.y = math.floor(res.t.y / draw.PixelSize)
    Grid.init(res.x,res.y)
    term.clear()
    term.setGraphicsMode(1)
    draw.setPalette()
    term.drawPixels(0,0,draw.densityToCol(0.0, false),res.t.x,res.t.y)
end

local function Start()
    
end

local function Update()
    draw.drawFromArray2D(0,0,Grid)
end

local function Closing()
    term.clear()
    term.setGraphicsMode(0)
    draw.resetPalette()
    term.clear()
    term.setCursorPos(1,1)
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
