require("map/mapTypes")

mapGeneration = {}

mapGeneration['linearTunnel'] = require("map/generation/base/linearTunnel")
mapGeneration['nonLinearTunnel'] = require("map/generation/base/nonLinearTunnel")
mapGeneration['linearCave'] = require("map/generation/base/linearCave")
mapGeneration['nonLinearCave'] = require("map/generation/base/nonLinearCave")
mapGeneration['outlineWall'] = require("map/generation/modify/outlineWall")

function mapGeneration.testGeneration()
	local map1 = map:new()
	map1:buildMap(60,60)
	io.output("./mapoutput.grid", "w")

	linearCave.generate(map1,2,400)

	map1:printMap(" ")

	io.close()
end

function mapGeneration.runGenerate(script, map, seed, ...)
	mapGeneration[script].generate(map,seed,...)
end

function mapGeneration.runScript(script, map, ...)
	mapGeneration[script].run(map, ...)
end

function mapGeneration.configureVariable(script, parameter, value)
	mapGeneration[script][parameter] = value
end

function mapGeneration.configureTable(script, parameter, tableIn)
	for key, value in pairs(tableIn) do
		mapGeneration[script][parameter][key] = value
	end
end

function mapGeneration.getParameter(script, parameter)
	return mapGeneration[script][parameter]
end

--TODO: Test. May not work correctly.
function mapGeneration.getTableParameter(script, parameter)
	local returnTable = mapGeneration[script][parameter]
	return returnTable
end

function mapGeneration.getParameterList(script)
	local returnTable = mapGeneration[script].parameters
	for key,value in pairs(returnTable) do
		print(value)
	end
	return returnTable
end