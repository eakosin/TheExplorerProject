require("helpers")

camera = {}
camera.x = 0
camera.y = 0
camera.lx = 0
camera.ly = 0

function camera:move(x,y)
	self.x = self.x + x
	self.y = self.y + y
end

function camera:dx()
	return camera.x - camera.lx
end

function camera:dy()
	return camera.y - camera.ly
end

function camera:getPosition()
	self.lx, self.ly = self.x, self.y
	return self.x, self.y
end