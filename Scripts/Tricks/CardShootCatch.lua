local Technique = require("Scripts.Techniques.Technique")

local CardShootCatch = {
    New = function(self, deck, input)
        local instance = setmetatable({}, self)

        instance.deck = deck
        instance.input = input
        instance.name = "card shoot"
        return instance
    end,

    OnStart = function(self)
        self.input:AddKeyListener("f", self.deck, "StartSpin")
		self.input:AddMouseListener(1, self.deck, "CatchCard")
		self.catchCardNotificationId = self.deck:AddListener("CatchCard", self, "OnCatchCard")
		self.dropCardNotificationId = self.deck:AddListener("OnCardDropped", self, "OnCardDropped")
    end,

    OnStop = function(self)
		self.input:RemoveKeyListener("f")
		self.input:RemoveMouseListener(1)
		self.deck:RemoveListener("CatchCard", self.catchCardNotificationId)
		self.deck:RemoveListener("OnCardDropped", self.dropCardNotificationId)
		self.deck:ResetSpinCard()
    end,

	OnCatchCard = function(self)
		print("OnCatchCard:")
		--self:SendToFinishListener()
	end,
	
	OnCardDropped = function(self)
		print("OnCardDropped:")
		--self:SendToFinishListener()
	end,
}

CardShootCatch.__index = CardShootCatch
setmetatable(CardShootCatch, Technique)
return CardShootCatch