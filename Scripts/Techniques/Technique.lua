local Common = require("Scripts.Common")

local Technique = 
{
    GetScore = function(self)
        return self.score or 0
    end,

	Technique_GetTechniqueCard = function(self)
		return self.techniqueCard
	end,
}

Technique.__index = Technique
return Technique