local test = 
{
    DrawTest = function(self)
        love.graphics.print("Hello World", 400, 300)
        love.graphics.circle("fill", 200, 200, 50)
        love.graphics.circle("fill", 400, 200, 50)
    end,
}
return test