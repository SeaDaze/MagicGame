
local Animator = require("Scripts.libraries.anim8")

local Briefcase = 
{
    Load = function(self)
        self.leftHand = Player:GetLeftHand()
        self.rightHand = Player:GetRightHand()
        self.spriteWidth = 40
        self.spriteHeight = 70
        self.position = { 
            x = love.graphics.getWidth() - (self.spriteWidth * GameSettings.WindowResolutionScale),
            y = love.graphics.getHeight() - (self.spriteHeight * GameSettings.WindowResolutionScale)
        }
        self.briefcaseSpritesheet = love.graphics.newImage("Images/Background/briefcase.png")
		self.briefcaseGrid = Animator.newGrid(self.spriteWidth, self.spriteHeight, self.briefcaseSpritesheet:getWidth(), self.briefcaseSpritesheet:getHeight())
        self.openAnimation = Animator.newAnimation(self.briefcaseGrid('1-3', 1), 0.1, self.OnAnimationFinished)
		self.closeAnimation = Animator.newAnimation(self.briefcaseGrid('3-1', 1), 0.1, self.OnAnimationFinished)
        self.closeAnimation:pauseAtEnd()
        self.open = false
        self.nearDistance = 20000
    end,

    Update = function(self, dt)
        self:HandleRightHand()
        self:HandleLeftHand()
        self.openAnimation:update(dt)
        self.closeAnimation:update(dt)
    end,

    Draw = function(self)
        if self.open then
            self.openAnimation:draw(
                self.briefcaseSpritesheet,
                self.position.x,
                self.position.y,
                nil,
                GameSettings.WindowResolutionScale,
                GameSettings.WindowResolutionScale,
                self.spriteWidth / 2,
                self.spriteHeight / 2
            )
        else
            self.closeAnimation:draw(
                self.briefcaseSpritesheet,
                self.position.x,
                self.position.y,
                nil,
                GameSettings.WindowResolutionScale,
                GameSettings.WindowResolutionScale,
                self.spriteWidth / 2,
                self.spriteHeight / 2
            )
        end
    end,

    OnAnimationFinished = function(briefcaseAnimation, loops)
        briefcaseAnimation:pauseAtEnd()
    end,

    Open = function(self)
        self.open = true
        self.openAnimation:pauseAtStart()
        self.openAnimation:resume()
    end,

    Close = function(self)
        self.open = false
        self.closeAnimation:pauseAtStart()
        self.closeAnimation:resume()
    end,

    HandleRightHand = function(self)
        local rightHandPosition = self.rightHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.position.x, self.position.y, rightHandPosition.x, rightHandPosition.y) < self.nearDistance
        if withinRange and not self.hoveredRight then
            self.hoveredRight = true
            self.rightHand:AddNearbyBriefcase(self)
            self:EvaluateOpenState()
        elseif not withinRange and self.hoveredRight then
            self.hoveredRight = false
            self.rightHand:RemoveNearbyBriefcase(self)
            self:EvaluateOpenState()
        end
    end,

    HandleLeftHand = function(self)
        local handPosition = self.leftHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.position.x, self.position.y, handPosition.x, handPosition.y) < self.nearDistance
        if withinRange and not self.hoveredLeft then
            self.hoveredLeft = true
            self.leftHand:AddNearbyBriefcase(self)
            self:EvaluateOpenState()
        elseif not withinRange and self.hoveredLeft then
            self.hoveredLeft = false
            self.leftHand:RemoveNearbyBriefcase(self)
            self:EvaluateOpenState()
        end
    end,

    EvaluateOpenState = function(self)
        if not self.open and (self.hoveredRight or self.hoveredLeft) then
            self:Open()
        elseif self.open and not (self.hoveredRight or self.hoveredLeft) then
            self:Close()
        end
    end,

}

return Briefcase