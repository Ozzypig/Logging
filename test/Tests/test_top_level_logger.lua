--- Loggers that aren't in a heirarchy should have the root logger as their parent.
function test_top_level_logger(Logging)
	local logger = Logging:getLogger("test_top_level_logger")
	assert(logger.parent == Logging:getRootLogger(), "Parent of plain loggers should be root logger")
end

return test_top_level_logger
