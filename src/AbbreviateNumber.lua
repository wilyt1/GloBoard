local abbreviations =
	{ K = 4, M = 7, B = 10, T = 13, Qa = 16, Qi = 19, Sx = 22, Sp = 25, Oc = 28, No = 31, Dc = 34, Ud = 37, Dd = 40 }

return function(number, convergeStyle)
	assert(type(number) == "number", "Error: 'number' must be of type number.")

	if convergeStyle == "Comma" then
		return ("%d"):format(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	local text = ("%.f"):format(math.floor(number))

	for abbreviation, digit in abbreviations do
		if #text >= digit and #text < (digit + 3) then
			text = ("%.1f%s"):format(
				math.floor(number / 10 ^ (digit - 2)) * 10 ^ (digit - 2) / 10 ^ (digit - 1),
				abbreviation
			)
			break
		end
	end

	return text
end
