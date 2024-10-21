local Common = {
	DistanceSquared = function(self, x1, y1, x2, y2)
		return (x2-x1)^2 + (y2-y1)^2
	end,

	Distance = function(self, x1, y1, x2, y2)
		return math.sqrt(self:DistanceSquared(x1, y1, x2, y2))
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

	ExecuteHooks = function(target, functionName, params)
        for _, func in pairs(target.common_hooks[functionName]) do
            func(params)
        end
    end,

	---@param target table (Table which contains the target function we are hooking)
	---@param targetFunction string (Name of target function to hook)
	---@param hookedFunction function (Function to be called)
    HookFunction = function(target, targetFunction, hookedFunction)
		if not target.common_hookId then
			target.common_hookId = {}
		end
        if not target.common_hookId[targetFunction] then
            target.common_hookId[targetFunction] = 0
        end
		if not target.common_hooks then
			target.common_hooks = {}
		end
        if not target.common_hooks[targetFunction] then
            target.common_hooks[targetFunction] = {}
        end
        target.common_hookId[targetFunction] = target.common_hookId[targetFunction] + 1
        target.common_hooks[targetFunction][target.common_hookId[targetFunction]] = hookedFunction
        return target.common_hookId[targetFunction]
    end,

    UnhookFunction = function(target, targetFunction, common_hookId)
        target.common_hooks[targetFunction][common_hookId] = nil
    end,

}
return Common