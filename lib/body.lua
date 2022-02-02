import("List")

local verArray = List("Vertex Array")
local indArray = List("Index Array")

local Model = {
    rot = vec3(0,0,0),
    sca = vec3(1,1,1),
    tra = vec3(0,0,0)
}

Body = function (ver, ind, model)
    if (ver ~= nil) then verArray.list = ver end
    if (ind ~= nil) then indArray.list = ind end
    if (model == nil) then model = Model end
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