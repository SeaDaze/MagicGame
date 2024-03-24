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
}
return Common