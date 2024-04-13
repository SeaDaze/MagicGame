local Technique = require("Scripts.Techniques.Technique")

local CardShootCatch = {
    New = function(self, deck, leftHand, rightHand, input)
        local instance = setmetatable({}, self)

        instance.deck = deck
        instance.input = input
        instance.name = "card shoot"
        return instance
    end,

    OnStart = function(self)
        self.input:AddKeyListener("f", self.deck, "StartSpin")
		self.input:AddMouseListener(1, self.deck, "CatchCard")
    end,

    OnStop = function(self)
    end,
}

CardShootCatch.__index = CardShootCatch
setmetatable(CardShootCatch, Technique)
return CardShootCatch