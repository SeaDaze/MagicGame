

local RightHand = {
    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    FollowMouse = function(self, Flux)
        Flux.to(self.position, 0.4, { x = love.mouse.getX(), y = love.mouse.getY()})
    end,

    Draw = function(self)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, math.rad(self.angle), 1, 1, self.halfWidth + 10, self.halfHeight + 20)
    end,
}

RightHand.__index = RightHand
RightHand.New = function()
    local instance = setmetatable({}, RightHand)
    instance.sprite = love.graphics.newImage("Images/rightHand.png")
    instance.position = { x = 300, y = 300 }
    instance.halfWidth = instance.sprite:getWidth() / 2
    instance.halfHeight = instance.sprite:getHeight() / 2
	instance.angle = 0
    return instance
end
return RightHand