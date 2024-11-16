local Common = require "Scripts.Common"

local Constants = 
{
    Left = -1,
    Right = 1,
}
local AudienceMember = 
{
    New = function(self, allSpriteData)
        local instance = setmetatable({}, self)

        instance.spriteData = self:GenerateRandomAudienceMember(allSpriteData)
        instance.speed = love.math.random(10, 30)
        instance.lower = 0
        instance.upper = love.graphics.getWidth() - (32 * 4)
        instance.position = {
            x = love.math.random(instance.lower, instance.upper),
            y = love.math.random(80),
        }
        local randomDirection = love.math.random(2)
        instance.direction = randomDirection == 1 and Constants.Left or Constants.Right

        instance.maxHealth = 30
        instance.health = instance.maxHealth

        return instance
    end,

    FixedUpdate = function(self, dt)
        if self.health == 0 then
            return
        end
        if self.position.x <= self.lower then
            self.direction = Constants.Right
        elseif self.position.x >= self.upper then
            self.direction = Constants.Left
        end

        self.position.x = self.position.x + (dt * self.speed * self.direction)
    end,

    Draw = function(self)
        if self.health == 0 then
            return
        end
        love.graphics.draw(self.spriteData.head.spritesheet, self.spriteData.head.quad, self.position.x, self.position.y, 0, 3, 3)
        love.graphics.draw(self.spriteData.face.spritesheet, self.spriteData.face.quad, self.position.x, self.position.y, 0, 3, 3)
        love.graphics.draw(self.spriteData.hair.spritesheet, self.spriteData.hair.quad, self.position.x, self.position.y, 0, 3, 3)
        --love.graphics.print(self.health, GameConstants.UI.Font, self.position.x, self.position.y)
    end,

    GenerateRandomAudienceMember = function(self, allSpriteData)
        local spriteData = {}

        -- Generate head shape
        spriteData.head = {}
        spriteData.head.spritesheet = allSpriteData.head.spritesheet
        spriteData.head.quad = allSpriteData.head.quads[love.math.random(table.count(allSpriteData.head.quads))]
        -- Generate hair
        spriteData.hair = {}
        spriteData.hair.spritesheet = allSpriteData.hair.spritesheet
        spriteData.hair.quad = allSpriteData.hair.quads[love.math.random(table.count(allSpriteData.hair.quads))]

        -- Store all facial expressions
        spriteData.face = {}
        spriteData.face.spritesheet = allSpriteData.face.spritesheet
        spriteData.face.expressionQuads = 
        {
            Neutral = allSpriteData.face.quads[1],
            Suspicious = allSpriteData.face.quads[2],
            Awe = allSpriteData.face.quads[3],
            Scared = allSpriteData.face.quads[4],
            Happy = allSpriteData.face.quads[5],
            ScaryHappy = allSpriteData.face.quads[6],
            Angry = allSpriteData.face.quads[7],
        }
        spriteData.face.quad =  spriteData.face.expressionQuads.Neutral

        return spriteData
    end,

    SetFaceAngry = function(self)
        self.spriteData.face.quad = self.spriteData.face.expressionQuads.Angry
    end,

    SetFaceNeutral = function(self)
        self.spriteData.face.quad = self.spriteData.face.expressionQuads.Neutral
    end,

    SetFaceHappy = function(self)
        self.spriteData.face.quad = self.spriteData.face.expressionQuads.Happy
    end,

    SetFaceAwe = function(self)
        self.spriteData.face.quad = self.spriteData.face.expressionQuads.Awe
    end,

    GetMaxHealth = function(self)
        return self.maxHealth
    end,

    GetHealth = function(self)
        return self.health
    end,

    SetHealth = function(self, health)
        self.health = health
    end,
}

AudienceMember.__index = AudienceMember

return AudienceMember