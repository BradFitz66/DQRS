local State = require("Resources.lib.Rocket_Engine.State").new("Idle")
State.Enter=function(owner)
    owner:load_tree("idle",true)
end

State.Update=function(owner,dt) 
    if(owner.move_vector~=vector.new(0,0)) then
        owner:change_state("Walk")
    end
end

State.Exit=function(owner) 

end


return State