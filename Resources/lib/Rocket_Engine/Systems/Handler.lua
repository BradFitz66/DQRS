--[[
    Base for chain of responsibility

    Adapted from:
    https://github.com/woshihuo12/LuaDesignPattern/blob/master/responeChain.lua
]]


local Handler={}
Handler.__index={}
function Handler.new(o)
    local new_handler=setmetatable(o,Handler) or setmetatable({},Handler)

    new_handler.request_handler=function() end
    new_handler.successor=nil
    return new_handler
end

function Handler:set_successor(o)
    self.successor=o
end


---Handle a request and pass it up the chain
---@param request any
function Handler:handle_request(request)
    if(successor~=nil) then
        self.successor:handle_request(request)
        return
    end

    return self.request_handler(request)
end

return Handler