gamestate = {}
function gamestate.new(st)
	local state = {
		enter          = st.enter or function() end,
		leave          = st.leave or function() end,
		update         = st.update or function() end,
		draw           = st.draw or function() end,
		onkey          = st.onkey or function() end,
		mousereleased = st.mousereleased or function() end,
		data           = st.data or {},
		is_initalized  = false,
	}
	state.init = function(s)
		if st.init then st.init(state) end
		s.is_initalized = true
	end
	return state
end

function gamestate.switch(to, options)
	if not to then return end
	if gamestate.current then
		gamestate.current:leave()
	end
	if not to.is_initalized then
		to:init()
	end
	gamestate.current = to
	gamestate.current:enter(options)
end
