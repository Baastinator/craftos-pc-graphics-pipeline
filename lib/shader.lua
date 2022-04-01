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

local recalculate = false;
local recalculateWhat = {
    camrot = false,
    camtra = false,
    modrot = false,
    modtra = false,
    modsca = false,
    model = false,
    camera = false,
    proj = false,
}

local projections = {
    PersMatrix = function(l,r,t,b,n,f)
        local m = mat4()
        m[1]  = (2*n)/(r-l)  m[3]  = (r+l)/(r-l) 
        m[6]  = (2*n)/(t-b)  m[7]  = (t+b)/(t-b)
        m[11] = -(f+n)/(f-n) m[12] = -(2*f*n)/(f-n)
        m[15] = -1
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
        m[1] = cz * cy                     m[2]  = -cy * sz                    m[3]  = sy
        m[5] = (sx * sy * cz) + (cx * sz)  m[6]  = (-sx * sy * sz) + (cx * cz) m[7]  = -sx * cy
        m[9] = (-cx * sy * cz) + (sx * sz) m[10] = (cx * sy * sz) + (sx * cz)  m[11] = cx * cy
        return m
    end
}

local matrices = {}

local function calculatePers()
    matrices.pers = projections.PersMatrix(-res.x/2,res.x/2,-res.y/2,res.y/2,res.x/2,-res.x/2)
end

local calculateMod = {
    rot = function(Id)
        matrices[Id].rota = projections.RotaMatrix(bodies.list[Id].model.rot)
    end,
    sca = function(Id)
        matrices[Id].scal = projections.ScalMatrix(bodies.list[Id].model.sca)
    end,
    tra = function(Id)
        matrices[Id].tran = projections.TranMatrix(bodies.list[Id].model.tra)
    end
}

local calculateCamMat = function()
    matrices.cam = matrices.camRot * matrices.camTra
end

local calculateCam = {
    tra = function()
        matrices.camTra = projections.TranMatrix(cameraTransport.tra)
    end,
    rot = function()
        matrices.camRot = projections.RotaMatrix(cameraTransport.rot)
    end,
}

local function calculateModel(Id)
    matrices[Id].model = matrices[Id].tran * matrices[Id].rota * matrices[Id].scal
end

local function calculateProj(Id)
    matrices[Id].ProjectionMatrix = matrices.pers * matrices.cam * matrices[Id].model
end


local function calcMatrixFull(Id)
    calculatePers()
    calculateMod.sca(Id)
    calculateMod.rot(Id)
    calculateMod.tra(Id)
    calculateCam.tra()
    calculateCam.rot()
    calculateCamMat()
    calculateModel(Id)
    calculateProj(Id)
end

local function calcMatrixSmart(ID)
    local T = recalculateWhat
    if (T.camrot) then
        calculateCam.rot()
        T.camrot = false
        T.camera = true
    end
    if (T.camtra) then
        calculateCam.tra()
        T.camtra = false
        T.camera = true
    end
    if (T.modrot) then
        calculateMod.rot(ID)
        T.modrot = false
        T.model = true
    end
    if (T.modsca) then
        calculateMod.sca(ID)
        T.modsca = false
        T.model = true
    end
    if (T.modtra) then
        calculateMod.tra(ID)
        T.modtra = false
        T.model = true
    end
    if (T.camera) then
        calculateCam.full()
        T.camera = false
        T.proj = true
    end
    if (T.model) then
        calculateModel(ID)
        T.model = false
        T.proj = true
    end
    if (T.proj) then
        calculateProj(ID)
        T.proj = false
    end
    recalculate = false
end

local function project(vec3input,bodyID)
    local input = vec3input:vec4()
    if (matrices[bodyID].ProjectionMatrix == nil) then
        calcMatrixFull(bodyID)
    end
    if (recalculate) then
        calcMatrixSmart(bodyID)
    end
    matrices.projectedVector = matrices[bodyID].ProjectionMatrix * input
    local projectedVector3 = vec3(matrices.projectedVector.x,matrices.projectedVector.y,matrices.projectedVector.z)/matrices.projectedVector.w
    return projectedVector3
end

local function insertBodies(range)
    for i, v in ipairs(range) do
        local id = bodies.add(v)
        matrices[id] = {}
        calculateMod.tra(id)
        calculateMod.sca(id)
        calculateMod.rot(id)
    end
    -- debugLog(clean(bodies),"bodies lol")
end

local function CamKeyToRecalcKey(key)
    if (key == "tra") then return "camtra"
    elseif (key == "rot") then return "camrot"
    else error("CamKeyToRecalcKey: bad input");
    end
end


local function SetCameraTransform(key, value)
    cameraTransport[key] = value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[CamKeyToRecalcKey(key)] = true
end

local function AddCameraTransform(key, value)
    cameraTransport[key] = cameraTransport[key] + value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[CamKeyToRecalcKey(key)] = true
end

local function GetCameraTransform(key)
    return cameraTransport[key]
    
end

local function BodyKeyToRecalcKey(key)
    if (key == "tra") then return "modtra"
    elseif (key == "rot") then return "modrot"
    elseif (key == "sca") then return "modsca"
    else error("BodyKeyToRecalcKey: bad input");
    end
end

local function AddBodyTransform(ID,key,value)
    bodies.list[ID].model[key] = bodies.list[ID].model[key] + value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[BodyKeyToRecalcKey(key)] = true
end

local function SetBodyTransform(ID,key,value)
    bodies.list[ID].model[key] = value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[BodyKeyToRecalcKey(key)] = true
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
    end
    debugLog(Dlog,"renderVert")
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

local function renderPolygons(grid, LL)
    local function Lines(a, b) 
        local T = {}
        T.minX = math.min(a.x, b.x)
        if T.minX == a.x then
            -- if start is small, start becomes min and end becomes max
            T.minY = a.y
            T.minZ = a.z
            T.maxX = b.x
            T.maxY = b.y
            T.maxZ = b.z
        else
            -- otherwise, end becomes min and start becomes max 
            -- y ignored, cool ideas
            T.minY = b.y
            T.minZ = b.z
            T.maxX = a.x
            T.maxY = a.y
            T.maxZ = a.z
        end
        T.xDiff = T.maxX - T.minX
        T.yDiff = T.maxY - T.minY
        T.zDiff = T.maxZ - T.minZ
        
        if T.xDiff >= math.abs(T.yDiff) then
            T.base = "x"
            T.ySlope = T.yDiff / T.xDiff
            T.zSlope = T.zDiff / T.xDiff
        else
            T.base = "y"
            T.xSlope = T.xDiff / T.yDiff
            T.zSlope = T.zDiff / T.yDiff
        end
        return T
    end
    function interpolate(S, E, y)
        return S.x + (E.x - S.x) * (y - S.y) / (E.y - S.y)
        --X(y) = xS + (xE - xS) * (y - yS) / (yE - yS)
    end
    local function sortPoints(a,b,c) 
        if a.y > b.y and a.y > c.y then
            if b.y > c.y then
            
            elseif b.y == c.y then
                if b.x > c.x then

                else
                    b, c = c, b
                end
            else
                b, c = c, b
            end
        elseif a.y == b.y then
            if a.x > b.x then

            else
                a, b = b, a
            end
        elseif a.y == c.y then
            if a.x > c.x then

            else
                a, b = b, a
            end
        elseif a.y < b.y then
            if b.y < c.y then
                a, c = c, a
            elseif c.y < a.y then
                a, b = b, a
            else
                a, b, c = b, c ,a
            end
        elseif a.y < c.y then
            if a.y < b.y then
                
            end
        end
    end
    local ab, bc, ca
    for bi, bv in ipairs(bodies.list) do
        for ii, iv in ipairs(bv.indArray.list) do
            local currPoly = {}
            currPoly.a = project(bv.verArray.list[iv.x],bi)
            currPoly.b = project(bv.verArray.list[iv.y],bi)
            currPoly.c = project(bv.verArray.list[iv.z],bi)

            currPoly.a = vec3(grid.NDCtoScreen(currPoly.a.x,currPoly.a.y,currPoly.a.z,res))
            currPoly.b = vec3(grid.NDCtoScreen(currPoly.b.x,currPoly.b.y,currPoly.b.z,res))
            currPoly.c = vec3(grid.NDCtoScreen(currPoly.c.x,currPoly.c.y,currPoly.c.z,res))

            currPoly.lines = {}

            currPoly.lines.ab = Lines(currPoly.a, currPoly.b)
            currPoly.lines.bc = Lines(currPoly.b, currPoly.c)
            currPoly.lines.ca = Lines(currPoly.c, currPoly.a)

            -- points topdown
            -- if same y, left first


            local a, b, c = sortPoints(currPoly.a, currPoly.b, currPoly.c)



            ab = currPoly.lines.ab
            bc = currPoly.lines.bc
            ca = currPoly.lines.ca

            if (ab.base == "x") then
                for i=0,ab.xDiff do
                    local reach = 1 
                end
            else
                for i=0,ab.yDiff do

                end
            end

            -- debugLog(currPoly,"currPoly")
        end
    end
end

return {
    renderPolygons = renderPolygons,
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
    insertBodies = insertBodies,
    GetCameraTransform = GetCameraTransform,
    SetCameraTransform = SetCameraTransform,
    AddCameraTransform = AddCameraTransform
}
