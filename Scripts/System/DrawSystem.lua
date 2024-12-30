
local mask_shader = love.graphics.newShader[[
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]

local DrawSystem = 
{

    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================

    Load = function(self)
        self.layers = {}
        self.orderedLayers = {}
        self.debug_DrawFunctions = {}
        self.debug_DrawIndex = 0
    end,

    DrawAll = function(self)
        for layerOrderedIndex, layerIndex in ipairs(self.orderedLayers) do
            for drawableIndex, drawableData in pairs(self.layers[layerIndex]) do
                if drawableData.visible then
                    if drawableData.type == GameConstants.DrawableTypes.Sprite then
                        self:DrawSprite(drawableData)
                    elseif drawableData.type == GameConstants.DrawableTypes.Text then
                        self:DrawText(drawableData)
                    elseif drawableData.type == GameConstants.DrawableTypes.SpritesheetQuad then
                        self:DrawSpritesheetQuad(drawableData)
                    end
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

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    DrawSprite = function(self, spriteData)
        --if spriteData.drawShadow and spriteData.position.z > 0 then
            -- love.graphics.setColor(0, 0, 0, 0.2)
            -- love.graphics.draw(
            --     spriteData.drawable,
            --     spriteData.position.x + (spriteData.position.z * GameSettings.WindowResolutionScale),
            --     spriteData.position.y + (spriteData.position.z * GameSettings.WindowResolutionScale),
            --     math.rad(spriteData.angle),
            --     GameSettings.WindowResolutionScale * spriteData.scaleModifier * (1 + (spriteData.position.z / 100)),
            --     GameSettings.WindowResolutionScale * spriteData.scaleModifier * (1 + (spriteData.position.z / 100)),
            --     spriteData.width * spriteData.originOffsetRatio.x,
            --     spriteData.height * spriteData.originOffsetRatio.y
            -- )
            -- love.graphics.setColor(1, 1, 1, 1)
        --end
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
        if spritesheetData.drawShadow and spritesheetData.position.z > 0 then
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.draw(
                spritesheetData.drawableSpritesheet,
                spritesheetData.quad,
                spritesheetData.position.x + (spritesheetData.position.z * GameSettings.WindowResolutionScale),
                spritesheetData.position.y + (spritesheetData.position.z * GameSettings.WindowResolutionScale),
                math.rad(spritesheetData.angle),
                GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
                GameSettings.WindowResolutionScale * spritesheetData.scaleModifier * (1 + (spritesheetData.position.z / 100)),
                spritesheetData.width * spritesheetData.originOffsetRatio.x,
                spritesheetData.height * spritesheetData.originOffsetRatio.y
            )
            love.graphics.setColor(1, 1, 1, 1)
        end
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

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================

    AddDrawable = function(self, drawable)
        if not drawable then
            print("AddDrawable: Received drawable is nil")
            return
        end
        if not drawable.type then
            print("AddDrawable: Received drawable does not have a type")
            return
        end
        local layerIndex = drawable.layerIndex
        if not self.layers[layerIndex] then
            self.layers[layerIndex] = {}
        end
        table.insert(self.layers[layerIndex], drawable)
        table.insert(self.orderedLayers, layerIndex)
        table.sort(self.orderedLayers)
    end,

    RemoveDrawable = function(self, drawable)
        if not drawable then
            print("AddDrawable: Received sprite is nil")
            return
        end
        local layerIndex = drawable.layerIndex
        table.removeByValue(self.layers[layerIndex], drawable)
    end,

    ChangeDrawableLayerIndex = function(self, drawable, newLayerIndex)
        self:RemoveDrawable(drawable)
        drawable.layerIndex = newLayerIndex
        self:AddDrawable(drawable)
    end,

    AddDebugDraw = function(self, func)
        self.debug_DrawIndex = self.debug_DrawIndex + 1
        self.debug_DrawFunctions[self.debug_DrawIndex] = func
        table.insert(self.debug_DrawFunctions, func)
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