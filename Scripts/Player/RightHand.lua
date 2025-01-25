local Hand = require("Scripts.Player.Hand")
local EventIds = require("Scripts.System.EventIds")
local Vector3  = require("Scripts.System.Vector3")
local RightHand = setmetatable({
	New = function(self)
		local instance = setmetatable({}, self)

		instance.drawables = 
		{
			[GameConstants.HandStates.PalmDown] = DrawSystem:LoadImage("Images/Hands/right_palmDown_ThumbIn.png"),
			[GameConstants.HandStates.PalmDownPinch] = DrawSystem:LoadImage("Images/Hands/right_palmDown_PinchNoThumb.png"),
			[GameConstants.HandStates.PalmDownIndexOut] = DrawSystem:LoadImage("Images/Hands/right_palmDown_IndexOut.png"),
			[GameConstants.HandStates.PalmUp] = DrawSystem:LoadImage("Images/Hands/right_palmUp_ThumbIn.png"),
			[GameConstants.HandStates.PalmUpPinch] = DrawSystem:LoadImage("Images/Hands/right_palmUp_NoThumb.png"),
			[GameConstants.HandStates.PalmDownTableSpread] = DrawSystem:LoadImage("Images/Hands/right_palmDown_TableSpread.png"),
			[GameConstants.HandStates.PalmDownNatural] = DrawSystem:LoadImage("Images/Hands/right_palmDown_Natural.png"),
			[GameConstants.HandStates.PalmDownGrabOpen] = DrawSystem:LoadImage("Images/Hands/right_palmDown_GrabOpen.png"),
			[GameConstants.HandStates.PalmDownGrabClose] = DrawSystem:LoadImage("Images/Hands/right_palmDown_GrabClose.png"),
			[GameConstants.HandStates.PalmDownRelaxed] = DrawSystem:LoadImage("Images/Hands/right_palmDown_Relaxed.png"),
			[GameConstants.HandStates.PalmDownRelaxedIndexOut] = DrawSystem:LoadImage("Images/Hands/right_palmDown_RelaxedIndexOut.png"),
			[GameConstants.HandStates.PalmDownRelaxedIndexPressed] = DrawSystem:LoadImage("Images/Hands/right_palmDown_RelaxedIndexOutPressed.png"),
			[GameConstants.HandStates.MechanicsGrip] = nil,
			[GameConstants.HandStates.Fan] = nil,
		}

		-- instance.spritePalmDown = DrawSystem:LoadImage("Images/Hands/right_palmDown_ThumbIn.png")
		-- instance.spritePalmDownIndexOut = DrawSystem:LoadImage("Images/Hands/right_palmDown_IndexOut.png")
		-- instance.spritePalmDownPinchNoThumb = DrawSystem:LoadImage("Images/Hands/right_palmDown_PinchNoThumb.png")
		-- instance.spritePalmDownPinchThumbOnly = DrawSystem:LoadImage("Images/Hands/right_palmDown_PinchThumbOnly.png")
		-- instance.spritePalmDownTableSpread = DrawSystem:LoadImage("Images/Hands/right_palmDown_TableSpread.png")
		-- instance.spritePalmDownNatural = DrawSystem:LoadImage("Images/Hands/right_palmDown_Natural.png")
		-- instance.spritePalmDownGrabOpen = DrawSystem:LoadImage("Images/Hands/right_palmDown_GrabOpen.png")
		-- instance.spritePalmDownGrabClose = DrawSystem:LoadImage("Images/Hands/right_palmDown_GrabClose.png")
		-- instance.spritePalmDownRelaxed = DrawSystem:LoadImage("Images/Hands/right_palmDown_Relaxed.png")
		-- instance.spritePalmDownRelaxedIndexOut = DrawSystem:LoadImage("Images/Hands/right_palmDown_RelaxedIndexOut.png")
		-- instance.spritePalmUp = DrawSystem:LoadImage("Images/Hands/right_palmUp_ThumbIn.png")
		-- instance.spritePalmUpNoThumb = DrawSystem:LoadImage("Images/Hands/right_palmUp_NoThumb.png")
		-- instance.spritePalmUpThumbOnly = DrawSystem:LoadImage("Images/Hands/right_palmUp_ThumbOnly.png")

		
		instance.targetPosition = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
		instance.relaxedFingerOffset = Vector3:New(-20 * GameSettings.WindowResolutionScale, -20 * GameSettings.WindowResolutionScale, 0)
		instance.relaxedFingerPosition = Vector3:New(0, 0, 0)

		instance.indexFingerOffset = { x = -18, y = -25 }

		instance.palmUpPinchOffset = { x = 25, y = -35 }

		-- instance.width = instance.spritePalmDown:getWidth()
		-- instance.height = instance.spritePalmDown:getHeight()
		-- instance.centerOffset = { x = instance.width / 2, y = instance.height / 2}

		instance.angle = 0
		instance.state = GameConstants.HandStates.PalmDownRelaxed
		instance.visible = true
		instance.active = true
		instance.moveSpeed = 500

		instance.nearbyPickups = {}
		instance.actionListenTarget = EventIds.RightAction
		instance.scaleModifier = 2

		instance.sprite = Sprite:New(
			instance.drawables[instance.state],
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
			0,
			2,
			DrawLayers.RightHandDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)
		instance.position = instance.sprite.position

		-- DrawSystem:AddDebugDraw(
        --     function ()
        --         if not instance.active then
        --             return
        --         end
		-- 		local pos = { 
		-- 			x = instance.sprite.position.x + (instance.indexFingerOffset.x * GameSettings.WindowResolutionScale),
		-- 			y = instance.sprite.position.y + (instance.indexFingerOffset.y * GameSettings.WindowResolutionScale)
		-- 		}
		-- 		love.graphics.setColor(1, 0, 0, 1)
		-- 		love.graphics.ellipse(
		-- 			"fill",
		-- 			pos.x,
		-- 			pos.y,
		-- 			5,
		-- 			5,
		-- 			6
		-- 		)
        --         love.graphics.setColor(1, 1, 1, 1)
        --     end
        -- )
		
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
        self.activeTween = Flux.to(self.sprite.position, 0.3, { x = self.targetPosition.x, y = self.targetPosition.y})

		self:UpdateFingerPositions()
    end,

	FixedUpdate = function(self, dt)
	end,

	UpdateFingerPositions = function(self)
		local spritePosition = self.sprite:GetPosition()
		self.relaxedFingerPosition.x = spritePosition.x + self.relaxedFingerOffset.x
		self.relaxedFingerPosition.y = spritePosition.y + self.relaxedFingerOffset.y
	end,

	GetIndexFingerPosition = function(self)
		local pos = {
			x = self.sprite.position.x + (self.indexFingerOffset.x * GameSettings.WindowResolutionScale),
			y = self.sprite.position.y + (self.indexFingerOffset.y * GameSettings.WindowResolutionScale)
		}
		return pos
	end,

	GetPalmUpPinchFingerPosition = function(self)
		local pos = { x = self.position.x + self.palmUpPinchOffset.x, y = self.position.y + self.palmUpPinchOffset.y }
		return pos
	end,

	GetRelaxedFingerPosition = function(self)
		return self.relaxedFingerPosition
	end,

}, Hand)

RightHand.__index = RightHand
return RightHand