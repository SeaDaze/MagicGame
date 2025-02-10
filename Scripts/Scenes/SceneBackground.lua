local Vector3 = require("Scripts.System.Vector3")

local SceneBackground = 
{
    Load = function(self)
        self.sprites = 
        {
            {
                sprite = Sprite:New(
                    love.graphics.newImage("Images/Background/BlocksBackground4.png"),
                    { x = 0, y = 0, z = 0 },
                    0,
                    1,
                    DrawLayers.Background,
                    true,
                    { x = 0, y = 0 }
                ),
                movementScale = 1,
            },
            {
                sprite = Sprite:New(
                    love.graphics.newImage("Images/Background/BlocksBackground3.png"),
                    { x = 0, y = 0, z = 0 },
                    0,
                    1,
                    DrawLayers.Background,
                    true,
                    { x = 0, y = 0 }
                ),
                movementScale = 5,
            },
            {
                sprite = Sprite:New(
                    love.graphics.newImage("Images/Background/BlocksBackground2.png"),
                    { x = 0, y = 0, z = 0 },
                    0,
                    1,
                    DrawLayers.Background,
                    true,
                    { x = 0, y = 0 }
                ),
                movementScale = 20,
            },
            {
                sprite = Sprite:New(
                    love.graphics.newImage("Images/Background/BlocksBackground1.png"),
                    { x = 0, y = 0, z = 0 },
                    0,
                    1,
                    DrawLayers.Background,
                    true,
                    { x = 0, y = 0 }
                ),
                movementScale = 50,
            },
        }
        for index, imageData in ipairs(self.sprites) do
            DrawSystem:AddDrawable(imageData.sprite)
        end
    end,

    FixedUpdate = function(self, dt)
		-- local w, h = love.graphics.getWidth(), love.graphics.getHeight()
		-- local cx, cy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
		-- local mx, my = love.mouse.getX(), love.mouse.getY() 

		-- local vec = Vector3:New(((mx - cx) /  (w) * 2), 0, 0)
        -- for index, imageData in pairs(self.sprites) do
        --     imageData.sprite:SetPosition(vec * imageData.movementScale)
        -- end
    end,
}
return SceneBackground