require("helpers")

ai = {}
ai.aiType = "1"

function ai:new(world)
	new = {}
	setmetatable(new, self)
	self.__index = self
	new.world = world
	return new
end

function ai:initalize(aiType)
	self.aiType = aiType or self.aiType
end

function ai:fillEventQueue()

end

function ai:processEvent()

end

function ai:processChanges()

end