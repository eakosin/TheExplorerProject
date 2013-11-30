require("helpers")

local nonLinearCave = {}

nonLinearCave.searchDistance = 2
nonLinearCave.shortCircuit = 0
nonLinearCave.secondTest = false

nonLinearCave.pathingWeights = {primary = 50, secondary = 25}
nonLinearCave.directionWeight = {north = 100, west = 75, east = 75, south = 35}

function nonLinearCave.resetVariables()
	nonLinearCave.searchDistance = 4
	nonLinearCave.shortCircuit = 0
	nonLinearCave.terminationWeight = 90
	nonLinearCave.closeFunc = true
	nonLinearCave.pathingWeights = {primary = 50, secondary = 25}
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
	--print("nonLinearCave.nearWall("..x..","..y..","..direction..","..distance..")")
    isNearWall = false
	if(distance<=0) then
		return true
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
	if(decay < math.random(0,100)) then
		print("DECAYED")
		return
	end
	if(direction == "north") then
		if(nonLinearCave.nearEdge(map,x,y) == "north") then
			if((math.random(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((math.random(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((math.random(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((math.random(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
	math.randomseed(seed)
	nonLinearCave.newTile(map,math.random((map.width / 4),((map.width * 3) / 4)),map.height,"north",decay)
	return
end

return nonLinearCave