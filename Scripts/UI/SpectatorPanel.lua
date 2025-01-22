local EventIds = require "Scripts.System.EventIds"

local SpectatorPanel = 
{
	Load = function(self)
        self.drawable = love.graphics.newImage("Images/Background/SpectatorPanel.png")

        -- Components
        self.sprite = Sprite:New(
            self.drawable,
            { x = love.graphics.getWidth() - (2 * GameSettings.WindowResolutionScale), y = love.graphics.getHeight() / 2, z = 0 },
            0,
            1,
            DrawLayers.PerformanceMat,
            true,
            { x = 1, y = 0.5 }
        )

        EventSystem:ConnectToEvent(EventIds.ShowSpectatorPanel, self, "OnShowRequested")
        EventSystem:ConnectToEvent(EventIds.HideSpectatorPanel, self, "OnHideRequested")
	end,

	OnShowRequested = function(self)
        DrawSystem:AddDrawable(self.sprite)
    end,

    OnHideRequested = function(self)
        DrawSystem:RemoveDrawable(self.sprite)
    end,

}
return SpectatorPanel