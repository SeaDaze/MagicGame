
local RightHand = {
	New = function(self)
		local instance = setmetatable({}, self)

		instance.spritePalmDown = love.graphics.newImage("Images/Hands/right_palmDown_ThumbIn.png")
		instance.spritePalmDownIndexOut = love.graphics.newImage("Images/Hands/right_palmDown_IndexOut.png")
		instance.spritePalmDownPinchNoThumb = love.graphics.newImage("Images/Hands/right_palmDown_PinchNoThumb.png")
		instance.spritePalmDownPinchThumbOnly = love.graphics.newImage("Images/Hands/right_palmDown_PinchThumbOnly.png")
		instance.spritePalmDownTableSpread = love.graphics.newImage("Images/Hands/right_palmDown_TableSpread.png")
		instance.spritePalmDownNatural = love.graphics.newImage("Images/Hands/right_palmDown_Natural.png")
		instance.spritePalmDownGrabOpen = love.graphics.newImage("Images/Hands/right_palmDown_GrabOpen.png")
		instance.spritePalmDownGrabClose = love.graphics.newImage("Images/Hands/right_palmDown_GrabClose.png")

		instance.spritePalmUp = love.graphics.newImage("Images/Hands/right_palmUp_ThumbIn.png")
		instance.spritePalmUpNoThumb = love.graphics.newImage("Images/Hands/right_palmUp_NoThumb.png")
		instance.spritePalmUpThumbOnly = love.graphics.newImage("Images/Hands/right_palmUp_ThumbOnly.png")

		instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.indexFingerOffset = { x = -25, y = -35 }
		instance.palmUpPinchOffset = { x = 25, y = -35 }

		instance.halfWidth = instance.spritePalmDown:getWidth() / 2
		instance.halfHeight = instance.spritePalmDown:getHeight() / 2
		instance.angle = 0
		instance.state = GameConstants.RightHandStates.PalmDownGrabOpen
		instance.visible = true
		instance.active = true
		instance.moveSpeed = 500

		instance.windowScaleMultiplier = 1
		return instance
	end,

    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    Update = function(self, dt)
		if not self.active then
			return
		end

		if Input:GetRightJoystickAxisPriority() then
			local horizontal = Input:GetInputAxis(GameConstants.InputAxis.Right.X)
			local vertical = Input:GetInputAxis(GameConstants.InputAxis.Right.Y)
	
			self.targetPosition.x = self.targetPosition.x + (horizontal * self.moveSpeed * dt)
			self.targetPosition.y = self.targetPosition.y + (vertical * self.moveSpeed * dt)
		else
			self.targetPosition = { x = love.mouse.getX(), y = love.mouse.getY() }
		end
		self.targetPosition.x = Common:Clamp(self.targetPosition.x, 0, love.graphics.getWidth())
		self.targetPosition.y = Common:Clamp(self.targetPosition.y, 0, love.graphics.getHeight())
        self.activeTween = Flux.to(self.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y})
    end,

    Draw = function(self)
		if not self.visible then
			return
		end
		--love.graphics.setColor(1, 1, 1, 0.8)
		if self.state == GameConstants.RightHandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchThumbOnly)
		elseif self.state == GameConstants.RightHandStates.PalmUp then
			self:DrawHand(self.spritePalmUp)
		elseif self.state == GameConstants.RightHandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpNoThumb)
		end
		--love.graphics.setColor(1, 1, 1, 1)
    end,

	LateDraw = function(self)
		if not self.visible then
			return
		end
		--love.graphics.setColor(1, 1, 1, 0.8)
		if self.state == GameConstants.RightHandStates.PalmDown then
			self:DrawHand(self.spritePalmDown)
		elseif self.state == GameConstants.RightHandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchNoThumb)
		elseif self.state == GameConstants.RightHandStates.PalmDownIndexOut then
			self:DrawHand(self.spritePalmDownIndexOut)
		elseif self.state == GameConstants.RightHandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpThumbOnly)
		elseif self.state == GameConstants.RightHandStates.PalmDownTableSpread then
			self:DrawHand(self.spritePalmDownTableSpread)
		elseif self.state == GameConstants.RightHandStates.PalmDownNatural then
			self:DrawHand(self.spritePalmDownNatural)
		elseif self.state == GameConstants.RightHandStates.PalmDownGrabOpen then
			self:DrawHand(self.spritePalmDownGrabOpen)
		elseif self.state == GameConstants.RightHandStates.PalmDownGrabClose then
			self:DrawHand(self.spritePalmDownGrabClose)
		end
		--love.graphics.setColor(1, 1, 1, 1)
    end,

    DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), GameSettings.WindowResolutionScale * self.windowScaleMultiplier, GameSettings.WindowResolutionScale * self.windowScaleMultiplier, self.halfWidth, self.halfHeight)
    end,

	SetState = function(self, newState)
		self.state = newState
	end,

	GetIndexFingerPosition = function(self)
		local pos = { x = self.position.x + self.indexFingerOffset.x, y = self.position.y + self.indexFingerOffset.y }
		return pos
	end,

	GetPalmUpPinchFingerPosition = function(self)
		local pos = { x = self.position.x + self.palmUpPinchOffset.x, y = self.position.y + self.palmUpPinchOffset.y }
		return pos
	end,

	GetPosition = function(self)
		return self.position
	end,
	
	Disable = function(self)
		self.active = false
		self.activeTween:stop()
	end,

	Enable = function(self)
		self.active = true
	end,
}
RightHand.__index = RightHand

return RightHand