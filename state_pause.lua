require "gamestate"
require "button"

gamestate.pause = gamestate.new{

enter = function(self)
    self.data.screen = love.graphics.newScreenshot()
    self.data.screen = love.graphics.newImage(self.data.screen)

end,

draw = function(self)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local w2, h2 = w/2,h/2
    love.graphics.draw(self.data.screen,0,0)
    love.graphics.setColor(0,60,0,100)
    love.graphics.rectangle('fill',0,0,w,h)
    love.graphics.setColor(0,255,0,255)
    love.graphics.setFont(50)
    love.graphics.printf("PAUSE", w2, h2, 0, 'center')
    love.graphics.setFont(20)
end,

onkey = function(self, key)
    if key == 'p' then
        gamestate.switch(gamestate.game)
    end
end

}

