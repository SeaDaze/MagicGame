local Clickable = require ("Scripts.Clickable")
local Constants = require ("Scripts.Constants")

local MainMenu =
{
    Load = function(self, gameInstance)
        self.buttons = {}
        self.buttons.start = Clickable:New()
        self.buttons.start:ListenOnClicked(self, "OnStartClicked")
        self.gameInstance = gameInstance
    end,

    Update = function(self, dt)
        for _, button in pairs(self.buttons) do
            button:Update(dt)
        end
    end,

    Draw = function(self)
        love.graphics.print("Main Menu", 100, 10)

        for _, button in pairs(self.buttons) do
            button:Draw()
        end
    end,

    OnStartClicked = function(self)
        self.gameInstance:OnGameStateChanged(Constants.GameStates.Game)
    end,
}
return MainMenu