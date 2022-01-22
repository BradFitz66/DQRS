local State = require("Resources.lib.Rocket_Engine.State").new("Squish")
State.Enter=function(owner)
	owner.sprite.in_air=false;
    owner.sprite.local_position=vector.new(0,0)
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