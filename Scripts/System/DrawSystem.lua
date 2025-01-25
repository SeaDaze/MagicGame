

local DrawSystem = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================

    Load = function(self)
        self.layers = {}
        self.orderedLayers = {}
		self.updateTable = {}
        self.debug_DrawFunctions = {}
        self.debug_DrawIndex = 0
		self.blurEffect = Moonshine(Moonshine.effects.boxblur).chain(Moonshine.effects.pixelate)
		self.debug_DrawCalls = 0
    end,

	Update = function(self, dt)
		for _, drawable in pairs(self.updateTable) do
			if drawable.Update then
				drawable:Update(dt)
			else
				print("DrawSystem:Update() Error - Drawable class does not contain Update() function")
			end
		end
	end,

    DrawAll = function(self)
		-- self.blurEffect(
		-- 	function()
		-- 		for layerOrderedIndex, layerIndex in ipairs(self.orderedLayers) do
		-- 			for drawableIndex, drawableData in pairs(self.layers[layerIndex]) do
		-- 				if drawableData.blur then
		-- 					self:EvaluateDrawableType(drawableData)
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- )
		self.debug_DrawCalls = 0
        for layerOrderedIndex, layerIndex in ipairs(self.orderedLayers) do
            for drawableIndex, drawableData in pairs(self.layers[layerIndex]) do
                if drawableData.visible and not drawableData.blur then
					self:EvaluateDrawableType(drawableData)
					self.debug_DrawCalls = self.debug_DrawCalls + 1
                end
            end
        end

        if not GameSettings.Debug_Show then
            return
        end
        for _, func in pairs(self.debug_DrawFunctions) do
            func()
        end
    end,

	EvaluateDrawableType = function(self, drawableData)
		if drawableData.colorOverride then
			love.graphics.setColor(drawableData.colorOverride)
		end
		if drawableData.type == GameConstants.DrawableTypes.Sprite then
			self:DrawSprite(drawableData)
		elseif drawableData.type == GameConstants.DrawableTypes.Text then
			self:DrawText(drawableData)
		elseif drawableData.type == GameConstants.DrawableTypes.SpritesheetQuad then
			self:DrawSpritesheetQuad(drawableData)
		elseif drawableData.type == GameConstants.DrawableTypes.ComplexSpritesheetQuad then
			self:DrawComplexSpritesheetQuad(drawableData)
		elseif drawableData.type == GameConstants.DrawableTypes.ParticleSystem then
			self:DrawParticleSystem(drawableData)
		elseif drawableData.type == GameConstants.DrawableTypes.SpriteBatch then
			self:DrawSpriteBatch(drawableData)
		end
		if drawableData.colorOverride then
			love.graphics.setColor(1, 1, 1, 1)
		end
	end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

	LoadImage = function(self, imagePath)
		Log.Low("LoadImage: Loaded image with path: ", imagePath)
		return love.graphics.newImage(imagePath)
	end,

	---@param self any
	---@param spritesheet love.Image
	---@param spriteWidth number
	---@param spriteHeight number
	ExtractAllSpritesheetQuads = function(self, spritesheet, spriteWidth, spriteHeight)
		local spritesheetWidth = spritesheet:getWidth()
		local spritesheetHeight = spritesheet:getHeight()

		local columns = spritesheetWidth / spriteWidth
		local rows = spritesheetHeight / spriteHeight
		local quads = {}
		local quadIndex = 1
		for y = 0, rows - 1 do
			for x = 0, columns - 1 do
				quads[quadIndex] = love.graphics.newQuad(x * spriteWidth, y * spriteHeight, spriteWidth, spriteHeight, spritesheetWidth, spritesheetHeight)
				quadIndex = quadIndex + 1
			end
		end
		Log.Med("ExtractAllSpritesheetQuads: Extracted ", table.count(quads), " quads")
		return quads
	end,

	---@param self any
	---@param spritesheet love.Image
	---@param spriteWidth number
	---@param spriteHeight number
	ExtractSpritesheetQuadByRow = function(self, spritesheet, spriteWidth, spriteHeight, row, columns)
		local spritesheetWidth = spritesheet:getWidth()
		local spritesheetHeight = spritesheet:getHeight()

		local quads = {}
		local quadIndex = 1

		for x = 0, columns - 1 do
			quads[quadIndex] = love.graphics.newQuad(x * spriteWidth, (row - 1) * spriteHeight, spriteWidth, spriteHeight, spritesheetWidth, spritesheetHeight)
			quadIndex = quadIndex + 1
		end
		Log.Med("ExtractSpritesheetQuadByRow: Extracted ", table.count(quads), " quads")
		return quads
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    DrawSprite = function(self, spriteData)
        love.graphics.draw(
            spriteData.drawable,
            spriteData.position.x,
            spriteData.position.y,
            math.rad(spriteData.angle),
            GameSettings.WindowResolutionScale * spriteData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
            GameSettings.WindowResolutionScale * spriteData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
            spriteData.width * spriteData.originOffsetRatio.x,
            spriteData.height * spriteData.originOffsetRatio.y
        )
        if GameSettings.Debug_DrawSpriteOrigins then
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.ellipse(
                "fill",
                spriteData.position.x,
                spriteData.position.y,
                5,
                5,
                6
            )
            love.graphics.setColor(1, 1, 1, 1)
        end
    end,

    DrawSpritesheetQuad = function(self, spritesheetData)
        love.graphics.draw(
            spritesheetData.drawableSpritesheet,
            spritesheetData.quad,
            spritesheetData.position.x,
            spritesheetData.position.y,
            math.rad(spritesheetData.angle),
            GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
            GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
            spritesheetData.width * spritesheetData.originOffsetRatio.x,
            spritesheetData.height * spritesheetData.originOffsetRatio.y
        )
    end,

	DrawComplexSpritesheetQuad = function(self, spritesheetData)
		for index, spritesheet in ipairs(spritesheetData.drawableSpritesheetTable) do
			love.graphics.draw(
				spritesheet,
				spritesheetData.quadTable[index],
				spritesheetData.position.x,
				spritesheetData.position.y,
				math.rad(spritesheetData.angle),
				GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
				GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
				spritesheetData.width * spritesheetData.originOffsetRatio.x,
				spritesheetData.height * spritesheetData.originOffsetRatio.y
			)
		end
    end,

    DrawText = function(self, textData)
        love.graphics.printf(
            textData.text,
            textData.font,
            textData.position.x,
            textData.position.y,
            textData.limit,
            textData.alignment
        )
    end,

	DrawParticleSystem = function(self, particleSystemData)
		love.graphics.draw(particleSystemData.particleSystem)
	end,

	DrawSpriteBatch = function(self, spriteBatchData)
		love.graphics.draw(spriteBatchData.spriteBatch)
	end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    AddDrawable = function(self, drawable)
        if not drawable then
            Log.Error("AddDrawable: Received drawable is nil")
            return
        end
        if not drawable.type then
			Log.Error("AddDrawable: Received drawable does not have a type")
            return
        end
        local layerIndex = drawable.layerIndex
        if not self.layers[layerIndex] then
            self.layers[layerIndex] = {}
        end
        table.insert(self.layers[layerIndex], drawable)
		if not table.findKey(self.orderedLayers, layerIndex) then
			table.insert(self.orderedLayers, layerIndex)
		end
        table.sort(self.orderedLayers)
		if drawable.requiresUpdate then
			table.insert(self.updateTable, drawable)
		end
		Log.Med("AddDrawable: ")
    end,

    RemoveDrawable = function(self, drawable)
        if not drawable then
            print("RemoveDrawable: Received sprite is nil")
            return
        end
        local layerIndex = drawable.layerIndex
        table.removeByValue(self.layers[layerIndex], drawable)
		if drawable.requiresUpdate then
			table.removeByValue(self.updateTable, drawable)
		end

		Log.Med("RemoveDrawable: ")
    end,

    ChangeDrawableLayerIndex = function(self, drawable, newLayerIndex)
        self:RemoveDrawable(drawable)
        drawable.layerIndex = newLayerIndex
        self:AddDrawable(drawable)
    end,

    AddDebugDraw = function(self, func)
        self.debug_DrawIndex = self.debug_DrawIndex + 1
        self.debug_DrawFunctions[self.debug_DrawIndex] = func
        return self.debug_DrawIndex
    end,

    RemoveDebugDraw = function(self, drawIndex)
        if not self.debug_DrawFunctions[drawIndex] then
            return
        end
        self.debug_DrawFunctions[drawIndex] = nil
    end,

    -- ===========================================================================================================
    -- #endregion


}
return DrawSystem