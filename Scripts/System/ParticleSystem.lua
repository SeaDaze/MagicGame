
local ParticleSystem = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

	New = function(self, image, position, layerIndex)
		local instance = setmetatable({}, self)
		instance.particleSystem = love.graphics.newParticleSystem(image, 1000)
		instance.particleSystem:setParticleLifetime(10, 10) -- Particles live at least 2s and at most 5s.
		instance.particleSystem:setEmissionRate(10)
		instance.particleSystem:setLinearAcceleration(-100, -100, 100, 100) -- Random movement in all directions.
		instance.particleSystem:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
		instance.particleSystem:setSizes(0, GameSettings.WindowResolutionScale)
		instance.particleSystem:moveTo(position.x, position.y)
		instance.layerIndex = layerIndex or 0
		instance.requiresUpdate = true
		instance.type = GameConstants.DrawableTypes.ParticleSystem
		instance.visible = true
		instance.blur = true
		return instance
	end,

	Update = function(self, dt)
		self.particleSystem:update(dt)
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #endregion
}
ParticleSystem.__index = ParticleSystem
return ParticleSystem