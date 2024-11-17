local AIHand = require("Scripts.AI.AIHand")

local AILeftHand = setmetatable({

    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    New = function(self)
		local instance = setmetatable({}, self)

		instance.spriteFanNoThumb = love.graphics.newImage("Images/Hands/AI/ai_left_fan_NoThumb.png")
		instance.spriteFanThumbOnly = love.graphics.newImage("Images/Hands/AI/ai_left_fan_ThumbOnly.png")

		instance.spritePalmDownRelaxed = love.graphics.newImage("Images/Hands/AI/ai_left_palmDown_Relaxed.png")
		instance.spritePalmDownRelaxedIndexOut = love.graphics.newImage("Images/Hands/AI/ai_left_palmDown_RelaxedIndexOut.png")

		instance.state = GameConstants.HandStates.Fan

		instance.position = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
		instance.targetPosition = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
		instance.moveInterval = 0.5
		instance.width = instance.spritePalmDownRelaxed:getWidth()
		instance.height = instance.spritePalmDownRelaxed:getHeight()
		instance.angle = 0
		instance.visible = true
		instance.active = true
    
		return instance
	end,

    Update = function(self, dt)
        self.activeTween = Flux.to(self.position, self.moveInterval, { x = self.targetPosition.x, y = self.targetPosition.y})
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
    end,

	LateDraw = function(self)
		if not self.visible then
			return
		end
		if self.state == GameConstants.HandStates.Fan then
			self:DrawHand(self.spriteFanThumbOnly)
		end
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), 5, 5, (self.width / 2), self.height / 2)
	end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    SetState = function(self, newState)
		self.state = newState
	end,

    SetPosition = function(self, position)
        self.position.x = position.x
        self.position.y = position.y
    end,

    SetTargetPosition = function(self, position)
        self.targetPosition.x = position.x
        self.targetPosition.y = position.y
    end,

    ResetPosition = function(self)
        self.position = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
    end,

    ResetTargetPosition = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
    end,

    -- ===========================================================================================================
    -- #endregion


}, AIHand)

AILeftHand.__index = AILeftHand
return AILeftHand