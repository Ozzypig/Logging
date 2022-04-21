local Logging = {}
Logging.__index = Logging
Logging.Logging = Logging

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

function Logging.new()
	local self = setmetatable({
		rootLogger = nil;
	}, Logging)
	return self
end

function Logging:getLogger(name)
	assert(typeof(name) == "string" and name:len() > 0, "name must be non-empty string, is " .. typeof(name))
	return self:getRootLogger():getChild(name)
end

function Logging:createRootLogger()
	local logger = Logging.Logger.new(self, Logging.ROOT_LOGGER_NAME, nil)
	logger:setLevel(Logging.ROOT_LOGGER_LEVEL)
	return logger
end

function Logging:getRootLogger()
	local logger = self.rootLogger
	if not logger then
		logger = self:createRootLogger()
		self.rootLogger = logger
	end
	return logger
end

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

function Logging:getLevelName(level)
	assert(typeof(level) == "number", "level must be a number, is " .. typeof(level))
	for k, v in pairs(Logging.Level) do
		if typeof(v) == "number" and v == level then
			return k
		end
	end
	error("No name for log level " .. level)
end

for _i, methodName in pairs(Logging.ROOT_LOGGER_METHODS) do
	assert(Logging.Logger[methodName], "No such logger method: " .. methodName)
	local function wrapper(self, ...)
		local logger = self:getRootLogger()
		return assert(logger[methodName], "No such logger method: " .. methodName)(logger, ...)
	end
	Logging[methodName] = wrapper
end

return Logging.new()
