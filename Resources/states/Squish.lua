local State = require("Resources.scripts.State").new("Squish")
State.Enter=function(owner)
	owner.sprite.inAir=false;
    owner.sprite.localPosition=vector.zero
	owner:loadTree("squish",true,false)
end

State.Update=function(owner,dt) 
	
end

State.Exit=function(owner) 
end


return State