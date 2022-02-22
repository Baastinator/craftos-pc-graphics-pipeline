import("vec3")
import("vec2")
import("List")
import("body")
import("tblclean")

icosahedron = {
    ver = {
        vec3(0,30,0),
        vec3(26,15,0),
        vec3(8,15,25),
        vec3(-21,15,15),
        vec3(-21,15,-15),
        vec3(8,15,-25),
        vec3(21,-15,15),
        vec3(-8,-15,25),
        vec3(-26,-15,0),
        vec3(-8,-15,-25),
        vec3(21,-15,-15),
        vec3(0,-30,0),
    },
    ind = {
        vec3(1,2,3),
        vec3(1,4,3),
        vec3(1,4,5),
        vec3(1,6,5),
        vec3(1,6,2),
        vec3(2,3,7),
        vec3(8,3,7),
        vec3(3,4,8),
        vec3(9,4,8),
        vec3(4,5,9),
        vec3(10,5,9),
        vec3(5,6,10),
        vec3(11,6,10),
        vec3(6,2,11),
        vec3(7,2,11),
        vec3(12,11,10),
        vec3(12,9,10),
        vec3(12,9,8),
        vec3(12,7,8),
        vec3(12,7,11),
    }
}

tetrahedra = {
    ver = {
        vec3(26,15,0),
        vec3(-13,15,22.5),
        vec3(-13,15,-22.5),
        vec3(0,-30,0),
    },
    ind = {
        vec3(1,2,3),
        vec3(4,3,2),
        vec3(4,2,1),
        vec3(4,1,3)
        
    }
}

tPiece = {
    ver = {
        vec3(45,0,-15),
        vec3(45,0,15),
        vec3(45,-30,-15),
        vec3(45,-30,15),
        vec3(-45,0,-15),
        vec3(-45,0,15),
        vec3(-45,-30,-15),
        vec3(-45,-30,15),

        vec3(15,0,15),
        vec3(15,0,-15),
        vec3(15,30,15),
        vec3(15,30,-15),
        vec3(-15,0,15),
        vec3(-15,0,-15),
        vec3(-15,30,15),
        vec3(-15,30,-15),
    },
    ind = {
        vec3(1,2,3),
        vec3(4,2,3),
        vec3(9,10,11),
        vec3(12,10,11),
        vec3(5,6,7),
        vec3(8,6,7),
        vec3(13,14,15),
        vec3(16,14,15),
        vec3(1,3,5),
        vec3(7,5,3),
        vec3(16,10,12),
        vec3(14,16,10),
        vec3(2,4,8),
        vec3(8,2,6),
        vec3(11,13,15),
        vec3(11,13,9),
        vec3(11,12,15),
        vec3(16,12,15),
        vec3(3,4,7),
        vec3(8,4,7),
        vec3(1,2,9),
        vec3(1,10,9),
        vec3(5,6,13),
        vec3(5,14,13),
    }
}
cube = {
    ver = {
        vec3(0,0,0),
        vec3(26,15,0),
        vec3(8,15,25),
        vec3(-21,15,15),
        vec3(-21,15,-15),
        vec3(8,15,-25),
    },
    ind = {
        vec3(3,2,4),
        vec3(1,2,3),

        vec3(2,4,6),
        vec3(6,8,4),
        
        vec3(4,3,8),
        vec3(3,8,7),
        
        vec3(5,2,6),
        vec3(2,5,1),
        
        vec3(5,7,1),
        vec3(1,3,7),

        vec3(6,5,8),
        vec3(8,5,7),
    }
}

diamond = {
    ver = function(count)
        local T = {vec3(0,20)}
        
        for i=0,count-1 do
            local yeet = vec3((20*math.cos((i/count)*2*math.pi)),-10,(20*math.sin((i/count)*2*math.pi)))
            table.insert(T,yeet)
        end

        for i=0,count-1 do
            local yeet = vec3((15*math.cos((i/count)*2*math.pi+math.pi/count)),-15,(15*math.sin((i/count)*2*math.pi+math.pi/count)))
            table.insert(T,yeet)
        end

        return T
    end,
    ind = function(count)
        local T = {}
        for i=2,count do
            table.insert(T,vec3(1,i,i+1))
        end
        table.insert(T,vec3(1,count+1,2))
        for i=2,count do
            table.insert(T,vec3(
                count+i,
                i,
                i+1
            ))
        end
        table.insert(T,vec3(count+1,2*count+1,2))
        for i=2,count do
            table.insert(T,vec3(
                count+i,
                count+i+1,
                i+1
            ))
        end
        table.insert(T,vec3(count+2,count+count+1,2))
        return T
        -- vec3(10,2,3),
        -- vec3(10,11,3),
        -- vec3(3,11,4),
        -- vec3(12,11,4),
        -- vec3(12,4,5),
        -- vec3(12,13,5),
        -- vec3(6,13,5),
        -- vec3(6,13,14),
        -- vec3(6,7,14),
        -- vec3(15,7,14),
        -- vec3(15,7,8),
        -- vec3(15,16,8),
        -- vec3(9,16,8),
        -- vec3(9,16,18),
        -- vec3(9,2,18),
        -- vec3(10,2,18),
    end
}

function makeFloorMesh(size, tileDensity, func)
    if (not size) then error("makeFloorMesh: please insert size") end
    if (not tileDensity) then error("makeFloorMesh: please insert tile density") end
    if (not func) then func = function(x,z) return 0 end end
    local verArray = {}
    for x=-size/2,size/2,size/tileDensity do
        for z=-size/2,size/2,size/tileDensity do
            table.insert(verArray,vec3(x,func(x,z),z))
        end
    end
    local indArray = {}
    for x=1,tileDensity do
        for z=1,tileDensity do
            table.insert(
                indArray,
                vec3(
                    (z-1)*tileDensity+x+z-1,
                    (z-1)*tileDensity+x+z,
                    z+x+z*tileDensity)
                )
            table.insert(
                indArray,
                vec3(
                    (z-1)*tileDensity+x+z,
                    x+z*tileDensity+z,
                    x+z+z*tileDensity+1
                )
            )
        end
    end
    -- debugLog(clean(indArray),"indarray")
    return Body(verArray,indArray)
end