local AIHand = require("Scripts.AI.AIHand")

local AIRightHand = setmetatable({

    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    New = function(self)
		local instance = setmetatable({}, self)

		instance.spritePalmDownRelaxed = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_Relaxed.png")
		instance.spritePalmDownRelaxedIndexOut = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_RelaxedIndexOut.png")

		instance.state = GameConstants.HandStates.PalmDownRelaxedIndexOut

		instance.position = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
		instance.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
        instance.width = instance.spritePalmDownRelaxed:getWidth()
		instance.height = instance.spritePalmDownRelaxed:getHeight()
        instance.indexFingerOffset = { x = 8, y = 12 }
		instance.moveInterval = 0.5
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

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    DrawHand = function(self, sprite)
		love.graphics.draw(sprite, self.position.x, self.position.y, math.rad(self.angle), GameSettings.WindowResolutionScale, GameSettings.WindowResolutionScale, self.width / 2, self.height / 2)
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
        self.position = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
    end,

    ResetTargetPosition = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
    end,

    SetIndexFingerPosition = function(self, position)
        self.position = 
        {
            x = position.x - (self.indexFingerOffset.x * GameSettings.WindowResolutionScale),
            y = position.y - (self.indexFingerOffset.y * GameSettings.WindowResolutionScale),
        }
    end,

    SetTargetIndexFingerPosition = function(self, position)
        self.targetPosition = 
        {
            x = position.x - (self.indexFingerOffset.x * GameSettings.WindowResolutionScale),
            y = position.y - (self.indexFingerOffset.y * GameSettings.WindowResolutionScale),
        }
    end,

    SetMoveInterval = function(self, interval)
        self.moveInterval = interval
    end,

    -- ===========================================================================================================
    -- #endregion


}, AIHand)

AIRightHand.__index = AIRightHand
return AIRightHand