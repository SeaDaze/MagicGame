local Character =
{
	New = function(self)
		local instance = setmetatable({}, self)
        instance.characterSprite = love.graphics.newImage("Images/Characters/character_03.png")
        instance.movementSpeed = 60
        instance.position = { x = 600, y = 510 }
        instance.facingRight = true
		return instance
	end,

    Update = function(self, Flux, dt)
        if love.keyboard.isDown("a") then
            -- local movementDelta = self.movementSpeed * dt
            -- self.position.x = self.position.x - movementDelta
            self.facingRight = false
        end

        if love.keyboard.isDown("d") then
            -- local movementDelta = self.movementSpeed * dt
            -- self.position.x = self.position.x + movementDelta
            self.facingRight = true
        end
    end,

    Draw = function(self)
        local scale = 4
        if not self.facingRight then
            scale = -4
        end
        love.graphics.draw(self.characterSprite, self.position.x, self.position.y, 0, scale, 4, self.characterSprite:getWidth() / 2)
    end,
}

Character.__index = Character
return Character