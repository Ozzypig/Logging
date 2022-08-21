-- Logger:getFullName should encorporate all ancestor names, except the root logger.
function test_logger_getFullName(Logging)
	local function assertFullName(logger, expectedFullName)
		local actualFullName = logger:getFullName()
		assert(actualFullName == expectedFullName, ("Expected %q, got %q"):format(expectedFullName, actualFullName))
	end
	assertFullName(Logging:getRootLogger(), "Logging")
	assertFullName(Logging:getLogger("a"), "a")
	assertFullName(Logging:getLogger("a.b"), "a.b")
	assertFullName(Logging:getLogger("a.b.c"), "a.b.c")
	assertFullName(Logging:getLogger("x"):getChild("y"), "x.y")
	assertFullName(Logging:getLogger("x"):getChild("y"):getChild("z"), "x.y.z")
end

return test_logger_getFullName
