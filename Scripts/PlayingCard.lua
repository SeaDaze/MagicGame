local Constants = require("Scripts.Constants")
local Common = require("Scripts.Common")

local PlayingCard = {
	New = function(self, value, suit, spritesheet, quad, position, faceDownSprite, leftHand, rightHand)
		local instance = setmetatable({}, self)

		-- Sprites
		instance.spritesheet = spritesheet
		instance.quad = quad
		instance.faceDownSprite = faceDownSprite
		local width, height = quad:getTextureDimensions()
		instance.width = (width / 13)
		instance.height = (height / 4)
		instance.halfWidth = instance.width / 2
		instance.halfHeight = instance.height / 2

		-- Position/rotation
		instance.position = position or { x = 0, y = 0 }
		instance.targetPosition = position or { x = 0, y = 0 }
		instance.angle = 0
		instance.targetAngle = 0
		instance.previousTargetAngle = 0
		instance.offset = { x = 0, y = 0 }
		instance.targetOffset =  { x = 0, y = 0 }
		instance.previousOffset = { x = 0, y = 0 }

		-- GameObject references
		instance.leftHand = leftHand
		instance.rightHand = rightHand

		-- State booleans
		instance.facingUp = false
		instance.out = false
		instance.spinning = false
		instance.inRightHand = false
		instance.dropped = false
		instance.heldBySpectator = false
		instance.handingBack = false
		
		-- Variables
		instance.value = value
		instance.suit = suit
		instance.spinningSpeed = 500

		return instance
	end,

	Update = function(self, Flux, dt)
		if self.spinning then
			self:Spin(dt)
		else
			if not self.inRightHand then
				if self.angle ~= self.targetAngle then
					Flux.to(self, 0.3, { angle = self.targetAngle })
				end
			end
		end

		if self.offset ~= self.targetOffset then
			Flux.to(self.offset, 0.3, { x = self.targetOffset.x, y = self.targetOffset.y })
		end

		if self.out then
			if self.inRightHand then
				self:SetPosition({x = self.rightHand.position.x, y = self.rightHand.position.y })
			else
				Flux.to(self.position, 1, { x = self.targetPosition.x, y = self.targetPosition.y } )
			end
		else
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
		end
	end,

    Draw = function(self)
		if self.facingUp then
			love.graphics.draw(
				self.spritesheet,
				self.quad,
				self.position.x,
				self.position.y,
				math.rad(self.angle),
				5,
				5,
				self.halfWidth + self.offset.x,
				self.halfHeight + self.offset.y
			)
        else
			love.graphics.draw(
				self.faceDownSprite,
				self.position.x,
				self.position.y,
				math.rad(self.angle),
				5,
				5,
				self.halfWidth + self.offset.x,
				self.halfHeight + self.offset.y
			)
		end
    end,

	-----------------------------------------------------------------------------------------------------------
	-- Public functions
	-----------------------------------------------------------------------------------------------------------
	Flip = function(self)
		self.facingUp = not self.facingUp
	end,

	Spin = function(self, dt)
		self.angle = self.angle + (self.spinningSpeed * dt)
	end,

	-----------------------------------------------------------------------------------------------------------
	-- Getters/Setters
	-----------------------------------------------------------------------------------------------------------
	SetFacingUp = function(self, facingUp)
		self.facingUp = facingUp
	end,

    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    GetPosition = function(self)
        return self.position
    end,

	GetDropped = function(self)
		return self.dropped
	end,

	SetDropped = function(self, isDropped)
		self.dropped = isDropped
	end,
}

PlayingCard.__index = PlayingCard

return PlayingCard