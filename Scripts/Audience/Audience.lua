local Spectator = require("Scripts.Audience.Spectator")
local EventIds       = require("Scripts.System.EventIds")

local Audience = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================
	Load = function(self)
        local headSpritesheet = DrawSystem:LoadImage("Images/Faces/Head_Base_Spritesheet.png")
        local hairSpritesheet = DrawSystem:LoadImage("Images/Faces/Hair_Spritesheet.png")
        local faceSpritesheet = DrawSystem:LoadImage("Images/Faces/Face_Spritesheet.png")

		self.headSpriteBatch = Sprite:NewSpriteBatch(headSpritesheet, 500)
		self.hairSpriteBatch = Sprite:NewSpriteBatch(hairSpritesheet, 500)
		self.faceSpriteBatch = Sprite:NewSpriteBatch(faceSpritesheet, 500)

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
        for _, spectator in pairs(self.audience) do
			spectator:FixedUpdate(dt)

			local sprite = spectator.sprite
			self.headSpriteBatch.spriteBatch:set(
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
		   	self.hairSpriteBatch.spriteBatch:set(
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
		   	self.faceSpriteBatch.spriteBatch:set(
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
		self:GenerateAudience(5000)

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
			spectator.headSpriteBatchId = self.headSpriteBatch.spriteBatch:add(
				sprite.quadTable[1],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
			spectator.hairSpriteBatchId = self.hairSpriteBatch.spriteBatch:add(
				sprite.quadTable[2],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
			spectator.faceSpriteBatchId = self.faceSpriteBatch.spriteBatch:add(
				sprite.quadTable[3],
				sprite.position.x,
				sprite.position.y,
				math.rad(sprite.angle),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				GameSettings.WindowResolutionScale * sprite.scaleModifier * (1 + (sprite.position.z / 100)),
				sprite.width * sprite.originOffsetRatio.x,
				sprite.height * sprite.originOffsetRatio.y
			)
            --DrawSystem:AddDrawable(spectator.sprite)

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

		DrawSystem:AddDrawable(self.headSpriteBatch)
		DrawSystem:AddDrawable(self.hairSpriteBatch)
		DrawSystem:AddDrawable(self.faceSpriteBatch)
	end,

	OnStop = function(self)
        for _, spectator in pairs(self.audience) do
            DrawSystem:RemoveDrawable(spectator.sprite)
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
				self.audienceSpriteData.face.quads[GameConstants.AudienceFaceIndex.Neutral],
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