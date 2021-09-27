local mathb = dofile("lib/mathb.lua")

local function new(x, y)
	return {x=x or 0, y=y or 0}
end

local function subtract(a,b)
    return new(
        a.x - b.x,
		a.y - b.y
    )
end

local function rotate(VectorInput, Angle, Origin)
	Origin = Origin or new(0,0)
	Angle = Angle * math.pi / 180 
	local Product = new(0,0)
	local ShiftedVector = new(VectorInput.x - Origin.x,VectorInput.y - Origin.y)
	Product.x = ShiftedVector.x * math.cos(Angle) - ShiftedVector.y * math.sin(Angle)
	Product.y = ShiftedVector.x * math.sin(Angle) + ShiftedVector.y * math.cos(Angle)
	Product.x = Product.x + Origin.x
	Product.y = Product.y + Origin.y
	Product.x = mathb.round(Product.x,8)
	Product.y = mathb.round(Product.y,8)
	return Product
end

local function multiply(VectorInput, Scalar)
	return new(
		VectorInput.x * Scalar,
		VectorInput.y * Scalar
	)
end

local function add(v1, v2)
	return new(
		v1.x + v2.x,
		v1.y + v2.y
	)
end

local function dot(a,b)
	return (
		a.x * b.x +
		a.y * b.y
	)	
end

local function getLength(a)
	return math.sqrt(a.x * a.x + a.y * a.y)
end

local function normalise(a)
	local length = getLength(a)
	return new(
		a.x / length,
		a.y / length
	)
end

local function getAngle(a,b,radians,normalised)
	radians = radians or false
	normalised = normalised or true
	local A = normalise(a)
	local B = normalise(b)
	local output = dot(A,B)
	output = math.acos(output)
	if radians == false then
		output = output * 180 / math.pi
	end
	if normalised == false then
		output = output * getLength(a) * getLength(b)
	end
	return output
end

return {
	getLength = getLength,
	getAngle = getAngle,
	normalise = normalise,
	dot = dot,
	subtract = subtract,
	add = add,
	multiply = multiply,
	new = new, 
	rotate = rotate,
}
