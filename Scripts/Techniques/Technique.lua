local Common = require("Scripts.Common")

local Technique = 
{
    GetScore = function(self)
        return self.score or 0
    end,

	AddListener = function(self, listenTarget, functionName)
		self.callbackId = self.callbackId + 1
		self.callbackTargets[self.callbackId] = {
			listenTarget = listenTarget,
			functionName = functionName,
		}
		return self.callbackId
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
		Flux.to(self.leftHand.position, 0.4, { x = centerPoint.x, y = centerPoint.y} )
		Flux.to(self.rightHand.position, 0.4, { x = centerPoint.x, y = centerPoint.y} )

		self.technique_timerNotificationId = Timer:AddListener(self, "Technique_OnTimerFinished")
		Timer:Start("Technique_HandsTogether", 0.4)
	end,

	Technique_OnTimerFinished = function(self, timerId)
		if timerId == "Technique_HandsTogether" then
			self.deck:SwapHands()
			self.leftHand:Enable()
			self.rightHand:Enable()
			Timer:RemoveListener(self.technique_timerNotificationId)
		end
	end,

	Technique_ExecuteHooks = function(self, functionName, params)
        for _, func in pairs(self.actionListeners[functionName]) do
            func(params)
        end
    end,

	Technique_AddActionListener = function(self, action, callback)
		if not self.actionListeners then
			self.actionListeners = {}
		end
		if not self.actionListeners[action] then
			self.actionListeners[action] = {}
		end
		if not self.actionListenerId then
			self.actionListenerId = 0
		end
		self.actionListenerId = self.actionListenerId + 1
		if not self.listenerIdToAction then
			self.listenerIdToAction = {}
		end
		self.listenerIdToAction[self.actionListenerId] = action

		self.actionListeners[action][self.actionListenerId] = callback
        return self.actionListenerId
	end,

    Technique_RemoveActionListener = function(self, listenerId)
		local action = self.listenerIdToAction[listenerId]
		if not action then
			print("RemoveActionListener: No action found with listenerId=", listenerId)
			return
		end
		if self.actionListeners[action][listenerId] then
			self.actionListeners[action][listenerId] = nil
		end
	end,

	Technique_OnTechniqueEvaluated = function(self, score)
		self:Technique_ExecuteHooks("Technique_OnTechniqueEvaluated", { score = score })
	end,

	Technique_OnFinished = function(self)
		self:Technique_ExecuteHooks("Technique_OnFinished")
	end,
}

Technique.__index = Technique
return Technique