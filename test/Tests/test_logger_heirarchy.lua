--- Logging:getLogger should propery create the logger heirarchy.
function test_logger_heirarchy(Logging)
	assert(Logging:getRootLogger() == Logging:getRootLogger(), "Failed root Logger idempotency check")
	assert(Logging:getLogger("foo") == Logging:getLogger("foo"), "Failed Logger idempotency check")
	assert(Logging:getLogger("a.b.c").parent == Logging:getLogger("a.b"), "Failed Logger parent check")
	assert(Logging:getLogger("a.b.c").parent.parent == Logging:getLogger("a"), "Failed Logger grandparent check")
	assert(Logging:getLogger("x.y") == Logging:getLogger("x.y.z").parent, "Failed Logger parent check (reverse)")
	assert(Logging:getLogger("x") == Logging:getLogger("x.y.z").parent.parent, "Failed Logger grandparent check (reverse)")
end

return test_logger_heirarchy
