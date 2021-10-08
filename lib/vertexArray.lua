import("vec3")

local list = {}

local function add(vec)
    if vec.z == nil then
        error("Vertex Array: add: Invalid Object")
    end
    table.insert(list,vec)
end

local function get(index)
    return list[index]
end

local function set(index, value)
    list[index] = value
end

local function remove(index)
---@diagnostic disable-next-line: undefined-field
    for i=index,table.getn(list) do
        list[i] = list[i+1] or nil
    end
end

return {
    set = set,
    remove = remove,
    get = get,
    list = list,
    add = add
}
