--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("map/mapGeneration")
require("level")
require("character")
require("enemy")
require("projectiles")

world.lcgrandom = lcgrandom:new()
world.camera = nil
world.levelChange = false
world.loading = false

world.levels = {}
world.characters = {}
world.enemies = {}
world.projectiles = {}
world.eventQueue = {level = {}, character = {}, enemy = {}, world = {}, projectile = {}}

world.currentLevel = 0

function world.fillEventQueue()
	if(world.levels[world.currentLevel]) then
		world.levels[world.currentLevel]:fillEventQueue()
	end
	for id = 1, #world.characters do
		world.characters[id]:fillEventQueue()
	end
end

--[[
Events are to be packed into this format:
world.eventQueue.(level|character|enemy)[id] = {(eventDestination|all), [eventDestination2], ..., [eventDestinationi], object = publishingObject, name = name, eventParameter = value, ...}
For example: world.eventQueue.enemy[#world.eventQueue.enemy + 1] = {"all", "character1", name = "collision", x = chraracter.x, y = character.y}
world.eventQueue.world[id] = {eventParameter = value, ...}
]]--
function world.processEventQueue()
	for id = 1, #world.eventQueue.world do
		debugLog:append(tostring(id)..": "..tostring(world.eventQueue.world[id]))
		world.processWorldEvent(world.eventQueue.world[id])
	end
	world.eventQueue.world = {}
	for id = 1, #world.eventQueue.level do
		world.processLevelEvent(world.eventQueue.level[id])
	end
	world.eventQueue.level = {}
	for id = 1, #world.eventQueue.character do
		world.processLevelEvent(world.eventQueue.character[id])
	end
	world.eventQueue.character = {}
	for id = 1, #world.eventQueue.enemy do
		world.processLevelEvent(world.eventQueue.enemy[id])
	end
	world.eventQueue.enemy = {}
	for id = 1, #world.eventQueue.projectile do
		world.processLevelEvent(world.eventQueue.projectile[id])
	end
	world.eventQueue.projectile = {}
end

function world.processWorldEvent(event)
	debugLog:append(tostring(event))
	if(event.name == "generatelevels") then
		event.number = event.number or 3
		for id = 1, event.number do
			debugLog:append("\nLevel: "..tostring(id).." - "..tostring(world.levels[id]))
			local timeStart = love.timer.getTime()
			world.levels[id] = level:new(world)
			world.levels[id].id = id
			world.levels[id].name = "Level "..id
			world.levels[id]:generate(world.lcgrandom:int32())
			world.levels[id]:prepareSpriteBatches()
			debugLog:append("Time: "..tostring(love.timer.getTime() - timeStart).." sec")
			--world.levels[id]:clearParameters()
		end
		debugLog:append("Memory: "..tostring(collectgarbage("count")))
		debugLog:commit()
		collectgarbage()
		--world.levelChange = true
	elseif(event.name == "destroylevels") then
		if(event.ids) then
			for i = 1, #event.ids do
				world.levels[event.ids[i]] = nil
			end
		else
			world.levels = {}
		end
		collectgarbage()
	elseif(event.name == "changelevel") then
		world.currentLevel = helpers.clamp(event.id,1,#world.levels)
		local levelStart = world.levels[world.currentLevel].terrain.map.start
		if(world.characters[1]) then
			world.characters[1]:placeCharacter(((levelStart.x * 32) - 32), ((levelStart.y * 32) - 16))
		end
		world.camera.configureBoundries(world.levels[world.currentLevel].terrain.map.width,
										world.levels[world.currentLevel].terrain.map.height,
										world.levels[world.currentLevel].tileSize.x,
										world.levels[world.currentLevel].tileSize.y,
										unpack(world.canvasDimensions))
	elseif(event.name == "createcharacter") then
		world.characters[event.id] = character:new(world)
		character:initialize()
		local levelStart = world.levels[world.currentLevel].terrain.map.start
		character:placeCharacter(((levelStart.x * 32) - 32), ((levelStart.y * 32) - 16))
	end
end

function world.processLevelEvent(event)
	if(event.destination == "all") then
		for id = 1, #world.levels do
			world.levels[id]:processEvent(event)
		end
	elseif(event.destination == "currentlevel") then
		world.levels[world.currentLevel]:processEvent(event)
	else
		destination = 1
		while(event[destination]) do
			world.levels[event[destination]]:processEvent(event)
		end
	end
end

function world.processCharacterEvent(id, event)
	if(event.destination == "all") then
		for id = 1, #world.characters do
			world.characters[id]:processEvent(event)
		end
	elseif(event.destination == "currentlevel") then
		world.characters[world.currentLevel]:processEvent(event)
	else
		destination = 1
		while(event[destination]) do
			world.characters[event[destination]]:processEvent(event)
		end
	end
end

function world.processEnemyEvent(id, event)
	if(event.destination == "all") then
		for id = 1, #world.enemies do
			world.enemies[id]:processEvent(event)
		end
	elseif(event.destination == "currentlevel") then
		world.enemies[world.currentLevel]:processEvent(event)
	else
		destination = 1
		while(event[destination]) do
			world.enemies[event[destination]]:processEvent(event)
		end
	end
end

function world.processProjectileEvent(id, event)
	if(event.destination == "all") then
		for id = 1, #world.projectiles do
			world.projectiles[id]:processEvent(event)
		end
	elseif(event.destination == "currentlevel") then
		world.projectiles[world.currentLevel]:processEvent(event)
	else
		destination = 1
		while(event[destination]) do
			world.projectiles[event[destination]]:processEvent(event)
		end
	end
end

function world.processChanges()
	for id = 1, #world.characters do
		world.characters[id]:processChanges()
	end
end

function world.configureCamera()
	world.camera.setPosition((world.characters[1].x - (world.canvasDimensions[1] / 2)), (world.characters[1].y - (world.canvasDimensions[2] / 2)))
end

function world.draw()
	world.levels[world.currentLevel]:draw()
	for id = 1, #world.characters do
		world.characters[id]:draw()
	end
end

function world.initialize(parameters)
	for key,value in pairs(parameters) do
		world[key] = value
	end
	world.seed = world.seed or os.time()
	world.lcgrandom:seed(world.seed)
	--Generate as many random numbers as possible within a 50ms period to add hardware performance
	--to the os time for better randomization.
	local count = 0
	if(not world.count) then
		local startTime = love.timer.getTime()
		while((love.timer.getTime() - startTime) < .05) do
			world.lcgrandom:int32()
			count = count + 1
		end
	else
		local i = 0
		while(i < world.count) do
			world.lcgrandom:int32()
			i = i + 1
		end
	end
	debugLog:append("World Seed: "..tostring(world.seed).." Iteration Count: "..tostring(count))
	mapGeneration.loadScripts()
	world.canvasDimensions = {world.drawingCanvas:getDimensions()}
end