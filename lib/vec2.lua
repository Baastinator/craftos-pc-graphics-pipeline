
local vector2 = {
    add = function (a,b)
        return vec2(
            a.x + b.x,
            a.y + b.y
        )
    end,
    subtract = function ( a,b )
        return vec2(
            a.x - b.x,
            a.y - b.y
        )
    end,
    mult = function(s,o)
        if type(o) == "table" then
            if (o.type == "vec2") then
                return (
                    s.x * o.x +
                    s.y * o.y
                )
            else
                error("vec2 mult: invalid type")
            end
        elseif type(o) == "number" then
            return vec3(
                s.x * o,
                s.y * o
            )
        end
    end,
    tostring = function(a)
        return a.x..","..a.y
    end,
    toTable = function (a)
        return {a.x,a.y}
    end,
    toVector = function ( t )
        return vec2(t[1],t[2])
    end,
    getLength = function ( a )
        return math.sqrt( a.x * a.x + a.y * a.y)
    end,
    normalise = function (a)
        return vec2(
            a.x / a:getLength(),
            a.y / a:getLength()
        )
    end
}

local MT = {
    __add = vector2.add,
    __sub = vector2.subtract,
    __index = {
        toTable = vector2.toTable,
        toVector = vector2.toVector,
        getLength = vector2.getLength,
        normalise = vector2.normalise
    },
    __tostring = vector2.tostring,
    __mul = vector2.mult
}

function vec2(x,y)
    return setmetatable(
        {
            type = "vec2",
            x = x or 0,
            y = y or 0
        }, MT
    )
end


