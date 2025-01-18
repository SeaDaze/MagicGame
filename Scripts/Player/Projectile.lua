local EventIds = require "Scripts.System.EventIds"

local Projectile = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

	New = function(self, sprite, target, score)
		local instance = setmetatable({}, self)
		instance.sprite = sprite
		instance.baseSpeed = 50
		instance.acceleration = 0
		instance.target = target
		instance.hitRadius = instance.sprite:GetWidth() * GameSettings.WindowResolutionScale
		instance.timerNotificationId = Timer:AddListener(instance, "OnTimerFinished")
		instance.id = UniqueIds:GenerateNew()
		instance.score = score
		Timer:Start("Projectile" .. instance.id, 1)
		return instance
	end,

	Update = function(self, dt)
		self:MoveTowardsTarget(dt)
		self:EvaluateTargetHit()
	end,

	OnStop = function(self)
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