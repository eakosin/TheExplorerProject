require("helpers")
require("map/mapTypes")
require("lcgrandom")

local caveStructures = {}

--[[
ID System:
Each script needs a unique id number.
Starting at 1.
]]--
caveStructures.id = 1
caveStructures.name = "Cave Structures 1"
caveStructures.tileImageName = "crapstalagtite.png"

--Configuration Parameters
caveStructures.seed = 0

--Create table of parameters
caveStructures.parameters = helpers.keys(caveStructures)

--Configuration Constraints
--See documentation(TODO)
caveStructures.constraint = {}
for key,value in pairs(caveStructures.parameters) do
	caveStructures.constraint[value] = {}
end
caveStructures.constraint.id.none = true
caveStructures.constraint.name.none = true
caveStructures.constraint.tileImageName.none = true
caveStructures.constraint.seed.seed = true

function caveStructures.resetVariables()
	caveStructures.seed = 0
end

caveStructures.lcgrandom = nil

function caveStructures.addStalagtites(terrain, decorate)
	xShift, yShift = caveStructures.lcgrandom:int(), caveStructures.lcgrandom:int()
	for x=1, terrain.width do
		for y=1, terrain.height do
			if((terrain.grid[x][y] == terrain.tileset.floor) and (love.math.noise((x + xShift),(y + yShift)) > 0.9)) then
				decorate.grid[x][y] = decorate.tileset.stalagtite
			end
		end
	end
end

function caveStructures.run(terrain, decorate)
	caveStructures.lcgrandom = lcgrandom:new()
	caveStructures.lcgrandom:seed(caveStructures.seed)
	caveStructures.addStalagtites(terrain, decorate)
end

return caveStructures