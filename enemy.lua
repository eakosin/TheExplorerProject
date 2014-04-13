require("helpers")

enemy = {}

enemy.world = {}
enemy.type = "enemy"
enemy.id = 0
enemy.name = ""
enemy.imageName = "crapenemy.png"
enemy.width, enemy.height = 0,0
enemy.x, enemy.y = 0,0
enemy.dx, enemy.dy = 0,0
enemy.canMove = false
enemy.stats = {health = 100, energy = 50, damage = 5, defense = 5, status = {}}


--[[
enemy:new(world)
This function pass the world object.
]]--
--param: world
--return: new
function enemy:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.stats = {health = 100, energy = 50, damage = 5, defense = 5, status = {}}
	return new
end


--[[
enemy:initialize()
This function initialize the enemy.
]]--
--param: none
--return: none
function enemy:initialize()
	self.image = love.graphics.newImage("images/"..self.imageName)
end


--[[
enemy:placeEnemy(x, y)
This function places enemy on the grid.
]]--
--param: x
--param: y
--return: none
function enemy:placeEnemy(x, y)
	self.x = x
	self.y = y
end


--[[
enemy:fillEventQueue()
This function calls fillEventQueue in every object in enemy.
]]--
--param: none
--return: none
function enemy:fillEventQueue()
	if(self.dx ~= 0 or self.dy ~= 0) then
		self.world.eventQueue.level[#self.world.eventQueue.level + 1] = {destination = "currentlevel",
																		name = "collision",
																		object = self}
	end
	if(self.dx ~= 0 or self.dy ~= 0) then
		self.world.eventQueue.character[#self.world.eventQueue.character + 1] = {destination = "all",
																		name = "collision",
																		object = self}
	end
	if(self.dx ~= 0 or self.dy ~= 0) then
		self.world.eventQueue.enemy[#self.world.eventQueue.enemy + 1] = {destination = "all",
																		name = "collision",
																		object = self}
	end
	self.world.eventQueue.ai[#self.world.eventQueue.ai + 1] = {1, name = "enemyai", object = self}
	self.canMove = true
--publish update event to AI object
end

--[[
enemy:processEvent()
This function calls processEvent in every object in enemy.
]]--
--param: event
--return: none
function enemy:processEvent(event)
	if(event.name == "collision") then
		if(event.object ~= self) then
			if(not ((event.object.x + event.object.dx > self.x + self.image:getWidth()) or
				 (event.object.x + event.object.dx + event.object.image:getWidth() < self.x) or
				 (event.object.y + event.object.dy > self.y + self.image:getHeight()) or
				 (event.object.y + event.object.dy + event.object.image:getHeight() < self.y))) then
				event.object.canMove = false
			end
		end
	elseif(event.name == "collisionplayer") then
		if(event.object ~= self) then
			while(math.abs(event.object.dx) > 0) do
				if(not ((event.object.x + event.object.dx > self.x + self.image:getWidth() - 1) or
					 (event.object.x + event.object.dx + event.object.image:getWidth() - 1 < self.x) or
					 (event.object.y > self.y + self.image:getHeight() - 1) or
					 (event.object.y + event.object.image:getHeight() - 1 < self.y))) then
					event.object.dx = event.object.dx - (math.abs(event.object.dx) / event.object.dx)
				else
					break
				end
			end
			while(math.abs(event.object.y) > 0) do
				if(not ((event.object.x > self.x + self.image:getWidth() - 1) or
						   (event.object.x + event.object.image:getWidth() - 1 < self.x) or
						   (event.object.y + event.object.dy > self.y + self.image:getHeight() - 1) or
						   (event.object.y + event.object.dy + event.object.image:getHeight() - 1 < self.y))) then
					event.object.dy = event.object.dy - (math.abs(event.object.dy) / event.object.dy)
				else
					break
				end
			end
			state = true
			while(math.abs(event.object.y) > 0 and math.abs(event.object.x) > 0) do
				if(not ((event.object.x + event.object.dx > self.x + self.image:getWidth() - 1) or
						   (event.object.x + event.object.dx + event.object.image:getWidth() - 1 < self.x) or
						   (event.object.y + event.object.dy > self.y + self.image:getHeight() - 1) or
						   (event.object.y + event.object.dy + event.object.image:getHeight() - 1 < self.y))) then
					if(state and math.abs(event.object.x) > 0) then
						event.object.dx = event.object.dx - (math.abs(event.object.dx) / event.object.dx)
					elseif(math.abs(event.object.y) > 0) then
						event.object.dy = event.object.dy - (math.abs(event.object.dy) / event.object.dy)
					end
					state = not state
				else
					break
				end
			end
		end
	end
end

--[[
enemy:processChanges()
This function call processChanges in every existing object in enemy.
]]--
--param: none
--return: none
function enemy:processChanges()
	if(self.canMove) then
		self.x = self.x + self.dx
		self.y = self.y + self.dy
	end
end



--[[
enemy.draw()
Call draw in enemy to display on screen.
]]--
--param: none
--return: none
function enemy:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 0, 0, 0, 0 )
end
