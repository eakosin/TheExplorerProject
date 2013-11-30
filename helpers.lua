function string:split(pattern)
	left, right = self:find(pattern)
	return self:sub(0,(left-1)), self:sub(right+1)
end

--TODO: Make it work...
function string:splitmulti(pattern)
	local splitstring = {}
	local index = 1
	for left, right in pairs({self:find(pattern)}) do
		splitstring[index], splitstring[index+1] = self:sub(0,(left-1)), self:sub(right+1)
		index = index + 2
	end
	return splitstring
end

helpers = {}

function helpers.keys(tblin)
	local keys = {}
	local tbliter = tablin
	for key, value in pairs(tblin) do
		keys[#keys+1] = key
	end
	return keys
end

--TODO: Simplify and performance
function helpers.round(value)
	if(value > 0) then
		return math.floor(value + 0.5)
	elseif(value < 0) then
		return math.ceil(value - 0.5)
	else
		return 0
	end
end

--TODO: Simplify and performance
function helpers.int(value)
	if(value > 0) then
		return math.floor(value)
	elseif(value < 0) then
		return math.ceil(value)
	else
		return 0
	end
end

--TODO: If possible simplify and performance
function helpers.odd(value,up)
	value = helpers.int(value)
	if(value == 0) then
		return ((up and 1) or -1)
	elseif(math.fmod(value,2) == 0) then
		return value + (((up and 1) or -1) * (value / math.abs(value)))
	else
		return value
	end
end

--TODO: If possible simplify and performance
function helpers.even(value,up)
	sign = (value / math.abs(value))
	if(value == 0) then
		return 0
	else
		return helpers.odd((value + ((up and sign) or 0)), true) - sign
	end
end