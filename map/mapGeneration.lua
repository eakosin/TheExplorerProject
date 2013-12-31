require("map/mapTypes")

mapGeneration = {}

scriptLocations = {"base", "modify", "decorate"}--, "populate", "dynamic"}

function mapGeneration.loadScripts()
	for i = 1, #scriptLocations do
		if(love.filesystem.exists("map/generation/"..scriptLocations[i])) then
			mapGeneration[scriptLocations[i]] = {}
			mapGeneration[scriptLocations[i]].scripts = {}
			for _,file in pairs(love.filesystem.getDirectoryItems("map/generation/"..scriptLocations[i])) do
				scriptName = file:divide("%.")
				script = require("map/generation/"..scriptLocations[i].."/"..scriptName)
				mapGeneration[scriptLocations[i]].scripts[script.id] = script
			end
		end
	end
end

function mapGeneration.generation(level)
	scripts = {}
	scripts.base = {id = level.lcgrandom:int(1,2)}
	--Temporarily static. Other scripts have not been correctly setup.
	--scripts.base = {id = 1}
	scripts.base.script = mapGeneration.base.scripts[scripts.base.id]
	level.terrain.scripts = {}
	level.terrain.scripts.base = {}
	mapGeneration.configureScript(scripts.base.script,"base","terrain",level)
	mapGeneration.runScript(scripts.base.script,level.terrain.map)
	level.terrain.tileImageName = scripts.base.script.tileImageName
	for i = 1, #level.terrain.scripts.base.modify do
		scripts.modify = {id = level.terrain.scripts.base.modify[i]}
		scripts.modify.script = mapGeneration.modify.scripts[scripts.modify.id]
		level.terrain.scripts.modify = {[scripts.modify.id] = {}}
		mapGeneration.configureScript(scripts.modify.script,"modify","terrain",level)
		mapGeneration.runScript(scripts.modify.script,level.terrain.map)
	end
	-- for i = 1, #level.terrain.scripts.base[scripts.base.id].decorate do
		-- scripts.decorate = {id = level.terrain.scripts.base[scripts.base.id].decorate[i]}
		-- scripts.decorate.script = mapGeneration.decorate.scripts[scripts.decorate.id]
		-- level.terrain.decorate = {[scripts.decorate.id] = {}}
		-- mapGeneration.configureScript(scripts.decorate.script,"decorate","decorate",level)
		-- mapGeneration.runScript(scripts.decorate.script,level.terrain.map)
	-- end
	io.output("./maps/mapoutput"..tostring(level.id)..".grid", "w")
	level.terrain.map:printReadableMap(" ")
	io.close()
end

function mapGeneration.decoration(level)
	level.decorate.scripts = {}
	for i = 1, #level.terrain.scripts.base.decorate do
		scripts.decorate = {id = level.terrain.scripts.base.decorate[i]}
		scripts.decorate.script = mapGeneration.decorate.scripts[scripts.decorate.id]
		level.decorate.scripts.decorate = {[scripts.decorate.id] = {}}
		mapGeneration.configureScript(scripts.decorate.script,"decorate","decorate",level)
		mapGeneration.runScript(scripts.decorate.script,level.terrain.map,level.decorate.map)
	end
	io.output("./maps/mapoutput"..tostring(level.id).."d.grid", "w")
	level.decorate.map:printReadableMap(" ")
	io.close()
end

function mapGeneration.configureScript(script,scriptType,layer,level)
	local constraint
	local dependList = {}
	debugLog:append("Script: "..tostring(script.name))
	for _,parameter in pairs(script.parameters) do
		if(script.constraint[parameter].range) then
			constraint = script.constraint[parameter].range
			script[parameter] = level.lcgrandom:int(unpack(constraint))
			level[layer].scripts[scriptType][parameter] = script[parameter]
		elseif(script.constraint[parameter].select) then
			constraint = script.constraint[parameter].select
			script[parameter] = constraint[level.lcgrandom:int(1,#constraint)]
			level[layer].scripts[scriptType][parameter] = script[parameter]
		elseif(script.constraint[parameter].seed) then
			script[parameter] = level.lcgrandom:int32()
			level[layer].scripts[scriptType][parameter] = script[parameter]
		elseif(script.constraint[parameter].procedure) then
			constraint = level.lcgrandom:int32()
			script.constraint[parameter].procedure(constraint)
			level[layer].scripts[scriptType][parameter] = script[parameter]
		elseif(script.constraint[parameter].depend) then
			dependList[#dependList + 1] = parameter
		elseif(script.constraint[parameter].none) then
			debugLog:append(script[parameter])
			level[layer].scripts[scriptType][parameter] = script[parameter]
		end
		--Print Parameters DEBUG
		if(type(level[layer].scripts[scriptType][parameter]) == "table") then
			debugLog:append(parameter..":")
			for k,v in pairs(level[layer].scripts[scriptType][parameter]) do
				debugLog:append("  "..tostring(k)..": "..tostring(v))
			end
		else
			debugLog:append(tostring(parameter)..": "..tostring(level[layer].scripts[scriptType][parameter]))
		end
	end
	debugLog:append("Depend:")
	--Depend Constraints
	if(script.constraint.depend) then
		constraint = level.lcgrandom:int32()
		script.constraint.depend(constraint)
		level[layer].scripts[scriptType].depend = constraint
		for _,parameter in pairs(dependList) do
			level[layer].scripts[scriptType][parameter] = script[parameter]
			--Print Depend Parameters DEBUG
			if(type(level[layer].scripts[scriptType][parameter]) == "table") then
				debugLog:append(parameter..":")
				for k,v in pairs(level[layer].scripts[scriptType][parameter]) do
					debugLog:append("  "..tostring(k)..": "..tostring(v))
				end
			else
				debugLog:append(tostring(parameter)..": "..tostring(level[layer].scripts[scriptType][parameter]))
			end
		end
	end
	debugLog:append()
end

function mapGeneration.runScript(script, map, ...)
	script.run(map, ...)
end