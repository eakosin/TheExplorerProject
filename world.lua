--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("map/mapGeneration")
require("level")
require("characters")
require("enemies")

world.lcgrandom = lcgrandom:new()
world.camera = nil
world.levelChange = false

world.levels = {}
world.characters = {}
world.enemies = {}
world.eventQueue = {level = {}, character = {}, enemy = {}, world = {}}

world.currentLevel = 0

--[[
Events are to be packed into this format:
world.eventQueue.(level|character|enemy)[id] = {(eventDestination|all), [eventDestination2], ..., [eventDestinationi], publishingObject, eventParameter = value, ...}
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
		world.processLevelEvent(id, event)
		world.eventQueue.level[id] = nil
	end
end

function world.processWorldEvent(event)
	if(event.name == "generatelevels") then
		for id = 1, 1 do
			print("Level: "..tostring(id))
			world.levels[id] = level:new()
			world.levels[id].name = "level"..id
			world.levels[id]:generate(world.lcgrandom:int32())
			world.levels[id]:prepareSpriteBatches()
			print("Address: "..tostring(world.levels[id]))
			world.levels[id]:clearParameters()
		end
		print("Memory: "..tostring(collectgarbage("count")))
		collectgarbage("restart")
		world.levelChange = true
	elseif(event.name == "destroylevels") then
		if(event.ids) then
			for i = 1, #event.ids do
				world.levels[event.ids[i]] = nil
			end
		else
			world.levels = {}
		end
		collectgarbage("collect")
	elseif(event.name == "changelevel") then
		world.currentLevel = event.id
		world.levelChange = true
		print("levelid: "..tonumber(world.currentLevel))
	end
end

function world.processLevelEvent(id, event)
	if(event[1] == "all") then
		for id,level in pairs(world.levels) do
			level:processEvent()
		end
	else
		
	end
end

function world.processCharacterEvent(id, event)
	
end

function world.processEnemyEvent(id, event)
	
end

function world.draw()
	--Temporary camera bounding until the camera is controlled by the Character object.
	if(world.levelChange) then
		world.camera.configureBoundries(world.levels[world.currentLevel].terrain.map.width,
										world.levels[world.currentLevel].terrain.map.height,
										world.levels[world.currentLevel].tileSize.x,
										world.levels[world.currentLevel].tileSize.y,
										world.drawingCanvas:getDimensions())
		local levelStart = world.levels[world.currentLevel].terrain.map.start
		helpers.debugLog(world.drawingCanvas)
		world.camera.setPosition(((levelStart.x * 32) - (world.drawingCanvas:getDimensions() / 2)), (levelStart.y * 32))
		world.levelChange = false
		print("world.currentLevel: "..tostring(world.levels[world.currentLevel]))
	end
	world.levels[world.currentLevel]:draw()
end

function world.initialize(parameters)
	for key,value in pairs(parameters) do
		world[key] = value
	end
	world.seed = world.seed or os.time()
	world.lcgrandom:seed(world.seed)
	helpers.debugLog("World Seed: "..tostring(world.seed))
	mapGeneration.loadScripts()
end