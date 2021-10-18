local vertArray = import("vertexArray")
local indArray = import("indiceArray")

import("vec2")
import("vec3")
import("vec4")
import("mat4")

local cameraVector = vec3(0,0,-1)
local lightSource = vec3(1,0,1)

local model = {
    rot = vec3(0,0,0),
    sca = vec3(1,1,1),
    tra = vec3(0,0,0)
}

cameraTransport = {
    rot = vec3(0,0,0),
    tra = vec3(0,0,-200)
}

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
        local sg, sb, sa = math.sin(eulerVec3.x),math.sin(eulerVec3.y),math.sin(eulerVec3.z)
        local cg, cb, ca = math.cos(eulerVec3.x),math.cos(eulerVec3.y),math.cos(eulerVec3.z)
        local m = mat4()
        -- m[1] = {ca*cb, (ca*sb*sg) - (sa*cg), (ca*sb*cg) + (sa*sg), 0}
        -- m[2] = {sa*cb, (sa*sb*sg) + (ca*cg), (sa*sb*cg) - (ca*sg), 0}
        -- m[3] = {-sb  , cb*sg           , cb*cg           , 0}
        m[1] = {ca * cb                     ,-cb * sa                    ,sb       ,0}
        m[2] = {(sg * sb * ca) + (cg * sa)  ,(-sg * sb * sa) + (cg * ca) ,-sg * cb ,0}
        m[3] = {(-cg * sb * ca) + (sg * sa) ,(cg * sb * sa) + (sg * ca)  ,cg * cb  ,0}
        m[4] = {0                           ,0                           ,0        ,1}
        return m
    end
}

local function project(vec3input)
    local input = vec3input:vec4()
    local proj = projections.ProjMatrix(-res.x/2,res.x/2,-res.y/2,res.y/2,-res.x/2,res.x/2)
    local scal = projections.ScalMatrix(model.sca)
    local tran = projections.TranMatrix(model.tra)
    local rota = projections.RotaMatrix(model.rot)
    local camRot = projections.RotaMatrix(cameraTransport.rot)
    local camTra = projections.TranMatrix(cameraTransport.tra)
    local cam = camRot * camTra 
    local model = tran * rota * scal
    local PerspectiveMatrix = proj * cam * model
    local projectedVector = PerspectiveMatrix * input
    local projectedVector3 = vec3(projectedVector.x,projectedVector.y,projectedVector.z)/projectedVector.w
    return projectedVector3
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
        grid.SetlightLevel(pos.x,pos.y,pos.z,1)
    end
    -- debugLog(debugT,"rendvert")
end

local function renderWireframe(grid)
    local polyList = {}
    for i, v in ipairs(indArray.list) do
        polyList[i] = {}
        local currPoly = {}
        currPoly.a = project(vertArray.list[v.x])
        currPoly.b = project(vertArray.list[v.y])
        currPoly.c = project(vertArray.list[v.z])
        currPoly.a = vec3(grid.NDCtoScreen(currPoly.a.x,currPoly.a.y,currPoly.a.z,res))
        currPoly.b = vec3(grid.NDCtoScreen(currPoly.b.x,currPoly.b.y,currPoly.b.z,res))
        currPoly.c = vec3(grid.NDCtoScreen(currPoly.c.x,currPoly.c.y,currPoly.c.z,res))
        paintutils.drawLine(currPoly.a.x*2, currPoly.a.y*2, currPoly.b.x*2, currPoly.b.y*2, 2^15)
        paintutils.drawLine(currPoly.b.x*2, currPoly.b.y*2, currPoly.c.x*2, currPoly.c.y*2, 2^15)
        paintutils.drawLine(currPoly.c.x*2, currPoly.c.y*2, currPoly.a.x*2, currPoly.a.y*2, 2^15)
        -- debugLog({currPoly,"a"},"polies"..i)
    end
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
    cameraTransport = cameraTransport,
    renderWireframe = renderWireframe,
    model = model,
    projections = projections,
    setRes = setRes,
    renderPolygons = renderPolygons,
    renderVertices = renderVertices,
    project = project,
    vertArray = vertArray,
    indArray = indArray
}
