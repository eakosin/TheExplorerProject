require("map/mapTypes")
require("helpers")
require("map/mapGeneration")

level = {}

function level:newLevel(script,width,height,seed,decay)
	level = {}
	setmetatable(level, self)
	self.__index = self
	self.image = love.graphics.newImage("images/craptileset.png")
	self.map = map:new()
	self.map:buildMap(width,height)
	mapGeneration.manualGeneration(script,self.map,seed,decay)
	io.output("./mapoutput.grid", "w")
	self.map:printMap(" ")
	io.close()
	return self
end

function level:buildSpriteBatch(tsx,tsy)
	self.spriteBatch = love.graphics.newSpriteBatch(self.image,10000)
	self.tsx, self.tsy = tsx,tsy
end

function level:buildQuads()
	self.quads = {}
	self.numTilesX = helpers.int(self.image:getWidth()/self.tsx)
	self.numTilesY = helpers.int(self.image:getHeight()/self.tsy)
	print(self.numTilesX, self.numTilesY)
	for tx = 1,self.numTilesX do
		self.quads[tx] = love.graphics.newQuad(((tx-1)*self.tsx),0,self.tsx,self.tsy,self.image:getWidth(),self.image:getHeight())
	end
end

function level:populateSpriteBatch()
	for y=1,self.map.height do
		for x=1,self.map.width do
			self.spriteBatch:add(self.quads[tonumber(self.map.grid[x][y])],((x-1)*self.tsx),((y-1)*self.tsy))
		end
	end
end

function level:draw()
	love.graphics.draw(self.spriteBatch)
end