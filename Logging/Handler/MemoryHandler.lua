--[=[
	@class MemoryHandler

	An implementation of [Handler] which stores [Record]s in a buffer. When
	the buffer fills, it passes the stored [Record]s to another target
	[Handler], then the buffer is cleared.
]=]
local Level = require(script.Parent.Parent:WaitForChild("Level"))

local Handler = require(script.Parent)

local MemoryHandler = setmetatable({}, { __index = Handler })
MemoryHandler.__index = MemoryHandler

--[=[
	@prop buffer table
	@within MemoryHandler
	@since 0.1.0
	An array-like table which stores [Record]s.
]=]

--[=[
	@prop i number
	@within MemoryHandler
	@private
	@since 0.1.0
	The index where the next [Record] is to be stored in the [MemoryHandler.buffer]
]=]

--[=[
	@prop capacity number
	@within MemoryHandler
	@since 0.1.0
	The number of [Record] that can be stored in the buffer before [MemoryHandler:flush] is called.
]=]

--[=[
	@prop flushLevel Level
	@within MemoryHandler
	@since 0.1.0
	If a [Record] with a level greater than or equal to this level is handled, then [MemoryHandler:flush]
	is called immediately.
]=]

--[=[
	@prop target Handler
	@within MemoryHandler
	@since 0.1.0
	Another handler to handle stored [Record] when [MemoryHandler:flush] is called.
]=]

--[=[
	@prop flushOnClose boolean
	@within MemoryHandler
	@since 0.1.0
	Determines whether [MemoryHandler:flush] is called when [MemoryHandler:close] is called.
]=]

--[=[
	@prop lastRecord Record
	@within MemoryHandler
	@private
	@since 0.1.0
	The most recently handled record.
]=]

--[=[
	@since 0.1.0
	Creates a new MemoryHandler of a given capacity.
	@param capacity number
	@param flushLevel Level
	@param target Handler
	@param flushOnClose boolean
	@return MemoryHandler
]=]
function MemoryHandler.new(capacity, flushLevel, target, flushOnClose)
	local self = setmetatable(Handler.new(), MemoryHandler)
	self.buffer = table.create(capacity)
	self.i = 1
	self.capacity = capacity
	self.flushLevel = flushLevel or Level.Error
	self.target = target
	self.flushOnClose = (flushOnClose == nil) or flushOnClose
	self.lastRecord = nil
	return self
end

function MemoryHandler:__tostring()
	return ("<MemoryHandler (%d/%d)>"):format(self.i, self.capacity)
end

--[=[
	@since 0.1.0
	Adds the given record to the buffer. Then, if [MemoryHandler:shouldFlush]
	returns true, [MemoryHandler:flush] is called.
	@param record Record
]=]
function MemoryHandler:emit(record)
	self.lastRecord = record
	self.buffer[self.i] = record
	self.i += 1
	if self:shouldFlush(record) then
		self:flush()
	end
end

--[=[
	@since 0.1.0
	Returns the last record emit to the MemoryHandler.
	@return Record
]=]
function MemoryHandler:getLastRecord()
	return self.lastRecord
end

--[=[
	@since 0.1.0
	Returns the number of records that the MemoryHandler has stored in the buffer.
	@return number
]=]
function MemoryHandler:size()
	return self.i - 1
end

--[=[
	@since 0.1.0
	Returns the number of records that the MemoryHandler can store in its buffer before filling.
	@return number
]=]
function MemoryHandler:space()
	return self.capacity - self:size()
end

--[=[
	@since 0.1.0
	Returns whether the MemoryHandler's buffer has run out of space.
	@return boolean
]=]
function MemoryHandler:isFull()
	return self:space() <= 0
end

--[=[
	@since 0.1.0
	If a [MemoryHandler.target] is set, this passes all of the [Record]s stored in the buffer
	to [Handler:handle]. Then, the buffer is empted ([MemoryHandler:emptyBuffer]).
]=]
function MemoryHandler:flush()
	if self.target then
		for i = 1, self.i - 1 do
			self.target:handle(self.buffer[i])
		end
	end
	self:emptyBuffer()
end

--[=[
	@since 0.1.0
	Clears the buffer of all [Record]s.
]=]
function MemoryHandler:emptyBuffer()
	table.clear(self.buffer)
	self.i = 1
end

--[=[
	@since 0.1.0
	Sets the target [Handler] for when the MemoryHandler is flushed.
	@param target Handler
]=]
function MemoryHandler:setTarget(target)
	self.target = target
end

--[=[
	@since 0.1.0
	Determines whether the MemoryHandler should flush its contents based on the given record
	and the state of the buffer. If the given record is at or above the [MemoryHandler.flushLevel],
	or if the buffer is full ([MemoryHandler:isFull]), this method returns true.
	This method can be overwritten to provide a different flush strategy.
	@param record Record
	@return boolean
]=]
function MemoryHandler:shouldFlush(record)
	return record.level >= self.flushLevel or self:isFull()
end

--[=[
	@since 0.1.0
	If [MemoryHandler.flushOnClose] is true, then [MemoryHandler:flush] is called.
]=]
function MemoryHandler:close()
	if self.flushOnClose then
		self:flush()
	end
end

return MemoryHandler
