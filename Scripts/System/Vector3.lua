

local Vector3 = {
	New = function (self, x, y, z)
		return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, self)
	end,

	__tostring = function(self)
    	return string.format("Vector3(%.2f, %.2f, %.2f)", self.x, self.y, self.z)
	end,

	__add = function(self, other)
		return self:New(self.x + other.x, self.y + other.y, self.z + other.z)
	end,

	__sub = function(self, other)
		return self:New(self.x - other.x, self.y - other.y, self.z - other.z)
	end,

	__mul = function(self, value)
		if type(value) == "number" then
			return self:New(self.x * value, self.y * value, self.z * value)
		else
			error("__mul: Multiplication requires a scalar value")
		end
	end,

	__div = function(self, value)
		if type(value) == "number" then
			return self:New(self.x / value, self.y / value, self.z / value)
		else
			error("__div: Division requires a scalar value")
		end
	end,

	__eq = function(self, other)
		return self.x == other.x and self.y == other.y and self.z == other.z
	end,

	__unm = function(self)
		return self:New(-self.x, -self.y, -self.z)
	end,

	Dot = function(self, other)
		return self.x * other.x + self.y * other.y + self.z * other.z
	end,

	Cross = function(self, other)
		return self:New(
			self.y * other.z - self.z * other.y,
			self.z * other.x - self.x * other.z,
			self.x * other.y - self.y * other.x
		)
	end,

	Magnitude = function(self)
		return math.sqrt(self.x^2 + self.y^2 + self.z^2)
	end,

	Normalize = function(self)
		local mag = self:magnitude()
		if mag == 0 then
			error("Normalize: Cannot normalize a zero vector.")
		end
		return self / mag
	end,

	Copy = function(self)
		return self:New(self.x, self.y, self.z)
	end,

}
Vector3.__index = Vector3
return Vector3