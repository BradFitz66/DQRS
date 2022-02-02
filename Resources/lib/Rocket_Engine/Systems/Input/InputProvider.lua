--[[
    Input provider that uses chain of responsibility to provide input to various stuff.

    Allows more control over input and allows me to do stuff like steal control away from the player easily. Can even be reused for AI.
]]

local input_provider={}
input_provider.__index=input_provider
input_provider.states={

}
input_provider.input_state={
    move_vector,
    space_down,
    space_up,
    action_down,
    in_cutscene    
}
function input_provider:add_state(o)
    table.insert(self.states,1,o or error("No state passed"));
end
function input_provider:get_current_input_state()
    local input_state=table.copy(self.input_state)
    for _, state in pairs(self.states) do
        input_state=state:handle_request(input_state)
    end
    return input_state
end

return input_provider