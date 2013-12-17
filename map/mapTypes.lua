require("tiles")

map = {}
map.width, map.height = 0, 0
tiles.buildTileset()
map.tileset = tiles.returnTileset()
map.grid = {}

function map:new(new)
	new = new or {}
	setmetatable(new, self)
	self.__index = self
	new.grid = {}
	return new
end

function map:buildMap(inwidth, inheight)
	self.width, self.height = (inwidth or 0), (inheight or 0)
	for x=1,self.width do
		self.grid[x] = {}
		for y=1,self.height do
			self.grid[x][y] = self.tileset.none
		end
	end
end

function map:addMapLayer(name,fillValue)
	self[name] = {}
	for x=1,self.width do
		self[name][x] = {}
		for y=1,self.height do
			self[name][x][y] = fillValue
		end
	end
end

function map:printMap(spacer)
	for y=1,self.height do
		for x=1,self.width do
			io.write(self.grid[x][y]..spacer)
		end
		io.write("\n")
	end
end

function map:printReadableMap(spacer)
	local conversion = {'.','+','#','~'}
	for y=1,self.height do
		for x=1,self.width do
			io.write(conversion[self.grid[x][y]]..spacer)
		end
		io.write("\n")
	end
end