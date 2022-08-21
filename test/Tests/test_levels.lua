--- Logs which are not of a sufficient level should be filtered
function test_levels(Logging)
	local handled = 0
	local message = "Hello, world"
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local logger = Logging:getLogger("test_levels")
	logger:setLevel(level)
	logger:addHandler(function(_record)
		handled += 1
	end)
	logger:log(levelLower, message)
	assert(handled == 0, "Record should not have been handled")
	logger:log(level, message)
	assert(handled == 1, "Record should have been handled")
end

return test_levels
