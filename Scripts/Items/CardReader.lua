local BoxCollider = require("Scripts.Physics.BoxCollider")
local EventIds    = require("Scripts.System.EventIds")

local CardReaderStates = 
{
    Default = 1,
    Green = 2,
}

local CardReader = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================

    Load = function(self)
        -- Variables
        self.drawables = 
        {
            [CardReaderStates.Default] = DrawSystem:LoadImage("Images/Items/ShopKeeper/CardReader.png"),
            [CardReaderStates.Green] = DrawSystem:LoadImage("Images/Items/ShopKeeper/CardReaderGreen.png"),
        }

        self.active = false
        self.state = CardReaderStates.Default

        self.buyListeners = {}
        self.listenerId = 0
        self.totalCost = 0

        self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")

        -- Components
        self.sprite = Sprite:New(
			self.drawables[self.state],
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
			0,
			1,
			DrawLayers.CardReader,
			true,
			{ x = 0.5, y = 0.5 }
		)

        self.priceText = Text:New(
            "£0",
            GameConstants.UI.FontAlt,
            { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 10 },
            0,
            DrawLayers.CardReader + 1,
            "center"
        )

        self.collider = BoxCollider:BoxCollider_New(self, self.sprite.position, self.sprite.width, self.sprite.height, { x = 0.5, y = 0.5 })
        self.collider:BoxCollider_AddCollisionListener(Player:GetCreditCard():GetCollider(),
            function(colliderA, colliderB)
                if not self.active then
                    return
                end
                if self.totalCost > 0 then
                    Timer:Start("CardReader_Read", 1.5)
                end
            end,

            function(colliderA, colliderB)
                if not self.active then
                    return
                end
                Timer:Stop("CardReader_Read")
                if self.state == CardReaderStates.Green then
                    self:SetState(CardReaderStates.Default)
                end
            end
        )

        self.textOffset = 
        {
            x = -love.graphics.getWidth() / 2,
            y = -self.sprite:GetHeight() * 1.2,
        }
    end,

    Update = function(self, dt)
        if not self.active then
            return
        end
        local spritePosition = self.sprite:GetPosition()
        self.priceText:SetPosition({
            x = spritePosition.x + self.textOffset.x,
            y = spritePosition.y + self.textOffset.y,
        })
        self.collider:BoxCollider_Update()
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    OnStartShop = function(self)
        DrawSystem:AddDrawable(self.sprite)
        DrawSystem:AddDrawable(self.priceText)
        self.sprite:SetVisible(false)
        self.priceText:SetVisible(false)
        self.collider:BoxCollider_OnStart()
    end,

    OnStopShop = function(self)
        DrawSystem:RemoveDrawable(self.sprite)
        DrawSystem:RemoveDrawable(self.priceText)
        self.collider:BoxCollider_OnStop()
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    SetState = function(self, newState)
        self.sprite:SetDrawable(self.drawables[newState])
		self.state = newState
        if newState == CardReaderStates.Default then
            self.priceText:SetVisible(true)
        else
            self.priceText:SetVisible(false)
        end
	end,

    OnTimerFinished = function(self, timerId)
        if timerId == "CardReader_Read" then
            self:SetState(CardReaderStates.Green)
			EventSystem:BroadcastEvent(EventIds.CreditCardReadSuccess)
        end
	end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    SetPosition = function(self, newPosition, offset)
        offset = offset or {x = 0, y = 0}
        self.sprite.position.x = newPosition.x + offset.x
        self.sprite.position.y = newPosition.y + offset.y
    end,

    SetVisible = function(self, isVisible)
        self.sprite:SetVisible(isVisible)
        self.priceText:SetVisible(isVisible)
    end,

    SetActive = function(self, isActive)
        self.active = isActive
    end,

    SetTotalCost = function(self, cost)
        self.totalCost = cost
        self.priceText:SetText("£".. tostring(self.totalCost))
    end,

    AddBuyListener = function(self, buySuccessCallback)
		self.listenerId = self.listenerId + 1
		self.buyListeners[self.listenerId] =
		{
			buySuccessCallback = buySuccessCallback,
		}
    end,

    -- ===========================================================================================================
    -- #endregion
}
return CardReader