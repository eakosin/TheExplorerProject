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
	level.scripts.base = {id = scripts.base.id, parameters = {}}
	mapGeneration.configureScript(scripts.base.script,level)
	mapGeneration.runScript(scripts.base.script,level.maps.base)
	--Modify - TODO: Should run all important scripts that match base ids.
	--e.g. - cleanup.lua, outlineWall.lua, etc.
	scripts.modify = {id = level.lcgrandom:int(1,#mapGeneration.modify.ids)}
	scripts.modify.script = mapGeneration.modify.ids[scripts.modify.id]
	level.scripts.modify = {id = scripts.modify.id, parameters = {}}
	--mapGeneration.configureScript(scripts.modify.script,level)
	mapGeneration.runScript(scripts.modify.script,level.maps.base)
	io.output("./mapoutput.grid", "w")
	level.maps.base:printReadableMap(" ")
	io.close()
end

function mapGeneration.configureScript(script,level)
	local constraint
	local dependList = {}
	for _,parameter in pairs(script.parameters) do
		if(script.constraint[parameter].range) then
			constraint = script.constraint[parameter].range
			script[parameter] = level.lcgrandom:int(unpack(constraint))
			level.scripts.base.parameters[parameter] = script[parameter]
		elseif(script.constraint[parameter].select) then
			constraint = script.constraint[parameter].select
			script[parameter] = constraint[level.lcgrandom:int(1,#constraint)]
			level.scripts.base.parameters[parameter] = script[parameter]
		elseif(script.constraint[parameter].seed) then
			script[parameter] = level.lcgrandom:int32()
			level.scripts.base.parameters[parameter] = script[parameter]
		elseif(script.constraint[parameter].procedure) then
			constraint = level.lcgrandom:int32()
			script.constraint[parameter].procedure(constraint)
			level.scripts.base.parameters[parameter] = script[parameter]
		elseif(script.constraint[parameter].depend) then
			dependList[#dependList + 1] = parameter
		end
		--Print Parameters DEBUG
		if(type(level.scripts.base.parameters[parameter]) == "table") then
			print(parameter..":")
			for k,v in pairs(level.scripts.base.parameters[parameter]) do
				print(k,v)
			end
		else
			print(parameter, level.scripts.base.parameters[parameter])
		end
	end
	print("Depend:")
	--Depend Constraints
	constraint = level.lcgrandom:int32()
	script.constraint.depend(constraint)
	level.scripts.base.parameters.depend = constraint
	for _,parameter in pairs(dependList) do
		level.scripts.base.parameters[parameter] = script[parameter]
		--Print Depend Parameters DEBUG
		if(type(level.scripts.base.parameters[parameter]) == "table") then
			print(parameter..":")
			for k,v in pairs(level.scripts.base.parameters[parameter]) do
				print(k,v)
			end
		else
			print(parameter, level.scripts.base.parameters[parameter])
		end
	end
end

function mapGeneration.runScript(script, map, ...)
	script.run(map, ...)
end