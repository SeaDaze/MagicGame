
local Hand = require("Scripts.Player.Hand")

local LeftHand = setmetatable({
	New = function(self)
		local instance = setmetatable({}, self)

		instance.spriteMechanicsGrip = love.graphics.newImage("Images/Hands/left_dealerGrip.png")
		instance.spriteFanNoThumb = love.graphics.newImage("Images/Hands/left_fan_NoThumb.png")
		instance.spriteFanThumbOnly = love.graphics.newImage("Images/Hands/left_fan_ThumbOnly.png")
		instance.spritePalmDownNatural = love.graphics.newImage("Images/Hands/left_palmDown_Natural.png")
		instance.spritePalmDownGrabOpen = love.graphics.newImage("Images/Hands/left_palmDown_GrabOpen.png")
		instance.spritePalmDownGrabClose = love.graphics.newImage("Images/Hands/left_palmDown_GrabClose.png")
		instance.spritePalmDownRelaxed = love.graphics.newImage("Images/Hands/left_palmDown_Relaxed.png")
		instance.spritePalmDownRelaxedIndexOut = love.graphics.newImage("Images/Hands/left_palmDown_RelaxedIndexOut.png")

		instance.state = GameConstants.HandStates.PalmDownGrabOpen
		instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.moveSpeed = 500
		instance.width = instance.spriteMechanicsGrip:getWidth()
		instance.height = instance.spriteMechanicsGrip:getHeight()
		instance.centerOffset = { x = instance.width / 2, y = instance.height / 2}
		instance.angle = 0
		instance.visible = true
		instance.active = true
		instance.nearbyPickups = {}

		instance.actionListenTarget = GameConstants.InputActions.Left

		instance.collider = require("Scripts.Physics.BoxCollider")
        --instance.collider:BoxCollider_Initialize(instance.position, instance.width * GameSettings.WindowResolutionScale, instance.height * GameSettings.WindowResolutionScale, instance.centerOffset)
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

		self.targetPosition.x = Common:Clamp(self.targetPosition.x, 0, love.graphics.getWidth())
		self.targetPosition.y = Common:Clamp(self.targetPosition.y, 0, love.graphics.getHeight())
		
        self.activeTween = Flux.to(self.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y })
		--self.collider:BoxCollider_Update()
    end,

	FixedUpdate = function(self, dt)
	end,

    Draw = function(self)
		if not self.visible then
			return
		end
		if self.state == GameConstants.HandStates.MechanicsGrip then
			self:DrawHand(self.spriteMechanicsGrip)
		elseif self.state == GameConstants.HandStates.Fan then
			self:DrawHand(self.spriteFanNoThumb)
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
		--self.collider:BoxCollider_DebugDraw()
    end,

	LateDraw = function(self)
		if not self.visible then
			return
		end
		if self.state == GameConstants.HandStates.Fan then
			self:DrawHand(self.spriteFanThumbOnly)
		end
    end,

	DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), GameSettings.WindowResolutionScale, GameSettings.WindowResolutionScale, self.centerOffset.x, self.centerOffset.y)
	end,

}, Hand)

LeftHand.__index = LeftHand

return LeftHand