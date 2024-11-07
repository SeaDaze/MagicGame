local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local TechniqueCard = require("Scripts.Items.Pickup.Cards.TechniqueCard")
local TechniqueCardSlot = require("Scripts.Items.Pickup.Cards.TechniqueCardSlot")

local RoutineBuilderScene = 
{
    Load = function(self)
		self.leftHand = LeftHand:New()
        self.rightHand = RightHand:New()

        local cardSlotSprite = love.graphics.newImage("Images/Cards/TechniqueCards/technique_CardSlot.png")

        self.pickups = {
            TechniqueCard:New(self.leftHand, self.rightHand),
        }
        
        for _, pickup in pairs(self.pickups) do
            pickup:AddPickupListener(
                function(_, card)
                    local attachedSlot = card:GetAttachedSlot()
                    if attachedSlot then
                        attachedSlot:SetAttachedCard(nil)
                    end
                end
            )
            pickup:AddDroppedListener(
                function(_, card)
                    for _, cardSlot in pairs(self.cardSlots) do
                        if not card:GetAttachedSlot() then
                            if cardSlot:EvaluateWithinRange(card:GetPosition()) then
                                cardSlot:SetAttachedCard(card)
                            end
                        end
                    end
                end
            )
        end

        self.cardSlots = {
            TechniqueCardSlot:New(cardSlotSprite, { x = (love.graphics.getWidth() / 2) - (cardSlotSprite:getWidth() * 4), y = love.graphics.getHeight() -  (cardSlotSprite:getHeight() * 2) }),
            TechniqueCardSlot:New(cardSlotSprite, { x = (love.graphics.getWidth() / 2) - (cardSlotSprite:getWidth() * 2), y = love.graphics.getHeight() -  (cardSlotSprite:getHeight() * 2) }),
            TechniqueCardSlot:New(cardSlotSprite, { x = (love.graphics.getWidth() / 2), y = love.graphics.getHeight() -  (cardSlotSprite:getHeight() * 2) }),
            TechniqueCardSlot:New(cardSlotSprite, { x = (love.graphics.getWidth() / 2) + (cardSlotSprite:getWidth() * 2), y = love.graphics.getHeight() -  (cardSlotSprite:getHeight() * 2) }),
            TechniqueCardSlot:New(cardSlotSprite, { x = (love.graphics.getWidth() / 2) + (cardSlotSprite:getWidth() * 4), y = love.graphics.getHeight() -  (cardSlotSprite:getHeight() * 2) }),
        }
    end,

    OnStart = function(self)
        love.mouse.setVisible(false)
        self.leftActionInputId = Input:AddActionListener(GameConstants.InputActions.Left,
            function ()
                self.leftHand:SetState(GameConstants.LeftHandStates.PalmDownGrabClose)
            end,
            function ()
                self.leftHand:SetState(GameConstants.LeftHandStates.PalmDownGrabOpen)
            end
        )

        self.rightActionInputId = Input:AddActionListener(GameConstants.InputActions.Right,
            function ()
                self.rightHand:SetState(GameConstants.RightHandStates.PalmDownGrabClose)
            end,
            function ()
                self.rightHand:SetState(GameConstants.RightHandStates.PalmDownGrabOpen)
            end
        )

        for _, pickup in pairs(self.pickups) do
            pickup:OnStart()
        end
    end,

    OnStop = function(self)
        Input:RemoveActionListener(self.leftActionInputId)
        Input:RemoveActionListener(self.rightActionInputId)
        for _, pickup in pairs(self.pickups) do
            pickup:OnStop()
        end
    end,

    Update = function(self, dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        for _, pickup in pairs(self.pickups) do
            pickup:Update(dt)
        end
    end,

    Draw = function(self)
        love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)

        for _, cardSlot in pairs(self.cardSlots) do
            cardSlot:Draw()
        end

        for _, pickup in pairs(self.pickups) do
            pickup:Draw()
        end
        love.graphics.printf("Build", GameConstants.UI.Font, 0, 0, love.graphics.getWidth(), "center")
        self.leftHand:Draw()
        self.rightHand:Draw()
        
    end,

    LateDraw = function(self)
        self.leftHand:LateDraw()
        self.rightHand:LateDraw()
    end,
}
return RoutineBuilderScene