require("helpers")

local linearTunnel = {}

--[[
ID System:
Each script needs a unique id number.
Generation scripts span 1000-1999
Modify scripts span 2000-2999
]]--
linearTunnel.id = 1002

--Configuration Parameters
linearTunnel.searchDistance = 5
linearTunnel.shortCircuit = 0
linearTunnel.closeFunc = false
linearTunnel.searchShape = "diamond"
linearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 50}

--Create table of parameters
linearTunnel.parameters = helpers.keys(linearTunnel)

--Configuration Constraints
--linearTunnel.constraint.searchDistance = 

function linearTunnel.resetVariables()
	linearTunnel.searchDistance = 4
	linearTunnel.shortCircuit = 0
	linearTunnel.closeFunc = false
	linearTunnel.shape = "column"
	linearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 50}
end

function linearTunnel.computeRelativePathWeight(map, x, y)
    nPer = y / map.height
    sPer = (map.height-y) / map.height
    ePer = (map.width-x) / map.width
    wPer = x / map.width
    return {north = helpers.int(linearTunnel.directionWeight.north * nPer),
			west = helpers.int(linearTunnel.directionWeight.west * wPer),
			east = helpers.int(linearTunnel.directionWeight.east * ePer),
			south = helpers.int(linearTunnel.directionWeight.south * sPer)}
end

function linearTunnel.compareAndNil(val1, val2)
	return ((val1 == nil) or (val1 == val2))
end

function linearTunnel.nearWall(map, x, y, direction, distance)
	--print("linearTunnel.nearWall("..x..","..y..","..direction..","..distance..")")
    isNearWall = false
	if(linearTunnel.searchShape == "column") then
		if(distance<=0) then
			return false
		elseif(distance == 1 and linearTunnel.quickTerminate) then
			if(direction == "north") then
				if(linearTunnel.compareAndNil(map.grid[x][y-1], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x,y-1,"north",distance-1)
				end
			elseif(direction == "south") then
				if(linearTunnel.compareAndNil(map.grid[x][y+1], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x,y+1,"south",distance-1)
				end
			elseif(direction == "west") then
				if((not map.grid[x-1]) or linearTunnel.compareAndNil(map.grid[x-1][y], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x-1,y,"west",distance-1)
				end
			elseif(direction == "east") then
				if((not map.grid[x+1]) or linearTunnel.compareAndNil(map.grid[x+1][y], map.tileset.floor)) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x+1,y,"east",distance-1)
				end
			end
		else
			if(direction == "north") then
				if(((not map.grid[x-1]) or linearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor)) or 
						linearTunnel.compareAndNil(map.grid[x][y-1], map.tileset.floor) or 
						((not map.grid[x+1]) or linearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x,y-1,"north",distance-1)
				end
			elseif(direction == "south") then
				if(((not map.grid[x-1]) or linearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor)) or 
						linearTunnel.compareAndNil(map.grid[x][y+1], map.tileset.floor) or 
						((not map.grid[x+1]) or linearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x,y+1,"south",distance-1)
				end
			elseif(direction == "west") then
				if((not map.grid[x-1]) or 
						(linearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor) or 
						linearTunnel.compareAndNil(map.grid[x-1][y], map.tileset.floor) or 
						linearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x-1,y,"west",distance-1)
				end
			elseif(direction == "east") then
				if((not map.grid[x+1]) or 
						(linearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor) or 
						linearTunnel.compareAndNil(map.grid[x+1][y], map.tileset.floor) or 
						linearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
					return true
				else
					isNearWall = isNearWall or linearTunnel.nearWall(map,x+1,y,"east",distance-1)
				end
			end
		end
	elseif(linearTunnel.searchShape == "diamond") then
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
					linearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	elseif(linearTunnel.searchShape == "square") then
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
					linearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	end
    return isNearWall
end

function linearTunnel.nearEdge(map, x, y)
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

function linearTunnel.newTile(map, x, y, direction, decay)
	--print("linearTunnel.newTile("..x..","..y..","..direction..","..decay..")")
	map.grid[x][y] = map.tileset.floor
	if(decay < lcgrandom.int(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(linearTunnel.nearEdge(map,x,y) == "north") then
			if((lcgrandom.int(0,100) <= 50) and (not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
				linearTunnel.newTile(map,x-1,y,"west",decay-1)
			elseif(not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
				linearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = linearTunnel.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance))) then
                linearTunnel.newTile(map,x,y-1,"north",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
                linearTunnel.newTile(map,x-1,y,"west",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
                linearTunnel.newTile(map,x+1,y,"east",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance)) then
                linearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
		end
	elseif(direction == "south") then
		if(linearTunnel.nearEdge(map,x,y) == "south") then
			if((lcgrandom.int(0,100) <= 50) and (not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
				linearTunnel.newTile(map,x+1,y,"east",decay-1)
			elseif(not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
				linearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = linearTunnel.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance))) then
                linearTunnel.newTile(map,x,y+1,"south",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
                linearTunnel.newTile(map,x+1,y,"east",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
                linearTunnel.newTile(map,x-1,y,"west",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance)) then
                linearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
		end
	elseif(direction == "west") then
		if(linearTunnel.nearEdge(map,x,y) == "west") then
			if((lcgrandom.int(0,100) <= 50) and (not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
				linearTunnel.newTile(map,x,y+1,"south",decay-1)
			elseif(not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
				linearTunnel.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = linearTunnel.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance))) then
                linearTunnel.newTile(map,x-1,y,"west",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
                linearTunnel.newTile(map,x,y+1,"south",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
                linearTunnel.newTile(map,x,y-1,"north",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"west",linearTunnel.searchDistance)) then
                linearTunnel.newTile(map,x-1,y,"west",decay-1)
			end
		end
	elseif(direction == "east") then
		if(linearTunnel.nearEdge(map,x,y) == "east") then
			if((lcgrandom.int(0,100) <= 50) and (not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
				linearTunnel.newTile(map,x,y-1,"north",decay-1)
			elseif(not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
				linearTunnel.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = linearTunnel.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance))) then
                linearTunnel.newTile(map,x+1,y,"east",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (not linearTunnel.nearWall(map,x,y,"north",linearTunnel.searchDistance-linearTunnel.shortCircuit))) then
                linearTunnel.newTile(map,x,y-1,"north",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"south",linearTunnel.searchDistance-linearTunnel.shortCircuit)) then
                linearTunnel.newTile(map,x,y+1,"south",decay-1)
            elseif(not linearTunnel.nearWall(map,x,y,"east",linearTunnel.searchDistance)) then
                linearTunnel.newTile(map,x+1,y,"east",decay-1)
			end
		end
	end
	return
end
			
function linearTunnel.generate(map, seed, decay)
	lcgrandom.seed(seed)
	linearTunnel.newTile(map,lcgrandom.int((map.width / 4),((map.width * 3) / 4)),map.height,"north",decay)
	return
end

return linearTunnel