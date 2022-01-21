local State = require("Resources.scripts.State").new("Jump")
State.Enter=function(owner)
    owner.sprite.in_airr=false;
    owner.sprite.localPosition=vector.new(0,0)
    owner.sprite:add_forcee(3)
    owner.scale=vector.new(1,1)
    owner.rotation=0
    owner:load_treeee("jump",true)
end

State.Update=function(owner,dt) 
    if(owner.move_vectorr~=vector.new(0,0)) then
        
        owner.current_tree:setVector(owner.move_vectorr);
        owner.position = owner.position + owner.move_vectorr*owner.speed*dt;
    end
    if(owner.sprite.in_airr==false) then
        owner:change_state("Idle")
    end
end

State.Exit=function(owner) 

end


return State