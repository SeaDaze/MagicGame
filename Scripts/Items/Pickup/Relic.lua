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
        instance.sprite = love.graphics.newImage(RelicSprites[typeId])

        instance:Pickup_Initialize(leftHand, rightHand)
        instance.windowScaleFraction = 1
        return instance
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
        print("Relic: OnStart")
    end,

}, Pickup)

Relic.__index = Relic

return Relic