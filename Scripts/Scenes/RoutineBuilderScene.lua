local TechniqueCard = require("Scripts.Items.Pickup.Cards.TechniqueCard")

local RoutineBuilderScene = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
		self.leftHand = Player:GetLeftHand()
        self.rightHand = Player:GetRightHand()

        self.pickups = {
            --TechniqueCard:New("Fan", self.leftHand, self.rightHand),
            --TechniqueCard:New("FalseCut", self.leftHand, self.rightHand),
        }
    end,

    OnStart = function(self)
        Player:OnStartBuild()

        love.mouse.setVisible(false)

        -- for _, pickup in pairs(self.pickups) do
        --     pickup:OnStart()
        --     pickup:AddPickupListener(
        --         function(_, card)
        --             local attachedSlot = card:GetAttachedSlot()
        --             if attachedSlot then
        --                 attachedSlot:SetAttachedCard(nil)
        --             end
        --         end
        --     )
        --     pickup:AddDroppedListener(
        --         function(_, card)
        --             local cardSlots = Player:GetCardSlots()
        --             for _, cardSlot in pairs(cardSlots) do
        --                 if not card:GetAttachedSlot() then
        --                     if cardSlot:EvaluateWithinRange(card:GetPosition()) then
        --                         cardSlot:SetAttachedCard(card)
        --                     end
        --                 end
        --             end
        --         end
        --     )
        -- end
    end,

    OnStop = function(self)
        Player:OnStopBuild()
        for _, pickup in pairs(self.pickups) do
            pickup:OnStop()
        end
    end,

    Update = function(self, dt)
        for _, pickup in pairs(self.pickups) do
            pickup:Update(dt)
        end
        Player:Update(dt)
    end,

    FixedUpdate = function(self, dt)
		Player:FixedUpdate(dt)
	end,

    Draw = function(self)
        love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)
        for _, pickup in pairs(self.pickups) do
            pickup:Draw()
        end
        Player:Draw()

        love.graphics.printf("Build", GameConstants.UI.Font, 0, 0, love.graphics.getWidth(), "center")
    end,

	LateDraw = function(self)
		Player:LateDraw()
	end,
}
return RoutineBuilderScene