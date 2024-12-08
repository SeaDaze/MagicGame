local BoxCollider = require("Scripts.Physics.BoxCollider")

local BuyZone = 
{
    Load = function(self)
        self.sprite = love.graphics.newImage("Images/UI/BuyZone.png")
        self.width = self.sprite:getWidth() * GameSettings.WindowResolutionScale
        self.height = self.sprite:getHeight() * GameSettings.WindowResolutionScale
        self.position = 
        {
            x = (love.graphics.getWidth() / 2),
            y = (love.graphics.getHeight() * 0.75),
        }
        self.centerOffset = { x = self.sprite:getWidth() / 2, y = self.sprite:getHeight() / 2 }

        self.collider = BoxCollider:BoxCollider_New(self.position, self.width, self.height, self.centerOffset)
    end,

    Update = function(self, dt)
        self.collider:BoxCollider_Update()
    end,

    Draw = function(self)
		love.graphics.draw(
            self.sprite,
            self.position.x,
            self.position.y,
            0,
            GameSettings.WindowResolutionScale,
            GameSettings.WindowResolutionScale,
            self.centerOffset.x,
            self.centerOffset.y
        )

        self.collider:BoxCollider_DebugDraw()
    end,

    GetCollider = function(self)
        return self.collider
    end,
}
return BuyZone