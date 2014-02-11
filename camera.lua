require("helpers")

camera = {}
camera.x = 0
camera.y = 0
camera.lx = 0
camera.ly = 0
camera.tileBound = {x = 0, y = 0}
camera.tileSize = {x = 32, y = 32}
camera.canvasSize = {width = 800, height = 600}

--[[
camera.configureBoundries()
This function configures the boundaries at which the camera can move.
]]--
--param: tileBoundX
--param: tileBoundY 
--param: tileSizeX 
--param: tileSizeY
--param: canvasWidth
--param: canvasHeight 
--return: none
function camera.configureBoundries(tileBoundX, tileBoundY, tileSizeX, tileSizeY, canvasWidth, canvasHeight)
	camera.tileBound.x, camera.tileBound.y = tileBoundX, tileBoundY
	camera.tileSize.x, camera.tileSize.y = tileSizeX, tileSizeY
	camera.canvasSize.width, camera.canvasSize.height = canvasWidth, canvasHeight
end

--[[
camera.bound()
This function checks to see if the value is within the camera range.  It returns a the boundary
value that is within the boundary if the 'value' parameter is outside of it and the parameter itself
if it is within it.
]]--
--param: value - the value to check
--param: lower - the lower boundary
--param: upper -  the upper boundary
--return: the place where the camera should move
function camera.bound(value,lower,upper)
	return (value > upper and upper) or (value < lower and lower) or value
end

--[[
camera.move()
This function moves the camera by the ammount passed in as the parameters.  If that moves the
camera outside of the boundaries then the boundary is set as the new coordinate.
]]--
--param: x - the change in x coordinate
--param: y - the change in y coordinate
--return: none
function camera.move(x,y)
	camera.x = camera.x + x
	camera.x = camera.bound(camera.x,0,((camera.tileBound.x*camera.tileSize.x)-camera.canvasSize.width))
	camera.y = camera.y + y
	camera.y = camera.bound(camera.y,0,((camera.tileBound.y*camera.tileSize.y)-camera.canvasSize.height))
end

--[[
camera.setPosition()
This function sets the new camera position to the values passed in as x and y parameters
]]--
--param: x - the new x position
--param: y - the new y position
--return: none
function camera.setPosition(x,y)
	camera.x = camera.bound(x,0,((camera.tileBound.x*camera.tileSize.x)-camera.canvasSize.width))
	camera.y = camera.bound(y,0,((camera.tileBound.y*camera.tileSize.y)-camera.canvasSize.height))
end

--[[
camera.dx()
This function gets the change in X camera position from the current and last camera position
]]--
--param: none
--return: the change in camera position from the current and last camera position
function camera.dx()
	return camera.x - camera.lx
end

--[[
camera.dx()
This function gets the change in Y camera position from the current and last camera position
]]--
--param: none
--return: the change in camera position from the current and last camera position
function camera.dy()
	return camera.y - camera.ly
end

--[[
camera.getPosition()
This function sets the current camera position to the last camera position
]]--
--param: none
--return: the current x coordiante, the current y coordinate
function camera.getPosition()
	camera.lx, camera.ly = camera.x, camera.y
	return camera.x, camera.y
end

--[[
camera.getNegativePosition()
Transform world coordinates to simulate camera direction.
]]--
--param: none
--return: negative x value, negative y value
function camera.getNegativePosition()
	camera.lx, camera.ly = camera.x, camera.y
	return -camera.x, -camera.y
end
