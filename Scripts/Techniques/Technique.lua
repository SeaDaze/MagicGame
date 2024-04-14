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
}

Technique.__index = Technique
return Technique