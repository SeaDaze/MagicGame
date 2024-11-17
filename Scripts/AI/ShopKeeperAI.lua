local AILeftHand = require("Scripts.AI.AILeftHand")
local AIRightHand = require("Scripts.AI.AIRightHand")
local Deck = require("Scripts.Deck")

local ShopKeeperAI = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
        self.leftHand = AILeftHand:New()
        self.rightHand = AIRightHand:New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
        Input:AddKeyListener("p", self, "StartFan")
        -- Input:AddKeyListener("i", self, "OnStartFan")
        -- Input:AddKeyListener("u", self, "UninitializeFan")

        self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
    end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        if self.fanSpreading then
            self:HandleFan()
        end
        --
    end,

    FixedUpdate = function(self, dt)
        self.deck:FixedUpdate(dt)
        self.leftHand:FixedUpdate(dt)
        self.rightHand:FixedUpdate(dt)
    end,

    Draw = function(self)
        self.leftHand:Draw()
        self.rightHand:Draw()
        self.deck:Draw()
    end,

    LateDraw = function(self)
        self.deck:LateDraw()
        self.leftHand:LateDraw()
        self.rightHand:LateDraw()
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================



    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    StartFan = function(self)
        self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
        self.rightHand:ResetPosition()
        self.rightHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) - 100, y = love.graphics.getHeight() / 2 })
        self.leftHand:ResetPosition()
        self.leftHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) + 100, y = love.graphics.getHeight() / 2 })
        Timer:Start("ShopKeeperAI_InitializeFan", 0.8)
    end,

    OnTimerFinished = function(self, timerId)
        if timerId == "ShopKeeperAI_InitializeFan" then
            self:InitializeFan()
            self.fanSpreading = true
            Timer:Start("ShopKeeperAI_StartFanning", 1)
            self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxedIndexOut)
        elseif timerId == "ShopKeeperAI_StartFanning" then
            self.rightHand:SetMoveInterval(0)
            self:Fan()
            Timer:Start("ShopKeeperAI_OnFanFinished", 2)
        elseif timerId == "ShopKeeperAI_OnFanFinished" then
            self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
            self.fanSpreading = false
            self.rightHand:SetMoveInterval(0.5)
            self.rightHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) - 100, y = love.graphics.getHeight() / 2 })
            Timer:Start("ShopKeeperAI_OnStopFanDemo", 1)
        elseif timerId == "ShopKeeperAI_OnStopFanDemo" then
            self.rightHand:ResetTargetPosition()
            self.leftHand:ResetTargetPosition()
            self:UninitializeFan()
        end
	end,

    HandleFan = function(self)
        local firstCard = self.deck:GetCard(52)
        self.rightHand:SetTargetIndexFingerPosition(firstCard:GetBottomCenterSocket())
    end,

    InitializeFan = function(self)
        local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card.targetOriginOffset = { x = 0, y = -card.halfHeight }
			card.previousOriginOffset = { x = 0, y = -card.halfHeight }
            card:SetAngularSpeed(1)
		end
    end,

    Fan = function(self)
		local angleIncrement = 3.5
		local angle = 0
        local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card.targetAngle = angle
			if angle < 180 then
				angle = angle + angleIncrement
			end
		end
	end,

    UninitializeFan = function(self)
		local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card.targetOriginOffset = { x = 0, y = 0 }
			card.previousOriginOffset = { x = 0, y = 0 }
			card.targetAngle = 0
            card:SetAngularSpeed(0.2)
		end
	end,
    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #endregion

}
return ShopKeeperAI