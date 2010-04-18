require "gamestate"
require "button"

local playernames = {"Player One", "Player Two"}

gamestate.finish = gamestate.new {

enter = function(self, opt)
	self.data.screen = love.graphics.newScreenshot()
	self.data.screen = love.graphics.newImage(self.data.screen)

	self.data.gametime = string.format("%.2fs", opt[2].gametime)
	local posession = math.ceil(opt[2].posession/opt[2].gametime * 100)
	self.data.posession = string.format("%d%%/%d%%", posession, (100 - posession))
	local speednames = {
		"Like a snail",
		"Like the british rail",
		"Like "..playernames[(opt[1]%2 + 1)].."'s relexes",
		"Like a Porsche Roadster",
		"Ridiculously fast",
		"Like the Millenium Falcon",
	}
	local speed = math.ceil(opt[2].speed / 1400 * #speednames)
	self.data.speed = speednames[speed]
	self.data.scorediff = opt[2].scorediff
	if self.data.scorediff > 8 then
		self.data.mocking = playernames[(opt[1]%2)+1]..", are you still alive?"
	elseif self.data.scorediff > 6 then
		self.data.mocking = playernames[(opt[1]%2 + 1)].." never really had a chance"
	elseif self.data.scorediff > 4 then
		self.data.mocking = playernames[opt[1]].." humiliated "..playernames[(opt[1]%2)+1]
	elseif self.data.scorediff > 2 then
		self.data.mocking = playernames[opt[1]].." showed some serious ownage"
	else
		self.data.mocking = "Damn, that was close!"
	end

	if not self.data.posession then
		self.data.posession = "50%/50%"
	end
	self.data.statstring = string.format("%s\n%s\n%s",
	self.data.gametime, self.data.speed,
	self.data.posession)
	self.data.titlestr= "Gametime:\nBall speed:\nBall posession:"

	if not self.data.button then
		local btnpos = vector.new(love.graphics.getWidth()/2, love.graphics.getHeight() - 100)
		self.data.button = button.new{
			pos = btnpos,
			size = vector.new(200,45),
			text = "Menu",
			onclick = function(self)
				sound.select()
				gamestate.switch(gamestate.menu)
			end,
			onenter = function(self)
				sound.click()
			end,
		}
	end

	self.data.message = string.format("%s wins!", playernames[opt[1]])
	local align = vector.new(Font[60]:getWidth(self.data.message), Font[60]:getHeight(self.data.message))
	self.data.textpos = vector.new(love.graphics.getWidth(), love.graphics.getHeight() - 200)/2
	self.data.textpos = self.data.textpos - align/2
end,

mousereleased = function(self, x,y,btn)
	self.data.button:mouse(x,y,btn)
end,

leave = function(self)
end,

draw = function(self)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	local w2, h2 = w/2,h/2
	love.graphics.draw(self.data.screen,0,0)
	love.graphics.setColor(0,60,0,100)
	love.graphics.rectangle('fill',0,0,w,h)

	love.graphics.setColor(0,255,0,255)
	love.graphics.setFont(Font[60])
	love.graphics.print(self.data.message, self.data.textpos.x, self.data.textpos.y)

	love.graphics.setFont(Font[30])
	self.data.button:draw()

	local staty = 230
	love.graphics.setColor(0,30,0,180)
	love.graphics.rectangle('fill',160, staty, 480, 180)
	love.graphics.setColor(0,100,0,255)
	love.graphics.rectangle('line',160, staty, 480, 180)
	local x2 = w2 - Font[30]:getWidth("Game stats") / 2
	love.graphics.print("Game stats", x2, staty + 30)

	love.graphics.setFont(Font[20])
	x2 = Font[20]:getWidth("Score Difference:")
	love.graphics.printf(self.data.titlestr, 170, staty + 70, 300)
	love.graphics.printf(self.data.statstring, 170+x2+30, staty + 70, 300)
	x2 = w2 - Font[20]:getWidth(self.data.mocking) / 2
	love.graphics.setColor(0,140,0,255)
	love.graphics.printf(self.data.mocking, x2, staty+160, 400)

	particles.draw()
end,

update = function(self, dt)
	particles.update(dt)
	self.data.button:update(dt)
end

}
