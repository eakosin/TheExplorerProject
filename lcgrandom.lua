lcgrandom = {}

--These values are from the Microsoft Visual C++ parameters. 
--GCC parameters produced very wrong results.
lcgrandom.m = (2 ^ 32)
lcgrandom.a = 214013
lcgrandom.c = 2531011

--No bitwise operators in Lua 5.1.
lcgrandom.bit = {}
lcgrandom.bit[32] = 2^32
lcgrandom.bit[31] = 2^31
lcgrandom.bit[16] = 2^16
lcgrandom.bit[15] = 2^15

lcgrandom.seed = 0

lcgrandom.current = 0

function lcgrandom:new(new)
	new = new or {}
	setmetatable(new, self)
	self.__index = self
	return new
end

function lcgrandom:seed(x)
	self.seed = x % self.m
	self.current = (((self.a * self.seed) + self.c) % self.m)
end

--Returns a 32bit unsigned value.
function lcgrandom:rawval()
	self.current = (((self.a * self.current) + self.c) % self.m)
	return self.current
end

--Returns a divided float range TODO
function lcgrandom:float(x,y)
	x = x or 1.0
	self.current = (((self.a * self.current) + self.c) % self.m)
	if(y) then
		return ((self.current / (self.bit[32] / (y - x))) + x)
	else
		return (self.current / (self.bit[32] / x))
	end
end

--Only use this if you need a range larger than 65535.
function lcgrandom:int32(x,y)
	x = x or self.bit[32]
	self.current = (((self.a * self.current) + self.c) % self.m)
	if(y) then
		return ((self.current % (y - x + 1)) + x)
	else
		return (self.current % (x + 1))
	end
end

--(x - y) cannot be greater than 65535.
function lcgrandom:int(x,y)
	x = x or self.bit[16]
	self.current = (((self.a * self.current) + self.c) % self.m)
	local current = self.current
	if((current - self.bit[31]) >= 0) then
		current = current - self.bit[31]
	end
	if(y) then
		return ((math.floor(current / self.bit[15]) % (y - x + 1)) + x)
	else
		return (math.floor(current / self.bit[15]) % (x + 1))
	end
end

function lcgrandom:reset()
	self.current = (((self.a * self.seed) + self.c) % self.m)
	return self.seed
end