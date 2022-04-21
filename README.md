# Logging v0.2.0

**Logging** is a logging library for Roblox that takes after
[Python's logging](https://docs.python.org/3/library/logging.html) library. It
has no dependencies and is lightweight.

## Quick-Start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logging = require(ReplicatedStorage:WaitForChild("Logging"))
-- Do this just once at startup:
Logging:basicConfig{level="Debug"; format="%(name)s:%(level)s:%(message)s"}
-- Now log events when they happen:
Logging:debug("Hello, world")
-- Using a Logger object for your module/game:
local logger = Logging:getLogger("MyGame")
logger:debug("Created %d zombies", 5)
logger:info("Starting round with %d players", 2)
logger:warning("Watch out, the %s might %s", "balloon", "pop")
logger:error("DataStores might be down")
logger:critical("A real showstopper, closing server")
-- Filter logs lower than a certain level:
logger:setLevel("Info")
-- Use child loggers for subsystems:
logger:getChild("DataStores"):info("Loaded player data")
```

Dive right into the [Getting Started](docs/getting-started.md) guide for more.
Or check out the [docs](docs/index.md) directory (WIP).

## Development

This project is built using [Rojo 7](https://github.com/rojo-rbx/rojo), and linted
using [selene](https://github.com/Kampfkarren/selene).

* [default.project.json](default.project.json) builds the library as a model, and
  can be included in Rojo projects which depend on this library.
* [test.project.json](test.project.json) builds a place which runs unit tests
  (open in Roblox Studio and click Run).
  * Tests can be found in [tests/Tests.lua](tests/Tests.lua)

A [Makefile](Makefile) is included with several various useful targets (`test`, `serve`).
