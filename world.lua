--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("map/mapGeneration")
require("level")
require("character")
require("enemy")

world.lcgrandom = lcgrandom:new()
world.camera = nil
world.levelChange = false

world.levels = {}
world.characters = {}
world.enemies = {}
world.eventQueue = {level = {}, character = {}, enemy = {}, world = {}}

world.currentLevel = 0

function world.fillEventQueue()
	world.levels[world.currentLevel]:fillEventQueue()
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
	for id,event in pairs(world.eventQueue.world) do
		print(event.name)
		world.processWorldEvent(event)
		world.eventQueue.world[id] = nil
	end
	for id,event in pairs(world.eventQueue.level) do
		world.processLevelEvent(event)
		world.eventQueue.level[id] = nil
	end
end

function world.processWorldEvent(event)
	if(event.name == "generatelevels") then
		for id = 1, 10 do
			print("Level: "..tostring(id))
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
		world.levelChange = true
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
		world.currentLevel = event.id
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
		for id,level in pairs(world.levels) do
			--level:processEvent()
		end
	elseif(event.destination == "currentlevel") then
		world.levels[world.currentLevel]:processEvent(event)
	end
end

function world.processCharacterEvent(id, event)
	
end

function world.processEnemyEvent(id, event)
	
end

function world.sendInput(group, id, keys)
	world[group][id]:recieveInput(keys)
end

function world.processMovement()
	for id = 1, #world.characters do
		world.characters[id]:move()
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
	debugLog:append("World Seed: "..tostring(world.seed))
	mapGeneration.loadScripts()
	world.canvasDimensions = {world.drawingCanvas:getDimensions()}
end