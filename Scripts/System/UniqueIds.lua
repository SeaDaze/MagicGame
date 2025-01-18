
local UniqueIds = 
{
	IDs = {},

	GenerateNew = function(self)
		local id
		repeat
			id = math.random(1000000, 9999999)
		until not self.IDs[id]

		self.IDs[id] = true
		return id
	end,
}
return UniqueIds