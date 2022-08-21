--- Filters should be used to determine if a record should be handled
function test_filtering(Logging)
	local handled = 0
	local message = "Hello, world"
	local logger = Logging:getLogger("test_filtering")
	logger:addHandler(function (_record)
		handled += 1
	end)
	logger:addFilter(function (_logger, record)
		return record:getMessage() == message
	end)
	logger:warning("Goodbye, world")
	assert(handled == 0, "Record should not have been handled")
	logger:warning(message)
	assert(handled == 1, "Record should have been handled")
end

return test_filtering
