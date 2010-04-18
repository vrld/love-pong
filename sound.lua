require "moan"
sound = {}

sound.samples = {
	ping = love.audio.newSource(Moan.newSample(Moan.envelope(
	Moan.signal(Moan.triangle, 540, .5),
	Moan.decrease(.2)), .2)),

	pong = love.audio.newSource(Moan.newSample(Moan.envelope(
	Moan.signal(Moan.triangle, 500, .5),
	Moan.decrease(.2)), .2)),

	goal_left = love.audio.newSource(Moan.newSample(function(t)
		if t < .175 then
			return Moan.triangle(440*t) * math.max(1-t/.15,0) * .5
		end
		t = t - .175
		if t < .175 then
			return Moan.triangle(660*t) * math.max(1-t/.15,0) * .5
		end
		t = t - .175
		return Moan.triangle(880*t) * math.max(1-t/.15,0) * .5
	end, .5)),

	goal_right = love.audio.newSource(Moan.newSample(function(t)
		if t < .175 then
			return Moan.triangle(880*t) * math.max(1-t/.15,0) * .5
		end
		t = t - .175
		if t < .175 then
			return Moan.triangle(660*t) * math.max(1-t/.15,0) * .5
		end
		t = t - .175
		return Moan.triangle(440*t) * math.max(1-t/.15,0) * .5
	end, .5)),

	select = love.audio.newSource(Moan.newSample(Moan.envelope(
	Moan.signal(Moan.sin,2640,.7),
	Moan.decrease(.01)), .01)),

	click = love.audio.newSource(Moan.newSample(Moan.envelope(
	Moan.signal(Moan.noise, 1, .4),
	Moan.decrease(.005)), .005)),
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
