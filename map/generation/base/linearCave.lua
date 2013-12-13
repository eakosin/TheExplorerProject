require("helpers")

local linearCave = {}

--[[
ID System:
Each script needs a unique id number.
Generation scripts span 1000-1999
Modify scripts span 2000-2999
]]--
linearCave.id = 2
linearCave.name = "Single Path Cave 1"

--Configuration Parameters
linearCave.searchDistance = 20
linearCave.shortCircuit = 0
linearCave.directionWeight = {north = 100, west = 75, east = 75, south = 50}

--Create table of parameters
linearCave.parameters = helpers.keys(linearCave)

--Configuration Constraints
--linearCave.constraint.searchDistance = 

function linearCave.resetVariables()
	linearCave.searchDistance = 20
	linearCave.shortCircuit = 0
	linearCave.directionWeight = {north = 100, west = 75, east = 75, south = 50}
end

function linearCave.computeRelativePathWeight(map, x, y)
    nPer = y / map.height
    sPer = (map.height-y) / map.height
    ePer = (map.width-x) / map.width
    wPer = x / map.width
    return {north = helpers.int(linearCave.directionWeight.north * nPer),
			west = helpers.int(linearCave.directionWeight.west * wPer),
			east = helpers.int(linearCave.directionWeight.east * ePer),
			south = helpers.int(linearCave.directionWeight.south * sPer)}
end

function linearCave.compareAndNil(val1, val2)
	return ((val1 == nil) or (val1 == val2))
end

function linearCave.nearWall(map, x, y, direction, distance)
	--print("linearCave.nearWall("..x..","..y..","..direction..","..distance..")")
    isNearWall = false
	if(distance<=0) then
		return false
	else
		if(direction == "north") then
			if(((not map.grid[x-1]) or linearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor)) or 
					linearCave.compareAndNil(map.grid[x][y-1], map.tileset.floor) or 
					((not map.grid[x+1]) or linearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return false or linearCave.nearWall(map,x,y-1,"north",distance-1)
			end
		elseif(direction == "south") then
			if(((not map.grid[x-1]) or linearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor)) or 
					linearCave.compareAndNil(map.grid[x][y+1], map.tileset.floor) or 
					((not map.grid[x+1]) or linearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor))) then
				return false or linearCave.nearWall(map,x,y+1,"south",distance-1)
			end
		elseif(direction == "west") then
			if((not map.grid[x-1]) or 
					(linearCave.compareAndNil(map.grid[x-1][y-1], map.tileset.floor) or 
					linearCave.compareAndNil(map.grid[x-1][y], map.tileset.floor) or 
					linearCave.compareAndNil(map.grid[x-1][y+1], map.tileset.floor))) then
				return false or linearCave.nearWall(map,x-1,y,"west",distance-1)
			end
		elseif(direction == "east") then
			if((not map.grid[x+1]) or 
					(linearCave.compareAndNil(map.grid[x+1][y+1], map.tileset.floor) or 
					linearCave.compareAndNil(map.grid[x+1][y], map.tileset.floor) or 
					linearCave.compareAndNil(map.grid[x+1][y-1], map.tileset.floor))) then
				return false or linearCave.nearWall(map,x+1,y,"east",distance-1)
			end
		end
	end
    return true
end

function linearCave.nearEdge(map, x, y)
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

function linearCave.newTile(map, x, y, direction, decay)
	--print("linearCave.newTile("..x..","..y..","..direction..","..decay..")")
	map.grid[x][y] = map.tileset.floor
	if(decay < lcgrandom.int(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(linearCave.nearEdge(map,x,y) == "north") then
			if((lcgrandom.int(0,100) <= 50) and (linearCave.nearWall(map,x,y,"west",linearCave.searchDistance-linearCave.shortCircuit))) then
				linearCave.newTile(map,x-1,y,"west",decay-1)
			elseif(linearCave.nearWall(map,x,y,"east",linearCave.searchDistance-linearCave.shortCircuit)) then
				linearCave.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = linearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (linearCave.nearWall(map,x,y,"north",linearCave.searchDistance))) then
                linearCave.newTile(map,x,y-1,"north",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (linearCave.nearWall(map,x,y,"west",linearCave.searchDistance-linearCave.shortCircuit))) then
                linearCave.newTile(map,x-1,y,"west",decay-1)
            elseif(linearCave.nearWall(map,x,y,"east",linearCave.searchDistance-linearCave.shortCircuit)) then
                linearCave.newTile(map,x+1,y,"east",decay-1)
            elseif(linearCave.nearWall(map,x,y,"north",linearCave.searchDistance)) then
                linearCave.newTile(map,x,y-1,"north",decay-1)
			end
		end
	elseif(direction == "south") then
		if(linearCave.nearEdge(map,x,y) == "south") then
			if((lcgrandom.int(0,100) <= 50) and (linearCave.nearWall(map,x,y,"east",linearCave.searchDistance-linearCave.shortCircuit))) then
				linearCave.newTile(map,x+1,y,"east",decay-1)
			elseif(linearCave.nearWall(map,x,y,"west",linearCave.searchDistance-linearCave.shortCircuit)) then
				linearCave.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = linearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (linearCave.nearWall(map,x,y,"south",linearCave.searchDistance))) then
                linearCave.newTile(map,x,y+1,"south",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (linearCave.nearWall(map,x,y,"east",linearCave.searchDistance-linearCave.shortCircuit))) then
                linearCave.newTile(map,x+1,y,"east",decay-1)
            elseif(linearCave.nearWall(map,x,y,"west",linearCave.searchDistance-linearCave.shortCircuit)) then
                linearCave.newTile(map,x-1,y,"west",decay-1)
            elseif(linearCave.nearWall(map,x,y,"south",linearCave.searchDistance)) then
                linearCave.newTile(map,x,y+1,"south",decay-1)
			end
		end
	elseif(direction == "west") then
		if(linearCave.nearEdge(map,x,y) == "west") then
			if((lcgrandom.int(0,100) <= 50) and (linearCave.nearWall(map,x,y,"south",linearCave.searchDistance-linearCave.shortCircuit))) then
				linearCave.newTile(map,x,y+1,"south",decay-1)
			elseif(linearCave.nearWall(map,x,y,"north",linearCave.searchDistance-linearCave.shortCircuit)) then
				linearCave.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = linearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.west) and (linearCave.nearWall(map,x,y,"west",linearCave.searchDistance))) then
                linearCave.newTile(map,x-1,y,"west",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.south) and (linearCave.nearWall(map,x,y,"south",linearCave.searchDistance-linearCave.shortCircuit))) then
                linearCave.newTile(map,x,y+1,"south",decay-1)
            elseif(linearCave.nearWall(map,x,y,"north",linearCave.searchDistance-linearCave.shortCircuit)) then
                linearCave.newTile(map,x,y-1,"north",decay-1)
            elseif(linearCave.nearWall(map,x,y,"west",linearCave.searchDistance)) then
                linearCave.newTile(map,x-1,y,"west",decay-1)
			end
		end
	elseif(direction == "east") then
		if(linearCave.nearEdge(map,x,y) == "east") then
			if((lcgrandom.int(0,100) <= 50) and (linearCave.nearWall(map,x,y,"north",linearCave.searchDistance-linearCave.shortCircuit))) then
				linearCave.newTile(map,x,y-1,"north",decay-1)
			elseif(linearCave.nearWall(map,x,y,"south",linearCave.searchDistance-linearCave.shortCircuit)) then
				linearCave.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = linearCave.computeRelativePathWeight(map,x,y)
            if((lcgrandom.int(1,100) <= relativeDirectionWeight.east) and (linearCave.nearWall(map,x,y,"east",linearCave.searchDistance))) then
                linearCave.newTile(map,x+1,y,"east",decay-1)
            elseif((lcgrandom.int(1,100) <= relativeDirectionWeight.north) and (linearCave.nearWall(map,x,y,"north",linearCave.searchDistance-linearCave.shortCircuit))) then
                linearCave.newTile(map,x,y-1,"north",decay-1)
            elseif(linearCave.nearWall(map,x,y,"south",linearCave.searchDistance-linearCave.shortCircuit)) then
                linearCave.newTile(map,x,y+1,"south",decay-1)
            elseif(linearCave.nearWall(map,x,y,"east",linearCave.searchDistance)) then
                linearCave.newTile(map,x+1,y,"east",decay-1)
			end
		end
	end
	return
end
			
function linearCave.run(map, seed, decay)
	lcgrandom.seed(seed)
	linearCave.newTile(map,lcgrandom.int((map.width / 4),((map.width * 3) / 4)),map.height,"north",decay)
	return
end

return linearCave