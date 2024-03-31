

local RightHand = {
    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    FollowMouse = function(self, Flux)
        Flux.to(self.position, 0.2, { x = love.mouse.getX(), y = love.mouse.getY()})
    end,

    Draw = function(self)
		if love.mouse.isDown(1) then
			love.graphics.draw(self.pinchSprite, self.position.x, self.position.y, math.rad(self.angle), 4, 4, self.halfWidth, self.halfHeight)
		else
			love.graphics.draw(self.sprite, self.position.x, self.position.y, math.rad(self.angle), 4, 4, self.halfWidth, self.halfHeight)
		end
    end,

	GetIndexFingerPosition = function(self)
		local pos = { x = self.position.x + self.indexFingerOffset.x, y = self.position.y + self.indexFingerOffset.y }
		return pos
	end,

}

RightHand.__index = RightHand
RightHand.New = function()
    local instance = setmetatable({}, RightHand)
    instance.sprite = love.graphics.newImage("Images/Hands/right_palmDown_ThumbIn.png")
	instance.pinchSprite = love.graphics.newImage("Images/Hands/right_palmDown_Pinch.png")
    instance.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
	instance.indexFingerOffset = { x = - 25, y = -35 }
    instance.halfWidth = instance.sprite:getWidth() / 2
    instance.halfHeight = instance.sprite:getHeight() / 2
	instance.angle = 0
    return instance
end
return RightHand