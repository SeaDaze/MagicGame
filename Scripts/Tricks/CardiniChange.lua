local Technique = require("Scripts.Techniques.Technique")
local Common = require("Scripts.Common")

local CardiniChange = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
		instance.leftHand = leftHand
		instance.rightHand = rightHand

		-- Variables
        instance.name = "cardini"
		instance.duration = 0.5
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        --Input:AddKeyListener("f", self, nil, "HandleChange")
		self.rightHand:SetState(GameConstants.HandStates.PalmDown)
    end,

    Update = function(self, dt)
		if not self.evaluateScore then
			return
		end
		local cardPosition = {
			x = self.deck.cards[52].position.x + self.deck.cards[52].positionOffset.x,
			y = self.deck.cards[52].position.y + self.deck.cards[52].positionOffset.y,
		}
		local handPosition = self.rightHand.position
		local distanceSquared = Common:DistanceSquared(cardPosition.x, cardPosition.y, handPosition.x, handPosition.y)
		table.insert(self.scores, distanceSquared)

		--print("DistanceSquared=", distanceSquared)
	end,

    OnStop = function(self)
		Input:RemoveKeyListener("f")
		Timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
		if timerId == "Halfway" then
			self.evaluateScore = false
			self.deck:CardiniChange()
			Flux.to(self.deck.cards[1].scale, 0.3, { x = 5 } )
			Flux.to(self.deck.cards[1].positionOffset, 0.3, { x = 0 } )
			Timer:Start("Finished", 1)
			HUD:SetScoreText(math.floor(self:EvaluateScore()))
		elseif timerId == "Finished" then
			
		end
	end,

	HandleChange = function(self)
		Input:DisableForSeconds(1)
		Flux.to(self.deck.cards[52].scale, self.duration, { x = 0 } )
		Flux.to(self.deck.cards[52].positionOffset, self.duration, { x = self.deck.cards[52].halfWidth * GameSettings.WindowResolutionScale } )
		Timer:Start("Halfway", self.duration)
		self.evaluateScore = true
		self.scores = {}
	end,

	EvaluateScore = function(self)
		local numberOfScores = table.count(self.scores)
		if numberOfScores == 0 then
			return 0
		end
		local maxScore = 3000
		local totalScore = 0
		for _, score in ipairs(self.scores) do
			local evaluatedScore = (maxScore - score) / 30
			if evaluatedScore < 0 then
				evaluatedScore = 0
			end
			totalScore = totalScore + evaluatedScore
		end

		return totalScore / numberOfScores
	end,

}

CardiniChange.__index = CardiniChange
setmetatable(CardiniChange, Technique)
return CardiniChange