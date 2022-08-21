--[=[
	@class FuncHandler
	An implementation of [Handler] which wraps a subject function and calls it when
	the handler is emit a [Record]. [Logger:addHandler] automatically creates one
	if you pass it a function.
]=]
local Handler = require(script.Parent)

local FuncHandler = setmetatable({}, { __index = Handler })
FuncHandler.__index = FuncHandler

--[=[
	@prop func (Record) -> ()
	@within FuncHandler
	@since 0.1.0
	The subject function to be called with [Record] as they are emit.
]=]

--[=[
	Creates a new FuncHandler with the given subject function.
	@since 0.1.0
	@param func (Record) -> ()
	@return FuncHandler
]=]
function FuncHandler.new(func)
	assert(typeof(func) == "function", "function expected, got " .. typeof(func))
	local self = setmetatable(Handler.new(), FuncHandler)
	self.func = func
	return self
end

function FuncHandler:__tostring()
	return ("<FuncHandler: %s>"):format(tostring(self.func))
end

--[=[
	Calls the subject function with the given record.
	@since 0.1.0
	@param record Record
]=]
function FuncHandler:emit(record)
	self.func(record)
end

return FuncHandler
