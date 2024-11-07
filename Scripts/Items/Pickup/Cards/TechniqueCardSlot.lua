
local TechniqueCardSlot = 
{
    New = function(self, sprite, position)
        local instance = setmetatable({}, self)
        
        instance.position = position
        instance.sprite = sprite
        instance.scaleModifier = GameSettings.WindowResolutionScale / 3
        return instance
    end,

    Update = function(self, dt)
    end,

    Draw = function(self)
        love.graphics.draw(
            self.sprite,
            self.position.x,
            self.position.y,
            0,
            self.scaleModifier,
            self.scaleModifier,
            self.sprite:getWidth() / 2,
            self.sprite:getHeight() / 2
        )
    end,

    GetAttachedCard = function(self)
        return self.attachedCard
    end,

    SetAttachedCard = function(self, card)
        if card then
            self.attachedCard = card
            self.attachedCard:SetPosition({ x = self.position.x, y = self.position.y })
            self.attachedCard:SetAttachedSlot(self)
        else
            self.attachedCard:SetAttachedSlot(nil)
            self.attachedCard = nil
        end
    end,

    EvaluateWithinRange = function(self, position)
        local distance = self.sprite:getWidth() * self.scaleModifier
        return Common:DistanceSquared(self.position.x, self.position.y, position.x, position.y) < (distance * distance)
    end,
}
TechniqueCardSlot.__index = TechniqueCardSlot
return TechniqueCardSlot