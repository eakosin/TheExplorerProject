require("helpers")

local cleanTunnels = {}

--[[
ID System:
Each script needs a unique id number.
Starting at 1.
]]--
cleanTunnels.id = 2
cleanTunnels.name = "Clean Tunnels"

--Configuration Parameters
--none

--Create table of parameters
cleanTunnels.parameters = helpers.keys(cleanTunnels)

--Configuration Constraints
--See documentation(TODO)
cleanTunnels.constraint = {}
for key,value in pairs(cleanTunnels.parameters) do
	cleanTunnels.constraint[value] = {}
end
cleanTunnels.constraint.id.none = true
cleanTunnels.constraint.name.none = true

function cleanTunnels.resetVariables()
	--none
end

function cleanTunnels.matchRow(map,x,y,pattern)
	matching = true
	for tile = 1, #pattern do
		matching = matching and ((not map.grid[x + tile - 1]) or (pattern[tile] == map.grid[x + tile - 1][y]))
	end
	return matching
end

function cleanTunnels.matchColumn(map,x,y,pattern)
	matching = true
	for tile = 1, #pattern do
		matching = matching and ((not map.grid[x][y + tile - 1]) or (pattern[tile] == map.grid[x][y + tile - 1]))
	end
	return matching
end

function cleanTunnels.run(map)
	local distance = 0
	for x=2,(map.width-2) do
		for y=2,(map.height-2) do
			--West
			if(cleanTunnels.matchColumn(map,x,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				distance = 1
				while(true) do
					if(cleanTunnels.matchColumn(map,x-distance,y-1,{map.tileset.none,map.tileset.none,map.tileset.none})) then
						while(distance > 0) do
							map.grid[x-distance][y] = map.tileset.none
							distance = distance - 1
						end
					elseif(cleanTunnels.matchColumn(map,x-distance,y-1,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
						distance = distance + 1
					else
						break
					end
				end
			end
			--East
			if(cleanTunnels.matchColumn(map,x,y-1,{map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				distance = 1
				while(true) do
					if(cleanTunnels.matchColumn(map,x+distance,y-1,{map.tileset.none,map.tileset.none,map.tileset.none})) then
						while(distance > 0) do
							map.grid[x+distance][y] = map.tileset.none
							distance = distance - 1
						end
					elseif(cleanTunnels.matchColumn(map,x+distance,y-1,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
						distance = distance + 1
					else
						break
					end
				end
			end
			--North
			if(cleanTunnels.matchRow(map,x-1,y,{map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				distance = 1
				while(true) do
					if(cleanTunnels.matchRow(map,x-1,y-distance,{map.tileset.none,map.tileset.none,map.tileset.none})) then
						while(distance > 0) do
							map.grid[x][y-distance] = map.tileset.none
							distance = distance - 1
						end
					elseif(cleanTunnels.matchRow(map,x-1,y-distance,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
						distance = distance + 1
					else
						break
					end
				end
			end
			--South
			if(cleanTunnels.matchRow(map,x-1,y,{map.tileset.floor,map.tileset.floor,map.tileset.floor})) then
				distance = 1
				while(true) do
					if(cleanTunnels.matchRow(map,x-1,y+distance,{map.tileset.none,map.tileset.none,map.tileset.none})) then
						while(distance > 0) do
							map.grid[x][y+distance] = map.tileset.none
							distance = distance - 1
						end
					elseif(cleanTunnels.matchRow(map,x-1,y+distance,{map.tileset.none,map.tileset.floor,map.tileset.none})) then
						distance = distance + 1
					else
						break
					end
				end
			end
		end
	end
end

return cleanTunnels