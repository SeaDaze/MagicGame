local Constants = require("Scripts.Constants")

local RightHand = {
	New = function(self)
		local instance = setmetatable({}, self)

		instance.spritePalmDown = love.graphics.newImage("Images/Hands/right_palmDown_ThumbIn.png")
		instance.spritePalmDownIndexOut = love.graphics.newImage("Images/Hands/right_palmDown_IndexOut.png")
		instance.spritePalmDownPinchNoThumb = love.graphics.newImage("Images/Hands/right_palmDown_PinchNoThumb.png")
		instance.spritePalmDownPinchThumbOnly = love.graphics.newImage("Images/Hands/right_palmDown_PinchThumbOnly.png")

		instance.spritePalmUp = love.graphics.newImage("Images/Hands/right_palmUp_ThumbIn.png")
		instance.spritePalmUpNoThumb = love.graphics.newImage("Images/Hands/right_palmUp_NoThumb.png")
		instance.spritePalmUpThumbOnly = love.graphics.newImage("Images/Hands/right_palmUp_ThumbOnly.png")

		instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.indexFingerOffset = { x = -25, y = -35 }
		instance.palmUpPinchOffset = { x = 25, y = -35 }

		instance.halfWidth = instance.spritePalmDown:getWidth() / 2
		instance.halfHeight = instance.spritePalmDown:getHeight() / 2
		instance.angle = 0
		instance.state = Constants.RightHandStates.PalmUpPinch
		instance.visible = true
		instance.active = true

		return instance
	end,

    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    Update = function(self, Flux, dt)
		if not self.active then
			return
		end
        self.activeTween = Flux.to(self.position, 0.2, { x = love.mouse.getX(), y = love.mouse.getY()})
    end,

    Draw = function(self)
		love.graphics.setColor(1, 1, 1, 0.8)
		if not self.visible then
			return
		end
		if self.state == Constants.RightHandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchThumbOnly)
		elseif self.state == Constants.RightHandStates.PalmUp then
			self:DrawHand(self.spritePalmUp)
		elseif self.state == Constants.RightHandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpNoThumb)
		end
		love.graphics.setColor(1, 1, 1, 1)
    end,

	LateDraw = function(self)
		love.graphics.setColor(1, 1, 1, 0.8)
		if not self.visible then
			return
		end
		if self.state == Constants.RightHandStates.PalmDown then
			self:DrawHand(self.spritePalmDown)
		elseif self.state == Constants.RightHandStates.PalmDownPinch then
			self:DrawHand(self.spritePalmDownPinchNoThumb)
		elseif self.state == Constants.RightHandStates.PalmDownIndexOut then
			self:DrawHand(self.spritePalmDownIndexOut)
		elseif self.state == Constants.RightHandStates.PalmUpPinch then
			self:DrawHand(self.spritePalmUpThumbOnly)
		end
		love.graphics.setColor(1, 1, 1, 1)
    end,

    DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), 5, 5, self.halfWidth, self.halfHeight)
    end,

	ChangeState = function(self, newState)
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
}
RightHand.__index = RightHand

return RightHand