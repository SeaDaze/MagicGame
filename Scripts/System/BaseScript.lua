
-- Base script which can be inherited by any other script
-- Has useful base wrapper functionality

local BaseScript = 
{
    OnStart = function(self)
        self.testNumber = 12
        Log.Med("OnStart: BaseScript")
    end,
}
return BaseScript