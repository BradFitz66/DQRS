local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Jump")
State.Enter=function(owner)

    if(not owner.physics_data.in_air) then
        owner.position.y=0
        owner.scale=vector.new(1,1)
        owner.rotation=0    
        owner:add_force(3)
    end
    owner:load_tree("jump",true)
end

State.Update=function(owner,dt) 
    if(owner.move_vector~=vector.new(0,0)) then
        
        owner.current_tree:set_vector(owner.move_vector);
		owner:set_position_planar(vector.new(
			owner.position.x+((owner.move_vector.x*owner.speed)*dt),
			owner.position.z+((owner.move_vector.y*owner.speed)*dt))
		);
    end
    if(not owner.physics_data.in_air) then
        if(owner.inside_bouncy) then
            owner:add_force(3)
        else
            owner:change_state("Idle")
        end
    end
end

State.Exit=function(owner) 

end


return State