local State = require("Resources.lib.Rocket_Engine.State").new("Jump")
State.Enter=function(owner)

    if(not owner.sprite.in_air) then
        owner.sprite.local_position=vector.new(0,0)
        owner.scale=vector.new(1,1)
        owner.rotation=0    
        owner.sprite:add_force(3)
    end
    owner:load_tree("jump",true)
end

State.Update=function(owner,dt) 
    if(owner.move_vector~=vector.new(0,0)) then
        
        owner.current_tree:set_vector(owner.move_vector);
        owner.position = owner.position + owner.move_vector*owner.speed*dt;
    end
    if(not owner.sprite.in_air) then
        if(owner.inside_bouncy) then
            owner.sprite:add_force(3)
        else
            owner:change_state("Idle")
        end
    end
end

State.Exit=function(owner) 

end


return State