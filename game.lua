-- External Libraries
local Flux = require("Scripts.libraries.flux")
local moonshine = require ("Scripts.libraries.moonshine")

-- Helpers
local Constants = require ("Scripts.Constants")
local Background = require("Scripts.Background")

-- Scenes
local PerformScene = require("Scripts.PerformScene")
local StreetScene = require("Scripts.StreetScene")

local HUD = require("Scripts.UI.HUD")
local KeyboardUI = require("Scripts.UI.KeyboardUI")


local Input = require("Scripts.Input")
local PlayerStats = require("Scripts.PlayerStats")

local game = {

    Load = function(self)
        love.math.setRandomSeed(os.time())
        love.graphics.setDefaultFilter("nearest", "nearest")
		love.mouse.setVisible(false)
        KeyboardUI:Load()
        self.gameState = Constants.GameStates.Streets
        
        self.background = Background:New()

        StreetScene:Load(self, KeyboardUI, Input)
		PerformScene:Load(self, KeyboardUI, Input, HUD)
        HUD:Load(PlayerStats)

        Input:AddKeyListener("escape", self, "ExitGame")
        Input:AddKeyListener("f11", self, "SetFullScreen")
        self:OnGameStateChanged(Constants.GameStates.Perform)
        self.fullScreen = false

        self.effect = moonshine(moonshine.effects.vignette)
        .chain(moonshine.effects.desaturate)
        --.chain(moonshine.effects.glow)

        self.desaturation = 0.5
        self.glow = 5
        Input:AddKeyListener("t", self, "Saturate", "Desaturate")
        Input:AddKeyListener("right", self, "IncreaseOffset")
        Input:AddKeyListener("left", self, "DecreaseOffset")
    end,

    Update = function(self, dt)
		Flux.update(dt)
        KeyboardUI:Update(Flux, dt)
        --HUD:Update()
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Update(dt)
            return
        elseif self.gameState == Constants.GameStates.Perform then
			PerformScene:Update(Flux, dt)
        elseif self.gameState == Constants.GameStates.Streets then
            StreetScene:Update(Flux, dt)
            self.background:Update(Flux, dt)
        end
        self.effect.desaturate.strength = self.desaturation
        --self.effect.glow.strength = self.glow
        Input:Update()
    end,

    Draw = function(self)
        self.effect(function()
            if self.gameState == Constants.GameStates.MainMenu then
                self.mainMenu:Draw()
            elseif self.gameState == Constants.GameStates.Perform then
                --self.background:Draw()
                PerformScene:Draw()
            elseif self.gameState == Constants.GameStates.Streets then
                self.background:Draw()
                StreetScene:Draw()
            end
        end)
        KeyboardUI:Draw()
        HUD:Draw()
    end,

	LateDraw = function(self)
		PerformScene:LateDraw()
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