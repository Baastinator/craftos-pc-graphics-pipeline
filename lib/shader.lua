local vertArray = import("vertexArray")
local indArray = import("indiceArray")
local vec2 = import("vec2")
local vec3 = import("vec3")
local draw = import("draw")

local camera = vec3.new(0,0,-1)
local lightSource = vec3.new(1,0,1)

local res

local projIt = 0

local function project(vec3input)
    vec3input.y = -vec3input.y
    vec3input.z = vec3input.z + 2
    vec3input.x = vec3input.x / vec3input.z
    vec3input.y = vec3input.y / vec3input.z
    vec3input = vec3.add(vec3input,vec3.new(1,1,0))
    local output = vec2.new(
        math.floor((vec3input.x) * res.x / 2),
        math.floor((vec3input.y) * res.y / 2)
    )
    if output.x >= res.x then
        output.x = res.x-1
    elseif output.x <= 0 then
        output.x = 1
    end
    if output.y >= res.y then
        output.y = res.y-1
    elseif output.y <= 0 then
        output.x = 1
    end
    -- debugLog(output,"project"..projIt)
    projIt = projIt + 1
    return output
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

local function renderPolygons(grid)
    local polyList = {}
    for i, v in ipairs(indArray.list) do
        --realisePolys
        polyList[i] = {}
        local currPoly = {}
        -- calculate and save poly vectors
        currPoly.a = vec3.subtract(vertArray.list[v.y],vertArray.list[v.x])
        currPoly.b = vec3.subtract(vertArray.list[v.z],vertArray.list[v.y])
        currPoly.c = vec3.subtract(vertArray.list[v.x],vertArray.list[v.z])
        polyList[i].raw = currPoly
        polyList[i].raw.aStart = vertArray.list[v.x]
        
        -- project poly vectors into 2d
        polyList[i].proj = {}
        polyList[i].proj.a = project(polyList[i].raw.a)
        -- polyList[i].proj.aStart = project(polyList[i].raw.aStart)
        polyList[i].proj.b = project(polyList[i].raw.b)
        polyList[i].proj.c = project(polyList[i].raw.c)
        
        --rasterization value
        local rast = {}
        local proj = {
            a = project(polyList[i].raw.a),
            aStart = project(polyList[i].raw.aStart),
            b = project(polyList[i].raw.b),
            c = project(polyList[i].raw.c)
        }
        rast.am = proj.a.x / proj.a.y
        rast.bm = proj.b.x / proj.b.y
        rast.cm = proj.c.x / proj.c.y
        rast.as = project(vertArray.list[v.x])
        rast.bs = vec2.add(rast.as,proj.a)
        rast.cs = vec2.add(rast.bs,proj.b)
        polyList[i].rast = rast
        rast = nil
        proj = nil

        local cInv = vec3.scale(currPoly.c,-1)
        polyList[i].normal = vec3.normalise(vec3.cross(cInv,currPoly.a))
        if vec3.dot(polyList[i].normal,camera) < 0 then
            polyList[i].rendered = true
            polyList[i].lighting = (vec3.dot(
                vec3.normalise(polyList[i].normal),
                vec3.normalise(lightSource)
            ) + 1.5 ) / 2.5
        else
            polyList[i].rendered = false
        end
        if polyList[i].rendered == false then
            polyList[i] = { rendered = false }
        end
        debugLog(polyList,"polys")
        debugLog(currPoly,"currPoly")
    end
    local localGrid = {}
    for i, v in ipairs(grid.grid) do
        localGrid[i] = {}
        for i2, v2 in ipairs(grid.grid[i]) do
            localGrid[i][i2] = 0
        end
    end
end

return {
    setRes = setRes,
    renderPolygons = renderPolygons,
    renderVertices = renderVertices,
    project = project,
    vertArray = vertArray,
    indArray = indArray
}
