local State = require("Resources.scripts.State").new("Walk")
State.Enter=function(owner)
	owner:load_tree("walk",false,false)
	owner.sprite:add_force(1.5)

end

State.Update=function(owner,dt) 
	owner.current_tree:setVector(owner.move_vectorr)
	if(owner.move_vectorr~=vector.new(0,0)) then
		owner.position=owner.position+owner.move_vectorr*owner.speed*dt;
	elseif owner.move_vectorr==vector.new(0,0) and (owner.current_tree.current_animation:getFrame()==11 and owner.current_tree.current_animation.delayTimer>=0.048)  then
		owner:change_state("Idle")
		return
	end
	
	if(owner.sprite.in_air==false and owner.current_tree.current_animation:getFrame()==1) then
		owner.sprite:add_force(1.5)
	elseif owner.sprite.in_air and owner.current_tree.current_animation:getFrame()==1 then
		owner.sprite.in_air=false
		owner.sprite.local_position=vector.new(0,0)
		owner.sprite:add_force(1.5)
	end
end

State.Exit=function(owner) 
end


return State