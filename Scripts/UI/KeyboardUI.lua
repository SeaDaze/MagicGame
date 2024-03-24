

local KeyboardUI =
{
    Load = function(self, gameInstance)
		self.keys = {}
		self.font = love.graphics.newFont("Fonts/pixelFont.ttf",24)
		self.scale = 2
		self.keys["f"] = {
			image = love.graphics.newImage("Images/Keyboard/key_f.png"),
			position = { x = love.graphics.getWidth() - 200 , y = 200 },
			text = "",
		}
    end,

    Update = function(self, Flux, dt)
    end,

    Draw = function(self)
		for keyName, keyData in pairs(self.keys) do
			love.graphics.draw(keyData.image, keyData.position.x, keyData.position.y, 0, self.scale, self.scale)
			love.graphics.printf(keyData.text, self.font, keyData.position.x + (keyData.image:getWidth() * self.scale) + 10, keyData.position.y + 5, 500, "left")
		end
    end,

	SetKeyText = function(self, keyName, text)
		self.keys[keyName].text = text
	end,

	AddKeyToUI = function(self, keyName, text)

	end,
}
return KeyboardUI