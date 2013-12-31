require("helpers")
require("map/mapTypes")

local thickenTunnels = {}

--[[
ID System:
Each script needs a unique id number.
Starting at 1.
]]--
thickenTunnels.id = 3
thickenTunnels.name = "Thicken Tunnels"

--Configuration Parameters
--none

--Create table of parameters
thickenTunnels.parameters = helpers.keys(thickenTunnels)

--Configuration Constraints
--See documentation(TODO)
thickenTunnels.constraint = {}
for key,value in pairs(thickenTunnels.parameters) do
	thickenTunnels.constraint[value] = {}
end
thickenTunnels.constraint.id.none = true
thickenTunnels.constraint.name.none = true

function thickenTunnels.resetVariables()
	--none
end

function thickenTunnels.matchRow(map,x,y,pattern)
	matching = true
	for tile = 1, #pattern do
		matching = matching and ((not map.grid[x + tile - 1]) or (pattern[tile] == map.grid[x + tile - 1][y]))
	end
	return matching
end

function thickenTunnels.matchColumn(map,x,y,pattern)
	matching = true
	for tile = 1, #pattern do
		matching = matching and ((not map.grid[x][y + tile - 1]) or (pattern[tile] == map.grid[x][y + tile - 1]))
	end
	return matching
end

function thickenTunnels.double(inMap)
	local oldMap = map:new()
	oldMap:buildMap(inMap.width, inMap.height)
	oldMap.start = {x = inMap.start.x, y = inMap.start.y}
	for x=1, inMap.width do
		for y=1, inMap.height do
			oldMap.grid[x][y] = inMap.grid[x][y]
		end
	end
	inMap.grid = {}
	collectgarbage()
	inMap:buildMap((oldMap.width * 2), (oldMap.height * 2))
	inMap.start = {x = (oldMap.start.x * 2), y = (oldMap.start.y * 2)}
	for x=0, (oldMap.width - 1) do
		for y=0, (oldMap.height - 1) do
			inMap.grid[(x*2)+1][(y*2)+1] = oldMap.grid[x+1][y+1]
			inMap.grid[(x*2)+2][(y*2)+1] = oldMap.grid[x+1][y+1]
			inMap.grid[(x*2)+1][(y*2)+2] = oldMap.grid[x+1][y+1]
			inMap.grid[(x*2)+2][(y*2)+2] = oldMap.grid[x+1][y+1]
		end
	end
end

function thickenTunnels.widen(map)
	for x=2,(map.width) do
		for y=2,(map.height) do
			--Vertical
			if((y < (map.height - 3)) and thickenTunnels.matchColumn(map,x-1,y,{map.tileset.floor}) and thickenTunnels.matchColumn(map,x,y-1,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 1][y + 1] = map.tileset.floor
				map.grid[x][y + 1] = map.tileset.floor
			--Horizontal
			elseif((x < (map.width - 3)) and thickenTunnels.matchRow(map,x,y-1,{map.tileset.floor}) and thickenTunnels.matchRow(map,x-1,y,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
				map.grid[x + 1][y - 1] = map.tileset.floor
				map.grid[x + 1][y] = map.tileset.floor
			end
		end
	end
end

function thickenTunnels.cornerFill(map)
	for x=2,(map.width-2) do
		for y=2,(map.height-2) do
			--Vertical
			if(thickenTunnels.matchColumn(map,x-1,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.none}) and thickenTunnels.matchColumn(map,x,y-1,{map.tileset.none,map.tileset.floor,map.tileset.floor})) then
				map.grid[x - 1][y + 1] = map.tileset.floor
				map.grid[x][y - 1] = map.tileset.floor
			end
			if(thickenTunnels.matchColumn(map,x-1,y-1,{map.tileset.none,map.tileset.floor,map.tileset.floor}) and thickenTunnels.matchColumn(map,x,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 1][y - 1] = map.tileset.floor
				map.grid[x][y + 1] = map.tileset.floor
			end
			--Horizontal
			if(thickenTunnels.matchRow(map,x-1,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.none}) and thickenTunnels.matchRow(map,x-1,y,{map.tileset.none,map.tileset.floor,map.tileset.floor})) then
				map.grid[x + 1][y - 1] = map.tileset.floor
				map.grid[x - 1][y] = map.tileset.floor
			end
			if(thickenTunnels.matchRow(map,x-1,y-1,{map.tileset.none,map.tileset.floor,map.tileset.floor}) and thickenTunnels.matchRow(map,x-1,y,{map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 1][y - 1] = map.tileset.floor
				map.grid[x + 1][y] = map.tileset.floor
			end
		end
	end
end

function thickenTunnels.cornerFillDouble(map)
	for x=2,(map.width-2) do
		for y=2,(map.height-2) do
			--Vertical
			if(thickenTunnels.matchColumn(map,x-1,y-2,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none}) and thickenTunnels.matchColumn(map,x,y-2,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				map.grid[x - 1][y + 1] = map.tileset.floor
				map.grid[x][y - 2] = map.tileset.floor
			end
			if(thickenTunnels.matchColumn(map,x-1,y-2,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor}) and thickenTunnels.matchColumn(map,x,y-2,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 1][y - 2] = map.tileset.floor
				map.grid[x][y + 1] = map.tileset.floor
			end
			--Horizontal
			if(thickenTunnels.matchRow(map,x-2,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none}) and thickenTunnels.matchRow(map,x-2,y,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				map.grid[x + 1][y - 1] = map.tileset.floor
				map.grid[x - 2][y] = map.tileset.floor
			end
			if(thickenTunnels.matchRow(map,x-2,y-1,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor}) and thickenTunnels.matchRow(map,x-2,y,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 2][y - 1] = map.tileset.floor
				map.grid[x + 1][y] = map.tileset.floor
			end
		end
	end
end

function thickenTunnels.cornerCutDouble(map)
	for x=2,(map.width-2) do
		for y=2,(map.height-2) do
			--Vertical
			if(thickenTunnels.matchColumn(map,x-1,y-2,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})
				and thickenTunnels.matchColumn(map,x,y-2,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				map.grid[x - 2][y] = (map.grid[x - 3] and map.grid[x - 3][y]) or map.tileset.none
				map.grid[x + 1][y - 1] = map.grid[x + 2][y - 1]
			end
			if(thickenTunnels.matchColumn(map,x-1,y-2,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})
				and thickenTunnels.matchColumn(map,x,y-2,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 2][y - 1] = (map.grid[x - 3] and map.grid[x - 3][y - 1]) or map.tileset.none
				map.grid[x + 1][y] = map.grid[x + 2][y]
			end
			--Horizontal
			if(thickenTunnels.matchRow(map,x-2,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})
				and thickenTunnels.matchRow(map,x-2,y,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				map.grid[x][y - 2] = map.grid[x][y - 3] or map.tileset.none
				map.grid[x - 1][y + 1] = map.grid[x - 1][y + 2]
			end
			if(thickenTunnels.matchRow(map,x-2,y-1,{map.tileset.none,map.tileset.floor,map.tileset.floor,map.tileset.floor})
				and thickenTunnels.matchRow(map,x-2,y,{map.tileset.floor,map.tileset.floor,map.tileset.floor,map.tileset.none})) then
				map.grid[x - 1][y - 2] = map.grid[x - 1][y - 3] or map.tileset.none
				map.grid[x][y + 1] = map.grid[x][y + 2]
			end
		end
	end
end

function thickenTunnels.run(map)
	--thickenTunnels.widen(map)
	--thickenTunnels.cornerFill(map)
	thickenTunnels.double(map)
	thickenTunnels.cornerCutDouble(map)
	--thickenTunnels.cornerFillDouble(map)
end

return thickenTunnels