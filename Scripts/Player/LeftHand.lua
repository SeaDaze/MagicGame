local Hand = require("Scripts.Player.Hand")
local EventIds = require("Scripts.System.EventIds")

local LeftHand = setmetatable({
	New = function(self)
		local instance = setmetatable({}, self)

		instance.drawables = 
		{
			[GameConstants.HandStates.PalmDown] = nil,
			[GameConstants.HandStates.PalmDownPinch] = nil,
			[GameConstants.HandStates.PalmDownIndexOut] = nil,
			[GameConstants.HandStates.PalmUp] = nil,
			[GameConstants.HandStates.PalmUpPinch] = nil,
			[GameConstants.HandStates.PalmDownTableSpread] = nil,
			[GameConstants.HandStates.PalmDownNatural] = DrawSystem:LoadImage("Images/Hands/left_palmDown_Natural.png"),
			[GameConstants.HandStates.PalmDownGrabOpen] = DrawSystem:LoadImage("Images/Hands/left_palmDown_GrabOpen.png"),
			[GameConstants.HandStates.PalmDownGrabClose] = DrawSystem:LoadImage("Images/Hands/left_palmDown_GrabClose.png"),
			[GameConstants.HandStates.PalmDownRelaxed] = DrawSystem:LoadImage("Images/Hands/left_palmDown_Relaxed.png"),
			[GameConstants.HandStates.PalmDownRelaxedIndexOut] = DrawSystem:LoadImage("Images/Hands/left_palmDown_RelaxedIndexOut.png"),
			[GameConstants.HandStates.MechanicsGrip] = DrawSystem:LoadImage("Images/Hands/left_dealerGrip.png"),
			[GameConstants.HandStates.Fan] = DrawSystem:LoadImage("Images/Hands/left_fan_NoThumb.png"),
		}

		instance.lateDrawables =
		{
			[GameConstants.HandStates.Fan] = DrawSystem:LoadImage("Images/Hands/left_fan_ThumbOnly.png"),
		}

		instance.state = GameConstants.HandStates.PalmDownRelaxed
		
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.moveSpeed = 500
		instance.active = true
		instance.nearbyPickups = {}
		instance.actionListenTarget = EventIds.LeftAction
		instance.scaleModifier = 2

		instance.sprite = Sprite:New(
			instance.drawables[instance.state],
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
			0,
			2,
			DrawLayers.LeftHandDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)

		instance.lateSprite = Sprite:New(
			instance.lateDrawables[GameConstants.HandStates.Fan],
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
			0,
			2,
			DrawLayers.LeftHandAboveDeck,
			false,
			{ x = 0.5, y = 0.5 }
		)
		instance.position = instance.sprite.position

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

        self.activeTween = Flux.to(self.sprite.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y })
		self.lateSprite:SetPosition(self.sprite.position)
    end,

	FixedUpdate = function(self, dt)
	end,

}, Hand)

LeftHand.__index = LeftHand

return LeftHand