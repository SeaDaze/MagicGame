
local PlayingCard = {

	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================
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
		instance.originOffsetRatio = { x = 0.5, y = 0.5 }
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
		instance.state = GameConstants.CardStates.InLeftHandDefault
		instance.facingUp = false
		instance.spinning = false
		instance.dropped = false

		-- Variables
		instance.value = value
		instance.suit = suit
		instance.spinningSpeed = 500
		instance.angularSpeed = 0.2

		return instance
	end,

	Update = function(self, dt)
		self:UpdateSpriteOriginOffsetRatio()
		if self.UpdateFunctionsByState[self.state] then
			self.UpdateFunctionsByState[self.state](self)
		end

		-- if self.state == GameConstants.CardStates.SpinningOut then
		-- 	self:Spin(dt)
		-- else

		-- end

		--if self.state == GameConstants.CardStates.InLeftHandDefault then
		--	self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y, z = self.leftHand.position.z })
		-- elseif self.state == GameConstants.CardStates.InRightHandPinchPalmDown then
		-- 	self:SetPosition(self.rightHand:GetIndexFingerPosition())
		-- elseif self.state == GameConstants.CardStates.InRightHandPinchPalmUp then
		-- 	self:SetPosition(self.rightHand:GetPalmUpPinchFingerPosition())
		-- elseif self.state == GameConstants.CardStates.InRightHandTableSpread then
		-- 	self:SetPosition({x = self.rightHand.position.x, y = self.rightHand.position.y })
		--end

		-- if self.state ~= GameConstants.CardStates.Dropped and self.sprite.position.x > love.graphics.getWidth() then
		-- 	self:SetState(GameConstants.CardStates.Dropped)
		-- end
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================

	Flip = function(self)
		self.facingUp = not self.facingUp
	end,

	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================

	UpdateSpriteOriginOffsetRatio = function(self)
		Flux.to(self.originOffsetRatio, 0.3, { x = self.targetOriginOffsetRatio.x, y = self.targetOriginOffsetRatio.y })
		self.sprite:SetOriginOffsetRatio(self.originOffsetRatio)
	end,

	StateChangeFunctions = 
	{
		[GameConstants.CardStates.InLeftHandDefault] = function(self)
			self.state = GameConstants.CardStates.InLeftHandDefault
		end,

		[GameConstants.CardStates.InLeftHandFanning] = function(self)
			self.state = GameConstants.CardStates.InLeftHandFanning
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

	UpdateFunctionsByState = 
	{
		[GameConstants.CardStates.InLeftHandDefault] = function(self)
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y, z = self.leftHand.position.z })
			self:RotateTowardsTargetAngle()
		end,

		[GameConstants.CardStates.InLeftHandFanning] = function(self)
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y, z = self.leftHand.position.z })
		end,

		[GameConstants.CardStates.HeldBySpectator] = function(self)
		end,

		[GameConstants.CardStates.ReturningToDeck] = function(self)
		end,

		[GameConstants.CardStates.SpinningOut] = function(self)
		end,

		[GameConstants.CardStates.Dropped] = function(self)
		end,

		[GameConstants.CardStates.InRightHandPinchPalmDown] = function(self)
		end,

		[GameConstants.CardStates.InRightHandPinchPalmUp] = function(self)
		end,

		[GameConstants.CardStates.InRightHandTableSpread] = function(self)
		end,
	},

	Spin = function(self, dt)
		self.angle = self.angle + (self.spinningSpeed * dt)
	end,

	RotateTowardsTargetAngle = function(self)
		if self.angle ~= self.targetAngle then
			Flux.to(self.sprite, self.angularSpeed, { angle = self.targetAngle })
		end
	end,

	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================

	SetState = function(self, newState)
		if self.state == newState then
			print("SetState: cannot change state, newState == old state. state=", table.findKey(GameConstants.CardStates, newState))
			return
		end
		if not self.StateChangeFunctions[newState] then
			print("SetState: state change function not set up for state=", table.findKey(GameConstants.CardStates, newState))
			return
		end
		self.StateChangeFunctions[newState](self)
	end,

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

	-- ===========================================================================================================
	-- #endregion

}

PlayingCard.__index = PlayingCard

return PlayingCard