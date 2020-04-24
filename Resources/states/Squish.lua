local State = require("Resources.scripts.State").new("Squish")
State.Enter=function(owner)
	owner.sprite.inAir=false;
    owner.sprite.localPosition=vector.zero
	owner:loadTree("squish",true)
end

State.Update=function(owner,dt) 
	if(owner.currentTree.currentAnimation:getFrame()==5)then
		owner:changeState("Squished")
	end
end

State.Exit=function(owner) 
end


return State