--[=[
	@class Record
	Represents the occurrence of an event.
]=]
local Record = {}
Record.__index = Record

--[=[
	@prop logger Logger
	@within Record
	@since 0.1.0
	The logger which created this record.
]=]

--[=[
	@prop level Level
	@within Record
	@since 0.1.0
	The level representing the importance or severity of the event the record represents.
]=]

--[=[
	@type RecordMessage string
	@within Record
	An object that represents a record's message. At the moment, this may only be a string.
]=]

--[=[
	@prop message RecordMessage
	@within Record
	@since 0.2.0
	The record's message.
]=]

--[=[
	@type timestamp number
	@within Record
	Seconds since the Unix epoch under UTC time.
]=]

--[=[
	@prop created timestamp
	@within Record
	@since 0.1.0
	The time when the record was created.
]=]

--[=[
	@prop handled boolean
	@within Record
	@since 0.1.0
	Whether this record has been handled by at least one [Handler].
]=]

--[=[
	Create a new record for the given [Logger] with the importance/severity indicated by [Level].
	The provided values are formatted to generate the record message ([Record:getMessage]).
	This should not be called directly. Instead, use [Logger:log] and its variants.
	@param logger Logger
	@param level Level
	@param message RecordMessage
	@param ... any
	@private
	@return Record
	@since 0.1.0
]=]
function Record.new(logger, level, message, ...)
	assert(typeof(level) == "number", "Level must be a number (use Logging.Level constants)")
	local self = setmetatable({
		logger = logger,
		level = level,
		message = message,
		values = { ... },
		created = os.time(),
		handled = false,
	}, Record)
	return self
end

function Record:__tostring()
	return self:getMessage()
end

--[=[
	Returns the formatted message.
	@return string
	@since 0.1.0
]=]
function Record:getMessage()
	return self.message:format(unpack(self.values))
end

return Record
