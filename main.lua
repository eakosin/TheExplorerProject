require("menu")
require("tiles")
require("map/mapGeneration")
require("helpers")
require("world")
require("camera")
require("lcgrandom")

debugLog:clear()

keyState = {}

inputLock = {}

mouseState = {}

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
	keyState[key] = true
end

function love.keyreleased(key)
	keyState[key] = nil
	inputLock:unlock(key)
end

function love.mousepressed(x, y, button)
	mouseState[button] = {x = x, y = y}
end

function love.mousereleased(x, y, button)
	mouseState[button] = nil
end

canvas = {}

function love.load()
	local screenWidth, screenHeight = love.window.getDesktopDimensions(1)
	love.graphics.setDefaultFilter("linear", "nearest", 8)
	canvas.diffuse = love.graphics.newCanvas(screenWidth / 2, screenHeight / 2)
	love.graphics.setDefaultFilter("linear", "linear", 8)
	canvas.primary = love.graphics.newCanvas()
	love.graphics.setCanvas(canvas.diffuse)
	love.graphics.setBackgroundColor(0,0,0,255)
	love.graphics.clear()
	love.graphics.printf("You, and others around you are 'immigrants' to this city who were searching for a better life for your family after leaving the villages. This is the only job opportunity available and it barely provides enough for food and dwelling costs. This is similar to coal miners who have this as their only available job opportunity, and risk life and limb to support their family. \n\n\nYour character's job is to test and report on randomly generated worlds to help find and refine bugs in the generational algorithms. This involves fighting your way through the monsters inhabiting each world and exploring to find as much loot as possible to improve your pay commission style.\n\n\nClick to continue...", screenWidth / 32, screenHeight / 16, screenWidth / 3, 'left')
	love.graphics.setCanvas(canvas.primary)
	love.graphics.origin()
	love.graphics.draw(canvas.diffuse,0,0,0,2,2)
	love.graphics.setCanvas()
	love.graphics.draw(canvas.primary)
	love.graphics.present()
	while(not (love.mouse.isDown("l") or love.mouse.isDown("r"))) do love.event.pump() end
	--One: 1386895053
	--seed = 1387229252
	--seed = 1387294098
	world.initialize{menu = menu, camera = camera, drawingCanvas = canvas.diffuse, keyState = keyState, inputLock = inputLock, mouseState = mouseState}

	menu.initialize{world = world, canvas = canvas.diffuse, keyState = keyState, inputLock = inputLock, mouseState = mouseState}
end

timeStart = 0
frame = 0

function love.update(dt)
	timeStart = love.timer.getTime()
	--Process input before processing event queue.
	love.event.pump()
	if(world.dead) then
		menu.visible = true
		world.loading = true
		world.dead = false
		world.eventQueue.world[#world.eventQueue.world + 1] = {name = "destroy"}
	end
	if(keyState.escape) then
		menu.visible = true
		world.loading = true
		world.eventQueue.world[#world.eventQueue.world + 1] = {name = "destroy"}
	end
	if(keyState.n) then
		if(inputLock:lock("n")) then
			--level = helpers.clamp((level + 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel + 1),1,#world.levels)}
		end
	end
	if(keyState.p) then
		if(inputLock:lock("p")) then
			--level = helpers.clamp((level - 1), 1, #world.levels)
			world.eventQueue.world[#world.eventQueue.world + 1] = {name = "changelevel", id = helpers.clamp((world.currentLevel - 1),1,#world.levels)}
		end
	end
	if(world.loading) then
		world.processEventQueue()
		world.processChanges()
		world.loading = false
	elseif(menu.visible) then
		menu.fillEventQueue()
		menu.processEventQueue()
	else
		world.fillEventQueue()
		world.processEventQueue()
		world.processChanges()
		world.updateUI()
	end
	debugLog:commit()
end

--Draw scene
function love.draw()
	--timeStart = love.timer.getTime()
	if(menu.visible) then
		love.graphics.origin()
		love.graphics.setCanvas(canvas.diffuse)
		
		love.graphics.clear()
		
		menu.draw()
		
		love.graphics.setCanvas(canvas.primary)
		love.graphics.draw(canvas.diffuse,0,0,0,2,2)
		love.graphics.setCanvas()
		love.graphics.draw(canvas.primary)
	elseif(world.loading) then
		love.graphics.setCanvas(canvas.diffuse)
		
		love.graphics.setBackgroundColor(0,0,0,255)
		love.graphics.clear()
		
		love.graphics.print("Loading...")
		
		love.graphics.setCanvas(canvas.primary)
		love.graphics.origin()
		love.graphics.draw(canvas.diffuse,0,0,0,2,2)
		love.graphics.setCanvas()
		love.graphics.draw(canvas.primary)
	else
		world.configureCamera()
		love.graphics.translate(camera.getNegativePosition())
		love.graphics.setCanvas(canvas.diffuse)
		
		love.graphics.setBackgroundColor(0,0,0,255)
		love.graphics.clear()
		
		world.draw()
		
		love.graphics.origin()
		
		world.drawUI()
		
		love.graphics.setCanvas(canvas.primary)
		love.graphics.draw(canvas.diffuse,0,0,0,2,2)
		love.graphics.setCanvas()
		love.graphics.draw(canvas.primary)
	end
	--debugLog:append(tostring(love.timer.getTime() - timeStart).." - Frame "..tostring(frame))
	--debugLog:commit()
	frame = frame + 1
end

--Quitting
function love.quit()
	debugLog:commit()
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