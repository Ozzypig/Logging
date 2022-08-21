--- Functions passed to Logger:addHandler should be called.
function test_record_handling(Logging)
	local handled = false
	local message = "Hello, world"
	local logger = Logging:getLogger("test_record_handling")
	logger:addHandler(function(record)
		handled = record:getMessage() == message
	end)
	logger:warning(message)
	assert(handled, "Record should have been handled")
end

return test_record_handling
