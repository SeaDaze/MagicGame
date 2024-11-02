
local LeftHand = {
	New = function(self)
		local instance = setmetatable({}, self)

		instance.spriteMechanicsGrip = love.graphics.newImage("Images/Hands/left_dealerGrip.png")
		instance.spriteFanNoThumb = love.graphics.newImage("Images/Hands/left_fan_NoThumb.png")
		instance.spriteFanThumbOnly = love.graphics.newImage("Images/Hands/left_fan_ThumbOnly.png")

		instance.state = GameConstants.LeftHandStates.MechanicsGrip
		instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.moveSpeed = 500
		instance.width = instance.spriteMechanicsGrip:getWidth()
		instance.height = instance.spriteMechanicsGrip:getHeight()
		instance.angle = 0
		instance.visible = true
		instance.active = true

		return instance
	end,

    Update = function(self, dt)
		if not self.active then
			return
		end
		local horizontal = Input:GetInputAxis(GameConstants.InputAxis.Left.X)
		local vertical = Input:GetInputAxis(GameConstants.InputAxis.Left.Y)

		self.targetPosition.x = self.targetPosition.x + (horizontal * self.moveSpeed * dt)
		self.targetPosition.y = self.targetPosition.y + (vertical * self.moveSpeed * dt)

        self.activeTween = Flux.to(self.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y })
    end,

    Draw = function(self)
		if not self.visible then
			return
		end
		if self.state == GameConstants.LeftHandStates.MechanicsGrip then
			self:DrawHand(self.spriteMechanicsGrip)
		elseif self.state == GameConstants.LeftHandStates.Fan then
			self:DrawHand(self.spriteFanNoThumb)
		end
    end,

	LateDraw = function(self)
		if not self.visible then
			return
		end
		if self.state == GameConstants.LeftHandStates.Fan then
			self:DrawHand(self.spriteFanThumbOnly)
		end
    end,

	DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), 5, 5, (self.width / 2), self.height / 2)
	end,

	ChangeState = function(self, newState)
		self.state = newState
	end,

	GetState = function(self)
		return self.state
	end,

	Disable = function(self)
		self.active = false
		self.activeTween:stop()
	end,

	Enable = function(self)
		self.active = true
	end,
}
LeftHand.__index = LeftHand

return LeftHand