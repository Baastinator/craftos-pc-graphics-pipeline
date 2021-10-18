import("vec3")

local function drawLine(Svec3, Evec3, LL, grid)
    local Dvec3 = vec3(
        Evec3.x - Svec3.x,
        Evec3.y - Svec3.y,
        Evec3.z - Svec3.z
    )
    local denom
    local Mvec2 = {} 
    if Dvec3.x >= Dvec3.y then
        Mvec2.dy = Dvec3.y / Dvec3.x
        Mvec2.dz = Dvec3.z / Dvec3.x
        denom = "x"
    else
        Mvec2.dx = Dvec3.x / Dvec3.y
        Mvec2.dz = Dvec3.z / Dvec3.y
        denom = "y"
    end
    if denom == "x" then
        for x=1,Dvec3.x do
            local y = (x*Mvec2.dy)
            local z = (x*Mvec2.dz)
            debugLog({mz=Mvec2.dz,dx=Dvec3.x,x=x,y=y,z=z},"x")
            grid.SetlightLevel(x+Svec3.x,y+Svec3.y,z+Svec3.z,LL,false)
        end
    else
        for y=1,Dvec3.y do
            local x = (y*Mvec2.dx)
            local z = (y*Mvec2.dz)
            grid.SetlightLevel(x+Svec3.x,y+Svec3.y,z+Svec3.z,LL,false)
        end
    end
end

return {
    drawLine = drawLine
}