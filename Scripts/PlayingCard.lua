local PlayingCard = {
    SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

    Draw = function(self)
        love.graphics.draw(self.spritesheet, self.quad, self.position.x, self.position.y)
    end,
}

PlayingCard.__index = PlayingCard
PlayingCard.New = function(spritesheet, quad, position)
    local instance = setmetatable({}, PlayingCard)
    instance.spritesheet = spritesheet
    instance.quad = quad
    instance.position = position or { x = 0, y = 0 }
    return instance
end
return PlayingCard