require("map/mapTypes")

mapGeneration = {}

require("map/generation/base/linearTunnel")
require("map/generation/base/nonLinearTunnel")
require("map/generation/base/linearCave")
require("map/generation/base/nonLinearCave")

function mapGeneration.testGeneration()
	local map1 = map:new()
	map1:buildMap(60,60)
	io.output("./mapoutput.grid", "w")

	linearCave.generate(map1,2,400)

	map1:printMap(" ")

	io.close()
end

function mapGeneration.manualGeneration(script,map,seed,decay)
	linearCave.generate(map,seed,decay)
end