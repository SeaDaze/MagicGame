local LeftHand = {
    HandleMovement = function(self, Flux, dt)
        if love.keyboard.isDown("w") then
            self.targetPosition.y = self.targetPosition.y - (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("a") then
            self.targetPosition.x = self.targetPosition.x - (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("s") then
            self.targetPosition.y = self.targetPosition.y + (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("d") then
            self.targetPosition.x = self.targetPosition.x + (self.moveSpeed * dt)
        end
        Flux.to(self.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y })
    end,

    Draw = function(self)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, math.rad(self.angle), 5, 5, (self.width / 2), self.height / 2)
    end,
}

LeftHand.__index = LeftHand
LeftHand.New = function()
    local instance = setmetatable({}, LeftHand)
    instance.sprite = love.graphics.newImage("Images/Hands/left_dealerGrip.png")
    instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
    instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
    instance.moveSpeed = 200
	instance.width = instance.sprite:getWidth()
	instance.height = instance.sprite:getHeight()
	instance.angle = 0
    return instance
end
return LeftHand