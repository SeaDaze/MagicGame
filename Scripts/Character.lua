local Common = require("Scripts.Common")
local Constants = require("Scripts.Constants")

local Character =
{
	New = function(self, gameInstance, keyboardUI)
		local instance = setmetatable({}, self)
        instance.characterSprite = love.graphics.newImage("Images/Characters/character_03.png")
        instance.movementSpeed = 60
        instance.position = { x = love.graphics.getWidth() / 2, y = 510 }
        instance.facingRight = true
        instance.nearbyAI = {}
        instance.keyboardUI = keyboardUI
        instance.gameInstance = gameInstance
		return instance
	end,

    Update = function(self, Flux, dt)
        if love.keyboard.isDown("a") then
            self.facingRight = false
        end

        if love.keyboard.isDown("d") then
            self.facingRight = true
        end

        if Common:TableCount(self.nearbyAI) > 0 and love.keyboard.isDown("space") then
            self.gameInstance:OnGameStateChanged(Constants.GameStates.Perform)
        end
    end,

    Draw = function(self)
        local scale = 4
        if not self.facingRight then
            scale = -4
        end
        love.graphics.draw(self.characterSprite, self.position.x, self.position.y, 0, scale, 4, self.characterSprite:getWidth() / 2)
    end,

    OnAIEnteredRange = function(self, aiReference)
        print("OnAIEnteredRange: near AI with id=", aiReference.id)
        -- if Common:TableCount(self.nearbyAI) == 0 then
        --     self.keyboardUI:AddKeyToUI("space", "Interact")
        -- end
        self.nearbyAI[aiReference.id] = aiReference
        print("OnAIEnteredRange: Common:TableCount(self.nearbyAI)=", Common:TableCount(self.nearbyAI))
    end,

    OnAIExitedRange = function(self, aiReference)
        print("OnAIExitedRange: no longer near AI with id=", aiReference.id)
        self.nearbyAI[aiReference.id] = nil
        -- if Common:TableCount(self.nearbyAI) == 0 then
        --     self.keyboardUI:RemoveKeyFromUI("space")
        -- end
        print("OnAIExitedRange: Common:TableCount(self.nearbyAI)=", Common:TableCount(self.nearbyAI))
    end,
}

Character.__index = Character
return Character