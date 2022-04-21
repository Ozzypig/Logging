local Record = {}
Record.__index = Record

function Record.new(logger, level, message, ...)
	assert(typeof(level) == "number", "Level must be a number (use Logging.Level constants)")
	local self = setmetatable({
		logger = logger;
		level = level;
		message = message;
		values = {...};
		created = os.time();
		handled = false;
	}, Record)
	return self
end

function Record:__tostring()
	return self:getMessage()
end

function Record:getMessage()
	return self.message:format(unpack(self.values))
end

return Record
