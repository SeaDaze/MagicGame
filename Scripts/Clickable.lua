local Clickable = {}
Clickable.__index = Clickable

Clickable.New = function(self)
    local instance = setmetatable({}, Clickable)
    instance.hovered = false
    instance.down = false
    instance.defaultImage = love.graphics.newImage("Images/okUP.jpg")
    instance.hoveredImage = love.graphics.newImage("Images/okHOVERED.jpg")
    instance.downImage = love.graphics.newImage("Images/okDOWN.jpg")
    instance.callbackListeners = {}
    instance.callbackId = 0
    return instance
end

Clickable.Update = function(self, dt)
    if love.mouse.getX() >= 0 and love.mouse.getX() <= 32 and love.mouse.getY() >= 0 and love.mouse.getY() <= 32 then
        self.hovered = true
    else
        self.hovered = false
    end

    if self.hovered and not self.down and love.mouse.isDown(1) then
        self.down = true
        for _, callbackData in pairs(self.callbackListeners) do
            callbackData.table[callbackData.func](callbackData.table)
        end
    elseif not love.mouse.isDown(1) then
        self.down = false
    end
end

Clickable.Draw = function(self)
    if self.hovered and not self.down then
        love.graphics.draw(self.hoveredImage, 0, 0)
    elseif self.hovered and self.down then
        love.graphics.draw(self.downImage, 0, 0)
    else
        love.graphics.draw(self.defaultImage, 0, 0)
    end
end

---@param self any
---@param callbackTable table
---@param callbackFunc string
Clickable.ListenOnClicked = function(self, callbackTable, callbackFunc)
    self.callbackId = self.callbackId + 1
    self.callbackListeners[self.callbackId] = {
        table = callbackTable,
        func = callbackFunc,
    }
    return self.callbackId
end

return Clickable