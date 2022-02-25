local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Hurt")
local db=false;
State.Enter=function(owner)
    if(owner.physics_data.in_air==false) then
        owner:change_state("Idle")
        return
    end
    owner:load_tree("hurt",true)
    owner.current_tree:set_vector(vector.new(owner.physics_data.velocity.x,owner.physics_data.velocity.z):normalized())
    db=false
end

State.Update=function(owner,dt)
    if(owner.physics_data.in_air==false) then
        timer.after(.25,function()
            if(db==true)then return end 
            db=true
            owner:change_state("Idle")
        end)
    end
end

State.Exit=function(owner) 

end


return State
