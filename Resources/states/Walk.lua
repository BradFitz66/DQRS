local State = require("Resources.scripts.State").new("Walk")
State.Enter=function(owner)
	owner:loadTree("walk",false,false)
end

State.Update=function(owner,dt) 
	
	if(owner.moveVector~=vector.zero) then
		owner.position=owner.position+owner.moveVector;
		owner.currentTree.vector=owner.moveVector;
	else
		owner.statemachine:changeState("Idle")
    end
end

State.Exit=function(owner) 

end


return State