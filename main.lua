require("tiles")
require("map/mapGeneration")
require("helpers")
require("world")
require("camera")
require("lcgrandom")

debugLog:clear()

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
	world.sendInput("characters", 1, activeKeys)
end

function love.keyreleased(key)
	activeKeys[key] = nil
	inputLock:unlock(key)
	world.sendInput("characters", 1, activeKeys)
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
	world.initialize{camera = camera, drawingCanvas = canvas.diffuse, seed = 1387294098}
	world.eventQueue.world[#world.eventQueue.world + 1] = {name = "generatelevels"}
	world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = 1}
	world.eventQueue.world[#world.eventQueue.world + 1] = {name = "createcharacter", id = 1}
	world.processEventQueue()
end

function love.update(dt)
	--Process input before processing event queue.
	love.event.pump()
	if(activeKeys.escape) then
		love.event.quit()
	end
	if(activeKeys.n) then
		if(inputLock:lock("n")) then
			--level = helpers.clamp((level + 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel + 1),1,#world.levels)}
		end
	end
	if(activeKeys.p) then
		if(inputLock:lock("p")) then
			--level = helpers.clamp((level - 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel - 1),1,#world.levels)}
		end
	end
	world.fillEventQueue()
	world.processEventQueue()
	world.processMovement()
	debugLog:commit()
end

timeStart = 0

--Draw scene
function love.draw()
	--timeStart = love.timer.getTime()
	world.configureCamera()
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

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	debugLog:commit()
	
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isCreated() then
        if not pcall(love.window.setMode, 800, 600) then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
    end
    if love.joystick then
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration() -- Stop all joystick vibrations.
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    love.graphics.setBackgroundColor(89, 157, 220)
    local font = love.graphics.setNewFont(14)

    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    love.graphics.clear()
    love.graphics.origin()

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    local function draw()
        love.graphics.clear()
        love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
        love.graphics.present()
    end

    while true do
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return
            end
            if e == "keypressed" and a == "escape" then
                return
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end

end