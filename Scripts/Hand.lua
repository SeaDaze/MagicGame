

local Hand = {
    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    FollowMouse = function(self, Flux)
        Flux.to(self.position, 0.4, { x = love.mouse.getX() - self.halfWidth, y = love.mouse.getY() - self.halfHeight})
    end,

    Draw = function(self)
        love.graphics.draw(self.sprite, self.position.x, self.position.y)
    end,
}

Hand.__index = Hand
Hand.New = function()
    local instance = setmetatable({}, Hand)
    instance.sprite = love.graphics.newImage("Images/rightHand.png")
    instance.position = { x = 0, y = 0 }
    instance.halfWidth = instance.sprite:getWidth() / 2
    instance.halfHeight = instance.sprite:getHeight() / 2
    return instance
end
return Hand