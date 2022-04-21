local Level = require(script.Parent:WaitForChild("Level"))
local Formatter = require(script.Parent:WaitForChild("Formatter"))

local Handler = {}
Handler.__index = Handler
Handler.formatter = Formatter.new()

function Handler.new()
	local self = setmetatable({
		filters = {};
		level = Level.NotSet;
		formatter = nil;
	}, Handler)
	return self
end

function Handler:__tostring()
	return "<Handler>"
end

function Handler:setLevel(level)
	self.level = level
end

function Handler:addFilter(filter)
	assert(typeof(filter) == "function", "filter must be a function, got " .. typeof(filter))
	self.filters[filter] = filter
end

function Handler:removeFilter(filter)
	self.filters[filter] = nil
end

function Handler:filter(record)
	if self.level > record.level then
		--print(("Handler filtered on level (%d < %d)"):format(self.level, record.level))
		return false
	end
	for filter in pairs(self.filters) do
		if not filter(self, record) then
			--print("Handler filter", filter)
			return false
		end
	end
	return true
end

function Handler:setFormatter(formatter)
	self.formatter = formatter
end

function Handler:handle(record)
	if self:filter(record) then
		self:emit(record)
	end
end
Handler.__call = Handler.handle

function Handler:emit(_record)
	error("Handler:emit is abstract")
end

function Handler:flush()
	-- abstract, no-op
end

function Handler:close()
	-- abstract, no-op
end

return Handler
