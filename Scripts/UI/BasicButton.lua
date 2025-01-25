
local Button = require("Scripts.UI.Button")

local BasicButtonType = 
{
    [GameConstants.UI.BasicButtonType.Rectangle] = 
    {
        default = "Images/UI/Buttons/Basic/BasicButton_Default.png",
        hovered = "Images/UI/Buttons/Basic/BasicButton_Hovered.png",
        selected = "Images/UI/Buttons/Basic/BasicButton_Selected.png",
        size = 
        {
            x = 64,
            y = 32,
        }
    },
    [GameConstants.UI.BasicButtonType.Square] = 
    {
        default = "Images/UI/Buttons/squareButton_Default.png",
        hovered = "Images/UI/Buttons/squareButton_Hovered.png",
        selected = "Images/UI/Buttons/squareButton_Selected.png",
        size = 
        {
            x = 32,
            y = 32,
        }
    },
}

local BasicButton = {
    New = function(self, type, text, position, anchor)
        local instance = setmetatable({}, self)
        --instance.size = BasicButtonType[type].size
    
        instance.defaultSprite = DrawSystem:LoadImage(BasicButtonType[type].default)
        instance.hoveredSprite = DrawSystem:LoadImage(BasicButtonType[type].hovered)
        instance.selectedSprite = DrawSystem:LoadImage(BasicButtonType[type].selected)
        instance.size = 
        {
            x = instance.defaultSprite:getWidth(),
            y = instance.defaultSprite:getHeight(),
        }
        instance:Initialize(instance.size.x, instance.size.y)
        instance.sprite = instance.defaultSprite
        instance.text = text
        instance.anchor = anchor
        instance.position = position
        return instance
    end,

    Update = function(self, dt)
        self:SuperUpdate(dt)
	end,

    Draw = function(self)
        local scale = self:GetScale()
        love.graphics.draw(self.sprite, self:GetOnScreenPosition().x, self:GetOnScreenPosition().y, 0, scale, scale)
        love.graphics.print(self.text, GameConstants.UI.Font, self:GetTextPosition().x, self:GetTextPosition().y)
    end,

    OnMouseHoverStart = function(self)
        self.sprite = self.hoveredSprite
        print("OnMouseHoverStart: ", self.text)
    end,

    OnMouseHoverStop = function(self)
        self.sprite = self.defaultSprite
        print("OnMouseHoverStop: ", self.text)
    end,

    OnMouseClickStart = function(self)
        self.sprite = self.selectedSprite
        self:SendEventToListeners()
        print("OnMouseClickStart: ", self.text)
    end,

    OnMouseClickStop = function(self)
        if self:GetHovered() then
            self.sprite = self.hoveredSprite
        else
            self.sprite = self.defaultSprite
        end
        print("OnMouseClickStop: ", self.text)
    end,

    GetScale = function(self)
        return GameSettings.UIScale --GameSettings.WindowResolutionScale + GameSettings.UIScaleOffset
    end,

    GetOnScreenPosition = function(self)
        local onScreenSize = self:GetOnScreenSize()
        if self.anchor == GameConstants.UI.Anchor.Left or self.anchor == GameConstants.UI.Anchor.Top then
            return self.position
        elseif self.anchor == GameConstants.UI.Anchor.Right then
            return {
                x = love.graphics.getWidth() - onScreenSize.x - self.position.x,
                y = self.position.y,
            }
        elseif self.anchor == GameConstants.UI.Anchor.Bottom then
            return {
                x = self.position.x,
                y = love.graphics.getHeight() - onScreenSize.y - self.position.y,
            }
        end
    end,

    GetTextPosition = function(self)
        local basePosition = self:GetOnScreenPosition()
        local onScreenSize = self:GetOnScreenSize()
        return {
            x = basePosition.x + (onScreenSize.x / 4),
            y = basePosition.y + (onScreenSize.y / 3),
        }
    end,

    GetOnScreenSize = function(self)
        return {
            x = self.size.x * self:GetScale(),
            y = self.size.y * self:GetScale(),
        }
    end,
}

BasicButton.__index = BasicButton
setmetatable(BasicButton, Button)
return BasicButton