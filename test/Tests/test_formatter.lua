-- Formatter format properly.
function test_formatter(Logging)
	local message = "Hello, world"
	local name = "test_formatter"

	local logger = Logging:getLogger(name)
	logger:addHandler(function() end)
	assert(
		Logging.Formatter.new():format(logger:debug(message)) == message,
		"Default formatter should format the message by itself"
	)
	assert(
		Logging.Formatter.new("%(message)s"):format(logger:debug(message)) == message,
		"Formatter did not format %(message)s properly"
	)
	assert(
		Logging.Formatter.new("%(name)s"):format(logger:debug(message)) == name,
		"Formatter did not format %(name)s properly"
	)
	assert(
		Logging.Formatter.new("%(asctime)s"):format(logger:debug(message))
			== os.date(Logging.Formatter.ASCTIME_FORMAT, os.time()),
		"Formatter did not format %(asctime)s properly"
	)
end

return test_formatter
