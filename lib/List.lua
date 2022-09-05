---@class list
---@field public add function
---@field public get function
---@field public set function
---@field public remove function
---@field public clear function

---@param element any list element to add
local function add(self,element)
    -- debug.List = {self,element}
    if (element == nil) then error("element must not be nil",2) end
    if not (type(self) == "table" or self.Type:match"list" == "list") then error("List Add needs to be called on itself",2) end
    element.id = self.idCounter
    self.idCounter = self.idCounter + 1
    table.insert(self,element)
    return #self
end

---@param index number id to pull
local function get(self,index)
    if (type(self) ~= "table") then error("function needs to be executed on list",2) end
    if #self < index then error(Type.." List get: Outside range",2) end
    return self[index]
end

---@param index number id to change
---@param value any new element
local function set(self,index, value)
    if #self < index then error(Type.." List set: Outside range",2) end
    self[index] = value
end

---@param index number id to remove
local function remove(self,index)
    if #self < index then error(Type.." List remove: Outside range",2) end
    for i=index,#self do
        self[i] = self[i+1] or nil
    end
end

local function clear(self)
    for i, v in ipairs(self) do
        self[i] = nil 
    end
end

local function find(self,id)
    for i,v in ipairs(self) do
        if id == v.id then
            return v
        end
    end
end

---@generic T
---@param type string type of list
---@return list
local function List(type)
    Type = type
    return setmetatable({
        type = "list."..Type,
    },{
        __index = {
            clear = clear,
            set = set,
            remove = remove,
            get = get,
            add = add,
            find = find,
            idCounter = 1
        }
    })
end

return List