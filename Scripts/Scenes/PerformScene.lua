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

		self.quota = 300
		self.quotaText = Text:New(
            "Quota: ".. tostring(0),
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
		Player:OnStartPerform(Audience:GetAllSpectators())
		Mat:OnStartPerform()
		DrawSystem:AddDrawable(self.quotaText)
		DrawSystem:AddDrawable(self.scoreText)
		DrawSystem:AddDrawable(self.tricksText)
		DrawSystem:AddDrawable(self.tutorialText)
		self.scoreNotificationId = EventSystem:ConnectToEvent(EventIds.SpectatorScoreUpdated, self, "OnSpectatorScoreUpdated")
		self.quota = Player:EvaluateQuota()
		self.quotaText:SetText("Quota: ".. tostring(self.quota))
		self.quotaReached = false
	end,

	OnStop = function(self)
		Player:OnStopPerform()
		Mat:OnStopPerform()
		DrawSystem:RemoveDrawable(self.quotaText)
		DrawSystem:RemoveDrawable(self.scoreText)
		DrawSystem:RemoveDrawable(self.tricksText)
		DrawSystem:RemoveDrawable(self.tutorialText)
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

	OnSpectatorScoreUpdated = function(self, spectatorScore)
		local score = 0
		for _, spectator in pairs(Audience:GetAllSpectators()) do
			score = score + spectator:GetScore()
		end

		self.scoreText:SetText("Score: " .. tostring(math.floor(score)))
		if self.quotaReached then
			return
		end
		if score > self.quota then
			EventSystem:BroadcastEvent(EventIds.OnQuotaReached)
			self.quotaReached = true
		end
	end,
}
return PerformScene