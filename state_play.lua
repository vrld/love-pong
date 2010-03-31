require "vector"
require "actors"
require "sound"
require "particles"
require "gamestate"


local controller = {}
function controller.mouse(p, dt)
    local d = (love.mouse.getY() - p.pos.y) * p.speed
    p:move(d*dt)
end

function controller.keyboard(up, down)
    return function(p, dt)
        if love.keyboard.isDown(up) then
            p:move(-p.speed)
        elseif love.keyboard.isDown(down) then
            p:move(p.speed)
        end
    end
end

function controller.predict_impact(state)
    return function(p, dt)
        local m = state.data.ball.direction.y / state.data.ball.direction.x
        m = m * (p.pos.x - state.data.ball.pos.x)
        m = m + state.data.ball.pos.y - p.pos.y
        local y = math.min(math.max(p.pos.y + m, 0), love.graphics.getHeight())
        p:move( (y - p.pos.y) * p.speed * dt )
    end
end

function controller.ballpos(state)
    return function(p, dt)
        local d = (state.data.ball.pos.y - p.pos.y) * p.speed
        p:move(d*dt)
    end
end

function controller.smart(state, is_left)
    local function towards_me(d)
        if is_left then return d < 0 end
        return d > 0
    end
    local predict = controller.predict_impact(state)
    local ballpos = controller.ballpos(state)

    return function(p, dt)
        local dx = math.abs(state.data.ball.pos.x - p.pos.x)
        if towards_me(state.data.ball.direction.x) and dx < love.graphics.getWidth() / 2 then
            predict(p, dt)
        else
            ballpos(p, dt)
        end
    end
end

gamestate.play = gamestate.new{

data = {
    paddle = {},
    ball = nil,
    score = {0,0}
},

init = function(state)
    local padding = 20
    local size = vector.new(8, 40)
    local color = {0,150,0,255}

    state.data.ball = ball.new(vector.new(love.graphics.getWidth() / 2,
                               love.graphics.getHeight() / 2),
                    vector.new(math.random() * 2 - 1,
                               math.random() * 2 - 1),
                    9, 400, 1.05, color)

    state.data.ball.on_goal = function(left_player)
        sound.goal(left_player)
        if left_player then
            state.data.score[1] = state.data.score[1] + 1
        else
            state.data.score[2] = state.data.score[2] + 1
        end
    end
    state.data.ball.on_collision = function(pos)
        particles.spawn(pos, .3)
        sound.pingpong()
    end

    state.data.paddle[1] = paddle.new(vector.new(padding + size.x, love.graphics.getHeight()/2),
                            size, 7, color, controller.smart(state, true))

    state.data.paddle[2] = paddle.new(vector.new(love.graphics.getWidth() - padding - size.x,
                            love.graphics.getHeight()/2),
                            size, 7, color, controller.smart(state, false))
end,

enter = function(state, options)
    if not options then return end
    
    if options.reset then
        state.data.score = {0,0}
        state.data.ball.pos = vector.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        state.data.ball.direction = vector.new(1, math.random() - .5):normalized()
        if math.random() > .5 then
            state.data.ball.direction.x = -state.data.ball.direction.x
        end
        state.data.ball.speed = 400
        state.data.paddle[1].pos.y = love.graphics.getHeight()/2
        state.data.paddle[2].pos.y = love.graphics.getHeight()/2
    end

    local cpu_controller = {
        Easy = controller.ballpos,
        Normal = controller.smart,
        Hard = controller.smart,
    }
    local cpu_speed = {
        Easy = 10,
        Normal = 3,
        Hard = 7,
    }

    if options.players == 0 then
        state.data.paddle[1].controller = cpu_controller[options.difficulty](state, true)
        state.data.paddle[1].speed = cpu_speed[options.difficulty]
        state.data.paddle[2].controller = cpu_controller[options.difficulty](state, false)
        state.data.paddle[2].speed = cpu_speed[options.difficulty]
    elseif options.players == 1 then
        state.data.paddle[1].controller = controller.mouse
        state.data.paddle[1].speed = 7
        state.data.paddle[2].controller = cpu_controller[options.difficulty](state, false)
        state.data.paddle[2].speed = cpu_speed[options.difficulty]
    elseif options.players == 2 then
        state.data.paddle[1].controller = controller.keyboard('w','s')
        state.data.paddle[1].speed = 10
        state.data.paddle[2].controller = controller.keyboard('up','down')
        state.data.paddle[2].speed = 10
    end
end,

update = function(state, dt)
    if state.data.score[1] > 10 then
        gamestate.switch(gamestate.endgame, 1)
    elseif state.data.score[2] > 10 then
        gamestate.switch(gamestate.endgame, 2)
    end

    local px = (state.data.ball.pos.x - love.graphics.getWidth() / 2) / (love.graphics.getWidth() / 2)
    state.data.ball.radius = 12 + math.cos(px * math.pi) * 3
    state.data.ball:update(dt, state.data.paddle)

    for _,p in pairs(state.data.paddle) do
        p:controller(dt)
    end

    particles.update(dt)
end,

draw = function(state)
    local w,h = love.graphics.getWidth(), love.graphics.getHeight()
    local w2,h2 = w/2, h/2

    -- field
    love.graphics.setColor(0,100,0,255)
    love.graphics.setLineStipple(0x00FF, 2)
    love.graphics.line(w2, 5, w2, h-5)
    love.graphics.setLineStipple(0xFFFF)
    love.graphics.rectangle('line', 5, 5, w-10, h-9)

    -- paddles, particles, ball
    for _,p in pairs(state.data.paddle) do
        p:draw()
    end
    state.data.ball:draw()

    -- scoreboard
    love.graphics.setColor(0,100,0,100)
    love.graphics.rectangle('fill', w2 - 100,2, 200,32)
    love.graphics.setColor(0,255,0,255)
    love.graphics.printf(tostring(state.data.score[1]), w2 - 5, 25, 0, 'right')
    love.graphics.print(":", w2 - 3, 24)
    love.graphics.printf(tostring(state.data.score[2]), w2 + 5, 25, 0, 'left')

    particles.draw()
end,

onkey = function(state, key)
    if key == 'p' then
        gamestate.switch(gamestate.pause)
    elseif key == 'q' then
        gamestate.switch(gamestate.menu)
    end
end

}
