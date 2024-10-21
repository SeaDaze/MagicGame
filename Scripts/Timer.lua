
local Timer = {
	Load = function(self)
		self.callbackTargets = {}
		self.runningTimers = {}
		self.callbackId = 0
	end,

    Update = function(self, dt)
		local timersToRemove = {}
		for timerId, timerData in pairs(self.runningTimers) do
			if love.timer.getTime() >= timerData.endTime then
				for _, callbackTarget in pairs(self.callbackTargets) do
					callbackTarget.listenTarget[callbackTarget.functionName](callbackTarget.listenTarget, timerId)
				end
				table.insert(timersToRemove, timerId)
			end
		end
		for _, timerId in pairs(timersToRemove) do
			self.runningTimers[timerId] = nil
		end
	end,

	Start = function(self, id, duration)
		self.runningTimers[id] = {
			id = id,
			duration = duration,
			startTime = love.timer.getTime(),
			endTime = love.timer.getTime() + duration,
		}
		print("Start: Started timer with id=", id, ", forr duration=", duration)
	end,

	AddListener = function(self, listenTarget, functionName)
		self.callbackId = self.callbackId + 1
		self.callbackTargets[self.callbackId] = {
			listenTarget = listenTarget,
			functionName = functionName,
		}
		return self.callbackId
	end,

	RemoveListener = function(self, callbackId)
		self.callbackTargets[callbackId] = nil
	end,
}

return Timer