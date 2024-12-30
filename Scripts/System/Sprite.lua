
local Sprite =
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    New = function(self, drawable, position, angle, scaleModifier, layerIndex, drawShadow, originOffsetRatio)
        if not drawable then
            print("Sprite:New() Error - Cannot create new sprite object, received drawable is nil")
            return nil
        end

		local instance = setmetatable({}, self)
        -- Inputs
        instance.drawable = drawable
        instance.position =
        {
            x = position.x or 0,
            y = position.y or 0,
            z = position.z or 0,
        }
        instance.angle = angle or 0
        instance.scaleModifier = scaleModifier or 1
        instance.layerIndex = layerIndex or 0
        instance.drawShadow = drawShadow
        instance.originOffsetRatio = originOffsetRatio or { x = 0, y = 0 }

        -- New variables
        instance.width = drawable:getWidth()
        instance.height = drawable:getHeight()
        instance.visible = true
        instance.type = GameConstants.DrawableTypes.Sprite

        return instance
    end,

    NewFromSpritesheet = function(self, drawableSpritesheet, quad, dimensions, position, angle, scaleModifier, layerIndex, drawShadow, originOffsetRatio)
        if not drawableSpritesheet then
            print("Sprite:NewFromSpritesheet() Error - Cannot create new sprite object, received drawable is nil")
            return nil
        end

		local instance = setmetatable({}, self)
        -- Inputs
        instance.drawableSpritesheet = drawableSpritesheet
        instance.quad = quad
        instance.position =
        {
            x = position.x or 0,
            y = position.y or 0,
            z = position.z or 0,
        }
        instance.angle = angle or 0
        instance.scaleModifier = scaleModifier or 1
        instance.layerIndex = layerIndex or 0
        instance.drawShadow = drawShadow
        instance.originOffsetRatio = originOffsetRatio or { x = 0, y = 0 }

        -- New variables
        instance.width = dimensions.width
        instance.height = dimensions.height
        instance.visible = true
        instance.type = GameConstants.DrawableTypes.SpritesheetQuad

        return instance
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    CreateSpritesheetQuad = function(self, spritesheet, columnCount, rowCount, column, row)
        if not column > 0 then
            return
        end
        if not row > 0 then
            return
        end

        local spriteWidth = spritesheet:GetWidth() / columnCount
        local spriteHeight = spritesheet:GetHeight() / rowCount

        local x = (column - 1) * spriteWidth
        local y = (row - 1) * spriteHeight
        
        return love.graphics.newQuad(x, y, spriteWidth, spriteHeight, spritesheet:GetWidth(), spritesheet:GetHeight())
    end,

    GetAllSockets = function(self)
        local originOffset = 
        {
            x = (self.originOffsetRatio.x * self.width * GameSettings.WindowResolutionScale),
            y = (self.originOffsetRatio.y * self.height * GameSettings.WindowResolutionScale),
        }

        local sockets = {
            topLeft = Common:RotatePointAroundPoint(
            {
                x = self.position.x - (originOffset.x),
                y = self.position.y - (originOffset.y),
            }, self.position, self.angle),
            top = Common:RotatePointAroundPoint(
            {
                x = self.position.x,
                y = self.position.y - (originOffset.y),
            }, self.position, self.angle),
            topRight = Common:RotatePointAroundPoint(
            {
                x = self.position.x + (self.width * GameSettings.WindowResolutionScale) - (originOffset.x),
                y = self.position.y - (originOffset.y),
            }, self.position, self.angle),
            bottomLeft = Common:RotatePointAroundPoint(
            {
                x = self.position.x - (originOffset.x),
                y = self.position.y + (self.height * GameSettings.WindowResolutionScale) - (originOffset.y),
            }, self.position, self.angle),
            bottomRight = Common:RotatePointAroundPoint(
            {
                x = self.position.x + (self.width * GameSettings.WindowResolutionScale) - (originOffset.x),
                y = self.position.y + (self.height * GameSettings.WindowResolutionScale) - (originOffset.y),
            }, self.position, self.angle),
        }

        return sockets
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    SetDrawable = function(self, drawable)
        self.drawable = drawable
    end,

    GetDrawable = function(self)
        return self.drawable
    end,

    SetPosition = function(self, position)
        self.position = {
            x = position.x,
            y = position.y,
            z = position.z or 0,
        }
    end,

    GetPosition = function(self)
        return self.position
    end,

    GetHeight = function(self)
        return self.height
    end,

    GetWidth = function(self)
        return self.width
    end,

    SetVisible = function(self, isVisible)
        self.visible = isVisible
    end,

    SetScaleModifier = function(self, newScaleModifier)
        self.scaleModifier = newScaleModifier
    end,

    SetOriginOffsetRatio = function(self, originOffsetRatio)
		self.originOffsetRatio = 
        {
            x = originOffsetRatio.x,
            y = originOffsetRatio.y,
        }
	end,

    -- ===========================================================================================================
    -- #endregion
}
Sprite.__index = Sprite
return Sprite