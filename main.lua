require("tiles")
require("map/mapGeneration")
require("helpers")
require("world")
require("camera")
require("lcgrandom")

gameState = "maptest"

activeKeys = {}

--Special settings for development
devConf = {}
devConf.seed = 95
--Max of 16375 - Stack Size
devConf.decay = 200
devConf.mapType = "nonLinearCave"
devConf.tileImage = nil
devConf.mapSize = {x = 60,y = 60}
devConf.tileSize = {x = 32,y = 32}
devConf.cameraSpeed = 8
devConf.testCanvas = nil

function love.keypressed(key)
	activeKeys[key] = true
end

function love.keyreleased(key)
	activeKeys[key] = nil
end

function love.load()
	world.eventQueue.level["generate"] = {devConf.mapType,devConf.mapSize.x,devConf.mapSize.y,devConf.seed,devConf.decay}
	camera.tileBound.x, camera.tileBound.y = devConf.mapSize.x, devConf.mapSize.y
	camera.tileSize.x, camera.tileSize.y = devConf.tileSize.x, devConf.tileSize.x
	--devConf.testCanvas = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
end

function love.update(dt)
	--Main loop
	
	love.event.pump()
	if(activeKeys.escape) then
		love.event.quit()
	end
	if(activeKeys.up) then
		camera.move(0,-devConf.cameraSpeed)
	end
	if(activeKeys.down) then
		camera.move(0,devConf.cameraSpeed)
	end
	if(activeKeys.left) then
		camera.move(-devConf.cameraSpeed,0)
	end
	if(activeKeys.right) then
		camera.move(devConf.cameraSpeed,0)
	end
	world.processEventQueue()
	if(camera.dx() ~= 0 or camera.dy() ~= 0) then
		print("dx: "..camera.dx(),"dy: "..camera.dy(),"x: "..camera.x,"y: "..camera.y)
	end
end

--Draw scene
function love.draw()
	love.graphics.translate(camera.getNegativePosition())
	--love.graphics.setCanvas(devConf.testCanvas)
	
	world.draw()
	
	--love.graphics.setCanvas()
	--love.graphics.origin()
	--love.graphics.draw(devConf.testCanvas)
end

--Quitting
function love.quit()
	
end

--The main loop
function love.run()

    if love.math then
        love.math.setRandomState(os.time())
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