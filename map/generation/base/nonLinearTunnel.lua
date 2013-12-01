require("helpers")

local nonLinearTunnel = {}

nonLinearTunnel.searchDistance = 13
nonLinearTunnel.shortCircuit = 0
nonLinearTunnel.terminationWeight = 90
nonLinearTunnel.quickTerminate = false
nonLinearTunnel.searchShape = "diamond"
nonLinearTunnel.secondTest = true

nonLinearTunnel.pathingWeights = {primary = 50, secondary = 25}
nonLinearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 50}

function nonLinearTunnel.resetVariables()
	nonLinearTunnel.searchDistance = 4
	nonLinearTunnel.shortCircuit = 0
	nonLinearTunnel.terminationWeight = 90
	nonLinearTunnel.closeFunc = true
	nonLinearTunnel.pathingWeights = {primary = 50, secondary = 25}
	nonLinearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 50}
end

function nonLinearTunnel.computeRelativePathWeight(map, x, y)
    nPer = y / map.height
    sPer = (map.height-y) / map.height
    ePer = (map.width-x) / map.width
    wPer = x / map.width
    return {north = helpers.int(nonLinearTunnel.directionWeight.north * nPer),
			west = helpers.int(nonLinearTunnel.directionWeight.west * wPer),
			east = helpers.int(nonLinearTunnel.directionWeight.east * ePer),
			south = helpers.int(nonLinearTunnel.directionWeight.south * sPer)}
end

function nonLinearTunnel.compareAndNil(val1, val2)
	return ((val1 == nil) or (val1 == val2))
end

function nonLinearTunnel.nearWall(map, x, y, direction, distance)
	--print("nonLinearTunnel.nearWall("..x..","..y..","..direction..","..distance..")")
    isNearWall = false
	if(nonLinearTunnel.searchShape == "column") then
		if(distance<=0) then
			return false
		elseif(distance == 1 and nonLinearTunnel.quickTerminate) then
			if(direction == "north") then
				if(nonLinearTunnel.compareAndNil(map.grid[x][y-1], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y-1,"north",distance-1)
				end
			elseif(direction == "south") then
				if(nonLinearTunnel.compareAndNil(map.grid[x][y+1], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y+1,"south",distance-1)
				end
			elseif(direction == "west") then
				if((not map.grid[x-1]) or nonLinearTunnel.compareAndNil(map.grid[x-1][y], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x-1,y,"west",distance-1)
				end
			elseif(direction == "east") then
				if((not map.grid[x+1]) or nonLinearTunnel.compareAndNil(map.grid[x+1][y], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x+1,y,"east",distance-1)
				end
			end
		else
			if(direction == "north") then
				if(((not map.grid[x-1]) or nonLinearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor)) or 
						nonLinearTunnel.compareAndNil(map.grid[x][y-1], map.tileset.floor) or 
						((not map.grid[x+1]) or nonLinearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y-1,"north",distance-1)
				end
			elseif(direction == "south") then
				if(((not map.grid[x-1]) or nonLinearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor)) or 
						nonLinearTunnel.compareAndNil(map.grid[x][y+1], map.tileset.floor) or 
						((not map.grid[x+1]) or nonLinearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y+1,"south",distance-1)
				end
			elseif(direction == "west") then
				if((not map.grid[x-1]) or 
						(nonLinearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor) or 
						nonLinearTunnel.compareAndNil(map.grid[x-1][y], map.tileset.floor) or 
						nonLinearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x-1,y,"west",distance-1)
				end
			elseif(direction == "east") then
				if((not map.grid[x+1]) or 
						(nonLinearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor) or 
						nonLinearTunnel.compareAndNil(map.grid[x+1][y], map.tileset.floor) or 
						nonLinearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x+1,y,"east",distance-1)
				end
			end
		end
	elseif(nonLinearTunnel.searchShape == "diamond") then
		local distance = helpers.odd(distance,up)
		isNearWall = false
		positionAhead, halfDistance = distance, (helpers.int(distance / 2))
		local tx = function(ahead, side)
			if(direction == "north") then
				return (x - (helpers.int(ahead / 2)) + (side - 1))
			elseif(direction == "south") then
				return (x + (helpers.int(ahead / 2)) - (side - 1))
			elseif(direction == "west") then
				return (x + (helpers.int(ahead / 2)) - halfDistance - 1)
			elseif(direction == "east") then
				return (x - (helpers.int(ahead / 2)) + halfDistance + 1)
			end
		end
		local ty = function(ahead, side)
			if(direction == "north") then
				return (y + (helpers.int(ahead / 2)) - halfDistance - 1)
			elseif(direction == "south") then
				return (y - (helpers.int(ahead / 2)) + halfDistance + 1)
			elseif(direction == "west") then
				return (y + (helpers.int(ahead / 2)) - (side - 1))
			elseif(direction == "east") then
				return (y - (helpers.int(ahead / 2)) + (side - 1))
			end
		end
		while(positionAhead >= 1) do
			for positionSide=1,positionAhead do
				isNearWall = isNearWall or 
					(not map.grid[tx(positionAhead,positionSide)]) or
					nonLinearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	elseif(nonLinearTunnel.searchShape == "square") then
		local distance = helpers.odd(distance,up)
		isNearWall = false
		positionAhead, halfDistance = distance, (helpers.int(distance / 2))
		local tx = function(ahead, side)
			if(direction == "north") then
				return (x - halfDistance + (side - 1))
			elseif(direction == "south") then
				return (x + halfDistance - (side - 1))
			elseif(direction == "west") then
				return (x + (helpers.int(ahead / 2)) - halfDistance - 1)
			elseif(direction == "east") then
				return (x - (helpers.int(ahead / 2)) + halfDistance + 1)
			end
		end
		local ty = function(ahead, side)
			if(direction == "north") then
				return (y + (helpers.int(ahead / 2)) - halfDistance - 1)
			elseif(direction == "south") then
				return (y - (helpers.int(ahead / 2)) + halfDistance + 1)
			elseif(direction == "west") then
				return (y + halfDistance - (side - 1))
			elseif(direction == "east") then
				return (y - halfDistance + (side - 1))
			end
		end
		while(positionAhead >= 1) do
			for positionSide=1,distance do
				isNearWall = isNearWall or 
					(not map.grid[tx(positionAhead,positionSide)]) or
					nonLinearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	end
    return isNearWall
end

function nonLinearTunnel.nearEdge(map, x, y)
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

function nonLinearTunnel.newTile(map, x, y, direction, decay)
	--print("nonLinearTunnel.newTile("..x..","..y..","..direction..","..decay..")")
	map.grid[x][y] = map.tileset.floor
	if(decay < math.random(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "north") then
			if((math.random(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.north) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.west) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
            if(not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
            if(nonLinearTunnel.secondTest and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
		end
	elseif(direction == "south") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "south") then
			if((math.random(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.south) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.east) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
            if(not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
            if(nonLinearTunnel.secondTest and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
		end
	elseif(direction == "west") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "west") then
			if((math.random(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.west) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.south) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
            if(not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
            if(nonLinearTunnel.secondTest and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
		end
	elseif(direction == "east") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "east") then
			if((math.random(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((math.random(1,100) <= relativeDirectionWeight.east) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
            if((math.random(1,100) <= relativeDirectionWeight.north) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
            if(not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
            if(nonLinearTunnel.secondTest and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
		end
	end
	return
end
			
function nonLinearTunnel.generate(map, seed, decay)
	math.randomseed(seed)
	nonLinearTunnel.newTile(map,math.random((map.width / 4),((map.width * 3) / 4)),map.height,"north",decay)
	return
end

return nonLinearTunnel