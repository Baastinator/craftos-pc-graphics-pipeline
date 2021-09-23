local round = function(number, digits)
    digits = digits or 0
    number = number * (10^digits)
    number = number + 0.5
    number = math.floor(number)
    number = number / (10^digits)
    return number
end

local function average(T)
    local output = 0
    local num = 4
    if T.N == nil then
        T.N = 0
        num = num - 1
    end
    if T.E == nil then
        T.E = 0
        num = num - 1
    end
    if T.S == nil then
        T.S = 0
        num = num - 1
    end
    if T.W == nil then
        T.W = 0
        num = num - 1
    end
    output = output + T.N
    output = output + T.E 
    output = output + T.S
    output = output + T.W
    ---@diagnostic disable-next-line: undefined-field
    return (output)/num
end

return {
    average = average,
    round = round,
}
