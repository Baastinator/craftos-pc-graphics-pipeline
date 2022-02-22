-- imports

local Grid = import("grid")
local draw = import("draw")
local Shader = import("shader")
local paint = import("paint")
import("meshes")
import("perlin")
import("vec3")
import("body")
import("tblclean")
--import("vec2")

-- globals

local res = {}
local tres = {}
local key
local debugMode = false
local gameLoop = true
local FPS = 60
local framesElapsed = 0

local time

-- side functions

local mesh = function()
    local rand = {}
    for i=1,7 do 
        rand[i] = 10*math.random();
    end 
    local function sin(a) return math.sin(a/20) end
    local function factorial(a)
        local product = 1
        for i = 1,a do
            product = product * i
        end
        return product
    end 
    local function sum(a)

        
        local sum = 0
        local n = 100
        for i=1,n do
            sum = sum + ((math.log(2)*(a/10))^i)/factorial(i)
        end
        return sum
    end
    local function Noise(x,z)
        
        x = -x
        return (2/30)^(x)
        + 30
        -- math.max(
        --     100*perlin:noise(x/500,z/500,rand[7]) +
        --     50*perlin:noise(x/250,z/250,rand[6]) +
        --     20*perlin:noise(x/100,z/100,rand[5]) +
        --     10*perlin:noise(x/50,z/50,rand[4]) +
        --     5*perlin:noise(x/25,z/25,rand[3]) +
        --     2*perlin:noise(x/10,z/10,rand[2]) +
        --     1*perlin:noise(x/5,z/5,rand[1])
        --     - - (x*x+z*z)/5000
        --     ,0
        -- ) 
    end
    local mesh = makeFloorMesh(500,100,function(x,z) return -Noise(x,z) end)
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
    time = os.time()
    
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
    Shader.cameraTransport.rot = vec3(0,0,0)
    Shader.cameraTransport.tra = vec3(0,0,-500)
    local lBodies = {
        mesh()
    --[[    Body({
            vec3(0,-10),
            vec3(10,15),
            vec3(-10,10)
        },{
            vec3(1,2,3)
        })]]
    }
    Shader.insertBodies(lBodies)
    --paint.drawLine(vec3(30,30,30),vec3(60,60,60),1,Grid)
    -- debugLog(res,"res")
    Shader.SetBodyTransform(1,"sca",vec3(1,1,1))
    Shader.SetBodyTransform(1,"tra",vec3(0,0,0))
    Shader.SetBodyTransform(1, "rot",vec3(-30))

end 

local function PreUpdate()
    Grid.init(res.x,res.y)
end

local function Update()
end

local function Render()
    if (framesElapsed % 100 == 0) then
    -- debugLog(framesElapsed,"yeet")
        -- Shader.renderVertices(Grid)
    Shader.renderWireframe(Grid, 1)
    Shader.renderPolygons(Grid, 1)
    draw.drawFromArray2D(0,0,Grid)
    end
    if (framesElapsed == 0) then
        local yeet = os.time()-time
        debugLog(yeet,"startup")
    end
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
        sleep(0)
        framesElapsed = framesElapsed + 1;
    end
    Closing()
end

-- execution

parallel.waitForAny(main,userInput)
