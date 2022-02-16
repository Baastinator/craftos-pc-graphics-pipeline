local Paint = import("paint")

import("vec2")
import("vec3")
import("vec4")
import("mat4")
import("List")
import("tblclean")

local cameraVector = vec3(0,0,-1)
local lightSource = vec3(1,0,1)

local bodies = List("Body")

local cameraTransport = {
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
        local sx, sy, sz = math.sin(eulerVec3.x),math.sin(eulerVec3.y),math.sin(eulerVec3.z)
        local cx, cy, cz = math.cos(eulerVec3.x),math.cos(eulerVec3.y),math.cos(eulerVec3.z)
        local m = mat4().identity()
        m[1] = {cz * cy                     ,-cy * sz                    ,sy       ,0}
        m[2] = {(sx * sy * cz) + (cx * sz)  ,(-sx * sy * sz) + (cx * cz) ,-sx * cy ,0}
        m[3] = {(-cx * sy * cz) + (sx * sz) ,(cx * sy * sz) + (sx * cz)  ,cx * cy  ,0}
        return m
    end
}

local function project(vec3input,bodyID)
    local input = vec3input:vec4()
    local temp = {}
    -- debugLog(clean({bodies,bID=bodyID}))
    temp.proj = projections.ProjMatrix(-res.x/2,res.x/2,-res.y/2,res.y/2,-res.x/2,res.x/2)
    temp.scal = projections.ScalMatrix(bodies.list[bodyID].model.sca)
    temp.tran = projections.TranMatrix(bodies.list[bodyID].model.tra)
    temp.rota = projections.RotaMatrix(bodies.list[bodyID].model.rot)
    temp.camRot = projections.RotaMatrix(cameraTransport.rot)
    temp.camTra = projections.TranMatrix(cameraTransport.tra)
    temp.cam = temp.camRot * temp.camTra 
    temp.model = temp.tran * temp.rota * temp.scal
    local PerspectiveMatrix = temp.proj * temp.cam * temp.model
    local projectedVector = PerspectiveMatrix * input
    local projectedVector3 = vec3(projectedVector.x,projectedVector.y,projectedVector.z)/projectedVector.w
    return projectedVector3
end

local function insertBodies(range)
    for i, v in ipairs(range) do
        bodies.add(v)
    end
    debugLog(clean(bodies),"bodies lol")
end

local function AddBodyTransform(ID,key,value)
    bodies.list[ID].model[key] = bodies.list[ID].model[key] + value
end

local function SetBodyTransform(ID,key,value)
    bodies.list[ID].model[key] = value
end

local function GetBodyTransform(ID,key)
    return bodies.list[ID].model[key]
end

local function setRes(Res)
    res = Res
end

local function renderVertices(grid)
    local Dlog = {}
    for i, body in ipairs(bodies.list) do
        for i2, v in ipairs(body.verArray.list) do
            local pos = project(v,i)
            grid.SetlightLevel(pos.x,pos.y,pos.z,1)
            if i==2 then
                Dlog[i2] = pos
            end
        end
        -- debugLog(Dlog,"renderVert")
    end
end

local function renderWireframe( grid, LL)
    for bi, bv in ipairs(bodies.list) do
        for i, v in ipairs(bv.indArray.list) do
            local currPoly = {}
            currPoly.a = project(bv.verArray.list[v.x],bi)
            currPoly.b = project(bv.verArray.list[v.y],bi)
            currPoly.c = project(bv.verArray.list[v.z],bi)
            currPoly.a = vec3(grid.NDCtoScreen(currPoly.a.x,currPoly.a.y,currPoly.a.z,res))
            currPoly.b = vec3(grid.NDCtoScreen(currPoly.b.x,currPoly.b.y,currPoly.b.z,res))
            currPoly.c = vec3(grid.NDCtoScreen(currPoly.c.x,currPoly.c.y,currPoly.c.z,res))
            Paint.drawLine(currPoly.a, currPoly.b, LL, grid)
            Paint.drawLine(currPoly.b, currPoly.c, LL, grid)
            Paint.drawLine(currPoly.c, currPoly.a, LL, grid)
        end
    end
end

return {
    AddBodyTransform = AddBodyTransform,
    SetBodyTransform = SetBodyTransform,
    GetBodyTransform = GetBodyTransform,
    cameraTransport = cameraTransport,
    renderWireframe = renderWireframe,
    projections = projections,
    setRes = setRes,
    renderVertices = renderVertices,
    project = project,
    bodies = bodies,
    insertBodies = insertBodies
}
