require "state_menu.lua"
require "state_game.lua"
require "state_pause.lua"
require "state_finish.lua"
require "hook.lua"

Font = {}
function love.load()
	Font[20] = love.graphics.newFont(20)
	Font[30] = love.graphics.newFont(30)
	Font[60] = love.graphics.newFont(60)
	Font[120] = love.graphics.newFont(120)
	love.graphics.setFont(Font[20])
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(0,40,0)

	gamestate.switch(gamestate.menu)
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
