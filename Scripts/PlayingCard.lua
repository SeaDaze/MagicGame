
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

		-- Position/rotation/scale
		instance.position = position or { x = 0, y = 0 }
		instance.positionOffset = { x = 0, y = 0 }
		instance.angle = 0
		instance.targetAngle = 0
		instance.previousTargetAngle = 0
		instance.originOffset = { x = 0, y = 0 }
		instance.targetOriginOffset =  { x = 0, y = 0 }
		instance.previousOriginOffset = { x = 0, y = 0 }
		instance.scale = { x = 5, y = 5 }

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
		if self.state == GameConstants.CardStates.SpinningOut then
			self:Spin(dt)
		else
			if self.angle ~= self.targetAngle then
				Flux.to(self, self.angularSpeed, { angle = self.targetAngle })
			end
		end

		if self.originOffset ~= self.targetOriginOffset then
			Flux.to(self.originOffset, 0.3, { x = self.targetOriginOffset.x, y = self.targetOriginOffset.y })
		end

		if self.state == GameConstants.CardStates.InLeftHand then
			self:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
		elseif self.state == GameConstants.CardStates.InRightHandPinchPalmDown then
			self:SetPosition(self.rightHand:GetIndexFingerPosition())
		elseif self.state == GameConstants.CardStates.InRightHandPinchPalmUp then
			self:SetPosition(self.rightHand:GetPalmUpPinchFingerPosition())
		elseif self.state == GameConstants.CardStates.InRightHandTableSpread then
			self:SetPosition({x = self.rightHand.position.x, y = self.rightHand.position.y })
		end

		if self.state ~= GameConstants.CardStates.Dropped and self.position.x > love.graphics.getWidth() then
			self:SetState(GameConstants.CardStates.Dropped)
		end

		self:UpdateSockets()
	end,

    Draw = function(self)
		if self.facingUp then
			love.graphics.draw(
				self.spritesheet,
				self.quad,
				self.position.x + self.positionOffset.x,
				self.position.y + self.positionOffset.y,
				math.rad(self.angle),
				self.scale.x,
				self.scale.y,
				self.halfWidth + self.originOffset.x,
				self.halfHeight + self.originOffset.y
			)
        else
			love.graphics.draw(
				self.faceDownSprite,
				self.position.x + self.positionOffset.x,
				self.position.y + self.positionOffset.y,
				math.rad(self.angle),
				self.scale.x,
				self.scale.y,
				self.halfWidth + self.originOffset.x,
				self.halfHeight + self.originOffset.y
			)
		end

		-- love.graphics.setColor(0, 1, 0, 1)
		-- for key, socket in pairs(self.sockets) do
		-- 	love.graphics.ellipse("fill", socket.x, socket.y, 4, 4, 6)
		-- end
		-- love.graphics.setColor(1, 1, 1, 1)
    end,


	UpdateSockets = function(self)
		local positionOffsetVector = Common:ConvertAngleToVectorDirection(self.angle + 90)
        local positionOffsetDirection = Common:Normalize(positionOffsetVector)

		local offsetDistance = ((self.halfHeight - self.originOffset.y) * GameSettings.WindowResolutionScale)

		local offset = 
		{
			x = positionOffsetDirection.x * offsetDistance,
			y = positionOffsetDirection.y * offsetDistance,
		}
		self.sockets.bottomCenter = 
		{
			x = self.position.x + offset.x,
			y = self.position.y + offset.y,
		}
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

	GetBottomCenterSocket = function(self)
		return self.sockets.bottomCenter
	end,

	SetAngularSpeed = function(self, speed)
		self.angularSpeed = speed
	end,
}

PlayingCard.__index = PlayingCard

return PlayingCard