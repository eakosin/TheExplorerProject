require("helpers")

camera = {}
camera.x = 0
camera.y = 0
camera.lx = 0
camera.ly = 0
camera.tileBound = {x = 0, y = 0}
camera.tileSize = {x = 32, y = 32}
camera.canvasSize = {width = 800, height = 600}

function camera.configureBoundries(tileBoundX, tileBoundY, tileSizeX, tileSizeY, canvasWidth, canvasHeight)
	camera.tileBound.x, camera.tileBound.y = tileBoundX, tileBoundY
	camera.tileSize.x, camera.tileSize.y = tileSizeX, tileSizeY
	camera.canvasSize.width, camera.canvasSize.height = canvasWidth, canvasHeight
end

function camera.bound(value,lower,upper)
	return (value > upper and upper) or (value < lower and lower) or value
end

function camera.move(x,y)
	camera.x = camera.x + x
	camera.x = camera.bound(camera.x,0,((camera.tileBound.x*camera.tileSize.x)-camera.canvasSize.width))
	camera.y = camera.y + y
	camera.y = camera.bound(camera.y,0,((camera.tileBound.y*camera.tileSize.y)-camera.canvasSize.height))
end

function camera.setPosition(x,y)
	camera.x = camera.bound(x,0,((camera.tileBound.x*camera.tileSize.x)-camera.canvasSize.width))
	camera.y = camera.bound(y,0,((camera.tileBound.y*camera.tileSize.y)-camera.canvasSize.height))
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

--Transform world coordinates to simulate camera direction.
function camera.getNegativePosition()
	camera.lx, camera.ly = camera.x, camera.y
	return -camera.x, -camera.y
end