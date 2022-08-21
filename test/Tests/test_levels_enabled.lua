--- Logger:isEnabledFor should accurately determine whether a logger of a certain level will filter records of another level
function test_levels_enabled(Logging)
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local levelHigher = Logging.Level.Warning

	local logger = Logging:getLogger("test_levels_enabled")
	logger:setLevel(level)
	assert(logger:isEnabledFor(level), "Level should be enabled when set to same level")
	assert(not logger:isEnabledFor(levelLower), "Lower level should not be enabled")
	assert(logger:isEnabledFor(levelHigher), "Higher level should be enabled")
end

return test_levels_enabled
