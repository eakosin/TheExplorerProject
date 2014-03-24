require("helpers")

character = {}

character.world = {}
character.id = 0
character.name = ""
character.isPlayer = true
character.imageName = "crapcharacter.png"
character.x, character.y = 0,0
--character.dn, character.ds, character.dw, character.de = 0,0,0,0
character.dx, character.dy = 0,0
-- character.canMove = {north = true, south = true, west = true, east = true}
character.canMove = {x = true, y = true}
character.stats = {health = 100, energy = 50, weapon = 5, armor = 5, status = {}}


--[[
character:new(world)
This function pass the world object.
]]--
--param: world
--return: new
function character:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.canMove = {north = true, south = true, west = true, east = true}
	new.stats = {health = 100, energy = 50, weapon = 5, armor = 5, status = {}}
	return new
end


--[[
character:initialize(isPlayer)
This function initialize the player.
]]--
--param: isPlayer
--return: none
function character:initialize(isPlayer)
	self.isPlayer = isPlayer
	self.image = love.graphics.newImage("images/"..self.imageName)
end


--[[
character:placeCharacter(x, y)
This function places character on the grid.
]]--
--param: x
--param: y
--return: none
function character:placeCharacter(x, y)
	self.x = x
	self.y = y
end



--[[
character:fillEventQueue()
This function calls fillEventQueue in every object in character.
]]--
--param: none
--return: none
function character:fillEventQueue()
	if(self.world.keyState.up) then
		self.dy = -8
	elseif(self.world.keyState.down) then
		self.dy = 8
	else
		self.dy = 0
	end
	if(self.world.keyState.left) then
		self.dx = -8
	elseif(self.world.keyState.right) then
		self.dx = 8
	else
		self.dx = 0
	end
	if(self.dy ~= 0 or self.dx ~= 0) then
		self.world.eventQueue.level[#self.world.eventQueue.level + 1] = {destination = "currentlevel",
																		name = "collisionplayer",
																		object = self}
	end
end



function character:processEvent()

end



--[[
character:processChanges()
This function call processChanges in every existing object in character.
]]--
--param: none
--return: none
function character:processChanges()
	if(self.canMove.x) then
		self.x = self.x + self.dx
	end
	if(self.canMove.y) then
		self.y = self.y + self.dy
	end
	self.canMove.x = true
	self.canMove.y = true
end

--[[
character.draw()
Call draw in character to display on screen.
]]--
--param: none
--return: none
function character:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 0, 0, 0, 0 )
end
