local List = require'list'
local la = require"linalg"

local verArray = List("Vertex Array")
local indArray = List("Index Array")

local Model = {
    rot = la.vec{0,0,0},
    sca = la.vec{1,1,1},
    tra = la.vec{0,0,0}
}

Body = function (ver, ind, model)
    if (ver ~= nil) then 
        for i,v in ipairs(ver) do
            verArray:add(v)
        end
    end
    if (ind ~= nil) then 
        for i,v in ipairs(ind) do
            indArray:add(v)
        end
    end
    if (model == nil) then 
        model = Model 
    end
    if (model.rot == nil) then model.rot = Model.rot end
    if (model.sca == nil) then model.sca = Model.sca end
    if (model.tra == nil) then model.tra = Model.tra end
    return {
        type = "Body",
        model = model,
        indArray = indArray,
        verArray = verArray
    }
end