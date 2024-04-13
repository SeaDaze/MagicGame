local HUD =
{
    Load = function(self, playerStatsReference)
        self.font = love.graphics.newFont("Fonts/pixelFont.ttf", 20)
        self.trickFont = love.graphics.newFont("Fonts/vollkorn.ttf", 30)
        self.position = { x = 5, y = 5 }
        self.playerStats = playerStatsReference
        self.equippedTechnique = ""
        self.routineText = { "fan", "selection", "false cut", "double lift", "cardini" }
        self.routineOffset = 0
    end,

    Draw = function(self)
        love.graphics.printf("Money: " .. tostring(self.playerStats.Money), self.font, self.position.x, self.position.y, 500, "left")
        love.graphics.printf("Reputation: " .. tostring(self.playerStats.Reputation), self.font, self.position.x, self.position.y + 20, 500, "left")
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.printf("FPS: " .. tostring(love.timer.getFPS()), self.font, self.position.x, self.position.y + 40, 500, "left")
		love.graphics.setColor(1, 1, 1, 1)
        local x = 0
        local opacity = 1
        for key, text in pairs(self.routineText) do
            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.printf(text, self.trickFont, 0 + x + self.routineOffset, love.graphics.getHeight() - 60, love.graphics.getWidth(), "center")
            if x == 0 then
                opacity = opacity - 0.6
            else
                opacity = opacity - 0.1
            end
            x = x + 150
        end
        love.graphics.setColor(1, 1, 1, 1)
    end,

    SetEquippedTechnique = function(self, newText)
        self.equippedTechnique = newText
    end,
}
return HUD