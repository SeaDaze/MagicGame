-- Game objects
local Audience = require("Scripts.Audience.Audience")
local Mat = require("Scripts.Mat")

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
    end,

	OnStart = function(self)
		Player:OnStartPerform()
		self.techniqueEvaluatedListenerId = Player:AddActionListener("OnTechniqueEvaluated",
			function(score)
				if not score then
					return
				end
				HUD:SetScoreText(math.floor(score))
				self.audience:SetAudienceAwe(score)
				self.audience:HandleDamage(math.floor(score))
			end
		)
	end,

	OnStop = function(self)
		Player:OnStopPerform()
		Player:RemoveActionListener(self.techniqueEvaluatedListenerId)
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

		love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)

		Mat:Draw()
		self.audience:Draw()
		Player:Draw()

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
}
return PerformScene