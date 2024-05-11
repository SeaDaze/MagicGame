
local Logger = 
{
    Load = function(self)
        local success, message = love.filesystem.write("MagicGame.log", "Initialising Logger")
        if success then 
            print ("Log file created")
        else 
            print ("Log file not created: " .. message)
        end
    end,

    Log = function(self, message)
        local currentTime = os.date("%X", os.time())
        love.filesystem.append("MagicGame.log", "\n[".. currentTime .. "] " .. message)
    end,
}

return Logger