require("helpers")

local outlineWalls = {}

outlineWalls.full = true

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