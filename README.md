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

Dive right into the [Getting Started](https://docs.ozzypig.com/Logging/docs/getting-started)
guide for more.

## Development

* [Visual Studio Code](https://code.visualstudio.com/)
* Markdown (.md) linted using [markdownlint](https://github.com/DavidAnson/markdownlint)
* Luau code (.lua) linted using [selene](https://github.com/Kampfkarren/selene)
* Built using [Rojo 7](https://github.com/rojo-rbx/rojo):
  * **default.project.json** builds the library as a model,
    can be included in other Rojo projects which depend on this library.
  * **test.project.json** builds a place which runs unit tests
    (open in Roblox Studio and click Run).
    * Tests can be found in **tests/Tests.lua**
* Makefile included with several useful targets (`test`, `serve`) which operate
  on the Rojo project files above.
* **wally.toml**: package manifest for [wally](https://github.com/UpliftGames/wally)
* **moonwave.toml** Configuration for building documentation using [Moonwave](https://github.com/UpliftGames/moonwave)
