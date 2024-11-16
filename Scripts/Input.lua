

local Input =
{
	Load = function(self)
		self.enabled = true
		local joysticks = love.joystick.getJoysticks()
		print("joysticks=", table.count(joysticks))
		self.joystick = joysticks[1]

		self.lastMousePosition = 
		{
			x = 0,
			y = 0,
		}

		self.rightAxisJoystickActive = false

		if not self.actionListeners then
			self.actionListeners = {}
		end
		self.actionDown = {}
		for _, action in ipairs(GameConstants.InputActions) do
			self.actionDown[action] = false
		end
		self.actionQueries = 
		{
			[GameConstants.InputActions.Left] = self.GetLeftActionDown,
			[GameConstants.InputActions.Right] = self.GetRightActionDown
		}
		self.actionListenerId = 0
	end,

    Update = function(self)
		self:EvaluateRightJoystickAxisPriority()

		if not self.enabled then
			if self.reEnableTime and love.timer.getTime() > self.reEnableTime then
				self.reEnableTime = nil
				self.enabled = true
				print("Update: input re-enabled")
			else
				return
			end
		end

		if self.keyListeners then
			for key, keyData in pairs(self.keyListeners) do
				if not keyData.down and love.keyboard.isDown(key) then
					keyData.down = true
					if keyData.downCallback then
						keyData.tableInstance[keyData.downCallback](keyData.tableInstance)
					end
				elseif keyData.down and not love.keyboard.isDown(key) then
					keyData.down = false
					if keyData.upCallback then
						keyData.tableInstance[keyData.upCallback](keyData.tableInstance)
					end
				end
			end
		end

		if self.mouseListeners then
			for index, mouseData in pairs(self.mouseListeners) do
				if not mouseData.down and love.mouse.isDown(index) then
					mouseData.tableInstance[mouseData.downCallback](mouseData.tableInstance)
					mouseData.down = true
				elseif mouseData.down and not love.mouse.isDown(index) then
					mouseData.down = false
					if mouseData.upCallback then
						mouseData.tableInstance[mouseData.upCallback](mouseData.tableInstance)
					end
				end
			end
		end

		for action, queryActionFunction in pairs(self.actionQueries) do
			local actionDown = queryActionFunction(self)
			if self.actionListeners[action] then
				if actionDown and not self.actionDown[action] then
					self.actionDown[action] = true
					for _, listenerTable in pairs(self.actionListeners[action]) do
						if listenerTable.downCallback then
							listenerTable:downCallback()
						end
					end
				elseif not actionDown and self.actionDown[action] then
					self.actionDown[action] = false
					for _, listenerTable in pairs(self.actionListeners[action]) do
						if listenerTable.upCallback then
							listenerTable:upCallback()
						end
					end
				end
			end
		end
    end,


	--==========================================================================================================
	-- Listeners
	--==========================================================================================================
	AddMouseListener = function(self, index, tableInstance, downCallback, upCallback)
		if not self.mouseListeners then
			self.mouseListeners = {}
		end
		self.mouseListeners[index] =
		{
			down = false,
			tableInstance = tableInstance,
			downCallback = downCallback,
			upCallback = upCallback,
		}
		print("AddMouseListener: Added listener for index=", index, ", when pressed, will call function=", downCallback)
	end,

	RemoveMouseListener = function(self, index)
		self.mouseListeners[index] = nil
		print("RemoveMouseListener: Removed listener for mouse button=", index)
	end,

	AddKeyListener = function(self, key, tableInstance, downCallback, upCallback)
		if not self.keyListeners then
			self.keyListeners = {}
		end
		self.keyListeners[key] =
		{
			down = false,
			tableInstance = tableInstance,
			downCallback = downCallback,
			upCallback = upCallback,
		}
		print("AddKeyListener: Added listener for key=", key, ", when pressed, will call function=", downCallback)
	end,

	RemoveKeyListener = function(self, key)
		self.keyListeners[key] = nil
		print("RemoveKeyListener: Removed listener for key=", key)
	end,

	AddActionListener = function(self, action, downCallback, upCallback)
		if not self.actionListeners[action] then
			self.actionListeners[action] = {}
		end
		self.actionListenerId = self.actionListenerId + 1
		if not self.listenerIdToAction then
			self.listenerIdToAction = {}
		end
		self.listenerIdToAction[self.actionListenerId] = action

		self.actionListeners[action][self.actionListenerId] =
		{
			downCallback = downCallback,
			upCallback = upCallback,
		}

		print("AddActionListener: Added action listener for action=", action, ", listenerId=",self.actionListenerId )
		return self.actionListenerId
	end,

	RemoveActionListener = function(self, listenerId)
		local action = self.listenerIdToAction[listenerId]
		if not action then
			print("RemoveActionListener: No action found with listenerId=", listenerId)
			return
		end
		if self.actionListeners[action][listenerId] then
			self.actionListeners[action][listenerId] = nil
		end

		print("RemoveActionListener: Removed action listener for action=", action, ", listenerId=", listenerId)
	end,

	--==========================================================================================================
	-- Global gets
	--==========================================================================================================

	GetInputAxis = function(self, axis)
		if axis == GameConstants.InputAxis.Left.X then
			local joystickAxis = self:GetJoystickAxis(GameConstants.JoystickAxis.LeftStick.X)
			local keyboardAxis = self:GetKeyboardAxis("a", "d")

			if math.abs(joystickAxis) > math.abs(keyboardAxis) then
				if joystickAxis < 0 then
					return (joystickAxis * joystickAxis * -1)
				else 
					return (joystickAxis * joystickAxis)
				end
			else
				return keyboardAxis
			end
		elseif axis == GameConstants.InputAxis.Left.Y then
			local joystickAxis = self:GetJoystickAxis(GameConstants.JoystickAxis.LeftStick.Y)
			local keyboardAxis = self:GetKeyboardAxis("w", "s")

			if math.abs(joystickAxis) > math.abs(keyboardAxis) then
				if joystickAxis < 0 then
					return (joystickAxis * joystickAxis * -1)
				else 
					return (joystickAxis * joystickAxis)
				end
			else
				return keyboardAxis
			end
		elseif axis == GameConstants.InputAxis.Right.X then
			local joystickAxis = self:GetJoystickAxis(GameConstants.JoystickAxis.RightStick.X)
			local keyboardAxis = self:GetKeyboardAxis("left", "right")

			if math.abs(joystickAxis) > math.abs(keyboardAxis) then
				if joystickAxis < 0 then
					return (joystickAxis * joystickAxis * -1)
				else 
					return (joystickAxis * joystickAxis)
				end
			else
				return keyboardAxis
			end
		elseif axis == GameConstants.InputAxis.Right.Y then
			local joystickAxis = self:GetJoystickAxis(GameConstants.JoystickAxis.RightStick.Y)
			local keyboardAxis = self:GetKeyboardAxis("up", "down")

			if math.abs(joystickAxis) > math.abs(keyboardAxis) then
				if joystickAxis < 0 then
					return (joystickAxis * joystickAxis * -1)
				else 
					return (joystickAxis * joystickAxis)
				end
			else
				return keyboardAxis
			end
		end
	end,

	GetJoystickAxis = function(self, joystickAxis)
		if self.joystick then
			local axis = self.joystick:getGamepadAxis(joystickAxis)
			if axis and math.abs(axis) > GameConstants.JoystickInputDeadzone then
				return axis
			end
			return 0
		end
		return 0
	end,

	GetKeyboardAxis = function(self, negative, positive)
		local leftAxis = love.keyboard.isDown(negative) and -1 or 0
		local rightAxis = love.keyboard.isDown(positive) and 1 or 0
		return (leftAxis + rightAxis)
	end,

	GetLeftActionDown = function(self)
		return love.keyboard.isDown("space") or self:GetJoystickAxis(GameConstants.JoystickAxis.LeftTrigger) > 0.5
	end,

	GetRightActionDown = function(self)
		return love.mouse.isDown(1) or self:GetJoystickAxis(GameConstants.JoystickAxis.RightTrigger) > 0.5
	end,

	EvaluateRightJoystickAxisPriority = function(self)
		if love.mouse.getX() ~= self.lastMousePosition.x or love.mouse.getY() ~= self.lastMousePosition.y then
			self.rightAxisJoystickActive = false
			self.lastMousePosition = 
			{
				x = love.mouse.getX(),
				y = love.mouse.getY(),
			}
		end

		if not self.rightAxisJoystickActive then
			local joystickAxisX = self:GetJoystickAxis(GameConstants.JoystickAxis.RightStick.X)
			local joystickAxisY = self:GetJoystickAxis(GameConstants.JoystickAxis.RightStick.Y)
			if math.abs(joystickAxisX) > 0 or math.abs(joystickAxisY) > 0 then
				self.rightAxisJoystickActive = true
			end
		end
	end,

	GetRightJoystickAxisPriority = function(self)
		return self.rightAxisJoystickActive
	end,

	SetEnabled = function(self, enabled)
		self.enabled = enabled
	end,

	DisableForSeconds = function(self, seconds)
		self.enabled = false
		self.reEnableTime = love.timer.getTime() + seconds
		print("DisableForSeconds: input disable for seconds=", seconds)
	end,
}

return Input