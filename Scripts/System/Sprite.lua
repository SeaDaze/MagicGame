
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
		instance.originOffset = {
            x = (instance.originOffsetRatio.x * instance.width * GameSettings.WindowResolutionScale),
            y = (instance.originOffsetRatio.y * instance.height * GameSettings.WindowResolutionScale),
        }
        return instance
    end,

	---comment
	---@param self any
	---@param drawableSpritesheet love.Image
	---@param quad love.Quad
	---@param dimensions table (width, height)
	---@param position table (x, y)
	---@param angle number
	---@param scaleModifier number
	---@param layerIndex number
	---@param drawShadow boolean
	---@param originOffsetRatio table (x, y)
	---@return table|nil
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
		instance.originOffset = {
            x = (instance.originOffsetRatio.x * instance.width * GameSettings.WindowResolutionScale),
            y = (instance.originOffsetRatio.y * instance.height * GameSettings.WindowResolutionScale),
        }
        return instance
    end,

	NewComplexSpriteFromSpritesheet = function(self, drawableSpritesheetTable, quadTable, dimensions, position, angle, scaleModifier, layerIndex, drawShadow, originOffsetRatio)
		local spriteCount = table.count(drawableSpritesheetTable)
		local quadCount = table.count(quadTable)

		if spriteCount ~= quadCount then
			print("Sprite:NewComplexSprite() Error - Cannot create new sprite object, number of spritesheets and quads is mismatched")
            return nil
		end

		local instance = setmetatable({}, self)
		instance.drawableSpritesheetTable = drawableSpritesheetTable
        instance.quadTable = quadTable

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
        instance.type = GameConstants.DrawableTypes.ComplexSpritesheetQuad
		instance.originOffset = {
            x = (instance.originOffsetRatio.x * instance.width * GameSettings.WindowResolutionScale),
            y = (instance.originOffsetRatio.y * instance.height * GameSettings.WindowResolutionScale),
        }
		return instance
	end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    CreateSpritesheetQuad = function(self, spritesheet, columnCount, rowCount, column, row)
        if column <= 0 then
            return
        end
        if row <= 0 then
            return
        end

        local spriteWidth = spritesheet:GetWidth() / columnCount
        local spriteHeight = spritesheet:GetHeight() / rowCount

        local x = (column - 1) * spriteWidth
        local y = (row - 1) * spriteHeight

        return love.graphics.newQuad(x, y, spriteWidth, spriteHeight, spritesheet:GetWidth(), spritesheet:GetHeight())
    end,

	GetSocket = function(self, socketName)
		if self.GetSocketFunctions[socketName] then
			return self.GetSocketFunctions[socketName](self)
		end
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

	-- Gets the socket position taking into account the rotation relative to the origin and the origin offset
	GetRelativeSocketPosition = function(self, socket)
		return Common:RotatePointAroundPoint({
			x = socket.x - self.originOffset.x,
			y = socket.y - self.originOffset.y,
		}, self.position, self.angle)
	end,

	GetSocketFunctions = 
	{
		TopLeft = function(self)
			return self:GetRelativeSocketPosition(self.position)
		end,

		Top = function(self)
			return self:GetRelativeSocketPosition({
                x = self.position.x + (0.5 * self.width * GameSettings.WindowResolutionScale),
                y = self.position.y,
            })
		end,

		TopRight = function(self)
			return self:GetRelativeSocketPosition({
                x = self.position.x + (self.width * GameSettings.WindowResolutionScale),
                y = self.position.y,
            })
		end,

		BottomLeft = function(self)
			return self:GetRelativeSocketPosition({
                x = self.position.x,
                y = self.position.y + (self.height * GameSettings.WindowResolutionScale),
            })
		end,

		Bottom = function(self)
			return self:GetRelativeSocketPosition({
                x = self.position.x + (0.5 * self.width * GameSettings.WindowResolutionScale),
                y = self.position.y + (self.height * GameSettings.WindowResolutionScale),
            })
		end,

		BottomRight = function(self)
			return self:GetRelativeSocketPosition({
                x = self.position.x + (self.width * GameSettings.WindowResolutionScale),
                y = self.position.y + (self.height * GameSettings.WindowResolutionScale),
            })
		end,
	},

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

    GetAngle = function(self)
        return self.angle
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
		self.originOffset = {
            x = (self.originOffsetRatio.x * self.width * GameSettings.WindowResolutionScale),
            y = (self.originOffsetRatio.y * self.height * GameSettings.WindowResolutionScale),
        }
	end,

	SetColorOverride = function(self, color)
		self.colorOverride = color
	end,
    -- ===========================================================================================================
    -- #endregion
}
Sprite.__index = Sprite
return Sprite