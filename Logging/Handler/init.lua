--[=[
	@class Handler
	Abstractor processor of [Record]s. Like [Logger]s, it can also have its own level and filters.
]=]

local Level = require(script.Parent:WaitForChild("Level"))
local Formatter = require(script.Parent:WaitForChild("Formatter"))

local Handler = {}
Handler.__index = Handler
Handler.formatter = Formatter.new()

--[=[
	@prop filters table
	@within Handler
	@tag Filtering
	@since 0.1.0
	A set of [Filter]s added to this handler with [Handler:addFilter]
]=]

--[=[
	@prop level Level
	@within Handler
	@tag Filtering
	@since 0.1.0
	Set the lowest level of [Record]s that this handler will handle.
]=]

--[=[
	@prop formatter Formatter
	@within Handler
	@since 0.1.0
	The formatter to use when processing messages produced by [Record]s.
]=]

--[=[
	@since 0.1.0
	Abstract. Creates a new handler.
	@return Handler
]=]
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

--[=[
	@since 0.1.0
	Set the lowest level of [Record]s that this handler will handle.
	@tag Filtering
	@param level Level
]=]
function Handler:setLevel(level)
	self.level = level
end

--[=[
	@since 0.2.0
	Returns whether this handler will filter [Record]s with the given [Level] according to its [Handler.level].
	@tag Filtering
	@param level Level
]=]
function Handler:isEnabledFor(level)
	return self.level <= level
end

--[=[
	@since 0.1.0
	Adds a [Filter] to this handler.
	@tag Filtering
	@param filter Filter
]=]
function Handler:addFilter(filter)
	assert(typeof(filter) == "function", "filter must be a function, got " .. typeof(filter))
	self.filters[filter] = filter
end

--[=[
	@since 0.1.0
	Removes a [Filter] from this handler.
	@param filter Filter
	@tag Filtering
]=]
function Handler:removeFilter(filter)
	self.filters[filter] = nil
end

--[=[
	@since 0.1.0
	Checks if the level of the given record using [Handler:isEnabledFor].
	If it is, each filter added by [Handler:addFilter] is called in turn.
	If any filter function returns false or nil, this function returns false.
	Otherwise, this function returns true.
	@tag Filtering
	@param record Record
	@return boolean
]=]
function Handler:filter(record)
	if not self:isEnabledFor(record.level) then
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

--[=[
	@since 0.1.0
	Sets the formatter to be used by the handler.
	@param formatter Formatter
]=]
function Handler:setFormatter(formatter)
	self.formatter = formatter
end

--[=[
	@since 0.1.0
	Calls [Handler:filter] and if it passes, then [Handler:emit].
	@param record Record
]=]
function Handler:handle(record)
	if self:filter(record) then
		self:emit(record)
	end
end
Handler.__call = Handler.handle

--[=[
	@since 0.1.0
	Abstract. Performs the record-handling logic.
	@param _record Record
]=]
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
