local Common = require("Scripts.Common")

local AICharacter =
{
	New = function(self, facingRight, position, playerReference, aicharacterSprite, id)
		local instance = setmetatable({}, self)
        
        instance.movementSpeed = math.random(35, 45)
        instance.position = position or { x = 0, y = 510 }
        instance.facingRight = facingRight
		instance.moving = true
		instance.cameraMovementDelta = 0
        instance.withinPlayerRange = false
        instance.distanceSqWithinRange = 400
        instance.playerReference = playerReference
        instance.aicharacterSprite = aicharacterSprite
        instance.id = id
		return instance
	end,

    Update = function(self, Flux, dt)
        self:EvaluateWithinPlayerRange()
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

    GetPlayerWithinRange = function(self)
        return Common:DistanceSquared(self.position.x, self.position.y, self.playerReference.position.x, self.playerReference.position.y) < self.distanceSqWithinRange
    end,

    EvaluateWithinPlayerRange = function(self)
        if not self.withinPlayerRange and self:GetPlayerWithinRange() then
            self.playerReference:OnAIEnteredRange(self)
            self.withinPlayerRange = true
        elseif self.withinPlayerRange and not self:GetPlayerWithinRange() then
            self.playerReference:OnAIExitedRange(self)
            self.withinPlayerRange = false
        end
    end,
}

AICharacter.__index = AICharacter
return AICharacter