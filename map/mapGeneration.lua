require("map/mapTypes")
require("map/generation/base/linearTunnel")
require("map/generation/base/nonLinearTunnel")
require("map/generation/base/linearCave")
require("map/generation/base/nonLinearCave")

map1 = map:new()
map1:buildMap(60,60)
io.output("./mapoutput.grid", "w")

linearCave.generate(map1,103,200)

map1:printMap(" ")

io.close()