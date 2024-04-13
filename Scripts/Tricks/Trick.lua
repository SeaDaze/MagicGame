local Technique = 
{
    GetScore = function(self)
        return self.score or 0
    end,

    OnStart = function(self)
    end,

    Update = function(self, Flux, dt)
    end,

    OnFinish = function(self)
    end,
}

Technique.__index = Technique
return Technique