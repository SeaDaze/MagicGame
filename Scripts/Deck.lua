

local Deck = {
    HandleMovement = function(self, Flux, dt)
        if love.keyboard.isDown("w") then
            self.targetPosition.y = self.targetPosition.y - (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("a") then
            self.targetPosition.x = self.targetPosition.x - (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("s") then
            self.targetPosition.y = self.targetPosition.y + (self.moveSpeed * dt)
        end
        if love.keyboard.isDown("d") then
            self.targetPosition.x = self.targetPosition.x + (self.moveSpeed * dt)
        end
        Flux.to(self.position, 0.4, { x = self.targetPosition.x, y = self.targetPosition.y })
    end,

    Draw = function(self)
        love.graphics.draw(self.hand, self.position.x - 45, self.position.y - 60)
        --love.graphics.draw(self.spritesheet, self.quad, self.position.x, self.position.y)
    end,
}

Deck.__index = Deck
Deck.New = function()
    local instance = setmetatable({}, Deck)

    local deckWidth = 88
    local deckHeight = 140
    local spritesheetWidth = 264
    instance.spritesheet = love.graphics.newImage("Images/Cards/TopDown/DeckVertical.png")
    instance.hand = love.graphics.newImage("Images/leftHandHoldingDeck.png")
    instance.quad = love.graphics.newQuad(0, 0, deckWidth, deckHeight, spritesheetWidth, deckHeight)
    instance.position = { x = 0, y = 0 }
    instance.halfWidth = deckWidth / 2
    instance.halfHeight = deckHeight / 2
    instance.targetPosition = { x = 200, y = 200 }
    instance.moveSpeed = 150
    return instance
end
return Deck