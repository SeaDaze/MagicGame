local AIHand = require("Scripts.AI.AIHand")

local AIRightHand = setmetatable({

    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
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
			[GameConstants.HandStates.PalmDownNatural] = nil,
			[GameConstants.HandStates.PalmDownGrabOpen] = nil,
			[GameConstants.HandStates.PalmDownGrabClose] = nil,
			[GameConstants.HandStates.PalmDownRelaxed] = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_Relaxed.png"),
			[GameConstants.HandStates.PalmDownRelaxedIndexOut] = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_RelaxedIndexOut.png"),
			[GameConstants.HandStates.MechanicsGrip] = love.graphics.newImage("Images/Hands/AI/ai_right_dealerGrip.png"),
			[GameConstants.HandStates.Fan] = nil,
		}

        -- instance.spriteMechanicsGrip = love.graphics.newImage("Images/Hands/AI/ai_right_dealerGrip.png")
		-- instance.spritePalmDownRelaxed = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_Relaxed.png")
		-- instance.spritePalmDownRelaxedIndexOut = love.graphics.newImage("Images/Hands/AI/ai_right_palmDown_RelaxedIndexOut.png")

		instance.state = GameConstants.HandStates.PalmDownRelaxedIndexOut
		instance.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 100 }

        instance.indexFingerOffset = { x = 8, y = 12 }
		instance.moveInterval = 0.5
		instance.active = true

        instance.sprite = Sprite:New(
			instance.drawables[instance.state],
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
			0,
			2,
			DrawLayers.AIHand,
			true,
			{ x = 0.5, y = 0.5 }
		)

		return instance
	end,

    Update = function(self, dt)
        self.activeTween = Flux.to(self.sprite.position, self.moveInterval, { x = self.targetPosition.x, y = self.targetPosition.y})
    end,

    FixedUpdate = function(self, dt)
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    OnStartShop = function(self)
		DrawSystem:AddDrawable(self.sprite)
    end,

    OnStopShop = function(self)
		DrawSystem:RemoveDrawable(self.sprite)
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    SetState = function(self, newState)
        self.sprite:SetDrawable(self.drawables[newState])
		self.state = newState
	end,

    SetPosition = function(self, position)
        self.sprite.position.x = position.x
        self.sprite.position.y = position.y
    end,

    GetPosition = function(self)
        return self.sprite.position
    end,

    SetTargetPosition = function(self, position)
        self.targetPosition.x = position.x
        self.targetPosition.y = position.y
    end,

    ResetPosition = function(self)
        self.sprite.position = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
    end,

    ResetTargetPosition = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 100 }
    end,

    SetTargetPositionOffScreen = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 2 * -self.sprite.height * GameSettings.WindowResolutionScale }
    end,

    SetTargetPositionForward = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y = 2 * self.sprite.height * GameSettings.WindowResolutionScale }
    end,

    SetTargetPositionOffScreenCenter = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2), y = 2 * -self.sprite.height * GameSettings.WindowResolutionScale }
    end,

    SetIndexFingerPosition = function(self, position)
        self.sprite.position = 
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