
local AudioSystem = 
{
	-- ===========================================================================================================
	-- #region [CORE]
	-- ===========================================================================================================

	Load = function(self)
		self.createdAudioSources = {}
	end,

	CreateAudioSource = function(self, filename)
		return love.audio.newSource(filename, "static")
	end,

	GetAudioSourceClone = function(self, filename)
		if not self.createdAudioSources[filename] then
			self.createdAudioSources[filename] = self:CreateAudioSource(filename)
		end
		return self.createdAudioSources[filename]:clone()
	end,

	PlaySound = function(self, audioSource)
		-- if audioSource:isPlaying() then
		-- 	audioSource:stop()
		-- end
		audioSource:play()
	end,

	-- ===========================================================================================================
	-- #region [EXTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [INTERNAL]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #region [PUBLICHELPERS]
	-- ===========================================================================================================
	-- ===========================================================================================================
	-- #endregion
}
return AudioSystem