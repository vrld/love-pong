require "vector"

particles = {}
particles.systems = {}
particles.sprite = love.image.newImageData(8,8)
particles.sprite:mapPixel(function(x,y)
    local dist = math.max(1 - vector.dist(vector.new(x,y), vector.new(3.5,3.5)) / 3, 0)
    return dist * 128 + 127, 255, 0, dist * 128
end)
particles.sprite = love.graphics.newImage(particles.sprite)

function particles.spawn(pos, lifetime, spread, direction)
    local p = love.graphics.newParticleSystem(particles.sprite, 200)
    local lifetime = lifetime or .5
    local spread = spread or 2 * math.pi
    p:setPosition(pos.x, pos.y)
    p:setEmissionRate(200)
    p:setParticleLife(.4,1)
    p:setSpread(spread)
    p:setSpeed(50,100)
    if direction then
        p:setDirection(direction.x, direction.y)
    end
    p:start()

    particles.systems[p] = {lifetime, 0}
    return p
end

function particles.update(dt)
    for sys, lt in pairs(particles.systems) do
        sys:update(dt)
        lt[2] = lt[2] + dt
        if lt[1] <= lt[2] and sys:isEmpty() then
            particles.systems[sys] = nil
        else
            sys:setEmissionRate(math.max((1-lt[2]/lt[1]) * 200, 0))
        end
    end
end

function particles.draw()
    for sys, _ in pairs(particles.systems) do
        love.graphics.draw(sys)
    end
end
