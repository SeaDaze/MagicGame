local EventIds = require "Scripts.System.EventIds"

local Projectile = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

	Load = function(self)
		self.projectileImage = DrawSystem:LoadImage("Images/Projectiles/Projectile_01.png")
	end,

	New = function(self, position, target, score)
		love.graphics.setDefaultFilter("nearest", "nearest")
		local instance = setmetatable({}, self)
		local scale = math.random(1, 3)

		instance.sprite = Sprite:New(
            self.projectileImage,
            position,
            0,
            scale,
            DrawLayers.Projectiles,
            true,
            { x = 0.5, y = 0.5 }
        )

		instance.baseSpeed = 50
		instance.acceleration = 0
		instance.target = target
		instance.hitRadius = instance.sprite:GetWidth() * GameSettings.WindowResolutionScale
		instance.timerNotificationId = Timer:AddListener(instance, "OnTimerFinished")
		instance.id = UniqueIds:GenerateNew()
		instance.score = score
		Timer:Start("Projectile" .. instance.id, 1)
		DrawSystem:AddDrawable(instance.sprite)
		return instance
	end,

	Update = function(self, dt)
		self:MoveTowardsTarget(dt)
		self:EvaluateTargetHit()
	end,

	OnStop = function(self)
		DrawSystem:RemoveDrawable(self.sprite)
		Timer:RemoveListener(self.timerNotificationId)
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================

	OnTimerFinished = function(self, timerId)
        if timerId == "Projectile" .. self.id then
			self.acceleration = 10
        end
	end,

	MoveTowardsTarget = function(self, dt)
		local targetPosition = self.target:GetPosition()
		local currentPosition = self.sprite:GetPosition()

		local directionVector = {
			x = targetPosition.x - currentPosition.x,
			y = targetPosition.y - currentPosition.y,
		}
		directionVector = Common:Normalize(directionVector)

		local newPosition = {
			x = currentPosition.x + (directionVector.x * self.baseSpeed * dt),
			y = currentPosition.y + (directionVector.y * self.baseSpeed * dt),
		}

		self.sprite:SetPosition(newPosition)
		self.baseSpeed = self.baseSpeed + self.acceleration
	end,

	EvaluateTargetHit = function(self)
		local targetPosition = self.target:GetPosition()
		local currentPosition = self.sprite:GetPosition()
		if Common:DistanceSquared(targetPosition.x, targetPosition.y, currentPosition.x, currentPosition.y) < (self.hitRadius * self.hitRadius) then
			EventSystem:BroadcastEvent(EventIds.ProjectileHit, self, self.target, self.score)
		end
	end,

	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #endregion
}
Projectile.__index = Projectile
return Projectile