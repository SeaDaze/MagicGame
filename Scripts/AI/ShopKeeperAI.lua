local AILeftHand = require("Scripts.AI.AILeftHand")
local AIRightHand = require("Scripts.AI.AIRightHand")
local Deck = require("Scripts.Deck")
local CardReader = require("Scripts.Items.CardReader")
local EventIds = require("Scripts.System.EventIds")

local ShopKeeperAI = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
        self.leftHand = AILeftHand:New()
        self.rightHand = AIRightHand:New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
        CardReader:Load()

        self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")

        self.deck:SetActive(false)
        self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
        self.leftHand:SetState(GameConstants.HandStates.PalmDownRelaxed)

        self.totalCost = 0
        self.previousTotalCost = 0
    end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        if self.fanSpreading then
            self:HandleFan()
        end

        CardReader:Update(dt)
        CardReader:SetPosition(self.rightHand:GetPosition())
        --
    end,

    FixedUpdate = function(self, dt)
        self.deck:FixedUpdate(dt)
        self.leftHand:FixedUpdate(dt)
        self.rightHand:FixedUpdate(dt)
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    OnStartShop = function(self)
        self.leftHand:OnStartShop()
        self.rightHand:OnStartShop()
        CardReader:OnStartShop()

		self.itemBoughtNotificationId = EventSystem:ConnectToEvent(EventIds.ItemBought, self, "OnItemBought")
    end,

    OnStopShop = function(self)
        self.leftHand:OnStopShop()
        self.rightHand:OnStopShop()
        CardReader:OnStopShop()

		EventSystem:DisconnectFromEvent(self.itemBoughtNotificationId)
		self.itemBoughtNotificationId = nil
    end,

    AddToCost = function(self, cost)
        self.previousTotalCost = self.totalCost
        self.totalCost = self.totalCost + cost
        self:OnTotalCostChanged()
    end,

    RemoveFromCost = function(self, cost)
        self.previousTotalCost = self.totalCost
        self.totalCost = self.totalCost - cost
        self:OnTotalCostChanged()
    end,

    OnItemBought = function(self, item)
		local cost = item:GetValue()
        self.previousTotalCost = self.totalCost
        self.totalCost = self.totalCost - cost
        CardReader:SetTotalCost(self.totalCost)
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    OnTotalCostChanged = function(self)
        self:ShowCardReader()
    end,

    ShowCardReader = function(self)
        Timer:Stop("ShopKeeperAI_HideCardReader")
        Timer:Start("ShopKeeperAI_ShowCardReader", 0.5)
        self.rightHand:SetTargetPositionOffScreen()
        self.leftHand:SetTargetPositionOffScreenOppositeSide()
    end,

    HideCardReader = function(self)
        Timer:Stop("ShopKeeperAI_ShowCardReader")
        Timer:Start("ShopKeeperAI_HideCardReader", 0.5)
        self.rightHand:SetTargetPositionOffScreen()
        --self.leftHand:SetTargetPositionOffScreen()
    end,

    StartFan = function(self)
        self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
        self.rightHand:ResetPosition()
        self.rightHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) - 100, y = love.graphics.getHeight() / 2 })
        self.leftHand:ResetPosition()
        self.leftHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) + 100, y = love.graphics.getHeight() / 2 })
        Timer:Start("ShopKeeperAI_InitializeFan", 0.8)
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


    OnTimerFinished = function(self, timerId)
        if self.TimerFunctions[timerId] then
            self.TimerFunctions[timerId](self)
        end
	end,

    TimerFunctions = 
    {
        -- ===========================================================================================================
        -- FAN DEMO
        -- ===========================================================================================================
        ShopKeeperAI_InitializeFan = function(self)
            self:InitializeFan()
            self.fanSpreading = true
            Timer:Start("ShopKeeperAI_StartFanning", 1)
            self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxedIndexOut)
        end,

        ShopKeeperAI_StartFanning = function(self)
            self.rightHand:SetMoveInterval(0)
            self:Fan()
            Timer:Start("ShopKeeperAI_OnFanFinished", 2)
        end,

        ShopKeeperAI_OnFanFinished = function(self)
            self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
            self.fanSpreading = false
            self.rightHand:SetMoveInterval(0.5)
            self.rightHand:SetTargetPosition({ x = (love.graphics.getWidth()/2) - 100, y = love.graphics.getHeight() / 2 })
            Timer:Start("ShopKeeperAI_OnStopFanDemo", 1)
        end,

        ShopKeeperAI_OnStopFanDemo = function(self)
            self.rightHand:ResetTargetPosition()
            self.leftHand:ResetTargetPosition()
            self:UninitializeFan()
        end,

        -- ===========================================================================================================
        -- CARD READER
        -- ===========================================================================================================

        ShopKeeperAI_ShowCardReader = function(self)
            CardReader:SetVisible(true)
            CardReader:SetActive(true)
            self.rightHand:SetState(GameConstants.HandStates.MechanicsGrip)
            self.rightHand:SetTargetPositionForward()
            self.leftHand:ResetTargetPosition()
            CardReader:SetTotalCost(self.totalCost)
        end,

        ShopKeeperAI_HideCardReader = function(self)
            CardReader:SetVisible(false)
            CardReader:SetActive(false)
            self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
            self.rightHand:ResetTargetPosition()
            self.leftHand:ResetTargetPosition()
        end,

    },

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #endregion

}
return ShopKeeperAI