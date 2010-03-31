sound = {}
function sound.newSample(len, gen)
    local samples = math.floor(len * 44100)
    local data = love.sound.newSoundData(samples, 44100, 16, 1)
    for i=1,samples do
        local t = i / 44100
        data:setSample(i, gen(t))
    end
    return data
end

function sound.rect(x) 
    local x = x % 1
    if x > .5 then return 1 else return -1 end
end

function sound.triangle(x)
    local x = x % 1
    if x < .5 then return 4*x-1 else return 3-4*x end
end

sound.samples = {
    ping = love.audio.newSource(sound.newSample(.2, function(t) 
        return sound.triangle(540*t) * (1-t/.2) * .5
    end)),

    pong = love.audio.newSource(sound.newSample(.2, function(t) 
        return sound.triangle(500*t) * (1-t/.2) * .5
    end)),

    goal_left = love.audio.newSource(sound.newSample(.5, function(t)
        if t < .175 then
            return sound.triangle(440*t) * math.max(1-t/.15,0) * .5
        end
        t = t - .175
        if t < .175 then
            return sound.triangle(660*t) * math.max(1-t/.15,0) * .5
        end
        t = t - .175
        return sound.triangle(880*t) * math.max(1-t/.15,0) * .5
    end)),

    goal_right = love.audio.newSource(sound.newSample(.5, function(t)
        if t < .175 then
            return sound.triangle(880*t) * math.max(1-t/.15,0) * .5
        end
        t = t - .175
        if t < .175 then
            return sound.triangle(660*t) * math.max(1-t/.15,0) * .5
        end
        t = t - .175
        return sound.triangle(440*t) * math.max(1-t/.15,0) * .5
    end)),

    select = love.audio.newSource(sound.newSample(.01, function(t)
        return math.sin(2*math.pi*2640*t) * math.max(1-t/.01, 0) * .7
    end)),

    click = love.audio.newSource(sound.newSample(.005, function(t)
        return (math.random()*2-1) * math.max(1-t/.005, 0) * .4
    end)),
}

local pingpong_player = coroutine.create(function()
    while true do
        for _,s in pairs{sound.samples.ping, sound.samples.pong} do
            love.audio.play(s)
            coroutine.yield()
        end
    end
end)

function sound.pingpong()
    coroutine.resume(pingpong_player)
end

function sound.goal(left_player)
    if left_player then
        love.audio.play(sound.samples.goal_left)
    else
        love.audio.play(sound.samples.goal_right)
    end
end

function sound.select()
    love.audio.play(sound.samples.select)
end

function sound.click()
    love.audio.play(sound.samples.click)
end
