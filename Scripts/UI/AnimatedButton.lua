local Animator = require("Scripts.libraries.anim8")

local font = love.graphics.newFont("Fonts/pixelifySans.ttf", 30)

local Button = {
	New = function(self, text, position, width, height, textScale)
		local instance = setmetatable({}, self)
        instance.text = text
        instance.position = position
        instance.width = width * 3
        instance.height = height * 3
        instance.textScale = textScale
        instance.color = { 0, 0, 0, 1}
        instance.hovered = false
        instance.clicked = false
		instance.callbackData = { }
        instance.active = true

        -- instance.spriteSheet = DrawSystem:LoadImage("Images/UI/Buttons/Button_Test_Anim.png")
		-- instance.grid = Animator.newGrid(80, 45, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight())
		-- instance.animation = Animator.newAnimation(instance.grid('1-10', 1), 0.02)
        -- instance.reverseAnimation = Animator.newAnimation(instance.grid('10-1', 1), 0.02)
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

        local mouseHovering = self:EvaluateMouseHover()
        if mouseHovering and not self.hovered then
            self.hovered = true
            self:OnMouseHoverStart()
            self.animation:resume()
        elseif not mouseHovering and self.hovered then
            self.hovered = false
            self:OnMouseHoverStop()
            self.reverseAnimation:gotoFrame(1)
        end

        if self.hovered then
            if self.animation.position == #self.animation.frames then
                self.animation:pauseAtEnd()
            else
                self.animation:update(dt)
            end
        else
            if self.reverseAnimation.position == #self.reverseAnimation.frames then
                self.animation:pauseAtStart()
                
                self.reversing = false
            else
                self.reverseAnimation:update(dt)
                self.reversing = true
            end
        end

        if self.hovered and not self.clicked and love.mouse.isDown(1) then
            self.clicked = true
            self:OnMouseClickStart()
			-- if self.callbackData.listenTarget then
			-- 	self.callbackData.listenTarget[self.callbackData.functionName](self.callbackData.listenTarget, self.callbackData.params)
			-- end
            -- for _, callbackData in pairs(self.callbackListeners) do
            --     callbackData.table[callbackData.func](callbackData.table)
            -- end
        elseif not love.mouse.isDown(1) and self.clicked then
            self.clicked = false
            self:OnMouseClickStop()
        end
    end,

    Draw = function(self)

        -- if not self.active then
        --     love.graphics.setColor(0.5, 0.5, 0.5)
        -- elseif self.hovered and not self.clicked then
        --     love.graphics.setColor(0.7, 0.7, 0.8)
        -- elseif self.clicked then
        --     love.graphics.setColor(0.5, 0.5, 0.8)
        -- else
        --     love.graphics.setColor(1, 1, 1)
        -- end
        
        -- love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, 2, 2)
        if self.reversing then
            self.reverseAnimation:draw(self.spriteSheet, self.position.x, self.position.y, nil, 3, 3)
        else
            self.animation:draw(self.spriteSheet, self.position.x, self.position.y, nil, 3, 3)
        end
        love.graphics.printf(self.text, font, self.position.x + 70, self.position.y + 45, 150, "left")

        --love.graphics.print({ self.color, self.text }, self.position.x, self.position.y, 0, self.textScale)
        -- love.graphics.setColor(1, 1, 1)
    end,

    SetActive = function(self, active)
        self.active = active
    end,

    EvaluateMouseHover = function(self)
        return love.mouse.getX() >= self.position.x and love.mouse.getX() <= self.position.x + self.width and love.mouse.getY() >= self.position.y and love.mouse.getY() <= self.position.y + self.height
    end,

    OnMouseHoverStart = function(self)
    end,

    OnMouseHoverStop = function(self)
    end,

    OnMouseClickStart = function(self)
    end,

    OnMouseClickStop = function(self)
    end,

}

Button.__index = Button
return Button