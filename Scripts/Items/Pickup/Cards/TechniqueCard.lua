local Pickup = require "Scripts.Items.Pickup.Pickup"

local TechniqueCardSprites = 
{
    Fan = "Images/Cards/TechniqueCards/technique_Fan.png",
    FalseCut = "Images/Cards/TechniqueCards/technique_FalseCut.png",
}

local TechniqueCard = setmetatable(
{
	New = function(self, typeId,  leftHand, rightHand)
		local instance = setmetatable({}, self)
        instance.typeId = typeId
        instance.sprite = love.graphics.newImage(TechniqueCardSprites[typeId])

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

    GetTypeId = function(self)
        return self.typeId
    end,

}, Pickup)

TechniqueCard.__index = TechniqueCard

return TechniqueCard