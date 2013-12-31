require("helpers")


local stairs = {}

--[[
ID System:
Each script needs a unique id number.
Starting at 1.
]]--
stairs.id = 2
stairs.name = "Stairs 1"
stairs.tileImageName = "crapstalagtite.png"

--Configuration Parameters
stairs.seed = 0

--Create table of parameters
stairs.parameters = helpers.keys(stairs)

--Configuration Constraints
--See documentation(TODO)
stairs.constraint = {}
for key,value in pairs(stairs.parameters) do
	stairs.constraint[value] = {}
end
stairs.constraint.id.none = true
stairs.constraint.name.none = true
stairs.constraint.tileImageName.none = true
stairs.constraint.seed.seed = true

function stairs.resetVariables()
	stairs.seed = 0
end

stairs.lcgrandom = nil

function stairs.run(terrain, decorate)
	stairs.lcgrandom = lcgrandom:new()
	stairs.lcgrandom:seed(stairs.seed)
	for y=1,terrain.height do
		for x=1,terrain.width do
			if(terrain.grid[x][y] == terrain.tileset.floor) then
				decorate.grid[x][y] = decorate.tileset.stairsdown
				return
			end
		end
	end
end

return stairs