local AICharacter = require("Scripts.AICharacter")

local AICharacterManager =
{
    Load = function(self, playerReference)
        self.aiCharacters = {}
        self.aiCount = 10
        self.playerReference = playerReference

        local aicharacterSprite = love.graphics.newImage("Images/Characters/character_02.png")
        for id = 1, self.aiCount do
            local randomInt = love.math.random(1, 2)
            local facingRight = randomInt == 1 or false
            local position = { x = math.random(0, love.graphics.getWidth()), y = 510 }
            table.insert(self.aiCharacters, AICharacter:New(facingRight, position, self.playerReference, aicharacterSprite, id))
        end
    end,

    Update = function(self, Flux, dt)
        for _, aiCharacter in pairs(self.aiCharacters) do
            aiCharacter:Update(Flux, dt)
        end
    end,

    DrawAllCharacters = function(self)
        for _, aiCharacter in pairs(self.aiCharacters) do
            aiCharacter:Draw()
        end
    end,
}

return AICharacterManager