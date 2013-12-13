require("map/mapTypes")
require("helpers")
require("map/mapGeneration")
require("lcgrandom")

level = {}
level.width, level.height = 125,125
level.maps = {}
level.scripts = {}
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
	self.maps.base = map:new()
	self.maps.base:buildMap(self.width,self.height)
	mapGeneration.generate(self)
end

function level:prepareForDrawing()

end

function level:draw()
	
end