local Level = require(script.Parent:WaitForChild("Level"))
local Record = require(script.Parent:WaitForChild("Record"))
local FuncHandler = require(script.Parent:WaitForChild("Handler"):WaitForChild("FuncHandler"))

--[=[
	@class Logger
	Responsible for creating [Record]s to be filtered and emit to [Handler]s.
]=]
local Logger = {}
Logger.__index = Logger
Logger.RecordClass = Record
Logger.ERR_UNHANDLED_RECORD = "Unhandled record - did you forget to call Logging:basicConfig or add a handler?"
Logger.pcallLevel = Level.Error

--[=[
	@type Filter (Record) -> (boolean)
	@within Logger
	A function which accepts a record to consider and returns a boolean indicating whether
	the record should be processed. It is called by [Logger:filter] and [Handler:filter].
]=]

--[=[
	@prop logging Logging
	@within Logger
	@since 0.1.0
	The logging module in which this logger was created.
]=]

--[=[
	@prop name string
	@within Logger
	@tag Hierarchy
	@since 0.1.0
	The name of this logger to be considered when working with logger hierarchies.
]=]

--[=[
	@prop parent Logger
	@within Logger
	@tag Hierarchy
	@since 0.1.0
	The parent logger whose level shall be deferred to when this logger's level is [Level.NotSet]
	(see [Logger:getEffectiveLevel]). [Records] emit by this logger are emit to the parent logger
	if [Logger.propagate] is true.

	Loggers at the top level, e.g. `Logging:getLogger("MyModule")`, have the root logger as their parent.
	The root logger does not have a parent.
]=]

--[=[
	@prop propagate boolean
	@within Logger
	@tag Hierarchy
	@since 0.1.0
	Indicates whether records should be handled by the [Logger.parent], if it exists.
]=]

--[=[
	@prop children table
	@within Logger
	@tag Hierarchy
	@since 0.1.0
	Maps the child [Logger.name]s to the child [Logger]s themselves.
]=]

--[=[
	@prop level Level
	@within Logger
	@tag Filtering
	@since 0.1.0
	The level of this logger. Use [Logger:getEffectiveLevel] when considering
	a logger's level.
]=]

--[=[
	@prop filters table
	@within Logger
	@tag Filtering
	@since 0.1.0
	A set of [Filter]s added to this logger with [Logger:addFilter].
]=]

--[=[
	@prop handlers table
	@within Logger
	@tag Handling
	@since 0.1.0
	A set of [Handler]s added to this logger with [Logger:addHandler].
]=]

--[=[
	@since 0.1.0
	Constructs a new logger of the given `name` within the given [Logging] module.
	Should not be used directly. Instead, call [Logging:getLogger] or [Logger:getChild] which
	properly construct the logger hierarchy.
	@param logging Logging
	@param name string
	@param parent [Record]
	@private
	@return Logger
]=]
function Logger.new(logging, name, parent)
	assert(typeof(name) == "string", "name must be string, got " .. typeof(name))
	local self = setmetatable({
		logging = logging,
		name = name;
		parent = parent;
		children = {};
		level = Level.NotSet;
		handlers = {};
		filters = {};
		propagate = true;
	}, Logger)
	return self
end

function Logger:__tostring()
	return ("<Logger %q (%s)>"):format(self:getFullName(), self.logging:getLevelName(self.level))
end

--[=[
	@since 0.1.0
	Returns the names of all ancestors of a logger and the logger's name itself, concatenated by
	periods, e.g. `MyFightingGame.Players.DataStores`. The value returned by this function can
	be sent to [Logging:getLogger] to retrieve the same logger.
	@tag Hierarchy
	@return string
]=]
function Logger:getFullName()
	if self == self.logging:getRootLogger() then
		return self.name
	else
		return (self.parent and self.parent ~= self.logging:getRootLogger() and self.parent:getFullName() .. "." or "") .. self.name
	end
end

--[=[
	@since 0.1.0
	Gets a child logger with the given name, creating it if it does not exist.
	If the given name contains a period, the logger returned is the child whose name appears
	after the period, i.e. `logger:getChild("MyFightingGame.Players")` is the same as
	`logger:getChild("MyFightingGame"):getChild("Players")`
	@tag Hierarchy
	@param childName string
]=]
function Logger:getChild(childName)
	local descendantName = nil

	local s, e = childName:find("%.")
	if s and e then
		-- "foo.bar.baz"
		-- childName: "foo"
		-- descendantName: "bar.baz"
		childName, descendantName = childName:sub(1, s - 1), childName:sub(e + 1)
	end

	local logger = self.children[childName]
	if not logger then
		logger = Logger.new(self.logging, childName, self)
		self.children[childName] = logger
	end
	
	return descendantName and logger:getChild(descendantName) or logger
end

--[=[
	@since 0.1.0
	Sets the lowest level of [Record]s that this logger will emit to its handlers.
	@tag Filtering
	@param level Level
]=]
function Logger:setLevel(level)
	local ty = typeof(level)
	if ty == "number" then
		self.level = level
	elseif ty == "string" then
		return self:setLevel(assert(Level[level], "no such level: " .. tostring(level)))
	else
		error("level must be string or nubmer, got " .. ty)
	end
end

--[=[
	@since 0.1.0
	Returns the level of this logger, or if it is [Level.NotSet], the effective level of the [Logger.parent].
	@tag Filtering
	@return Level
]=]
function Logger:getEffectiveLevel()
	return self.level ~= Level.NotSet and self.level or (self.parent and self.parent:getEffectiveLevel() or Level.NotSet)
end

--[=[
	@since 0.1.0
	Returns whether this logger will filter [Record]s with the given [Level] according to its [Logger:getEffectiveLevel].
	@tag Filtering
	@param level Level
]=]
function Logger:isEnabledFor(level)
	if typeof(level) == "string" then
		level = assert(Level[level], "No such level: " .. level)
	end
	assert(typeof(level) == "number", "level must be number, is " .. typeof(level))
	return self:getEffectiveLevel() <= level
end

--[=[
	@since 0.1.0
	Adds a [Filter] to this logger.
	@tag Filtering
	@param filter Filter
]=]
function Logger:addFilter(filter)
	assert(typeof(filter) == "function", "filter must be a function, got " .. typeof(filter))
	self.filters[filter] = filter
end

--[=[
	@since 0.1.0
	Removes a [Filter] from this logger.
	@param filter Filter
	@tag Filtering
]=]
function Logger:removeFilter(filter)
	self.filters[filter] = nil
end

--[=[
	@since 0.1.0
	Checks if the level of the given record using [Logger:isEnabledFor].
	If it is, each filter added by [Logger:addFilter] is called in turn.
	If any filter function returns false or nil, this function returns false.
	Otherwise, this function returns true.
	@tag Filtering
	@param record Record
	@return boolean
]=]
function Logger:filter(record)
	if not self:isEnabledFor(record.level) then
		return false
	end
	for filter in pairs(self.filters) do
		if not filter(self, record) then
			return false
		end
	end
	return true
end

--[=[
	@since 0.1.0
	Adds a [Handler] to this logger. If a function is provided instead, a [FuncHandler] is created to wrap it.
	@tag Handling
	@param handler Handler
]=]
function Logger:addHandler(handler)
	local ty = typeof(handler)
	if ty == "function" then
		handler = FuncHandler.new(handler)
	else
		assert(ty == "table", "function or table expected, got " .. ty)
	end
	self.handlers[handler] = handler
end

--[=[
	@since 0.1.0
	Removes a [Handler] from this logger. If a function is provided, a [FuncHandler] with the given function is searched for and removed.
	@tag Handling
	@param handler Handler
]=]
function Logger:removeHandler(handler)
	local ty = typeof(handler)
	if ty == "function" then
		-- Find FuncHandler by func
		for handler2 in pairs(self.handlers) do
			if handler2.func == handler then
				handler = handler2
				break
			end
		end
	else
		assert(ty == "table", "function or table expected, got " .. ty)
	end
	self.handlers[handler] = nil
end

--[=[
	@since 0.1.0
	Creates a [Record] with the provided arguments.
	@tag Logging
	@param level Level
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:newRecord(level, message, ...)
	return self.RecordClass.new(self, level, message, ...)
end

--[=[
	@since 0.1.0
	Create a [Record] using [Logger:newRecord] with the provided arguments.
	Then, calls [Logger:filter], and if it passes, [Logger:emit]. Returns the
	newly created record.
	@tag Logging
	@param level Level
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:log(level, message, ...)
	local record = self:newRecord(level, message, ...)
	if self:filter(record) then
		self:emit(record)
	end
	return record
end

--[=[
	@since 0.1.0
	Invokes each of the logger's [Handler]s with the given [Record]. Then,
	if [Logger.propagate] is true, the record is emit on the [Logger.parent].
	@tag Logging
	@param record Record
]=]
function Logger:emit(record)
	for handler in pairs(self.handlers) do
		local ty = typeof(handler)
		if ty == "table" and handler:filter(record) then
			handler:handle(record)
			record.handled = true
		end
	end
	if self.propagate and self.parent then
		self.parent:emit(record)
	elseif not record.handled then
		warn(Logger.ERR_UNHANDLED_RECORD)
	end
end

--[=[
	@since 0.1.0
	Invokes [Logger:log] with the level of the record set to [Level.Debug].
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:debug(message, ...)
	return self:log(Level.Debug, message, ...)
end
Logger.print = Logger.debug


--[=[
	@since 0.1.0
	Invokes [Logger:log] with the level of the record set to [Level.Info].
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:info(message, ...)
	return self:log(Level.Info, message, ...)
end

--[=[
	@since 0.1.0
	Invokes [Logger:log] with the level of the record set to [Level.Warning].
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:warning(message, ...)
	return self:log(Level.Warning, message, ...)
end
Logger.warn = Logger.warning

--[=[
	@since 0.1.0
	Invokes [Logger:log] with the level of the record set to [Level.Error].
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:error(message, ...)
	return self:log(Level.Error, message, ...)
end

--[=[
	@since 0.1.0
	Invokes [Logger:log] with the level of the record set to [Level.Critical].
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]
function Logger:critical(message, ...)
	return self:log(Level.Critical, message, ...)
end

--[=[
	@since 0.1.0
	Returns two functions which wrap the built-in `print` and `wrap` globals.
	If `callOriginal` is true, the original global functions are called after
	logging.
	@tag Sugar
	@param callOriginal boolean
	@return function, function
]=]
function Logger:wrap(callOriginal)
	-- toS(a, b, c) --> "%s %s %s", a, b, c
	local function toS(...)
		local v = {...}
		return table.concat(table.create(#v, "%s"), " "), ...
	end
	-- print -> logger:debug
	local function printWrapper(...)
		self:debug(toS(...))
		if callOriginal then
			print(...)
		end
	end
	-- warn -> logger:warning
	local function warnWrapper(...)
		self:warning(toS(...))
		if callOriginal then
			warn(...)
		end
	end
	return printWrapper, warnWrapper
end

--[=[
	@since 0.1.0
	Works just like the global `pcall`, with the addition of logging an [Level.Error] if the function errors.
	@tag Sugar
	@param func function
	@param ... any
	@return any
]=]
function Logger:pcall(func, ...)
	local retVals = {pcall(func, ...)}
	if not retVals[1] then
		self:log(Logger.pcallLevel, "%s", retVals[2])
	end
	return unpack(retVals)
end

--[=[
	@since 0.1.0
	Works just like the global `xpcall`, with the addition of logging an [Level.Error] if the function errors.
	@tag Sugar
	@param func function
	@param errorHandler function
	@param ... any
	@return any
]=]
function Logger:xpcall(func, errorHandler, ...)
	return xpcall(func, function (err)
		self:log(Logger.pcallLevel, "%s", err)
		return errorHandler(err)
	end, ...)
end

return Logger