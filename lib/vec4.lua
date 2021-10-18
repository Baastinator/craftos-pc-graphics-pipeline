--import("vec3")

local vector4 =  {
    add = function(s,o)
        return vec4(
            s.x + o.x,
            s.y + o.y,
            s.z + o.z,
            s.w + o.w
        )
    end,
    subtract = function(s,o)
        return vec4(
            s.x - o.x,
            s.y - o.y,
            s.z - o.z,
            s.w - o.w
        )
    end,
    mult = function(s,o)
        if type(o) == "table" then
            if (o.type == "vec4") then
                return (
                    s.x * o.x +
                    s.y * o.y +
                    s.z * o.z +
                    s.w * o.w
                )
            else
                error("vec4 mult: invalid type")
            end
        elseif type(o) == "number" then
            return vec4(
                s.x * o,
                s.y * o,
                s.z * o,
                s.w * o
            )
        end
    end,
    tostring = function(a)
        return a.x..","..a.y..","..a.z..","..a.w
    end,
    toTable = function (a)
        return {a.x,a.y,a.z,a.w}
    end,
    toVector = function ( t )
        return vec4(t[1],t[2],t[3],t[4])
    end,
    getLength = function ( a )
        return math.sqrt( a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w )
    end,
    normalise = function (a)
        return vec4(
            a.x / a:getLength(),
            a.y / a:getLength(),
            a.z / a:getLength(),
            a.w / a:getLength()
        )
    end,
    divide = function ( a ,b )
        if type(b) ~= "number" then
            error("vec4 div: invalid input")
        else
            return vec4(
                a.x / b,
                a.y / b,
                a.z / b,
                a.w / b
            )
        end
    end,
    vector3 = function (a)
        return vec3(a.x,a.y,a.z)
    end
}



local MT = {
    __add = vector4.add,
    __sub = vector4.subtract,
    __index = {
        toTable = vector4.toTable,
        toVector = vector4.toVector,
        getLength = vector4.getLength,
        normalise = vector4.normalise,
        vec3 = vector4.vector3
    },
    __mul = vector4.mult,
    __tostring = vector4.tostring,
    __div = vector4.divide
}



function vec4(x,y,z,w)
    return setmetatable(
        {
            type = "vec4",
            x = x or 0,
            y = y or 0, 
            z = z or 0,
            w = w or 0,
            add = vector4.add,
            subtract = vector4.subtract,
            mult = vector4.mult
        },
        MT
    )    
end

