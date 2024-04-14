

local Input =
{
	Load = function(self)
		self.enabled = true
	end,

    Update = function(self)
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
					keyData.tableInstance[keyData.downCallback](keyData.tableInstance)
					keyData.down = true
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

	RemoveMouseListener = function(self, index)
		self.mouseListeners[index] = nil
		print("RemoveMouseListener: Removed listener for mouse button=", index)
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