--[=[
	@class OutputHandler
	An implementation of [Handler] which pipes record messages to either `print` or `warn`, depending
	on the record level ([Level.Warning] and higher will be piped to `warn`).
	[Logging:basicConfig] creates one of these and attaches it to the root logger.
]=]
local Level = require(script.Parent.Parent:WaitForChild("Level"))

local Handler = require(script.Parent)

local OutputHandler = setmetatable({}, { __index = Handler })
OutputHandler.__index = OutputHandler

--[=[
	@since 0.1.0
	Creates a new OutputHandler.
	@return OutputHandler
]=]
function OutputHandler.new()
	local self = setmetatable(Handler.new(), OutputHandler)
	return self
end

function OutputHandler:__tostring()
	return "<OutputHandler>"
end

--[=[
	@since 0.1.0
	Formats the given record using the [Handler.formatter], then passes it to either `print` or
	`warn`, depending on record level ([Level.Warning] and higher will be piped to `warn`).
	@param record Record
]=]
function OutputHandler:emit(record)
	local message = self.formatter:format(record)
	if record.level >= Level.Warning then
		warn(message)
	else
		print(message)
	end
end

return OutputHandler
