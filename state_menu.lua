require "vector"
require "sound"
require "gamestate"
require "particles"
require "button"

local next_difficulty = {
	Easy = "Normal",
	Normal = "Hard",
	Hard = "Easy"
}

gamestate.menu = gamestate.new{

data = {
	buttons = {},
	difficulty = "Normal",
},

init = function(self)
	local btnpos = vector.new(love.graphics.getWidth()/2, love.graphics.getHeight()/3 + 75)
	local btnspace = vector.new(0,75)
	self.data.buttons['0p'] = button.new{
		pos = btnpos,
		size = vector.new(400,45),
		text = "CPU vs CPU",
		onclick = function()
			sound.select()
			gamestate.switch(gamestate.game, {players=0, reset=true, difficulty = self.data.difficulty})
		end,
		onenter = function()
			sound.click()
		end,
	}

	self.data.buttons['1p'] = button.new{
		pos = btnpos + btnspace,
		size = vector.new(400,45),
		text = "Human vs CPU",
		onclick = function()
			sound.select()
			gamestate.switch(gamestate.game, {players=1, reset=true, difficulty = self.data.difficulty})
		end,
		onenter = function()
			sound.click()
		end,
	}

	self.data.buttons['2p'] = button.new{
		pos = btnpos + 2 * btnspace,
		size = vector.new(400,45),
		text = "Human vs Human",
		onclick = function(btn)
			sound.select()
			gamestate.switch(gamestate.game, {players=2, reset=true, difficulty = self.data.difficulty})
		end,
		onenter = function()
			sound.click()
		end,
	}

	self.data.buttons['diff'] = button.new{
		pos = btnpos + 3 * btnspace,
		size = vector.new(400,45),
		text = "Difficulty: "..self.data.difficulty,
		onclick = function(btn)
			sound.select()
			self.data.difficulty = next_difficulty[self.data.difficulty]
			btn.text = "Difficulty: " .. self.data.difficulty
		end,
		onenter = function()
			sound.click()
		end,
	}
end,

enter = function(self)
	love.graphics.setFont(Font[30])
end,

leave = function(self)
end,

mousereleased = function(self, x,y,btn)
	for _,b in pairs(self.data.buttons) do
		b:mouse(x,y,btn)
	end
end,

draw = function(self)
	love.graphics.setBackgroundColor(0,40,0)
	if not self.data.logo then
		local px,py = 148, 97
		px = love.graphics.getWidth()/2
		py = 140
		local title = 'p0ng'
		love.graphics.setFont(Font[120])
		love.graphics.setColor(0,60,0,255)
		love.graphics.printf(title, px+2, py+2, 0, 'center')
		love.graphics.setColor(0,200,0,255)
		love.graphics.printf(title, px-1, py-1, 0, 'center')
		love.graphics.setColor(0,100,0,255)
		love.graphics.printf(title, px, py, 0, 'center')
		love.graphics.setFont(Font[30])

		local screenshot = love.graphics.newScreenshot()
		local logodata = love.image.newImageData(300,130)
		logodata:paste(screenshot, 0,0, 
		love.graphics.getWidth()/2 - 148, 140 - 97, 300, 130)
		-- blur and spotlight
		logodata:mapPixel(function(x,y,r,g,b,a)
			local r,g,b,a = r,g,b,a
			if x > 2 and x < 297 then
				pixels = {
					{logodata:getPixel(x-2,y)},
					{logodata:getPixel(x-1,y)},
					{logodata:getPixel(x+1,y)},
					{logodata:getPixel(x+2,y)},
				}
				for _,p in pairs(pixels) do 
					r = r + p[1] 
					g = g + p[2] 
					b = b + p[3] 
				end
				r, g, b = r/(#pixels+1), g/(#pixels+1), b/(#pixels+1)
				g = math.max(math.sin(math.pi * (x+125) / 500) * math.sin(math.pi * y / 130) * 1.6 * g, 40)
				g = math.min(g, 255)
			end
			return r,g,b,a
		end)
		self.data.logo = love.graphics.newImage(logodata)
	else
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.data.logo, love.graphics.getWidth()/2 - 148, 140 - 97)
	end

	for _,b in pairs(self.data.buttons) do
		b:draw()
	end
	particles.draw()
end,

update = function(self, dt)
	particles.update(dt)
	for _,b in pairs(self.data.buttons) do
		b:update(dt)
	end
end,

}
