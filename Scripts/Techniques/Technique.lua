local Common = require("Scripts.Common")

local Technique = 
{
    GetScore = function(self)
        return self.score or 0
    end,

    SetFinishListener = function(self, listener, functionName)
        self.listenerData = {
            listener = listener,
            functionName = functionName
        }
    end,

	RemoveFinishListener = function(self)
		self.listenerData = nil
	end,

	SendToFinishListener = function(self)
		if not self.listenerData then
			return
		end
		self.listenerData.listener[self.listenerData.functionName](self.listenerData.listener)
	end,

	GetName = function(self)
		return self.name or ""
	end,

	SwapHands = function(self)
		self.technique_SwapHandsData = 
		{
			leftHandOriginalPosition = self.leftHand.position,
			rightHandOriginalPosition = self.rightHand.position,
		}

		self.leftHand:Disable()
		self.rightHand:Disable()
		local direction = {
			x = self.rightHand.position.x - self.leftHand.position.x,
			y = self.rightHand.position.y - self.leftHand.position.y,
		}
		direction = Common:Normalize(direction)
		local distance = Common:Distance(self.rightHand.position.x, self.rightHand.position.y, self.leftHand.position.x, self.leftHand.position.y)
		local centerPoint = {
			x = self.leftHand.position.x + (direction.x * distance / 2),
			y = self.leftHand.position.y + (direction.y * distance / 2),
		}
		self.flux.to(self.leftHand.position, 0.4, { x = centerPoint.x, y = centerPoint.y} )
		self.flux.to(self.rightHand.position, 0.4, { x = centerPoint.x, y = centerPoint.y} )

		self.technique_timerNotificationId = self.timer:AddListener(self, "Technique_OnTimerFinished")
		self.timer:Start("Technique_HandsTogether", 0.4)
	end,

	Technique_OnTimerFinished = function(self, timerId)
		if timerId == "Technique_HandsTogether" then
			self.deck:SwapHands()
			self.leftHand:Enable()
			self.rightHand:Enable()
			self.timer:RemoveListener(self.technique_timerNotificationId)
		end
	end,
}

Technique.__index = Technique
return Technique