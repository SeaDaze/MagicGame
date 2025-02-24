
local System = require("Scripts.System.System")
local BaseScript = require("Scripts.System.BaseScript")
local LocalTimer = require("Scripts.Timer")
local EventIds   = require("Scripts.System.EventIds")

local ScoreText = 
{
	New = function(self, score)
		self.id = UniqueIds:GenerateNew()
		self.text = Text:New(
            tostring(score),
            GameConstants.UI.Font,
            { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		self.text.color = {1, 0, 0, 1}
		Flux.to(self.text.color, 5, { [4] = 0 })
		DrawSystem:AddDrawable(self.text)

		self.timer = LocalTimer:New()
		self.timer:AddListener(self, "OnTimerFinished")
		self.timer:Start("ScoreText", 5)

		return System:CreateChainedInheritanceScript(
			BaseScript,
			self
		)
	end,

	Update = function(self, dt)
		self.timer:Update(dt)
	end,

	OnTimerFinished = function(self, timerId)
		if timerId == "ScoreText" then
			DrawSystem:RemoveDrawable(self.text)
			EventSystem:BroadcastEvent(EventIds.OnFinishScoreTextLifetime, self.id)
		end
	end,
}
return ScoreText