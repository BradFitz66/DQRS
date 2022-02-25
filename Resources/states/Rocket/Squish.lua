local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Squish")
State.Enter=function(owner)
	owner.physics_data.in_air=false;
    owner.position.y=0
	owner:load_tree("squish",true)
end

State.Update=function(owner,dt) 
	if(owner.current_tree.current_animation:getFrame()==5)then
		owner:change_state("Squished")
	end
end

State.Exit=function(owner) 
end


return State