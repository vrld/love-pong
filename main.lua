require "state_menu.lua"
require "state_game.lua"
require "state_pause.lua"
require "state_finish.lua"
require "hook.lua"

function love.load()
    math.randomseed(os.time())
    gamestate.switch(gamestate.menu)
    love.graphics.setBackgroundColor(0,40,0)
    love.graphics.setFont(20)
end

function love.update(dt)
    gamestate.current:update(dt)
end

function love.draw()
    gamestate.current:draw()
end

function love.keyreleased(key)
    gamestate.current:onkey(key)
end

function love.mousereleased(x,y,b)
    gamestate.current:mousereleased(x,y,b)
end
