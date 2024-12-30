

local Inventory = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================

    Load = function(self)
        self.relics = {}
        self.inventoryItemScaleModifier = 0.5
    end,

    Update = function(self, dt)
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================

    AddRelicToInventory = function(self, relic)
        relic:SetItemOwner(GameConstants.ItemOwners.Player)
        relic:SetActive(false)

        local relicCount = table.count(self.relics)
        local position
        local relicSprite = relic:GetSprite()
        relicSprite:SetScaleModifier(self.inventoryItemScaleModifier)

        -- Modify positions taking into account window resolution, the sprite center and new inventory scale
        local scaleModifier = GameSettings.WindowResolutionScale * self.inventoryItemScaleModifier
        if relicCount > 0 then
            local lastRelicSprite = self.relics[relicCount]:GetSprite()
            position = {
                x = lastRelicSprite:GetPosition().x + (lastRelicSprite:GetWidth() * scaleModifier),
                y = lastRelicSprite:GetHeight() * scaleModifier / 2,
                z = 0,
            }
        else
            position = {
                x = relicSprite:GetWidth() * scaleModifier / 2,
                y = relicSprite:GetHeight() * scaleModifier / 2,
                z = 0,
            }
        end

        relic:SetPosition(position)
        relic:GetCollider():BoxCollider_SetScaleModifier({ x = self.inventoryItemScaleModifier, y = self.inventoryItemScaleModifier })
        table.insert(self.relics, relic)
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #endregion
}
return Inventory