-- Game objects
local Audience = require("Scripts.Audience.Audience")
local Mat = require("Scripts.Mat")
local Text = require("Scripts.System.Text")
local EventIds = require("Scripts.System.EventIds")
local ParticleSystem = require("Scripts.System.ParticleSystem")
local SpectatorPanel = require("Scripts.UI.SpectatorPanel")

local PerformScene =
{
	-- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
		-- Create new objects
		Audience:Load()
		Mat:Load()
		SpectatorPanel:Load()

		self.backgroundVFX = 
		{
			ParticleSystem:New(
				love.graphics.newImage("Images/Cards/spade_01.png"),
				{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 },
				0
			),
			ParticleSystem:New(
				love.graphics.newImage("Images/Cards/heart_01.png"),
				{ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 },
				0
			),
		}

		self.blurEffect = Moonshine(Moonshine.effects.boxblur).chain(Moonshine.effects.pixelate)

		self.quotaText = Text:New(
            "Quota: 300",
            GameConstants.UI.Font,
            { x = 10, y = 170, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		self.scoreText = Text:New(
            "Score: 0",
            GameConstants.UI.Font,
            { x = 10, y = 200, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		self.tricksText = Text:New(
            "Tricks: 3",
            GameConstants.UI.Font,
            { x = 10, y = 230, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		self.tutorialText = Text:New(
            "",
            GameConstants.UI.Font,
            { x = 10, y = 260, z = 0 },
            0,
            DrawLayers.HUD,
            "left"
        )
		self.tutorialText:SetLimit(60 * GameSettings.WindowResolutionScale)
    end,

	OnStart = function(self)
		Audience:OnStart()
		Player:OnStartPerform(Audience:GetAllMembers())
		Mat:OnStartPerform()
		SpectatorPanel:OnStartPerform()
		DrawSystem:AddDrawable(self.quotaText)
		DrawSystem:AddDrawable(self.scoreText)
		DrawSystem:AddDrawable(self.tricksText)
		DrawSystem:AddDrawable(self.tutorialText)
		for _, vfx in pairs(self.backgroundVFX) do
			DrawSystem:AddDrawable(vfx)
		end
		self.scoreNotificationId = EventSystem:ConnectToEvent(EventIds.AudienceMemberScoreUpdated, self, "OnAudienceMemberScoreUpdated")
	end,

	OnStop = function(self)
		Player:OnStopPerform()
		Mat:OnStopPerform()
		SpectatorPanel:OnStopPerform()
		DrawSystem:RemoveDrawable(self.quotaText)
		DrawSystem:RemoveDrawable(self.scoreText)
		DrawSystem:RemoveDrawable(self.tricksText)
		DrawSystem:RemoveDrawable(self.tutorialText)
		for _, vfx in pairs(self.backgroundVFX) do
			DrawSystem:RemoveDrawable(vfx)
		end
		EventSystem:DisconnectFromEvent(self.scoreNotificationId)
		Audience:OnStop()
		self.scoreNotificationId = nil
	end,

    Update = function(self, dt)
		Player:Update(dt)
    end,

	FixedUpdate = function(self, dt)
		Player:FixedUpdate(dt)
		Audience:FixedUpdate(dt)
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

	OnAudienceMemberScoreUpdated = function(self, score)
		local score = 0
		for _, member in pairs(Audience:GetAllMembers()) do
			score = score + member:GetScore()
		end

		self.scoreText:SetText("Score: " .. tostring(math.floor(score)))
	end,
}
return PerformScene