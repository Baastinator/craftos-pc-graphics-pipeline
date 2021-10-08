local vertArray = import("vertexArray")
local indArray = import("indiceArray")
import("vec2")
import("vec3")
import("vec4")
import("mat4")

local cameraVector = vec3(0,0,-1)
local lightSource = vec3(1,0,1)

local res

local projections = {
    ProjMatrix = function(l,r,t,b,n,f)
        local m = mat4()
        m[1] = {(2*n)/(r-l) ,0           ,(r+l)/(r-l)  ,0             }
        m[2] = {0           ,(2*n)/(t-b) ,(t+b)/(t-b)  ,0             }
        m[3] = {0           ,0           ,-(f+n)/(f-n) ,-(2*f*n)/(f-n)}
        m[4] = {0           ,0           ,-1           ,0             }
        return m
    end,
    ScalMatrix = function (scalVec3)
        local m = mat4().identity()
        m:set(1,1,scalVec3.x)
        m:set(2,2,scalVec3.y)
        m:set(3,3,scalVec3.z)
        return m
    end,
    TranMatrix = function ( traVec3 )
        local m = mat4().identity()
        m:set(4,1,traVec3.x)
        m:set(4,2,traVec3.y)
        m:set(4,3,traVec3.z)
        return m
    end,
    RotaMatrix = function ( eulerVec3 )
        eulerVec3 = eulerVec3 * (math.pi/180)
        local sx, sy, sz = math.sin(eulerVec3.x),math.sin(eulerVec3.y),math.sin(eulerVec3.z)
        local cx, cy, cz = math.cos(eulerVec3.x),math.cos(eulerVec3.z),math.cos(eulerVec3.z)
        local m = mat4()
        m[1] = {cy * cz                     ,-cy * sz                    ,sy       ,0}
        m[2] = {(sx * sy * cz) + (cx * sz)  ,(-sx * sy * sz) + (cx * cz) ,-sx * cy ,0}
        m[3] = {(-cx * sy * cz) + (sx * sz) ,(cx * sy * sz) + (sx * cz)  ,cx * cy  ,0}
        m[4] = {0                           ,0                           ,0        ,1}
        return m
    end
}

local function project(vec3input)
    local input = vec3input:vec4()
    local proj = projections.ProjMatrix(-res.x/2,res.x/2,-res.y/2,res.y/2,10,100)
    local scal = projections.ScalMatrix(vec3(1,1,1))
    local tran = projections.TranMatrix(vec3(0,0,0))
    local rota = projections.RotaMatrix(vec3(0,0,0))
    local camRot = projections.TranMatrix(vec3(0,0,0))
    local camTra = projections.TranMatrix(vec3(0,0,10))
    local cam = camTra * camRot
    local model = tran * rota * scal
    local PerspectiveMatrix = proj * cam * model
    local projectedVector = PerspectiveMatrix * input
    return projectedVector
end

local function setRes(Res)
    res = Res
end

local function renderVertices(grid)
    local debugT = {}
    for i, v in ipairs(vertArray.list) do
        debugT[i] = {}
        debugT[i].v = v
        local pos = project(v)
        debugT[i].pos = pos
        grid.SetlightLevel(pos.x,pos.y,1)
    end
    -- debugLog(debugT,"rendvert")
end

local function renderWireframe(grid)
    
end

local function renderPolygons(grid)
    -- local polyList = {}
    -- for i, v in ipairs(indArray.list) do
    --     --realisePolys
    --     polyList[i] = {}
    --     local currPoly = {}
    --     -- calculate and save poly vectors
    --     currPoly.a = vec3.subtract(vertArray.list[v.y],vertArray.list[v.x])
    --     currPoly.b = vec3.subtract(vertArray.list[v.z],vertArray.list[v.y])
    --     currPoly.c = vec3.subtract(vertArray.list[v.x],vertArray.list[v.z])
    --     polyList[i].raw = currPoly
    --     polyList[i].raw.aStart = vertArray.list[v.x]
        
    --     -- project poly vectors into 2d
    --     polyList[i].proj = {}
    --     polyList[i].proj.a = project(polyList[i].raw.a)
    --     -- polyList[i].proj.aStart = project(polyList[i].raw.aStart)
    --     polyList[i].proj.b = project(polyList[i].raw.b)
    --     polyList[i].proj.c = project(polyList[i].raw.c)
        
    --     --rasterization values
    --     local rast = {}
    --     local proj = {
    --         a = project(polyList[i].raw.a),
    --         aStart = project(polyList[i].raw.aStart),
    --         b = project(polyList[i].raw.b),
    --         c = project(polyList[i].raw.c)
    --     }
    --     rast.am = proj.a.x / proj.a.y
    --     rast.bm = proj.b.x / proj.b.y
    --     rast.cm = proj.c.x / proj.c.y
    --     rast.as = project(vertArray.list[v.x])
    --     rast.bs = vec2.add(rast.as,proj.a)
    --     rast.cs = vec2.add(rast.bs,proj.b)
    --     polyList[i].rast = rast
    --     rast = nil
    --     proj = nil

    --     local cInv = vec3.scale(currPoly.c,-1)
    --     polyList[i].normal = vec3.normalise(vec3.cross(cInv,currPoly.a))
    --     if vec3.dot(polyList[i].normal,cameraVector) < 0 then
    --         polyList[i].rendered = true
    --         polyList[i].lighting = (vec3.dot(
    --             vec3.normalise(polyList[i].normal),
    --             vec3.normalise(lightSource)
    --         ) + 1.5 ) / 2.5
    --     else
    --         polyList[i].rendered = false
    --     end
    --     if polyList[i].rendered == false then
    --         polyList[i] = { rendered = false }
    --     end
    --     debugLog(polyList,"polys")
    --     debugLog(currPoly,"currPoly")
    -- end
    -- local localGrid = {}
    -- for i, v in ipairs(grid.grid) do
    --     localGrid[i] = {}
    --     for i2, v2 in ipairs(grid.grid[i]) do
    --         localGrid[i][i2] = 0
    --     end
    -- end
end

return {
    projections = projections,
    setRes = setRes,
    renderPolygons = renderPolygons,
    renderVertices = renderVertices,
    project = project,
    vertArray = vertArray,
    indArray = indArray
}
