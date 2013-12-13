--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("map/mapGeneration")
require("level")
require("characters")
require("enemies")

world.lcgrandom = lcgrandom:new()
world.camera = nil

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
			world.levels[id] = level:new()
			world.levels[id].name = "level"..id
			world.levels[id]:generate(world.lcgrandom:int32())
		end
	elseif(event.name == "destroylevels") then
		world.levels = {}
		collectgarbage("collect")
	elseif(event.name == "changelevel") then
		world.currentLevel = event.id
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
	world.levels[world.currentLevel]:draw()
end

function world.initialize(staticSeed, ...)
	seed = staticSeed or os.time()
	seed = world.lcgrandom:seed(seed)
	mapGeneration.loadScripts()
	if(...) then
		--TODO: Bypass game to test scripts with controllable parameters.
	end
end