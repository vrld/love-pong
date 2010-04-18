require "gamestate"
require "button"

gamestate.finish = gamestate.new {

enter = function(self, winner)
    self.data.screen = love.graphics.newScreenshot()
    self.data.screen = love.graphics.newImage(self.data.screen)
    self.data.winner = winner

    if not self.data.button then
        local btnpos = vector.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 100)
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

    self.data.message = string.format("Player %d wins!", self.data.winner)
    love.graphics.setFont(50)
    local font = love.graphics.getFont()
    local align = vector.new(font:getWidth(self.data.message), font:getHeight(self.data.message))
    self.data.textpos = vector.new(love.graphics.getWidth(), love.graphics.getHeight())/2
    self.data.textpos = self.data.textpos - align / 2
end,

mousereleased = function(self, x,y,btn)
    love.graphics.setFont(50)
    self.data.button:mouse(x,y,btn)
end,

leave = function(self)
    love.graphics.setFont(20)
end,

draw = function(self)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local w2, h2 = w/2,h/2
    love.graphics.draw(self.data.screen,0,0)
    love.graphics.setColor(0,60,0,100)
    love.graphics.rectangle('fill',0,0,w,h)
    love.graphics.setColor(0,255,0,255)
    love.graphics.print(self.data.message, self.data.textpos.x, self.data.textpos.y)
    -- scale font for button rendering - hackish
    if not self.data.button.image then
        love.graphics.setFont(30)
        self.data.button:draw()
        love.graphics.setFont(50)
    else
        self.data.button:draw()
    end

    particles.draw()
end,

update = function(self, dt)
    particles.update(dt)
    self.data.button:update(dt)
end

}
