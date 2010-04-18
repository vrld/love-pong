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
        if not p.holdingtime then p.holdingtime = 1 end
        p.holdingtime = p.holdingtime + dt * 2
        if love.keyboard.isDown(up) then
            p:move(-p.speed * p.holdingtime)
        elseif love.keyboard.isDown(down) then
            p:move(p.speed * p.holdingtime)
        else
            p.holdingtime = 1
        end
    end
end

function controller.predict_impact(self)
    return function(p, dt)
        local m = self.data.ball.direction.y / self.data.ball.direction.x
        m = m * (p.pos.x - self.data.ball.pos.x)
        m = m + self.data.ball.pos.y - p.pos.y
        local y = math.min(math.max(p.pos.y + m, 0), love.graphics.getHeight())
        p:move( (y - p.pos.y) * p.speed * dt )
    end
end

function controller.ballpos(self)
    return function(p, dt)
        local d = (self.data.ball.pos.y - p.pos.y) * p.speed
        p:move(d*dt)
    end
end

function controller.smart(self, is_left)
    local function towards_me(d)
        if is_left then return d < 0 end
        return d > 0
    end
    local predict = controller.predict_impact(self)
    local ballpos = controller.ballpos(self)

    return function(p, dt)
        local dx = math.abs(self.data.ball.pos.x - p.pos.x)
        if towards_me(self.data.ball.direction.x) and dx < love.graphics.getWidth() / 2 then
            predict(p, dt)
        else
            ballpos(p, dt)
        end
    end
end

gamestate.game = gamestate.new{

data = {
    paddle = {},
    ball = nil,
    score = {0,0}
},

init = function(self)
    local padding = 20
    local size = vector.new(8, 40)
    local color = {0,150,0,255}

    self.data.ball = ball.new(vector.new(love.graphics.getWidth() / 2,
                               love.graphics.getHeight() / 2),
                    vector.new(math.random() * 2 - 1,
                               math.random() * 2 - 1),
                    9, 400, 1.05, color)
    self.data.ball.direction:normalize_inplace()

    self.data.ball.on_goal = function(left_player)
        sound.goal(left_player)
        if left_player then
            self.data.score[1] = self.data.score[1] + 1
        else
            self.data.score[2] = self.data.score[2] + 1
        end
        love.graphics.setBackgroundColor(0,40,0)
    end
    self.data.ball.on_collision = function(pos)
        particles.spawn(pos, .3)
        sound.pingpong()
        local frac = self.data.ball.speed / self.data.ball.orig_speed
        local s = (frac - 1) / 4
        love.graphics.setBackgroundColor(s * 80, math.max((1 - s) * 40, 0), 0)
    end

    self.data.paddle[1] = paddle.new(vector.new(padding + size.x, love.graphics.getHeight()/2),
                            size, 7, color, controller.smart(self, true))

    self.data.paddle[2] = paddle.new(vector.new(love.graphics.getWidth() - padding - size.x,
                            love.graphics.getHeight()/2),
                            size, 7, color, controller.smart(self, false))
end,

enter = function(self, options)
    self.data.timeout = 2.9
    if not options then return end
    
    if options.reset then
        self.data.score = {0,0}
        self.data.ball.pos = vector.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        self.data.ball.direction = vector.new(1, math.random() - .5):normalized()
        if math.random() > .5 then
            self.data.ball.direction.x = -self.data.ball.direction.x
        end
        self.data.ball.speed = 400
        self.data.paddle[1].pos.y = love.graphics.getHeight()/2
        self.data.paddle[2].pos.y = love.graphics.getHeight()/2
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
        self.data.paddle[1].controller = cpu_controller[options.difficulty](self, true)
        self.data.paddle[1].speed = cpu_speed[options.difficulty]
        self.data.paddle[2].controller = cpu_controller[options.difficulty](self, false)
        self.data.paddle[2].speed = cpu_speed[options.difficulty]
    elseif options.players == 1 then
        self.data.paddle[1].controller = controller.mouse
        self.data.paddle[1].speed = 7
        self.data.paddle[2].controller = cpu_controller[options.difficulty](self, false)
        self.data.paddle[2].speed = cpu_speed[options.difficulty]
    elseif options.players == 2 then
        self.data.paddle[1].controller = controller.keyboard('w','s')
        self.data.paddle[1].speed = 10
        self.data.paddle[2].controller = controller.keyboard('up','down')
        self.data.paddle[2].speed = 10
    end
end,

update = function(self, dt)
    particles.update(dt)
    if self.data.timeout > 1 then 
        self.data.timeout = self.data.timeout - dt
        return
    end

    if self.data.score[1] > 10 then
        gamestate.switch(gamestate.finish, 1)
    elseif self.data.score[2] > 10 then
        gamestate.switch(gamestate.finish, 2)
    end

    local px = (self.data.ball.pos.x - love.graphics.getWidth() / 2) / (love.graphics.getWidth() / 2)
    self.data.ball.radius = 12 + math.cos(px * math.pi) * 3
    self.data.ball:update(dt, self.data.paddle)

    for _,p in pairs(self.data.paddle) do
        p:controller(dt)
    end
end,

draw = function(self)
    local w,h = love.graphics.getWidth(), love.graphics.getHeight()
    local w2,h2 = w/2, h/2

    -- field
    love.graphics.setColor(0,100,0,255)
    love.graphics.setLineStipple(0x00FF, 2)
    love.graphics.line(w2, 5, w2, h-5)
    love.graphics.setLineStipple(0xFFFF)
    love.graphics.rectangle('line', 5, 5, w-10, h-9)

    -- paddles, particles, ball
    for _,p in pairs(self.data.paddle) do
        p:draw()
    end
    self.data.ball:draw()

    -- scoreboard
    love.graphics.setColor(0,100,0,100)
    love.graphics.rectangle('fill', w2 - 100,2, 200,32)
    love.graphics.setColor(0,255,0,255)
    love.graphics.printf(tostring(self.data.score[1]), w2 - 5, 25, 0, 'right')
    love.graphics.print(":", w2 - 3, 24)
    love.graphics.printf(tostring(self.data.score[2]), w2 + 5, 25, 0, 'left')

    if self.data.timeout > 1.3 then
        love.graphics.setFont(60)
        rsg = {"go!", "ready?"}
        love.graphics.printf(rsg[math.floor(self.data.timeout)], w2, h2-100, 0, 'center')
        love.graphics.setFont(20)
    end

    particles.draw()
end,

onkey = function(self, key)
    if key == 'p' then
        gamestate.switch(gamestate.pause)
    elseif key == 'q' then
        gamestate.switch(gamestate.menu)
    end
end

}
