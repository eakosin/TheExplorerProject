require("helpers")

tiles = {}
tiles.defFile = "tileSet.def"
tiles.tileset = {}

function tiles:buildTileset(defFile)
	tiles.defFile = defFile or "tileSet.def"
	tiles.tileset = {}
	for line in love.filesystem.lines(tiles.defFile) do
		name, char = line:split("|")
		tiles.tileset[name] = char
	end
end

function tiles:returnTileset()
	local tileset = tiles.tileset
	return tileset
end