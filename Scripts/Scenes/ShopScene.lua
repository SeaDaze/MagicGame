
local ShopKeeperAI = require("Scripts.AI.ShopKeeperAI")
local Mat = require("Scripts.Mat")
local Relic = require("Scripts.Items.Pickup.Relic")
local BuyZone = require("Scripts.UI.BuyZone")
local EventIds = require("Scripts.System.EventIds")

local ShopScene = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

    Load = function(self)
        ShopKeeperAI:Load()
        Mat:Load()
        BuyZone:Load()
        
        self.pickups = {
            Relic:New("Apple", Player:GetLeftHand(), Player:GetRightHand()),
        }

        for _, relic in pairs(self.pickups) do
            relic:SetItemOwner(GameConstants.ItemOwners.ShopKeeper)
        end

        self.pickupsInBuyZone = {}
    end,

    OnStart = function(self)
        Player:OnStartShop()
        ShopKeeperAI:OnStartShop()
        BuyZone:OnStart()

		for _, pickup in pairs(self.pickups) do
            local pickupCollider = pickup:GetCollider()
            pickupCollider:BoxCollider_AddCollisionListener(BuyZone:GetCollider(),
                function(colliderA, colliderB)
                    if pickup:GetItemOwner() == GameConstants.ItemOwners.ShopKeeper then
                        table.insert(self.pickupsInBuyZone, pickup)
                    end
                end,

                function(colliderA, colliderB)
                    if pickup:GetItemOwner() == GameConstants.ItemOwners.ShopKeeper then
                        table.removeByValue(self.pickupsInBuyZone, pickup)
                    end
                end
            )

            pickup:OnStart()
        end

		self.cardReaderSuccessNotificationId = EventSystem:ConnectToEvent(EventIds.CreditCardReadSuccess, self, "OnCreditCardReadSuccess")
		self.itemPickedUpNotificationId = EventSystem:ConnectToEvent(EventIds.ItemPickedUp, self, "OnItemPickedUp")
		self.itemDroppedNotificationId = EventSystem:ConnectToEvent(EventIds.ItemDropped, self, "OnItemDropped")

        self.debug_DrawIndex = DrawSystem:AddDebugDraw(
            function ()
                love.graphics.printf("Shop", GameConstants.UI.Font, 0, 0, love.graphics.getWidth(), "center")
            end
        )
    end,

    OnStop = function(self)
        Player:OnStopShop()
        BuyZone:OnStop()

        DrawSystem:RemoveDebugDraw(self.debug_DrawIndex)

		EventSystem:DisconnectFromEvent(self.cardReaderSuccessNotificationId)
		self.cardReaderSuccessNotificationId = nil
		EventSystem:DisconnectFromEvent(self.itemPickedUpNotificationId)
		self.itemPickedUpNotificationId = nil
		EventSystem:DisconnectFromEvent(self.itemDroppedNotificationId)
		self.itemDroppedNotificationId = nil
    end,

    Update = function(self, dt)
        for _, pickup in pairs(self.pickups) do
            pickup:Update(dt)
        end
        Player:Update(dt)
        ShopKeeperAI:Update(dt)
    end,

    FixedUpdate = function(self, dt)
		Player:FixedUpdate(dt)
        ShopKeeperAI:FixedUpdate(dt)
	end,

	-- ===========================================================================================================
	-- #region [NOTIFICATIONS]
	-- ===========================================================================================================

	OnItemPickedUp = function(self, pickup)
		if pickup:GetItemOwner() ~= GameConstants.ItemOwners.ShopKeeper then
			return
		end
		if table.findKey(self.pickupsInBuyZone, pickup) then
			ShopKeeperAI:RemoveFromCost(pickup:GetValue())
		end
	end,

	OnItemDropped = function(self, pickup)
		if pickup:GetItemOwner() ~= GameConstants.ItemOwners.ShopKeeper then
			return
		end
		if table.findKey(self.pickupsInBuyZone, pickup) then
			ShopKeeperAI:AddToCost(pickup:GetValue())
		end
	end,

	OnCreditCardReadSuccess = function(self)
		for _, pickup in pairs(self.pickupsInBuyZone) do
			if pickup:GetItemOwner() == GameConstants.ItemOwners.ShopKeeper then
				EventSystem:BroadcastEvent(EventIds.ItemBought, pickup)
			end
		end
	end,

	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #endregion
}

return ShopScene