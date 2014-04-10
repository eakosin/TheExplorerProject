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
progressBar.width, progressBar.height = 0, 0
progressBar.x, progressBar.y = 0, 0
progressBar.text = ""
progressBar.textOffset = 4
progressBar.active = false
progressBar.backImageName = ""
progressBar.frontImageName = ""
progressBar.vertices = { 
	{0, 0, 0, 0, 255, 255, 255, 255},		
	{progressBar.width/2, 0, 1, 0, 255, 255, 255, 255},		
	{0, progressBar.height, 0, 1, 255, 255, 255, 255},		
	{progressBar.width/2, progressBar.height, 1, 1, 255, 255, 255, 255},		
	}		
progressBar.progressBarMesh = {}
progressBar.progressBarQuad = {}

--[[
progressBar:new()
Creates a new progresss bar if the param is nil
]]--
--param: new - the object to be set as the progress bar. 
--returns: new - the object after the progress bar is created and setup.
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
--param: parameters - the list of values to set as the progress bar's atributes
--return: none
function progressBar:configure(parameters)
	for key, value in pairs(parameters) do
		self[key] = value
	end


	--configure back side of progress bar
	self.font = love.graphics.newFont("fonts/Karla/Karla-Regular.ttf", 18)
	self.backImage = love.graphics.newImage("images/"..self.backImageName)
	self.canvas = love.graphics.newCanvas(self.width,self.height)
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBackgroundColor(0,0,0,0)
	love.graphics.clear()
	love.graphics.draw(self.backImage, self.width/self.backImage:getWidth(), self.height/self.backImage:getHeight())
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(self.text, self.textOffset, ((self.height / 2) - (self.font:getHeight() / 2) - 2))
	
	--configure front side of progress bar
	self.frontImage = love.graphics.newImage("images/crapbackground.png")
	self.progressBarMesh = love.graphics.newMesh(self.vertices, self.frontImage, "triangles")
	self.progressBarMesh:setVertexMap(1,2,3,4,2,3)
	
	--reset global canvas
	love.graphics.setCanvas()

end

--[[
progressBar:update()
updates the width of the progress bar
]]--
--param: parameters - value = number to be displayed, maximum = number that is the max of the progress bar
--return: none
function progressBar:update(parameters)
	value = parameters[value] and parameters[value] or 0
	maximum = parameters[maximum] and parameters[maximum] or 1
	fraction = value/maximum
	
	self.vertices[2][1] = self.width*fraction
	self.vertices[4][1] = self.width*fraction
	self.progressBarMesh:setVertices(self.vertices)
end

--[[
progressBar:draw()
sends the progress bar canvas to the love library to draw it on the screen
]]--
--param: none
--return: none
function progressBar:draw()
	love.graphics.draw(self.canvas, self.x, self.y)
	love.graphics.draw(self.progressBarMesh, self.x, self.y)
--	love.graphics.print("frontStuff", self.x, self.y)
end

--[[
line object
]]--
line = {}
line.points = {x1, y1, x2, y2}
line.color = {255, 255, 255, 255}
line.thicknes = 0
line.style = "rough"


--[[
line:new()
Creates a new line if the param is nil
]]--
--param: new - the object to be set as the line. 
--returns: new - the object after the line is created and setup.
function line:new(new)
    	new = {}
	setmetatable(new, self)
    	self.__index = self
    	return new
end

--[[
line:configure()
Builds the line's properties based on the parameters passed in
]]--
--param: parameters - the list of values to set as the line's atributes
--return: none
function line:configure(params)
	self:update(params)
end

--[[
line:update()
updates the values of the line object.
]]--
--param: params - the keys and their values to be set as the objects values
--return: none
function line:update(params)
	for key, value in pairs(parameters) do
		self[key] = value
	end
end

--[[
line:draw()
draws the line object
]]--
--param: none
--return: none
function line:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.setLine(self.thickness, self.style)
	love.graphics.line(unpack(self.points))
end
