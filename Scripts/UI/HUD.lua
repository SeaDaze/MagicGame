local HUD =
{
    Load = function(self, playerStatsReference)
        self.font = love.graphics.newFont("Fonts/pixelifySans.ttf", 12)
        self.trickFont = love.graphics.newFont("Fonts/pixelifySans.ttf", 30)
		self.scoreFont = love.graphics.newFont("Fonts/micro5.ttf", 45)
        self.position = { x = 5, y = 5 }
        self.playerStats = playerStatsReference
        self.routineText = { "fan", "selection", "false cut", "double lift", "cardini" }
		self.scoreText = ""
        self.routineOffset = 0
		self.textOffsetInterval = 150
		self.routineIndex = 1
    end,

    Draw = function(self)
        love.graphics.printf("Money: " .. tostring(self.playerStats.Money), self.trickFont, self.position.x, self.position.y + 670, 500, "left")
        -- love.graphics.printf("Reputation: " .. tostring(self.playerStats.Reputation), self.font, self.position.x, self.position.y + 20, 500, "left")
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.printf("FPS: " .. tostring(love.timer.getFPS()), self.font, self.position.x, self.position.y, 500, "left")
		love.graphics.setColor(1, 1, 1, 1)
        local x = 0
        local opacity = 1
        for index, text in pairs(self.routineText) do
			if index == self.routineIndex then
				opacity = 1
			else
				opacity = 0.25
			end
            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.printf(text, self.trickFont, (x + self.routineOffset), love.graphics.getHeight() - 60, love.graphics.getWidth(), "center")
            x = x + self.textOffsetInterval
        end
        love.graphics.setColor(self.scoreTextRed or 1, self.scoreTextGreen or 1, 0, 1)
		love.graphics.printf(self.scoreText, self.scoreFont, 0, love.graphics.getHeight() - 150, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end,

    SetRoutineText = function(self, textTable)
        self.routineText = textTable
    end,

	SetRoutineIndex = function(self, index)
		self.routineIndex = index
		Flux.to(self, 0.5, { routineOffset = (self.routineIndex - 1) * (-self.textOffsetInterval) })
	end,

	SetScoreText = function(self, scoreText)
        self.scoreText = scoreText .. "!"
        if type(scoreText) ~= "number" then
            return
        end
        if scoreText == 0 then
            self.scoreTextRed = 1
            self.scoreTextGreen = 0
        else
            self.scoreTextRed = (100 - scoreText) / 100
            self.scoreTextGreen = scoreText / 100
        end
	end,

}
return HUD