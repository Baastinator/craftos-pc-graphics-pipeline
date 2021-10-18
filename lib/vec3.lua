import("vec4")

local vector3 = {
    add = function (a,b)
        return vec3(
            a.x + b.x,
            a.y + b.y,
            a.z + b.z
        )
    end,
    subtract = function ( a,b )
        return vec3(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        )
    end,
    mult = function(s,o)
        if type(o) == "table" then
            if (o.type == "vec3") then
                return (
                    s.x * o.x +
                    s.y * o.y +
                    s.z * o.z
                )
            else
                error("vec3 mult: invalid type")
            end
        elseif type(o) == "number" then
            return vec3(
                s.x * o,
                s.y * o,
                s.z * o
            )
        end
    end,
    tostring = function(a)
        return a.x..","..a.y..","..a.z
    end,
    toTable = function (a)
        return {a.x,a.y,a.z}
    end,
    toVector = function ( t )
        return vec3(t[1],t[2],t[3])
    end,
    cross = function (a,b)
        return vec3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    end,
    getLength = function ( a )
        return math.sqrt( a.x * a.x + a.y * a.y + a.z * a.z )
    end,
    normalise = function (a)
        return vec3(
            a.x / a:getLength(),
            a.y / a:getLength(),
            a.z / a:getLength()
        )
    end,
    vector4 = function ( a )
        return vec4(a.x,a.y,a.z,1)
    end,
    divide = function ( a ,b )
        if type(b) ~= "number" then
            error("vec3 div: invalid input")
        else
            return vec3(
                a.x / b,
                a.y / b,
                a.z / b
            )
        end
    end
}

local MT = {
    __add = vector3.add,
    __sub = vector3.subtract,
    __index = {
        toTable = vector3.toTable,
        toVector = vector3.toVector,
        cross = vector3.cross,
        getLength = vector3.getLength,
        normalise = vector3.normalise,
        vec4 = vector3.vector4
    },
    __tostring = vector3.tostring,
    __mul = vector3.mult,
    __div = vector3.divide
}

function vec3(x,y,z)
    return setmetatable(
        {
            type = "vec3",
            x = x or 0,
            y = y or 0,
            z = z or 0
        }, MT
    )
end


