--- Loggers without handlers should propagate to the parent logger.
function test_propagation(Logging)
	local handled = 0
	local message = "Hello, world"
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local logger = Logging:getLogger("tests_propagation")
	local childLogger = logger:getChild("child")
	logger:setLevel(levelLower)
	logger:addHandler(function(_record)
		handled += 1
	end)
	childLogger:log(level, message)
	assert(handled == 1, "Record emission did not propagate")
end

return test_propagation
