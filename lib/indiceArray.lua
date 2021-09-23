local vec3 = import("vec3")

local list = {}

local function add(ind)
    if ind.z == nil then
        error("Indice Array: add: Invalid Object")
    end
    table.insert(list,ind)
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
