local Pickup = require "Scripts.Items.Pickup.Pickup"

local TechniqueCard = setmetatable(
{
	New = function(self,  leftHand, rightHand)
		local instance = setmetatable({}, self)
        instance.sprite = love.graphics.newImage("Images/Cards/TechniqueCards/technique_Fan.png")

        instance:Pickup_Initialize(leftHand, rightHand)
        instance.windowScaleFraction = 3
        return instance
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
        print("TechniqueCard: OnStart")
    end,

    SetAttachedSlot = function(self, slot)
        self.attachedSlot = slot
    end,

    GetAttachedSlot = function(self)
        return self.attachedSlot
    end,

}, Pickup)

TechniqueCard.__index = TechniqueCard

return TechniqueCard