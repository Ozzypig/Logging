local Level = require(script.Parent:WaitForChild("Level"))
local Record = require(script.Parent:WaitForChild("Record"))
local FuncHandler = require(script.Parent:WaitForChild("Handler"):WaitForChild("FuncHandler"))

local Logger = {}
Logger.__index = Logger
Logger.RecordClass = Record
Logger.ERR_UNHANDLED_RECORD = "Unhandled record - did you forget to call Logging:basicConfig or add a handler?"
Logger.pcallLevel = Level.Error

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

function Logger:getFullName()
	if self == self.logging:getRootLogger() then
		return self.name
	else
		return (self.parent and self.parent ~= self.logging:getRootLogger() and self.parent:getFullName() .. "." or "") .. self.name
	end
end

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

function Logger:getEffectiveLevel()
	return self.level ~= Level.NotSet and self.level or (self.parent and self.parent:getEffectiveLevel() or Level.NotSet)
end

function Logger:addHandler(handler)
	local ty = typeof(handler)
	if ty == "function" then
		handler = FuncHandler.new(handler)
	else
		assert(ty == "table", "function or table expected, got " .. ty)
	end
	self.handlers[handler] = handler
end

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

function Logger:addFilter(filter)
	assert(typeof(filter) == "function", "filter must be a function, got " .. typeof(filter))
	self.filters[filter] = filter
end

function Logger:removeFilter(filter)
	self.filters[filter] = nil
end

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

function Logger:isEnabledFor(level)
	if typeof(level) == "string" then
		level = assert(Level[level], "No such level: " .. level)
	end
	assert(typeof(level) == "number", "level must be number, is " .. typeof(level))
	return self:getEffectiveLevel() <= level
end

function Logger:newRecord(...)
	return self.RecordClass.new(...)
end

function Logger:log(...)
	local record = self:newRecord(self, ...)
	if self:filter(record) then
		self:emit(record)
	end
	return record
end

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

function Logger:debug(...)
	return self:log(Level.Debug, ...)
end
Logger.print = Logger.debug

function Logger:info(...)
	return self:log(Level.Info, ...)
end

function Logger:warning(...)
	return self:log(Level.Warning, ...)
end
Logger.warn = Logger.warning

function Logger:error(...)
	return self:log(Level.Error, ...)
end

function Logger:critical(...)
	return self:log(Level.Critical, ...)
end

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

function Logger:pcall(func, ...)
	local retVals = {pcall(func, ...)}
	if not retVals[1] then
		self:log(Logger.pcallLevel, "%s", retVals[2])
	end
	return unpack(retVals)
end

function Logger:xpcall(func, errorHandler, ...)
	return xpcall(func, function (err)
		self:log(Logger.pcallLevel, "%s", err)
		return errorHandler(err)
	end, ...)
end

return Logger