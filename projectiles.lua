require("helpers")

projectile = {}

projectile.world = {}
projectile.id = 0
projectile.name = ""
projectile.imageName = "crapprojectile.png"
projectile.x, projectile.y = 0,0
projectile.dx, projectile.dy = 0,0
projectile.destx, projectile.desty = 0,0
projectile.speedScaler = {x = 0, y=0}
projectile.path = {pathType="linear",speed="3"}
projectile.canMove = true
projectile.stats = {class = "", energy = 0, damage = 5, defense = 5, status = {}}

function projectile:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.stats = {energy = 0, damage = 5, defense = 5, status = {}}
	return new
end
function projectile:initialize(destx, desty, speed, path)
	self.image = love.graphics.newImage("images/"..self.imageName)
	self.destx = destx or self.destx
	self.desty = desty or self.destx
	self.speed = speed or self.speed
	self.path = path or self.path
	self.speedScaler.x = ((self.destx - self.x)/(self.desty - self.y))
	self.speedScaler.y = 1 - ((self.destx - self.x)/(self.desty - self.y))
end
function projectile:placeProjectile(x, y)
	self.x = self.x + self.dx
	self.y = self.y + self.dy
end
function projectile:fillEventQueue()
	--process curve, calc dx and dy based off of speed/path
	self.dx = self.speedScaler.x * self.path.speed
	self.dy = self.speedScaler.y * self.path.speed
	self.world.eventQueue.world[#self.world.eventQueue.world+1]={name="collision", object=self}
	--self.level
end
function projectile:processEvent(event)
	--change or modify projectile based off of user action and projectile class
	width = event.object.image:getWidth()
	height = event.object.image:getHeight()
	topLeftCorner = {x = event.object.x + event.object.dx, y = event.object.y + event.object.dy}
	bottomRightCorner = {x = event.object.x + event.object.image:getWidth() ++ event.object.dx, 
							y = event.object.y + event.object.image:getHeight() + event.object.dy}
	if ((self.x >= topLeftCorner.x and self.y >= topLeftCorner.y) and 
		(self.x <= bottomRightCorner.x and self.y <= bottomRightCorner.y)) then
		event.object.canMove = false
	end
	if ((event.object.x >= self.x and event.object.y >= self.y) and 
		(event.object.x <= self.x + self.image:getWidth() and event.object.y <= self.y + self.image:getHeight())) then
		event.object.canMove = false
	end
end
function projectile:processChanges()
	if (self.canMove == false)
		then
		self.world.eventQueue.world[#self.world.eventQueue.world+1]={name="destroyprojectile", object=self}
	else
		--cont. moving based of of changes in fill event queue
		self.x = self.x + self.dx
		self.y = self.y + self.dy
	end
end
function projectile:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 8, 32, 0, 0 )
end