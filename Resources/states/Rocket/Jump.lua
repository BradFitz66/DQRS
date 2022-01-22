local State = require("Resources.lib.Rocket_Engine.State").new("Jump")
State.Enter=function(owner)
    owner.sprite.in_air=false;
    owner.sprite.local_position=vector.new(0,0)
    owner.sprite:add_force(3)
    owner.scale=vector.new(1,1)
    owner.rotation=0
    owner:load_tree("jump",true)
end

State.Update=function(owner,dt) 
    if(owner.move_vector~=vector.new(0,0)) then
        
        owner.current_tree:set_vector(owner.move_vector);
        owner.position = owner.position + owner.move_vector*owner.speed*dt;
    end
    if(owner.sprite.in_air==false) then
        owner:change_state("Idle")
    end
end

State.Exit=function(owner) 

end


return State