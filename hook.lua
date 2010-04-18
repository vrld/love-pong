hook = {}
hook.__index = hook
function hook:add(fun)
    if type(fun) == "function" then
        self[fun] = fun
    end
end

function hook:remove(fun)
    self[fun] = nil
end

function hook:exec(...)
    for f,_ in pairs(self) do
        f(...)
    end
end

function hook.register(name, fun)
    h = {}
    setmetatable(h, hook)
    h:add(fun)
    hook[name] = h
    return h
end
