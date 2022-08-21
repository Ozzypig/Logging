--- Logger:wrap should return functions that emit Debug and Warning logs, respectively.
function test_wrap(Logging)
	local expectedLevel = nil
	local message = "Hello, world"
	local logger = Logging:getLogger("test_wrap")
	logger:addHandler(function (record)
		assert(record.level == expectedLevel, "Expected level " .. expectedLevel .. ", emit level " .. record.level)
	end)
	local print, warn = logger:wrap()
	expectedLevel = Logging.Level.Debug
	print(message)
	expectedLevel = Logging.Level.Warning
	warn(message)
end

return test_wrap
