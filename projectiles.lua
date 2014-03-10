require("helpers")

projectile = {}

projectile.world = {}
projectile.id = 0
projectile.name = ""
projectile.imageName = "crapprojectile.png"
projectile.x, projectile.y = 0,0
projectile.dx, projectile.dy = 0,0
projectile.destx, projectile.desty = 0,0
projectile.speed = 0
projectile.path = {}
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
	--self.image = love.graphics.newImage("images/"..self.imageName)
	self.destx = destx or self.destx
	self.desty = desty or self.destx
	self.speed = speed or self.speed
	self.path = path
end
function projectile:placeProjectile(x, y)
	self.x = x
	self.y = y
end
function projectile:fillEventQueue()
	--process curve, calc dx and dy based off of speed/path
end
function projectile:processEvent(event)
	--change or modify projectile based off of user action and projectile calss
end
function projectile:processChanges()
	if (self.canMove = false)
		then
		--dissapear, destroy, sick, etc.
	else
		--cont. moving based of of changes in fill event queue
	end
end
function projectile:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 8, 32, 0, 0 )
end
