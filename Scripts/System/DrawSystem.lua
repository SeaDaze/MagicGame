local LocalTimer = require "Scripts.Timer"
local EventIds   = require "Scripts.System.EventIds"

local Constants = 
{
	FadeTransitionDuration = 0.25,
	DefaultVignetteRadius = 1.5,
}

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
		self.debug_DrawCalls = 0

		self.blurEffect = Moonshine(Moonshine.effects.boxblur).chain(Moonshine.effects.pixelate)
		
		self.shadowCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
		
		self.shadowShader = love.graphics.newShader [[
			vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
				vec4 pixel = Texel(texture, texCoords);  // Get pixel from texture
				if (pixel.a > 0.0) {  // Only modify non-transparent pixels
					return vec4(0.0, 0.0, 0.0, 0.2);  // Force white color and 0.2 alpha
				}
				return pixel;  // Keep fully transparent pixels as they are
			}
		]]

		self.timer = LocalTimer:New()
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")

		self.transitioningScene = false
		self.vignetteRadius = 0
		self.vignetteShader = love.graphics.newShader("Scripts/Shaders/vignette.glsl")
		self.vignetteShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        self.vignetteShader:send("radius", self.vignetteRadius)  -- Controls how far the vignette effect reaches
        self.vignetteShader:send("softness", 1) -- Controls the smoothness of the vignette edges
    end,

	Update = function(self, dt)
		self.timer:Update(dt)
		for _, drawable in pairs(self.updateTable) do
			if drawable.Update then
				drawable:Update(dt)
			else
				print("DrawSystem:Update() Error - Drawable class does not contain Update() function")
			end
		end
		self.vignetteShader:send("radius", self.vignetteRadius)
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
		love.graphics.setShader(self.vignetteShader)

		self.debug_DrawCalls = 0
        for layerOrderedIndex, layerIndex in ipairs(self.orderedLayers) do
			if layerIndex == DrawLayers.LeftHandDefault then
				self:CreateShadowCanvas()
				self:DrawShadowCanvas()
			end

            for drawableIndex, drawableData in pairs(self.layers[layerIndex]) do
                if drawableData.visible and not drawableData.blur then
					self:EvaluateDrawableType(drawableData)
                end
            end
        end
		love.graphics.setShader()

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
		self.debug_DrawCalls = self.debug_DrawCalls + 1
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
		if spriteData.drawShadow and (spriteData.layerIndex < DrawLayers.DeckBottom or spriteData.layerIndex > DrawLayers.DeckTop) then
			love.graphics.setColor(0, 0, 0, 0.2)
			love.graphics.draw(
				spriteData.drawable,
				spriteData.position.x + 20,
				spriteData.position.y + 20,
				math.rad(spriteData.angle),
				GameSettings.WindowResolutionScale * spriteData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
				GameSettings.WindowResolutionScale * spriteData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
				spriteData.width * spriteData.originOffsetRatio.x,
				spriteData.height * spriteData.originOffsetRatio.y
			)
			love.graphics.setColor(1, 1, 1, 1)
		end
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

	DrawSprites = function(self, sprites)
		for i = 1, 10000 do
			love.graphics.draw(sprites[i])
		end
	end,

	DrawSpriteBatch = function(self, spriteBatchData)
		love.graphics.draw(spriteBatchData.spriteBatch)
	end,

	CreateShadowCanvas = function(self)
		love.graphics.setCanvas(self.shadowCanvas)
		love.graphics.clear(0, 0, 0, 0)
		for deckLayerIndex = DrawLayers.DeckBottom, DrawLayers.DeckTop, 1 do
			if self.layers[deckLayerIndex] then
				for drawableIndex, drawableData in pairs(self.layers[deckLayerIndex]) do
					if drawableData.drawShadow and drawableData.visible and not drawableData.blur then
						love.graphics.draw(
							drawableData.drawable,
							drawableData.position.x + 20,
							drawableData.position.y + 20,
							math.rad(drawableData.angle),
							GameSettings.WindowResolutionScale * drawableData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
							GameSettings.WindowResolutionScale * drawableData.scaleModifier,-- * (1 + (spriteData.position.z / 100)),
							drawableData.width * drawableData.originOffsetRatio.x,
							drawableData.height * drawableData.originOffsetRatio.y
						)
					end
				end
			end
		end
		love.graphics.setCanvas()
	end,

	DrawShadowCanvas = function(self)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setShader(self.shadowShader)
		love.graphics.draw(self.shadowCanvas, 0, 0)
		love.graphics.setShader(self.vignetteShader)
	end,

	OnTimerFinished = function(self, timerId)
        if timerId == "TransitionSceneFadeToBlack" then
			self:FadeToScene(Constants.FadeTransitionDuration)
			self.timer:Start("TransitionSceneFadeToScene", Constants.FadeTransitionDuration)
			EventSystem:BroadcastEvent(EventIds.SceneTransitionMiddle)
		elseif timerId == "TransitionSceneFadeToScene" then
			self.transitioningScene = false
			EventSystem:BroadcastEvent(EventIds.SceneTransitionEnd)
		end
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

	FadeToBlack = function(self, duration)
		Flux.to(self, duration, { vignetteRadius = 0 })
	end,

	FadeToScene = function(self, duration)
		Flux.to(self, duration, { vignetteRadius = Constants.DefaultVignetteRadius })
	end,

	StartSceneTransition = function(self)
		self.timer:Start("TransitionSceneFadeToBlack", Constants.FadeTransitionDuration)
		self:FadeToBlack(Constants.FadeTransitionDuration)
		EventSystem:BroadcastEvent(EventIds.SceneTransitionStart)
	end,

    -- ===========================================================================================================
    -- #endregion


}
return DrawSystem