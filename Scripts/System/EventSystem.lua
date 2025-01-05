

local EventSystem = 
{
	Load = function(self)
		self.eventListeners = {}
		self.notificationIdToEventId = {}
		self.notificationId = 0
	end,

	--- Broadcast an event to all listeners
	---@param self any
	---@param eventId number
	---@param ... unknown
	BroadcastEvent = function(self, eventId, ...)
		if not self.eventListeners[eventId] then
			return
		end
		for _, callbackData in pairs(self.eventListeners[eventId]) do
			callbackData.instanceTable[callbackData.callbackFunctionName](callbackData.instanceTable, ...)
		end
	end,

	--- Connect to events using a number ID. When the event is broadcasted, the given callback function will be called
	---@param self any
	---@param eventId number
	---@param instanceTable table
	---@param callbackFunctionName string
	---@return number
	ConnectToEvent = function(self, eventId, instanceTable, callbackFunctionName)
		local error = false
		if type(eventId) ~= "number" then
			print("ConnectToEvent: Connect failed - the received eventId is not a number")
			error = true
		end
		if type(instanceTable) ~= "table" then
			print("ConnectToEvent: Connect failed - the received callback is not a function")
			error = true
		end
		if type(callbackFunctionName) ~= "string" then
			print("ConnectToEvent: Connect failed - the received callback is not a function")
			error = true
		end
		if error then
			return 0
		end

		if not self.eventListeners[eventId] then
			self.eventListeners[eventId] = {}
		end
		self.notificationId = self.notificationId + 1
		self.notificationIdToEventId[self.notificationId] = eventId

		self.eventListeners[eventId][self.notificationId] = 
		{
			instanceTable = instanceTable,
			callbackFunctionName = callbackFunctionName
		}
		return self.notificationId
	end,

	--- Disconnect from an event using the notification Id generated from ConnectToEvent function
	---@param self any
	---@param notificationId any
	DisconnectFromEvent = function(self, notificationId)
		local eventId = self.notificationIdToEventId[notificationId]
		if not eventId then
			print("DisconnectFromEvent: No existing event connections with Id: '", notificationId, "'")
			return
		end
		self.eventListeners[eventId][notificationId] = nil
	end,
}
return EventSystem