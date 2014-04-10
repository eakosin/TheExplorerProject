require("map/mapTypes")
require("helpers")
require("map/mapGeneration")
require("lcgrandom")

level = {terrain = {}, decorate = {}, dynamic = {}}
level.world = {}
level.id = 0
level.name = "Level 0"
level.tileSize = {x = 32, y = 32}
level.seed = 0

function level:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.terrain = {}
	new.decorate = {}
	new.dynamic = {}
	new.tileSize = {x = 32, y = 32}
	new.lcgrandom = lcgrandom:new()
	return new
end

function level:initialize(seed)
	self.seed = seed
	self.lcgrandom:seed(self.seed)
	--[[self.width = helpers.int(weighting.oddExp(self.lcgrandom:float(),3,100,.6,-74,10))
	self.height = helpers.int(weighting.oddExp(self.lcgrandom:float(),3,100,.6,-74,0))]]--
	self.width = 75
	self.height = 75
	self.terrain.map = map:new()
	self.terrain.map:buildMap(self.width,self.height)
	mapGeneration.generation(self)
	self.width, self.height = self.terrain.map.width, self.terrain.map.height
	self.decorate.map = map:new()
	self.decorate.map:buildMap(self.width,self.height)
	mapGeneration.decoration(self)
end

--SUPER TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--[[
function level:saveParameters()
	io.output("./parameters.txt", "w")
	--Print Parameters DEBUG
	if(type(self.terrain.scripts[scriptType][script.id][parameter]) == "table") then
		io.write(tostring(parameter)..":\n")
		for k,v in pairs(self.terrain.scripts[scriptType][script.id][parameter]) do
			io.write(tostring(k)..": "..tostring(v).."\n")
		end
	else
		io.write(tostring(parameter)..": "..tostring(self.terrain.scripts[scriptType][script.id][parameter]))
	end
	--Print Depend Parameters DEBUG
	if(type(self.terrain.scripts[scriptType][script.id][parameter]) == "table") then
		io.write(tostring(parameter)..":\n")
		for k,v in pairs(self.terrain.scripts[scriptType][script.id][parameter]) do
			io.write(tostring(k)..": "..tostring(v).."\n")
		end
	else
		io.write(tostring(parameter)..": "..tostring(self.terrain.scripts[scriptType][script.id][parameter]))
	end
	io.close()
end
]]--

function level:clearParameters()
	self.terrain.scripts = nil
	collectgarbage()
end
	
function level:prepareSpriteBatches()
	--Terrain Sprite Batch
	local numTiles = {x = 0, y = 0}
	self.terrain.tileImage = love.graphics.newImage("images/"..self.terrain.tileImageName)
	self.terrain.spriteBatch = love.graphics.newSpriteBatch(self.terrain.tileImage,100000)
	self.terrain.spriteBatch:bind()
	numTiles.x = helpers.int(self.terrain.tileImage:getWidth()/self.tileSize.x)
	numTiles.y = helpers.int(self.terrain.tileImage:getHeight()/self.tileSize.y)
	self.terrain.quad = {}
	for tx = 1,numTiles.x do
		for ty = 1,numTiles.y do
			self.terrain.quad[tx+((ty-1)*numTiles.x)] = love.graphics.newQuad(((tx-1)*self.tileSize.x),((ty-1)*self.tileSize.y),
																				self.tileSize.x,self.tileSize.y,
																				self.terrain.tileImage:getWidth(),self.terrain.tileImage:getHeight())
		end
	end
	self.terrain.map:addMapLayer("spriteBatchID",0)
	for x=1,self.terrain.map.width do
		for y=1,self.terrain.map.height do
			if(self.terrain.map.grid[x][y] ~= self.terrain.map.tileset.none) then
				self.terrain.map.spriteBatchID[x][y] = self.terrain.spriteBatch:add(self.terrain.quad[self.terrain.map.grid[x][y]],((x-1)*self.tileSize.x),((y-1)*self.tileSize.y))
			end
		end
	end
	self.terrain.spriteBatch:unbind()
	--Decoration Sprite Batch
	local numTiles = {x = 0, y = 0}
	self.decorate.tileImage = love.graphics.newImage("images/"..self.decorate.scripts.decorate.tileImageName)
	self.decorate.spriteBatch = love.graphics.newSpriteBatch(self.decorate.tileImage,100000)
	self.decorate.spriteBatch:bind()
	numTiles.x = helpers.int(self.decorate.tileImage:getWidth()/self.tileSize.x)
	numTiles.y = helpers.int(self.decorate.tileImage:getHeight()/self.tileSize.y)
	self.decorate.quad = {}
	for tx = 1,numTiles.x do
		for ty = 1,numTiles.y do
			self.decorate.quad[(tx+((ty-1)*numTiles.x))+127] = love.graphics.newQuad(((tx-1)*self.tileSize.x),((ty-1)*self.tileSize.y),
																				self.tileSize.x,self.tileSize.y,
																				self.decorate.tileImage:getWidth(),self.decorate.tileImage:getHeight())
		end
	end
	self.decorate.map:addMapLayer("spriteBatchID",0)
	for x=1,self.decorate.map.width do
		for y=1,self.decorate.map.height do
			if(self.decorate.map.grid[x][y] ~= self.decorate.map.tileset.none) then
				--debugLog:append("x: "..tostring(x).." y: "..tostring(y).." - "..tostring(self.decorate.map.grid[x][y]))
				self.decorate.map.spriteBatchID[x][y] = self.decorate.spriteBatch:add(self.decorate.quad[self.decorate.map.grid[x][y]],((x-1)*self.tileSize.x),((y-1)*self.tileSize.y))
			end
		end
	end
	self.decorate.spriteBatch:unbind()
end

function level:fillEventQueue()
	
end

function level:processEvent(event)
	if(event.name == "collisionplayer") then
		topLeftCorner = {x = event.object.x, y = event.object.y}
		topRightCorner = {x = event.object.x + (event.object.image:getWidth() * 0.5), y = event.object.y}
		bottomLeftCorner = {x = event.object.x, y = event.object.y + (event.object.image:getHeight() * 0.75)}
		bottomRightCorner = {x = event.object.x + (event.object.image:getWidth() * 0.5), y = event.object.y + (event.object.image:getHeight() * 0.75)}
		debugLog:append("topLeftCorner "..tostring(topLeftCorner.x / 32).." "..tostring(topLeftCorner.y / 32).."\n")
		debugLog:append("bottomRightCorner "..tostring(bottomRightCorner.x / 32).." "..tostring(bottomRightCorner.y / 32).."\n")
		if(self.terrain.map.grid[helpers.int(topLeftCorner.x / 32) + 1][helpers.int(((topLeftCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int(topRightCorner.x / 32) + 1][helpers.int(((topRightCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int(bottomLeftCorner.x / 32) + 1][helpers.int(((bottomLeftCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int(bottomRightCorner.x / 32) + 1][helpers.int(((bottomRightCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall) then
			event.object.canMove.y = false
		end
		if(self.terrain.map.grid[helpers.int((topLeftCorner.x + event.object.dx) / 32) + 1][helpers.int((topLeftCorner.y / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((topRightCorner.x + event.object.dx) / 32) + 1][helpers.int((topRightCorner.y / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((bottomLeftCorner.x + event.object.dx) / 32) + 1][helpers.int((bottomLeftCorner.y / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((bottomRightCorner.x + event.object.dx) / 32) + 1][helpers.int((bottomRightCorner.y / 32)) + 1] == self.terrain.map.tileset.wall) then
			event.object.canMove.x = false
		end
	--Generic bounding box based collision checking.
	--Use object.x, object.y and (object.x + object.image.getWidth()) and (object.y + object.image.getHeight()) to find the bounding box.
	elseif(event.name == "collision") then
		--debugLog:append(tostring(helpers.int((event.object.x + 32) / 32))..","..tostring(helpers.int(((event.object.y + 32) / 32))).." - "..tostring(self.terrain.map.grid[helpers.int((event.object.x / 32) + 32)][helpers.int((event.object.y / 32))]))
		topLeftCorner = {x = event.object.x, y = event.object.y}
		topRightCorner = {x = event.object.x + (event.object.image:getWidth() * (event.object.image:getWidth() / 32)), y = event.object.y}
		bottomLeftCorner = {x = event.object.x, y = event.object.y + (event.object.image:getHeight() * (event.object.image:getHeight() / 32))}
		bottomRightCorner = {x = event.object.x + (event.object.image:getWidth() * (event.object.image:getWidth() / 32)), y = event.object.y + (event.object.image:getHeight() * (event.object.image:getHeight() / 32))}
		if(self.terrain.map.grid[helpers.int((topLeftCorner.x + event.object.dx) / 32) + 1][helpers.int(((topLeftCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((topRightCorner.x + event.object.dx) / 32) + 1][helpers.int(((topRightCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((bottomLeftCorner.x + event.object.dx) / 32) + 1][helpers.int(((bottomLeftCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall or
		   self.terrain.map.grid[helpers.int((bottomRightCorner.x + event.object.dx) / 32) + 1][helpers.int(((bottomRightCorner.y + event.object.dy) / 32)) + 1] == self.terrain.map.tileset.wall) then
			event.object.canMove = false
		end
	end
end

function level:draw()
	love.graphics.draw(self.terrain.spriteBatch)
	love.graphics.draw(self.decorate.spriteBatch)
end
