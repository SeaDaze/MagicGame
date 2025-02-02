
local shadowshader = love.graphics.newShader [[
	vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
		vec4 pixel = Texel(texture, texCoords);  // Get pixel from texture
		if (pixel.a > 0.0) {  // Only modify non-transparent pixels
			return vec4(0.0, 0.0, 0.0, 0.2);  // Force white color and 0.2 alpha
		}
		return pixel;  // Keep fully transparent pixels as they are
	}
]]

local rotateShader = love.graphics.newShader[[
	extern number angle;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		float xOffset = cos(angle) * 0.5 + 0.5;
		texture_coords.x = mix(0.5, texture_coords.x, xOffset);
		return Texel(texture, texture_coords) * color;
	}
]]

local Common = require("Scripts.Common")
local Log = require("Scripts.Debug.Log")

local TestEnvironment = {

	Load = function(self)
		love.graphics.setDefaultFilter("nearest", "nearest")
		self.faceDownDrawable = love.graphics.newImage("Images/Cards/cardBack_03.png")
		self.canvas = love.graphics.newCanvas()
		self.angle = 0
		self.maxDepth = 50
		io.open("MagicGame.log","w"):close()
		Log.outfile = "MagicGame.log"
	end,

	Update = function(self, dt)
		self.angle = self.angle + dt
	end,

	Draw = function(self)
		local scale = 5
		local w, h = self.faceDownDrawable:getWidth(), self.faceDownDrawable:getHeight()
		local ox, oy = -(w * 0.5), -(h * 0.5)
		local cx, cy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
		local mx, my = love.mouse.getX(), love.mouse.getY() 
		
		local vec = { x =(mx - cx) /  (w*scale) * 2, y = (my - cy) / (h*scale) * 2 }
		--vec = Common:Normalize(vec)
		Log.Med("Vec=", vec.x, ", ", vec.y)

		vec.x = Common:Clamp(vec.x, -1, 1) * 5
		vec.y = Common:Clamp(vec.y, -1, 1) * 5
		
		-- Define distorted quad
		local vertices = {
			{
				-- top-left corner (red-tinted)
				0, 0, -- position of the vertex
				0, 0, -- texture coordinate at the vertex position
				1, 0, 0, -- color of the vertex
			},
			{
				-- top-right corner (green-tinted)
				w, 0,
				1, 0, -- texture coordinates are in the range of [0, 1]
				0, 1, 0
			},
			{
				-- bottom-right corner (blue-tinted)
				w, h,
				1, 1,
				0, 0, 1
			},
			{
				-- bottom-left corner (yellow-tinted)
				0, h,
				0, 1,
				1, 1, 0
			},
		}

		vertices[1][1] = vertices[1][1] + ox
		vertices[1][2] = vertices[1][2] + oy
		vertices[2][1] = vertices[2][1] + ox
		vertices[2][2] = vertices[2][2] + oy
		vertices[3][1] = vertices[3][1] + ox
		vertices[3][2] = vertices[3][2] + oy
		vertices[4][1] = vertices[4][1] + ox
		vertices[4][2] = vertices[4][2] + oy

		local mesh = love.graphics.newMesh(vertices, "fan")
        mesh:setTexture(self.faceDownDrawable)
		love.graphics.draw(mesh, cx, cy, 0, 5, 5, 0, 0)
	end,

	DrawSetColor = function(self)
		love.graphics.setColor(0, 0, 0, 0.2)
		love.graphics.draw(self.faceDownDrawable, 200, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 300, 200, 0, 6, 6)
		love.graphics.setColor(1, 1, 1, 1)
	end,

	DrawCanvas = function(self)
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.draw(self.faceDownDrawable, 200, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 300, 200, 0, 6, 6)
		love.graphics.setCanvas()

		love.graphics.setColor(0, 0, 0, 0.2)
		love.graphics.draw(self.canvas, 0, 0)

		love.graphics.setColor(1, 1, 1, 1)
	end,

	DrawBlendMode = function(self)
		love.graphics.setBlendMode("replace")  -- Ensures overlapping doesn't add up

		love.graphics.setColor(0, 0, 0, 0.5)  -- All images forced to white with 0.2 alpha
		love.graphics.draw(self.faceDownDrawable, 200, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 300, 200, 0, 6, 6)

		love.graphics.setBlendMode("alpha")  -- Reset to default blending
		love.graphics.setColor(1, 1, 1, 1)  -- Reset color
	end,

	DrawShader = function(self)
		love.graphics.setShader(shadowshader)  -- Apply shadowshader to make all pixels uniform

		love.graphics.draw(self.faceDownDrawable, 200, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 300, 200, 0, 6, 6)
		love.graphics.setShader()  -- Reset shadowshader
	end,

	DrawCanvasWithShader = function(self)
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.draw(self.faceDownDrawable, 200, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 300, 200, 0, 6, 6)
		love.graphics.setCanvas()
		love.graphics.setShader(shadowshader)  -- Apply shadowshader to make all pixels uniform
		love.graphics.draw(self.canvas, 0, 0)
		love.graphics.setShader()
	end,

	DrawCanvasWithShader2 = function(self)
		--love.graphics.setCanvas(self.canvas)
		--love.graphics.clear(0, 0, 0, 0)
		love.graphics.draw(self.faceDownDrawable, 400, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 500, 100, 0, 6, 6)
		love.graphics.draw(self.faceDownDrawable, 400, 200, 0, 6, 6)
		-- love.graphics.setCanvas()
		-- love.graphics.setShader(shadowshader)  -- Apply shadowshader to make all pixels uniform
		-- love.graphics.draw(self.canvas, 0, 0)
		-- love.graphics.setShader()
	end,

}

return TestEnvironment