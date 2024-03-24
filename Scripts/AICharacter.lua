local AICharacter =
{
	New = function(self, facingRight)
		local instance = setmetatable({}, self)
        instance.aicharacterSprite = love.graphics.newImage("Images/Characters/character_02.png")
        instance.movementSpeed = 40
		local x = facingRight and 0 or love.graphics.getWidth()
        instance.position = { x = x, y = 510 }
        instance.facingRight = facingRight
		instance.moving = true
		instance.cameraMovementDelta = 0
		return instance
	end,

    Update = function(self, Flux, dt)
		if not self.moving then
			return
		end
		self.cameraMovementDelta = 0
		if love.keyboard.isDown("a") then
            self.cameraMovementDelta = 60 * dt
        elseif love.keyboard.isDown("d") then
			self.cameraMovementDelta = -60 * dt
        end

		local movementDelta = self.movementSpeed * dt
		movementDelta = self.facingRight and movementDelta or movementDelta * -1
		self.position.x = self.position.x + movementDelta + self.cameraMovementDelta
    end,

    Draw = function(self)
        local scale = 4
        if not self.facingRight then
            scale = -4
        end
        love.graphics.draw(self.aicharacterSprite, self.position.x, self.position.y, 0, scale, 4, self.aicharacterSprite:getWidth() / 2)
    end,
}

AICharacter.__index = AICharacter
return AICharacter