local input = require("Resources.lib.Input")

local player_input=require("Resources.lib.Rocket_Engine.Systems.Handler"):new()


--[[
    Handle request. Request should always be the input_state table inside InputProvider.lua

    This handler should always be the first in the chain. This allows any other system to override move_vector and other controls to provide automated input for the player 
    (i.e. for cutscenes)
]]
player_input.request_handler=function(request) 
    local hori,vert=control_scheme:get 'move'
    request.move_vector=vector.new(hori,vert)
    request.space_down=control_scheme:down 'jump'
    request.space_up=control_scheme:released 'jump'
    request.action_down=control_scheme:pressed 'action'
    return request
end


return player_input