local Background =
{
	New = function(self)
		local instance = setmetatable({}, self)
        instance.background = love.graphics.newImage("Images/Buildings/Background_01.png")
        instance.building1 = love.graphics.newImage("Images/Buildings/Buildings_01.png")
        instance.building2 = love.graphics.newImage("Images/Buildings/Buildings_02.png")
        instance.building3 = love.graphics.newImage("Images/Buildings/Buildings_03.png")
        instance.building4 = love.graphics.newImage("Images/Buildings/Buildings_04.png")
        instance.movementSpeed = 10
        instance.bg1Position = { x = 0, y = 0 }
        instance.bg2Position = { x = 0, y = 0 }
        instance.bg3Position = { x = 0, y = 0 }
        instance.bg4Position = { x = 0, y = 0 }
		return instance
	end,

    Update = function(self, Flux, dt)
        if love.keyboard.isDown("a") then
            local movementDelta = self.movementSpeed * dt
            self.bg4Position.x = self.bg4Position.x + movementDelta
            self.bg3Position.x = self.bg3Position.x + (movementDelta * 2)
            self.bg2Position.x = self.bg2Position.x + (movementDelta * 4)
            self.bg1Position.x = self.bg1Position.x + (movementDelta * 6)
        end

        if love.keyboard.isDown("d") then
            local movementDelta = self.movementSpeed * dt
            self.bg4Position.x = self.bg4Position.x - movementDelta
            self.bg3Position.x = self.bg3Position.x - (movementDelta * 2)
            self.bg2Position.x = self.bg2Position.x - (movementDelta * 4)
            self.bg1Position.x = self.bg1Position.x - (movementDelta * 6)
        end
    end,

    Draw = function(self)
        love.graphics.draw(self.background, 0, 0, 0, 4, 4)
        love.graphics.draw(self.building4, self.bg4Position.x, self.bg4Position.y, 0, 4, 4)
        love.graphics.draw(self.building4, self.bg4Position.x - self.building4:getWidth() * 4, self.bg4Position.y, 0, 4, 4)
        love.graphics.draw(self.building4, self.bg4Position.x + self.building4:getWidth() * 4, self.bg4Position.y, 0, 4, 4)

        love.graphics.draw(self.building3, self.bg3Position.x, self.bg3Position.y, 0, 4, 4)
        love.graphics.draw(self.building3, self.bg3Position.x - self.building3:getWidth() * 4, self.bg4Position.y, 0, 4, 4)
        love.graphics.draw(self.building3, self.bg3Position.x + self.building3:getWidth() * 4, self.bg4Position.y, 0, 4, 4)

        love.graphics.draw(self.building2, self.bg2Position.x, self.bg2Position.y, 0, 4, 4)
        love.graphics.draw(self.building2, self.bg2Position.x - self.building2:getWidth() * 4, self.bg4Position.y, 0, 4, 4)
        love.graphics.draw(self.building2, self.bg2Position.x + self.building2:getWidth() * 4, self.bg4Position.y, 0, 4, 4)

        love.graphics.draw(self.building1, self.bg1Position.x, self.bg1Position.y, 0, 4, 4)
        love.graphics.draw(self.building1, self.bg1Position.x - self.building1:getWidth() * 4, self.bg4Position.y, 0, 4, 4)
        love.graphics.draw(self.building1, self.bg1Position.x + self.building1:getWidth() * 4, self.bg4Position.y, 0, 4, 4)
        
    end,
}

Background.__index = Background
return Background