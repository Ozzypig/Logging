local Level = {
	-- Default value for new loggers. Indicates that effective
	-- level should come from the logger's parent.
	NotSet = 0;

	-- Detail used when diagnosing problems
	Debug = 10;

	-- Confirmation that things are working as expected
	Info = 20;

	-- Indication that something unexpected happened, OR
	-- Indication that something may go wrong in the near future.
	Warning = 30;

	-- Indication that something couldn't be done due
	-- to a more serious problem.
	Error = 40;

	-- Indication that the program itself may not be able 
	-- to continue due to a serious error.
	Critical = 50;
}

return Level
