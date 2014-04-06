require("helpers")

enemy = {}

enemy.world = {}
enemy.id = 0
enemy.name = ""
enemy.imageName = "crapenemy.png"
enemy.x, enemy.y = 0,0
enemy.dx, enemy.dy = 0,0
enemy.canMove = true
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
	self.world.eventQueue.ai[#self.world.eventQueue.ai + 1] = {1, name = "enemyai", object = self}
--publish update event to AI object
end


function enemy:processEvent(event)

end



--[[
enemy:processChanges()
This function call processChanges in every existing object in enemy.
]]--
--param: none
--return: none
function enemy:processChanges()


end



--[[
enemy.draw()
Call draw in enemy to display on screen.
]]--
--param: none
--return: none
function enemy:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, self.image:getWidth(), self.image:getHeight(), 0, 0 )
end
