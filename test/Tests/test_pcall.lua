local util = require(script.Parent.Parent:WaitForChild("util"))

--- Logger:pcall and Logger:xpcall should emit Warning when given function errors and work like their wrapped counterparts.
function test_pcall(Logging)
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
		util.assertCompare("Values passed do not match", expectedCallValues, {...})
		return unpack(expectedReturnValues)
	end
	actualReturnValues = {logger:pcall(pcallCheckValues, unpack(expectedCallValues))}
	assert(actualReturnValues[1], "Logger:pcall should return true if the function runs without error: " .. tostring(actualReturnValues[2]))
	util.assertCompare("Logger:pcall return values do not match", expectedReturnValues, {select(2, unpack(actualReturnValues))})
	
	-- case 2: error
	local function failWhale()
		error(errorMessage)
	end
	actualReturnValues = {logger:pcall(failWhale)}
	assert(not actualReturnValues[1], "Logger:pcall should return false if the function raises an error")
	assert(util.matchEnd(actualReturnValues[2], errorMessage), ("Logger:pcall should return the error when the function raises one, expected %q got %q"):format(actualReturnValues[2], errorMessage))
end

return test_pcall
