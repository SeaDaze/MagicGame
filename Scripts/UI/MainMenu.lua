
local BasicButton = require("Scripts.UI.BasicButton")

local MainMenu =
{
    Load = function(self)
        self.buttons = 
        {
            begin = BasicButton:New(
                GameConstants.UI.BasicButtonType.Rectangle,
                "Begin",
                { x = 20, y = 20 },
                GameConstants.UI.Anchor.Left
            ),
            settings = BasicButton:New(
                GameConstants.UI.BasicButtonType.Rectangle,
                "Settings",
                { x = 20, y = 100 },
                GameConstants.UI.Anchor.Left
            ),
        }
        self.buttons.begin:AddListener(self, "OnBeginClicked")
        self.buttons.settings:AddListener(self, "OnSettingsMenuClicked")
        self.logicActive = true
    end,

    OnStart = function(self)
		love.mouse.setVisible(true)
	end,

	OnStop = function(self)
	end,

    Update = function(self, dt)
        if not self.logicActive then
            return
        end
        for _, button in pairs(self.buttons) do
            button:Update(dt)
        end
    end,

    Draw = function(self)
        for _, button in pairs(self.buttons) do
            button:Draw()
        end
    end,

    OnBeginClicked = function(self)
        self:OnRequestGameStateChange(GameConstants.GameStates.Perform)
    end,

    OnRequestGameStateChange = function(self, newState)
        Common.ExecuteHooks(self, "OnRequestGameStateChange", { newState = newState })
    end,

    OnSettingsMenuClicked = function(self)
        self.logicActive = false
        SettingsMenu:SetActive(true)
        self.closeSettingsMenuHookId = SettingsMenu:HookFunction("OnCloseClicked", function()
            print("OnSettingsMenuClicked: Settings menu closed")
            self.logicActive = true
            SettingsMenu:UnhookFunction("OnCloseClicked", self.closeSettingsMenuHookId)
        end)
    end,

}
return MainMenu