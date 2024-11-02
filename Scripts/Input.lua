

local Input =
{
	Load = function(self)
		self.enabled = true
		local joysticks = love.joystick.getJoysticks()
		print("joysticks=", Common:TableCount(joysticks))
		self.joystick = joysticks[1]

		self.lastMousePosition = 
		{
			x = 0,
			y = 0,
		}

		self.rightAxisJoystickActive = false
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