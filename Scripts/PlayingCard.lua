local Constants = require("Scripts.Constants")
local Common = require("Scripts.Common")

local PlayingCard = {
	New = function(self, value, suit, spritesheet, quad, position, faceDownSprite, leftHand, rightHand, flux)
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
		instance.angle = 0
		instance.targetAngle = 0
		instance.previousTargetAngle = 0
		instance.offset = { x = 0, y = 0 }
		instance.targetOffset =  { x = 0, y = 0 }
		instance.previousOffset = { x = 0, y = 0 }

		-- GameObject references
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.flux = flux

		-- States
		instance.state = Constants.CardStates.InDeck
		instance.facingUp = false
		instance.spinning = false
		instance.dropped = false
		
		-- Variables
		instance.value = value
		instance.suit = suit
		instance.spinningSpeed = 500

		return instance
	end,

	Update = function(self, Flux, dt)
		if self.state == Constants.CardStates.SpinningOut then
			self:Spin(dt)
		else
			-- if self.state ~= Constants.CardStates.InRightHand then
				
			-- end
			if self.angle ~= self.targetAngle then
				Flux.to(self, 0.3, { angle = self.targetAngle })
			end
		end

		if self.offset ~= self.targetOffset then
			Flux.to(self.offset, 0.3, { x = self.targetOffset.x, y = self.targetOffset.y })
		end

		if self.state == Constants.CardStates.InDeck then
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
		elseif self.state == Constants.CardStates.InRightHandPinchPalmDown then
			self:SetPosition(self.rightHand:GetIndexFingerPosition())
		elseif self.state == Constants.CardStates.InRightHandPinchPalmUp then
			self:SetPosition(self.rightHand:GetPalmUpPinchFingerPosition())
		end

		if self.state ~= Constants.CardStates.Dropped and self.position.x > love.graphics.getWidth() then
			self:ChangeState(Constants.CardStates.Dropped)
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
	-- State change functions
	-----------------------------------------------------------------------------------------------------------

	ChangeState = function(self, newState)
		if self.state == newState then
			print("ChangeState: cannot change state, newState == old state. state=", self.state)
			return
		end
		self.StateChangeFunctions[newState](self)
	end,

	StateChangeFunctions = 
	{
		[Constants.CardStates.InDeck] = function(self)
			self.state = Constants.CardStates.InDeck
		end,

		[Constants.CardStates.HeldBySpectator] = function(self)
			self.state = Constants.CardStates.HeldBySpectator
			self.targetOffset = { x = 0, y = 0 }
			self.targetAngle = 0
			self.facingUp = true
			self.flux.to(self.position, 0.5, { x = love.graphics.getWidth() / 2, y = 100 } )
		end,

		[Constants.CardStates.ReturningToDeck] = function(self)
			self.state = Constants.CardStates.ReturningToDeck
			self.facingUp = false
			self.flux.to(self.position, 0.35, { x = self.leftHand.position.x, y = self.leftHand.position.y } )
		end,

		[Constants.CardStates.SpinningOut] = function(self)
			self.state = Constants.CardStates.SpinningOut
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
			local randomY = love.math.random(0, love.graphics.getHeight())
			self.targetPosition = { x = love.graphics.getWidth() + 100, y = randomY }
			self.flux.to(self.position, 1.2, { x = self.targetPosition.x, y = self.targetPosition.y })
		end,

		[Constants.CardStates.Dropped] = function(self)
			self.state = Constants.CardStates.Dropped
		end,

		[Constants.CardStates.InRightHandPinchPalmDown] = function(self)
			self.state = Constants.CardStates.InRightHandPinchPalmDown
		end,

		[Constants.CardStates.InRightHandPinchPalmUp] = function(self)
			self.state = Constants.CardStates.InRightHandPinchPalmUp
			self.facingUp = true
		end,
	},


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