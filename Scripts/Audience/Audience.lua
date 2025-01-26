local Spectator = require("Scripts.Audience.Spectator")
local EventIds = require("Scripts.System.EventIds")

local Audience = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================
	Load = function(self)
		self.audienceNumber = 10000

		local characterSpritesheet = DrawSystem:LoadImage("Images/Faces/Character_Spritesheet.png")
		self.characterSpriteBatch = Sprite:NewSpriteBatch(characterSpritesheet, self.audienceNumber, DrawLayers.Audience)

		self.audienceSpriteData =
		{
			head =
			{
				spritesheet = characterSpritesheet,
				quads = DrawSystem:ExtractSpritesheetQuadByRow(characterSpritesheet, 32, 32, 1, 2),
			},
			hair =
			{
				spritesheet = characterSpritesheet,
				quads = DrawSystem:ExtractSpritesheetQuadByRow(characterSpritesheet, 32, 32, 3, 7),
			},
			face =
			{
				spritesheet = characterSpritesheet,
				quads = DrawSystem:ExtractSpritesheetQuadByRow(characterSpritesheet, 32, 32, 2, 7),
			},
		}

        self.audience = {}
    end,

    FixedUpdate = function(self, dt)
        for _, spectator in pairs(self.audience) do
			spectator:FixedUpdate(dt)

			local sprite = spectator.sprite
			self.characterSpriteBatch.spriteBatch:set(
				spectator.headSpriteBatchId,
				sprite.quadTable[1],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
		   	self.characterSpriteBatch.spriteBatch:set(
				spectator.hairSpriteBatchId,
			   	sprite.quadTable[2],
			   	sprite.position.x,
			   	sprite.position.y,
			   	math.rad(sprite.angle),
			   	GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
			   	GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
			   	sprite.width * sprite.originOffsetRatio.x,
			   	sprite.height * sprite.originOffsetRatio.y
		   	)
		   	self.characterSpriteBatch.spriteBatch:set(
				spectator.faceSpriteBatchId,
			   	sprite.quadTable[3],
			   	sprite.position.x,
			   	sprite.position.y,
			   	math.rad(sprite.angle),
			   	GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
			   	GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
			   	sprite.width * sprite.originOffsetRatio.x,
			   	sprite.height * sprite.originOffsetRatio.y
		   	)
        end
    end,

	OnStart = function(self)
		self:GenerateAudience(self.audienceNumber)

		DrawSystem:AddDebugDraw(
            function ()
				local indexFingerPosition = Player:GetRightHand():GetRelaxedFingerPosition()
				love.graphics.ellipse(
					"fill",
					indexFingerPosition.x,
					indexFingerPosition.y,
					3,
					3,
					6
				)
			end
		)

        for _, spectator in pairs(self.audience) do
			local sprite = spectator.sprite
			spectator.headSpriteBatchId = self.characterSpriteBatch.spriteBatch:add(
				sprite.quadTable[1],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
			spectator.hairSpriteBatchId = self.characterSpriteBatch.spriteBatch:add(
				sprite.quadTable[2],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
			spectator.faceSpriteBatchId = self.characterSpriteBatch.spriteBatch:add(
				sprite.quadTable[3],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)

			local collider = spectator:GetCollider()
			collider:BoxCollider_OnStart()
			local playerRelaxedFingerPosition = Player:GetRightHand():GetRelaxedFingerPosition()
			collider:BoxCollider_AddPointCollisionListener(playerRelaxedFingerPosition,
				function(colliderA)
					EventSystem:BroadcastEvent(EventIds.OnStartHoverSpectator, colliderA:BoxCollider_GetOwner())
				end,
				function(colliderA)
					EventSystem:BroadcastEvent(EventIds.OnStopHoverSpectator, colliderA:BoxCollider_GetOwner())
				end
			)
        end

		DrawSystem:AddDrawable(self.characterSpriteBatch)
	end,

	OnStop = function(self)
		DrawSystem:RemoveDrawable(self.characterSpriteBatch)
		self.characterSpriteBatch.spriteBatch:clear()

        for _, spectator in pairs(self.audience) do
			local collider = spectator:GetCollider()
			collider:BoxCollider_OnStop()
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
            for _, spectator in pairs(self.audience) do
                spectator:SetFaceAngry()
            end
        elseif score < 50 then
            for _, spectator in pairs(self.audience) do
                spectator:SetFaceNeutral()
            end
        elseif score < 75 then
            for _, spectator in pairs(self.audience) do
                spectator:SetFaceHappy()
            end
        else
            for _, spectator in pairs(self.audience) do
                spectator:SetFaceAwe()
            end
        end
    end,

	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================

	GenerateAudience = function(self, size)
		self.audience = {}
		for spectatorIndex = 1, size do
			self.audience[spectatorIndex] = self:GenerateRandomSpectator()
		end
	end,

	GenerateRandomSpectator = function(self)
		local sprite = Sprite:NewComplexSpriteFromSpritesheet(
			{
				self.audienceSpriteData.head.spritesheet,
				self.audienceSpriteData.hair.spritesheet,
				self.audienceSpriteData.face.spritesheet,
			},
			{
				self.audienceSpriteData.head.quads[love.math.random(table.count(self.audienceSpriteData.head.quads))],
				self.audienceSpriteData.hair.quads[love.math.random(table.count(self.audienceSpriteData.hair.quads))],
				self.audienceSpriteData.face.quads[GameConstants.AudienceFaceIndex.Suspicious],
			},
			{ width = 32, height = 32 },
			{ x = 0, y = 0 },
			0,
			1,
			DrawLayers.Audience,
			false,
			{ x = 0.5, y = 0.5 }
		)

        return Spectator:New(sprite)
    end,

	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	GetAllSpectators = function(self)
		return self.audience
	end,

	-- ===========================================================================================================
	-- #endregion


}
return Audience