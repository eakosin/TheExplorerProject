require("map/mapTypes")

mapGeneration = {}

scriptLocations = {"base", "modify"}--, "decorate", "populate", "dynamic"}

function mapGeneration.loadScripts()
	for i = 1, #scriptLocations do
		if(love.filesystem.exists("map/generation/"..scriptLocations[i])) then
			mapGeneration[scriptLocations[i]] = {}
			mapGeneration[scriptLocations[i]].ids = {}
			for _,file in pairs(love.filesystem.getDirectoryItems("map/generation/"..scriptLocations[i])) do
				scriptName = file:divide("%.")
				script = require("map/generation/"..scriptLocations[i].."/"..scriptName)
				mapGeneration[scriptLocations[i]].ids[script.id] = script
			end
		end
	end
end

function mapGeneration.generate(level)
	scripts = {}
	--scripts.base = {id = level.lcgrandom:int(1,#mapGeneration.base.ids)}
	--Temporarily static. Other scripts have not been correctly setup.
	scripts.base = {id = 4}
	scripts.base.script = mapGeneration.base.ids[scripts.base.id]
	level.layers.terrain.scripts = {}
	level.layers.terrain.scripts.base = {[scripts.base.id] = {}}
	mapGeneration.configureScript(scripts.base.script,"base","terrain",level)
	mapGeneration.runScript(scripts.base.script,level.layers.terrain.map)
	level.layers.terrain.tileImageName = scripts.base.script.tileImageName
	--Modify - TODO: Should run all important scripts that match base ids.
	--e.g. - cleanup.lua, outlineWall.lua, etc.
	scripts.modify = {id = level.lcgrandom:int(1,#mapGeneration.modify.ids)}
	scripts.modify.script = mapGeneration.modify.ids[scripts.modify.id]
	level.layers.terrain.modify = {[scripts.modify.id] = {}}
	--mapGeneration.configureScript(scripts.modify.script,"modify","terrain",level)
	mapGeneration.runScript(scripts.modify.script,level.layers.terrain.map)
	io.output("./mapoutput.grid", "w")
	level.layers.terrain.map:printReadableMap(" ")
	io.close()
end

function mapGeneration.configureScript(script,scriptType,layer,level)
	local constraint
	local dependList = {}
	for _,parameter in pairs(script.parameters) do
		if(script.constraint[parameter].range) then
			constraint = script.constraint[parameter].range
			script[parameter] = level.lcgrandom:int(unpack(constraint))
			level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		elseif(script.constraint[parameter].select) then
			constraint = script.constraint[parameter].select
			script[parameter] = constraint[level.lcgrandom:int(1,#constraint)]
			level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		elseif(script.constraint[parameter].seed) then
			script[parameter] = level.lcgrandom:int32()
			level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		elseif(script.constraint[parameter].procedure) then
			constraint = level.lcgrandom:int32()
			script.constraint[parameter].procedure(constraint)
			level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		elseif(script.constraint[parameter].depend) then
			dependList[#dependList + 1] = parameter
		elseif(script.constraint[parameter].none) then
			level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		end
		--Print Parameters DEBUG
		if(type(level.layers[layer].scripts[scriptType][script.id][parameter]) == "table") then
			print(parameter..":")
			for k,v in pairs(level.layers[layer].scripts[scriptType][script.id][parameter]) do
				print(k,v)
			end
		else
			print(parameter, level.layers[layer].scripts[scriptType][script.id][parameter])
		end
	end
	print("Depend:")
	--Depend Constraints
	constraint = level.lcgrandom:int32()
	script.constraint.depend(constraint)
	level.layers[layer].scripts[scriptType][script.id].depend = constraint
	for _,parameter in pairs(dependList) do
		level.layers[layer].scripts[scriptType][script.id][parameter] = script[parameter]
		--Print Depend Parameters DEBUG
		if(type(level.layers[layer].scripts[scriptType][script.id][parameter]) == "table") then
			print(parameter..":")
			for k,v in pairs(level.layers[layer].scripts[scriptType][script.id][parameter]) do
				print(k,v)
			end
		else
			print(parameter, level.layers[layer].scripts[scriptType][script.id][parameter])
		end
	end
end

function mapGeneration.runScript(script, map, ...)
	script.run(map, ...)
end