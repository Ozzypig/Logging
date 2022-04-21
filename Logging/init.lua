--[=[
	@class Logging
	The root module object, which contains the root logger. 
	Also exposes proxy methods which operate on the root logger, e.g. [Logging:debug] calls [Logger:debug] on the root logger.
]=]

local Logging = {}
Logging.__index = Logging
Logging.Logging = Logging

Logging.Version = require(script:WaitForChild("Version"))
Logging.Level = require(script:WaitForChild("Level"))
Logging.Record = require(script:WaitForChild("Record"))
Logging.Logger = require(script:WaitForChild("Logger"))
Logging.Formatter = require(script:WaitForChild("Formatter"))
Logging.Handler = require(script:WaitForChild("Handler"))
Logging.OutputHandler = require(script.Handler:WaitForChild("OutputHandler"))
Logging.NullHandler = require(script.Handler:WaitForChild("NullHandler"))
Logging.FuncHandler = require(script.Handler:WaitForChild("FuncHandler"))
Logging.MemoryHandler = require(script.Handler:WaitForChild("MemoryHandler"))

Logging.ROOT_LOGGER_NAME = "Logging"
Logging.ROOT_LOGGER_LEVEL = Logging.Level.Warning
Logging.ROOT_LOGGER_METHODS = {
	-- Standard log methods
	"log", "debug", "info", "warning", "error", "critical",
	-- Wrappers
	"wrap", "print", "warn", "pcall", "xpcall",
	-- Logger configuration
	"setLevel", "isEnabledFor",
	"addHandler", "removeHandler",
	"addFilter", "removeFilter", "filter"
}

--[=[
	@since 0.1.0
	Constructs a new Logging module. For normal use, this is done once by the module.
	When running tests, the Logging module is recreated for each test case.
	@private
	@return Logging
]=]
function Logging.new()
	local self = setmetatable({
		rootLogger = nil;
	}, Logging)
	return self
end

--[=[
	@since 0.1.0
	Calls [Logger:getChild] on the root logger with the given name
	@param name string
]=]
function Logging:getLogger(name)
	assert(typeof(name) == "string" and name:len() > 0, "name must be non-empty string, is " .. typeof(name))
	return self:getRootLogger():getChild(name)
end

--[=[
	@since 0.1.0
	Creates a new root logger at the default level.
	@private
	@return Logger
]=]
function Logging:createRootLogger()
	local logger = Logging.Logger.new(self, Logging.ROOT_LOGGER_NAME, nil)
	logger:setLevel(Logging.ROOT_LOGGER_LEVEL)
	return logger
end

--[=[
	@since 0.1.0
	Returns the root logger, calling [Logging:createRootLogger] if it hasn't been created yet.
	@return Logger
]=]
function Logging:getRootLogger()
	local logger = self.rootLogger
	if not logger then
		logger = self:createRootLogger()
		self.rootLogger = logger
	end
	return logger
end

--[=[
	@since 0.1.0
	Attaches an [OutputHandler] with a [Formatter] to the root logger. The following keys can be specified:

	* `level` [Level]: The level to set the root logger. Default: [Level.Warning]
	* `format` string: The [Formatter.fmt] of the [OutputHandler]. Default: `%(message)s`
	* `force` boolean: If true, adds the new handler even if the root logger already has one.

	@param options table
]=]
function Logging:basicConfig(options)
	local logger = self:getRootLogger()
	if not next(logger.handlers) or options["force"] then -- logger.handlers is empty:
		-- Set root logger level
		if options["level"] then
			logger:setLevel(options["level"])
		end
		-- Add output handler which sends Debug/Info to print() and all others to warn()
		local outputHandler = Logging.OutputHandler.new()
		local formatter = Logging.Formatter.new(options["format"] or "%(name)s:%(level)s:%(message)s")
		outputHandler:setFormatter(formatter)
		logger:addHandler(outputHandler)
	else
		warn("Logging:basicConfig failed: root logger already has at least one handler. Set option \"force\" to silence.")
	end
end

--[=[
	@since 0.1.0
	Returns the string name of the given numeric level, or raises an error if no name matches.
	@param level Level
	@return string
]=]
function Logging:getLevelName(level)
	assert(typeof(level) == "number", "level must be a number, is " .. typeof(level))
	for k, v in pairs(Logging.Level) do
		if typeof(v) == "number" and v == level then
			return k
		end
	end
	error("No name for log level " .. level)
end

--[=[
	@since 0.1.0
	Proxy for [Logger:setLevel] on the root logger.
	@method setLevel
	@within Logging
	@tag Filtering
	@param level Level
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:addFilter] on the root logger.
	@method addFilter
	@within Logging
	@tag Filtering
	@param filter Filter
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:removeFilter] on the root logger.
	@method removeFilter
	@within Logging
	@tag Filtering
	@param filter Filter
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:filter] on the root logger.
	@method filter
	@within Logging
	@tag Filtering
	@return boolean
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:addHandler] on the root logger.
	@method addHandler
	@within Logging
	@tag Handling
	@param handler Handler
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:removeHandler] on the root logger.
	@method removeHandler
	@within Logging
	@tag Handling
	@param handler Handler
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:log] on the root logger.
	@method log
	@within Logging
	@tag Logging
	@param level Level
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:debug] on the root logger.
	@method debug
	@within Logging
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:info] on the root logger.
	@method info
	@within Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:warning] on the root logger.
	@method warning
	@within Logging
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:error] on the root logger.
	@method error
	@within Logging
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:critical] on the root logger.
	@method critical
	@within Logging
	@tag Logging
	@param message RecordMessage
	@param ... any
	@return Record
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:wrap] on the root logger.
	@method wrap
	@within Logging
	@tag Sugar
	@param callOriginal boolean
	@return function, function
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:pcall] on the root logger.
	@method pcall
	@within Logging
	@tag Sugar
	@param func function
	@param ... any
	@return any
]=]

--[=[
	@since 0.1.0
	Proxy for [Logger:xpcall] on the root logger.
	@method xpcall
	@within Logging
	@tag Sugar
	@param func function
	@param errorHandler function
	@param ... any
	@return any
]=]

for _i, methodName in pairs(Logging.ROOT_LOGGER_METHODS) do
	assert(Logging.Logger[methodName], "No such logger method: " .. methodName)
	local function wrapper(self, ...)
		local logger = self:getRootLogger()
		return assert(logger[methodName], "No such logger method: " .. methodName)(logger, ...)
	end
	Logging[methodName] = wrapper
end

return Logging.new()
