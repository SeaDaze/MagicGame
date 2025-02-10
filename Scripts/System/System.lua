
local System = {
	CreateChainedInheritanceScript = function(self, ...)
		local scripts = {...}
		local extractedFunctionLists = {}
		local createdScript = {}

		for i = 1, #scripts do
			for key, value in pairs(scripts[i]) do
				if type(value) == "function" then
					if not extractedFunctionLists[key] then
						extractedFunctionLists[key] = {}
					end
					table.insert(extractedFunctionLists[key], value)
				else
					createdScript[key] = value
				end
			end
		end

		for functionName, functionList in pairs(extractedFunctionLists) do
			createdScript[functionName] = self:CreateChainedFunction(functionList)
		end

		return createdScript
	end,

	CreateChainedFunction = function(self, functionList)
		return function(...)
			for index, func in ipairs(functionList) do
				func(...)
			end
		end
	end,
}
return System