
local Text = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================

    New = function(self, text, font, position, angle, layerIndex, alignment)
		local instance = setmetatable({}, self)
        instance.text = text
        instance.position =
        {
            x = position.x or 0,
            y = position.y or 0,
            z = position.z or 0,
        }

        instance.font = font
        instance.angle = angle or 0
        instance.layerIndex = layerIndex or 0
        instance.visible = true
        instance.alignment = alignment or "center"
        instance.type = GameConstants.DrawableTypes.Text
        instance.limit = love.graphics.getWidth()
        
        return instance
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    SetText = function(self, newText)
        self.text = newText
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

    SetVisible = function(self, isVisible)
        self.visible = isVisible
    end,
    -- ===========================================================================================================
    -- #endregion
}
Text.__index = Text
return Text