local input = require("Resources.lib.Input")

local player_input=require("Resources.lib.Rocket_Engine.Systems.Handler"):new()

player_input.request_handler=function(request) 
    local hori,vert=control_scheme:get 'move'
    request.move_vector=vector.new(hori,vert)
    
end


return player_input