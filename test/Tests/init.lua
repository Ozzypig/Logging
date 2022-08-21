local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logging = require(ReplicatedStorage:WaitForChild("Logging"))
local LoggingClass = Logging.Logging

local Tests = {}
Tests.tests = {}

--- Filters should be used to determine if a record should be handled
function Tests.tests.test_filtering()
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

--- By default, levels lower than Warning should be filtered.
function Tests.tests.test_default_levels()
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

--- Logs which are not of a sufficient level should be filtered
function Tests.tests.test_levels()
	local handled = 0
	local message = "Hello, world"
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local logger = Logging:getLogger("test_levels")
	logger:setLevel(level)
	logger:addHandler(function (_record)
		handled += 1
	end)
	logger:log(levelLower, message)
	assert(handled == 0, "Record should not have been handled")
	logger:log(level, message)
	assert(handled == 1, "Record should have been handled")
end

--- Logger:isEnabledFor should accurately determine whether a logger of a certain level will filter records of another level
function Tests.tests.test_levels_enabled()
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local levelHigher = Logging.Level.Warning

	local logger = Logging:getLogger("test_levels_enabled")
	logger:setLevel(level)
	assert(logger:isEnabledFor(level), "Level should be enabled when set to same level")
	assert(not logger:isEnabledFor(levelLower), "Lower level should not be enabled")
	assert(logger:isEnabledFor(levelHigher), "Higher level should be enabled")
end

--- Logger:isEnabledFor should defer to the parent logger if its log level is NotSet (default).
function Tests.tests.test_levels_heirarchy()
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local levelHigher = Logging.Level.Warning

	local logger = Logging:getLogger("foo")
	local childLogger = logger:getChild("bar")

	logger:setLevel(level)
	assert(childLogger:isEnabledFor(level), "Level should be enabled when set to same level")
	assert(not childLogger:isEnabledFor(levelLower), "Lower level should not be enabled")
	assert(childLogger:isEnabledFor(levelHigher), "Higher level should be enabled")
end

--- Records should format their message properly according to the provided arguments.
function Tests.tests.test_record_message_formatting()
	Logging:addHandler(function (_record) end)

	local logger = Logging:getLogger("test_record_message_formatting")
	local message = "%s 1 %s 2 %d"
	local expected = "A 1 B 2 1337"
	local record = logger:warning(message, "A", "B", 1337)
	local got = record:getMessage()
	assert(got == expected, ("Record message not format properly, expected %q got %q"):format(expected, got))
end

--- Loggers that aren't in a heirarchy should have the root logger as their parent.
function Tests.tests.test_top_level_logger()
	local logger = Logging:getLogger("test_top_level_logger")
	assert(logger.parent == Logging:getRootLogger(), "Parent of plain loggers should be root logger")
end

--- Logging:getLogger should propery create the logger heirarchy.
function Tests.tests.test_logger_heirarchy()
	assert(Logging:getRootLogger() == Logging:getRootLogger(), "Failed root Logger idempotency check")
	assert(Logging:getLogger("foo") == Logging:getLogger("foo"), "Failed Logger idempotency check")
	assert(Logging:getLogger("a.b.c").parent == Logging:getLogger("a.b"), "Failed Logger parent check")
	assert(Logging:getLogger("a.b.c").parent.parent == Logging:getLogger("a"), "Failed Logger grandparent check")
	assert(Logging:getLogger("x.y") == Logging:getLogger("x.y.z").parent, "Failed Logger parent check (reverse)")
	assert(Logging:getLogger("x") == Logging:getLogger("x.y.z").parent.parent, "Failed Logger grandparent check (reverse)")
end

--- Logger:getChild should propery create the logger heirarchy.
function Tests.tests.test_logger_getChild()
	assert(Logging:getRootLogger():getChild("baz") == Logging:getLogger("baz"), "Failed Logger idempotency check (getChild)")
	assert(Logging:getLogger("spam"):getChild("eggs") == Logging:getLogger("spam.eggs"), "Failed Logger:getChild")
	assert(Logging:getLogger("a.b"):getChild("c").parent == Logging:getLogger("a.b"), "Failed Logger parent check (getChild)")
	assert(Logging:getLogger("a"):getChild("b"):getChild("c").parent.parent == Logging:getLogger("a"), "Failed Logger grandparent check (getChild)")
	assert(Logging:getLogger("x.y") == Logging:getLogger("x.y"):getChild("z").parent, "Failed Logger parent check (reverse) (getChild)")
	assert(Logging:getLogger("x") == Logging:getLogger("x"):getChild("y"):getChild("z").parent.parent, "Failed Logger grandparent check (reverse) (getChild)")
end

-- Logger:getFullName should encorporate all ancestor names, except the root logger.
function Tests.tests.test_logger_getFullName()
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

--- Logging module should expose various root logger methods.
function Tests.tests.test_module_level_methods()
	local handled = 0
	local message = "Hello, world"
	Logging:addHandler(function (_record)
		handled += 1
	end)
	Logging:warning(message)
	assert(handled == 1, "Record should have been handled")
	Logging:getRootLogger():warning(message)
	assert(handled == 2, "Record should have been handled")
end

--- Functions passed to Logger:addHandler should be called.
function Tests.tests.test_record_handling()
	local handled = false
	local message = "Hello, world"
	local logger = Logging:getLogger("test_record_handling")
	logger:addHandler(function (record)
		handled = record:getMessage() == message
	end)
	logger:warning(message)
	assert(handled, "Record should have been handled")
end

--- Loggers without handlers should propagate to the parent logger.
function Tests.tests.test_propagation()
	local handled = 0
	local message = "Hello, world"
	local level = Logging.Level.Info
	local levelLower = Logging.Level.Debug
	local logger = Logging:getLogger("tests_propagation")
	local childLogger = logger:getChild("child")
	logger:setLevel(levelLower)
	logger:addHandler(function (_record)
		handled += 1
	end)
	childLogger:log(level, message)
	assert(handled == 1, "Record emission did not propagate")
end

--- Logger:wrap should return functions that emit Debug and Warning logs, respectively.
function Tests.tests.test_wrap()
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

local function compare(t0, t1)
	for k, v in pairs(t0) do
		if v ~= t1[k] then
			return false, k
		end
	end
	for k, v in pairs(t1) do
		if v ~= t0[k] then
			return false, k
		end
	end
	return true, nil
end

local function assertCompare(m, t0, t1)
	assert(typeof(m) == "string", "string expected")
	assert(typeof(t0) == "table", "table expected")
	assert(typeof(t1) == "table", "table expected")
	local areSame, k = compare(t0, t1)
	assert(areSame, ("%s (key = %s: %s, %s)"):format(m, tostring(k), tostring(t0[k]), tostring(t1[k])))
end

local function matchEnd(haystack, needle)
	return haystack:sub(haystack:len() - needle:len() + 1, haystack:len()) == needle
end

--- Logger:pcall and Logger:xpcall should emit Warning when given function errors and work like their wrapped counterparts.
function Tests.tests.test_pcall()
	local logger = Logging:getLogger("test_pcall")
	local expectedLevel = Logging.Logger.pcallLevel
	logger:addHandler(function (record)
		assert(record.level == expectedLevel, ("Expected level %s, emit level %s"):format(expectedLevel, record.level))
	end)

	local expectedCallValues = {"hello", 1337, true, {}, setmetatable({}, {})}
	local expectedReturnValues = {"goodbye", 42, false, {}, setmetatable({}, {})}
	local actualReturnValues = nil
	local errorMessage = "Fail whale"

	-- case 1: no error
	local function pcallCheckValues(...)
		assertCompare("Values passed do not match", expectedCallValues, {...})
		return unpack(expectedReturnValues)
	end
	actualReturnValues = {logger:pcall(pcallCheckValues, unpack(expectedCallValues))}
	assert(actualReturnValues[1], "Logger:pcall should return true if the function runs without error: " .. tostring(actualReturnValues[2]))
	assertCompare("Logger:pcall return values do not match", expectedReturnValues, {select(2, unpack(actualReturnValues))})
	
	-- case 2: error
	local function failWhale()
		error(errorMessage)
	end
	actualReturnValues = {logger:pcall(failWhale)}
	assert(not actualReturnValues[1], "Logger:pcall should return false if the function raises an error")
	assert(matchEnd(actualReturnValues[2], errorMessage), ("Logger:pcall should return the error when the function raises one, expected %q got %q"):format(actualReturnValues[2], errorMessage))
end

--- Logger:xpcall should emit Warning when given function errors and work like their wrapped counterparts.
function Tests.tests.test_xpcall()
	local logger = Logging:getLogger("test_xpcall")
	local expectedLevel = Logging.Logger.pcallLevel
	logger:addHandler(function (record)
		assert(record.level == expectedLevel, ("Expected level %s, emit level %s"):format(expectedLevel, record.level))
	end)

	local expectedCallValues = {"hello", 1337, true, {}, setmetatable({}, {})}
	local expectedReturnValues = {"goodbye", 42, false, {}, setmetatable({}, {})}
	local expectedErrorReturnValue = "thisIsMyError"
	local actualReturnValues = nil
	local errorMessage = "Fail whale"
	
	local errorActual = nil
	local errorHandlerCalled = false
	local function xpcallErrorHandler(err)
		errorHandlerCalled = true
		errorActual = err
		return expectedErrorReturnValue
	end

	-- case 1: no error
	local function xpcallCheckValues(...)
		assertCompare("Values passed do not match", expectedCallValues, {...})
		return unpack(expectedReturnValues)
	end
	actualReturnValues = {logger:xpcall(xpcallCheckValues, xpcallErrorHandler, unpack(expectedCallValues))}
	assert(actualReturnValues[1], "Logger:xpcall should return true if the function runs without error: " .. tostring(errorActual))
	assert(not errorHandlerCalled, "Logger:xpcall should not call the error handler if the function runs without error")
	assertCompare("Logger xpcall return values do not match", expectedReturnValues, {select(2, unpack(actualReturnValues))})

	-- case 2: error
	local function failWhale()
		error(errorMessage)
	end
	actualReturnValues = {logger:xpcall(failWhale, xpcallErrorHandler)}
	assert(not actualReturnValues[1], "Logger:xpcall should return false if the function raises an error")
	assert(errorHandlerCalled, "Logger:xpcall should call the error handler if the function runs raises an error")
	assert(matchEnd(errorActual, errorMessage), ("Logger:xpcall should call the error handler with the error message if the function raises an error, expected %q, got %q"):format(errorMessage, errorActual))
	assert(actualReturnValues[2] == expectedErrorReturnValue, "Logger:xpcall should return the value returned by the error handler if the function raises an error")
end

-- asctime should format properly.
function Tests.tests.test_asctime()
	local timestamp = 1650430672 -- April 20th, 2022 at 12:57:52 AM
	assert(os.date(Logging.Formatter.ASCTIME_FORMAT, timestamp) == "2022-04-20 12:57:52", "asctime format is incorrect")
end

-- Formatter format properly.
function Tests.tests.test_formatter()
	local message = "Hello, world"
	local name = "test_formatter"

	local logger = Logging:getLogger(name)
	logger:addHandler(function () end)
	assert(Logging.Formatter.new():format(logger:debug(message)) == message, "Default formatter should format the message by itself")
	assert(Logging.Formatter.new("%(message)s"):format(logger:debug(message)) == message, "Formatter did not format %(message)s properly")
	assert(Logging.Formatter.new("%(name)s"):format(logger:debug(message)) == name, "Formatter did not format %(name)s properly")
	assert(Logging.Formatter.new("%(asctime)s"):format(logger:debug(message)) == os.date(Logging.Formatter.ASCTIME_FORMAT, os.time()), "Formatter did not format %(asctime)s properly")
end

-- MemoryHandler should work properly.
function Tests.tests.test_MemoryHandler()
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
	memoryHandler:setTarget(Logging.FuncHandler.new(function (_record)
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

local HR = ("-"):rep(15)
local UNICORN = [[
                    /
               ,.. /
             ,'   ';
  ,,.__    _,' /';  .
 :','  ~~~~    '. '~
:' (   )         )::,
'. '. .=----=..-~  .;'
 '  ;'  ::   ':.  '"
   (:   ':    ;)
    \\   '"  ./
     '"      '"]]
function Tests.run()
	local passed, total = 0, 0
	for name, test in pairs(Tests.tests) do
		print(("%s %s"):format(HR, name))
		-- Re-create Logging module before each test
		Logging = LoggingClass.new()

		total += 1
		local success, err = pcall(test)
		if success then
			print(("PASS: %s"):format(name))
			passed += 1
		else
			warn(("FAIL: %s\n%s"):format(name, err))
		end
	end
	print(("%s\nRESULTS: %d / %d%s"):format(HR, passed, total, passed ~= total and "" or "\n" .. UNICORN))
end

return Tests
