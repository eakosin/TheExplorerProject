require("helpers")
require("ui")

menu = {}
menu.visible = true
menu.settings = {}
menu.screen = {main = {}, options = {}, help = {}}
menu.current = "main"
menu.eventQueue = {}


--[[
menu.fillEventQueue()
This function calls in every object in menu.
]]--
--param: none
--return: none
function menu.fillEventQueue()
	if(menu.mouseState.l) then
		menu.eventQueue[#menu.eventQueue + 1] = {name = "leftclick", x = (menu.mouseState.l.x / 2), y = (menu.mouseState.l.y / 2)}
	end
end



--[[
menu.processEventQueue()
This function sends event in queues to processing functions for that queue type.
]]--
--param: none
--return: none
function menu.processEventQueue()
	for id = 1, #menu.eventQueue do
		event = menu.eventQueue[id]
		if(event.name == "leftclick") then
			-- debugLog:append(event.name.." "..tostring(event.x)..", "..tostring(event.y))
			for _,button in pairs(menu.screen.main.buttons) do
				if((button.text == "Quit") and
					(button.x < event.x) and
					(event.x < button.x + button.width) and
					(button.y < event.y) and
					(event.y < button.y + button.height)) then
					love.event.quit()
				end
				if((button.text == "Start") and
					(button.x < event.x) and
					(event.x < button.x + button.width) and
					(button.y < event.y) and
					(event.y < button.y + button.height)) then
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "generatelevels", number = 1}
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "changelevel", id = 1}
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "createcharacter", id = 1}
					for i = 1, 25 do
						menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "createenemy", id = i}
					end
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "createai", id = 1}
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "createhealthbar", id = 1}
					-- debugLog:append("menu "..tostring(menu.world.eventQueue.world[1]))
					menu.visible = false
					menu.world.loading = true
				end
			end
		end
	end
	menu.eventQueue = {}
end


--[[
menu.initialize(parameters)
This function initializes a menu item with its label.
]]--
--param: parameters
--return: none
function menu.initialize(parameters)
	for key, value in pairs(parameters) do
		menu[key] = value
	end

	menu.screen.main.buttons = {}
	menu.screen.main.buttons.quit = button:new()
	menu.screen.main.buttons.quit:configure{backImageName = "crapbuttonback.png", x = menu.canvas:getWidth() / 2 - (76 / 2), y = 325, text = "Quit", width = 76, height = 50, textOffset = 20}
	menu.screen.main.buttons.start = button:new()
	menu.screen.main.buttons.start:configure{backImageName = "crapbuttonback.png", x = menu.canvas:getWidth() / 2 - (76 / 2), y = 125, text = "Start", width = 76, height = 50, textOffset = 15}
	menu.screen.main.background = love.graphics.newImage("images/crapbackground.png")
	menu.screen.main.background:setFilter("linear", "linear")
end

menu.screen.main.draw = function ()
	love.graphics.draw(menu.screen.main.background, 0, 0, 0, (menu.canvas:getWidth() / menu.screen.main.background:getWidth()), (menu.canvas:getWidth() / menu.screen.main.background:getWidth()))
	for _,button in pairs(menu.screen.main.buttons) do
		button:draw()
	end
end

menu.screen.options.draw = function ()

end

menu.screen.help.draw = function ()

end


--[[
menu.draw()
Call draw in menu to display on screen.
]]--
--param: none
--return: none
function menu.draw()
	menu.screen[menu.current].draw()
end

