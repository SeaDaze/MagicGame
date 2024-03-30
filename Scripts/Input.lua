

local Input =
{
    Update = function(self)
		if not self.keyListeners then
			return
		end
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
		print("AddKeyListener: Added listener for key=", key, ", when pressed, will call function=", callback)
	end,

	RemoveKeyListener = function(self, key)
		self.keyListeners[key] = nil
		print("RemoveKeyListener: Removed listener for key=", key)
	end,
}

return Input