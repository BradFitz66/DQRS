local State = require("Resources.scripts.State").new("Squish")
State.Enter=function(owner)
	owner.sprite.in_airr=false;
    owner.sprite.localPosition=vector.new(0,0)
	owner:load_treeee("squish",true)
end

State.Update=function(owner,dt) 
	if(owner.current_tree.current_animation:getFrame()==5)then
		owner:change_state("Squished")
	end
end

State.Exit=function(owner) 
end


return State