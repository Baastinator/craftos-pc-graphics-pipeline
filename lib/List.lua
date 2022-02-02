local list = {}
local Type = ""

local function add(Element)
    table.insert(list,Element)
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
