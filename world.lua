--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("level")
require("characters")
require("enemies")

world.levels = {}
world.characters = {}
world.enemies = {}
world.eventQueue = {level = {}, character = {}, enemy = {}}

--[[
Events are to be packed into this format:
world.eventQueue.(level|character|enemy) = {eventName = data, ...}
]]--
function world.processEventQueue()
	for eventType,event in pairs(world.eventQueue.level) do
		world.processLevelEvent(eventType, event)
		world.eventQueue.level[eventType] = nil
	end
end

function world.processLevelEvent(eventType,event)
	if(eventType == "generate") then
		world.levels.test = level:newLevel()
		world.levels.test:buildMap(unpack(event))
		world.levels.test:buildSpriteBatch(32,32)
		world.levels.test:buildQuads()
		world.levels.test:populateSpriteBatch()
	end
end

function world.processCharacterEvent(event)
	
end

function world.processEnemyEvent(event)
	
end

function world.draw()
	for key in pairs(world.levels) do
		world.levels[key]:draw()
	end
end
