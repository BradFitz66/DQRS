local State = require("Resources.scripts.State").new("Walk")
State.Enter=function(owner)
	owner:loadTree("walk",false,false)
	owner.sprite:AddForce(1.5)

end

State.Update=function(owner,dt) 
	
	if(owner.moveVector~=vector.zero) then
		owner.position=owner.position+owner.moveVector*owner.speed;
		owner.currentTree.vector=owner.moveVector;
	else
		owner.statemachine:changeState("Idle")
	end
	if(owner.sprite.inAir==false and owner.currentTree.currentAnimation:getFrame()==1) then
		owner.sprite:AddForce(1.5)
	elseif owner.sprite.inAir and owner.currentTree.currentAnimation:getFrame()==1 then
		owner.sprite.inAir=false
		owner.sprite.localPosition=vector.zero
		owner.sprite:AddForce(1.5)
	end
end

State.Exit=function(owner) 
end


return State