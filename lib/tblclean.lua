function clean(input)
    local output = {}
    for k, v in pairs(input) do
        if (type(v) ~= "function") then
            if (type(v)=="table") then
                output[k] = clean(v)
            else
                output[k] = v
            end
        else
            output[k] = "function"
        end
    end
    return output
end