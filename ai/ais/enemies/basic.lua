require("helpers")

local basic = {}

basic.id = 1
basic.name = "basic"

function basic.process(object, world)
	if(object.x ~= world.characters[1].x) then
		object.dx = -2 * (math.abs(object.x - world.characters[1].x) / (object.x - world.characters[1].x))
	end
	if(object.y ~= world.characters[1].y) then
		object.dy = -2 * (math.abs(object.y - world.characters[1].y) / (object.y - world.characters[1].y))
	end
end

return basic