local Level = require(script.Parent.Parent:WaitForChild("Level"))

local Handler = require(script.Parent)

local OutputHandler = setmetatable({}, {__index = Handler})
OutputHandler.__index = OutputHandler

function OutputHandler.new()
	local self = setmetatable(Handler.new(), OutputHandler)
	return self
end

function OutputHandler:__tostring()
	return "<OutputHandler>"
end

function OutputHandler:emit(record)
	local message = self.formatter:format(record)
	if record.level >= Level.Warning then
		warn(message)
	else
		print(message)
	end
end

return OutputHandler
