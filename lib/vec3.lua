
local function new(x,y,z)
    return {x=x,y=y,z=z}
end

local function add(v,o)
    return new(
        v.x+o.x,
        v.y+o.y,
        v.z+o.z
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
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end

local function dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

return {
    dot = dot,
    cross = cross,
    scale = scale,
    new = new,
    add = add
}