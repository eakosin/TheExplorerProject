require("tiles")
require("map/mapGeneration")
require("helpers")


tiles.buildTileset()

tileset = tiles.returnTileset()

keys = helpers.keys(tileset)

for dump, key in next,keys,nil do
	print(key," ",tileset[key])
end

print("Down:")
print("0 odd: "..helpers.odd(0))
print("0 even: "..helpers.even(0))
print("3 odd: "..helpers.odd(3))
print("4 odd: "..helpers.odd(4))
print("-3 odd: "..helpers.odd(-3))
print("-4 odd: "..helpers.odd(-4))
print("3 even: "..helpers.even(3))
print("4 even: "..helpers.even(4))
print("-3 even: "..helpers.even(-3))
print("-4 even: "..helpers.even(-4))
print("")
print("Up:")
print("0 odd: "..helpers.odd(0,true))
print("0 even: "..helpers.even(0,true))
print("3 odd: "..helpers.odd(3,true))
print("4 odd: "..helpers.odd(4,true))
print("-3 odd: "..helpers.odd(-3,true))
print("-4 odd: "..helpers.odd(-4,true))
print("3 even: "..helpers.even(3,true))
print("4 even: "..helpers.even(4,true))
print("-3 even: "..helpers.even(-3,true))
print("-4 even: "..helpers.even(-4,true))
