local Level = require(script.Parent.Parent:WaitForChild("Level"))

local Handler = require(script.Parent)

local MemoryHandler = setmetatable({}, {__index = Handler})
MemoryHandler.__index = MemoryHandler

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

function MemoryHandler:emit(record)
	self.lastRecord = record
	self.buffer[self.i] = record
	self.i += 1
	if self:shouldFlush(record) then
		self:flush()
	end
end

function MemoryHandler:getLastRecord()
	return self.lastRecord
end

function MemoryHandler:size()
	return self.i - 1
end

function MemoryHandler:space()
	return self.capacity - self:size()
end

function MemoryHandler:isFull()
	return self:space() <= 0
end

function MemoryHandler:flush()
	if self.target then
		for i = 1, self.i - 1 do
			self.target:handle(self.buffer[i])
		end
	end
	self:emptyBuffer()
end

function MemoryHandler:emptyBuffer()
	table.clear(self.buffer)
	self.i = 1
end

function MemoryHandler:setTarget(target)
	self.target = target
end

function MemoryHandler:shouldFlush(record)
	return record.level >= self.flushLevel or self:isFull()
end

function MemoryHandler:close()
	if self.flushOnClose then
		self:flush()
	end
end

return MemoryHandler
