
local TestScript = require("Scripts/Test/TestScript")

local TestEnvironment2 = 
{
    Load = function(self)
        TestScript:OnStart()
    end,

    Update = function(self, dt)

    end,

    Draw = function(self)

    end,
}
return TestEnvironment2