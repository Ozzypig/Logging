---
sidebar_position: 3
---
# Differences from Python logging

Although this library is based on the [Python logging](https://docs.python.org/3/library/logging.html)
library, it is not meant to be a full re-implementation. There are key differences
as a result of Roblox's sandbox, and the result is a significantly less complex module.

## Record Messages

Record content should always be strings. The Python library provides additional
flexibility.

## Exception Logging

Lua does not have a native object that represents an error; it simply deals in
strings. As such, [Logger:exception](https://docs.python.org/3/library/logging.html#logging.Logger.exception)
does not exist.

## Thread Safety

Roblox does not support true multithreading, so there is no mechanism (or need)
to serialize access to underlying I/O functionality on handlers. This library was
did not need to be designed with thread safety in mind.

## Handler Limitations

### Stream or File Handlers

Roblox does not provide access to the file system, so this library does not
include record handlers which work with files, such as:
[WatchedFileHandler](https://docs.python.org/3/library/logging.handlers.html#watchedfilehandler),
[RotatingFileHandler](https://docs.python.org/3/library/logging.handlers.html#rotatingfilehandler),
or [TimedRotatingFileHandler](https://docs.python.org/3/library/logging.handlers.html#timedrotatingfilehandler.
)

### Socket Handlers

Roblox does not provide access to sockets, which excludes
[SocketHandler](https://docs.python.org/3/library/logging.handlers.html#sockethandler),
[DatagramHandler](https://docs.python.org/3/library/logging.handlers.html#datagramhandler),
and [SMTPHandler](https://docs.python.org/3/library/logging.handlers.html#smtphandler).
Serializing/deserializing objects is often done using JSON; Lua does not have a
[pickle](https://docs.python.org/3/library/pickle.html) equivalent.

### System Event Handlers

Roblox does not provide access to operating system level logging, so
[SysLogHandler](https://docs.python.org/3/library/logging.handlers.html#sysloghandler)
and [NTEventLogHandler](https://docs.python.org/3/library/logging.handlers.html#nteventloghandler)
are out.
