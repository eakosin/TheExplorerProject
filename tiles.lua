require("helpers")

tiles = {}
tiles.defFile = "tileSet.def"
tiles.tileset = {}



--[[
tiles.buildTileset(defFile)
This function builds the set of tiles.
]]--
--param: defFile
--return: none
function tiles.buildTileset(defFile)
	tiles.defFile = defFile or "tileSet.def"
	tiles.tileset = {}
	for line in love.filesystem.lines(tiles.defFile) do
		name, char = line:divide("|")
		tiles.tileset[name] = tonumber(char)
	end
end


--[[
tiles.returnTileset()
This function returns the set of tiles.
]]--
--param: none
--return: tileset
function tiles.returnTileset()
	local tileset = tiles.tileset
	return tileset
end
