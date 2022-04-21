# Getting Started

Call `Logging:basicConfig` with a config table! This will set the log level and a
default handler on the root logger that sends logs to `print` and `warn` (depending
on level/severity).

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logging = require(ReplicatedStorage:WaitForChild("Logging"))
Logging:basicConfig{
	-- level: log events less severe than this are ignored
	level=Logging.Level.Debug; -- hint: "Debug" also works
	-- format: how do you want your log messages to look?
	format="%(asctime)s - %(name)s - %(level)s - %(message)s";
}
```

You're all set to go! When stuff happens, log it! You can now create logs on the
root logger using the following logging functions, which work like `string.format`:

```lua
-- Debug: For details useful during debugging:
Logging:debug("Score updated to %d", score) -- aka logger:print
-- Info: For confirmation that things are working:
Logging:info("Round started with %d participants", #players)
-- Warning: For potential/future issues:
Logging:warning("%s messed up", "The thing") -- aka logger:warn
-- Error: For suppressed errors:
Logging:error("Matchmaker broke with %d players in queue: %s", #players, error_message)
-- Critical: For showstopping events:
Logging:critical("Server is on fire! Abort, abort, abort!")
-- Or, specify a particular log level:
Logging:log(Logging.Level.Info, "Cave generated (difficulty = %s)", difficulty)
```

Calling these functions at the module level (Logging) calls the respective method
on the root logger object. It is better to use logger objects directly - read on!

## `Logger` Objects

Use `Logging:getLogger` to get a Logger with the name of whatever cool thing you
happen to be making. Loggers contain the same previously mentioned functions
(`debug`, `info`, `warning`, `error`, `critical` and `log`).

```lua
local logger = Logging:getLogger("MyFightingGame")
logger:info("Match started: %s vs %s", player1.Name, player2.Name)
```

Loggers exist in a **hierarchy**, much like Roblox objects. Every logger has one
parent, except the **root logger** (named "Logging"). If a system
uses a logger, then its sub-systems should use child loggers. You can use
`Logger:getChild` or `Logging:getLogger` with period-separated names to get
child loggers:

```lua
logger:getLogger("MyFightingGame.RoundSystem") -- OR
logger:getLogger("MyFightingGame"):getChild("RoundSystem")
```

### Levels

When a logger is used to create a log, also known as a record, its **effective level**
is determined: by default, loggers have a level of NotSet, which means they defer
to their parent's effective level. If the record's level is greater than or equal
to the logger's effective level, and the record satisfies the logger's filters,
the record is finally emit and passed to the logger's handlers!

```lua
logger:setLevel(Logging.Level.Info)
logger:debug("Calculating dingbat...") -- Ignore, because Debug < Info
logger:info("Rocket launched")         -- Emit, because Info == Info
logger:error("Sandwich storage full")  -- Emit, because Error > Info
```

Setting the level of the root logger is done with `Logging:basicConfig`, whose
default level is Warning. A record should be handled by at least one handler,
otherwise you'll get an "unhandled record" warning.

#### Filtering

Beyond the normal level filtering that is built in to loggers, you can also attach
functions that do your own filtering logic. Each filter is called with both the logger
itself and the record to filter. If any filter returns false, the record is ignored.

```lua
logger:addFilter(function (logger, record)
	-- Ignore messages shorter than 10 bytes:
	return record:getMessage():len() < 10
end)
```

### Propagation

When a logger emits a log it **propagates** the record to its ancestor's handlers
(unless `logger.propagates = false`). Note that the level and/or filters of the
ancestors are not considered when a record is propagated.

## `Handler` Objects

A **Handler** does something with log records. They can be added/removed to loggers:

```lua
logger:addHandler(handler)
logger:removeHandler(handler)
```

Handlers are abstract. See the following concrete implementations:

### `OutputHandler`

When you call `Logging:basicConfig`, the root logger gets a `OutputHandler` which
passes record messages to the built-in `print`/`warn` functions, depending on the
record level. This is your bread-and-butter handler for use in Roblox Studio's
[Output window](https://developer.roblox.com/en-us/articles/Debugging) and in
the [Developer Console](https://developer.roblox.com/en-us/articles/Developer-Console).

### `MemoryHandler`

A **MemoryHandler** stores a number of records in a buffer until it fills,
at which point it will flush all the records to a target handler (if set), then
empty. If it handles a record of level Error or higher, it flushes early.

### `NullHandler`

A **NullHandler** that doesn't do anything with records! How quaint. It is useful
for loggers that do not propagate logs to their parent, but need at least one handler
to avoid unhandled records.

### `FuncHandler`

A **FuncHandler** calls a function with a record immediately. If you pass a function
to `Logger:addHandler`, it will be automatically wrapped in a FuncHandler.

## Sugary Goodness

Logging is meant to be easy. To that end, there's some convenience Logger methods,
which are also available on the `Logging` module itself.

### Wrapping `print` and `warn`

If you like using the built-in `print` and `warn` functions, use `Logger:wrap`, which
returns two functions that replace them. Calling these will emit Debug/Warning records
accordingly. Like their original counterparts, they don't return anything.

```lua
-- Works great for using Logging in existing code:
local print, warn = logger:wrap()
print("Meow") -- works like logger:debug("Meow")
warn("Woof")  -- works like logger:warning("Woof")
```

Pass `true` to `wrap` and it will also call the original functions. This isn't recommended,
because it's preferable to attach an `OutputHandler` ideally using `Logging:basicConfig`.

### `pcall` and `xpcall`

Replace `pcall` &rarr; `logger:pcall` and `xpcall` &rarr; `logger:xpcall` and an
Error is logged automatically if the function raises one.

```lua
-- Replace pcall or xpcall with logger equivalent to warn if the function fails
logger:pcall(myUnsafeFunction, ...)
logger:xpcall(myUnsafeFunction, myErrorHandler, ...)
-- The module itself also has all these, which operate on a "root" logger:
Logging:debug("Hello, world")
```
