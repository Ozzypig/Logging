--[=[
	@class NullHandler
	An implementation of [Handler] which does nothing with [Record]s.
	Modules may elect to disable [Logger.propagate] to prevent logs
	from bubbling up to the root logger. In this case, to avoid an
	"unhandled log" warning, add a NullHandler.
]=]
local Handler = require(script.Parent)

local NullHandler = setmetatable({}, {__index = Handler})
NullHandler.__index = NullHandler

--[=[
	@since 0.1.0
	Creates a NullHandler.
	@return NullHandler
]=]
function NullHandler.new()
	local self = setmetatable(Handler.new(), NullHandler)
	return self
end

function NullHandler:__tostring()
	return "<NullHandler>"
end

--[=[
	@since 0.1.0
	Does nothing except give you an overwhelming feeling that everything is going to be OK.
	@param _record Record
]=]
function NullHandler:emit(_record)
	-- no-op
end

return NullHandler
