local Handler = require(script.Parent)

local FuncHandler = setmetatable({}, {__index = Handler})
FuncHandler.__index = FuncHandler

function FuncHandler.new(func)
	assert(typeof(func) == "function", "function expected, got " .. typeof(func))
	local self = setmetatable(Handler.new(), FuncHandler)
	self.func = func
	return self
end

function FuncHandler:__tostring()
	return ("<FuncHandler: %s>"):format(tostring(self.func))
end

function FuncHandler:emit(record)
	self.func(record)
end

return FuncHandler
