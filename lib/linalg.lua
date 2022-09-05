---@class matrix
---@field xSize number amount of columns
---@field ySize number amount of rows
---@field identity function
---@field set function
---@field tostring function
---@field getSize function
---@field add function
---@field subtract function
---@field multiply function
---@field get function
---@field type string identification string
---@field singleAdd function
---@field vecSet function
---@field vecGet function
---@field fill function
---@field det function
---@field pow function
---@field exp function
---@field fakeln function
---@field minus function
---@field inverse function
---@field length function

---@class vector: matrix

local Mathb = require('mathb')

local vec, mat

local matrix = {
    identity = function(size)
        if (type(size) ~= "number" or size ~= math.floor(size)) then error("input needs to be number",2) end
        local m = mat(size,size)
        for i=1,size do
            m:set(i,i,1)
        end
        return m
    end,
    tostring = function(self)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        local size = self:getSize()
        local str = ""
        for y=1,size.y do
            if (y > 1) then
                str = str.."\n"
            end
            for x=1,size.x do
                local val = Mathb.round(self:get(x,y),5)
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
    add = function(self,b)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("fist input needs to be matrix",2) end
        if (type(b) ~= "table" or b.Type:match("mat") ~= "mat") then error("second input needs to be matrix",2) end
        local size = self:getSize()
        local m = mat(size.x, size.y)
        for y=1,size.y do
            for x=1,size.x do
                m:set(x,y,self:get(x,y) + b:get(x,y))
            end
        end
        return m
    end,
    subtract = function(self,b)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("fist input needs to be matrix",2) end
        if (type(b) ~= "table" or b.Type:match("mat") ~= "mat") then error("second input needs to be matrix",2) end
        local size = self:getSize()
        local m = mat(size.x, size.y)
        for y=1,size.y do
            for x=1,size.x do
                m:set(x,y,self:get(x,y) - b:get(x,y))
            end
        end
        return m
    end,
    transpose = function (self)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        local size = self:getSize()
        local m = mat(size.x, size.y)
        for y=1,size.y do
            for x=1,size.x do
                m:set(x,y,self:get(y,x))
            end
        end
        return m
    end,
    multiply = function (self,b)
        if (type(self) == "table" and type(b) == "number") or (type(self) == "number" and type(b) == "table") then
            local A, B
            if (type(self) == "table") then
                if not (self.Type:match("mat") == "mat") then error("bad types",2) end
                A = self
                B = b
            else
                A = b
                B = self
            end
            local size = A:getSize()
            local m = mat(size.x,size.y)
            for y=1,size.y do
                for x=1,size.x do
                    m:set(x,y,A:get(x,y)*B)
                end
            end
            return m
        elseif (type(self) == "table" and type(b) == "table") then
            if (self.Type:match("mat") ~= "mat" or b.Type:match("mat") ~= "mat") then error("bad types",2) end
            if (self.Type == "mat.vec" and b.Type == "mat.vec") then 
                local sum = 0
                for i=1, self.ySize do
                    sum = sum + (self:vdGet(i) * b:vGet(i))
                end
                return sum
            end
            local aSize = self:getSize()
            local bSize = b:getSize()
            local ay, ax = aSize.y, aSize.x
            local by, bx = bSize.y, bSize.x
            if (ax ~= by) then 
                error("invalid size match",2) 
            end
            local m = mat(bx,ay)
            for i=1,ay do
                for j=1,bx do
                    for k=1,by do
                        m:add(j,i,(self:get(k,i)*b:get(j,k)))
                    end
                end
            end
            return m
        else
            error("bad input",2)
        end
    end,
    set = function ( self, x, y, val )
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(x) ~= "number" and x == math.floor(x)) then error("x position needs to be integer",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("y position needs to be integer",2) end
            if (type(val) ~= "number") then error("input needs to be number",2) end
        end
        self[(y-1)*self:getSize().x+x] = val
    end,
    get = function ( self, x, y )
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(x) ~= "number" and x == math.floor(x)) then error("x position needs to be integer",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("y position needs to be integer",2) end
        end
        return self[(y-1)*self:getSize().x+x]
    end,
    singleAdd = function ( self, x, y, val )
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(x) ~= "number" and x == math.floor(x)) then error("x position needs to be integer",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("y position needs to be integer",2) end
            if (type(val) ~= "number") then error("input needs to be number",2) end
        end
        self:set(x,y,self:get(x,y)+val)
    end,
    getSize = function(self)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        return {x=self.xSize,y=self.ySize}
    end,
    vecSet = function(self,y,val)
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("position needs to be integer",2) end
            if (type(val) ~= "number") then error("input needs to be number",2) end
        end
        self:set(1,y,val)
    end,
    vecGet = function(self,y) 
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("position needs to be integer",2) end
        end
        return self:get(1,y)
    end,
    vecAdd = function(self,y,val) 
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("setter needs to be executed on matrix",2) end
            if (type(y) ~= "number" and y == math.floor(y)) then error("position needs to be integer",2) end
            if (type(val) ~= "number") then error("input needs to be number",2) end
        end
        self:add(1,y,val)
        self.Type = "mat.vec"
    end,
    fill = function(self, content)
        for i=1,#content do
            if (type(content[i]) ~= "number") then error("Content needs to be purely numbers",2) end
            self[i] = content[i]
        end
    end,
    determinant = function(self)
        local size = self:getSize()
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("determinant needs to be called on matrix",2) end
        if (size.x ~= size.y) then error("Invalid dimensions",2) end
        local det2x2 = function(self) 
            return self[1]*self[4]-self[2]*self[3]
        end
        local det3x3 = function(self)    
            local m1 = mat(2,2) 
            local m2 = mat(2,2)
            local m3 = mat(2,2)
            m1:fill({self:get(2,2),self:get(3,2),self:get(2,3),self:get(3,3)})
            m2:fill({self:get(1,2),self:get(3,2),self:get(1,3),self:get(3,3)})
            m3:fill({self:get(1,2),self:get(2,2),self:get(1,3),self:get(2,3)})
            return self:get(1,1) * m1:det() - self:get(2,1) * m2:det() + self:get(3,1) * m3:det()
        end
        local det4x4 = function(self)
            local m1 = mat(3,3)
            local m2 = mat(3,3)
            local m3 = mat(3,3)
            local m4 = mat(3,3)
            m1:fill({self:get(2,2),self:get(3,2),self:get(4,2),self:get(2,3),self:get(3,3),self:get(4,3),self:get(2,4),self:get(3,4),self:get(4,4)})
            m2:fill({self:get(1,2),self:get(3,2),self:get(4,2),self:get(1,3),self:get(3,3),self:get(4,3),self:get(1,4),self:get(3,4),self:get(4,4)})
            m3:fill({self:get(1,2),self:get(2,2),self:get(4,2),self:get(1,3),self:get(2,3),self:get(4,3),self:get(1,4),self:get(2,4),self:get(4,4)})
            m4:fill({self:get(1,2),self:get(2,2),self:get(3,2),self:get(1,3),self:get(2,3),self:get(3,3),self:get(1,4),self:get(2,4),self:get(3,4)})
            return self:get(1,1) * m1:det() - self:get(2,1) * m2:det() + self:get(3,1) * m3:det() - self:get(4,1) * m4:det()
        end
        size = size.x
        if (size == 2) then
            return det2x2(self)
        elseif (size == 3) then
            return det3x3(self)
        elseif (size == 4) then
            return det4x4(self)
        end
    end,
    pow = function(self,b)
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
            if (self.xSize ~= self.ySize) then error("base matrix must be square",2) end
            if (type(b) ~= "number") then error("power needs to be number",2) end
            if (math.floor(b) ~= b or b < 0) then error("matpower: bad power",2) end
        end
        if (b == 0) then return (mat().identity(self.xSize)) end
        local product = self
        for i=1,b-1 do
            product = product * self
        end
        return product
    end,
    exp = function(self, it)
        if not it then it = 50 end
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        if (type(it) ~= "number") then error("iteration count needs to be number",2) end
        if (math.floor(it) ~= it or it <= 0) then error("bad iteration count",2) end
        local sum = mat().identity(self.xSize)
        for i=1,it do
            local part = ((1/Mathb.factorial(i)) * self:pow(i))
            if (type(part) == "number") then error("something bad happening here") end
            sum = sum + part
        end
        return sum
    end,
    fakeln = function(self)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        if not (self.xSize == 2 and self.ySize == 2 and self[1] == self[4] and self[2] == -self[3]) then
            error("bad input, please use complex form matrix",2)
        end
        local self = self[1]
        local b = -self[2]
        local r = math.sqrt(self*self+b*b)
        local t = math.atan2(b,self)
        local c = math.log(r)
        local d = t
        local m = mat(2,2)
        m:fill({c,-d,d,c})
        return m
    end,
    minus = function(self)
        if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
        for i=1,self.xSize*self.ySize do
            self[i] = -self[i]
        end
        return self
    end,
    inverse = function(self)
        do --input validation
            if (type(self) ~= "table" or self.Type:match("mat") ~= "mat") then error("function needs to be called on matrix",2) end
            if (self.xSize ~= self.ySize) then error("MatInverse: Matrix needs to be square",2) end
            if (self:det() == 0) then error("MatInverse: determinant cannot be 0",2) end
        end
        if (self.xSize == 2) then
            local det = self:det()
            self:fill({self[4],-self[2],-self[3],self[1]})
            self = (1/det) * self
            return self
        end
    end,
    length = function(self)
        local sum = 0
        for i, v in ipairs(self) do
            sum = sum + (v*v)
        end
        return math.sqrt(sum)
    end
}

local MT = {
    __index = {
        identity = matrix.identity,
        transpose = matrix.transpose,
        set = matrix.set,
        tostring = matrix.tostring,
        get = matrix.get,
        add = matrix.singleAdd,
        getSize = matrix.getSize,
        vAdd = matrix.vecAdd,
        vGet = matrix.vecGet,
        vSet = matrix.vecSet,
        fill = matrix.fill,
        det = matrix.determinant,
        pow = matrix.pow,
        exp = matrix.exp,
        ln = matrix.fakeln,
        inverse = matrix.inverse,
        subtract = matrix.subtract,
        length = matrix.length
    },
    __tostring = matrix.tostring,
    __add = matrix.add,
    __sub = matrix.subtract,
    __mul = matrix.multiply,
    __unm = matrix.minus,
    __len = matrix.length
}

---@param X? number amount of columns in the matrix
---@param Y? number amount of rows in the matrix
---@return matrix
mat = function(X,Y)
    if (X == nil and Y == nil) then return setmetatable({type="mat.empty"},MT) end
    local T = {}
    for i=1,X*Y do T[i] = 0 end
    T.Type = "mat"
    T.xSize = X
    T.ySize = Y
    return setmetatable(T,MT)
end

---@param input table table of vector elements
---@param mode? string mode of vector creation, 'polar' for polar coordinates. 2D only
---@return vector
vec = function(input,mode)
    local content = {}
    local size = 0
    if (type(input) == "table") then
        content = input
        size = #input
    elseif (type(input) == "number") then
        size = input
    else
        error("bad input",2)
    end 
    ---@type matrix
    local v = mat(1,size)
    v.Type = "mat.vec"
    if (size == 4) then
        v.x = content[1]
        v.y = content[2]
        v.z = content[3]
        v.w = content[4]
    elseif (size == 3) then
        v.x = content[1]
        v.y = content[2]
        v.z = content[3]
    elseif (size == 2) then
        v.x = content[1]
        v.y = content[2]
    end 
    if (mode == "polar") then
        if (size ~= 2) then error("polar mode requires 2 inputs",2) end
        v[1] = 2
    else 
        for i, V in ipairs(content) do
            v[i] = V
        end
    end
    ---@cast v vector
    return v
end

return {
    vec = vec,
    mat = mat
}