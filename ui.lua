button = {}
button.width, button.height = 0, 0
button.x, button.y = 0, 0
button.text = ""
button.textOffset = 4
button.active = false
button.backImageName = ""

function button:new(new)
	new = new or {}
	setmetatable(new, self)
	self.__index = self
	return new
end

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

function button:draw()
	love.graphics.draw(self.canvas, self.x, self.y)
end

ui = {}