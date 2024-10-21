-- Globals (because I'm lazy and no one can stop me)
GameSettings = require("Scripts.Config.GameSettings")
GameConstants = require("Scripts.Config.GameConstants")
Input = require("Scripts.Input")
Timer = require("Scripts.Timer")
HUD = require("Scripts.UI.HUD")
Common = require("Scripts.Common")

-- External Libraries
Flux = require("Scripts.libraries.flux")
local moonshine = require ("Scripts.libraries.moonshine")

-- Modals
SettingsMenu = require("Scripts.UI.SettingsMenu")

-- Scenes
local PerformScene = require("Scripts.PerformScene")
local MainMenu = require("Scripts.UI.MainMenu")
local ShopScene = require("Scripts.Scenes.ShopScene")

local PlayerStats = require("Scripts.PlayerStats")
local Logger = require("Scripts.Debug.Log")

local game = {

    Load = function(self)
        love.math.setRandomSeed(os.time())
        love.graphics.setDefaultFilter("nearest", "nearest")
		love.mouse.setVisible(true)

        Logger:Load()
		Input:Load()
		HUD:Load(PlayerStats)
        SettingsMenu:Load()
        Timer:Load()
        MainMenu:Load()
		PerformScene:Load()

        self.gameScenes =
        {
            [GameConstants.GameStates.MainMenu] = MainMenu,
            [GameConstants.GameStates.Perform] = PerformScene,
            [GameConstants.GameStates.Shop] = ShopScene,
        }

        self:SetGameState(GameConstants.GameStates.Perform)

		self.nextFixedUpdate = 0
		self.lastFixedUpdate = 0
		self.fixedUpdateStep = 1/60
    end,

    Update = function(self, dt)
        Input:Update()
        SettingsMenu:Update(dt)

        if SettingsMenu:GetActive() then
            return
        end

		Flux.update(dt)
		Timer:Update(dt)

        local gameScene = self:GetCurrentGameScene()
		if gameScene.Update then
			gameScene:Update(dt)
        end

		local currentTime = love.timer.getTime()
		if currentTime >= self.nextFixedUpdate then
			self:FixedUpdate(currentTime - self.lastFixedUpdate)
			self.lastFixedUpdate = currentTime
			self.nextFixedUpdate = currentTime + self.fixedUpdateStep
		end

    end,

	FixedUpdate = function(self, dt)
        local gameScene = self:GetCurrentGameScene()
		if gameScene.FixedUpdate then
			gameScene:FixedUpdate(dt)
        end
	end,

    Draw = function(self)
		self.gameScenes[self.gameState]:Draw()
    end,

	LateDraw = function(self)
        if self.gameState == GameConstants.GameStates.Perform then
            PerformScene:LateDraw()
        end
        SettingsMenu:Draw()
	end,

    GetCurrentGameScene = function(self)
        return self.gameScenes[self.gameState]
    end,

    SetGameState = function(self, newState)
        if self.gameScenes[self.gameState] then
            self.gameScenes[self.gameState]:OnStop()
            Common.UnhookFunction(
                self.gameScenes[self.gameState],
                "OnRequestGameStateChange",
                self.gameStateChangeHookId
            )
        end

        self.gameScenes[newState]:OnStart()
        self.gameStateChangeHookId = Common.HookFunction(
            self.gameScenes[newState],
            "OnRequestGameStateChange",
            function(params)
                self:SetGameState(params.newState)
            end
        )
        self.gameState = newState
    end,

    ExitGame = function(self)
        love.window.close()
    end,
}
return game