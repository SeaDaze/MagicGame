local Common = require("Scripts.Common")

local LineDraw = 
{
    Load = function(self, playerStatsReference)
        self.lines = {}
        self.originPoint = nil
        self.lineIndex = 1
    end,

    Update = function(self, Flux, dt)
        local mouseX, mouseY = love.mouse.getPosition()
        if love.mouse.isDown(1) then
            if not self.lines[self.lineIndex] then
                local x = mouseX
                local y = mouseY
                if self.lines[self.lineIndex - 1] then
                    x = self.lines[self.lineIndex - 1].x2
                    y = self.lines[self.lineIndex - 1].y2
                end
                self.lines[self.lineIndex] = { x1 = x, y1 = y, x2 = x, y2 = y }
            end
            self.lines[self.lineIndex].x2 = mouseX
            self.lines[self.lineIndex].y2 = mouseY
            if Common:DistanceSquared(self.lines[self.lineIndex].x1, self.lines[self.lineIndex].y1, self.lines[self.lineIndex].x2, self.lines[self.lineIndex].y2) > 300 then
                self.lineIndex = self.lineIndex + 1
            end
        elseif not love.mouse.isDown(1) then
            if self.originPoint then
                self.originPoint = nil
            end
            if Common:TableCount(self.lines) > 0 then
                self.lines = {}
            end
        end
    end,

    Draw = function(self)
        for _, line in pairs(self.lines) do
            love.graphics.line(line.x1, line.y1, line.x2, line.y2)
        end
    end,
}
return LineDraw