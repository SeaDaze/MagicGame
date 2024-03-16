local CardSpread = {
    Update = function(self, dt)

    end,

    Draw = function(self)
    end,
}

CardSpread.__index = CardSpread
CardSpread.New = function()
    local instance = setmetatable({}, CardSpread)

    return instance
end
return CardSpread