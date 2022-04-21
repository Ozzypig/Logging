local Level = require(script.Parent:WaitForChild("Level"))

local Formatter = {}
Formatter.__index = Formatter
Formatter.S_ASCTIME = "asctime"
Formatter.ASCTIME_FORMAT = "%Y-%m-%d %I:%M:%S"
Formatter.S_NAME = "name"
Formatter.S_LEVELNO = "levelno"
Formatter.S_LEVEL = "level"
Formatter.S_MESSAGE = "message"

function Formatter.new(fmt)
	local self = setmetatable({
		fmt = fmt or "%(message)s";
	}, Formatter)
	return self
end

function Formatter:setFormat(fmt)
	assert(typeof(fmt) == "string", "fmt expects string, is " .. typeof(fmt))
	self.fmt = fmt
end

function Formatter:format(logRecord)
	return self.fmt:gsub("%%%((.-)%).", function (s)
		if s == Formatter.S_MESSAGE then
			return logRecord:getMessage()
		elseif s == Formatter.S_NAME then
			return logRecord.logger:getFullName()
		elseif s == Formatter.S_LEVEL then
			for k, v in pairs(Level) do
				if v == logRecord.level then
					return k
				end
			end
			return "?"
		elseif s == Formatter.S_LEVELNO then
			return tostring(logRecord.level)
		elseif s == Formatter.S_ASCTIME then
			return os.date(Formatter.ASCTIME_FORMAT, logRecord.created)
		end
	end)
end

return Formatter
