local Common = {
	DistanceSquared = function(self, x1, y1, x2, y2)
		return (x2-x1)^2 + (y2-y1)^2
	end,

	TableCount = function(self, t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end,

	AngleBetweenVectors = function(self, a, b)
		return math.deg(math.atan2(b.y - a.y, b.x - a.x))
		-- local dot = self:DotProduct(a, b)
		-- local det = self:Determinant(a, b)

		-- return math.deg(math.atan2(det, dot))
		-- local a = math.deg(math.atan2(y2 - y1, x2 - x1))
		-- if a < 0 then
		-- 	return a + 360
		-- else
		-- 	return a
		-- end
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
		local length = math.sqrt(vec.x * vec.x + vec.y * vec.y)
		return { x = vec.x / length, y = vec.y / length }
	end,

}
return Common