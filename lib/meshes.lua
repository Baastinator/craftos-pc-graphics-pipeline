local List = require("List")
local la = require"linalg"
require("body")
require("tblclean")

icosahedron = {
    ver = {
        la.vec{0,30,0},
        la.vec{26,15,0},
        la.vec{8,15,25},
        la.vec{-21,15,15},
        la.vec{-21,15,-15},
        la.vec{8,15,-25},
        la.vec{21,-15,15},
        la.vec{-8,-15,25},
        la.vec{-26,-15,0},
        la.vec{-8,-15,-25},
        la.vec{21,-15,-15},
        la.vec{0,-30,0},
    },
    ind = {
        la.vec{1,2,3},
        la.vec{1,4,3},
        la.vec{1,4,5},
        la.vec{1,6,5},
        la.vec{1,6,2},
        la.vec{2,3,7},
        la.vec{8,3,7},
        la.vec{3,4,8},
        la.vec{9,4,8},
        la.vec{4,5,9},
        la.vec{10,5,9},
        la.vec{5,6,10},
        la.vec{11,6,10},
        la.vec{6,2,11},
        la.vec{7,2,11},
        la.vec{12,11,10},
        la.vec{12,9,10},
        la.vec{12,9,8},
        la.vec{12,7,8},
        la.vec{12,7,11},
    }
}

tetrahedra = {
    ver = {
        la.vec{26,15,0},
        la.vec{-13,15,22.5},
        la.vec{-13,15,-22.5},
        la.vec{0,-30,0},
    },
    ind = {
        la.vec{1,2,3},
        la.vec{4,3,2},
        la.vec{4,2,1},
        la.vec{4,1,3}
        
    }
}

tPiece = {
    ver = {
        la.vec{45,0,-15},
        la.vec{45,0,15},
        la.vec{45,-30,-15},
        la.vec{45,-30,15},
        la.vec{-45,0,-15},
        la.vec{-45,0,15},
        la.vec{-45,-30,-15},
        la.vec{-45,-30,15},

        la.vec{15,0,15},
        la.vec{15,0,-15},
        la.vec{15,30,15},
        la.vec{15,30,-15},
        la.vec{-15,0,15},
        la.vec{-15,0,-15},
        la.vec{-15,30,15},
        la.vec{-15,30,-15},
    },
    ind = {
        la.vec{1,2,3},
        la.vec{4,2,3},
        la.vec{9,10,11},
        la.vec{12,10,11},
        la.vec{5,6,7},
        la.vec{8,6,7},
        la.vec{13,14,15},
        la.vec{16,14,15},
        la.vec{1,3,5},
        la.vec{7,5,3},
        la.vec{16,10,12},
        la.vec{14,16,10},
        la.vec{2,4,8},
        la.vec{8,2,6},
        la.vec{11,13,15},
        la.vec{11,13,9},
        la.vec{11,12,15},
        la.vec{16,12,15},
        la.vec{3,4,7},
        la.vec{8,4,7},
        la.vec{1,2,9},
        la.vec{1,10,9},
        la.vec{5,6,13},
        la.vec{5,14,13},
    }
}
cube = {
    ver = {
        la.vec{0,0,0},
        la.vec{26,15,0},
        la.vec{8,15,25},
        la.vec{-21,15,15},
        la.vec{-21,15,-15},
        la.vec{8,15,-25},
    },
    ind = {
        la.vec{3,2,4},
        la.vec{1,2,3},

        la.vec{2,4,6},
        la.vec{6,8,4},
        
        la.vec{4,3,8},
        la.vec{3,8,7},
        
        la.vec{5,2,6},
        la.vec{2,5,1},
        
        la.vec{5,7,1},
        la.vec{1,3,7},

        la.vec{6,5,8},
        la.vec{8,5,7},
    }
}

diamond = {
    ver = function(count)
        local T = {la.vec{0,20}}
        
        for i=0,count-1 do
            local yeet = la.vec{(20*math.cos((i/count)*2*math.pi)),-10,(20*math.sin((i/count)*2*math.pi))}
            table.insert(T,yeet)
        end

        for i=0,count-1 do
            local yeet = la.vec{(15*math.cos((i/count)*2*math.pi+math.pi/count)),-15,(15*math.sin((i/count)*2*math.pi+math.pi/count))}
            table.insert(T,yeet)
        end

        return T
    end,
    ind = function(count)
        local T = {}
        for i=2,count do
            table.insert(T,la.vec{1,i,i+1})
        end
        table.insert(T,la.vec{1,count+1,2})
        for i=2,count do
            table.insert(T,la.vec{
                count+i,
                i,
                i+1
            })
        end
        table.insert(T,la.vec{count+1,2*count+1,2})
        for i=2,count do
            table.insert(T,la.vec{
                count+i,
                count+i+1,
                i+1
            })
        end
        table.insert(T,la.vec{count+2,count+count+1,2})
        return T
        -- la.vec{10,2,3),
        -- la.vec{10,11,3),
        -- la.vec{3,11,4),
        -- la.vec{12,11,4),
        -- la.vec{12,4,5),
        -- la.vec{12,13,5),
        -- la.vec{6,13,5),
        -- la.vec{6,13,14),
        -- la.vec{6,7,14),
        -- la.vec{15,7,14),
        -- la.vec{15,7,8),
        -- la.vec{15,16,8),
        -- la.vec{9,16,8),
        -- la.vec{9,16,18),
        -- la.vec{9,2,18),
        -- la.vec{10,2,18),
    end
}

function makeFloorMesh(size, tileDensity, func)
    if (not size) then error("makeFloorMesh: please insert size") end
    if (not tileDensity) then error("makeFloorMesh: please insert tile density") end
    if (not func) then func = function(x,z) return 0 end end
    local verArray = {}
    for x=-size/2,size/2,size/tileDensity do
        for z=-size/2,size/2,size/tileDensity do
            table.insert(verArray,la.vec{x,func(x,z),z})
        end
    end
    local indArray = {}
    for x=1,tileDensity do
        for z=1,tileDensity do
            table.insert(
                indArray,
                la.vec{
                    (z-1)*tileDensity+x+z-1,
                    (z-1)*tileDensity+x+z,
                    z+x+z*tileDensity
                }
            )
            table.insert(
                indArray,
                la.vec{
                    (z-1)*tileDensity+x+z,
                    x+z*tileDensity+z,
                    x+z+z*tileDensity+1
                }
            )
        end
    end
    return Body(verArray,indArray)
end


function SetFloorMesh(shader, size, x, z, value, body)
    if not body then body = 1 end
    shader.bodies[body].verArray[(z-1)*(size+1)+x].y = value
end

function GetFloorMesh(shader, size, x, z, body)
    if not body then body = 1 end
    return shader.bodies[body].verArray[(z-1)*(size+1)+x].y
end

function GetFloorMesh2Dpos(shader, size, x, z, body)
    if not body then body = 1 end
    local s = 0 
    local c = 0
    if (z < size) then
        s = s + GetFloorMesh(shader,size,x,z+1,body)
        c = c + 1
    end
    if (z > 1) then
        s = s + GetFloorMesh(shader,size,x,z-1,body)
        c = c + 1
    end
    if (x < size) then
        s = s + GetFloorMesh(shader,size,x+1,z,body)
        c = c + 1
    end
    if (x > 1) then
        s = s + GetFloorMesh(shader,size,x-1,z,body)
        c = c + 1
    end
    return s/c
end

function GetFloorMesh2D(shader,size,body)
    if not body then body = 1 end
    local grid = {}
    for z=1,size do
        grid[z] = {}
        for x=1,size do
            grid[z][x] = GetFloorMesh2Dpos(shader,size,x,z,body)
        end
    end
    return grid
end

function AddFloorMesh2D(shader, size, alpha, dt, grid, body) 
    if not body then body = 1 end
    if not grid then grid = GetFloorMesh2D(shader, size, body) end
    for z=1,size do
        for x=1,size do
            SetFloorMesh(shader,size,x,z,
                GetFloorMesh(shader,size,x,z,body)-alpha*grid[z][x]*dt,
            body)
        end
    end
end