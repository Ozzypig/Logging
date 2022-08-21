--- Logging module should expose various root logger methods.
function test_module_level_methods(Logging)
	local handled = 0
	local message = "Hello, world"
	Logging:addHandler(function(_record)
		handled += 1
	end)
	Logging:warning(message)
	assert(handled == 1, "Record should have been handled")
	Logging:getRootLogger():warning(message)
	assert(handled == 2, "Record should have been handled")
end

return test_module_level_methods
