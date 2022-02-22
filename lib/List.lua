local list = {}
local Type = ""

local function add(Element)
    table.insert(list,Element)
    return table.getn(list)
end

local function get(index)
    if table.getn(list) < index then error(Type.." List get: Outside range") end
    return list[index]
end

local function set(index, value)
    if table.getn(list) < index then error(Type.." List set: Outside range") end
    list[index] = value
end

local function remove(index)
    if table.getn(list) < index then error(Type.." List remove: Outside range") end
    for i=index,table.getn(list) do
        list[i] = list[i+1] or nil
    end
end

local function clear()
    for i, v in ipairs(list) do
        list[i] = nil 
    end
end

function List(type)
    Type = type
    return {
        clear = clear,
        type = Type,
        set = set,
        remove = remove,
        get = get,
        list = list,
        add = add
    }
end
