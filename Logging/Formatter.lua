local Level = require(script.Parent:WaitForChild("Level"))

--[=[
	@class Formatter
	Creates messages from [Record] objects for use in [Handler]s.
]=]
local Formatter = {}
Formatter.__index = Formatter
Formatter.S_ASCTIME = "asctime"
Formatter.ASCTIME_FORMAT = "%Y-%m-%d %I:%M:%S"
Formatter.S_NAME = "name"
Formatter.S_LEVELNO = "levelno"
Formatter.S_LEVEL = "level"
Formatter.S_MESSAGE = "message"

--[=[
	@prop fmt string
	@within Formatter
	@since 0.1.0
	Determines how the message should be format.
]=]

--[=[
	@since 0.1.0
	Create a new formatter which uses the given format string.
	@param fmt string
	@return Formatter
]=]
function Formatter.new(fmt)
	local self = setmetatable({
		fmt = fmt or "%(message)s";
	}, Formatter)
	return self
end

--[=[
	@since 0.1.0
	Sets the message format used by this formatter.
	@param fmt string
]=]
function Formatter:setFormat(fmt)
	assert(typeof(fmt) == "string", "fmt expects string, is " .. typeof(fmt))
	self.fmt = fmt
end

--[=[
	@since 0.1.0
	Format the [Formatter.fmt] string using details from the given [Record]
	@param record Record
]=]
function Formatter:format(record)
	return self.fmt:gsub("%%%((.-)%).", function (s)
		if s == Formatter.S_MESSAGE then
			return record:getMessage()
		elseif s == Formatter.S_NAME then
			return record.logger:getFullName()
		elseif s == Formatter.S_LEVEL then
			for k, v in pairs(Level) do
				if v == record.level then
					return k
				end
			end
			return "?"
		elseif s == Formatter.S_LEVELNO then
			return tostring(record.level)
		elseif s == Formatter.S_ASCTIME then
			return os.date(Formatter.ASCTIME_FORMAT, record.created)
		end
	end)
end

return Formatter
