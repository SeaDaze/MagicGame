local EventIds = require "Scripts.System.EventIds"
local Vector3  = require "Scripts.System.Vector3"

local SpectatorPanel = 
{
	Load = function(self)
        self.drawable = DrawSystem:LoadImage("Images/Background/SpectatorPanel.png")

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

        EventSystem:ConnectToEvent(EventIds.OnStartHoverSpectator, self, "OnStartHoverSpectator")
        EventSystem:ConnectToEvent(EventIds.OnStopHoverSpectator, self, "OnStopHoverSpectator")
		self.visible = false
		self.hoveredSpectators = {}
		self.selectedSpectator = nil
	end,

	OnStartHoverSpectator = function(self, spectator)
		table.insert(self.hoveredSpectators, spectator)
		if not self.visible then
			DrawSystem:AddDrawable(self.sprite)
			self.visible = true
		end
		self:EvaluatePriorityHoveredSpectator()
    end,

    OnStopHoverSpectator = function(self, spectator)
		table.removeByValue(self.hoveredSpectators, spectator)
		if table.isEmpty(self.hoveredSpectators) then
			DrawSystem:RemoveDrawable(self.sprite)
			self.visible = false
			self:CleanPanel()
		else
			self:EvaluatePriorityHoveredSpectator()
		end
    end,

	EvaluatePriorityHoveredSpectator = function(self)
		local prioritySpectator = self.hoveredSpectators[1]
		if prioritySpectator == self.selectedSpectator then
			return
		end
		if self.selectedSpectator then
			self:CleanPanel()
		end

		self.spectatorSpriteCopy = table.deepCopyWithMetaTable(prioritySpectator:GetSprite())
		self.spectatorSpriteCopy:SetOriginOffsetRatio({ x = 0, y = 0 })
		self.spectatorSpriteCopy:SetPosition(self.sprite:GetSocket("TopLeft"))
		self.spectatorSpriteCopy:SetScaleModifier(2)
		DrawSystem:AddDrawable(self.spectatorSpriteCopy)
		self.selectedSpectator = prioritySpectator
	end,

	CleanPanel = function(self)
		if self.spectatorSpriteCopy then
			DrawSystem:RemoveDrawable(self.spectatorSpriteCopy)
			self.spectatorSpriteCopy = nil
			self.selectedSpectator = nil
		end
	end,

}
return SpectatorPanel