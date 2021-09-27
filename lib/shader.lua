local vertArray = import("vertexArray")
local indArray = import("indiceArray")
local vec2 = import("vec2")
local vec3 = import("vec3")

local camera = vec3.new(0,0,-1)
local lightSource = vec3.new(1,0,1)

local function project(vec3input)
    local output = vec2.new(
        vec3input.x,
        vec3input.y
    )
    return output
end

local function renderVertices(grid)
    local debugT = {}
    for i, v in ipairs(vertArray.list) do
        debugT.v = v
        local pos = project(v)
        debugT.pos = pos
        grid.SetlightLevel(pos.x,pos.y,1)
    end
    --debugLog(debugT,"rendvert")
end

local function renderPolygons(grid)
    local polyList = {}
    for i, v in ipairs(indArray.list) do
        local currPoly = {}
        polyList[i] = {}
        currPoly.a = vec3.subtract(vertArray.list[v.y],vertArray.list[v.x])
        currPoly.b = vec3.subtract(vertArray.list[v.z],vertArray.list[v.y])
        currPoly.c = vec3.subtract(vertArray.list[v.x],vertArray.list[v.z])
        polyList[i] = currPoly
        polyList[i].aStart = vertArray.list[v.x]
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
        debugLog(polyList,"polys")
    end
    local localGrid = {}
    for i, v in ipairs(grid.grid) do
        localGrid[i] = {}
        for i2, v2 in ipairs(grid.grid[i]) do
            localGrid[i][i2] = 0
        end
    end
    for i, v in ipairs(polyList) do

    end
end

return {
    renderPolygons = renderPolygons,
    renderVertices = renderVertices,
    project = project,
    vertArray = vertArray,
    indArray = indArray
}
