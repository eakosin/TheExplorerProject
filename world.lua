--The world is a table of tables that contains everything.
--It will hold an event queue, which it will use to update any interactions.

world = {}

require("level")
require("characters")
require("enemies")

world.levels = {}
world.characters = {}
world.enemies = {}
world.eventQueue = {}

function world.processEventQueue()
	for key,value in pairs(world.eventQueue) do
		if(key == "generate" and value) then
			world.levels.test = level:newLevel(unpack(value))
			world.levels.test:buildSpriteBatch(32,32)
			world.levels.test:buildQuads()
			world.levels.test:populateSpriteBatch()
			world.eventQueue.generate = nil
		end
	end
end

function world.draw()
	for key in pairs(world.levels) do
		world.levels[key]:draw()
	end
end
