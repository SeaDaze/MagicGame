local Character =
{
	New = function(self)
		local instance = setmetatable({}, self)
        print("New Character")
        instance.characterSprite = love.graphics.newImage("Images/Characters/character_02.png")
        instance.movementSpeed = 40
        instance.position = { x = 600, y = 550 }
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