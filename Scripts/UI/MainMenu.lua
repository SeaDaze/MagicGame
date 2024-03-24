
local Constants = require ("Scripts.Constants")

local MainMenu =
{
    Load = function(self, gameInstance)
        self.gameInstance = gameInstance
    end,

    Update = function(self, dt)
    end,

    Draw = function(self)

    end,

    OnStartClicked = function(self)
        self.gameInstance:OnGameStateChanged(Constants.GameStates.Perform)
    end,
}
return MainMenu