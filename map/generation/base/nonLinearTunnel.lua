require("helpers")

local nonLinearTunnel = {}

--[[
ID System:
Each script needs a unique id number.
Starting at 1.
I almost wish for a simpler way to do this configuration stuff,
but this way, it can be flexible or minutely controlled.
Documentation to come...
]]--
nonLinearTunnel.id = 4
nonLinearTunnel.name = "Branching Tunnel 1"
nonLinearTunnel.tileImageName = "craptileset.png"

--[[
Script compatibility:
This is extremely important. Here, you will declare which scripts are to follow this one.
This is an inclusive feature, which means only listed scripts will be used.
You can decalare scripts via constraints such as select, multiselect, or procedure.
]]--
nonLinearTunnel.modify = {2,2,3,1}

--Configuration Parameters
nonLinearTunnel.seed = 0
nonLinearTunnel.decay = 200
nonLinearTunnel.searchDistance = 13
nonLinearTunnel.shortCircuit = 0
nonLinearTunnel.edgeBuffer = 0
nonLinearTunnel.searchShape = "square"
nonLinearTunnel.relativeWeights = true
nonLinearTunnel.leftOnFailure = true
nonLinearTunnel.terminationWeight = 100
nonLinearTunnel.terminationStep = 0
nonLinearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 35}

--Create table of parameters
nonLinearTunnel.parameters = helpers.keys(nonLinearTunnel)

--Configuration Constraints
nonLinearTunnel.constraint = {}
for key,value in pairs(nonLinearTunnel.parameters) do
	nonLinearTunnel.constraint[value] = {}
end
nonLinearTunnel.constraint.id.none = true
nonLinearTunnel.constraint.name.none = true
nonLinearTunnel.constraint.tileImageName.none = true
nonLinearTunnel.constraint.modify.none = true
nonLinearTunnel.constraint.seed.seed = true
nonLinearTunnel.constraint.decay.range = {125,225}
nonLinearTunnel.constraint.searchDistance.range = {7,17}
nonLinearTunnel.constraint.shortCircuit.depend = true
nonLinearTunnel.constraint.edgeBuffer.procedure = function (seed)
	local lcgrandomLocal = lcgrandom:new()
	lcgrandomLocal:seed(seed)
	nonLinearTunnel.edgeBuffer = (helpers.clamp(helpers.round(weighting.oddExp(lcgrandomLocal:float(),5,2,0.5,-2,0)),0,2) + 1)
end
nonLinearTunnel.constraint.searchShape.select = {"square","square","diamond","diamond","column"}
nonLinearTunnel.constraint.relativeWeights.select = {true,true,true,true,false,false}
nonLinearTunnel.constraint.leftOnFailure.select = {true,false}
nonLinearTunnel.constraint.terminationWeight.range = {92,100}
nonLinearTunnel.constraint.terminationStep.select = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,6,6,7,8}
nonLinearTunnel.constraint.directionWeight.procedure = function (seed)
	local lcgrandomLocal = lcgrandom:new()
	lcgrandomLocal:seed(seed)
	nonLinearTunnel.directionWeight.north = helpers.clamp(weighting.invExp(lcgrandomLocal:float(),4,100,1.075,0,0),0,100)
	nonLinearTunnel.directionWeight.south = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-80,-15),0,100)
	nonLinearTunnel.directionWeight.west = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-110,25),0,100)
	nonLinearTunnel.directionWeight.east = helpers.clamp(weighting.oddExp(lcgrandomLocal:float(),3,100,0.55,-110,25),0,100)
end

--Depend function.
nonLinearTunnel.constraint.depend = function (seed)
	local lcgrandomLocal = lcgrandom:new()
	lcgrandomLocal:seed(seed)
	nonLinearTunnel.shortCircuit = helpers.int(helpers.clamp(weighting.exp(lcgrandomLocal:float(),8,(nonLinearTunnel.searchDistance - 3),1,0,0),0,(nonLinearTunnel.searchDistance - 3)))
end

--TODO: Script parameter forwarding for explicit configuration?

nonLinearTunnel.lcgrandom = nil

function nonLinearTunnel.resetVariables()
	nonLinearTunnel.seed = 0
	nonLinearTunnel.decay = 200
	nonLinearTunnel.searchDistance = 13
	nonLinearTunnel.shortCircuit = 0
	nonLinearTunnel.searchShape = "square"
	nonLinearTunnel.relativeWeights = true
	nonLinearTunnel.secondTest = true
	nonLinearTunnel.leftOnFailure = true
	nonLinearTunnel.terminationWeight = 100
	nonLinearTunnel.terminationStep = 0
	nonLinearTunnel.directionWeight = {north = 100, west = 75, east = 75, south = 35}
end

function nonLinearTunnel.computeRelativePathWeight(map, x, y)
	if(nonLinearTunnel.relativeWeights) then
		nPer = y / map.height
		sPer = (map.height-y) / map.height
		ePer = (map.width-x) / map.width
		wPer = x / map.width
		return {north = helpers.int(nonLinearTunnel.directionWeight.north * nPer),
				west = helpers.int(nonLinearTunnel.directionWeight.west * wPer),
				east = helpers.int(nonLinearTunnel.directionWeight.east * ePer),
				south = helpers.int(nonLinearTunnel.directionWeight.south * sPer)}
	else
		return {north = nonLinearTunnel.directionWeight.north,
				west = nonLinearTunnel.directionWeight.west,
				east = nonLinearTunnel.directionWeight.east,
				south = nonLinearTunnel.directionWeight.south}
	end
end

function nonLinearTunnel.compareAndNil(val1, val2, nilIsFalse)
	return ((val1 == val2) or ((not nilIsFalse) and (val1 == nil)))
end

function nonLinearTunnel.nearWall(map, x, y, direction, distance, nilIsFalse)
	nilIsFalse = nilIsFalse or false
	--print("nonLinearTunnel.nearWall("..x..","..y..","..direction..","..distance..")")
    isNearWall = false
	if(nonLinearTunnel.searchShape == "column") then
		if(distance<=0) then
			return false
		else
			if(direction == "north") then
				if(((not map.grid[x-1]) or nonLinearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor, nilIsFalse)) or 
						nonLinearTunnel.compareAndNil(map.grid[x][y-1], map.tileset.floor, nilIsFalse) or 
						((not map.grid[x+1]) or nonLinearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor, nilIsFalse))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y-1,"north",distance-1,nilIsFalse)
				end
			elseif(direction == "south") then
				if(((not map.grid[x-1]) or nonLinearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor, nilIsFalse)) or 
						nonLinearTunnel.compareAndNil(map.grid[x][y+1], map.tileset.floor, nilIsFalse) or 
						((not map.grid[x+1]) or nonLinearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor, nilIsFalse))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x,y+1,"south",distance-1,nilIsFalse)
				end
			elseif(direction == "west") then
				if((not map.grid[x-1]) or 
						(nonLinearTunnel.compareAndNil(map.grid[x-1][y-1], map.tileset.floor, nilIsFalse) or 
						nonLinearTunnel.compareAndNil(map.grid[x-1][y], map.tileset.floor, nilIsFalse) or 
						nonLinearTunnel.compareAndNil(map.grid[x-1][y+1], map.tileset.floor, nilIsFalse))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x-1,y,"west",distance-1,nilIsFalse)
				end
			elseif(direction == "east") then
				if((not map.grid[x+1]) or 
						(nonLinearTunnel.compareAndNil(map.grid[x+1][y+1], map.tileset.floor, nilIsFalse) or 
						nonLinearTunnel.compareAndNil(map.grid[x+1][y], map.tileset.floor, nilIsFalse) or 
						nonLinearTunnel.compareAndNil(map.grid[x+1][y-1], map.tileset.floor, nilIsFalse))) then
					return true
				else
					isNearWall = isNearWall or nonLinearTunnel.nearWall(map,x+1,y,"east",distance-1,nilIsFalse)
				end
			end
		end
	elseif(nonLinearTunnel.searchShape == "diamond") then
		local distance = helpers.odd(distance,true)
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
					nonLinearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor, nilIsFalse)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	elseif(nonLinearTunnel.searchShape == "square") then
		local distance = helpers.odd(distance,true)
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
					nonLinearTunnel.compareAndNil(map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)], map.tileset.floor, nilIsFalse)
				--print(direction,"x:"..x,"y:"..y,"tx:"..tx(positionAhead,positionSide),"ty:"..ty(positionAhead,positionSide),map.grid[tx(positionAhead,positionSide)][ty(positionAhead,positionSide)],isNearWall)
			end
			positionAhead = positionAhead - 2
		end
	end
    return isNearWall
end

function nonLinearTunnel.nearEdge(map, x, y)
    if(y <= (1 + nonLinearTunnel.edgeBuffer)) then
        return "north"
	end
    if((map.height - nonLinearTunnel.edgeBuffer) <= y) then
        return "south"
	end
    if(x <= (1 + nonLinearTunnel.edgeBuffer)) then
        return "west"
	end
    if((map.width - nonLinearTunnel.edgeBuffer) <= x) then
        return "east"
	end
    return "floor"
end

function nonLinearTunnel.newTile(map, x, y, direction, decay, termination)
	--print("nonLinearTunnel.newTile("..x..","..y..","..direction..","..decay..")")
	map.grid[x][y] = map.tileset.floor
	if(decay < nonLinearTunnel.lcgrandom:int(0,100)) then
		--print("DECAYED")
		return
	end
	if(direction == "north") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "north") then
			if((nonLinearTunnel.lcgrandom:int(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,nonLinearTunnel.terminationWeight)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,nonLinearTunnel.terminationWeight)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.north) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.west) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.leftOnFailure or (nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.east)) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,nonLinearTunnel.terminationWeight) <= termination) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance,true))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,(termination-nonLinearTunnel.terminationStep))
			end
		end
	elseif(direction == "south") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "south") then
			if((nonLinearTunnel.lcgrandom:int(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,nonLinearTunnel.terminationWeight)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,nonLinearTunnel.terminationWeight)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.south) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.east) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.leftOnFailure or (nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.west)) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,nonLinearTunnel.terminationWeight) <= termination) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance,true))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,(termination-nonLinearTunnel.terminationStep))
			end
		end
	elseif(direction == "west") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "west") then
			if((nonLinearTunnel.lcgrandom:int(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,nonLinearTunnel.terminationWeight)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,nonLinearTunnel.terminationWeight)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.west) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.south) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.leftOnFailure or (nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.north)) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,nonLinearTunnel.terminationWeight) <= termination) and (not nonLinearTunnel.nearWall(map,x,y,"west",nonLinearTunnel.searchDistance,true))) then
                nonLinearTunnel.newTile(map,x-1,y,"west",decay-1,(termination-nonLinearTunnel.terminationStep))
			end
		end
	elseif(direction == "east") then
		if(nonLinearTunnel.nearEdge(map,x,y) == "east") then
			if((nonLinearTunnel.lcgrandom:int(0,100) <= 50) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
				nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,nonLinearTunnel.terminationWeight)
			elseif(not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit)) then
				nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,nonLinearTunnel.terminationWeight)
			end
		else
			local relativeDirectionWeight = nonLinearTunnel.computeRelativePathWeight(map,x,y)
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.east) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.north) and (not nonLinearTunnel.nearWall(map,x,y,"north",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y-1,"north",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.leftOnFailure or (nonLinearTunnel.lcgrandom:int(1,100) <= relativeDirectionWeight.south)) and (not nonLinearTunnel.nearWall(map,x,y,"south",nonLinearTunnel.searchDistance-nonLinearTunnel.shortCircuit))) then
                nonLinearTunnel.newTile(map,x,y+1,"south",decay-1,nonLinearTunnel.terminationWeight)
			end
            if((nonLinearTunnel.lcgrandom:int(1,nonLinearTunnel.terminationWeight) <= termination) and (not nonLinearTunnel.nearWall(map,x,y,"east",nonLinearTunnel.searchDistance,true))) then
                nonLinearTunnel.newTile(map,x+1,y,"east",decay-1,(termination-nonLinearTunnel.terminationStep))
			end
		end
	end
	return
end
			
function nonLinearTunnel.run(map)
	nonLinearTunnel.lcgrandom = lcgrandom:new()
	nonLinearTunnel.lcgrandom:seed(nonLinearTunnel.seed)
	map.start = {x = nonLinearTunnel.lcgrandom:int(helpers.int(map.width / 4),helpers.int((map.width * 3) / 4)), y = map.height,}
	nonLinearTunnel.newTile(map,map.start.x,map.start.y,"north",nonLinearTunnel.decay,nonLinearTunnel.terminationWeight)
	return
end

return nonLinearTunnel