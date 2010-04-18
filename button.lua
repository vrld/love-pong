require "vector"
require "hook"

button = {}
button.__index = button
function button:is_hovered(x, y)
	return (x > self.pos.x - self.size.x/2) and
	(x < self.pos.x + self.size.x/2) and
	(y > self.pos.y - self.size.y/2) and
	(y < self.pos.y + self.size.y/2)
end

local function unpack_color(color)
	return color[1], color[2], color[3], color[4]
end

function button:draw()
	if not self.is_visible then return end

	local textalign = vector.new(Font[30]:getWidth(self.text), -Font[30]:getHeight(self.text) + 6) / 2

	if self.is_entered then
		love.graphics.setColor(unpack_color(self.color_hovered))
	else
		love.graphics.setColor(unpack_color(self.background))
	end

	local px, py = (self.pos - self.size/2):unpack()
	love.graphics.rectangle('fill', px, py, self.size:unpack())
	love.graphics.setColor(unpack_color(self.textcolor))
	love.graphics.print(self.text, (self.pos - textalign):unpack())
	love.graphics.rectangle('line', px, py, self.size:unpack())
end

function button:update(dt)
	if not self.is_visible then return end
	local hover = self:is_hovered(love.mouse.getPosition())

	if hover and not self.is_entered then
		self:onenter()
	elseif not hover and self.is_entered then
		self:onleave()
	end

	self.is_entered = hover
end

function button:hide()
	self.is_visible = false
end

function button:show()
	self.is_visible = true
end

function button.new(b)
	local btn = {
		pos = b.pos or vector.new(200,200),
		size = b.size or vector.new(20,10),
		text = b.text or "o_O",
		onclick = b.onclick or function() end,
		onenter = b.onenter or function() end,
		onleave = b.onleave or function() end,
		background = b.background or {0,40,10,255},
		textcolor = b.textcolor or {0,128,0,255},
		is_entered = false,
		is_visible = true,
		image = nil,
	}

	local hovermul = b.hovermul or 1.6
	btn.color_hovered = {
		math.min(btn.background[1] * hovermul, 255),
		math.min(btn.background[2] * hovermul, 255),
		math.min(btn.background[3] * hovermul, 255),
	}
	function btn:mouse(x,y,b)
		if b ~= 'l' then return end
		if self:is_hovered(x,y) then
			self:onclick()
		end
	end
	setmetatable(btn, button)
	return btn
end

