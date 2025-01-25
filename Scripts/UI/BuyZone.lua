local BoxCollider = require("Scripts.Physics.BoxCollider")

local BuyZone = 
{
    Load = function(self)
        self.drawable = DrawSystem:LoadImage("Images/UI/BuyZone.png")

        self.sprite = Sprite:New(
			self.drawable,
			{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() * 0.75, z = 0 },
			0,
			1,
			DrawLayers.PickupDefault,
			true,
			{ x = 0.5, y = 0.5 }
		)

        self.collider = BoxCollider:BoxCollider_New(self, self.sprite.position, self.sprite.width, self.sprite.height, { x = 0.5, y = 0.5 })
    end,

    OnStart = function(self)
        DrawSystem:AddDrawable(self.sprite)
        self.collider:BoxCollider_OnStart()
	end,

	OnStop = function(self)
        DrawSystem:RemoveDrawable(self.sprite)
	end,

    Update = function(self, dt)
        self.collider:BoxCollider_Update()
    end,

    GetCollider = function(self)
        return self.collider
    end,
}
return BuyZone