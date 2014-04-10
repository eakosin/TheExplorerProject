require("helpers")

ai = {}
ai.aiType = "1"
ai.consistentData = {}
ai.delay = 0

ai.scriptLocations = {"enemies"} --,"bosses"}

function ai:loadScripts()
	for i = 1, #self.scriptLocations do
		if(love.filesystem.exists("ai/ais/"..self.scriptLocations[i])) then
			self[self.scriptLocations[i]] = {}
			self[self.scriptLocations[i]].scripts = {}
			for _,file in pairs(love.filesystem.getDirectoryItems("ai/ais/"..self.scriptLocations[i])) do
				scriptName = file:divide("%.")
				script = require("ai/ais/"..self.scriptLocations[i].."/"..scriptName)
				self[self.scriptLocations[i]].scripts[script.id] = script
			end
		end
	end
end

function ai:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	new.consistentData = {}
	return new
end

function ai:initialize(aiType)
	self.aiType = aiType or self.aiType
end

function ai:fillEventQueue()

end

function ai:processEvent(event)
	if(event.name == "enemyai") then
		self.enemies.scripts[1].process(event.object, self.world)
	end
end

function ai:processChanges()

end