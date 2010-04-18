require "gamestate"
require "button"

gamestate.pause = gamestate.new{

enter = function(self)
	if not self.data.fontpos then
		local w2, h2 = love.graphics.getWidth()/2, love.graphics.getHeight()/2
		self.data.fontpos = {
			x = w2 - Font[60]:getWidth("PAUSE")/2,
			y = h2 - Font[60]:getHeight("PAUSE")/2,
		}
	end

	love.graphics.setFont(Font[60])
end,

leave = function()
	love.graphics.setFont(Font[20])
end,

draw = function(self)
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.draw(self.data.screen,0,0)
	love.graphics.setColor(0,60,0,100)
	love.graphics.rectangle('fill',0,0,w,h)
	love.graphics.setColor(0,255,0,255)
	love.graphics.print("PAUSE", self.data.fontpos.x, self.data.fontpos.y)
end,

onkey = function(self, key)
	if key == 'p' then
		gamestate.switch(gamestate.game)
	end
end

}

