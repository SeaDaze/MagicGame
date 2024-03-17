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
		--self.deck:DoubleLift()
		--self.deck:OffsetCard(5)
	end,

    Update = function(self, Flux, dt)
		self.rightHand:FollowMouse(Flux)
		self.leftHand:HandleMovement(Flux, dt)
		for _, card in ipairs(self.deck.cards) do
			if not card.given then
				card:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
			end
		end
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

    Draw = function(self)
		self.leftHand:Draw()
		for _, card in ipairs(self.deck.cards) do
			card:Draw()
		end
		self.rightHand:Draw()
    end,
}

ErdnaseChange.__index = ErdnaseChange
return ErdnaseChange