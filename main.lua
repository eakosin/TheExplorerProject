require("tiles")
require("map/mapGeneration")
require("helpers")
require("world")
require("camera")
require("lcgrandom")

helpers.clearDebugLog()

dev = {}
dev.cameraSpeed = 8

activeKeys = {}

inputLock = {}

function inputLock:lock(input)
	if(self[input]) then
		return false
	end
	self[input] = true
	return true
end

function inputLock:unlock(input)
	self[input] = false
end

function love.keypressed(key)
	activeKeys[key] = true
end

function love.keyreleased(key)
	activeKeys[key] = nil
	inputLock:unlock(key)
end

canvas = {}

function love.load()
	local screenWidth, screenHeight = love.window.getDesktopDimensions(1)
	love.graphics.setDefaultFilter("linear", "nearest", 8)
	canvas.diffuse = love.graphics.newCanvas(screenWidth / 2, screenHeight / 2)
	love.graphics.setDefaultFilter("linear", "linear", 8)
	canvas.primary = love.graphics.newCanvas()
	--One: 1386895053
	--seed = 1387229252
	world.initialize{camera = camera, drawingCanvas = canvas.diffuse}
	world.eventQueue.world[#world.eventQueue.world + 1] = {name = "generatelevels"}
	world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = 1}
end

function love.update(dt)
	love.event.pump()
	if(activeKeys.escape) then
		love.event.quit()
	end
	if(activeKeys.up) then
		camera.move(0,-dev.cameraSpeed)
	end
	if(activeKeys.down) then
		camera.move(0,dev.cameraSpeed)
	end
	if(activeKeys.left) then
		camera.move(-dev.cameraSpeed,0)
	end
	if(activeKeys.right) then
		camera.move(dev.cameraSpeed,0)
	end
	if(activeKeys.n) then
		if(inputLock:lock("n")) then
			level = helpers.clamp((level + 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel + 1),1,#world.currentLevel)}
		end
	end
	if(activeKeys.p) then
		if(inputLock:lock("p")) then
			level = helpers.clamp((level - 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel - 1),1,#world.currentLevel)}
		end
	end
	world.processEventQueue()
end

timeStart = 0

--Draw scene
function love.draw()
	--timeStart = love.timer.getTime()
	love.graphics.translate(camera.getNegativePosition())
	love.graphics.setCanvas(canvas.diffuse)
	
	world.draw()
	
	love.graphics.setCanvas(canvas.primary)
	love.graphics.origin()
	love.graphics.draw(canvas.diffuse,0,0,0,2,2)
	love.graphics.setCanvas()
	love.graphics.draw(canvas.primary)
	--helpers.debugLog(love.timer.getTime() - timeStart)
end

--Quitting
function love.quit()
	
end

--The main loop
function love.run()

    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.window and love.graphics then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end

end