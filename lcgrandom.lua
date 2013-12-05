lcgrandom = {}

--These values are from the Microsoft Visual C++ parameters. 
--GCC parameters produced very wrong results.
lcgrandom.m = (2 ^ 32)
lcgrandom.a = 214013
lcgrandom.c = 2531011

--No bitwise operators in Lua 5.1.
lcgrandom.bit = {}
lcgrandom.bit[31] = 2^31
lcgrandom.bit[15] = 2^15

lcgrandom.seed = 0

lcgrandom.current = 0

function lcgrandom.seed(x)
	lcgrandom.seed = x % lcgrandom.m
	lcgrandom.current = (((lcgrandom.a * lcgrandom.seed) + lcgrandom.c) % lcgrandom.m)
end

--Returns a 32bit unsigned value.
function lcgrandom.rawval()
	lcgrandom.current = (((lcgrandom.a * lcgrandom.current) + lcgrandom.c) % lcgrandom.m)
	return lcgrandom.current
end

--Returns a divided float range TODO
function lcgrandom.float()
	lcgrandom.current = (((lcgrandom.a * lcgrandom.current) + lcgrandom.c) % lcgrandom.m)
	if(y) then
		return ((current / (y - x + 1)) + x)
	else
		return (current % (x + 1))
	end
end

--Only use this if you need a range larger than 65535.
function lcgrandom.int32(x,y)
	lcgrandom.current = (((lcgrandom.a * lcgrandom.current) + lcgrandom.c) % lcgrandom.m)
	if(y) then
		return ((lcgrandom.current % (y - x + 1)) + x)
	else
		return (lcgrandom.current % (x + 1))
	end
end

--(x - y) cannot be greater than 65535.
function lcgrandom.int(x,y)
	lcgrandom.current = (((lcgrandom.a * lcgrandom.current) + lcgrandom.c) % lcgrandom.m)
	local current = lcgrandom.current
	if((current - lcgrandom.bit[31]) >= 0) then
		current = current - lcgrandom.bit[31]
	end
	if(y) then
		return ((math.floor(current / lcgrandom.bit[15]) % (y - x + 1)) + x)
	else
		return (math.floor(current / lcgrandom.bit[15]) % (x + 1))
	end
end

function lcgrandom.reset()
	lcgrandom.current = (((lcgrandom.a * lcgrandom.seed) + lcgrandom.c) % lcgrandom.m)
	return lcgrandom.seed
end