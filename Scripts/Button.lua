local Button = {
	New = function(self, text, position, width, height, textScale)
		local instance = setmetatable({}, self)
        instance.text = text
        instance.position = position
        instance.width = width
        instance.height = height
        instance.textScale = textScale
        instance.color = { 0, 0, 0, 1}
        instance.hovered = false
        instance.clicked = false
		instance.callbackData = { }
        instance.active = false
		return instance
	end,

	AddListener = function(self, listenTarget, functionName, params)
		self.callbackData.listenTarget = listenTarget
		self.callbackData.functionName = functionName
		self.callbackData.params = params
	end,

    Update = function(self, dt)
        if not self.active then
            return
        end
        if love.mouse.getX() >= self.position.x and love.mouse.getX() <= self.position.x + self.width and love.mouse.getY() >= self.position.y and love.mouse.getY() <= self.position.y + self.height then
            self.hovered = true
        else
            self.hovered = false
        end

        if self.hovered and not self.clicked and love.mouse.isDown(1) then
            self.clicked = true
			if self.callbackData.listenTarget then
				self.callbackData.listenTarget[self.callbackData.functionName](self.callbackData.listenTarget, self.callbackData.params)
			end
            -- for _, callbackData in pairs(self.callbackListeners) do
            --     callbackData.table[callbackData.func](callbackData.table)
            -- end
        elseif not love.mouse.isDown(1) then
            self.clicked = false
        end
    end,

    Draw = function(self)
        if not self.active then
            love.graphics.setColor(0.5, 0.5, 0.5)
        elseif self.hovered and not self.clicked then
            love.graphics.setColor(0.7, 0.7, 0.8)
        elseif self.clicked then
            love.graphics.setColor(0.5, 0.5, 0.8)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, 2, 2)
        love.graphics.print({ self.color, self.text }, self.position.x, self.position.y, 0, self.textScale)
        love.graphics.setColor(1, 1, 1)
    end,

    SetActive = function(self, active)
        self.active = active
    end
}

Button.__index = Button
return Button