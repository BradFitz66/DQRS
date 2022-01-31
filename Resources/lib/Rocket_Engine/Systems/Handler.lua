--[[
    Base for chain of responsibility

    Adapted from:
    https://github.com/woshihuo12/LuaDesignPattern/blob/master/responeChain.lua
]]


local Handler={}

function Handler:new(o)
    o=o or {}
    o.request_handler=function() end
    setmetatable(o,self)
    
    return o
end

function Handler:set_successor(o)
    self.successor=o
end


---Handle a request and pass it up the chain
---@param request any
function Handler:handle_request(request)
    self.request_handler(request)
    self.set_successor:handle_request(request)
end

return Handler