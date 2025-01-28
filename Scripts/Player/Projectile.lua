local EventIds = require "Scripts.System.EventIds"
local LocalTimer = require "Scripts.Timer"

local Projectile = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

	Load = function(self)
		self.projectileImage = DrawSystem:LoadImage("Images/Projectiles/Projectile_01.png")
	end,

	New = function(self, position, target, score)
		local instance = setmetatable({}, self)
		local scale = love.math.random() * (3 - 1) + 1
		instance.sprite = Sprite:New(
            self.projectileImage,
            position,
            0,
            scale,
            DrawLayers.Projectiles,
            true,
            { x = 0.5, y = 0.5 }
        )

		instance.baseSpeed = love.math.random(40, 60)
		instance.acceleration = 0
		instance.target = target
		instance.hitRadius = instance.sprite:GetWidth() * GameSettings.WindowResolutionScale
		instance.id = UniqueIds:GenerateNew()
		instance.score = score

		instance.timer = LocalTimer:New()
		instance.timerNotificationId = instance.timer:AddListener(instance, "Projectile_OnTimerFinished")
		local min, max = 0.1, 1
		local randomInRange = love.math.random() * (max - min) + min
		instance.timer:Start("Projectile", randomInRange)

		return instance
	end,

	FixedUpdate = function(self, dt)
		self:MoveTowardsTarget(dt)
		self:EvaluateTargetHit()
		self.timer:Update(dt)
	end,

	OnStop = function(self)
		self.sprite.scaleModifier = 0
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================

	Projectile_OnTimerFinished = function(self, timerId)
        if timerId == "Projectile" then
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

	GetImage = function(self)
		return self.projectileImage
	end,

	GetSprite = function(self)
		return self.sprite
	end,

	-- ===========================================================================================================
	-- #endregion
}
Projectile.__index = Projectile
return Projectile