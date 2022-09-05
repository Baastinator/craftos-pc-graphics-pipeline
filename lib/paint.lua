function drawLine(v3Start, v3End, LL, grid)


    if v3Start.x == v3End.x and v3Start.y == v3End.y then
        grid.SetlightLevel(v3Start.x, v3Start.y, v3Start.z, LL, false)
        return
    end
    
    -- looks if min x is start or end
    local minX = math.min(v3Start.x, v3End.x)
    local maxX, minY, maxY, minZ, maxZ
    if minX == v3Start.x then
        -- if start is small, start becomes min and end becomes max
        minY = v3Start.y
        minZ = v3Start.z
        maxX = v3End.x
        maxY = v3End.y
        maxZ = v3End.z
    else
        -- otherwise, end becomes min and start becomes max 
        -- y ignored, cool ideas
        minY = v3End.y
        minZ = v3End.z
        maxX = v3Start.x
        maxY = v3Start.y
        maxZ = v3Start.z
    end

    -- TODO: clip to screen rectangle?
    -- no

    local xDiff = maxX - minX
    local yDiff = maxY - minY
    local zDiff = maxZ - minZ

    if xDiff > math.abs(yDiff) then
        local y = minY
        local z = minZ
        local dy = yDiff / xDiff
        local dz = zDiff / xDiff
        for x = minX, maxX do
            grid.SetlightLevel(x, math.floor(y + 0.5), math.floor(z + 0.5), LL, false)
            y = y + dy
            z = z + dz
        end
    else
        local x = minX
        local z = minZ
        local dx = xDiff / yDiff
        local dz = zDiff / yDiff
        if maxY >= minY then
            for y = minY, maxY do
                grid.SetlightLevel(math.floor(x + 0.5), y, math.floor(z + 0.5), LL, false)
                x = x + dx
                z = z + dz
            end
        else
            for y = minY, maxY, -1 do
                grid.SetlightLevel(math.floor(x + 0.5), y, math.floor(z + 0.5), LL, false)
                x = x - dx
                z = z - dz
            end
        end
    end
end



return {
    drawLine = drawLine
}