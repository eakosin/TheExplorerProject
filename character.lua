require("helpers")

character = {}

character.world = {}
character.id = 0
character.name = ""
character.isPlayer = true
character.imageName = "crapcharacter.png"
character.x, character.y = 0,0
character.dn, character.ds, character.dw, character.de = 0,0,0,0
character.canMove = {north = true, south = true, west = true, east = true}
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
This function...
]]--
--param: none
--return: none
function character:fillEventQueue()
	if(self.world.keyState.up) then
		self.dn = -8
	else
		self.dn = 0
	end
	if(self.world.keyState.down) then
		self.ds = 8
	else
		self.ds = 0
	end
	if(self.world.keyState.left) then
		self.dw = -8
	else
		self.dw = 0
	end
	if(self.world.keyState.right) then
		self.de = 8
	else
		self.de = 0
	end
	if(self.dn ~= 0 or self.ds ~= 0 or self.dw ~= 0 or self.de ~= 0) then
		self.world.eventQueue.level[#self.world.eventQueue.level + 1] = {destination = "currentlevel",
																		name = "collision",
																		object = self}
	end
end



function character:processEvent()

end



--[[
character:processChanges()
This function
]]--
--param: none
--return: none
function character:processChanges()
	if(self.canMove.north) then
		self.y = self.y + self.dn
	end
	if(self.canMove.south) then
		self.y = self.y + self.ds
	end
	if(self.canMove.west) then
		self.x = self.x + self.dw
	end
	if(self.canMove.east) then
		self.x = self.x + self.de
	end
	self.canMove.north = true
	self.canMove.south = true
	self.canMove.west = true
	self.canMove.east = true
end

--[[
character:draw()

]]--
--param: none
--return: none
function character:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 8, 32, 0, 0 )
end
