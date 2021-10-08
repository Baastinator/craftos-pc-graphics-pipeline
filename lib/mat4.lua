import("vec4")
local mathb = import("mathb")

local matrix4x4 = {
    identity = function()
        local m = mat4()
        for i=1,4 do
            m[i][i] = 1
        end
        return m
    end,
    tostring = function(m)
        local str = ""
        for y=1,4 do
            if (y > 1) then
                str = str.."\n"
            end
            for x=1,4 do
                local val = mathb.round(m[y][x],5)
                local placeholder = ""
                for i=#tostring(val),8 do
                    placeholder = placeholder.." "
                end
                if (x > 1) then
                    str = str..","
                end
                str = str..val..placeholder
            end
        end
        return str
    end,
    add = function(a,b)
        local m = mat4()
        for y=1,4 do
            for x=1,4 do
                m[y][x] = a[y][x] + b[y][x] 
            end
        end
        return m
    end,
    transpose = function (a)
        local m = mat4()
        for y=1,4 do
            for x=1,4 do
                m[y][x] = a[x][y]
            end
        end
        return m
    end,
    multiply = function (a,b)
        if type(b) == "number" then
            local m = mat4()
            for y=1,4 do
                for x=1,4 do
                    m[y][x] = a[y][x] * b
                end
            end
            return m
        elseif type(b) == "table" then
            if b.type == "vec4" then
                local b2 = b:toTable()
                local v4 = {0,0,0,0}
                for y=1,4 do
                    for x=1,4 do
                        v4[y] = v4[y] + (a[y][x] * b2[x])
                    end
                end
                return vec4().toVector(v4)
            elseif b.type == "mat4" then
                local m = mat4()
                for y1=1,4 do
                    for x1=1,4 do
                        local rV = {0,0,0,0}
                        local cV = {0,0,0,0}
                        for r=1,4 do
                            rV[r] = a:get(r,y1)
                        end
                        for c=1,4 do
                            cV[c] = b:get(x1,c)
                        end
                        cV = vec4().toVector(cV)
                        rV = vec4().toVector(rV)
                        m:set(x1,y1,cV * rV)
                    end
                end
                return m
            end
        end
    end,
    set = function (a, x, y, val)
        a[y][x] = val
    end,
    get = function ( a,x,y )
        return a[y][x]
    end
}


local MT = {
    __index = {
        identity = matrix4x4.identity,
        transpose = matrix4x4.transpose,
        set = matrix4x4.set,
        get = matrix4x4.get
    },
    __tostring = matrix4x4.tostring,
    __add = matrix4x4.add,
    __mul = matrix4x4.multiply
}

function mat4()
    return setmetatable({
        type = "mat4",
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0}
    },MT)
end
