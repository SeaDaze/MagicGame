
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
        self.leftHand = Player:GetLeftHand()
        self.rightHand = Player:GetRightHand()
        ShopKeeperAI:Load()
        Mat:Load()
        BuyZone:Load()
        self.table = love.graphics.newImage("Images/Background/table.png")
        
        self.pickups = {
            Relic:New("Apple", self.leftHand, self.rightHand),
        }
    end,

    OnStart = function(self)
        Player:OnStartShop()

        for _, pickup in pairs(self.pickups) do
            local pickupCollider = pickup:GetCollider()
            pickupCollider:BoxCollider_AddCollisionListener(BuyZone:GetCollider(), self.OnStartBoxCollision, self.OnStopBoxCollision)
            pickup:OnStart()
            pickup:AddPickupListener(
                function(_, card)
                    -- local attachedSlot = card:GetAttachedSlot()
                    -- if attachedSlot then
                    --     attachedSlot:SetAttachedCard(nil)
                    -- end
                end
            )
            pickup:AddDroppedListener(
                function(_, card)
                    -- local cardSlots = Player:GetCardSlots()
                    -- for _, cardSlot in pairs(cardSlots) do
                    --     if not card:GetAttachedSlot() then
                    --         if cardSlot:EvaluateWithinRange(card:GetPosition()) then
                    --             cardSlot:SetAttachedCard(card)
                    --         end
                    --     end
                    -- end
                end
            )
        end
    end,

    OnStop = function(self)
        Player:OnStopShop()
        for _, pickup in pairs(self.pickups) do
            pickup:OnStop()
        end
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

    Draw = function(self)
        love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)
        --Mat:Draw()
        BuyZone:Draw()
        for _, pickup in pairs(self.pickups) do
            pickup:Draw()
        end
        Player:Draw()
        ShopKeeperAI:Draw()
        love.graphics.printf("Shop", GameConstants.UI.Font, 0, 0, love.graphics.getWidth(), "center")
    end,

	LateDraw = function(self)
		Player:LateDraw()
        ShopKeeperAI:LateDraw()
	end,

    OnStartBoxCollision = function(self, colliderA, colliderB)
        print("Start Colliding")
    end,

    OnStopBoxCollision = function(self, colliderA, colliderB)
        print("Stop Colliding")
    end,
}

return ShopScene