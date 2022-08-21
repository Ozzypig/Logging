--- By default, levels lower than Warning should be filtered.
function test_default_levels(Logging)
	local handled = 0
	local message = "Hello, world"
	local logger = Logging:getLogger("test_default_levels")
	logger:addHandler(function (_record)
		handled += 1
	end)
	logger:debug(message)
	assert(handled == 0, "Record should not have been handled")
	logger:info(message)
	assert(handled == 0, "Record should not have been handled")
	logger:warning(message)
	assert(handled == 1, "Record should have been handled")
	logger:error(message)
	assert(handled == 2, "Record should have been handled")
	logger:critical(message)
	assert(handled == 3, "Record should have been handled")
end

return test_default_levels
