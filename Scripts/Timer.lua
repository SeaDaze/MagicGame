
local Timer = {
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
	end,

	AddListener = function(self, listenTarget, functionName)
		self.callbackId = self.callbackId + 1
		self.callbackTargets[self.callbackId] = {
			listenTarget = listenTarget,
			functionName = functionName,
		}
		return self.callbackId
	end,
}

Timer.__index = Timer
Timer.New = function()
    local instance = setmetatable({}, Timer)
	instance.callbackTargets = {}
	instance.runningTimers = {}
	instance.callbackId = 0
    return instance
end
return Timer