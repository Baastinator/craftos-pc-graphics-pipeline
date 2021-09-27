
local function new(x,y,z)
    return {x=x or 0,y=y or 0,z=z or 0}
end

local function add(v,o)
    return new(
        v.x+o.x,
        v.y+o.y,
        v.z+o.z
    )
end

local function subtract(a,b)
    return new(
        a.x-b.x,
        a.y-b.y,
        a.z-b.z
    )    
end

local function scale(v,s)
    return new(
        v.x * s,
        v.y * s,
        v.z * s
    )
end

local function cross(a,b)
    return new(
        a.y * b.z - a.z * b.y,
        a.z *b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end

local function getLength(a)
    return math.sqrt(
        a.x * a.x +
        a.y * a.y +
        a.z * a.z
    )
end

local function normalise(a)
    local length = getLength(a)
    return new(
        a.x / length,
        a.y / length,
        a.z / length
    )
end

local function dot(a, b)
    return (
        a.x * b.x +
        a.y * b.y +
        a.z * b.z
    )
end

return {
    getLength = getLength,
    normalise = normalise,
    subtract = subtract,
    dot = dot,
    cross = cross,
    scale = scale,
    new = new,
    add = add
}