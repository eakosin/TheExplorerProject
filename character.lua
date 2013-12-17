require("helpers")

character = {}

character.world = {}
character.id = 0
character.name = ""
character.imageName = "crapcharacter.png"
character.x, character.y = 0,0
character.dn, character.ds, character.dw, character.de = 0,0,0,0
character.canMove = {north = true, south = true, west = true, east = true}

function character:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.canMove = {north = true, south = true, west = true, east = true}
	return new
end

function character:initialize()
	self.image = love.graphics.newImage("images/"..self.imageName)
end

function character:placeCharacter(x, y)
	self.x = x
	self.y = y
end

function character:recieveInput(keys)
	if(keys.up) then
		self.dn = -8
	else
		self.dn = 0
	end
	if(keys.down) then
		self.ds = 8
	else
		self.ds = 0
	end
	if(keys.left) then
		self.dw = -8
	else
		self.dw = 0
	end
	if(keys.right) then
		self.de = 8
	else
		self.de = 0
	end
end

function character:fillEventQueue()
	if(self.dn ~= 0 or self.ds ~= 0 or self.dw ~= 0 or self.de ~= 0) then
		self.world.eventQueue.level[#self.world.eventQueue.level + 1] = {destination = "currentlevel",
																		name = "collision",
																		object = self,
																		x = self.x, y = self.y,
																		ds = self.ds, dn = self.dn, dw = self.dw, de = self.de}
	end
end

function character:move()
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

function character:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 8, 32, 0, 0 )
end