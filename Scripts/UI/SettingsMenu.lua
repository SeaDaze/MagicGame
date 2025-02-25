
local BasicButton = require("Scripts.UI.BasicButton")

local SettingsMenu =
{
    Load = function(self)
        self.background = DrawSystem:LoadImage("Images/Background/settingsbackground.png")
        -- self.buttons = 
        -- {
        --     apply = BasicButton:New(
        --         GameConstants.UI.BasicButtonType.Rectangle,
        --         "Apply",
        --         { x = 100, y = 20 },
        --         GameConstants.UI.Anchor.Bottom
        --     ),
        --     resolutionLeft = BasicButton:New(
        --         GameConstants.UI.BasicButtonType.Square,
        --         "<",
        --         { x = 200, y = 20 },
        --         GameConstants.UI.Anchor.Top
        --     ),
        --     resolutionRight = BasicButton:New(
        --         GameConstants.UI.BasicButtonType.Square,
        --         ">",
        --         { x = 264, y = 20 },
        --         GameConstants.UI.Anchor.Top
        --     ),
        --     close = BasicButton:New(
        --         GameConstants.UI.BasicButtonType.Rectangle,
        --         "Close",
        --         { x = 20, y = 20 },
        --         GameConstants.UI.Anchor.Bottom
        --     ),
        -- }
        -- local resolution = GameConstants.WindowResolution[GameSettings.WindowResolutionScale]
        -- self.resolutionText = "" .. resolution.x .. " x " .. resolution.y
        -- self.active = false
        -- self.newResolutionScale = nil
        -- self.buttons.resolutionLeft:AddListener(self, "OnDecreaseResolutionClicked")
        -- self.buttons.resolutionRight:AddListener(self, "OnIncreaseResolutionClicked")
        -- self.buttons.apply:AddListener(self, "OnApplyButtonClicked")
        -- self.buttons.close:AddListener(self, "OnCloseClicked")

        -- self.hooks = {}
        -- self.hookId = {}
       -- Input:AddKeyListener("escape", self, "ToggleActive")
    end,

    Update = function(self, dt)
        if not self.active then
            return
        end
        for _, button in pairs(self.buttons) do
            button:Update(dt)
        end
    end,

    Draw = function(self)
        if not self.active then
            return
        end
        love.graphics.draw(self.background, 0, 0, 0, GameSettings.WindowResolutionScale, GameSettings.WindowResolutionScale)
        for _, button in pairs(self.buttons) do
            button:Draw()
        end

        if self.newResolutionScale then
            love.graphics.setColor(1, 1, 0, 1)
        end
        love.graphics.print(self.resolutionText, GameConstants.UI.Font, 400, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    OnIncreaseResolutionClicked = function(self)
        if self.newResolutionScale then
            if self.newResolutionScale < GameConstants.WindowResolution.Max then
                self.newResolutionScale = self.newResolutionScale + 1
            end
        elseif GameSettings.WindowResolutionScale < GameConstants.WindowResolution.Max then
            self.newResolutionScale = GameSettings.WindowResolutionScale + 1
        end

        if self.newResolutionScale == GameSettings.WindowResolutionScale then
            self.newResolutionScale = nil
        end

        local newResolution = GameConstants.WindowResolution[self.newResolutionScale or GameSettings.WindowResolutionScale]
        self.resolutionText = "" .. newResolution.x .. " x " .. newResolution.y

        print("OnIncreaseResolutionClicked: new resolution=", self.resolutionText)
    end,

    OnDecreaseResolutionClicked = function(self)
        if self.newResolutionScale then
            if self.newResolutionScale > 1 then
                self.newResolutionScale = self.newResolutionScale - 1
            end
        elseif GameSettings.WindowResolutionScale > 1 then
            self.newResolutionScale = GameSettings.WindowResolutionScale - 1
        end

        if self.newResolutionScale == GameSettings.WindowResolutionScale then
            self.newResolutionScale = nil
        end
        local newResolution = GameConstants.WindowResolution[self.newResolutionScale or GameSettings.WindowResolutionScale]
        self.resolutionText = "" .. newResolution.x .. " x " .. newResolution.y

        print("OnDecreaseResolutionClicked: new resolution=", self.resolutionText)
    end,

    OnApplyButtonClicked = function(self)
        if self.newResolutionScale then
            GameSettings.WindowResolutionScale = self.newResolutionScale
            local windowResolution = GameConstants.WindowResolution[self.newResolutionScale]
            love.window.setMode(windowResolution.x, windowResolution.y)
            self.newResolutionScale = nil

            for _, button in pairs(self.buttons) do
                button:Reset()
            end
        end
    end,

    OnCloseClicked = function(self)
        self:SetActive(false)
    end,

    GetActive = function(self)
        return self.active
    end,

    SetActive = function(self, active)
        if active then
            self.prevMouseVisible = love.mouse.isVisible()
            if not love.mouse.isVisible() then
                love.mouse.setVisible(true)
            end
        else
            if not self.prevMouseVisible then
                love.mouse.setVisible(false)
            end
        end

        self.active = active
    end,

    ToggleActive = function(self)
        if self.active then
            self:SetActive(false)
        else
            self:SetActive(true)
        end
    end,
}
return SettingsMenu