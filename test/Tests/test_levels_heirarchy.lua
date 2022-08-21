--- Logger:isEnabledFor should defer to the parent logger if its log level is NotSet (default).
function test_levels_heirarchy(Logging)
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local levelHigher = Logging.Level.Warning

	local logger = Logging:getLogger("foo")
	local childLogger = logger:getChild("bar")

	logger:setLevel(level)
	assert(childLogger:isEnabledFor(level), "Level should be enabled when set to same level")
	assert(not childLogger:isEnabledFor(levelLower), "Lower level should not be enabled")
	assert(childLogger:isEnabledFor(levelHigher), "Higher level should be enabled")
end

return test_levels_heirarchy
