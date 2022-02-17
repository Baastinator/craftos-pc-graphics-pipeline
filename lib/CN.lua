
local CNum = {
    add = function(a,b)
        if (a.type ~= "CN" or b.type ~= "CN") then
            error("CN add: please insert valid input")
        end
        return CN(a.a + b.a, a.b + b.b)
    end,
    subtract = function (a,b) 
        if (a.type ~= "CN" or b.type ~= "CN") then
            error("CN sub: please insert valid input")
        end
        return CN(a.a - b.a, a.b - b.b)
    end,
    multiply = function(a,b)
        if (a.type ~= "CN" or b.type ~= "CN") then
            error("CN mult: please insert valid input")
        end
        return CN(
            a.a * b.a - a.b * b.b,
            a.a * b.b + b.a * a.b
        )
    end,
    tostring = function(a)
        local b = ""
        if (a.a ~= 0) then
            if (a.a < 0) then b = b.."-" end
            b = b..math.abs(a.a)
        end
        if (a.b ~= 0) then
            if (a.a ~= 0) then
                if (a.b < 0) then b = b.."-" else b = b.."+" end
            end
            if (a.b == 1) then b = b.."i" else b = b..math.abs(a.b).."i" end
        end
        return b
    end,
    getLength = function (a)
        return math.sqrt(a.a * a.a + a.b * a.b)
    end
}

local MT = {
    __add = CNum.add,
    __tostring = CNum.tostring,
    __sub = CNum.subtract,
    __mul = CNum.multiply,
    __index = {
        r = CNum.getLength
    }
}

function CN(a,b)
    if (not a) then a = 1 end
    if (not b) then b = 0 end
    return setmetatable({
        type="CN",
        a=a,
        b=b
    }, MT)
end