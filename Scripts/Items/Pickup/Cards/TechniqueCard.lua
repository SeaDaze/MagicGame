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
        instance.sprite =  Sprite:New(
			love.graphics.newImage(TechniqueCardSprites[typeId]),
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() * 0.9, z = 0 },
			0,
			1,
			DrawLayers.PickupDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)

        instance:Pickup_Initialize(leftHand, rightHand, 1)
        return instance
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
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

	GetPosition = function(self)
		return self.sprite.position
	end,

	FluxPositionTo = function(self, newPosition, duration)
		Flux.to(self.sprite.position, duration, { x = newPosition.x, y = newPosition.y })
	end,

}, Pickup)

TechniqueCard.__index = TechniqueCard

return TechniqueCard