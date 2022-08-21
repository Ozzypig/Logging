--- Records should format their message properly according to the provided arguments.
function test_record_message_formatting(Logging)
	Logging:addHandler(function (_record) end)

	local logger = Logging:getLogger("test_record_message_formatting")
	local message = "%s 1 %s 2 %d"
	local expected = "A 1 B 2 1337"
	local record = logger:warning(message, "A", "B", 1337)
	local got = record:getMessage()
	assert(got == expected, ("Record message not format properly, expected %q got %q"):format(expected, got))
end

return test_record_message_formatting
