local State = require("Resources.scripts.State").new("Walk")
State.Enter=function(owner)
	owner:loadTree("walk",false,false)
	owner.sprite:AddForce(1.5)

end

State.Update=function(owner,dt) 
	owner.currentTree:setVector(owner.moveVector)
	if(owner.moveVector~=vector.new(0,0)) then
		owner.position=owner.position+owner.moveVector*owner.speed*dt;
	elseif owner.moveVector==vector.new(0,0) and (owner.currentTree.currentAnimation:getFrame()==11 and owner.currentTree.currentAnimation.delayTimer>=0.048)  then
		owner:changeState("Idle")
		return
	end
	
	if(owner.sprite.inAir==false and owner.currentTree.currentAnimation:getFrame()==1) then
		owner.sprite:AddForce(1.5)
	elseif owner.sprite.inAir and owner.currentTree.currentAnimation:getFrame()==1 then
		owner.sprite.inAir=false
		owner.sprite.localPosition=vector.new(0,0)
		owner.sprite:AddForce(1.5)
	end
end

State.Exit=function(owner) 
end


return State