--[=[
	@class Level
	A [Record]'s level indicates the importance or severity of the event it describes.
]=]
local Level = {}

--[=[
	@type Level number
	@within Level
]=]

--[=[
	@prop NotSet Level
	@within Level
	@readonly
	@since 0.1.0
	0. Default for new [Logger] and [Handler].
	For loggers, this value indicates that the effective level should be that of the parent logger's effective level.
]=]
Level.NotSet = 0

--[=[
	@prop Debug Level
	@within Level
	@readonly
	@since 0.1.0
	10. Detail used when diagnosing problems.
]=]
Level.Debug = 10

--[=[
	@prop Info Level
	@within Level
	@readonly
	@since 0.1.0
	20. Confirmation that things are working as expected
]=]
Level.Info = 20

--[=[
	@prop Warning Level
	@within Level
	@readonly
	@since 0.1.0
	30. Indication that something unexpected happened, or that something may go wrong in the near future.
]=]
Level.Warning = 30

--[=[
	@prop Error Level
	@within Level
	@readonly
	@since 0.1.0
	40. Indication that something couldn't be done due to a more serious problem.
]=]
Level.Error = 40

--[=[
	@prop Critical Level
	@within Level
	@readonly
	@since 0.1.0
	50. Indication that the program itself may not be able to continue due to a serious error.
]=]
Level.Critical = 50

return Level
