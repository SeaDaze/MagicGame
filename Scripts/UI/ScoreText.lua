
local System = require("Scripts.System.System")
local BaseScript = require("Scripts.System.BaseScript")
local LocalTimer = require("Scripts.Timer")

local ScoreText = 
{
	Create = function(self, score)
		self.text = Text:New(
            tostring(score),
            GameConstants.UI.Font,
            { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		DrawSystem:AddDrawable(self.text)

		local timer = LocalTimer:New()
		timer:AddListener(self, "OnTimerFinished")
		timer:Start("ScoreText", 5)
	end,
}
return System:CreateChainedInheritanceScript(
	BaseScript,
	ScoreText
)