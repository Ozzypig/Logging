--- Logger:getChild should propery create the logger heirarchy.
function test_logger_getChild(Logging)
	assert(Logging:getRootLogger():getChild("baz") == Logging:getLogger("baz"), "Failed Logger idempotency check (getChild)")
	assert(Logging:getLogger("spam"):getChild("eggs") == Logging:getLogger("spam.eggs"), "Failed Logger:getChild")
	assert(Logging:getLogger("a.b"):getChild("c").parent == Logging:getLogger("a.b"), "Failed Logger parent check (getChild)")
	assert(Logging:getLogger("a"):getChild("b"):getChild("c").parent.parent == Logging:getLogger("a"), "Failed Logger grandparent check (getChild)")
	assert(Logging:getLogger("x.y") == Logging:getLogger("x.y"):getChild("z").parent, "Failed Logger parent check (reverse) (getChild)")
	assert(Logging:getLogger("x") == Logging:getLogger("x"):getChild("y"):getChild("z").parent.parent, "Failed Logger grandparent check (reverse) (getChild)")
end

return test_logger_getChild
