button = {}
button.width, button.height = 0, 0
button.x, button.y = 0, 0
button.text = ""
button.textOffset = 4
button.active = false
button.backImageName = ""

--[[
button:new()
Creates a new button if the param is nil
]]--
--param: new - the object to be set as the button. 
--returns: new - the object after the button is created and setup.
function button:new(new)
	new = new or {}
	setmetatable(new, self)
	self.__index = self
	return new
end

--[[
button:configure()
Builds the button's properties based on the parameters passed in
]]--
--param: parameters - the list of values to set as the button
--return: none
function button:configure(parameters)
	for key, value in pairs(parameters) do
		self[key] = value
	end
	self.font = love.graphics.newFont("fonts/Karla/Karla-Regular.ttf", 18)
	self.backImage = love.graphics.newImage("images/"..self.backImageName)
	self.canvas = love.graphics.newCanvas(self.width, self.height)
	local buttonQuad = love.graphics.newQuad(0, 0, self.width, self.height, self.backImage:getDimensions())
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBackgroundColor(0,0,0,0)
	love.graphics.clear()
	love.graphics.draw(self.backImage, buttonQuad)
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(self.text, self.textOffset, ((self.height / 2) - (self.font:getHeight() / 2) - 2))
	love.graphics.setCanvas()
end

--[[
button:draw()
sends the button object to the love library to draw it on the screen
]]--
--param: none
--return: none
function button:draw()
	love.graphics.draw(self.canvas, self.x, self.y)
end

progressBar = {}


progressBar = {}
progressBar.width, progressBar.height = 0, 0
progressBar.x, progressBar.y = 0, 0
progressBar.text = ""
progressBar.textOffset = 4
progressBar.active = false
progressBar.backImageName = ""
progressBar.frontImageName = ""
progressBar.verteicies = {}
progressBar.progressBarMesh = nil



--[[
progressBar:new()
Creates a new progresss bar if the param is nil
]]--
--param: new - the object to be set as the button. 
--returns: new - the object after the button is created and setup.
function progressBar:new(new)
	new = new or {}
	setmetatable(new, self)
	self.__index = self
	return new
end

--[[
progressBar:configure()
Builds the progress bar's properties based on the parameters passed in
]]--
--param: parameters - the list of values to set as the progress bar
--return: none
function progressBar:configure(parameters)
	for key, value in pairs(parameters) do
		self[key] = value
	end

	--configure back side of progress bar
	self.font = love.graphics.newFont("fonts/Karla/Karla-Regular.ttf", 18)
	self.backImage = love.graphics.newImage("images/"..self.backImageName)
	self.backCanvas = love.graphics.newCanvas(self.width, self.height)
	local progressBarQuad = love.graphics.newQuad(0, 0, self.width, self.height, self.backImage:getDimensions())
	love.graphics.setCanvas(self.backCanvas)
	love.graphics.setBackgroundColor(0,0,0,0)
	love.graphics.clear()
	love.graphics.draw(self.backImage, progressBarQuad)
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(self.text, self.textOffset, ((self.height / 2) - (self.font:getHeight() / 2) - 2))
	
	--configure front side of progress bar
	--self.frontCanvas = love.graphics.newCanvas(self.width, self.height)
	--self.frontImage = love.graphics.newImage("images/"..self.frontImageName)
	--self.progressBarMesh = love.graphics.newMesh(self.verticies, self.frontImage)
	--love.graphics.draw(self.frontImage, progressBarMesh)

	--reset global canvas
	love.graphics.setCanvas()

end

function progressBar:update(parameters)
	for key, value in pairs(parameters) do
		self[key] = value
	end
	--self.progressBarMesh.setVerticies(self.verticies, self.frontImage)
	--love.graphics.draw(self.frontImage, progressBarMesh)
end

--[[
progressBar:draw()
sends the progress bar object to the love library to draw it on the screen
]]--
--param: none
--return: none
function progressBar:draw()
	love.graphics.draw(self.backCanvas, self.x, self.y)
end

ui = {}
