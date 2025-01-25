local Pickup = require "Scripts.Items.Pickup.Pickup"

local RelicSprites = 
{
    Apple = "Images/Items/apple.png",
}

local Relic = setmetatable(
{
	New = function(self, typeId,  leftHand, rightHand)
		local instance = setmetatable({}, self)
        instance.typeId = typeId
        instance.drawable = DrawSystem:LoadImage(RelicSprites[typeId])

        instance.sprite = Sprite:New(
			instance.drawable,
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 3 },
			0,
			1,
			DrawLayers.PickupDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)

        instance:Pickup_Initialize(leftHand, rightHand)
        return instance
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

}, Pickup)

Relic.__index = Relic

return Relic