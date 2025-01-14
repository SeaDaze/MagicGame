local AudienceMember = require("Scripts.Audience.AudienceMember")

local Audience = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================
	Load = function(self)
        local headSpritesheet = love.graphics.newImage("Images/Faces/Head_Base_Spritesheet.png")
        local hairSpritesheet = love.graphics.newImage("Images/Faces/Hair_Spritesheet.png")
        local faceSpritesheet = love.graphics.newImage("Images/Faces/Face_Spritesheet.png")

		self.audienceSpriteData = 
		{
			head =
			{
				spritesheet = headSpritesheet,
				quads = DrawSystem:ExtractAllSpritesheetQuads(headSpritesheet, 32, 32),
			},
			hair =
			{
				spritesheet = hairSpritesheet,
				quads = DrawSystem:ExtractAllSpritesheetQuads(hairSpritesheet, 32, 32),
			},
			face =
			{
				spritesheet = faceSpritesheet,
				quads = DrawSystem:ExtractAllSpritesheetQuads(faceSpritesheet, 32, 32),
			},
		}

        self.audience = {}
    end,

    FixedUpdate = function(self, dt)
        for _, audienceMember in pairs(self.audience) do
           audienceMember:FixedUpdate(dt)
        end
    end,

    Draw = function(self)
        for _, audienceMember in pairs(self.audience) do
            audienceMember:Draw()
        end
    end,

	OnStart = function(self)
		self:GenerateAudience(10)
        for _, audienceMember in pairs(self.audience) do
            DrawSystem:AddDrawable(audienceMember.sprite)
        end
	end,

	OnStop = function(self)
        for _, audienceMember in pairs(self.audience) do
            DrawSystem:RemoveDrawable(audienceMember.sprite)
        end
		self.audience = {}
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================
    SetAudienceAwe = function(self, score)
        if not score then
            return
        end
        if score < 25 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceAngry()
            end
        elseif score < 50 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceNeutral()
            end
        elseif score < 75 then
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceHappy()
            end
        else
            for _, audienceMember in pairs(self.audience) do
                audienceMember:SetFaceAwe()
            end
        end
    end,

    HandleDamage = function(self, damage)
        print("damage=", damage)
        local remainingDamage = damage
        local damageDealt = 0
        for _, audienceMember in pairs(self.audience) do
            if remainingDamage == 0 then
                return
            end
            local currentHealth = audienceMember:GetHealth()
            print("currentHealth=", currentHealth)
            if currentHealth > 0 then
                if remainingDamage > currentHealth then
                    audienceMember:SetHealth(0)
                    damageDealt = currentHealth
                else
                    local newHealth = currentHealth - remainingDamage
                    audienceMember:SetHealth(newHealth)
                    damageDealt = remainingDamage
                    print("damageDealt=", damageDealt)
                end
                remainingDamage = remainingDamage - damageDealt
                print("remainingDamage=", remainingDamage)
            end
        end
    end,

	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================

	GenerateAudience = function(self, size)
		self.audience = {}
		for memberIndex = 1, size do
			self.audience[memberIndex] = self:GenerateRandomAudienceMember()
		end
	end,

	GenerateRandomAudienceMember = function(self)
		local sprite = Sprite:NewComplexSpriteFromSpritesheet(
			{
				self.audienceSpriteData.head.spritesheet,
				self.audienceSpriteData.hair.spritesheet,
				self.audienceSpriteData.face.spritesheet,
			},
			{
				self.audienceSpriteData.head.quads[love.math.random(table.count(self.audienceSpriteData.head.quads))],
				self.audienceSpriteData.hair.quads[love.math.random(table.count(self.audienceSpriteData.hair.quads))],
				self.audienceSpriteData.face.quads[GameConstants.AudienceFaceIndex.Neutral],
			},
			{ width = 32, height = 32 },
			{ x = 0, y = 0 },
			0,
			1,
			DrawLayers.Audience,
			false,
			{ x = 0, y = 0 }
		)

        return AudienceMember:New(sprite)
    end,

	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	GetTotalHealth = function(self)
        local total = 0
        for _, audienceMember in pairs(self.audience) do
            total = total + audienceMember:GetHealth()
        end
        return total
    end,
	-- ===========================================================================================================
	-- #endregion


}
return Audience