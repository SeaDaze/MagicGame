local Button = {
    Initialize = function(self, width, height)
        self.color = { 0, 0, 0, 1}
        self.hovered = false
        self.clicked = false
		self.callbackData = {}
        self.active = true
        self.width = width
        self.height = height
    end,

	AddListener = function(self, listenTarget, functionName, params)
		self.callbackData.listenTarget = listenTarget
		self.callbackData.functionName = functionName
		self.callbackData.params = params
        print("AddListener: Added listener for functionName=", functionName)
	end,

    SuperUpdate = function(self, dt)
        if not self.active then
            return
        end

        local mouseHovering = self:EvaluateMouseHover()
        if mouseHovering and not self.hovered then
            self.hovered = true
            self:OnMouseHoverStart()
        elseif not mouseHovering and self.hovered then
            self.hovered = false
            self:OnMouseHoverStop()
        end

        if self.hovered and not self.clicked and love.mouse.isDown(1) then
            self.clicked = true
            self:OnMouseClickStart()
        elseif not love.mouse.isDown(1) and self.clicked then
            self.clicked = false
            self:OnMouseClickStop()
        end
    end,

    Draw = function(self)
    end,

    SetActive = function(self, active)
        self.active = active
    end,

    GetHovered = function(self)
        return self.hovered
    end,

    GetScale = function(self)
        return 1
    end,

    EvaluateMouseHover = function(self)
        local onScreenPosition = self:GetOnScreenPosition()
        return love.mouse.getX() >= onScreenPosition.x and love.mouse.getX() <= onScreenPosition.x + (self.width * self:GetScale()) and love.mouse.getY() >= onScreenPosition.y and love.mouse.getY() <= onScreenPosition.y + (self.height * self:GetScale())
    end,

    OnMouseHoverStart = function(self)
        print("OnMouseHoverStart: BASE")
    end,

    OnMouseHoverStop = function(self)
        print("OnMouseHoverStop: BASE")
    end,

    OnMouseClickStart = function(self)
        print("OnMouseClickStart: BASE")
    end,

    OnMouseClickStop = function(self)
        print("OnMouseClickStop: BASE")
    end,

    SendEventToListeners = function(self)
        if self.callbackData.listenTarget then
            self.callbackData.listenTarget[self.callbackData.functionName](self.callbackData.listenTarget, self.callbackData.params)
        end
    end,

    Reset = function(self)
        self.clicked = false
        self.hovered = false
        print("Reset: BASE")
    end,
}

Button.__index = Button
return Button