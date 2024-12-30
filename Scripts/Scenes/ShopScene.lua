
local ShopKeeperAI = require("Scripts.AI.ShopKeeperAI")
local Mat = require("Scripts.Mat")
local Relic = require("Scripts.Items.Pickup.Relic")
local BuyZone = require("Scripts.UI.BuyZone")

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
            Relic:New("Apple", Player:GetLeftHand(), Player:GetRightHand()),
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

        -- Handle successfully buying items
        local cardReader = ShopKeeperAI:GetCardReader()
        cardReader:AddBuyListener(function ()
            for _, pickup in pairs(self.pickupsInBuyZone) do
                if pickup:GetItemOwner() == GameConstants.ItemOwners.ShopKeeper then
                    ShopKeeperAI:OnItemsBought(pickup:GetValue())
                    Player:GetInventory():AddRelicToInventory(pickup)
                end
            end
        end)

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
            pickup:AddPickupListener(
                function(_, p)
                    if pickup:GetItemOwner() ~= GameConstants.ItemOwners.ShopKeeper then
                        return
                    end

                    if table.findKey(self.pickupsInBuyZone, pickup) then
                        ShopKeeperAI:RemoveFromCost(p:GetValue())
                    end
                end
            )
            pickup:AddDroppedListener(
                function(_, p)
                    if pickup:GetItemOwner() ~= GameConstants.ItemOwners.ShopKeeper then
                        return
                    end
                    if table.findKey(self.pickupsInBuyZone, pickup) then
                        ShopKeeperAI:AddToCost(p:GetValue())
                    end
                end
            )
        end

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
}

return ShopScene