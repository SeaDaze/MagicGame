local Common = require("Scripts.Common")

local KeyboardUI =
{
    Load = function(self, gameInstance)
		self.keys = {}
		self.visibleKeys = {}

		self.font = love.graphics.newFont("Fonts/pixelFont.ttf",24)
		self.scale = 2
		self.topPosition = 200

		self.keys["f"] = {
			image = love.graphics.newImage("Images/Keyboard/key_f.png"),
			position = { x = love.graphics.getWidth() - 220 , y = self.topPosition },
			text = "",
		}
		self.keys["w"] = {
			image = love.graphics.newImage("Images/Keyboard/key_w.png"),
			position = { x = love.graphics.getWidth() - 220 , y = 200 },
			text = "",
		}
		self.keys["a"] = {
			image = love.graphics.newImage("Images/Keyboard/key_a.png"),
			position = { x = love.graphics.getWidth() - 220 , y = 200 },
			text = "",
		}
		self.keys["s"] = {
			image = love.graphics.newImage("Images/Keyboard/key_s.png"),
			position = { x = love.graphics.getWidth() - 220 , y = 200 },
			text = "",
		}
		self.keys["d"] = {
			image = love.graphics.newImage("Images/Keyboard/key_d.png"),
			position = { x = love.graphics.getWidth() - 220 , y = 200 },
			text = "",
		}
		self.keys["space"] = {
			image = love.graphics.newImage("Images/Keyboard/key_spacebar.png"),
			position = { x = love.graphics.getWidth() - 220 , y = 200 },
			text = "",
		}
		
		self.interval = 30
    end,

    Update = function(self, Flux, dt)
    end,

    Draw = function(self)
		local offsetIndex = 0
		for keyName, keyData in pairs(self.visibleKeys) do
			love.graphics.draw(keyData.image, keyData.position.x, keyData.position.y + (offsetIndex * self.interval), 0, self.scale, self.scale)
			love.graphics.printf(keyData.text, self.font, keyData.position.x + (keyData.image:getWidth() * self.scale) + 10, keyData.position.y + (offsetIndex * self.interval) + 5, 500, "left")
			offsetIndex = offsetIndex + 1
		end
    end,

	AddKeyToUI = function(self, keyName, text)
		if not keyName or not self.keys[keyName] then
			return
		end
		self.visibleKeys[keyName] = self.keys[keyName]
		self.visibleKeys[keyName].text = text
	end,
	
	RemoveKeyFromUI = function(self, keyName)
		if not keyName or not self.keys[keyName] then
			return
		end
		self.visibleKeys[keyName] = nil
	end,
}
return KeyboardUI