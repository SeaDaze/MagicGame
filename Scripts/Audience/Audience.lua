local AudienceMember = require("Scripts.Audience.AudienceMember")
local EventIds       = require("Scripts.System.EventIds")

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
		self.hoveredMembers = {}
    end,

    FixedUpdate = function(self, dt)
        for _, audienceMember in pairs(self.audience) do
           audienceMember:FixedUpdate(dt)
        end
    end,

	OnStart = function(self)
		self:GenerateAudience(3)
        for _, audienceMember in pairs(self.audience) do
            DrawSystem:AddDrawable(audienceMember.sprite)
			local collider = audienceMember:GetCollider()
			collider:BoxCollider_OnStart()
			local playerRelaxedFingerPosition = Player:GetRightHand():GetRelaxedFingerPosition()
			collider:BoxCollider_AddPointCollisionListener(playerRelaxedFingerPosition,
            function(colliderA)
				self:OnStartHoveringAudienceMember(colliderA:BoxCollider_GetOwner())
            end,

            function(colliderA)
				self:OnStopHoveringAudienceMember(colliderA:BoxCollider_GetOwner())
            end
        )
        end
	end,

	OnStop = function(self)
        for _, audienceMember in pairs(self.audience) do
            DrawSystem:RemoveDrawable(audienceMember.sprite)
			local collider = audienceMember:GetCollider()
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
			{ x = 0.5, y = 0.5 }
		)

        return AudienceMember:New(sprite)
    end,

	OnStartHoveringAudienceMember = function(self, audienceMember)
		Log.Med("OnStartHoveringAudienceMember: ")

		if table.isEmpty(self.hoveredMembers) then
			EventSystem:BroadcastEvent(EventIds.ShowSpectatorPanel)
		end
		
		table.insert(self.hoveredMembers, audienceMember)
	end,

	OnStopHoveringAudienceMember = function(self, audienceMember)
		Log.Med("OnStopHoveringAudienceMember: ")
		table.removeByValue(self.hoveredMembers, audienceMember)

		if table.isEmpty(self.hoveredMembers) then
			EventSystem:BroadcastEvent(EventIds.HideSpectatorPanel)
		end
	end,

	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	GetAllMembers = function(self)
		return self.audience
	end,

	-- ===========================================================================================================
	-- #endregion


}
return Audience