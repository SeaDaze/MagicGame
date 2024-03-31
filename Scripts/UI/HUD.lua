local HUD =
{
    Load = function(self, playerStatsReference)
        self.font = love.graphics.newFont("Fonts/pixelFont.ttf",20)
        self.position = { x = 5, y = 5 }
        self.playerStats = playerStatsReference
    end,

    Draw = function(self)
        love.graphics.printf("Money: " .. tostring(self.playerStats.Money), self.font, self.position.x, self.position.y, 500, "left")
        love.graphics.printf("Reputation: " .. tostring(self.playerStats.Reputation), self.font, self.position.x, self.position.y + 20, 500, "left")
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.printf("FPS: " .. tostring(love.timer.getFPS()), self.font, self.position.x, self.position.y + 40, 500, "left")
		love.graphics.setColor(1, 1, 1, 1)
    end,
}
return HUD