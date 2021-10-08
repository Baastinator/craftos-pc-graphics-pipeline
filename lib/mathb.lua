local round = function(number, digits)
    digits = digits or 0
    number = number * (10^digits)
    number = number + 0.5
    number = math.floor(number)
    number = number / (10^digits)
    return number
end

return {
    round = round,
}
