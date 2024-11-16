
local TechniqueCardSlot = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    New = function(self, index, sprites, position)
        local instance = setmetatable({}, self)

        instance.index = index
        instance.position = position
        instance.slotSprite = sprites.slot
        instance.scaleModifier = GameSettings.WindowResolutionScale / 3
        instance.completedSprite = sprites.completed
        instance.selectedSprite = sprites.selected
        return instance
    end,

    Update = function(self, dt)
    end,

    Draw = function(self)
        love.graphics.draw(
            self.slotSprite,
            self.position.x,
            self.position.y,
            0,
            self.scaleModifier,
            self.scaleModifier,
            self.slotSprite:getWidth() / 2,
            self.slotSprite:getHeight() / 2
        )
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    -- Tags are drawn by externals so they are not inside the usual draw function
    DrawTag = function(self)
        if self.tagSprite then
            love.graphics.draw(
                self.tagSprite,
                self.position.x,
                self.position.y,
                0,
                self.scaleModifier,
                self.scaleModifier,
                self.tagSprite:getWidth() / 2,
                self.tagSprite:getHeight() / 2
            )
        end
    end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    SetSelected = function(self)
        self.tagSprite = self.selectedSprite
    end,

    SetCompleted = function(self)
        self.tagSprite = self.completedSprite
    end,

    ClearTag = function(self)
        self.tagSprite = nil
    end,

    GetAttachedCard = function(self)
        return self.attachedCard
    end,

    SetAttachedCard = function(self, card)
        if card then
            if self.attachedCard then
                return
            end
            self.attachedCard = card
            self.attachedCard:SetPosition({ x = self.position.x, y = self.position.y })
            self.attachedCard:SetAttachedSlot(self)
            Player:SetRoutineIndex(self.index, card:GetTypeId())
        else
            self.attachedCard:SetAttachedSlot(nil)
            self.attachedCard = nil
            Player:SetRoutineIndex(self.index, nil)
        end
    end,

    EvaluateWithinRange = function(self, position)
        local distance = self.slotSprite:getWidth() * self.scaleModifier
        return Common:DistanceSquared(self.position.x, self.position.y, position.x, position.y) < (distance * distance)
    end,
}
TechniqueCardSlot.__index = TechniqueCardSlot
return TechniqueCardSlot