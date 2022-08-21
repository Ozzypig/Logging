-- asctime should format properly.
function test_asctime(Logging)
	local timestamp = 1650430672 -- April 20th, 2022 at 12:57:52 AM
	assert(os.date(Logging.Formatter.ASCTIME_FORMAT, timestamp) == "2022-04-20 12:57:52", "asctime format is incorrect")
end

return test_asctime
