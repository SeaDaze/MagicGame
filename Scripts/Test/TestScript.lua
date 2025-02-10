
local System = require("Scripts.System.System")
local BaseScript = require("Scripts.System.BaseScript")

local TestScript = 
{
    OnStart = function(self)
        Log.Med("OnStart: Test2", self.testNumber)
    end,
}
return System:CreateChainedInheritanceScript(
    BaseScript,
    TestScript
)