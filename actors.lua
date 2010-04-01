require "vector"

------- [[[ PADDLE ]]] ----------------------------------------------------
paddle = {}
paddle.__index = paddle
function paddle.new(pos, size, speed, color, controller)
    local p = {
        pos = pos or vector.new(20, 10),
        size = size or vector.new(8, 40),
        color = color or {0,0,0,255},
        speed = speed or .1,
        controller = controller or function() end
    }
    setmetatable(p, paddle)
    return p
end

function paddle.move(p, y)
    if p.pos.y + y < p.size.y then
        p.pos.y = p.size.y
    elseif p.pos.y + p.size.y + y > love.graphics.getHeight() then
        p.pos.y = love.graphics.getHeight() - p.size.y
    else
        p.pos.y = p.pos.y + y
    end
end

function paddle.draw(p)
    love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.color[4])
    love.graphics.rectangle('fill', p.pos.x - p.size.x, p.pos.y - p.size.y,
                                    p.size.x * 2, p.size.y * 2)
end

------- [[[ BALL ]]] ------------------------------------------------------
ball = {}
ball.__index = ball
function ball.new(pos, dir, radius, speed, speed_increase, color)
    local b = {
        pos = pos or vector.new(300,400),
        direction = dir or vector.new(1,1), 
        radius = radius or 10,
        speed = speed or 1,
        orig_speed = speed or 1,
        speed_increase = speed_increase,
        color = color,
        on_collision = function() end,
        on_goal = function() end}
    setmetatable(b, ball)
    return b
end

function ball.wall_collision(b)
    if b.pos.y < b.radius then
        return true, vector.new(0, 1) end
    if b.pos.y > love.graphics.getHeight() - b.radius then
        return true, vector.new(0,-1) end
    if b.pos.x < b.radius then
        return true, vector.new( 1,0) end
    if b.pos.x > love.graphics.getWidth() - b.radius then
        return true, vector.new(-1,0) end
    return false
end

function ball.paddle_collision(b, p)
    if b.pos.y < p.pos.y - p.size.y then return false end
    if b.pos.y > p.pos.y + p.size.y then return false end

    if math.abs(b.pos.x - p.pos.x) > b.radius + p.size.x / 2 then
        return false end

    local displacement = vector.new(p.size.x, 0)
    if p.pos.x < love.graphics.getWidth() / 2 then -- left paddle
        displacement = displacement * -1 end

    local d = b.pos - (p.pos + displacement)
    d.y = d.y / 15
    d:normalize_inplace()
    return true, d
end

local function sign(x) if x > 0 then return 1 elseif x < 0 then return -1 end return 0 end
function ball.reflect(b, n)
    local projected = n* (b.direction * n)
    b.direction = b.direction - 2 * projected
end

function ball.update(b, dt, paddles)
    b.pos = b.pos + b.direction * b.speed * dt
    local collides, normal = b:wall_collision()
    if collides then
        if normal.y == 0 then
            b.on_goal(normal.x < 0)
            -- reset ball
            b.pos = vector.new(love.graphics.getWidth()/2, 
                               love.graphics.getHeight()/2)
            local phi = math.random() * math.pi/2 - math.pi/4
            b.direction.x = -sign(b.direction.x) * math.cos(phi)
            b.direction.y = math.sin(phi)

            b.speed = b.orig_speed
        else
            b.on_collision(b.pos)
            b:reflect(normal)
            if b.pos.y - b.radius <= 0 then 
                b.pos.y = b.radius + 1 end
            if b.pos.y - b.radius >= love.graphics.getHeight() then 
                b.pos.y = love.graphics.getHeight() - b.radius - 2 end
        end
        return
    end

    for _, p in pairs(paddles) do
        collides, normal = b:paddle_collision(p)
        if collides then 
            b.on_collision(b.pos)
            b.speed = b.speed * b.speed_increase
            b:reflect(normal) 
            b.pos.x = p.pos.x + (p.size.x + b.radius) * sign(b.direction.x)
            return
        end
    end
end

function ball.draw(b)
    love.graphics.setColor(b.color[1], b.color[2], b.color[3], b.color[4])
--    love.graphics.circle('fill', b.pos.x, b.pos.y, b.radius, 10)
    love.graphics.rectangle('fill', b.pos.x-b.radius, b.pos.y-b.radius,
                                    2*b.radius, 2*b.radius)
end
