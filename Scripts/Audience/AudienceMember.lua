local EventIds = require "Scripts.System.EventIds"
local BoxCollider = require("Scripts.Physics.BoxCollider")

local Constants = 
{
    Left = -1,
    Right = 1,
}
local AudienceMember = 
{
    New = function(self, sprite)
        local instance = setmetatable({}, self)

		instance.sprite = sprite
        instance.speed = love.math.random(10, 30)
        instance.lower = 32
        instance.upper = love.graphics.getWidth() - (32 * 4)
        instance.sprite:SetPosition({
            x = love.math.random(instance.lower, instance.upper),
            y = love.math.random(80) + 40,
        })

        local randomDirection = love.math.random(2)
        instance.direction = randomDirection == 1 and Constants.Left or Constants.Right
		instance.score = 0

		instance.collider = BoxCollider:BoxCollider_New(
            instance,
            instance.sprite.position,
            instance.sprite.width,
            instance.sprite.height,
            instance.sprite.originOffsetRatio
        )

        return instance
    end,

    FixedUpdate = function(self, dt)
		local position = self.sprite:GetPosition()
        if position.x <= self.lower then
            self.direction = Constants.Right
        elseif position.x >= self.upper then
            self.direction = Constants.Left
        end

		self.sprite:SetPosition({
            x = position.x + (dt * self.speed * self.direction),
            y = position.y,
        })

		self.collider:BoxCollider_Update(dt)
    end,

	GetPosition = function(self)
		return self.sprite.position
	end,

	AddScore = function(self, score)
		self.score = self.score + score
		EventSystem:BroadcastEvent(EventIds.AudienceMemberScoreUpdated, self.score)
	end,

	GetScore = function(self)
		return self.score
	end,

	GetCollider = function(self)
		return self.collider
	end,
}

AudienceMember.__index = AudienceMember

return AudienceMember