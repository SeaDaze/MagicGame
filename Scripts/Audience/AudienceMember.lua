
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
            y = love.math.random(80),
        })

        local randomDirection = love.math.random(2)
        instance.direction = randomDirection == 1 and Constants.Left or Constants.Right

        instance.maxHealth = 30
        instance.health = instance.maxHealth

        return instance
    end,

    FixedUpdate = function(self, dt)
        if self.health == 0 then
            return
        end
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
    end,

    GetMaxHealth = function(self)
        return self.maxHealth
    end,

    GetHealth = function(self)
        return self.health
    end,

    SetHealth = function(self, health)
        self.health = health
    end,
}

AudienceMember.__index = AudienceMember

return AudienceMember