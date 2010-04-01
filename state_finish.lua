require "gamestate"
require "button"

gamestate.finish = gamestate.new {

enter = function(state, winner)
    state.data.screen = love.graphics.newScreenshot()
    state.data.screen = love.graphics.newImage(state.data.screen)
    state.data.winner = winner

    local btnpos = vector.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 100)
    state.data.button = button.new{
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

    state.data.message = string.format("Player %d wins!", state.data.winner)
    love.graphics.setFont(50)
    local font = love.graphics.getFont()
    local align = vector.new(font:getWidth(state.data.message), font:getHeight(state.data.message))
    state.data.textpos = vector.new(love.graphics.getWidth(), love.graphics.getHeight())/2
    state.data.textpos = state.data.textpos - align / 2

    love.mousereleased = function(x,y,b)
        if b ~= 'l' then return end
        if state.data.button:is_hovered(x,y) then
            state.data.button:onclick()
        end
        particles.spawn(vector.new(x,y), .3)
    end
end,

leave = function(state)
    love.mousereleased = function(x,y,b) end
    love.graphics.setFont(20)
end,

draw = function(state)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local w2, h2 = w/2,h/2
    love.graphics.draw(state.data.screen,0,0)
    love.graphics.setColor(0,60,0,100)
    love.graphics.rectangle('fill',0,0,w,h)
    love.graphics.setColor(0,255,0,255)
    love.graphics.setFont(50)
    love.graphics.print(state.data.message, state.data.textpos.x, state.data.textpos.y)
    love.graphics.setFont(20)
    state.data.button:draw()

    particles.draw()
end,

update = function(state, dt)
    particles.update(dt)
    state.data.button:update(dt)
end

}
