require("map/mapTypes")
require("helpers")
require("map/mapGeneration")
require("lcgrandom")

level = {}
level.width, level.height = 125,125
level.tileSize = {x = 32, y = 32}
level.layers = {terrain = {}, decorate = {}, dynamic = {}}
level.seed = 0
level.lcgrandom = lcgrandom:new()

function level:new(level)
	level = level or {}
	setmetatable(level, self)
	self.__index = self
	return self
end

function level:generate(seed)
	self.seed = seed
	self.lcgrandom:seed(seed)
	--[[self.width = helpers.int(weighting.oddExp(self.lcgrandom:float(),3,100,.6,-74,10))
	self.height = helpers.int(weighting.oddExp(self.lcgrandom:float(),3,100,.6,-74,0))]]--
	self.width = 125
	self.height = 125
	self.layers.terrain.map = map:new()
	self.layers.terrain.map:buildMap(self.width,self.height)
	mapGeneration.generate(self)
end


function level:prepareSpriteBatches()
	local numTiles = {x = 0, y = 0}
	self.layers.terrain.tileImage = love.graphics.newImage("images/"..self.layers.terrain.tileImageName)
	self.layers.terrain.spriteBatch = love.graphics.newSpriteBatch(self.layers.terrain.tileImage,1000000)
	numTiles.x = helpers.int(self.layers.terrain.tileImage:getWidth()/self.tileSize.x)
	numTiles.y = helpers.int(self.layers.terrain.tileImage:getHeight()/self.tileSize.y)
	self.layers.terrain.quad = {}
	for tx = 1,numTiles.x do
		for ty = 1,numTiles.y do
			self.layers.terrain.quad[tx+((ty-1)*numTiles.x)] = love.graphics.newQuad(((tx-1)*self.tileSize.x),((ty-1)*self.tileSize.y),
																				self.tileSize.x,self.tileSize.y,
																				self.layers.terrain.tileImage:getWidth(),self.layers.terrain.tileImage:getHeight())
		end
	end
	self.layers.terrain.map:addMapLayer("spriteBatchID",0)
	for x=1,self.layers.terrain.map.width do
		for y=1,self.layers.terrain.map.height do
			self.layers.terrain.map.spriteBatchID[x][y] = self.layers.terrain.spriteBatch:add(self.layers.terrain.quad[self.layers.terrain.map.grid[x][y]],((x-1)*self.tileSize.x),((y-1)*self.tileSize.y))
		end
	end
	
end

function level:draw()
	love.graphics.draw(self.layers.terrain.spriteBatch)
end