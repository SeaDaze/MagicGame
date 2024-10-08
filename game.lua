-- External Libraries
local Flux = require("Scripts.libraries.flux")
local moonshine = require ("Scripts.libraries.moonshine")

-- Helpers
local Constants = require ("Scripts.Constants")
local Background = require("Scripts.Background")

-- Scenes
local PerformScene = require("Scripts.PerformScene")
local StreetScene = require("Scripts.StreetScene")
local MainMenu = require("Scripts.UI.MainMenu")

local HUD = require("Scripts.UI.HUD")
local KeyboardUI = require("Scripts.UI.KeyboardUI")

local Input = require("Scripts.Input")
local PlayerStats = require("Scripts.PlayerStats")
local Timer = require("Scripts.Timer")

local Logger = require("Scripts.Debug.Log")

GameScale = 5

local game = {

    Load = function(self)
        love.math.setRandomSeed(os.time())
        love.graphics.setDefaultFilter("nearest", "nearest")
		love.mouse.setVisible(false)

        Logger:Load()
        KeyboardUI:Load()
		Input:Load()
		HUD:Load(PlayerStats, Flux)
		self.globalTimer = Timer:New()
        
        self.background = Background:New()

        MainMenu:Load(self)
        StreetScene:Load(self, KeyboardUI, Input)
		PerformScene:Load(self, KeyboardUI, Input, HUD, self.globalTimer, Flux)

        Input:AddKeyListener("escape", self, "ExitGame")
        Input:AddKeyListener("f11", self, "SetFullScreen")
        self:OnGameStateChanged(Constants.GameStates.Perform)
        self.fullScreen = false

        --self.effect = moonshine(moonshine.effects.vignette).chain(moonshine.effects.desaturate)
        --.chain(moonshine.effects.glow)

        self.desaturation = 0.5
        self.glow = 5
        Input:AddKeyListener("t", self, "Saturate", "Desaturate")
        Input:AddKeyListener("right", self, "IncreaseOffset")
        Input:AddKeyListener("left", self, "DecreaseOffset")
        Logger:Log("Test Log")
		self.nextFixedUpdate = 0
		self.lastFixedUpdate = 0
		self.fixedUpdateStep = 1/60
    end,

    Update = function(self, dt)
		Flux.update(dt)
        KeyboardUI:Update(Flux, dt)
		self.globalTimer:Update(dt)
        --HUD:Update()
        if self.gameState == Constants.GameStates.MainMenu then
            MainMenu:Update(dt)
            return
        elseif self.gameState == Constants.GameStates.Perform then
			PerformScene:Update(Flux, dt)
        elseif self.gameState == Constants.GameStates.Streets then
            StreetScene:Update(Flux, dt)
            self.background:Update(Flux, dt)
        end
        --self.effect.desaturate.strength = self.desaturation
        --self.effect.glow.strength = self.glow
        Input:Update()

		local currentTime = love.timer.getTime()
		if currentTime >= self.nextFixedUpdate then
			self:FixedUpdate(currentTime - self.lastFixedUpdate)
			self.lastFixedUpdate = currentTime
			self.nextFixedUpdate = currentTime + self.fixedUpdateStep
		end
    end,

	FixedUpdate = function(self, dt)
		if self.gameState == Constants.GameStates.Perform then
			PerformScene:FixedUpdate(dt)
        end
	end,

    Draw = function(self)
        -- self.effect(function()

        -- end)
		if self.gameState == Constants.GameStates.MainMenu then
			MainMenu:Draw()
		elseif self.gameState == Constants.GameStates.Perform then
			--self.background:Draw()
			PerformScene:Draw()
            HUD:Draw()
		elseif self.gameState == Constants.GameStates.Streets then
			self.background:Draw()
			StreetScene:Draw()
		end
        KeyboardUI:Draw()
    end,

	LateDraw = function(self)
        if self.gameState == Constants.GameStates.Perform then
            PerformScene:LateDraw()
        end
	end,

    OnGameStateChanged = function(self, newState)
        -- Handle Previous state
        if self.gameState == Constants.GameStates.Perform then
            PerformScene:OnStop()
        elseif self.gameState == Constants.GameStates.Streets then
            StreetScene:OnStop()
        end

        -- Change state
        self.gameState = newState

        -- New state
        if newState == Constants.GameStates.Perform then
            PerformScene:OnStart()
        elseif newState == Constants.GameStates.Streets then
            StreetScene:OnStart()
        end
    end,

    ExitGame = function(self)
        love.window.close()
    end,

    SetFullScreen = function(self)
        self.fullScreen = not self.fullScreen
        love.window.setFullscreen(self.fullScreen, "desktop")
    end,

    Desaturate = function(self)
        Flux.to(self, 1, { desaturation = 0.5 })
        Flux.to(self, 1, { glow = 0 })
    end,

    Saturate = function(self)
        Flux.to(self, 1, { desaturation = 0 })
        Flux.to(self, 1, { glow = 5 })
    end,

    IncreaseOffset = function(self)
        Flux.to(HUD, 1, { routineOffset = HUD.routineOffset - 150 })
    end,

    DecreaseOffset = function(self)
        Flux.to(HUD, 1, { routineOffset = HUD.routineOffset + 150 })

    end,
}
return game