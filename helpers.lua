--Ternary reduced performance over if clause.
function string:split(pattern)
	local originalString = self
	local splitstring = {}
	while(originalString) do
		left, right = originalString:find(pattern)
		if((not left) or (not right)) then
			splitstring[#splitstring+1], originalString = originalString, nil
		else
			splitstring[#splitstring+1], originalString  = originalString:sub(0,(left-1)), originalString:sub(right+1)
		end
	end
	return splitstring
end

--Faster if only a single split is required.
function string:divide(pattern)
	left, right = self:find(pattern)
	return self:sub(0,(left-1)), self:sub(right+1)
end



helpers = {}

--Using an index is slower in tables less than 10000 items in size.
function helpers.keys(tblin)
	local keys = {}
	local tbliter = tablin
	for key, value in pairs(tblin) do
		keys[#keys+1] = key
	end
	return keys
end

--Performance optimized. The else 0 prevents the enormous overhead of
--function calls.
function helpers.round(value)
	if(value > 0) then
		return math.floor(value + 0.5)
	elseif(value < 0) then
		return math.ceil(value - 0.5)
	else
		return 0
	end
end

--Performance optimized. The else 0 prevents the enormous overhead of
--function calls.
function helpers.int(value)
	if(value > 0) then
		return math.floor(value)
	elseif(value < 0) then
		return math.ceil(value)
	else
		return 0
	end
end

--[[
I'm sure you're asking yourself right now this question,
"Why would he duplicate functionality? Can't he just call helpers.int()?"
Yes, I could. But this is game being developed, and performance is important.
When all I have is 16ms to accomplish every piece of logic and the entire render
process, the saving of a few microseconds is valuable:
Computing int: 7.4250074310112e-007 sec
Using helpers.int():8.5221269808244e-007 sec
]]--

function helpers.odd(value,up)
	if(value > 0) then
		return math.floor(value)
	elseif(value < 0) then
		return math.ceil(value)
	else
		return 0
	end
	if(value == 0) then
		return ((up and 1) or -1)
	elseif(math.fmod(value,2) == 0) then
		return value + (((up and 1) or -1) * (value / math.abs(value)))
	else
		return value
	end
end

function helpers.even(value,up)
	if(value > 0) then
		value = math.floor(value)
	elseif(value < 0) then
		value = math.ceil(value)
	else
		value = 0
	end
	if(math.fmod(value,2) ~= 0) then
		return value + (((up and 1) or -1) * (value / math.abs(value)))
	else
		return value
	end
end