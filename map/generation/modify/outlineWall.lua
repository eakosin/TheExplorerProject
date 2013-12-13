require("helpers")

local outlineWalls = {}

--[[
ID System:
Each script needs a unique id number.
Generation scripts span 1000-1999
Modify scripts span 2000-2999
]]--
outlineWalls.id = 1
outlineWalls.name = "Walls 1"

--Configuration Parameters
outlineWalls.full = true

--Create table of parameters
outlineWalls.parameters = helpers.keys(outlineWalls)

--Configuration Constraints
--See documentation(TODO)
outlineWalls.constraint = {}
for key,value in pairs(outlineWalls.parameters) do
	outlineWalls.constraint[value] = {}
end
outlineWalls.constraint.id.none = true
outlineWalls.constraint.name.none = true
outlineWalls.constraint.full.select = {true,false}

function outlineWalls.resetVariables()
	outlineWalls.full = true
end

function outlineWalls.run(map)
	local isFloor
	if(outlineWalls.full) then
		for x=1,map.width do
			for y=1,map.height do
				if(map.grid[x][y] == map.tileset.floor) then
					if(map.grid[x-1]) then
						map.grid[x-1][y-1] = (map.grid[x-1][y-1] == map.tileset.none and map.tileset.wall) or map.grid[x-1][y-1]
						map.grid[x-1][y] = (map.grid[x-1][y] == map.tileset.none and map.tileset.wall) or map.grid[x-1][y]
						map.grid[x-1][y+1] = (map.grid[x-1][y+1] == map.tileset.none and map.tileset.wall) or map.grid[x-1][y+1]
					end
					map.grid[x][y-1] = (map.grid[x][y-1] == map.tileset.none and map.tileset.wall) or map.grid[x][y-1]
					map.grid[x][y+1] = (map.grid[x][y+1] == map.tileset.none and map.tileset.wall) or map.grid[x][y+1]
					if(map.grid[x+1]) then
						map.grid[x+1][y-1] = (map.grid[x+1][y-1] == map.tileset.none and map.tileset.wall) or map.grid[x+1][y-1]
						map.grid[x+1][y] = (map.grid[x+1][y] == map.tileset.none and map.tileset.wall) or map.grid[x+1][y]
						map.grid[x+1][y+1] = (map.grid[x+1][y+1] == map.tileset.none and map.tileset.wall) or map.grid[x+1][y+1]
					end
				end
			end
		end
	else
		for x=1,map.width do
			for y=1,map.height do
				if(map.grid[x][y] == map.tileset.floor) then
					if(map.grid[x-1]) then
						map.grid[x-1][y] = (map.grid[x-1][y] == map.tileset.none and map.tileset.wall) or map.grid[x-1][y]
					end
					map.grid[x][y-1] = (map.grid[x][y-1] == map.tileset.none and map.tileset.wall) or map.grid[x][y-1]
					map.grid[x][y+1] = (map.grid[x][y+1] == map.tileset.none and map.tileset.wall) or map.grid[x][y+1]
					if(map.grid[x+1]) then
						map.grid[x+1][y] = (map.grid[x+1][y] == map.tileset.none and map.tileset.wall) or map.grid[x+1][y]
					end
				end
			end
		end
	end
end

return outlineWalls