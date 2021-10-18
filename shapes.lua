local polyhedron = {
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