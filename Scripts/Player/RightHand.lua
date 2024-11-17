local Hand = require("Scripts.Player.Hand")

local RightHand = setmetatable({
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
		instance.spritePalmDownRelaxed = love.graphics.newImage("Images/Hands/right_palmDown_Relaxed.png")
		instance.spritePalmDownRelaxedIndexOut = love.graphics.newImage("Images/Hands/right_palmDown_RelaxedIndexOut.png")

		instance.spritePalmUp = love.graphics.newImage("Images/Hands/right_palmUp_ThumbIn.png")
		instance.spritePalmUpNoThumb = love.graphics.newImage("Images/Hands/right_palmUp_NoThumb.png")
		instance.spritePalmUpThumbOnly = love.graphics.newImage("Images/Hands/right_palmUp_ThumbOnly.png")

		instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.indexFingerOffset = { x = -8, y = -12 }
		instance.palmUpPinchOffset = { x = 25, y = -35 }

		instance.halfWidth = instance.spritePalmDown:getWidth() / 2
		instance.halfHeight = instance.spritePalmDown:getHeight() / 2
		instance.angle = 0
		instance.state = GameConstants.HandStates.PalmDownGrabOpen
		instance.visible = true
		instance.active = true
		instance.moveSpeed = 500

		instance.windowScaleMultiplier = 1

		instance.nearbyPickups = {}
		instance.actionListenTarget = GameConstants.InputActions.Right

		return instance
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

	FixedUpdate = function(self, dt)
	end,
	
    Draw = function(self)
		if not self.visible then
			return
		end
		--love.graphics.setColor(1, 1, 1, 0.8)
		if self.state == GameConstants.HandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchThumbOnly)
		elseif self.state == GameConstants.HandStates.PalmUp then
			self:DrawHand(self.spritePalmUp)
		elseif self.state == GameConstants.HandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpNoThumb)
		end
		--love.graphics.setColor(1, 1, 1, 1)
    end,

	LateDraw = function(self)
		if not self.visible then
			return
		end
		--love.graphics.setColor(1, 1, 1, 0.8)
		if self.state == GameConstants.HandStates.PalmDown then
			self:DrawHand(self.spritePalmDown)
		elseif self.state == GameConstants.HandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchNoThumb)
		elseif self.state == GameConstants.HandStates.PalmDownIndexOut then
			self:DrawHand(self.spritePalmDownIndexOut)
		elseif self.state == GameConstants.HandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpThumbOnly)
		elseif self.state == GameConstants.HandStates.PalmDownTableSpread then
			self:DrawHand(self.spritePalmDownTableSpread)
		elseif self.state == GameConstants.HandStates.PalmDownNatural then
			self:DrawHand(self.spritePalmDownNatural)
		elseif self.state == GameConstants.HandStates.PalmDownGrabOpen then
			self:DrawHand(self.spritePalmDownGrabOpen)
		elseif self.state == GameConstants.HandStates.PalmDownGrabClose then
			self:DrawHand(self.spritePalmDownGrabClose)
		elseif self.state == GameConstants.HandStates.PalmDownRelaxed then
			self:DrawHand(self.spritePalmDownRelaxed)
		elseif self.state == GameConstants.HandStates.PalmDownRelaxedIndexOut then
			self:DrawHand(self.spritePalmDownRelaxedIndexOut)
		end
		--love.graphics.setColor(1, 1, 1, 1)
    end,

    DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), GameSettings.WindowResolutionScale * self.windowScaleMultiplier, GameSettings.WindowResolutionScale * self.windowScaleMultiplier, self.halfWidth, self.halfHeight)
    end,

	GetIndexFingerPosition = function(self)
		local pos = { 
			x = self.position.x + (self.indexFingerOffset.x * GameSettings.WindowResolutionScale),
			y = self.position.y + (self.indexFingerOffset.y * GameSettings.WindowResolutionScale)
		}
		return pos
	end,

	GetPalmUpPinchFingerPosition = function(self)
		local pos = { x = self.position.x + self.palmUpPinchOffset.x, y = self.position.y + self.palmUpPinchOffset.y }
		return pos
	end,

}, Hand)

RightHand.__index = RightHand
return RightHand