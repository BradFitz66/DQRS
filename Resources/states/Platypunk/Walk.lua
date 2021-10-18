local State = require("Resources.scripts.State").new("Walk")
State.Enter=function(owner)
	owner:loadTree("walk",false,false)
	owner.moveVector=vector.new(0,1)
end

State.Update=function(owner,dt)
	if(owner.position.dist(owner.position,owner.walkDest)<1) then
		owner:changeState("Idle")
	end
	owner.moveVector=(owner.walkDest-owner.position):normalized()*owner.speed
	owner.position=owner.position + owner.moveVector * dt
	if(owner.moveVector~=vector.new(0,0))then
		owner.currentTree.vector=owner.moveVector:normalized()
	end
end

State.Exit=function(owner)
end


return State