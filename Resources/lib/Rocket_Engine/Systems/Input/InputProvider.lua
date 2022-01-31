local input_provider={}
input_provider.__index=input_provider
input_provider.states={

}
input_provider.input_state={
    move_vector,
    mouse_delta,
    space_down,
    space_up,
    in_cutscene    
}
function input_provider:add_state(o)
    table.insert(self.states,o or error("No state passed"));
    
end

return input_provider