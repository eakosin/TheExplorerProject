require("helpers")

camera = {}
camera.x = 0
camera.y = 0
camera.lx = 0
camera.ly = 0

function camera.bound(value,lower,upper)
	return (value > upper and upper) or (value < lower and lower) or value
end

function camera.move(x,y)
	camera.x = camera.x + x
	camera.x = camera.bound(camera.x,-((60*32)-800),0)
	camera.y = camera.y + y
	camera.y = camera.bound(camera.y,-((60*32)-600),0)
end

function camera.dx()
	return camera.x - camera.lx
end

function camera.dy()
	return camera.y - camera.ly
end

function camera.getPosition()
	camera.lx, camera.ly = camera.x, camera.y
	return camera.x, camera.y
end