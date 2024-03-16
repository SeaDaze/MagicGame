local Deck = {
	New = function(self)
		local instance = setmetatable({}, self)
		instance.cards = {}
		return instance
	end,

	DoubleLift = function(self)
		-- We swap the cards here because the second top card goes to the top when they are both flipped over together
		self:Swap(51, 52)
		self.cards[51]:SetFacingUp(true)
		self.cards[52]:SetFacingUp(true)
	end,

	Swap = function(self, a, b)
		if a < 1 or a > 52 then
			return
		end
		if b < 1 or b > 52 then
			return
		end
		if a == b then
			return
		end
		local temp = self.cards[a]
		self.cards[a] = self.cards[b]
		self.cards[b] = temp
	end,

	Fan = function(self)
		local angleIncrement = 8
		local angle = 0
		for index, card in ipairs(self.cards) do
			card.offset = { x = 0, y = card.halfHeight}
			card.angle = angle
			if angle < 180 then
				angle = angle + angleIncrement
			end
		end
	end,

	Unfan = function(self)
		for index, card in ipairs(self.cards) do
			card.offset = { x = 0, y = 0}
			card.angle = 0
		end
	end,

	OffsetCard = function(self, cardIndex)
		self.cards[cardIndex].offset = { x = 0, y = self.cards[cardIndex].halfHeight }
	end,
}

Deck.__index = Deck
return Deck