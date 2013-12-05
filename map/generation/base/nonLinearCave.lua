require("helpers")

local nonLinearCave = {}

--[[
ID System:
Each script needs a unique id number.
Generation scripts span 1000-1999
Modify scripts span 2000-2999
]]--
nonLinearCave.id = 1000

--Configuration Parameters
nonLinearCave.searchDistance = 2
nonLinearCave.shortCircuit = 0
nonLinearCave.originalSearch = true
nonLinearCave.secondTest = false
nonLinearCave.directionWeight = {north = 100, west = 75, east = 75, south = 35}

--Create table of parameters
nonLinearCave.parameters = helpers.keys(nonLinearCave)

--Configuration Constraints
--nonLinearCave.constraint.searchDistance = 

function nonLinearCave.resetVariables()
	nonLinearCave.searchDistance = 2
	nonLinearCave.shortCircuit = 0
	nonLinearCave.originalSearch = true
	nonLinearCave.secondTest = false
	nonLinearCave.directionWeight = {north = 100, west = 75, east = 75, south = 50}
end

function nonLinearCave.computeRelativePathWeight(map, x, y)
    nPer = y / map.height
    sPer = (map.height-y) / map.height
    ePer = (map.width-x) / map.width
    wPer = x / map.width
    return {north = helpers.int(nonLinearCave.directionWeight.north * nPer),
			west = helpers.int(nonLinearCave.directionWeight.west * wPer),
			east = helpers.int(nonLinearCave.directionWeight.east * ePer),
			south = helpers.int(nonLinearCave.directionWeight.south * sPer)}
end

function nonLinearCave.compareAndNil(val1, val2)
	return ((val1 == nil) or (val1 == val2))
end

function nonLinearCave.nearWall(map, x, y, direction, distance)
	--This if clause replicates an algorithmic bug that produced
	--fantastic results.
	if(nonLinearCave.originalSearch and distance > 1) then
		if(direction == "north") then
			y = y - 1
		elseif(direction == "south") then
			y = y + 1
		elseif(direction == "west") then
			x = x - 1
		elseif(direction == "east") then
			x = x + 1
		end
	end
    isNearWall = false
	if(distance <= 1) then
		if(direction == "north") then
			if(((not map.grid[x-1]) or nonLinearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor)) or 
					nonLinearCave.compareAndNil(map.grid[x][y-1], map.tileset.floor) or 
					((not map.grid[x+1]) or nonLinearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return true
			end
		elseif(direction == "south") then
			if(((not map.grid[x-1]) or nonLinearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor)) or 
					nonLinearCave.compareAndNil(map.grid[x][y+1], map.tileset.floor) or 
					((not map.grid[x+1]) or nonLinearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor))) then
				return true
			end
		elseif(direction == "west") then
			if((not map.grid[x-1]) or 
					(nonLinearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x-1][y], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor))) then
				return true
			end
		elseif(direction == "east") then
			if((not map.grid[x+1]) or 
					(nonLinearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x+1][y], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return true
			end
		end
	else
		if(direction == "north") then
			if(((not map.grid[x-1]) or nonLinearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor)) or 
					nonLinearCave.compareAndNil(map.grid[x][y-1], map.tileset.floor) or 
					((not map.grid[x+1]) or nonLinearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return true and nonLinearCave.nearWall(map,x,y-1,"north",distance-1)
			end
		elseif(direction == "south") then
			if(((not map.grid[x-1]) or nonLinearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor)) or 
					nonLinearCave.compareAndNil(map.grid[x][y+1], map.tileset.floor) or 
					((not map.grid[x+1]) or nonLinearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor))) then
				return true and nonLinearCave.nearWall(map,x,y+1,"south",distance-1)
			end
		elseif(direction == "west") then
			if((not map.grid[x-1]) or 
					(nonLinearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x-1][y], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor))) then
				return true and nonLinearCave.nearWall(map,x-1,y,"west",distance-1)
			end
		elseif(direction == "east") then
			if((not map.grid[x+1]) or 
					(nonLinearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x+1][y], map.tileset.floor) or 
					nonLinearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return true and nonLinearCave.nearWall(map,x+1,y,"east",distance-1)
			end
		end
	end
    return false
end

function nonLinearCave.nearEdge(map, x, y)
    if(y <= 1) then
        return "north"
	end
    if(map.height <= y) then
        return "south"
	end
    if(x <= 1) then
        return "west"
	end
    if(map.width <= x) then
        return "east"
	end
    return "floor"
end

function nonLinearCave.newTile(map, x, y, direction, decay)
	--print("nonLinearCave.newTile("..x..","..y..","..direction..","..decay..")")
	map.grid[x][y] = map.tileset.floor
	if(decay < lcgrandom.int(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(nonLinearCave.nearEdge(map,x,y) == "north") then
			if((lcgrandom.int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
            if(not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
            if(nonLinearCave.secondTest and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
		end
	elseif(direction == "south") then
		if(nonLinearCave.nearEdge(map,x,y) == "south") then
			if((lcgrandom.int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
            if(not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
            if(nonLinearCave.secondTest and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
		end
	elseif(direction == "west") then
		if(nonLinearCave.nearEdge(map,x,y) == "west") then
			if((lcgrandom.int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
            if(not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
            if(nonLinearCave.secondTest and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
		end
	elseif(direction == "east") then
		if(nonLinearCave.nearEdge(map,x,y) == "east") then
			if((lcgrandom.int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
            if(not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
            if(nonLinearCave.secondTest and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
		end
	end
	return
end
			
function nonLinearCave.generate(map, seed, decay)
	lcgrandom.seed(seed)
	nonLinearCave.newTile(map,lcgrandom.int((map.width / 4),((map.width * 3) / 4)),map.height,"north",decay)
	return
end

return nonLinearCave