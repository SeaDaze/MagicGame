local Common = require("Scripts.Common")

local ErdnaseChange = {
	New = function(self, leftHand, rightHand, deck)
		local instance = setmetatable({}, self)
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.deck = deck
		return instance
	end,

	Start = function(self)
		--self.deck:Fan()
		--self.deck:Shuffle()
		--self.deck:DoubleLift()
		--self.deck:OffsetCard(5)
	end,

    Update = function(self, Flux, dt)
		self:HandleChange()
    end,

	HandleChange = function(self)
		local positionX = self.rightHand.position.x
        local positionY = self.rightHand.position.y
        local distanceSquared = Common:DistanceSquared(positionX, positionY, self.deck.cards[51].position.x, self.deck.cards[51].position.y)
        if not self.changed and distanceSquared < 50 then
			self.deck:Swap(51, 52)
            self.changed = true
			print("HandleChange: successfully changed")
        end
	end,
}

ErdnaseChange.__index = ErdnaseChange
return ErdnaseChange