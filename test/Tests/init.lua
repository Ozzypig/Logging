local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logging = require(ReplicatedStorage:WaitForChild("Logging"))
local LoggingClass = Logging.Logging

local Tests = {}
Tests.tests = {}

-- Add all children as tests
for _, child in pairs(script:GetChildren()) do
	Tests.tests[child.Name] = require(child)
end

local HR = ("-"):rep(15)
local UNICORN = require(script.Parent:WaitForChild("Unicorn"))
function Tests.run()
	local passed, total = 0, 0
	local LoggingModule
	for name, test in pairs(Tests.tests) do
		print(("%s %s"):format(HR, name))
		-- Re-create Logging module before each test
		LoggingModule = LoggingClass.new()

		total += 1
		local success, err = pcall(test, LoggingModule)
		if success then
			print(("PASS: %s"):format(name))
			passed += 1
		else
			warn(("FAIL: %s\n%s"):format(name, err))
		end
	end
	print(("%s\nRESULTS: %d / %d%s"):format(HR, passed, total, passed ~= total and "" or "\n" .. UNICORN))
end

return Tests
