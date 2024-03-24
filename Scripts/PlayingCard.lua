local Constants = require("Scripts.Constants")

local PlayingCard = {
    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    Draw = function(self)
		if self.facingUp then
			love.graphics.draw(
				self.spritesheet,
				self.quad,
				self.position.x,
				self.position.y,
				math.rad(self.angle),
				4,
				4,
				self.halfWidth + self.offset.x,
				self.halfHeight + self.offset.y
			)
        else
			love.graphics.draw(
				self.faceDownSprite,
				self.position.x,
				self.position.y,
				math.rad(self.angle),
				4,
				4,
				self.halfWidth + self.offset.x,
				self.halfHeight + self.offset.y
			)
		end
    end,

	SetFacingUp = function(self, facingUp)
		self.facingUp = facingUp
	end,
}

PlayingCard.__index = PlayingCard
PlayingCard.New = function(value, suit, spritesheet, quad, position, faceDownSprite)
    local instance = setmetatable({}, PlayingCard)
	instance.value = value
	instance.suit = suit
    instance.spritesheet = spritesheet
    instance.quad = quad
	instance.facingUp = false
	instance.faceDownSprite = faceDownSprite
    instance.position = position or { x = 0, y = 0 }
	instance.targetPosition = position or { x = 0, y = 0 }
	instance.angle = 0
	instance.targetAngle = 0
	instance.offset = { x = 0, y = 0 }
	instance.targetOffset =  { x = 0, y = 0 }
	instance.previousOffset = { x = 0, y = 0 }
	local width, height = quad:getTextureDimensions()
	instance.halfWidth = (width / 13) / 2
	instance.halfHeight = (height / 4) / 2
	instance.given = false

    return instance
end
return PlayingCard