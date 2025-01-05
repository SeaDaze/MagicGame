local Pickup = require "Scripts.Items.Pickup.Pickup"

local CreditCard = setmetatable(
{
	New = function(self, leftHand, rightHand)
		local instance = setmetatable({}, self)
        instance.drawable = love.graphics.newImage("Images/Items/CreditCard.png")

        instance.sprite = Sprite:New(
			instance.drawable,
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 3 },
			0,
			1,
			DrawLayers.PickupDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)

        instance:Pickup_Initialize(leftHand, rightHand, 1)
		instance.itemOwner = GameConstants.ItemOwners.Player
        return instance
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

}, Pickup)
CreditCard.__index = CreditCard
return CreditCard