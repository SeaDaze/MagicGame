

local Common = {
	AABB = function(self, objA, objB)
		local error = false
		if not objA.position.x or not objA.position.y or not objA.width or not objA.height then
			print("Common:AABB - objA setup is missing a parameter")
			error = true
		end
		if not objB.position.x or not objB.position.y or not objB.width or not objB.height then
			print("Common:AABB - objB setup is missing a parameter")
			error = true
		end
		if error then
			return nil
		end
		if objA.position.x > (objB.position.x + objB.width) then
			return false
		elseif (objA.position.x + objA.width) < objB.position.x then
			return false
		elseif objA.position.y > (objB.position.y + objB.height) then
			return false
		elseif (objA.position.y + objA.height) < objB.position.y then
			return false
		end
		return true
	end,

	DistanceSquared = function(self, x1, y1, x2, y2)
		return (x2-x1)^2 + (y2-y1)^2
	end,

	Distance = function(self, x1, y1, x2, y2)
		return math.sqrt(self:DistanceSquared(x1, y1, x2, y2))
	end,

	AngleBetweenVectors = function(self, a, b)
		local dot = (a.x * b.x) + (a.y * b.y)

		local aMagnitude = math.sqrt((a.x * a.x) + (a.y * a.y))
		local bMagnitude = math.sqrt((b.x * b.x) + (b.y * b.y))

		local angleRad = math.acos(dot / (aMagnitude * bMagnitude))

		return math.deg(angleRad)
	end,

	ConvertAngleToVectorDirection = function(self, angleDeg)
		local rad = math.rad(angleDeg)
		return {
			x = math.cos(rad),
			y = math.sin(rad),
		}
	end,

	DotProduct = function(self, a, b)
		local value = 0
		for i = 1, #a do
			value = value + (a[i] * b[i])
		end
		return value
	end,

	Determinant = function(self, a, b)
		local value = 0
		for i = 1, #a do
			value = value - (a[i] * b[i])
		end
		return value
	end,

	Normalize = function(self, vec)
		local length = math.sqrt((vec.x * vec.x) + (vec.y * vec.y))
		return { x = vec.x / length, y = vec.y / length }
	end,

	Clamp = function(self, num, lower, upper)
		if num > upper then
			return upper
		end
		if num < lower then
			return lower
		end
		return num
	end,

	RotatePointAroundPoint = function(self, point, axisPoint, degrees)
		local rad = math.rad(degrees)
		local s = math.sin(rad)
		local c = math.cos(rad)

		-- Translate point to origin
		local translatedPoint = {
			x = point.x - axisPoint.x,
			y = point.y - axisPoint.y,
		}
		-- Rotate point aroud origin and translate back using axis point
		local rotatedPoint = {
			x = (translatedPoint.x * c) - (translatedPoint.y * s) + axisPoint.x,
			y = (translatedPoint.x * s) + (translatedPoint.y * c) + axisPoint.y,
		}
		
		return rotatedPoint
	end,
}
return Common