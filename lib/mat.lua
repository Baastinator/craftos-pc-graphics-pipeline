import("vec4")
local mathb = import("mathb")

local matrix4x4 = {
    identity = function()
        local m = mat4()
        for i=1,4 do
            m:set(i,i,1)
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
                local val = mathb.round(m:get(x,y),5)
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
                m:set(x,y,a:get(x,y) + b:get(x,y))
            end
        end
        return m
    end,
    transpose = function (a)
        local m = mat4()
        for y=1,4 do
            for x=1,4 do
                m:set(x,y,a:get(y,x))
            end
        end
        return m
    end,
    multiply = function (a,b)
        if type(a) == "table" and type(b) == "number" then
            local m = mat4()
            for y=1,4 do
                for x=1,4 do
                    m:set(x,y,a:get(x,y)*b)
                end
            end
            return m
        elseif type(a) == "number" and type(b) == "table" then
            local m = mat4()
            for y=1,4 do
                for x=1,4 do
                    m:set(x,y,b:get(x,y)*a)
                end
            end
            return m
        elseif type(b) == "table" then
            if b.type == "vec4" then
                local b2 = b:toTable()
                local v4 = {0,0,0,0}
                for y=1,4 do
                    for x=1,4 do
                        v4[y] = v4[y] + (a:get(x,y) * b2[x])
                    end
                end
                return vec4().toVector(v4)
            elseif b.type == "mat4" then
                local m = mat4()
                local ra, ca = 4, 4
                local rb, cb = 4, 4
                -- if (ca ~= rb) then error("matmul: bad size") end
                for i=1,ra do
                    for j=1,cb do
                        for k=1,rb do
                            m:add(j,i,(a:get(k,i)*b:get(j,k)))
                        end
                    end
                end
                -- for y1=1,4 do
                --     for x1=1,4 do
                --         local rV = {0,0,0,0}
                --         local cV = {0,0,0,0}
                --         for r=1,4 do
                --             rV[r] = a:get(r,y1)
                --         end
                --         for c=1,4 do
                --             cV[c] = b:get(x1,c)
                --         end
                --         cV = vec4().toVector(cV)
                --         rV = vec4().toVector(rV)
                --         m:set(x1,y1,cV * rV)
                --     end
                -- end
                return m
            else 
                error("MAT4: MUL: bad table input")
            end
        else
            error("MAT4: MUL: bad input")
        end
    end,
    set = function ( a, x, y, val )
        a[(y-1)*4+x] = val
    end,
    get = function ( a, x, y )
        return a[(y-1)*4+x]
    end,
    singleAdd = function ( a, x, y, val )
        a[(y-1)*4+x] = a[(y-1)*4+x] + val
    end
}

local MT = {
    __index = {
        identity = matrix4x4.identity,
        transpose = matrix4x4.transpose,
        set = matrix4x4.set,
        get = matrix4x4.get,
        add = matrix4x4.singleAdd,
    },
    __tostring = matrix4x4.tostring,
    __add = matrix4x4.add,
    __mul = matrix4x4.multiply
}

function mat4()
    return setmetatable({
        type = "mat4",
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
    },MT)
end
