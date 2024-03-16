local Constants = require("Scripts.Contants")

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
				1,
				1,
				(Constants.CardDimensions.Width / 2) + self.offset.x,
				(Constants.CardDimensions.Height / 2) + self.offset.y
			)
        else
			love.graphics.draw(
				self.faceDownSpritesheet,
				self.faceDownQuad,
				self.position.x,
				self.position.y,
				math.rad(self.angle),
				1,
				1,
				(Constants.CardDimensions.Width / 2) + self.offset.x,
				(Constants.CardDimensions.Height / 2) + self.offset.y
			)
		end
    end,

	SetFacingUp = function(self, facingUp)
		self.facingUp = facingUp
	end,
}

PlayingCard.__index = PlayingCard
PlayingCard.New = function(value, suit, spritesheet, quad, position, faceDownSpritesheet, faceDownQuad)
    local instance = setmetatable({}, PlayingCard)
	instance.value = value
	instance.suit = suit
    instance.spritesheet = spritesheet
    instance.quad = quad
	instance.facingUp = false
	instance.faceDownSpritesheet = faceDownSpritesheet
	instance.faceDownQuad = faceDownQuad
    instance.position = position or { x = 0, y = 0 }
	instance.angle = 0
	instance.offset = { x = 0, y = 0 }
	instance.halfWidth = Constants.CardDimensions.Width / 2
	instance.halfHeight = Constants.CardDimensions.Height / 2
    return instance
end
return PlayingCard