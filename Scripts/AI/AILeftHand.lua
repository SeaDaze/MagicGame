local AIHand = require("Scripts.AI.AIHand")

local AILeftHand = setmetatable({

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
			[GameConstants.HandStates.PalmDownRelaxed] = DrawSystem:LoadImage("Images/Hands/AI/ai_left_palmDown_Relaxed.png"),
			[GameConstants.HandStates.PalmDownRelaxedIndexOut] = DrawSystem:LoadImage("Images/Hands/AI/ai_left_palmDown_RelaxedIndexOut.png"),
			[GameConstants.HandStates.MechanicsGrip] = nil,
			[GameConstants.HandStates.Fan] = DrawSystem:LoadImage("Images/Hands/AI/ai_left_fan_NoThumb.png"),
		}

		-- instance.spriteFanNoThumb = DrawSystem:LoadImage("Images/Hands/AI/ai_left_fan_NoThumb.png")
		-- instance.spriteFanThumbOnly = DrawSystem:LoadImage("Images/Hands/AI/ai_left_fan_ThumbOnly.png")
		-- instance.spritePalmDownRelaxed = DrawSystem:LoadImage("Images/Hands/AI/ai_left_palmDown_Relaxed.png")
		-- instance.spritePalmDownRelaxedIndexOut = DrawSystem:LoadImage("Images/Hands/AI/ai_left_palmDown_RelaxedIndexOut.png")

		instance.state = GameConstants.HandStates.PalmDownRelaxed
		instance.targetPosition = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
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
		self.state = newState
	end,

	GetPosition = function(self)
		return self.sprite.position
	end,

    SetPosition = function(self, position)
        self.sprite.position.x = position.x
        self.sprite.position.y = position.y
    end,

    SetTargetPosition = function(self, position)
        self.targetPosition.x = position.x
        self.targetPosition.y = position.y
    end,

	SetTargetPositionOffScreen = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) + 200, y = 2 * -self.sprite.height * GameSettings.WindowResolutionScale }
    end,

	SetTargetPositionOffScreenOppositeSide = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) - 200, y =  2 * -self.sprite.height * GameSettings.WindowResolutionScale }
    end,

    ResetPosition = function(self)
        self.sprite.position = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
    end,

    ResetTargetPosition = function(self)
        self.targetPosition = { x = (love.graphics.getWidth()/2) + 200, y = 100 }
    end,

    -- ===========================================================================================================
    -- #endregion


}, AIHand)

AILeftHand.__index = AILeftHand
return AILeftHand