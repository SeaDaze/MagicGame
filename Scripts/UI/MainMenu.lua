
local Constants = require ("Scripts.Constants")
local Button = require("Scripts.UI.Button")

local MainMenu =
{
    Load = function(self, gameInstance)
        love.mouse.setVisible(true)
        self.settingsButton = Button:New("settings", { x = 10, y = 20}, 80, 45, 10)
        self.gameInstance = gameInstance
    end,

    Update = function(self, dt)
        self.settingsButton:Update(dt)
    end,

    Draw = function(self)
        self.settingsButton:Draw()
    end,
}
return MainMenu