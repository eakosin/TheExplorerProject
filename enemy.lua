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


function enemy:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.stats = {health = 100, energy = 50, damage = 5, defense = 5, status = {}}
	return new
end



function enemy:initialize()
	--self.image = love.graphics.newImage("images/"..self.imageName)
end



function enemy:placeEnemy(x, y)
	self.x = x
	self.y = y
end



function enemy:fillEventQueue()


end




function enemy:processChanges()



end




function enemy:draw()
	love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 8, 32, 0, 0 )
end
