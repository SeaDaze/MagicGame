
local PlayingCard = {
	New = function(self, value, suit, sprite, faceDownDrawable, leftHand, rightHand)
		local instance = setmetatable({}, self)

		-- Sprites
		instance.sprite = sprite
		instance.faceUpDrawable = sprite:GetDrawable()
		instance.faceDownDrawable = faceDownDrawable
		instance.sprite:SetDrawable(instance.faceDownDrawable)

		-- Position/rotation/scale
		instance.targetAngle = 0
		instance.previousTargetAngle = 0
		instance.targetOriginOffsetRatio =  { x = 0.5, y = 0.5 }

		instance.scaleModifier = 1
		instance.scale = { x = GameSettings.WindowResolutionScale * instance.scaleModifier, y = GameSettings.WindowResolutionScale * instance.scaleModifier }

		instance.sockets = 
		{
			bottomCenter = {
				x = 0,
				y = 0,
			}
		}

		-- GameObject references
		instance.leftHand = leftHand
		instance.rightHand = rightHand

		-- States
		instance.state = GameConstants.CardStates.InLeftHand
		instance.facingUp = false
		instance.spinning = false
		instance.dropped = false

		-- Variables
		instance.value = value
		instance.suit = suit
		instance.spinningSpeed = 500
		instance.angularSpeed = 1

		return instance
	end,

	Update = function(self, dt)
		self:UpdateSpriteOriginOffsetRatio()

		-- if self.state == GameConstants.CardStates.SpinningOut then
		-- 	self:Spin(dt)
		-- else
		if self.angle ~= self.targetAngle then
			Flux.to(self.sprite, self.angularSpeed, { angle = self.targetAngle })
		end
		-- end

		if self.state == GameConstants.CardStates.InLeftHand then
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y, z = self.leftHand.position.z })
		-- elseif self.state == GameConstants.CardStates.InRightHandPinchPalmDown then
		-- 	self:SetPosition(self.rightHand:GetIndexFingerPosition())
		-- elseif self.state == GameConstants.CardStates.InRightHandPinchPalmUp then
		-- 	self:SetPosition(self.rightHand:GetPalmUpPinchFingerPosition())
		-- elseif self.state == GameConstants.CardStates.InRightHandTableSpread then
		-- 	self:SetPosition({x = self.rightHand.position.x, y = self.rightHand.position.y })
		end

		-- if self.state ~= GameConstants.CardStates.Dropped and self.sprite.position.x > love.graphics.getWidth() then
		-- 	self:SetState(GameConstants.CardStates.Dropped)
		-- end

		self:UpdateSockets()
	end,

	UpdateSpriteOriginOffsetRatio = function(self)
		Flux.to(self.sprite.originOffsetRatio, 0.3, { x = self.targetOriginOffsetRatio.x, y = self.targetOriginOffsetRatio.y })
	end,

	UpdateSockets = function(self)
		-- Down
		local verticalOffsetDistance = self.sprite.height * GameSettings.WindowResolutionScale / 2 --((self.sprite.height - (self.sprite.originOffsetRatio.y * self.sprite.height)) * GameSettings.WindowResolutionScale)
		local horizontalOffsetDistance = self.sprite.width * GameSettings.WindowResolutionScale / 2 --((self.sprite.width - (self.sprite.originOffsetRatio.y * self.sprite.width)) * GameSettings.WindowResolutionScale)
	
		local positionOffsetVector = Common:ConvertAngleToVectorDirection(self.sprite.angle + 90)
        local positionOffsetDirection = Common:Normalize(positionOffsetVector)

		local halfWidth = self.sprite.width * GameSettings.WindowResolutionScale * 0.5
		local halfHeight = self.sprite.height * GameSettings.WindowResolutionScale * 0.5

		self.sockets.center = 
		{
			x = self.sprite.position.x + halfWidth,
			y = self.sprite.position.y + halfHeight,
		}

		-- self.sockets.bottomCenter = 
		-- {
		-- 	x = self.sprite.position.x + (positionOffsetDirection.x * verticalOffsetDistance),
		-- 	y = self.sprite.position.y + (positionOffsetDirection.y * verticalOffsetDistance),
		-- }

		-- positionOffsetVector = Common:ConvertAngleToVectorDirection(self.sprite.angle + 270)
        -- positionOffsetDirection = Common:Normalize(positionOffsetVector)
		-- self.sockets.topCenter = 
		-- {
		-- 	x = self.sprite.position.x + (positionOffsetDirection.x * verticalOffsetDistance),
		-- 	y = self.sprite.position.y + (positionOffsetDirection.y * verticalOffsetDistance),
		-- }
	end,

	-----------------------------------------------------------------------------------------------------------
	-- State change functions
	-----------------------------------------------------------------------------------------------------------

	SetState = function(self, newState)
		if self.state == newState then
			print("SetState: cannot change state, newState == old state. state=", self.state)
			return
		end
		self.StateChangeFunctions[newState](self)
	end,

	StateChangeFunctions = 
	{
		[GameConstants.CardStates.InLeftHand] = function(self)
			self.state = GameConstants.CardStates.InLeftHand
		end,

		[GameConstants.CardStates.HeldBySpectator] = function(self)
			self.state = GameConstants.CardStates.HeldBySpectator
			self.targetOriginOffset = { x = 0, y = 0 }
			self.targetAngle = 0
			self.facingUp = true
			Flux.to(self.position, 0.5, { x = love.graphics.getWidth() / 2, y = 100 } )
		end,

		[GameConstants.CardStates.ReturningToDeck] = function(self)
			self.state = GameConstants.CardStates.ReturningToDeck
			self.facingUp = false
			Flux.to(self.position, 0.35, { x = self.leftHand.position.x, y = self.leftHand.position.y } )
		end,

		[GameConstants.CardStates.SpinningOut] = function(self)
			self.state = GameConstants.CardStates.SpinningOut
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
			local randomY = love.math.random(0, love.graphics.getHeight())
			self.targetPosition = { x = love.graphics.getWidth() + 100, y = randomY }
			Flux.to(self.position, 1.2, { x = self.targetPosition.x, y = self.targetPosition.y })
		end,

		[GameConstants.CardStates.Dropped] = function(self)
			self.state = GameConstants.CardStates.Dropped
		end,

		[GameConstants.CardStates.InRightHandPinchPalmDown] = function(self)
			self.state = GameConstants.CardStates.InRightHandPinchPalmDown
		end,

		[GameConstants.CardStates.InRightHandPinchPalmUp] = function(self)
			self.state = GameConstants.CardStates.InRightHandPinchPalmUp
			self.facingUp = true
		end,

		[GameConstants.CardStates.InRightHandTableSpread] = function(self)
			self.state = GameConstants.CardStates.InRightHandTableSpread
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

	GetState = function(self)
		return self.state
	end,

	SetFacingUp = function(self, facingUp)
		if facingUp then
			self.sprite:SetDrawable(self.faceUpDrawable)
		else
			self.sprite:SetDrawable(self.faceDownDrawable)
		end
		self.facingUp = facingUp
	end,

    SetPosition = function(self, newPosition)
        self.sprite.position = 
		{
			x = newPosition.x,
			y = newPosition.y,
			z = newPosition.z or 0
		}
    end,

    GetPosition = function(self)
        return self.sprite.position
    end,

	GetDropped = function(self)
		return self.dropped
	end,

	SetDropped = function(self, isDropped)
		self.dropped = isDropped
	end,

	GetBottomCenterSocket = function(self)
		return self.sockets.bottomCenter
	end,

	SetAngularSpeed = function(self, speed)
		self.angularSpeed = speed
	end,

	GetSprite = function(self)
		return self.sprite
	end,

	SetTargetOriginOffsetRatio = function(self, newOffsetRatio)
		self.targetOriginOffsetRatio = 
		{
			x = newOffsetRatio.x,
			y = newOffsetRatio.y,
		}
	end,
}

PlayingCard.__index = PlayingCard

return PlayingCard