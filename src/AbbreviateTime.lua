local function formatTime(...)
	local parts = { ... }
	for index, part in parts do
		parts[index] = ("%02i"):format(part)
	end
	return table.concat(parts, ":")
end

return function(seconds)
	assert(type(seconds) == "number", "Error: 'seconds' must be of type number.")

	seconds = math.abs(seconds)

	return if seconds < 60
		then tostring(seconds)
		elseif seconds < 3600 then formatTime(seconds / 60, seconds % 60)
		elseif seconds < 86400 then formatTime(seconds / 3600, seconds % 3600 / 60, seconds % 60)
		else formatTime(seconds / 86400, seconds % 86400 / 3600, seconds % 3600 / 60, seconds % 60)
end
