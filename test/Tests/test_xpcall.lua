local util = require(script.Parent.Parent:WaitForChild("util"))

--- Logger:xpcall should emit Warning when given function errors and work like their wrapped counterparts.
function test_xpcall(Logging)
	local logger = Logging:getLogger("test_xpcall")
	local expectedLevel = Logging.Logger.pcallLevel
	logger:addHandler(function(record)
		assert(record.level == expectedLevel, ("Expected level %s, emit level %s"):format(expectedLevel, record.level))
	end)

	local expectedCallValues = { "hello", 1337, true, {}, setmetatable({}, {}) }
	local expectedReturnValues = { "goodbye", 42, false, {}, setmetatable({}, {}) }
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
		util.assertCompare("Values passed do not match", expectedCallValues, { ... })
		return unpack(expectedReturnValues)
	end
	actualReturnValues = { logger:xpcall(xpcallCheckValues, xpcallErrorHandler, unpack(expectedCallValues)) }
	assert(
		actualReturnValues[1],
		"Logger:xpcall should return true if the function runs without error: " .. tostring(errorActual)
	)
	assert(not errorHandlerCalled, "Logger:xpcall should not call the error handler if the function runs without error")
	util.assertCompare(
		"Logger xpcall return values do not match",
		expectedReturnValues,
		{ select(2, unpack(actualReturnValues)) }
	)

	-- case 2: error
	local function failWhale()
		error(errorMessage)
	end
	actualReturnValues = { logger:xpcall(failWhale, xpcallErrorHandler) }
	assert(not actualReturnValues[1], "Logger:xpcall should return false if the function raises an error")
	assert(errorHandlerCalled, "Logger:xpcall should call the error handler if the function runs raises an error")
	assert(
		util.matchEnd(errorActual, errorMessage),
		(
			"Logger:xpcall should call the error handler with the error message if the function raises an error, expected %q, got %q"
		):format(errorMessage, errorActual)
	)
	assert(
		actualReturnValues[2] == expectedErrorReturnValue,
		"Logger:xpcall should return the value returned by the error handler if the function raises an error"
	)
end

return test_xpcall
