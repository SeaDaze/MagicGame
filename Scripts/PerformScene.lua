-- Game objects
local Audience = require("Scripts.Audience.Audience")
local Mat = require("Scripts.Mat")
local Text = require("Scripts.System.Text")
local EventIds = require("Scripts.System.EventIds")

local PerformScene =
{
	-- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
		-- Create new objects
		self.audience = Audience:New()
		Mat:Load()

		self.backgroundVFX = 
		{
			self:CreateBackgroundVFX(love.graphics.newImage("Images/Cards/heart_01.png")),
			self:CreateBackgroundVFX(love.graphics.newImage("Images/Cards/spade_01.png")),
		}

		self.blurEffect = Moonshine(Moonshine.effects.boxblur).chain(Moonshine.effects.pixelate)

		self.scoreText = Text:New(
            "0",
            GameConstants.UI.Font,
            { x = 0, y = 120, z = 0 },
            0,
            DrawLayers.HUD,
            "center"
        )
    end,

	OnStart = function(self)
		Player:OnStartPerform()
		Mat:OnStartPerform()
		DrawSystem:AddDrawable(self.scoreText)

		self.scoreNotificationId = EventSystem:ConnectToEvent(EventIds.TechniqueEvaluated, self, "OnTechniqueEvaluated")
	end,

	OnStop = function(self)
		Player:OnStopPerform()
		Mat:OnStopPerform()
		DrawSystem:RemoveDrawable(self.scoreText)
		EventSystem:DisconnectFromEvent(self.scoreNotificationId)
		self.scoreNotificationId = nil
	end,

    Update = function(self, dt)
		Player:Update(dt)
		for _, vfx in pairs(self.backgroundVFX) do
			vfx:update(dt)
		end
    end,

	FixedUpdate = function(self, dt)
		Player:FixedUpdate(dt)
		self.audience:FixedUpdate(dt)
	end,

    Draw = function(self)
		self.blurEffect(
			function()
				for _, vfx in pairs(self.backgroundVFX) do
					love.graphics.draw(vfx)
				end
			end
		)

		self.audience:Draw()

		love.graphics.printf("Perform", GameConstants.UI.Font, 0, 0, love.graphics.getWidth(), "center")
		love.graphics.printf(self.audience:GetTotalHealth(), GameConstants.UI.Font, 0, 180, love.graphics.getWidth(), "center")
    end,

	LateDraw = function(self)
		Player:LateDraw()
		HUD:Draw()
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
	CreateBackgroundVFX = function(self, image)
		local psystem = love.graphics.newParticleSystem(image, 1000)
		psystem:setParticleLifetime(10, 10) -- Particles live at least 2s and at most 5s.
		psystem:setEmissionRate(10)
		psystem:setLinearAcceleration(-100, -100, 100, 100) -- Random movement in all directions.
		psystem:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
		psystem:setSizes(0, GameSettings.WindowResolutionScale)
		psystem:moveTo(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
		return psystem
	end,

	OnTechniqueEvaluated = function(self, techniqueName, score)
		self.scoreText:SetText(tostring(math.floor(score)))
	end,
}
return PerformScene