local AudienceMember = require("Scripts.Audience.AudienceMember")
local Common         = require("Scripts.Common")

local Audience = 
{
    New = function(self)
        local instance = setmetatable({}, self)

        local spriteWidth, spriteHeight = 32, 32
        local headSpritesheet = love.graphics.newImage("Images/Faces/Head_Base_Spritesheet.png")
        local hairSpritesheet = love.graphics.newImage("Images/Faces/Hair_Spritesheet.png")
        local faceSpritesheet = love.graphics.newImage("Images/Faces/Face_Spritesheet.png")

        local headQuads = self:GetTableOfQuads(headSpritesheet, spriteWidth, spriteHeight)
        local hairQuads = self:GetTableOfQuads(hairSpritesheet, spriteWidth, spriteHeight)
        local faceQuads = self:GetTableOfQuads(faceSpritesheet, spriteWidth, spriteHeight)

        local spriteData = {
            head = {
                spritesheet = headSpritesheet,
                quads = headQuads,
            },
            hair = {
                spritesheet = hairSpritesheet,
                quads = hairQuads,
            },
            face = {
                spritesheet = faceSpritesheet,
                quads = faceQuads,
            }
        }

        instance.audience = {}

        for i = 1, 10 do
            table.insert(instance.audience, AudienceMember:New(spriteData))
        end

        return instance
    end,

    FixedUpdate = function(self, dt)
        for _, audienceMember in pairs(self.audience) do
           audienceMember:FixedUpdate(dt)
        end
    end,

    SetAudienceAwe = function(self, score)
        if not score then
            return
        end
        if score < 25 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceAngry()
            end
        elseif score < 50 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceNeutral()
            end
        elseif score < 75 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceHappy()
            end
        else
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceAwe()
            end
        end
        
    end,

    Draw = function(self)
        for _, audienceMember in pairs(self.audience) do
            audienceMember:Draw()
        end
    end,

    GetTableOfQuads = function(self, spritesheet, spriteWidth, spriteHeight)
        local quads = {}
        local spritesheetWidth = spritesheet:getWidth()
        local spritesheetHeight = spritesheet:getHeight()
        local count = spritesheetWidth / spriteWidth
        local x = 0
        for i = 1, count do
            local quad = love.graphics.newQuad(x, 0, spriteWidth, spriteHeight, spritesheetWidth, spritesheetHeight)
            table.insert(quads, quad)
            x = x + spriteWidth
        end
        return quads
    end,
}
Audience.__index = Audience
return Audience