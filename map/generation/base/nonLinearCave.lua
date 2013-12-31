require("helpers")

local nonLinearCave = {}

--[[
ID System:
Each script needs a unique id number.
Generation scripts span 1000-1999
Modify scripts span 2000-2999
]]--
nonLinearCave.id = 1
nonLinearCave.name = "Cave 1"
nonLinearCave.tileImageName = "craptileset.png"

--[[
Script compatibility:
This is extremely important. Here, you will declare which scripts are to follow this one.
This is an inclusive feature, which means only listed scripts will be used.
You can decalare scripts via constraints such as select, multiselect, or procedure.
]]--
nonLinearCave.modify = {3,1}
nonLinearCave.decorate = {1,2}

--Configuration Parameters
nonLinearCave.seed = 0
nonLinearCave.decay = 200
nonLinearCave.searchDistance = 3
nonLinearCave.shortCircuit = 0
nonLinearCave.originalSearch = true
nonLinearCave.secondTest = false
nonLinearCave.relativeWeights = true
nonLinearCave.directionWeight = {north = 100, west = 75, east = 75, south = 35}

--Create table of parameters
nonLinearCave.parameters = helpers.keys(nonLinearCave)

--Configuration Constraints
nonLinearCave.constraint = {}
for key,value in pairs(nonLinearCave.parameters) do
	nonLinearCave.constraint[value] = {}
end
nonLinearCave.constraint.id.none = true
nonLinearCave.constraint.name.none = true
nonLinearCave.constraint.tileImageName.none = true
nonLinearCave.constraint.modify.none = true
nonLinearCave.constraint.decorate.none = true
nonLinearCave.constraint.seed.seed = true
nonLinearCave.constraint.searchDistance.none = true
nonLinearCave.constraint.originalSearch.none = true
nonLinearCave.constraint.secondTest.none = true
nonLinearCave.constraint.decay.range = {125,225}
nonLinearCave.constraint.shortCircuit.select = {0,0,0,0,0,1}
nonLinearCave.constraint.relativeWeights.select = {true,true,true,true,false,false}
nonLinearCave.constraint.directionWeight.procedure = function (seed)
	local lcgrandomLocal = lcgrandom:new()
	lcgrandomLocal:seed(seed)
	nonLinearCave.directionWeight.north = helpers.clamp(weighting.invExp(lcgrandomLocal:float(),4,100,1.075,0,0),0,100)
	nonLinearCave.directionWeight.south = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-80,-15),0,100)
	nonLinearCave.directionWeight.west = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-110,25),0,100)
	nonLinearCave.directionWeight.east = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-110,25),0,100)
end

function nonLinearCave.resetVariables()
	nonLinearCave.searchDistance = 2
	nonLinearCave.shortCircuit = 0
	nonLinearCave.originalSearch = true
	nonLinearCave.secondTest = false
	nonLinearCave.directionWeight = {north = 100, west = 75, east = 75, south = 35}
end

nonLinearCave.lcgrandom = nil

function nonLinearCave.computeRelativePathWeight(map, x, y)
	if(nonLinearCave.relativeWeights) then
		nPer = y / map.height
		sPer = (map.height-y) / map.height
		ePer = (map.width-x) / map.width
		wPer = x / map.width
		return {north = helpers.int(nonLinearCave.directionWeight.north * nPer),
				west = helpers.int(nonLinearCave.directionWeight.west * wPer),
				east = helpers.int(nonLinearCave.directionWeight.east * ePer),
				south = helpers.int(nonLinearCave.directionWeight.south * sPer)}
	else
		return {north = nonLinearCave.directionWeight.north,
				west = nonLinearCave.directionWeight.west,
				east = nonLinearCave.directionWeight.east,
				south = nonLinearCave.directionWeight.south}
	end
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
	if(decay < nonLinearCave.lcgrandom:int(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(nonLinearCave.nearEdge(map,x,y) == "north") then
			if((nonLinearCave.lcgrandom:int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((nonLinearCave.lcgrandom:int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((nonLinearCave.lcgrandom:int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.west) and (not nonLinearCave.nearWall(map,x,y,"west",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x-1,y,"west",decay-1)
			end
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.south) and (not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			if((nonLinearCave.lcgrandom:int(0,100) <= 50) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
				nonLinearCave.newTile(map,x,y-1,"north",decay-1)
			elseif(not nonLinearCave.nearWall(map,x,y,"south",nonLinearCave.searchDistance-nonLinearCave.shortCircuit)) then
				nonLinearCave.newTile(map,x,y+1,"south",decay-1)
			end
		else
			local relativeDirectionWeight = nonLinearCave.computeRelativePathWeight(map,x,y)
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.east) and (not nonLinearCave.nearWall(map,x,y,"east",nonLinearCave.searchDistance))) then
                nonLinearCave.newTile(map,x+1,y,"east",decay-1)
			end
            if((nonLinearCave.lcgrandom:int(1,100) <= relativeDirectionWeight.north) and (not nonLinearCave.nearWall(map,x,y,"north",nonLinearCave.searchDistance-nonLinearCave.shortCircuit))) then
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
			
function nonLinearCave.run(map, seed, decay)
	nonLinearCave.lcgrandom = lcgrandom:new()
	nonLinearCave.lcgrandom:seed(nonLinearCave.seed)
	map.start = {x = nonLinearCave.lcgrandom:int(helpers.int(map.width / 4),helpers.int((map.width * 3) / 4)), y = map.height,}
	nonLinearCave.newTile(map,map.start.x,map.start.y,"north",nonLinearCave.decay)
	return
end

return nonLinearCave