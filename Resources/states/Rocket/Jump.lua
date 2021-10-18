local State = require("Resources.scripts.State").new("Jump")
State.Enter=function(owner)
    owner.sprite.inAir=false;
    owner.sprite.localPosition=vector.new(0,0)
    owner.sprite:AddForce(3)
    owner.scale=vector.new(1,1)
    owner.rotation=0
    owner:loadTree("jump",true)
end

State.Update=function(owner,dt) 
    if(owner.moveVector~=vector.new(0,0)) then
        owner.currentTree.vector=owner.moveVector;
        owner.position = owner.position + owner.moveVector*owner.speed*dt;
    end
    if(owner.sprite.inAir==false) then
        owner:changeState("Idle")
    end
end

State.Exit=function(owner) 

end


return State