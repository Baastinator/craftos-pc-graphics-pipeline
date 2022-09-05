local Paint = require("paint")
local List = require"List"
local la = require'linalg'

local cameraVector = la.vec{0,0,-1} 
local lightSource = la.vec{1,0,1}

local bodies = List("Body")

local cameraTransport = {
    rot = la.vec{0,0,0},
    tra = la.vec{0,0,-200}
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
        local m = la.mat(4,4)
        m[1]  = (2*n)/(r-l)  m[3]  = (r+l)/(r-l) 
        m[6]  = (2*n)/(t-b)  m[7]  = (t+b)/(t-b)
        m[11] = -(f+n)/(f-n) m[12] = -(2*f*n)/(f-n)
        m[15] = -1
        return m
    end,
    ScalMatrix = function (scalVec3)
        local m = la.mat().identity(4)
        m:set(1,1,scalVec3[1])
        m:set(2,2,scalVec3[2])
        m:set(3,3,scalVec3[3])
        return m
    end,
    TranMatrix = function ( traVec3 )
        local m = la.mat().identity(4)
        m:set(4,1,traVec3[1])
        m:set(4,2,traVec3[2])
        m:set(4,3,traVec3[3])
        return m
    end,
    RotaMatrix = function ( eulerVec3 )
        _ENV.debug.eulvec = eulerVec3
        if not (type(eulerVec3) == "table" and eulerVec3.Type:match("mat") == "mat" and eulerVec3.xSize == 1) then 
            error("Input needs to be a vector",2)
        end 
        if eulerVec3.ySize < 3 then error("Vector needs to be atleast 3 dimensional",2) end
        eulerVec3 = eulerVec3 * (math.pi/180)
        local sx, sy, sz = math.sin(eulerVec3[1]),math.sin(eulerVec3[2]),math.sin(eulerVec3[3])
        local cx, cy, cz = math.cos(eulerVec3[1]),math.cos(eulerVec3[2]),math.cos(eulerVec3[3])
        local m = la.mat().identity(4)
        m[1] = cz * cy                     m[2]  = -cy * sz                    m[3]  = sy
        m[5] = (sx * sy * cz) + (cx * sz)  m[6]  = (-sx * sy * sz) + (cx * cz) m[7]  = -sx * cy
        m[9] = (-cx * sy * cz) + (sx * sz) m[10] = (cx * sy * sz) + (sx * cz)  m[11] = cx * cy
        return m
    end
}

local matrices = {}

local function calculatePers()
    matrices.pers = projections.PersMatrix(-res.x/2,res.x/2,res.y/2,-res.y/2,res.x/2,-res.x/2)
end

local calculateMod = {
    rot = function(Id)
        _ENV.debug.body = bodies[Id]
        matrices[Id].rota = projections.RotaMatrix(bodies[Id].model.rot)
    end,
    sca = function(Id)
        matrices[Id].scal = projections.ScalMatrix(bodies[Id].model.sca)
    end,
    tra = function(Id)
        matrices[Id].tran = projections.TranMatrix(bodies[Id].model.tra)
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
    local input = vec3input
    if (matrices[bodyID].ProjectionMatrix == nil) then
        calcMatrixFull(bodyID)
    end
    if (recalculate) then
        calcMatrixSmart(bodyID)
    end
    matrices.projectedVector = matrices[bodyID].ProjectionMatrix * input
    local projectedVector3 = la.vec{matrices.projectedVector[1],matrices.projectedVector[2],matrices.projectedVector[3]} * 1/matrices.projectedVector.w
    return projectedVector3
end

local function insertBodies(range)
    for i, v in ipairs(range) do
        local id = bodies:add(v)
        _ENV.debug.id = id or "id is nil"
        matrices[id] = {}
        calculateMod.tra(id)
        calculateMod.sca(id)
        calculateMod.rot(id)
    end
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

---@param value vector
local function AddCameraTransform(key, value)
    
---@diagnostic disable-next-line: assign-type-mismatch
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
    bodies[ID].model[key] = bodies[ID].model[key] + value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[BodyKeyToRecalcKey(key)] = true
end

local function SetBodyTransform(ID,key,value)
    bodies[ID].model[key] = value
    if (not recalculate) then
        recalculate = true
    end
    recalculateWhat[BodyKeyToRecalcKey(key)] = true
end

local function GetBodyTransform(ID,key)
    return bodies[ID].model[key]
end

local function setRes(Res)
    res = Res
end

local function renderVertices(grid)
    local Dlog = {}
    for i, body in ipairs(bodies) do
        for i2, v in ipairs(body.verArray) do
            local pos = project(v,i)
            grid.SetlightLevel(pos[1],pos[2],pos[3],1)
            if i==2 then
                Dlog[i2] = pos
            end
        end
    end
end

local function renderWireframe( grid, LL)
    for bi, bv in ipairs(bodies) do
        for i, v in ipairs(bv.indArray) do
            local currPoly = {}
            currPoly.a = project(bv.verArray[v[1]],bi)
            currPoly.b = project(bv.verArray[v[2]],bi)
            currPoly.c = project(bv.verArray[v[3]],bi)
            currPoly.a = la.vec{grid.NDCtoScreen(currPoly.a[1],currPoly.a[2],currPoly.a[3],res)}
            currPoly.b = la.vec{grid.NDCtoScreen(currPoly.b[1],currPoly.b[2],currPoly.b[3],res)}
            currPoly.c = la.vec{grid.NDCtoScreen(currPoly.c[1],currPoly.c[2],currPoly.c[3],res)}
            Paint.drawLine(currPoly.a, currPoly.b, LL, grid)
            Paint.drawLine(currPoly.b, currPoly.c, LL, grid)
            Paint.drawLine(currPoly.c, currPoly.a, LL, grid)
        end
    end
end

local function renderPolygons(grid, LL)
    
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
