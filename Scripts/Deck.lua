local Deck = {
	New = function(self)
		local instance = setmetatable({}, self)
		instance.cards = {}
		instance.fannedCards = 0
		instance.offsetCardIndex = nil
		return instance
	end,

	Update = function(self, Flux, dt)
		for index, card in ipairs(self.cards) do
			if card.angle ~= card.targetAngle then
				Flux.to(card, 0.3, { angle = card.targetAngle })
			end
			if card.offset ~= card.targetOffset then
				Flux.to(card.offset, 0.3, { x = card.targetOffset.x, y = card.targetOffset.y })
			end
			if card.given then
				Flux.to(card.position, 0.3, { x = card.targetPosition.x, y = card.targetPosition.y } )
			end
		end
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
		self.fannedCards = 0
		for index, card in ipairs(self.cards) do
			card.targetOffset = { x = 0, y = card.halfHeight }
			card.previousOffset = { x = 0, y = card.halfHeight }
			card.targetAngle = angle
			if angle < 180 then
				angle = angle + angleIncrement
				self.fannedCards = self.fannedCards + 1
			end
		end
	end,

	Unfan = function(self)
		for index, card in ipairs(self.cards) do
			card.targetOffset = { x = 0, y = 0 }
			card.previousOffset = { x = 0, y = 0 }
			card.targetAngle = 0
		end
		self.fannedCards = 0
	end,

	OffsetCard = function(self, cardIndex)
		if self.fannedCards == 0 then
			return
		end
		if self.offsetCardIndex then
			self:UnoffsetCard(self.offsetCardIndex)
		end
		self.cards[cardIndex].previousOffset = { x = self.cards[cardIndex].offset.x, y = self.cards[cardIndex].offset.y }
		self.cards[cardIndex].targetOffset = { x = 0, y = self.cards[cardIndex].offset.y + self.cards[cardIndex].halfHeight }
		self.offsetCardIndex = cardIndex
	end,
	
	UnoffsetCard = function(self, cardIndex)
		self.cards[cardIndex].targetOffset = { x = self.cards[cardIndex].previousOffset.x, y = self.cards[cardIndex].previousOffset.y }
		self.offsetCardIndex = nil
	end,

	OffsetRandomCard = function(self)
		local randomCardIndex = math.random(1, self.fannedCards)
		self:OffsetCard(randomCardIndex)
	end,

	GiveSelectedCard = function(self)
		if self.offsetCardIndex then
			self.cards[self.offsetCardIndex].targetPosition = { x = 600, y = 100 }
			self.cards[self.offsetCardIndex].targetOffset = { x = 0, y = 0 }
			self.cards[self.offsetCardIndex].targetAngle = 0
			self.cards[self.offsetCardIndex].given = true
			self.cards[self.offsetCardIndex].facingUp = true
		end
	end,

	RetrieveSelectedCard = function(self)

	end,
}

Deck.__index = Deck
return Deck