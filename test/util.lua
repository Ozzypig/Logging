local util = {}

function util.compare(t0, t1)
	for k, v in pairs(t0) do
		if v ~= t1[k] then
			return false, k
		end
	end
	for k, v in pairs(t1) do
		if v ~= t0[k] then
			return false, k
		end
	end
	return true, nil
end

function util.assertCompare(m, t0, t1)
	assert(typeof(m) == "string", "string expected")
	assert(typeof(t0) == "table", "table expected")
	assert(typeof(t1) == "table", "table expected")
	local areSame, k = util.compare(t0, t1)
	assert(areSame, ("%s (key = %s: %s, %s)"):format(m, tostring(k), tostring(t0[k]), tostring(t1[k])))
end

function util.matchEnd(haystack, needle)
	return haystack:sub(haystack:len() - needle:len() + 1, haystack:len()) == needle
end

return util
