local EventIds = require("Scripts.System.EventIds")

local Input =
{
	Load = function(self)
		local joysticks = love.joystick.getJoysticks()
		self.joystick = joysticks[1]

		self.lastMousePosition = 
		{
			x = 0,
			y = 0,
		}

		self.rightAxisJoystickActive = false

		self.actionDown = {}
		for _, action in ipairs(GameConstants.InputActions) do
			self.actionDown[action] = false
		end

		self.actionQueries = 
		{
			[GameConstants.InputActions.Left] = self.GetLeftActionDown,
			[GameConstants.InputActions.Right] = self.GetRightActionDown
		}
		self.inputActionToEventId = 
		{
			[GameConstants.InputActions.Left] = EventIds.LeftAction,
			[GameConstants.InputActions.Right] = EventIds.RightAction,
		}

		self.customQueries = {
			"return",
		}
		self.customKeyboardInputDown = {}
	end,

    Update = function(self)
		self:EvaluateRightJoystickAxisPriority()

		for action, queryActionFunction in pairs(self.actionQueries) do
			local actionDown = queryActionFunction(self)
			if actionDown and not self.actionDown[action] then
				self.actionDown[action] = true
				EventSystem:BroadcastEvent(self.inputActionToEventId[action], action, true)
			elseif not actionDown and self.actionDown[action] then
				self.actionDown[action] = false
				EventSystem:BroadcastEvent(self.inputActionToEventId[action], action, false)
			end
		end

		for _, key in pairs(self.customQueries) do
			local actionDown = love.keyboard.isDown(key)
			if actionDown and not self.customKeyboardInputDown[key] then
				self.customKeyboardInputDown[key] = true
				EventSystem:BroadcastEvent(EventIds.CustomKeyboardInput, key, true)
			elseif not actionDown and self.customKeyboardInputDown[key] then
				self.customKeyboardInputDown[key] = false
				EventSystem:BroadcastEvent(EventIds.CustomKeyboardInput, key, false)
			end
		end
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
}

return Input