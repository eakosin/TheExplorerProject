require("tiles")
require("map/mapGeneration")
require("helpers")
require("world")
require("camera")

gameState = "maptest"

activeKeys = {}

--Special settings for development
devConf = {}
devConf.seed = 2
devConf.decay = 400
devConf.mapType = "linearCave"
devConf.tileImage = nil

function love.keypressed(key)
	activeKeys[key] = true
	print(key)
end

function love.keyreleased(key)
	activeKeys[key] = nil
end

function love.load()
	world.eventQueue["generate"] = {devConf.mapType,60,60,devConf.seed,devConf.decay}
	devConf.tileImage = love.graphics.newImage("images/craptileset.png")
end

function love.update(dt)
	--Main loop
	love.event.pump()
	if(activeKeys.escape) then
		love.event.quit()
	end
	if(activeKeys.up) then
		camera:move(0,4)
	end
	if(activeKeys.down) then
		camera:move(0,-4)
	end
	if(activeKeys.left) then
		camera:move(4,0)
	end
	if(activeKeys.right) then
		camera:move(-4,0)
	end
	world.processEventQueue()
	print("dx: "..camera:dx(),"dy: "..camera:dy(),"x: "..camera.x,"y: "..camera.y)
end

--Draw scene
function love.draw()
	love.graphics.translate(camera:getPosition())
	world.draw()
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