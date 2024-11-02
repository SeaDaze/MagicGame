
local Mat = 
{
    Load = function(self)
        self.mat = love.graphics.newImage("Images/Background/mat.png")
        self.balanceBar = love.graphics.newImage("Images/Background/BalanceBar.png")
        self.balanceBarIndicator = love.graphics.newImage("Images/Background/BalanceBarIndicator.png")
        self.baseScale = 4
    end,

    Draw = function(self)
		local centerX = love.graphics.getWidth() / 2
		local centerY = love.graphics.getHeight() / 2
		local matHalfWidth = (self.mat:getWidth() / 2) * self.baseScale
		local matHalfHeight = (self.mat:getHeight() / 2) * self.baseScale
		love.graphics.draw(self.mat, centerX - matHalfWidth, centerY - matHalfHeight, 0, 4, 4)
        --love.graphics.draw(self.balanceBar, centerX - matHalfWidth, centerY + matHalfHeight, 0, 4, 4)
        --love.graphics.draw(self.balanceBarIndicator, centerX - matHalfWidth, centerY + matHalfHeight, 0, 4, 4)
    end,
}

return Mat