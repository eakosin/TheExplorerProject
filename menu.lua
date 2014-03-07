require("helpers")
require("ui")

menu = {}
menu.visible = true
menu.settings = {}
menu.screen = {main = {}, options = {}, help = {}}
menu.current = "main"
menu.eventQueue = {}

function menu.fillEventQueue()
	if(menu.mouseState.l) then
		menu.eventQueue[#menu.eventQueue + 1] = {name = "leftclick", x = (menu.mouseState.l.x / 2), y = (menu.mouseState.l.y / 2)}
	end
end

function menu.processEventQueue()
	for id = 1, #menu.eventQueue do
		event = menu.eventQueue[id]
		if(event.name == "leftclick") then
			debugLog:append(event.name.." "..tostring(event.x)..", "..tostring(event.y))
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
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "generatelevels"}
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "changelevel", id = 1}
					menu.world.eventQueue.world[#menu.world.eventQueue.world + 1] = {name = "createcharacter", id = 1}
					debugLog:append("menu "..tostring(menu.world.eventQueue.world[1]))
					menu.visible = false
					menu.world.loading = true
				end
			end
		end
	end
	menu.eventQueue = {}
end

--Against the design of the rest of this codebase, the menu will be hard defined here with static names.
--Yay...
function menu.initialize(parameters)
	for key, value in pairs(parameters) do
		menu[key] = value
	end
	
	menu.screen.main.buttons = {}
	menu.screen.main.buttons.quit = button:new()
	menu.screen.main.buttons.quit:configure{backImageName = "crapbuttonback.png", x = 362, y = 325, text = "Quit", width = 76, height = 50, textOffset = 20}
	--menu.screen.main.background = love.graphics.newImage("images/crapbackground.png")
	menu.screen.main.buttons.start = button:new()
	menu.screen.main.buttons.start:configure{backImageName = "crapbuttonback.png", x = 362, y = 125, text = "Start", width = 76, height = 50, textOffset = 15}
	menu.screen.main.background = love.graphics.newImage("images/crapbackground.png")
end

menu.screen.main.draw = function ()
	love.graphics.draw(menu.screen.main.background, 0, 0, 0, 1, 1)
	love.graphics.printf("You, and others around you are 'immigrants' to this city who were searching for a better life for your family after leaving the villages. This is the only job opportunity available and it barely provides enough for food and dwelling costs. This is similar to coal miners who have this as their only available job opportunity, and risk life and limb to support their family.", 5, 5, 600, 'left')
	love.graphics.printf("Your character's job is to test and report on randomly generated worlds to help find and refine bugs in the generational algorithms. This involves fighting your way through the monsters inhabiting each world and exploring to find as much loot as possible to improve your pay commission style.", 5, 150, 325, 'left')
	for _,button in pairs(menu.screen.main.buttons) do
		button:draw()
	end
end

menu.screen.options.draw = function ()

end

menu.screen.help.draw = function ()

end

function menu.draw()
	menu.screen[menu.current].draw()
end

