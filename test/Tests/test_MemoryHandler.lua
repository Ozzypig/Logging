-- MemoryHandler should work properly.
function test_MemoryHandler(Logging)
	local logger = Logging:getLogger("test_MemoryHandler")
	local capacity = 5
	local memoryHandler = Logging.MemoryHandler.new(capacity)
	logger:setLevel(Logging.Level.Debug)
	logger:addHandler(memoryHandler)
	assert(logger.handlers[memoryHandler], "MemoryHandler was not added")
	assert(memoryHandler:size() == 0, "MemoryHandler did not start empty (size)")
	assert(memoryHandler:space() == capacity, "MemoryHandler did not start empty (space)")
	for i = 1, capacity - 1 do
		local record = logger:debug("Log %d of %d", i, capacity)
		assert(memoryHandler:getLastRecord() == record, "MemoryHandler did not buffer the Record")
		assert(memoryHandler:size() == i, "MemoryHandler:size incorrect")
		assert(memoryHandler:space() == capacity - i, "MemoryHandler:space incorrect")
	end
	logger:debug("This log causes the MemoryHandler buffer to reach capacity and be flushed!")
	assert(memoryHandler:size() == 0, "MemoryHandler did not flush after reaching capacity")
	logger:error("By default, errors should cause the MemoryHandler to flush immediately")
	assert(memoryHandler:size() == 0, "MemoryHandler did not flush after error")
	-- target handler
	local targetHandled = 0
	memoryHandler:setTarget(Logging.FuncHandler.new(function(_record)
		targetHandled += 1
	end))
	for i = 1, capacity - 1 do
		logger:debug("Log %d of %d", i, capacity)
		assert(targetHandled == 0, "MemoryHandler should not yet pass records to target handler yet")
	end
	logger:debug("Flush time")
	assert(targetHandled == capacity, "MemoryHandler should have passed records to target handler")
	targetHandled = 0
	logger:error("Flush immediately like last time, target should handle this")
	assert(targetHandled == 1, "MemoryHandler should've passed record immediately")
end

return test_MemoryHandler
