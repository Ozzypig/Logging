local Handler = require(script.Parent)

local NullHandler = setmetatable({}, {__index = Handler})
NullHandler.__index = NullHandler

function NullHandler.new()
	local self = setmetatable(Handler.new(), NullHandler)
	return self
end

function NullHandler:__tostring()
	return "<NullHandler>"
end

function NullHandler:emit(_record)
	-- no-op
end

return NullHandler
