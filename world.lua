--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("map/mapGeneration")
require("level")
require("character")
require("enemy")
require("projectiles")
require("ai/ai")
require("ui")

world.lcgrandom = lcgrandom:new()
world.camera = nil
world.levelChange = false
world.loading = false

world.levels = {}
world.characters = {}
world.enemies = {}
world.projectiles = {}
world.ais = {}
world.ui = {}
world.eventQueue = {level = {}, character = {}, enemy = {}, world = {}, projectile = {}, ai = {}}

world.currentLevel = 0

--[[
world.fillEventQueue:
Call fillEventQueue in every object in the world
]]--
--param: none
--return: none
function world.fillEventQueue()
	if(world.levels[world.currentLevel]) then
		world.levels[world.currentLevel]:fillEventQueue()
	end
	for id = 1, #world.characters do
		world.characters[id]:fillEventQueue()
	end
	for id = 1, #world.enemies do
		world.enemies[id]:fillEventQueue()
	end
	for id = 1, #world.ais do
		world.ais[id]:fillEventQueue()
	end
	for id = 1, #world.ui do
		world.ui[id]:fillEventQueue()
	end
end

--[[
Events are to be packed into this format:
world.eventQueue.(level|character|enemy)[id] = {(eventDestination|all), [eventDestination2], ..., [eventDestinationi], object = publishingObject, name = name, eventParameter = value, ...}
For example: world.eventQueue.enemy[#world.eventQueue.enemy + 1] = {"all", "character1", name = "collision", x = chraracter.x, y = character.y}
world.eventQueue.world[id] = {eventParameter = value, ...}
]]--

--[[
world.processEventQueue:
Send each event in all queues to processing functions for that queue type.
--]]
--param: none
--return: none
function world.processEventQueue()
	for id = 1, #world.eventQueue.world do
		world.processWorldEvent(world.eventQueue.world[id])
	end
	world.eventQueue.world = {}
	for id = 1, #world.eventQueue.level do
		world.processLevelEvent(world.eventQueue.level[id])
	end
	world.eventQueue.level = {}
	for id = 1, #world.eventQueue.character do
		world.processCharacterEvent(world.eventQueue.character[id])
	end
	world.eventQueue.character = {}
	for id = 1, #world.eventQueue.enemy do
		world.processEnemyEvent(world.eventQueue.enemy[id])
	end
	world.eventQueue.enemy = {}
	for id = 1, #world.eventQueue.projectile do
		world.processProjectileEvent(world.eventQueue.projectile[id])
	end
	world.eventQueue.projectile = {}
	for id = 1, #world.eventQueue.ai do
		world.processAIEvent(world.eventQueue.ai[id])
	end
	world.eventQueue.ai = {}
end

--[[
world.processWorldEvent:
Process global events in the world queue
]]--
--param: event - event table containing all the event information
--return: none
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
			world.levels[id]:initialize(world.lcgrandom:int32())
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
		world.characters[event.id]:initialize()
		local levelStart = world.levels[world.currentLevel].terrain.map.start
		world.characters[event.id]:placeCharacter(((levelStart.x * 32) - 32), ((levelStart.y * 32) - 32))
	elseif(event.name == "createenemy") then
		skipTiles = world.levels[world.currentLevel].lcgrandom:int(0,250)
		local enemyStart = {x = 0, y = 0}
		for y = 1, world.levels[world.currentLevel].terrain.map.height do
			for x = 1, world.levels[world.currentLevel].terrain.map.width do
				if(world.levels[world.currentLevel].terrain.map.grid[x][y] == world.levels[world.currentLevel].terrain.map.tileset.floor) then
					-- debugLog:append("skipTiles: "..tostring(skipTiles))
					if(skipTiles <= 0) then
						enemyStart.x, enemyStart.y = x, y
						break
					else
						skipTiles = skipTiles - 1
					end
				end
			end
			if(skipTiles <= 0) then
				break
			end
		end
		if(skipTiles <= 0) then
			world.enemies[event.id] = enemy:new(world)
			world.enemies[event.id]:initialize()
			-- debugLog:append("skipTiles: "..tostring(skipTiles))
			world.enemies[event.id]:placeEnemy(((enemyStart.x * 32) - 32), ((enemyStart.y * 32) - 32))
		end
	elseif(event.name == "createai") then
		world.ais[event.id] = ai:new(world)
		world.ais[event.id]:initialize()
	end
end

--[[
world.processLevelEvent:
Process level events in the level queue and send to the requested levels
]]--
--param: event - event table containing all the event information
--return: none
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
			destination = destination + 1
		end
	end
end

--[[
world.processCharacterEvent:
Process character events in the character queue and send to the requested characters
]]--
--param: event - event table containing all the event information
--return: none
function world.processCharacterEvent(event)
	if(event.destination == "all") then
		for id = 1, #world.characters do
			world.characters[id]:processEvent(event)
		end
	else
		destination = 1
		while(event[destination]) do
			world.characters[event[destination]]:processEvent(event)
			destination = destination + 1
		end
	end
end

--[[
world.processEnemyEvent:
Process enemy events in the enemy queue and send to the requested enemies
]]--
--param: event - event table containing all the event information
--return: none
function world.processEnemyEvent(event)
	if(event.destination == "all") then
		for id = 1, #world.enemies do
			world.enemies[id]:processEvent(event)
		end
	else
		destination = 1
		while(event[destination]) do
			world.enemies[event[destination]]:processEvent(event)
			destination = destination + 1
		end
	end
end

--[[
world.processProjectileEvent:
Process projectile events in the projectile queue and send to the requested projectiles
]]--
--param: event - event table containing all the event information
--return: none
function world.processProjectileEvent(event)
	if(event.destination == "all") then
		for id = 1, #world.projectiles do
			world.projectiles[id]:processEvent(event)
		end
	else
		destination = 1
		while(event[destination]) do
			world.projectiles[event[destination]]:processEvent(event)
			destination = destination + 1
		end
	end
end

--[[
world.processAIEvent:
Process projectile events in the projectile queue and send to the requested projectiles
]]--
--param: event - event table containing all the event information
--return: none
function world.processAIEvent(event)
	debugLog:append("AI Process")
	if(event.destination == "all") then
		for id = 1, #world.ais do
			world.ais[id]:processEvent(event)
		end
	else
		destination = 1
		while(event[destination]) do
			world.ais[event[destination]]:processEvent(event)
			destination = destination + 1
		end
	end
end

--[[
world.processChanges:
Call processChanges in every existing object in world
]]--
--param: none
--return: none
function world.processChanges()
	for id = 1, #world.characters do
		world.characters[id]:processChanges()
	end
	for id = 1, #world.enemies do
		world.enemies[id]:processChanges()
	end
	for id = 1, #world.ais do
		world.ais[id]:processChanges()
	end
end

--[[
world.configureCamera:
Center camera position on the characters current location
]]--
--param: none
--return: none
function world.configureCamera()
	world.camera.setPosition((world.characters[1].x - (world.canvasDimensions[1] / 2)), (world.characters[1].y - (world.canvasDimensions[2] / 2)))
end

--[[
world.draw:
Call draw in every existing object in world and the currentLevel
]]--
--param: none
--return: none
function world.draw()
	world.levels[world.currentLevel]:draw()
	for id = 1, #world.characters do
		world.characters[id]:draw()
	end
	for id = 1, #world.enemies do
		world.enemies[id]:draw()
	end
end

--[[
world.initialize:
Prepare the world object by adding parameters to the table, setting the random seed and
start point, loading map generation scripts, and configuring the rendering surface
]]--
--param: A table of key = value parameters to be added to the world table 
--return: none
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
	ai:loadScripts()
	world.canvasDimensions = {world.drawingCanvas:getDimensions()}
end